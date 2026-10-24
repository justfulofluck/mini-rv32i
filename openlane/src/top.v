`timescale 1ns / 1ps

module top(
    input wire clk,
    input wire rst_n,

    // Instruction memory Interface
    output wire [31:0] instr_addr,
    input wire [31:0] instr,

    // Data Memory Interface
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    input wire [31:0] data_rdata,
    output wire mem_read,
    output wire mem_write,
    output wire [3:0]  mem_write_mask
);

    // internal wires
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_imm;
    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire [31:0] pc_target;
    reg         branch_taken;

    //control signals
    wire reg_write;
    wire alu_src;
    wire mem_to_reg;
    wire branch;
    wire jump;
    wire jump_src;
    wire link;
    wire lui;
    wire auipc;
    wire [3:0] alu_ctrl;

    //datapath signals
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] imm_out;
    wire [31:0] alu_b_in;
    wire [31:0] alu_results;
    wire zero_flag;
    wire lt_flag;
    wire ltu_flag;
    reg  [7:0]  load_byte;
    wire [15:0] load_half;
    wire [31:0] load_data;
    wire [31:0] store_data;
    wire [31:0] reg_wr_data;

    // Instruction fields
    wire [4:0] rs1_addr = instr[19:15];
    wire [4:0] rs2_addr = instr[24:20];
    wire [4:0] rd_addr  = instr[11:7];
    wire [6:0] opcode   = instr[6:0];
    wire [2:0] funct3   = instr[14:12];
    wire [6:0] funct7   = instr[31:25];

    // 1. Program counter & PC next logic
    assign pc_plus_4     = pc_current + 32'd4;
    assign pc_imm        = pc_current + imm_out;
    assign branch_target = pc_imm;
    assign jump_target   = jump_src ? ((rs1_data + imm_out) & 32'hFFFF_FFFE) // JALR
                                    : pc_imm;                                // JAL

    // 6 branch types
    always @(*) begin
        case (funct3)
            3'b000: branch_taken =  zero_flag;   // BEQ
            3'b001: branch_taken = ~zero_flag;   // BNE
            3'b100: branch_taken =  lt_flag;     // BLT
            3'b101: branch_taken = ~lt_flag;     // BGE
            3'b110: branch_taken =  ltu_flag;    // BLTU
            3'b111: branch_taken = ~ltu_flag;    // BGEU
            default: branch_taken = 1'b0;
        endcase
    end

    assign pc_target = jump                    ? jump_target   :
                       (branch & branch_taken) ? branch_target :
                                                 pc_plus_4;

    assign pc_next = pc_target;

    pc u_pc(
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc_current)
    );

    assign instr_addr = pc_current;

    // 2. Control Unit
    control_unit u_control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .jump_src(jump_src),
        .link(link),
        .lui(lui),
        .auipc(auipc),
        .alu_ctrl(alu_ctrl)
    );

    // 3. Writeback mux + register file
    assign reg_wr_data = link       ? pc_plus_4 :
                         lui        ? imm_out   :
                         auipc      ? pc_imm    :
                         mem_to_reg ? load_data :
                                      alu_results;

    regfile u_regfile(
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_en(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .wr_data(reg_wr_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // 4. Immediate Generator
    imm_gen u_imm_gen(
        .instr(instr),
        .imm_out(imm_out)
    );

    // 5. ALU & Operand MUX
    assign alu_b_in = (alu_src) ? imm_out : rs2_data;

    alu u_alu(
        .a(rs1_data),
        .b(alu_b_in),
        .alu_ctrl(alu_ctrl),
        .result(alu_results),
        .zero(zero_flag),
        .lt(lt_flag),
        .ltu(ltu_flag)
    );

    // 6. Load data (byte / half / word + sign extend)
    always @(*) begin
        case (alu_results[1:0])
            2'b00: load_byte = data_rdata[7:0];
            2'b01: load_byte = data_rdata[15:8];
            2'b10: load_byte = data_rdata[23:16];
            2'b11: load_byte = data_rdata[31:24];
        endcase
    end

    assign load_half = alu_results[1] ? data_rdata[31:16] : data_rdata[15:0];

    assign load_data = (funct3 == 3'b000) ? {{24{load_byte[7]}}, load_byte}   // LB
                     : (funct3 == 3'b001) ? {{16{load_half[15]}}, load_half} // LH
                     : (funct3 == 3'b100) ? {24'b0, load_byte}               // LBU
                     : (funct3 == 3'b101) ? {16'b0, load_half}               // LHU
                     :                      data_rdata;                      // LW

    // 7. Store data + byte mask
    assign store_data = (funct3 == 3'b000) ? {4{rs2_data[7:0]}}   // SB
                      : (funct3 == 3'b001) ? {2{rs2_data[15:0]}}  // SH
                      :                      rs2_data;            // SW

    assign mem_write_mask = mem_write ? ((funct3 == 3'b000) ? (4'b0001 << alu_results[1:0]) :
                                         (funct3 == 3'b001) ? (alu_results[1] ? 4'b1100 : 4'b0011) :
                                                              4'b1111)
                                      : 4'b0000;

    // 8. Data memory output
    assign data_addr  = alu_results;
    assign data_wdata = store_data;

endmodule

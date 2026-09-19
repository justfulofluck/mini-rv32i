`timescale 1ns / 1ps

module top(
    input wire clk,
    input wire rst_n,

    // Instruction memory Interface
    output wire [31:0] instr_addr,
    input wire [31:0] instr,

    // Data Memoory Interface
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    input wire [31:0] data_rdata,
    output wire mem_read,
    output wire mem_write
);

    // internal wires
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_pluse_4;
    wire [31:0] branch_target;
    wire pc_sel;

    //control signals
    wire reg_write;
    wire alu_src;
    wire mem_to_reg;
    wire branch;
    wire [3:0] alu_ctrl;

    //datapath signals
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] imm_out;
    wire [31:0] alu_b_in;
    wire [31:0] alu_results;
    wire zero_flag;
    wire [31:0] reg_wr_data;

    // Instruction fileds
    wire [4:0] rs1_addr = instr[19:15];
    wire [4:0] rs2_addr = instr[24:20];
    wire [4:0] rd_addr = instr[11:7];
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // 1. progrmain counter & PC next logic
    assign pc_pluse_4 = pc_current + 32'd4;
    assign branch_target = pc_current + imm_out;
    assign pc_sel = branch & zero_flag;
    assign pc_next = (pc_sel) ? branch_target : pc_pluse_4;

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
        .alu_ctrl(alu_ctrl)        
    );

    // 3. regsiter file
    assign reg_wr_data = (mem_to_reg) ? data_rdata : alu_results;

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

    // 4. Immidate Genrator
    imm_gen u_imm_gen(
        .instr (instr),
        .imm_out(imm_out)
    );

    // 5. ALU & Operand MUX
    assign alu_b_in = (alu_src) ? imm_out : rs2_data;

    alu u_alu(
        .a(rs1_data),
        .b(alu_b_in),
        .alu_ctrl(alu_ctrl),
        .result(alu_results),
        .zero(zero_flag)
    );

    // 6. data memeory output
    assign data_addr = alu_results;
    assign data_wdata = rs2_data;

endmodule
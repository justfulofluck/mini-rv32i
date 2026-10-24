`timescale 1ns / 1ps

module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        branch,
    output reg        jump,
    output reg        jump_src,
    output reg        link,
    output reg        lui,
    output reg        auipc,
    output reg  [3:0] alu_ctrl
);

    // RISC-V standard opcodes
    localparam OP_R_TYPE = 7'b0110011; // add, sub, and, or, slt // r-type
    localparam OP_I_TYPE = 7'b0010011; // addi, andi, ori, slti // i-type
    localparam OP_LOAD   = 7'b0000011; // lw // load type
    localparam OP_STORE  = 7'b0100011; // sw // store type
    localparam OP_BRANCH = 7'b1100011; // beq, bne // branch type
    localparam OP_JAL    = 7'b1101111; // jal // jump type
    localparam OP_JALR   = 7'b1100111; // jalr // jump type
    localparam OP_LUI    = 7'b0110111; // lui // lui type
    localparam OP_AUIPC  = 7'b0010111; // auipc // auipc type

    reg [1:0] alu_op;

    // --- 1. Main Decoder ---
    always @(*) begin    
        reg_write  = 1'b0;
        alu_src    = 1'b0; // Register input
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0; // ALU result
        branch     = 1'b0;
        jump       = 1'b0;
        jump_src   = 1'b0;
        link       = 1'b0;
        lui        = 1'b0;
        auipc      = 1'b0;
        alu_op     = 2'b00; // R-type ALU op
        case (opcode)
            OP_R_TYPE: begin
                reg_write  = 1'b1;
                alu_src    = 1'b0; // Register input
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0; // ALU result
                branch     = 1'b0;
                jump       = 1'b0;
                jump_src   = 1'b0;
                link       = 1'b0;
                lui        = 1'b0;
                auipc      = 1'b0;
                alu_op     = 2'b10; // R-type ALU op
            end

            OP_I_TYPE: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1; // Immediate input
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                jump_src   = 1'b0;
                link       = 1'b0;
                lui        = 1'b0;
                auipc      = 1'b0;
                alu_op     = 2'b11; // I-type ALU op
            end

            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1; // Read from RAM
                mem_write  = 1'b0;
                mem_to_reg = 1'b1; // Memory to Reg
                branch     = 1'b0;
                jump       = 1'b0;
                jump_src   = 1'b0;
                link       = 1'b0;
                lui        = 1'b0;
                auipc      = 1'b0;
                alu_op     = 2'b00; // Address ADD
            end

            OP_STORE: begin
                reg_write  = 1'b0; // No register write
                alu_src    = 1'b1;
                mem_read   = 1'b0;
                mem_write  = 1'b1; // Write to RAM
                mem_to_reg = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                jump_src   = 1'b0;
                link       = 1'b0;
                lui        = 1'b0;
                auipc      = 1'b0;
                alu_op     = 2'b00; // Address ADD
            end

            OP_BRANCH: begin
                reg_write  = 1'b0;
                alu_src    = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                branch     = 1'b1;
                jump       = 1'b0;
                jump_src   = 1'b0;
                link       = 1'b0;
                lui        = 1'b0;
                auipc      = 1'b0;
                alu_op     = 2'b01; // SUB for Branch
            end

            OP_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                link      = 1'b1;
            end

            OP_JALR: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                jump        = 1'b1;
                jump_src    = 1'b1;
                link        = 1'b1;
                alu_op      = 2'b00; // rs1 + imm
            end

            OP_LUI: begin
                reg_write   = 1'b1;
                lui         = 1'b1;
            end

            OP_AUIPC: begin
                reg_write   = 1'b1;
                auipc       = 1'b1;
            end

            default: begin
                reg_write  = 1'b0;
                alu_src    = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                jump_src   = 1'b0;
                link       = 1'b0;
                lui        = 1'b0;
                auipc      = 1'b0;
                alu_op     = 2'b00;
            end
        endcase
    end

    // --- 2. ALU Decoder ---
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000; // ADD for Load/Store
            2'b01: alu_ctrl = 4'b0001; // SUB for Branch

            2'b10: begin // R-Type
                case (funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? 4'b0001 : 4'b0000; // sub : add
                    3'b001: alu_ctrl = 4'b1000; // SLL
                    3'b010: alu_ctrl = 4'b0110; // SLT
                    3'b011: alu_ctrl = 4'b0111; // SLTU
                    3'b100: alu_ctrl = 4'b0101; // XOR
                    3'b101: alu_ctrl = (funct7[5]) ? 4'b1010 : 4'b1001; // SRL : SRL
                    3'b110: alu_ctrl = 4'b0100; // OR
                    3'b111: alu_ctrl = 4'b0011; // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            2'b11: begin // I-Type
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b001: alu_ctrl = 4'b1000; // SLLI
                    3'b010: alu_ctrl = 4'b0110; //SLTI
                    3'b011: alu_ctrl = 4'b0111; //SLTIU
                    3'b100: alu_ctrl = 4'b0101; // XORI
                    3'b101: alu_ctrl = (funct7[5]) ? 4'b1010 : 4'b1001; // SRAI : SRLI
                    3'b110: alu_ctrl = 4'b0100; // ORI
                    3'b111: alu_ctrl = 4'b0011; // ANDI
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule
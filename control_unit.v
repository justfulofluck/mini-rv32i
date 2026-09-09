`timescale 1ns / 1ps

module contorl_unit(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg [3:0] alu_ctrl 
);
    // RISC-V standard opcode
    localparam OP_R_TYPE = 7'b0110011; // add, sub, and, or, slt
    localparam OP_I_TYPE = 7'b0010011; // addi, andi, ori, slti
    localparam OP_LOAD = 7'b0000011; // lw
    localparam OP_STORE = 7'b0100011; // sw
    localparam OP_BRANCH = 7'b1100011; // beq, bne

    // 2-bit internal ALIOp
    reg [1:0] alu_op;

    // 1. Main Decoder
    always@(*) begin
        case (opcode)
            OP_R_TYPE: begin
                reg_write = 1'b1;
                alu_src = 1'b0; // read form register
                mem_read = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0; // ALU reult sae to register
                branch = 1'b0;
                alu_op = 2'b10; // R-type math
            end

            OP_I_TYPE: begin
                reg_write = 1'b1;
                alu_src = 1'b1; // read from 
                mem_read = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0; // ALU reult sae to register
                branch = 1'b0;
                alu_op = 2'b11; // R-type math
            end

            OP_LOAD: begin
                reg_write = 1'b1;
                alu_src = 1'b1; // read from memory
                mem_read = 1'b1;
                mem_write = 1'b0;
                mem_to_reg = 1'b1; // 
                branch = 1'b0;
                alu_op = 2'b00; // R-type math
            end

            OP_STORE: begin
                reg_write = 1'b1;
                alu_src = 1'b1; // read from memory
                mem_read = 1'b1;
                mem_write = 1'b0;
                mem_to_reg = 1'b1; // 
                branch = 1'b0;
                alu_op = 2'b00; // R-type math
            end

            OP_BRANCH: begin
                reg_write = 1'b1;
                alu_src = 1'b1; // read from memory
                mem_read = 1'b1;
                mem_write = 1'b0;
                mem_to_reg = 1'b1; // 
                branch = 1'b0;
                alu_op = 2'b01; // R-type math
            end

            default: begin
                reg_write = 1'b0;
                alu_src = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                branch = 1'b0;
                alu_op = 2'b00;
            end
        endcase
    end
    
    // 2. ALU Decoder
    always @(*) begin
        case(alu_op)
        2'b00: alu_ctrl = 4'b0000;
        2'b01: alu_ctrl = 4'b0001;

        2'b10; begin
            case (funct3)
                3'b000: alu_ctrl = (funct7[5]) ? 4'b0000;
                3'b111: alu_ctrl = 4'b0010;
                3'b110: alu_ctrl = 4'b0011;
                3'b100: alu_ctrl = 4'b0100;
                3'b010: alu_ctrl = 4'b0101;
                3'b011: alu_ctrl = 4'b0110;
                3'b001: alu_ctrl = 4'b0111;
                3'b100: alu_ctrl = (funct7[5]) ? 4'b1001 : 4'b1000;
                default: alu_ctrl = 4'b0000;
            endcase
        end
    
        2'b11; begin
            case (funct3)
                3'b000: alu_ctrl = 4'b0000;
                3'b111: alu_ctrl = 4'b0010;
                3'b110: alu_ctrl = 4'b0011;
                3'b100: alu_ctrl = 4'b0100;
                3'b010: alu_ctrl = 4'b0101;
                3'b011: alu_ctrl = 4'b0110;
                3'b001: alu_ctrl = 4'b0111;
                3'b100: alu_ctrl = (funct7[5]) ? 4'b1001 : 4'b1000;
                default: alu_ctrl = 4'b0000;
            endcase
        end

        default: alu_ctrl = 4'b0000;
        endcase
    end
    
endmodule
`timescale 1ns / 1ps

module imm_gen(
    input wire [31:0] instr,
    output reg [31:0] imm_out
);

    wire [6:0] opcode = instr[6:0];

    // RISC-V standard opcode
    localparam OPCODE_I_ARITH = 7'b0010011; // addi, andi, or i, xori 
    localparam OPCODE_I_LOAD = 7'b0000011; // lw, lh, lb
    localparam OPCODE_I_JALR = 7'b1100111; // JALR
    localparam OPCODE_S = 7'b0100011; // sw, sh, sb
    localparam OPCODE_B = 7'b1100011; // beq, ben, etc.
    localparam OPCODE_U_LUI = 7'b0110111; //lui
    localparam OPCODE_U_AUIPC = 7'b0010111; //auipc
    localparam OPCODE_J = 7'b1101111; // jal

    always @(*) begin
        case (opcode)
            OPCODE_I_ARITH,
            OPCODE_I_LOAD,
            OPCODE_I_JALR: begin
                imm_out = {{20{instr[31]}},instr[31:20]};
            end

            OPCODE_S: begin
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            OPCODE_B: begin
                imm_out = {{20{instr[31]}}, instr[7], instr[11:7]};
            end

            OPCODE_U_LUI,
            OPCODE_U_AUIPC: begin
                imm_out = {instr[31:12], 12'b0};
            end

            OPCODE_J: begin
                imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            default: begin
                imm_out = 32'd0;
            end
        endcase
    end
endmodule
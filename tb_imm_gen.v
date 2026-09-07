`timescale 1ns / 1ps

module tb_imm_gen;
    reg [31:0] instr;
    wire [31:0] imm_out;

    imm_gen uut (
        .instr(instr),
        .imm_out(imm_out)
    );

    initial begin
        $dumpfile("imm_out.vcd");
        $dumpvars(0,tb_imm_gen);

        // Test 1: I-Type (addi x1, x0, 15) -> imm = 15
        // instr = [12'd15, 5'd0, 3'b000, 5'd1, 7'b0010011]
        instr = 32'h00F00093;
        #10;
        $display("I-type TEST: instr=0x%h | imm_out=%0d (Expected: 15)", instr, $signed(imm_out));
        if($signed(imm_out) == 15) $display("PASS"); else $display("FAIL");

        // Test 2: I-Type Negative (addi x1, x0, -5) -> imm = -5
        // -5 in 12-bit is 0xFFB
        instr = 32'hFFB00093;
        #10;
        $display("Itype Negative: instr=0x%h | imm_out=%0d (Expected: -5)", instr, $signed(imm_out));

        // Test 3: S-Type (sw x2, 8(x1)) -> imm = 8
        // imm[11:5]=0, imm[4:0]=8, opcode=7'b0100011
        instr = 32'h0020A423;
        #10;
        $display("S-Type Test: instr=0x%h | imm_out=%d (expected 8)", instr, $signed(imm_out));

        $finish;
    end
endmodule

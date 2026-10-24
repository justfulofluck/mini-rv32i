`timescale 1ns / 1ps

module tb_imm_gen;

    reg  [31:0] instr;
    wire [31:0] imm_out;

    integer errors;

    imm_gen uut (
        .instr(instr),
        .imm_out(imm_out)
    );

    task check;
        input [31:0]  ins;
        input [31:0]  exp;
        input [255:0] name;
        begin
            instr = ins;
            #1;
            if (imm_out !== exp) begin
                $display("FAIL %0s: instr=0x%h imm=0x%h expected=0x%h", name, ins, imm_out, exp);
                errors = errors + 1;
            end else begin
                $display("PASS %0s: imm=0x%h (%0d)", name, imm_out, $signed(imm_out));
            end
        end
    endtask

    initial begin
        $dumpfile("imm_out.vcd");
        $dumpvars(0, tb_imm_gen);

        errors = 0;

        // ---------------- I-type ----------------
        check(32'h00F00093, 32'h0000000F, "I-type ADDI +15");
        check(32'hFFB00093, 32'hFFFFFFFB, "I-type ADDI -5");
        check(32'h80000093, 32'hFFFFF800, "I-type ADDI -2048");

        // ---------------- S-type ----------------
        check(32'h0020A423, 32'h00000008, "S-type SW +8");
        check(32'hFE20AC23, 32'hFFFFFFF8, "S-type SW -8");

        // ---------------- B-type ----------------
        check(32'h00208463, 32'h00000008, "B-type BEQ +8");
        check(32'hFE208CE3, 32'hFFFFFFF8, "B-type BEQ -8");

        // ---------------- U-type (LUI / AUIPC) ----------------
        check(32'h123450B7, 32'h12345000, "LUI 0x12345");
        check(32'h12345097, 32'h12345000, "AUIPC 0x12345");
        check(32'hFFFFF0B7, 32'hFFFFF000, "LUI 0xFFFFF");

        // ---------------- J-type (JAL) ----------------
        check(32'h008000EF, 32'h00000008, "JAL +8");
        check(32'hFFDFF0EF, 32'hFFFFFFFC, "JAL -4");
        check(32'h7FF7F0EF, 32'h0007FFFE, "JAL max +");
        check(32'h800800EF, 32'hFFF80000, "JAL max -");

        // ---------------- JALR (I-type) ----------------
        check(32'h008100E7, 32'h00000008, "JALR +8");
        check(32'hFF8100E7, 32'hFFFFFFF8, "JALR -8");

        // ---------------- unknown opcode ----------------
        check(32'h00000000, 32'h00000000, "unknown opcode");

        // ---------------- summary ----------------
        $display("----------------------------------------");
        if (errors == 0)
            $display("IMM_GEN TEST SUMMARY: ALL TESTS PASSED");
        else
            $display("IMM_GEN TEST SUMMARY: %0d TEST(S) FAILED", errors);
        $display("----------------------------------------");

        $finish;
    end

endmodule

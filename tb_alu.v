`timescale 1ns / 1ps

module tb_alu;

    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;
    wire        lt;
    wire        ltu;

    integer errors;

    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero),
        .lt(lt),
        .ltu(ltu)
    );

    // ---- result + zero checker ----
    task check;
        input [3:0]   ctrl;
        input [31:0]  x, y, exp;
        input [255:0] name;
        begin
            a = x; b = y; alu_ctrl = ctrl;
            #1;
            if (result !== exp) begin
                $display("FAIL %0s: a=%0d b=%0d result=%0d expected=%0d", name, x, y, result, exp);
                errors = errors + 1;
            end else begin
                $display("PASS %0s: result=%0d", name, result);
            end
        end
    endtask

    // ---- zero flag checker ----
    task check_zero;
        input [3:0]   ctrl;
        input [31:0]  x, y;
        input         exp;
        input [255:0] name;
        begin
            a = x; b = y; alu_ctrl = ctrl;
            #1;
            if (zero !== exp) begin
                $display("FAIL %0s: zero=%0b expected=%0b", name, zero, exp);
                errors = errors + 1;
            end else begin
                $display("PASS %0s: zero=%0b", name, zero);
            end
        end
    endtask

    // ---- lt / ltu checker ----
    task check_cmp;
        input [31:0]  x, y;
        input         exp_lt, exp_ltu;
        input [255:0] name;
        begin
            a = x; b = y; alu_ctrl = 4'b0001; // any ctrl, flags are combinational
            #1;
            if (lt !== exp_lt || ltu !== exp_ltu) begin
                $display("FAIL %0s: a=0x%h b=0x%h lt=%0b ltu=%0b expected lt=%0b ltu=%0b",
                         name, x, y, lt, ltu, exp_lt, exp_ltu);
                errors = errors + 1;
            end else begin
                $display("PASS %0s: lt=%0b ltu=%0b", name, lt, ltu);
            end
        end
    endtask

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, tb_alu);

        errors = 0;

        // ---------------- Arithmetic ----------------
        check(4'b0000, 32'd15,          32'd25,          32'd40,         "ADD");
        check(4'b0000, 32'hFFFFFFFF,    32'd1,           32'h00000000,   "ADD wrap");
        check(4'b0000, 32'h7FFFFFFF,    32'd1,           32'h80000000,   "ADD overflow");
        check(4'b0001, 32'd50,          32'd50,          32'd0,          "SUB equal");
        check(4'b0001, 32'd10,          32'd25,          32'hFFFFFFF1,   "SUB negative");

        // ---------------- Logic ----------------
        check(4'b0011, 32'hF0F0F0F0,    32'h0FF00FF0,    32'h00F000F0,   "AND");
        check(4'b0100, 32'hF0F0F0F0,    32'h0FF00FF0,    32'hFFF0FFF0,   "OR");
        check(4'b0101, 32'hF0F0F0F0,    32'h0FF00FF0,    32'hFF00FF00,   "XOR");

        // ---------------- Shifts ----------------
        check(4'b1000, 32'd1,           32'd31,          32'h80000000,   "SLL");
        check(4'b1001, 32'h80000000,    32'd4,           32'h08000000,   "SRL");
        check(4'b1010, 32'h80000000,    32'd4,           32'hF8000000,   "SRA");
        check(4'b1001, 32'hFFFFFFFF,    32'd32,          32'hFFFFFFFF,   "SRL shamt wrap");
        check(4'b1010, 32'hFFFFFFFF,    32'd33,          32'hFFFFFFFF,   "SRA shamt wrap");

        // ---------------- SLT / SLTU ----------------
        check(4'b0110, 32'd5,           32'd10,          32'd1,          "SLT 5<10");
        check(4'b0110, 32'd10,          32'd5,           32'd0,          "SLT 10<5");
        check(4'b0110, 32'hFFFFFFFB,    32'd3,           32'd1,          "SLT -5<3");
        check(4'b0111, 32'hFFFFFFFF,    32'd1,           32'd0,          "SLTU max<1");
        check(4'b0111, 32'd1,           32'hFFFFFFFF,    32'd1,          "SLTU 1<max");

        // ---------------- zero flag ----------------
        check_zero(4'b0001, 32'd42, 32'd42, 1'b1, "ZERO on equal SUB");
        check_zero(4'b0001, 32'd42, 32'd41, 1'b0, "ZERO on non-equal SUB");
        check_zero(4'b0000, 32'd0,  32'd0,  1'b1, "ZERO on 0+0");
        check_zero(4'b0101, 32'hAAAA5555, 32'hAAAA5555, 1'b1, "ZERO on XOR self");

        // ---------------- lt / ltu flags ----------------
        check_cmp(32'hFFFFFFFB, 32'd3,        1'b1, 1'b0, "CMP -5 vs 3");
        check_cmp(32'd3,        32'hFFFFFFFB, 1'b0, 1'b1, "CMP 3 vs -5");
        check_cmp(32'd7,        32'd7,        1'b0, 1'b0, "CMP equal");
        check_cmp(32'd0,        32'd1,        1'b1, 1'b1, "CMP 0 vs 1");

        // ---------------- summary ----------------
        $display("----------------------------------------");
        if (errors == 0)
            $display("ALU TEST SUMMARY: ALL TESTS PASSED");
        else
            $display("ALU TEST SUMMARY: %0d TEST(S) FAILED", errors);
        $display("----------------------------------------");

        $finish;
    end

endmodule

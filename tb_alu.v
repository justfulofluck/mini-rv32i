`timescale 1ns / 1ps
    
    module tb_alu; 
    
    reg [31:0] a, b;
    reg [3:0] alu_ctrl;
    wire [31:0] result;
    wire zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0,tb_alu);

        a = 32'd15;
        b = 32'd25;
        alu_ctrl = 4'b0000;
        #10;
        $display("ADD: a=%0d, b=%0d | result=%0d, zero=%0b", a, b, result, zero);

        a = 32'd50;
        b = 32'd50;
        alu_ctrl = 4'b0001;
        #10;
        $display("SUB: a=%0d, b=%0d | result=%0d, zero=%0b", a, b, result, zero);

        a = 32'd5;
        b = 32'd2;
        alu_ctrl = 4'b0101;
        #10;
        $display("XOR: a=%0d, b=%0d | result=%0d, zero=%0b", a, b, result, zero);

        a = 32'd20;
        b = 32'd10;
        alu_ctrl = 4'b0011;
        #10;
        $display("AND: a=%0d, b=%0d | result=%0d, zero=%0b", a, b, result, zero);

        a = 32'd15;
        b = 32'd25;
        alu_ctrl = 4'b0100;
        #10;
        $display("OR: a=%0d, b=%0d | result=%0d, zero=%0b", a, b, result, zero);

        a = 32'd20;
        b = 32'd10;
        alu_ctrl = 4'b0110;
        #10;
        $display("SLT: a=%0d, b=%0d | result=%0d, zero=%0b", a, b, result, zero);

        $finish;
    end

endmodule
`timescale 1ns / 1ps

module tb_regfile;

    reg clk;
    reg rst_n;
    reg reg_write_en;
    reg [4:0] rs1_addr, rs2_addr, rd_addr;
    reg [4:0] wr_data;
    wire [31:0] rs1_data, rs2_data;

    regfile uut (
        .clk(clk),
        .rd_addr(rd_addr),
        .rst_n(rst_n),
        .reg_write_en(reg_write_en),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .wr_data(wr_data)
    );

    // clock genration: 10ns period (100Mhz)
    always #5 clk = ~clk;

        initial begin
            $dumpfile("regfile.vcd");
            $dumpvars(0, tb_regfile);

        clk = 0;
        rst_n = 0;
        reg_write_en = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        wr_data = 0;

        // reset system
        #10 rst_n = 1;

        //test 1
        @(posedge clk);
        rd_addr = 5'd1;
        wr_data = 32'd100;
        reg_write_en = 1;
        @(posedge clk);
        reg_write_en = 0;

        // test 2
        @(posedge clk);
        rd_addr = 5'd2;
        wr_data = 32'd250;
        reg_write_en = 1;
        @(posedge clk);
        reg_write_en = 0;

        //test 3
        rs1_addr = 5'd1;
        rs1_addr = 5'd2;
        #2;
        $display("READ TEST: x1=%0d (Expected: 100), x2=%0d (Expected: 205)", rs1_addr, rs2_data); 

        //TEST 4
        @(posedge clk);
        rd_addr = 5'd0;
        wr_data = 32'd999;
        reg_write_en = 1;
        @(posedge clk);
        reg_write_en = 0;

        rs1_addr = 5'd0;
        #2;

        $display("ZERO REGISTER TEST: x0=%0d (Expected: 0)", rs1_data);        

        $finish;
end
endmodule
// Code your testbench here
// or browse Examples

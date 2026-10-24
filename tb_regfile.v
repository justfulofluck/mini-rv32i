`timescale 1ns / 1ps

module tb_regfile;

    reg  clk;
    reg  rst_n;
    reg  reg_write_en;
    reg  [4:0]  rs1_addr, rs2_addr, rd_addr;
    reg  [31:0] wr_data;
    wire [31:0] rs1_data, rs2_data;

    integer errors;

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

    // clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    task write_reg;
        input [4:0]  addr;
        input [31:0] data;
        begin
            @(negedge clk);
            rd_addr      = addr;
            wr_data      = data;
            reg_write_en = 1'b1;
            @(negedge clk);
            reg_write_en = 1'b0;
        end
    endtask

    task check_reg;
        input [4:0]   addr;
        input [31:0]  exp;
        input [255:0] name;
        begin
            rs1_addr = addr;
            #1;
            if (rs1_data !== exp) begin
                $display("FAIL %0s: x%0d = 0x%h expected 0x%h", name, addr, rs1_data, exp);
                errors = errors + 1;
            end else begin
                $display("PASS %0s: x%0d = 0x%h", name, addr, rs1_data);
            end
        end
    endtask

    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars(0, tb_regfile);

        errors = 0;
        clk = 0;
        rst_n = 0;
        reg_write_en = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr  = 0;
        wr_data  = 0;

        // reset
        #10 rst_n = 1;

        // write x1 = 100, x2 = 250
        write_reg(5'd1, 32'd100);
        write_reg(5'd2, 32'd250);

        // read back
        check_reg(5'd1, 32'd100, "write/read x1");
        check_reg(5'd2, 32'd250, "write/read x2");

        // both ports at once
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        #1;
        if (rs1_data !== 32'd100 || rs2_data !== 32'd250) begin
            $display("FAIL dual read: rs1=0x%h (exp 100) rs2=0x%h (exp 250)", rs1_data, rs2_data);
            errors = errors + 1;
        end else begin
            $display("PASS dual read: rs1=%0d rs2=%0d", rs1_data, rs2_data);
        end

        // x0 must stay zero even if written
        write_reg(5'd0, 32'd999);
        check_reg(5'd0, 32'd0, "x0 write ignored");

        // write enable = 0 must not write
        @(negedge clk);
        rd_addr = 5'd3; wr_data = 32'd777; reg_write_en = 0;
        @(negedge clk);
        check_reg(5'd3, 32'd0, "no write when enable=0");

        // unwritten register stays zero
        check_reg(5'd31, 32'd0, "unwritten x31");

        // overwrite an existing register
        write_reg(5'd1, 32'hDEADBEEF);
        check_reg(5'd1, 32'hDEADBEEF, "overwrite x1");

        // summary
        $display("----------------------------------------");
        if (errors == 0)
            $display("REGFILE TEST SUMMARY: ALL TESTS PASSED");
        else
            $display("REGFILE TEST SUMMARY: %0d TEST(S) FAILED", errors);
        $display("----------------------------------------");

        $finish;
    end

endmodule

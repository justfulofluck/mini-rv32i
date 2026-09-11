`timescale 1ns / 1ps

module tb_top;

    reg clk;
    reg rst_n;

    // CPU - Memory Interconnect Wires
    wire [31:0] instr_addr;
    wire [31:0] instr;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;
    wire        mem_read;
    wire        mem_write;

    // Instantiate CPU Core
    top u_cpu (
        .clk        (clk),
        .rst_n      (rst_n),
        .instr_addr (instr_addr),
        .instr      (instr),
        .data_addr  (data_addr),
        .data_wdata (data_wdata),
        .data_rdata (data_rdata),
        .mem_read   (mem_read),
        .mem_write  (mem_write)
    );

    // Instantiate Unified Memory
    ram u_ram (
        .clk        (clk),
        .instr_addr (instr_addr),
        .instr      (instr),
        .data_addr  (data_addr),
        .data_wdata (data_wdata),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .data_rdata (data_rdata)
    );

    // Clock Generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, tb_top);

        // Preload instructions directly into RAM
        #1;
        u_ram.mem[0] = 32'h00a00093; // addi x1, x0, 10
        u_ram.mem[1] = 32'h01400113; // addi x2, x0, 20
        u_ram.mem[2] = 32'h002081b3; // add  x3, x1, x2  (x3 should become 30)
        u_ram.mem[3] = 32'h00302023; // sw   x3, 0(x0)   (mem[0] should store 30)

        clk   = 0;
        rst_n = 0;

        // Apply Reset
        #15 rst_n = 1;

        // Run for 5 clock cycles
        #50;

        // Check Results
        $display("----------------------------------------");
        $display("EXECUTION FINISHED");
        $display("Register x1 = %0d (Expected: 10)", u_cpu.u_regfile.registers[1]);
        $display("Register x2 = %0d (Expected: 20)", u_cpu.u_regfile.registers[2]);
        $display("Register x3 = %0d (Expected: 30)", u_cpu.u_regfile.registers[3]);
        $display("Data at Mem[0] = %0d (Expected: 30)", u_ram.mem[0]);
        $display("----------------------------------------");

        $finish;
    end

endmodule
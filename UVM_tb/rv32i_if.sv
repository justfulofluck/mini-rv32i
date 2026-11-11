`timescale 1ns/1ps

interface rv32i_if(input logic clk);
	logic rst_n;

	// Instruction Memory Interface
	logic [31:0] instr_addr;
	logic [31:0] instr;

	// Data Memory Interface
	logic [31:0] data_addr;
	logic [31:0] data_wdata;
	logic [31:0] data_rdata;
	logic        mem_read;
	logic        mem_write;
	logic [3:0]  mem_write_mask;

	// Clocking block for driver
	clocking drv_cb @(posedge clk);
		default input #1step output #1;
		output rst_n;
		output instr;
		output data_rdata;
		input  instr_addr;
		input  data_addr;
		input  data_wdata;
		input  mem_read;
		input  mem_write;
		input  mem_write_mask;
	endclocking

	// Clocking block for monitor
	clocking mon_cb @(posedge clk);
		default input #1step;
		input rst_n;
		input instr_addr;
		input instr;
		input data_addr;
		input data_wdata;
		input data_rdata;
		input mem_read;
		input mem_write;
		input mem_write_mask;
	endclocking

	modport DRV (clocking drv_cb, input clk);
	modport MON (clocking mon_cb, input clk);
endinterface

`timescale 1ns / 1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "rv32i_if.sv"
`include "rv32i_seq_item.sv"
`include "rv32i_driver.sv"
`include "rv32i_monitor.sv"
`include "rv32i_agent.sv"
`include "rv32i_scoreboard.sv"
`include "rv32i_env.sv"

// Simple Base Test
class rv32i_base_test extends uvm_test;
    `uvm_component_utils(rv32i_base_test)

    rv32i_env env;

    function new(string name = "rv32i_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = rv32i_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("BASE_TEST", "UVM Simulation Started for Mini-RV32I!", UVM_LOW)
        
        // 100 clock cycles run simulation
        #1000;
        
        `uvm_info("BASE_TEST", "UVM Simulation Ending...", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass

module tb_top_uvm;
    // Clock generation (50 MHz / 20ns period)
    logic clk;
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Interface instance
    rv32i_if vif(clk);

    // Instantiate DUT (Mini-RV32I Core)
    top dut (
        .clk            (clk),
        .rst_n          (vif.rst_n),
        .instr_addr     (vif.instr_addr),
        .instr          (vif.instr),
        .data_addr      (vif.data_addr),
        .data_wdata     (vif.data_wdata),
        .data_rdata     (vif.data_rdata),
        .mem_read       (vif.mem_read),
        .mem_write      (vif.mem_write),
        .mem_write_mask (vif.mem_write_mask)
    );

    // Start UVM Test
    initial begin
        // Set virtual interface in config_db
        uvm_config_db#(virtual rv32i_if)::set(null, "*", "vif", vif);

        // VCD waveform dump
        $dumpfile("uvm_sim.vcd");
        $dumpvars(0, tb_top_uvm);

        // Run the test
        run_test("rv32i_base_test");
    end
endmodule

`ifndef RV32I_SCOREBOARD_SV
`define RV32I_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "rv32i_seq_item.sv"

class rv32i_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(rv32i_scoreboard)

    // Analysis Imp to receive transactions from Agent's Monitor
    uvm_analysis_imp #(rv32i_seq_item, rv32i_scoreboard) sb_export;

    // Golden Register Model: 32 registers of 32-bit
    bit [31:0] reg_model [0:31];

    // Counters for reporting
    int match_count;
    int mismatch_count;

    // Constructor
    function new(string name = "rv32i_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        match_count    = 0;
        mismatch_count = 0;
        for (int i = 0; i < 32; i++) reg_model[i] = 32'd0;
    endfunction

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export = new("sb_export", this);
    endfunction

    // Write method: Har cycle par Monitor se packet receive hota hai
    virtual function void write(rv32i_seq_item item);
        bit [6:0] opcode = item.instr[6:0];
        bit [4:0] rd     = item.instr[11:7];
        bit [2:0] funct3 = item.instr[14:12];
        bit [6:0] funct7 = item.instr[31:25];

        // x0 register must always remain 0
        reg_model[0] = 32'd0;

        // Check for Memory Store Operations
        if (item.mem_write) begin
            `uvm_info("SCB_STORE", $sformatf("STORE detected -> Addr: 0x%08x, Data: 0x%08x, Mask: 4'b%04b", 
                      item.data_addr, item.data_wdata, item.mem_write_mask), UVM_MEDIUM)
            match_count++;
        end

        // Check for Memory Load Operations
        if (item.mem_read) begin
            `uvm_info("SCB_LOAD", $sformatf("LOAD detected -> Addr: 0x%08x", item.data_addr), UVM_MEDIUM)
            match_count++;
        end

        // Basic sanity check: Instruction address must be 4-byte aligned
        if (item.instr_addr[1:0] != 2'b00) begin
            `uvm_error("SCB_PC_ALIGN", $sformatf("Misaligned PC: 0x%08x", item.instr_addr))
            mismatch_count++;
        end else begin
            match_count++;
        end
    endfunction

    // Report Phase: Final summary print
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB_REPORT", "--------------------------------------------------", UVM_NONE)
        `uvm_info("SCB_REPORT", $sformatf("SCOREBOARD SUMMARY: Matches = %0d, Mismatches = %0d", match_count, mismatch_count), UVM_NONE)
        if (mismatch_count == 0) begin
            `uvm_info("SCB_REPORT", ">>> TEST PASSED: ALL CHECKS CLEAN <<<", UVM_NONE)
        end else begin
            `uvm_error("SCB_REPORT", ">>> TEST FAILED: MISMATCHES DETECTED <<<")
        end
        `uvm_info("SCB_REPORT", "--------------------------------------------------", UVM_NONE)
    endfunction

endclass

`endif

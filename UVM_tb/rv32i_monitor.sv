`ifndef RV32I_MONITOR_SV
`define RV32I_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "rv32i_seq_item.sv"

class rv32i_monitor extends uvm_monitor;
    `uvm_component_utils(rv32i_monitor)

    // Virtual interface handle
    virtual rv32i_if vif;

    // Analysis Port (Scoreboard ko data bhejne ke liye)
    uvm_analysis_port #(rv32i_seq_item) mon_ap;

    // Constructor
    function new(string name = "rv32i_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);
        if (!uvm_config_db#(virtual rv32i_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON_NO_VIF", "Virtual interface handle not found in uvm_config_db!")
        end
    endfunction

    // Run Phase: Sampling DUT activity on every clock edge
    virtual task run_phase(uvm_phase phase);
        rv32i_seq_item item;

        // Reset release hone tak wait karein
        wait (vif.mon_cb.rst_n == 1'b1);

        forever begin
            @(vif.mon_cb);
            
            // Naya packet create karke bus state sample karein
            item = rv32i_seq_item::type_id::create("item");
            item.instr_addr     = vif.mon_cb.instr_addr;
            item.instr          = vif.mon_cb.instr;
            item.data_addr      = vif.mon_cb.data_addr;
            item.data_wdata     = vif.mon_cb.data_wdata;
            item.data_rdata     = vif.mon_cb.data_rdata;
            item.mem_read       = vif.mon_cb.mem_read;
            item.mem_write      = vif.mon_cb.mem_write;
            item.mem_write_mask = vif.mon_cb.mem_write_mask;

            // Scoreboard aur Coverage collectors ko broadcast karein
            mon_ap.write(item);
        end
    endtask

endclass

`endif

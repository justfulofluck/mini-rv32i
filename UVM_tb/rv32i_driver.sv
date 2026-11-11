`ifndef RV32I_DRIVER_SV
`define RV32I_DRIVER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "rv32i_seq_item.sv"

class rv32i_driver extends uvm_driver #(rv32i_seq_item);
    `uvm_component_utils(rv32i_driver)

    // Virtual Interface handle
    virtual rv32i_if vif;

    // Constructor
    function new(string name = "rv32i_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase: Virtual interface fetch karna UVM config db se
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual rv32i_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV_NO_VIF", "Virtual interface handle not found in uvm_config_db!")
        end
    endfunction

    // Run Phase: Continuous transaction processing loop
    virtual task run_phase(uvm_phase phase);
        // Initial reset state
        vif.drv_cb.rst_n      <= 1'b0;
        vif.drv_cb.instr      <= 32'h00000013; // NOP (addi x0, x0, 0)
        vif.drv_cb.data_rdata <= 32'd0;

        // Reset release after 2 clock cycles
        repeat (2) @(vif.drv_cb);
        vif.drv_cb.rst_n <= 1'b1;

        forever begin
            // 1. Get next item from sequencer
            seq_item_port.get_next_item(req);

            // 2. Drive transaction signals synchronized with clocking block
            @(vif.drv_cb);
            vif.drv_cb.instr      <= req.instr;
            vif.drv_cb.data_rdata <= req.data_rdata;

            // 3. Handshake complete
            seq_item_port.item_done();
        end
    endtask

endclass

`endif

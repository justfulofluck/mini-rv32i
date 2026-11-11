`ifndef RV32I_AGENT_SV
`define RV32I_AGENT_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "rv32i_seq_item.sv"
`include "rv32i_driver.sv"
`include "rv32i_monitor.sv"

// Typedef for Sequencer
typedef uvm_sequencer #(rv32i_seq_item) rv32i_sequencer;

class rv32i_agent extends uvm_agent;
    `uvm_component_utils(rv32i_agent)

    // Components
    rv32i_sequencer sequencer;
    rv32i_driver    driver;
    rv32i_monitor   monitor;

    // Analysis port to expose outside the agent (to scoreboard)
    uvm_analysis_port #(rv32i_seq_item) agt_ap;

    // Constructor
    function new(string name = "rv32i_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase: Sub-components instantiate karna
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Monitor hamesha banta hai (Active ya Passive dono mein)
        monitor = rv32i_monitor::type_id::create("monitor", this);

        // Agar agent ACTIVE hai, tabhi driver aur sequencer banenge
        if (get_is_active() == UVM_ACTIVE) begin
            driver    = rv32i_driver::type_id::create("driver", this);
            sequencer = rv32i_sequencer::type_id::create("sequencer", this);
        end
    endfunction

    // Connect Phase: Driver ko Sequencer ke TLM port se connect karna
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end

        // Monitor ke analysis port ko agent ke bahar expose karna
        agt_ap = monitor.mon_ap;
    endfunction

endclass

`endif

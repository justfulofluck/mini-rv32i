`ifndef RV32I_ENV_SV
`define RV32I_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "rv32i_agent.sv"
`include "rv32i_scoreboard.sv"

class rv32i_env extends uvm_env;
    `uvm_component_utils(rv32i_env)

    rv32i_agent      agent;
    rv32i_scoreboard scoreboard;

    // Constructor
    function new(string name = "rv32i_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase: Agent aur Scoreboard instantiate karna
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = rv32i_agent::type_id::create("agent", this);
        scoreboard = rv32i_scoreboard::type_id::create("scoreboard", this);
    endfunction

    // Connect Phase: Agent ke Monitor output ko Scoreboard ke input se bind karna
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.agt_ap.connect(scoreboard.sb_export);
    endfunction

endclass

`endif

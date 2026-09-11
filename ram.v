// Unified RAM

`timescale 1ns / 1ps

module ram(
    input wire clk,

    // Instruction Port (Read-only)
    input wire [31:0] instr_addr,
    output wire [31:0] instr,

    // data port (read / write)
    input wire [31:0] data_addr,
    input wire [31:0] data_wdata,
    input wire mem_read,
    input wire mem_write,
    output wire [31:0] data_rdata
);

    // 256 words (1 Kb total memrory)
    reg [31:0] mem [0:255];
    integer i;

    // Reset memory with 0s initially
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 32'd0;
        end
    end

    // Instruction Read (Word-aligned: instr_addr >> 2)
    assign instr = mem[instr_addr[9:2]];

    // Data Read
    assign data_rdata = (mem_read) ? mem[data_addr[9:2]] : 32'd0;

    // Data write (Synchtonous)
    always @(posedge clk) begin
        if (mem_write) begin
            mem[data_addr [9:2]] <= data_wdata;
        end
    end

endmodule

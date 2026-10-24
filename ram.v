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
    input wire [3:0]  mem_write_mask,
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

    // Data write (Synchronous, byte-masked)
    always @(posedge clk) begin
        if (mem_write) begin
            if (mem_write_mask[0]) mem[data_addr[9:2]][7:0]   <= data_wdata[7:0];
            if (mem_write_mask[1]) mem[data_addr[9:2]][15:8]  <= data_wdata[15:8];
            if (mem_write_mask[2]) mem[data_addr[9:2]][23:16] <= data_wdata[23:16];
            if (mem_write_mask[3]) mem[data_addr[9:2]][31:24] <= data_wdata[31:24];
        end
    end

endmodule

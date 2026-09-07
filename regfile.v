// Code your design here

`timescale 1ns / 1ps

module regfile (
    input wire clk,
    input wire rst_n,
    input wire reg_write_en,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire [31:0] wr_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    // 32 registers of 32 bit width
    reg [31:0] registers [31:0];
    integer i;

    // Asynchoronous Read logic with x0 hardware to 0
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : registers[rs2_addr];

    // synchronous write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i =  0; i <32; i = i+1)
                registers[i] <= 32'd0;
        end else if (reg_write_en && (rd_addr != 5'd0)) begin
            registers[rd_addr] <= wr_data;
        end
    end

endmodule
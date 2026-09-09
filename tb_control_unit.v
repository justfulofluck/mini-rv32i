`timescale 1ns / 1ps

module tb_control_unit;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire reg_write;
    wire alu_src;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire [3:0] alu_ctrl;
    wire branch;

    //Instantiate the Unit Under Test
    control_unit uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_ctrl(alu_ctrl),
        .branch(branch)
    );  

    initial begin
        $dumpfile("control_unit.vcd");
        $dumpvars(0,tb_control_unit);

        // Test 1 - R-type ADD (add x1, x2, x3)
        opcode = 7'b0100011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        $display("R-Type ADD: RegWrite=%b, ALUSrc=%b, ALUCtrl=%b (Expected: 1, 0, 0000)", reg_write, alu_src, alu_ctrl);

        // Test 1 - R-type ADD (add x1, x2, x3)
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #10;
        $display("R-Type SUB: RegWrite=%b, ALUSrc=%b, ALUCtrl=%b (Expected: 1, 0, 0001)", reg_write, alu_src, alu_ctrl);

        // Test 2 - I-type ADDI (addi x1, x2, 10)
        opcode = 7'b0010011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        $display("I-Type ADDI: RegWrite=%b, ALUSrc=%b, ALUCtrl=%b (Expected: 1, 1, 0000)", reg_write, alu_src, alu_ctrl);

        // Test 3 - Load (lw x1, 8(x2))
        opcode = 7'b0000011;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #10;
        $display("LOAD: RegWrite=%b, ALUSrc=%b, ALUCtrl=%b (Expected: 1, 1, 0000)", reg_write, alu_src, alu_ctrl);

        // Test 4 - Store (sw x1, 8(x2))
        opcode = 7'b0100011;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #10;
        $display("STORE: MemRead=%b, MemWrite=%b (Expected: 0, 1)", mem_read, mem_write);

        // Test 5 - Branch (beq x1, x2, L)
        opcode = 7'b1100011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        $display("BRANCH: Branch=%b, ALUSrc=%b, ALUCtrl=%b (Expected: 1, 1, 0001)", branch, alu_src, alu_ctrl);

        $finish;
    end
endmodule   
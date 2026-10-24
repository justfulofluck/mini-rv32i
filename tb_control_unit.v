`timescale 1ns / 1ps

module tb_control_unit;

    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire reg_write;
    wire alu_src;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire branch;
    wire jump;
    wire jump_src;
    wire link;
    wire lui;
    wire auipc;
    wire [3:0] alu_ctrl;

    integer errors;

    // {reg_write, alu_src, mem_read, mem_write, mem_to_reg,
    //  branch, jump, jump_src, link, lui, auipc, alu_ctrl}
    wire [14:0] actual = {reg_write, alu_src, mem_read, mem_write, mem_to_reg,
                          branch, jump, jump_src, link, lui, auipc, alu_ctrl};

    control_unit uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .jump_src(jump_src),
        .link(link),
        .lui(lui),
        .auipc(auipc),
        .alu_ctrl(alu_ctrl)
    );

    localparam OP_R     = 7'b0110011;
    localparam OP_I     = 7'b0010011;
    localparam OP_LOAD  = 7'b0000011;
    localparam OP_STORE = 7'b0100011;
    localparam OP_BRANCH= 7'b1100011;
    localparam OP_JAL   = 7'b1101111;
    localparam OP_JALR  = 7'b1100111;
    localparam OP_LUI   = 7'b0110111;
    localparam OP_AUIPC = 7'b0010111;

    task check;
        input [6:0]   op;
        input [2:0]   f3;
        input [6:0]   f7;
        input [14:0]  exp;   // {reg_write,alu_src,mem_read,mem_write,mem_to_reg,branch,jump,jump_src,link,lui,auipc,alu_ctrl}
        input [255:0] name;
        begin
            opcode = op; funct3 = f3; funct7 = f7;
            #1;
            if (actual !== exp) begin
                $display("FAIL %0s: got {rw,as,mr,mw,m2r,br,j,js,lk,lui,aui,alu}=%b expected=%b",
                         name, actual, exp);
                $display("       got: rw=%b as=%b mr=%b mw=%b m2r=%b br=%b j=%b js=%b lk=%b lui=%b aui=%b alu=%b",
                         reg_write, alu_src, mem_read, mem_write, mem_to_reg,
                         branch, jump, jump_src, link, lui, auipc, alu_ctrl);
                errors = errors + 1;
            end else begin
                $display("PASS %0s: alu_ctrl=%b", name, alu_ctrl);
            end
        end
    endtask

    initial begin
        $dumpfile("control_unit.vcd");
        $dumpvars(0, tb_control_unit);

        errors = 0;

        // ---------------- R-type: {rw=1, alu_ctrl=xxxx} ----------------
        check(OP_R, 3'b000, 7'b0000000, 15'b1_0_0_0_0_0_0_0_0_0_0_0000, "R ADD");
        check(OP_R, 3'b000, 7'b0100000, 15'b1_0_0_0_0_0_0_0_0_0_0_0001, "R SUB");
        check(OP_R, 3'b001, 7'b0000000, 15'b1_0_0_0_0_0_0_0_0_0_0_1000, "R SLL");
        check(OP_R, 3'b010, 7'b0000000, 15'b1_0_0_0_0_0_0_0_0_0_0_0110, "R SLT");
        check(OP_R, 3'b011, 7'b0000000, 15'b1_0_0_0_0_0_0_0_0_0_0_0111, "R SLTU");
        check(OP_R, 3'b100, 7'b0000000, 15'b1_0_0_0_0_0_0_0_0_0_0_0101, "R XOR");
        check(OP_R, 3'b101, 7'b0000000, 15'b1_0_0_0_0_0_0_0_0_0_0_1001, "R SRL");
        check(OP_R, 3'b101, 7'b0100000, 15'b1_0_0_0_0_0_0_0_0_0_0_1010, "R SRA");
        check(OP_R, 3'b110, 7'b0000000, 15'b1_0_0_0_0_0_0_0_0_0_0_0100, "R OR");
        check(OP_R, 3'b111, 7'b0000000, 15'b1_0_0_0_0_0_0_0_0_0_0_0011, "R AND");

        // ---------------- I-type: {rw=1, as=1, alu_ctrl=xxxx} ----------------
        check(OP_I, 3'b000, 7'b0000000, 15'b1_1_0_0_0_0_0_0_0_0_0_0000, "I ADDI");
        check(OP_I, 3'b001, 7'b0000000, 15'b1_1_0_0_0_0_0_0_0_0_0_1000, "I SLLI");
        check(OP_I, 3'b010, 7'b0000000, 15'b1_1_0_0_0_0_0_0_0_0_0_0110, "I SLTI");
        check(OP_I, 3'b011, 7'b0000000, 15'b1_1_0_0_0_0_0_0_0_0_0_0111, "I SLTIU");
        check(OP_I, 3'b100, 7'b0000000, 15'b1_1_0_0_0_0_0_0_0_0_0_0101, "I XORI");
        check(OP_I, 3'b101, 7'b0000000, 15'b1_1_0_0_0_0_0_0_0_0_0_1001, "I SRLI");
        check(OP_I, 3'b101, 7'b0100000, 15'b1_1_0_0_0_0_0_0_0_0_0_1010, "I SRAI");
        check(OP_I, 3'b110, 7'b0000000, 15'b1_1_0_0_0_0_0_0_0_0_0_0100, "I ORI");
        check(OP_I, 3'b111, 7'b0000000, 15'b1_1_0_0_0_0_0_0_0_0_0_0011, "I ANDI");

        // ---------------- Loads: {rw=1, as=1, mr=1, m2r=1, alu=0000} ----------------
        check(OP_LOAD, 3'b000, 7'b0, 15'b1_1_1_0_1_0_0_0_0_0_0_0000, "LB");
        check(OP_LOAD, 3'b001, 7'b0, 15'b1_1_1_0_1_0_0_0_0_0_0_0000, "LH");
        check(OP_LOAD, 3'b010, 7'b0, 15'b1_1_1_0_1_0_0_0_0_0_0_0000, "LW");
        check(OP_LOAD, 3'b100, 7'b0, 15'b1_1_1_0_1_0_0_0_0_0_0_0000, "LBU");
        check(OP_LOAD, 3'b101, 7'b0, 15'b1_1_1_0_1_0_0_0_0_0_0_0000, "LHU");

        // ---------------- Stores: {as=1, mw=1, alu=0000} ----------------
        check(OP_STORE, 3'b000, 7'b0, 15'b0_1_0_1_0_0_0_0_0_0_0_0000, "SB");
        check(OP_STORE, 3'b001, 7'b0, 15'b0_1_0_1_0_0_0_0_0_0_0_0000, "SH");
        check(OP_STORE, 3'b010, 7'b0, 15'b0_1_0_1_0_0_0_0_0_0_0_0000, "SW");

        // ---------------- Branches: {br=1, alu=0001} ----------------
        check(OP_BRANCH, 3'b000, 7'b0, 15'b0_0_0_0_0_1_0_0_0_0_0_0001, "BEQ");
        check(OP_BRANCH, 3'b001, 7'b0, 15'b0_0_0_0_0_1_0_0_0_0_0_0001, "BNE");
        check(OP_BRANCH, 3'b100, 7'b0, 15'b0_0_0_0_0_1_0_0_0_0_0_0001, "BLT");
        check(OP_BRANCH, 3'b101, 7'b0, 15'b0_0_0_0_0_1_0_0_0_0_0_0001, "BGE");
        check(OP_BRANCH, 3'b110, 7'b0, 15'b0_0_0_0_0_1_0_0_0_0_0_0001, "BLTU");
        check(OP_BRANCH, 3'b111, 7'b0, 15'b0_0_0_0_0_1_0_0_0_0_0_0001, "BGEU");

        // ---------------- Jumps ----------------
        // JAL: {rw=1, j=1, lk=1}
        check(OP_JAL, 3'b000, 7'b0, 15'b1_0_0_0_0_0_1_0_1_0_0_0000, "JAL");
        // JALR: {rw=1, as=1, j=1, js=1, lk=1, alu=0000}
        check(OP_JALR, 3'b000, 7'b0, 15'b1_1_0_0_0_0_1_1_1_0_0_0000, "JALR");

        // ---------------- U-type ----------------
        check(OP_LUI,   3'b000, 7'b0, 15'b1_0_0_0_0_0_0_0_0_1_0_0000, "LUI");
        check(OP_AUIPC, 3'b000, 7'b0, 15'b1_0_0_0_0_0_0_0_0_0_1_0000, "AUIPC");

        // ---------------- Unknown opcode -> all zero ----------------
        check(7'b0000000, 3'b000, 7'b0, 15'b0_0_0_0_0_0_0_0_0_0_0_0000, "unknown opcode");

        // ---------------- summary ----------------
        $display("----------------------------------------");
        if (errors == 0)
            $display("CONTROL_UNIT TEST SUMMARY: ALL TESTS PASSED");
        else
            $display("CONTROL_UNIT TEST SUMMARY: %0d TEST(S) FAILED", errors);
        $display("----------------------------------------");

        $finish;
    end

endmodule

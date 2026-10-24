`timescale 1ns / 1ps

module tb_top;

    reg clk;
    reg rst_n;

    wire [31:0] instr_addr;
    wire [31:0] instr;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;
    wire        mem_read;
    wire        mem_write;
    wire [3:0]  mem_write_mask;

    integer errors;
    integer i;

    // store monitor
    integer wcount;
    reg [31:0] w_addr [0:7];
    reg [3:0]  w_mask [0:7];
    reg [31:0] w_data [0:7];

    reg [31:0] exp_regs [1:31];

    top u_cpu (
        .clk(clk),
        .rst_n(rst_n),
        .instr_addr(instr_addr),
        .instr(instr),
        .data_addr(data_addr),
        .data_wdata(data_wdata),
        .data_rdata(data_rdata),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_write_mask(mem_write_mask)
    );

    ram u_ram (
        .clk(clk),
        .instr_addr(instr_addr),
        .instr(instr),
        .data_addr(data_addr),
        .data_wdata(data_wdata),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_write_mask(mem_write_mask),
        .data_rdata(data_rdata)
    );

    always #5 clk = ~clk;

    // record every store (address / byte mask / data)
    always @(posedge clk) begin
        if (rst_n && mem_write) begin
            w_addr[wcount] = data_addr;
            w_mask[wcount] = mem_write_mask;
            w_data[wcount] = data_wdata;
            wcount = wcount + 1;
        end
    end

    task check_reg;
        input integer id;
        input [31:0]  exp;
        begin
            if (u_cpu.u_regfile.registers[id] !== exp) begin
                $display("FAIL x%0d = 0x%h expected 0x%h", id,
                         u_cpu.u_regfile.registers[id], exp);
                errors = errors + 1;
            end else begin
                $display("PASS x%0d = 0x%h", id, exp);
            end
        end
    endtask

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, tb_top);

        errors = 0;
        wcount = 0;
        clk   = 0;
        rst_n = 0;

        // ---- program ----
        u_ram.mem[0] = 32'h00A00093;
        u_ram.mem[1] = 32'h01400113;
        u_ram.mem[2] = 32'h002081B3;
        u_ram.mem[3] = 32'h40110233;
        u_ram.mem[4] = 32'h0020F2B3;
        u_ram.mem[5] = 32'h0020E333;
        u_ram.mem[6] = 32'h0020C3B3;
        u_ram.mem[7] = 32'h0020A433;
        u_ram.mem[8] = 32'h001134B3;
        u_ram.mem[9] = 32'h00209533;
        u_ram.mem[10] = 32'h001155B3;
        u_ram.mem[11] = 32'h40115633;
        u_ram.mem[12] = 32'hFF000693;
        u_ram.mem[13] = 32'h4026D713;
        u_ram.mem[14] = 32'h01C6D793;
        u_ram.mem[15] = 32'h12345837;
        u_ram.mem[16] = 32'h00001897;
        u_ram.mem[17] = 32'hFFB00913;
        u_ram.mem[18] = 32'h00194463;
        u_ram.mem[19] = 32'h06F00993;
        u_ram.mem[20] = 32'h0DE00993;
        u_ram.mem[21] = 32'h0120D463;
        u_ram.mem[22] = 32'h06F00A13;
        u_ram.mem[23] = 32'h14D00A13;
        u_ram.mem[24] = 32'h00208463;
        u_ram.mem[25] = 32'h1BC00A93;
        u_ram.mem[26] = 32'h00209463;
        u_ram.mem[27] = 32'h22B00A93;
        u_ram.mem[28] = 32'h0120E463;
        u_ram.mem[29] = 32'h06F00B13;
        u_ram.mem[30] = 32'h29A00B13;
        u_ram.mem[31] = 32'h00197463;
        u_ram.mem[32] = 32'h06F00B93;
        u_ram.mem[33] = 32'h30900B93;
        u_ram.mem[34] = 32'h00800C6F;
        u_ram.mem[35] = 32'h06F00C93;
        u_ram.mem[36] = 32'h37800C93;
        u_ram.mem[37] = 32'h00000D17;
        u_ram.mem[38] = 32'h008D0DE7;
        u_ram.mem[39] = 32'h06F00E13;
        u_ram.mem[40] = 32'h3E700E13;
        u_ram.mem[41] = 32'h10000E93;
        u_ram.mem[42] = 32'h003EA023;
        u_ram.mem[43] = 32'h004EA223;
        u_ram.mem[44] = 32'h010EA423;
        u_ram.mem[45] = 32'h000EA283;
        u_ram.mem[46] = 32'h000E8303;
        u_ram.mem[47] = 32'h000EC383;
        u_ram.mem[48] = 32'h000E9403;
        u_ram.mem[49] = 32'h000ED483;
        u_ram.mem[50] = 32'h010E8503;
        u_ram.mem[51] = 32'h011EC583;
        u_ram.mem[52] = 32'h013E8603;
        u_ram.mem[53] = 32'h012E9683;
        u_ram.mem[54] = 32'h001E8023;
        u_ram.mem[55] = 32'h001E80A3;
        u_ram.mem[56] = 32'h001E9123;
        u_ram.mem[57] = 32'h003EA223;
        u_ram.mem[58] = 32'h0000006F;

        // ---- data memory preload (0x110 = byte/half load tests) ----
        u_ram.mem[68] = 32'h04030201;

        #15 rst_n = 1;

        // wait until the CPU reaches the final self-loop (word 58 -> 0xE8)
        wait (u_cpu.pc_current == 32'd232);
        @(posedge clk);
        #1;

        // ---- expected register values ----
        check_reg(1, 32'h0000000A);
        check_reg(2, 32'h00000014);
        check_reg(3, 32'h0000001E);
        check_reg(4, 32'h0000000A);
        check_reg(5, 32'h0000001E);
        check_reg(6, 32'h0000001E);
        check_reg(7, 32'h0000001E);
        check_reg(8, 32'h0000001E);
        check_reg(9, 32'h0000001E);
        check_reg(10, 32'h00000001);
        check_reg(11, 32'h00000002);
        check_reg(12, 32'h00000004);
        check_reg(13, 32'h00000403);
        check_reg(14, 32'hFFFFFFFC);
        check_reg(15, 32'h0000000F);
        check_reg(16, 32'h12345000);
        check_reg(17, 32'h00001040);
        check_reg(18, 32'hFFFFFFFB);
        check_reg(19, 32'h000000DE);
        check_reg(20, 32'h0000014D);
        check_reg(21, 32'h000001BC);
        check_reg(22, 32'h0000029A);
        check_reg(23, 32'h00000309);
        check_reg(24, 32'h0000008C);
        check_reg(25, 32'h00000378);
        check_reg(26, 32'h00000094);
        check_reg(27, 32'h0000009C);
        check_reg(28, 32'h000003E7);
        check_reg(29, 32'h00000100);
        check_reg(30, 32'h00000000);
        check_reg(31, 32'h00000000);

        // ---- store mask / data checks ----
        if (wcount != 7) begin
            $display("FAIL store count = %0d expected 7", wcount);
            errors = errors + 1;
        end
        // SW x3, 0(x29)
        if (w_addr[0] !== 32'h00000100 || w_mask[0] !== 4'b1111 || w_data[0] !== 32'h0000001E) begin
            $display("FAIL SW0: addr=0x%h mask=%b data=0x%h", w_addr[0], w_mask[0], w_data[0]);
            errors = errors + 1;
        end else $display("PASS SW0 mask=%b data=0x%h", w_mask[0], w_data[0]);
        // SW x4, 4(x29)
        if (w_addr[1] !== 32'h00000104 || w_mask[1] !== 4'b1111 || w_data[1] !== 32'h0000000A) begin
            $display("FAIL SW1: addr=0x%h mask=%b data=0x%h", w_addr[1], w_mask[1], w_data[1]);
            errors = errors + 1;
        end else $display("PASS SW1 mask=%b data=0x%h", w_mask[1], w_data[1]);
        // SW x16, 8(x29)
        if (w_addr[2] !== 32'h00000108 || w_mask[2] !== 4'b1111 || w_data[2] !== 32'h12345000) begin
            $display("FAIL SW2: addr=0x%h mask=%b data=0x%h", w_addr[2], w_mask[2], w_data[2]);
            errors = errors + 1;
        end else $display("PASS SW2 mask=%b data=0x%h", w_mask[2], w_data[2]);
        // SB x1, 0(x29)
        if (w_addr[3] !== 32'h00000100 || w_mask[3] !== 4'b0001 || w_data[3] !== 32'h0A0A0A0A) begin
            $display("FAIL SB0: addr=0x%h mask=%b data=0x%h", w_addr[0], w_mask[3], w_data[3]);
            errors = errors + 1;
        end else $display("PASS SB0 mask=%b data=0x%h", w_mask[3], w_data[3]);
        // SB x1, 1(x29)
        if (w_addr[4] !== 32'h00000101 || w_mask[4] !== 4'b0010 || w_data[4] !== 32'h0A0A0A0A) begin
            $display("FAIL SB1: addr=0x%h mask=%b data=0x%h", w_addr[4], w_mask[4], w_data[4]);
            errors = errors + 1;
        end else $display("PASS SB1 mask=%b data=0x%h", w_mask[4], w_data[4]);
        // SH x1, 2(x29)
        if (w_addr[5] !== 32'h00000102 || w_mask[5] !== 4'b1100 || w_data[5] !== 32'h000A000A) begin
            $display("FAIL SH : addr=0x%h mask=%b data=0x%h", w_addr[5], w_mask[5], w_data[5]);
            errors = errors + 1;
        end else $display("PASS SH  mask=%b data=0x%h", w_mask[5], w_data[5]);
        // SW x3, 4(x29)
        if (w_addr[6] !== 32'h00000104 || w_mask[6] !== 4'b1111 || w_data[6] !== 32'h0000001E) begin
            $display("FAIL SW : addr=0x%h mask=%b data=0x%h", w_addr[6], w_mask[6], w_data[6]);
            errors = errors + 1;
        end else $display("PASS SW  mask=%b data=0x%h", w_mask[6], w_data[6]);

        // ---- memory content checks (requires masked write in ram.v) ----
        // after SB,SB,SH on word 0x100: byte0=0x0A, byte1=0x0A, byte2,3=0x000A
        if (u_ram.mem[64] !== 32'h000A0A0A) begin
            $display("FAIL mem[0x100] = 0x%h expected 0x000A0A0A", u_ram.mem[64]);
            errors = errors + 1;
        end else $display("PASS mem[0x100] = 0x%h", u_ram.mem[64]);
        // SW x3, 4(x29)
        if (u_ram.mem[65] !== 32'h0000001E) begin
            $display("FAIL mem[0x104] = 0x%h expected 30", u_ram.mem[65]);
            errors = errors + 1;
        end else $display("PASS mem[0x104] = 30");

        $display("----------------------------------------");
        if (errors == 0)
            $display("TOP TEST SUMMARY: ALL TESTS PASSED");
        else
            $display("TOP TEST SUMMARY: %0d TEST(S) FAILED", errors);
        $display("----------------------------------------");
        $finish;
    end

    // watchdog
    initial begin
        #100000;
        $display("TIMEOUT: CPU did not reach the end (pc=0x%h)", u_cpu.pc_current);
        $finish;
    end

endmodule

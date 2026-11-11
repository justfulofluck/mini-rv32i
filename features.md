# Mini-RV32I Features & Capabilities

Comprehensive overview of current hardware features, instruction set support, physical design signoff, and planned future additions for the **Mini-RV32I** processor.

---

## 1. Core Processor Architecture

- **ISA Standard:** Full 32-bit RISC-V Base Integer Instruction Set (**RV32I** unprivileged user spec).
- **Execution Model:** Single-cycle datapath (**1 CPI** — single cycle per instruction execution).
- **Zero Latch Design:** Purely synchronous registers and combinational decoding with zero latch inference for clean ASIC synthesis.
- **Register File:**
  - $32 \times 32$-bit general-purpose registers (`x0` - `x31`).
  - Hardwired zero register: `x0` always reads `0x00000000`, writes to `x0` are ignored.
  - Dual asynchronous read ports (`rs1`, `rs2`) and single synchronous positive-edge write port (`rd`).
- **Program Counter (PC):**
  - Reset to `0x00000000` via active-low asynchronous reset (`rst_n`).
  - Sequential PC increment (`PC + 4`).
  - Branch target adder (`PC + imm`).
  - JAL target adder (`PC + imm`) and JALR base-offset adder (`rs1 + imm`).

---

## 2. Complete RV32I Instruction Set Support

Mini-RV32I natively executes all 37 base instructions across all 6 RISC-V formats:

| Format | Instruction | Operation Description |
| :--- | :--- | :--- |
| **R-Type** | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU` | Register-to-register arithmetic, logic, and bitwise operations |
| **I-Type (ALU)** | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SRLI`, `SRAI`, `SLTI`, `SLTIU` | Register-immediate arithmetic, shifts, and comparisons |
| **I-Type (Load)**| `LB`, `LH`, `LW`, `LBU`, `LHU` | Sub-word signed and unsigned memory loading |
| **I-Type (Jump)**| `JALR` | Indirect register jump with immediate offset and link (`rd = PC + 4`) |
| **S-Type (Store)**| `SB`, `SH`, `SW` | Byte, halfword, and word memory write operations |
| **B-Type (Branch)**| `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` | Conditional branch comparisons (signed and unsigned) |
| **U-Type** | `LUI`, `AUIPC` | Load Upper Immediate and Add Upper Immediate to PC |
| **J-Type** | `JAL` | Unconditional direct jump with link (`rd = PC + 4`) |

---

## 3. Arithmetic Logic Unit (ALU) & Immediate Generator

- **ALU Operations (10 functions):**
  - Addition (`ADD`), Subtraction (`SUB`)
  - Bitwise Boolean: `AND`, `OR`, `XOR`
  - Bit Shifts: Logical Left (`SLL`), Logical Right (`SRL`), Arithmetic Right (`SRA`)
  - Set-Less-Than: Signed (`SLT`), Unsigned (`SLTU`)
- **Comparison Flags:**
  - `zero_flag`: High when result equals zero (for `BEQ`/`BNE`).
  - `lt_flag`: Signed comparison result (for `BLT`/`BGE`).
  - `ltu_flag`: Unsigned comparison result (for `BLTU`/`BGEU`).
- **Immediate Generator:**
  - Handles I, S, B, U, and J immediate pack formats with sign-extension.

---

## 4. Memory Subsystem

- **Current RAM:**
  - 1 KB internal unified synchronous memory (256 words $\times$ 32 bits).
  - Word-aligned instruction read port.
  - Byte-masked synchronous write port via 4-bit `mem_write_mask`:
    - `4'b0001` - `4'b1000`: Single byte write (`SB`)
    - `4'b0011` / `4'b1100`: Halfword write (`SH`)
    - `4'b1111`: Full 32-bit word write (`SW`)
  - Sub-word sign/zero extend logic inside CPU datapath for byte and halfword reads.

---

## 5. Verification & Testbenches

- **Simulation Tool:** Icarus Verilog (`iverilog`) + GTKWave / VCD dump.
- **Test Coverage:**
  - `tb_alu.v`: Exhaustive ALU arithmetic, signed/unsigned comparisons, wrap-around, and flag tests.
  - `tb_control_unit.v`: Full decoding verification for all instruction classes.
  - `tb_imm_gen.v`: Negative, positive, and extreme boundary immediate tests.
  - `tb_regfile.v`: Multi-port read/write, `x0` protection, and overwrite tests.
  - `tb_top.v`: End-to-end integration test executing real RISC-V assembly programs and memory storage.
- **Test Status:** 100% of all unit and integration test suites pass cleanly.

---

## 6. Physical Design & ASIC Tapeout Status

- **ASIC Flow:** OpenLane (RTL-to-GDSII).
- **Target PDK:** SkyWater 130nm standard cells (`sky130_fd_sc_hd`).
- **Signoff Results:**
  - **GDSII:** Tapeout-ready layout generated (`openlane/runs/mini-rv32i/results/final/gds/top.gds`).
  - **DRC:** 0 design rule violations.
  - **LVS:** 0 errors (schematic and layout match perfectly).
  - **Static Timing Analysis (STA):**
    - Worst Negative Slack (WNS): `0.00 ns`
    - Setup Slack: `+4.40 ns`
    - Hold Slack: `+0.32 ns`

---

## 7. Future Enhancement Roadmap (Non-Destructive Additions)

Future enhancements that can be integrated around the core without modifying existing verified RTL:

1. **Expanded RAM / Memory Subsystem:**
   - Upgrade from 1 KB to 8 KB, 32 KB, or 64 KB SRAM block.
   - Dual-port or arbiter-based architecture for separate instruction and data caching.
2. **Standard Interconnect Bus:**
   - Wishbone B4 or AXI4-Lite master bus adapter on top of the CPU memory interface.
3. **Memory-Mapped Peripherals (MMIO):**
   - **UART Controller:** Serial TX/RX for interactive terminal I/O.
   - **GPIO Controller:** Configurable general-purpose I/O for external LEDs, switches, and sensors.
   - **64-bit Hardware Timer:** Real-time clock counter with compare registers.
4. **Machine Mode Interrupts & CSRs:**
   - Basic RISC-V Privileged Architecture support (`mstatus`, `mie`, `mtvec`, `mepc`, `mcause`).

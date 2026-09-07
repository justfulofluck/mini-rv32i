# Mini-RV32I: High-Performance 32-bit RISC-V Core

[![RISC-V](https://img.shields.io/badge/ISA-RISC--V%20RV32I%20Base-blue.svg)](https://riscv.org/)
[![HDL](https://img.shields.io/badge/HDL-Verilog--2001%20Synthesizable-brightgreen.svg)]()
[![Target PDK](https://img.shields.io/badge/Target%20PDK-SkyWater%20130nm-red.svg)]()
[![Architecture](https://img.shields.io/badge/Microarchitecture-Single--Cycle%20RTL-purple.svg)]()
[![License](https://img.shields.io/badge/License-MIT-orange.svg)]()

**Mini-RV32I** is a synthesizable, industry-standard **32-bit RISC-V (RV32I Unprivileged ISA) Processor Core** engineered in Verilog HDL. Designed with rigorous RTL design practices, the core features a deterministic single-cycle microarchitecture optimized for low silicon area, high clock-frequency efficiency, zero latch inference, and direct integration into physical ASIC synthesis flows (targeting the SkyWater 130nm PDK via OpenLane).

---

## Architecture & Microarchitectural Datapath

The processor implements a unified 32-bit datapath with single-cycle instruction retirement (1 CPI for all executed base instructions). 

```
+----------------------------------------------------------------------------------------------------+
|                                         MINI-RV32I CORE                                            |
|                                                                                                    |
|    +-------------+   Instruction [31:0]   +--------------------+                                   |
|    |   Program   | ---------------------> |    Control Unit    | === Control Buses                     |
|    | Counter(PC) |                        | (Opcode & Funct Dec|     (ALUSrc, RegWrite, MemRead...) |
|    +-------------+                        +--------------------+                                   |
|           |                                                                                        |
|           | Address [31:0]        Instruction [31:0]                                               |
|           v                               |                                                        |
|     +-----------+                         v                                                        |
|     |Instr Mem  |                 +--------------------+                                           |
|     |  (ROM)    |                 |   Immediate Gen    | -----------------+                        |
|     +-----------+                 |  (I, S, B, U, J)   |                  |                        |
|           |                       +--------------------+                  |                        |
|           |                                                               v                        |
|           +-----> rs1_addr [4:0]  +--------------------+ rs1_data [31:0] +-----+                   |
|           |       rs2_addr [4:0]  |   Register File    | --------------> | MUX |                   |
|           |                       |   (32 x 32-bit)    |                 +-----+                   |
|           +-----> rd_addr  [4:0]  |   x0 = Constant 0  |                    |                      |
|           |                       +--------------------+ rs2_data [31:0]    | Operand B            |
|           |                                 |                   |           v                      |
|           |                                 |                   +-----> +---------------+          |
|           |                                 |                           |  32-bit ALU   |          |
|           |                                 |                           | (Arith/Logic) |          |
|           |                                 |                           +---------------+          |
|           |                                 |                                   |                  |
|           |                                 |                                   +-----+            |
|           |                                 |                                         | Result     |
|           |                                 v                                         v            |
|           |                       +--------------------+                        +-----------+      |
|           |                       |   Data RAM / Bus   | <--------------------- | Data Mem  |      |
|           |                       +--------------------+                        +-----------+      |
|           |                                 |                                         |            |
|           |                                 +------------------<----------------------+            |
|           |                                 v                                                      |
|           +---------------------- [ Writeback MUX ]                                                |
+----------------------------------------------------------------------------------------------------+
```

### Microarchitectural Engineering Highlights

- **Deterministic 1-CPI Execution:** Every instruction computes and retires in a single synchronous clock period, eliminating pipeline stalls, hazard forwarding penalties, and branch mispredict bubbles.
- **Strict RV32I ISA Compliance:** Full hardware decode and execution for all standard RV32I integer formats: **R-Type, I-Type, S-Type, B-Type, U-Type, and J-Type**.
- **Silicon-Conscious Register File ($32 \times 32$-bit):**
  - **Dual Asynchronous Read Ports:** Instantaneous combinatorial access to source registers $rs1$ and $rs2$ without pipeline latency.
  - **Single Synchronous Write Port:** Edge-triggered commit on `posedge clk` protected by write-enable qualification.
  - **Zero-Overhead $x0$ Hardwiring:** Register $x0$ is hardwired to `32'h0000_0000` via combinatorial logic masking, preventing parasitic power dissipation from redundant switching.
- **Low-Latency Arithmetic Logic Unit (ALU):** 10-function execution core optimized for fast carry chains and efficient area utilization under standard cell synthesis.
- **Full Immediate Decoding Matrix:** Unified sign-extension and bit-slicing logic capable of dynamic 32-bit immediate reconstruction across all five immediate topologies.

---

## Instruction Set Architecture (RV32I Base)

The core natively decodes and computes the complete RV32I base integer specification:

| Instruction Category | Opcode / Type | Instructions Implemented |
| :--- | :--- | :--- |
| **Integer Arithmetic** | R-Type / I-Type | `ADD`, `SUB`, `ADDI` |
| **Logical Operations** | R-Type / I-Type | `AND`, `OR`, `XOR`, `ANDI`, `ORI`, `XORI` |
| **Shift Operations** | R-Type / I-Type | `SLL`, `SRL`, `SRA`, `SLLI`, `SRLI`, `SRAI` |
| **Comparisons** | R-Type / I-Type | `SLT` (Signed), `SLTU` (Unsigned), `SLTI`, `SLTIU` |
| **Upper Immediates** | U-Type | `LUI` (Load Upper Immediate), `AUIPC` (Add Upper Immediate to PC) |
| **Branch Operations** | B-Type | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` |
| **Jump & Link** | J-Type / I-Type | `JAL` (Unconditional Jump), `JALR` (Indirect Jump) |
| **Memory Access** | I-Type / S-Type | `LW`, `LH`, `LB`, `LHU`, `LBU`, `SW`, `SH`, `SB` |

---

## Hardware Subsystem Specifications

### 1. Arithmetic Logic Unit (`alu.v`)
The ALU serves as the primary execution engine. It accepts two 32-bit operands (`a`, `b`) and a 4-bit control code (`alu_ctrl`), outputting a 32-bit computation result along with conditional status flags:

| `alu_ctrl` | Symbol | Hardware Operation | Description |
| :---: | :--- | :--- | :--- |
| `4'b0000` | `ALU_ADD`  | $R = A + B$ | 32-bit Two's Complement Integer Addition |
| `4'b0001` | `ALU_SUB`  | $R = A - B$ | 32-bit Two's Complement Subtraction |
| `4'b0011` | `ALU_AND`  | $R = A \ \& \ B$ | Bitwise Conjunction |
| `4'b0100` | `ALU_OR`   | $R = A \ \| \ B$ | Bitwise Disjunction |
| `4'b0101` | `ALU_XOR`  | $R = A \oplus B$ | Bitwise Exclusive-OR |
| `4'b0110` | `ALU_SLT`  | $R = (\$signed(A) < \$signed(B)) \ ? \ 1 : 0$ | Signed Arithmetic Comparison |
| `4'b0111` | `ALU_SLTU` | $R = (A < B) \ ? \ 1 : 0$ | Unsigned Magnitude Comparison |
| `4'b1000` | `ALU_SLL`  | $R = A \ll B[4:0]$ | Logical Left Shift (up to 31 positions) |
| `4'b1001` | `ALU_SRL`  | $R = A \gg B[4:0]$ | Logical Right Shift (Zero Insertion) |
| `4'b1010` | `ALU_SRA`  | $R = \$signed(A) \ggg B[4:0]$ | Arithmetic Right Shift (Sign Preserved) |

- **Zero Flag Evaluation:** Evaluated via an inverted reduction NOR gate (`assign zero = (result == 32'd0)`), asserting single-cycle branch condition triggers.

### 2. Program Counter (`pc.v`)
- Synchronous 32-bit program pointer clocked at target system frequency.
- Active-low asynchronous reset (`rst_n`) guarantees deterministic core initialization to vector `0x0000_0000`.
- Glitch-free update path interfacing directly with the instruction cache/ROM address bus.

### 3. Register File (`regfile.v`)
- High-density $32 \times 32$-bit register array ($1024$ flip-flop storage bits).
- **Asynchronous Dual Read:** Provides simultaneous read availability of operands $rs1$ and $rs2$ during the instruction decode phase.
- **Controlled Synchronous Write:** Evaluates `reg_write_en` on the rising clock edge with write-address qualification:
  $$\text{Target Register} \leftarrow (\text{rd\_addr} \neq 0 \land \text{reg\_write\_en}) \ ? \ \text{wr\_data} : \text{Hold}$$
- Guaranteed immunity against accidental modification of $x0$.

### 4. Immediate Generator (`imm_gen.v`)
Dedicated combinatorial decoding hardware that reconstructs non-contiguous immediate bitfields into signed 32-bit words:
- **I-Format:** $\text{SignExt}(\text{instr}[31:20])$ (12-bit signed immediate)
- **S-Format:** $\text{SignExt}(\{\text{instr}[31:25], \text{instr}[11:7]\})$ (12-bit signed store offset)
- **B-Format:** $\text{SignExt}(\{\text{instr}[31], \text{instr}[7], \text{instr}[30:25], \text{instr}[11:8], 1'b0\})$ (13-bit halfword-aligned branch displacement)
- **U-Format:** $\{\text{instr}[31:12], 12'b0\}$ (20-bit page-aligned upper immediate)
- **J-Format:** $\text{SignExt}(\{\text{instr}[31], \text{instr}[19:12], \text{instr}[20], \text{instr}[30:21], 1'b0\})$ (21-bit jump displacement)

---

## RTL Design & ASIC Synthesis Considerations

The RTL codebase adheres strictly to synthesizable digital design principles:

1. **Zero Latch Inference:** All combinatorial `always @(*)` blocks enforce complete case coverage with explicit defaults, ensuring strictly combinational cell mapping without unintended transparent latches.
2. **Synchronous Reset Domain:** Edge-triggered storage units conform to standard cell flip-flop architectures with predictable setup and hold time margins ($T_{\text{setup}}$, $T_{\text{hold}}$).
3. **Static Timing Analysis (STA) Friendly:** Minimal combinational path depth between clock boundaries to maximize operational $F_{\text{max}}$.
4. **Physical Implementation Target:** Compatible with automated place-and-route (APR) flows such as **OpenLane / OpenROAD**, targeting the **SkyWater 130nm (sky130_fd_sc_hd)** high-density standard cell library for clean DRC/LVS physical silicon tapeout.

---

## Core File Hierarchy

```
Mini-RV32I/
├── alu.v             # Parameterized 32-bit Arithmetic Logic Unit
├── pc.v              # Synchronous 32-bit Program Counter
├── regfile.v         # Dual-Read, Single-Write 32x32 Register File
├── imm_gen.v         # Multi-format Immediate Sign-Extension Unit
├── control_unit.v    # Instruction Decoder & Main Control Logic
├── rv32i_top.v       # Top-Level Core Datapath Interconnect
├── project.md        # Technical Architecture Reference
└── README.md         # Professional Core Specification
```

---

## Technical References

- **RISC-V ISA Specification:** [Volume I: Unprivileged ISA (v20191213)](https://riscv.org/technical/specifications/)
- **Computer Architecture:** *Computer Organization and Design: RISC-V Edition* (David A. Patterson, John L. Hennessy)
- **Open-Source Silicon:** [SkyWater 130nm PDK Documentation](https://skywater-pdk.readthedocs.io/) & [The OpenROAD Project](https://theopenroadproject.org/)

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

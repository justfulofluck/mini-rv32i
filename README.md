# Mini-RV32I

[![RISC-V](https://img.shields.io/badge/ISA-RISC--V%20RV32I-blue.svg)](https://riscv.org/)
[![Target PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm-red.svg)](https://github.com/google/skywater-pdk)
[![Flow](https://img.shields.io/badge/ASIC%20Flow-OpenLane-blueviolet.svg)](https://github.com/The-OpenROAD-Project/OpenLane)
[![License](https://img.shields.io/badge/License-MIT-orange.svg)]()

A synthesizable, single-cycle **32-bit RISC-V (RV32I)** processor core engineered in Verilog HDL. Tapeout-ready for **SkyWater 130nm** via OpenLane with zero latch inference and clean DRC/LVS.

---

## Features

- **Single-Cycle (1 CPI):** Deterministic execution of every base instruction in a single clock cycle.
- **Full RV32I Base ISA:** Complete hardware support for R, I, S, B, U, and J format instructions.
- **Sub-Word Memory Access:** Byte and halfword loads/stores (`LB`, `LH`, `LW`, `LBU`, `LHU`, `SB`, `SH`, `SW`) with 4-bit write masking (`mem_write_mask`).
- **Register File ($32 \times 32$-bit):** Dual asynchronous read ports, synchronous write port, and hardwired zero register (`x0`).
- **Physical Design Ready:** Clean timing and automated place-and-route targeting `sky130_fd_sc_hd`.

---

## Datapath

```
                +--------------------+
                |    Control Unit    | === Control Signals
                +--------------------+
                  ^                |
Instruction [31:0]|                v
   [PC] -----> [Instr] -----> [Registers] -----> [ALU] -----> [Data RAM]
     ^                              |              |              |
     +--------- (PC + 4 / Jump / Branch) <---------+--------------+
```

---

## File Hierarchy

```
mini-rv32i/
├── openlane/
│   ├── config.json / config.tcl    # OpenLane ASIC & PDK configs
│   └── src/                        # Synthesizable RTL
│       ├── top.v                   # Core datapath & interconnect
│       ├── alu.v                   # 32-bit Arithmetic Logic Unit
│       ├── control_unit.v          # Instruction decoder
│       ├── imm_gen.v               # Immediate generator
│       ├── pc.v                    # Program Counter
│       └── regfile.v               # 32x32 register file
├── ram.v                           # 1 KB RAM with byte-masked write
├── tb_top.v                        # Full-system testbench
├── tb_*.v                          # Unit testbenches (alu, control, imm, regfile)
├── run.md                          # Quick commands reference
└── README.md
```

---

## Quickstart

### 1. Simulation (Icarus Verilog)

Run the full core self-checking testbench:

```bash
iverilog -o tb_top.vvp openlane/src/*.v ram.v tb_top.v && vvp tb_top.vvp
```

Run unit testbenches:
```bash
iverilog -o tb_alu.vvp openlane/src/alu.v tb_alu.v && vvp tb_alu.vvp
iverilog -o tb_control_unit.vvp openlane/src/control_unit.v tb_control_unit.v && vvp tb_control_unit.vvp
iverilog -o tb_imm_gen.vvp openlane/src/imm_gen.v tb_imm_gen.v && vvp tb_imm_gen.vvp
iverilog -o tb_regfile.vvp openlane/src/regfile.v tb_regfile.v && vvp tb_regfile.vvp
```

Waveform inspection:
```bash
gtkwave top.vcd
```

### 2. ASIC Synthesis & Tapeout (OpenLane)

Run RTL-to-GDSII flow:
```bash
openlane /home/bhavan/Public/work/mini-rv32i/openlane -tag mini-rv32i -overwrite
```

Inspect layout in KLayout:
```bash
cd openlane/runs/mini-rv32i
klayout -l results/signoff/top.lyp results/final/gds/top.gds &
```

---

## Supported Instructions

| Category | Instructions |
| :--- | :--- |
| **Arithmetic & Logic** | `ADD`, `SUB`, `ADDI`, `AND`, `OR`, `XOR`, `ANDI`, `ORI`, `XORI` |
| **Shifts** | `SLL`, `SRL`, `SRA`, `SLLI`, `SRLI`, `SRAI` |
| **Comparisons** | `SLT`, `SLTU`, `SLTI`, `SLTIU` |
| **Memory (Load/Store)** | `LB`, `LH`, `LW`, `LBU`, `LHU`, `SB`, `SH`, `SW` |
| **Branches** | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` |
| **Jumps & U-Type** | `JAL`, `JALR`, `LUI`, `AUIPC` |

---

## License

MIT License. See [LICENSE](LICENSE) for details.

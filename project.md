**Project Name: Mini-RV32I (Single-Cycle 32-bit RISC-V Processor)**

Building a single-cycle implementation of the open-standard **RISC-V RV32I base integer instruction set** is the industry standard for learning digital computer architecture. It strikes the right balance between being genuinely useful (it can run compiled C programs) and completely manageable for a beginner.

---

### What Knowledge You Will Gain

* **Computer Architecture Fundamentals:**
* Understand how instructions travel through the five classic stages: **Fetch $\rightarrow$ Decode $\rightarrow$ Execute $\rightarrow$ Memory Access $\rightarrow$ Writeback**.
* Master how machine code (raw 32-bit binary instructions) gets translated into hardware control signals.
* Learn how memory addressing, branching, immediate decoding, and pointer arithmetic actually work at the hardware level.

* **Digital Design & HDL Techniques:**
* Clean synchronous vs. asynchronous RTL design patterns in Verilog.
* Designing multi-port register files with proper write-enable masking.
* Structural hierarchy: writing modular sub-blocks and wiring them together using clean buses without creating combinational loops or latch inferences.

* **Physical Design & ASIC Realities (OpenLane/Sky130):**
* How abstract Verilog lines turn into physical standard cells, logic gates, and copper interconnects.
* Understanding real-world chip metrics: cell count, core utilization, clock-to-Q delays, setup/hold margins, and static timing analysis (STA).
* The transition from RTL simulation waveform traces directly to physical GDSII layout.

---

### Hands-on Experience You Will Build

| Phase | Milestone | Concrete Skills Developed |
| --- | --- | --- |
| **Phase 1: Datapath Execution** | Design & verify `alu.v` | Implementing 32-bit arithmetic, logic shifts, signed/unsigned comparisons, and overflow detection in Verilog. |
| **Phase 2: Storage & State** | Design `regfile.v` & `pc.v` | Building dual-read single-write register arrays, hardwiring register `x0` to zero, and managing program flow. |
| **Phase 3: Instruction Decoder** | Design `control_unit.v` | Parsing opcodes, `funct3`, and `funct7` fields to generate multiplexer select lines and write enables. |
| **Phase 4: Core Integration** | Assemble `rv32i_top.v` | Structural port mapping, wiring buses together, and handling sign-extension for immediate values (I, S, B, U, J types). |
| **Phase 5: System Simulation** | Write `tb_rv32i.v` | Creating a mock RAM model, compiling a small assembly program (like computing a Fibonacci sequence or array sum), and running functional verification. |
| **Phase 6: ASIC Hardening** | Push through OpenLane | Synthesizing, floorplanning, placing, routing, and checking post-route timing to generate a clean, DRC-free GDSII layout. |

---

**Phase 1: The Arithmetic Logic Unit (`alu.v`)**

* **The Concept:** The ALU is the mathematical calculator of the CPU. It has no memory; it takes two 32-bit binary inputs, an operation code, and outputs the calculation.
* **Tasks:**
* Write Verilog code handling basic math: addition (`ADD`), subtraction (`SUB`), logic operations (`AND`, `OR`, `XOR`), and shifts (`SLL`, `SRL`, `SRA`).
* Add comparison logic: Set Less Than (`SLT` for signed, `SLTU` for unsigned numbers).
* Build a dedicated testbench (`tb_alu.v`) to test positive/negative numbers, zero checks, and edge cases.

**Phase 2: Storage and State (`regfile.v` & `pc.v`)**

* **The Concept:** A CPU needs temporary scratchpads (registers) to hold variables while working on them, and a pointer to know which instruction to run next.
* **Tasks:**
* Build the **Program Counter (`pc.v`)**: A 32-bit register that updates on every clock tick (usually advancing by $+4$ bytes to fetch the next instruction, or jumping if there is a branch).
* Build the **Register File (`regfile.v`)**: An array of 32 registers ($x_0$ to $x_{31}$), each 32 bits wide.
* Implement two read ports (to fetch two operands at the same time) and one write port (to store results).
* Enforce the RISC-V rule: Register $x_0$ must always output zero, even if written to.

**Phase 3: The Immediate Generator (`imm_gen.v`)**

* **The Concept:** Assembly instructions often contain fixed numbers directly inside them (e.g., `addi x1, x2, 5`). These immediate bits are scattered across the 32-bit instruction word to keep hardware simple.
* **Tasks:**
* Extract and rearrange the embedded immediate bits based on the instruction format (I-type, S-type, B-type, U-type, and J-type).
* Sign-extend smaller values (like a 12-bit constant) into full 32-bit values so the ALU can safely compute with them.

**Phase 4: The Brain / Control Unit (`control_unit.v`)**

* **The Concept:** The control unit looks at the raw binary instruction and flips the internal switches (multiplexers and enables) to steer data through the CPU.
* **Tasks:**
* Decode the 7-bit `opcode`, 3-bit `funct3`, and 7-bit `funct7` fields.
* Generate simple control flags:
* `RegWrite`: Should we save the result to a register?
* `ALUSrc`: Is the second operand a register or an immediate number?
* `MemWrite` / `MemRead`: Are we accessing external RAM?
* `Branch`: Are we testing a condition to jump?
* `ALUControl`: Which exact math operation should the ALU execute?

**Phase 5: Core Assembly (`rv32i_top.v`)**

* **The Concept:** Stitch all the individual modules together into a complete single-cycle datapath.
* **Tasks:**
* Connect the modules using internal wires: `PC` $\rightarrow$ `Instruction Fetch` $\rightarrow$ `Decode` $\rightarrow$ `ALU` $\rightarrow$ `Writeback`.
* Place multiplexers (MUXes) at decision points (e.g., choosing whether the next PC value comes from $\text{PC}+4$ or a branch target address).

**Phase 6: Functional Verification (`tb_top.v`)**

* **The Concept:** Testing the assembled processor by letting it run an actual software program.
* **Tasks:**
* Write a mock memory model (`data_mem.v` / `instr_mem.v`) to hold binary code and data.
* Write a short 5-to-10 line RISC-V assembly test program (such as computing $1 + 2 + 3 + 4$ in a loop).
* Convert the assembly code into hexadecimal machine code (`program.hex`).
* Run a Verilog simulation (using Icarus Verilog/GTKWave) to verify that registers update correctly cycle-by-cycle.

**Phase 7: ASIC Synthesis & Layout (OpenLane)**

* **The Concept:** Turning the verified Verilog code into physical silicon geometry (GDSII).
* **Tasks:**
* Write an OpenLane `config.json` defining clock target (e.g., $10\text{ ns}$ / $100\text{ MHz}$) and core area.
* Run synthesis, floorplanning, placement, clock tree synthesis (CTS), and routing.
* Inspect the generated layout in KLayout to see the physical standard cells, power grid, and routing tracks.

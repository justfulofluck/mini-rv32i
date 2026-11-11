# LinkedIn Posts for Mini-RV32I

Yahan do variations hain—ek **Simple & Direct** aur ek **Technical Deep-Dive**. Jo bhi aapke network ke liye best lage, aap copy-paste kar sakte hain.

---

## Option 1: Simple & Direct (Recommended)

🚀 **Excited to share my latest project: Mini-RV32I — A Single-Cycle 32-bit RISC-V Processor Core!**

I designed and verified a synthesizable 32-bit RISC-V processor from scratch in Verilog HDL, fully taped out to GDSII using OpenLane on the SkyWater 130nm PDK.

Here are a few key highlights:
🔹 **Architecture:** Complete RV32I base integer ISA support (R, I, S, B, U, and J instructions) with a deterministic 1 CPI single-cycle datapath.
🔹 **Sub-Word Memory Handling:** Implemented byte-masked memory access supporting LB, LH, LW, SB, SH, and SW with full sign/zero extension.
🔹 **Rigorous Verification:** Built modular unit testbenches and an end-to-end integration testbench in Icarus Verilog (100% test pass rate).
🔹 **Physical Design Signoff (OpenLane & Sky130):**
   - 0 DRC Violations
   - 0 LVS Mismatches
   - Positive Setup & Hold Slack with zero timing violations

Building a CPU from architecture specification down to physical GDSII layout was an incredible learning experience in digital design and physical signoff.

Check out the repository here: [Insert GitHub Repo Link]

Looking forward to your thoughts and feedback! 👇

#RISCV #VLSI #DigitalDesign #Verilog #OpenLane #SkyWater130nm #Semiconductor #ASIC #HardwareEngineering

---

## Option 2: Technical & Modular Breakdown

From Verilog RTL to GDSII: Meet **Mini-RV32I** ⚡

Over the past few weeks, I’ve been working on designing a clean, tapeout-ready 32-bit RISC-V (RV32I) processor core. Here is a breakdown of what went into it:

⚙️ **Microarchitecture:**
- 32-bit ALU executing 10 arithmetic, logic, and comparison operations.
- 32 × 32-bit dual-read synchronous register file with hardwired `x0`.
- Control unit decoding all standard RISC-V formats with zero latch inference.
- Branch and jump resolution (PC-relative & register-indirect).

🛠️ **Memory & Sub-word Access:**
- Synchronous memory interface with 4-bit write masking (`mem_write_mask`) enabling clean byte/halfword operations.

🧪 **Verification & ASIC Flow:**
- Verified through self-checking testbenches with GTKWave waveform analysis.
- Pushed through the OpenLane RTL-to-GDSII flow targeting `sky130_fd_sc_hd` with clean signoff metrics (Zero DRC / Zero LVS / Zero WNS).

Next up: Planning a standardized Wishbone bus interconnect and memory-mapped peripherals (UART / GPIO / Timers)!

Explore the project code: [Insert GitHub Repo Link]

#ComputerArchitecture #RTL #ASICDesign #OpenSourceSilicon #Verilog #RISCV

---

## Targeted Hashtags & Indian Companies for Hiring Visibility

### 📌 High-Traffic Hashtags for India Hiring:
```
#SemiconductorIndia #VLSIJobs #RTLDesign #ASICVerification #PhysicalDesign #ChipDesign #IndiaSemiconductorMission #OpenLane #SkyWater130nm #RISCVIndia #DigitalVLSI #HardwareJobsIndia
```

### 🏢 Companies Operating in India to Target / Tag:
1. **RISC-V & Indigenous Silicon Startups:**
   - **InCore Semiconductors** (Chennai) - Custom RISC-V processors & IP cores
   - **Mindgrove Technologies** (IIT Madras incubated) - SoC design on RISC-V
   - **Tenstorrent India** (Bengaluru) - AI processors powered by RISC-V
   - **Calligo Technologies** / **Morphing Machines**
2. **Global Semiconductor & VLSI MNCs in India (Bengaluru / Hyderabad / Noida):**
   - **Texas Instruments India**
   - **Qualcomm India**
   - **Intel India**
   - **NVIDIA India**
   - **AMD India**
   - **MediaTek India**
   - **NXP Semiconductors India**
   - **Microchip Technology India**
3. **EDA & Design Services Giants:**
   - **Synopsys India**
   - **Cadence Design Systems**
   - **Wipro VLSI / HCL Semiconductor / Tata Elxsi / Cyient**

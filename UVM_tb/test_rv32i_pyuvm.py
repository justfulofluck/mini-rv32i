import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import pyuvm
from pyuvm import *

# ==========================================
# 1. Transaction Item
# ==========================================
class Rv32iSeqItem(uvm_sequence_item):
    def __init__(self, name="Rv32iSeqItem"):
        super().__init__(name)
        self.instr = 0x00000013       # Default NOP (addi x0, x0, 0)
        self.data_rdata = 0x00000000  # Data from RAM
        self.pc = 0x00000000
        self.data_addr = 0x00000000
        self.data_wdata = 0x00000000
        self.mem_read = 0
        self.mem_write = 0
        self.mem_write_mask = 0

# ==========================================
# 2. Sequence (Stimulus Generator)
# ==========================================
class Rv32iTestSequence(uvm_sequence):
    async def body(self):
        # Sample test instructions:
        # 1. addi x1, x0, 10   -> 0x00a00093
        # 2. addi x2, x0, 20   -> 0x01400113
        # 3. add  x3, x1, x2   -> 0x002081b3 (x3 = 30)
        # 4. sw   x3, 0(x0)    -> 0x00302023
        instructions = [
            0x00a00093,  # addi x1, x0, 10
            0x01400113,  # addi x2, x0, 20
            0x002081b3,  # add  x3, x1, x2 (x3 = 30)
            0x00302023,  # sw   x3, 0(x0)
            0x00000013,  # nop
            0x00000013   # nop
        ]

        for instr in instructions:
            item = Rv32iSeqItem("instr_item")
            await self.start_item(item)
            item.instr = instr
            item.data_rdata = 0
            await self.finish_item(item)

# ==========================================
# 3. Driver
# ==========================================
class Rv32iDriver(uvm_driver):
    def build_phase(self):
        self.dut = cocotb.top

    async def run_phase(self):
        # Reset core
        self.dut.rst_n.value = 0
        self.dut.instr.value = 0x00000013
        self.dut.data_rdata.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 1

        while True:
            item = await self.seq_item_port.get_next_item()
            await RisingEdge(self.dut.clk)
            self.dut.instr.value = item.instr
            self.dut.data_rdata.value = item.data_rdata
            self.seq_item_port.item_done()

# ==========================================
# 4. Monitor
# ==========================================
class Rv32iMonitor(uvm_monitor):
    def build_phase(self):
        self.dut = cocotb.top
        self.ap = uvm_analysis_port("mon_ap", self)

    async def run_phase(self):
        while True:
            await RisingEdge(self.dut.clk)
            if self.dut.rst_n.value == 1:
                item = Rv32iSeqItem("mon_item")
                item.pc = int(self.dut.instr_addr.value)
                item.data_addr = int(self.dut.data_addr.value)
                item.data_wdata = int(self.dut.data_wdata.value)
                item.mem_write = int(self.dut.mem_write.value)
                item.mem_read = int(self.dut.mem_read.value)
                self.ap.write(item)

# ==========================================
# 5. Scoreboard & Analysis Export
# ==========================================
class Rv32iScoreboardExport(uvm_analysis_export):
    def __init__(self, name, parent):
        super().__init__(name, parent)

    def write(self, item):
        self.parent.write(item)

class Rv32iScoreboard(uvm_scoreboard):
    def build_phase(self):
        self.export = Rv32iScoreboardExport("sb_export", self)
        self.passed_checks = 0

    def write(self, item):
        if item.mem_write == 1:
            self.logger.info(f"[SCOREBOARD] STORE Detected -> Addr: 0x{item.data_addr:08x}, Data: 0x{item.data_wdata:08x}")
            self.passed_checks += 1

    def check_phase(self):
        self.logger.info(f"[SCOREBOARD] Total Verified Checks: {self.passed_checks}")
        assert self.passed_checks > 0, "No valid write operations detected!"

# ==========================================
# 6. Environment & Test
# ==========================================
class Rv32iEnv(uvm_env):
    def build_phase(self):
        self.seqr = uvm_sequencer("seqr", self)
        self.driver = Rv32iDriver("driver", self)
        self.monitor = Rv32iMonitor("monitor", self)
        self.scoreboard = Rv32iScoreboard("scoreboard", self)

    def connect_phase(self):
        self.driver.seq_item_port.connect(self.seqr.seq_item_export)
        self.monitor.ap.connect(self.scoreboard.export)

class Rv32iPyuvmTest(uvm_test):
    def build_phase(self):
        self.env = Rv32iEnv("env", self)

    async def run_phase(self):
        self.raise_objection()
        seq = Rv32iTestSequence("test_seq")
        await seq.start(self.env.seqr)
        await Timer(100, unit="ns")
        self.drop_objection()

# ==========================================
# Cocotb Entry Point
# ==========================================
@cocotb.test()
async def run_uvm_test(dut):
    # Start 50 MHz clock
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())
    
    # Run test
    await uvm_root().run_test("Rv32iPyuvmTest")

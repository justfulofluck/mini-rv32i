# Simulator selection
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# RTL Source files
VERILOG_SOURCES += $(PWD)/../openlane/src/alu.v
VERILOG_SOURCES += $(PWD)/../openlane/src/control_unit.v
VERILOG_SOURCES += $(PWD)/../openlane/src/imm_gen.v
VERILOG_SOURCES += $(PWD)/../openlane/src/pc.v
VERILOG_SOURCES += $(PWD)/../openlane/src/regfile.v
VERILOG_SOURCES += $(PWD)/../openlane/src/top.v

# Top module name in Verilog
TOPLEVEL = top

# Python test module name
MODULE = test_rv32i_pyuvm

# Include cocotb make rules
include $(shell cocotb-config --makefiles)/Makefile.sim

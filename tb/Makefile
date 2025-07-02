# Makefile

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES =
COMPILE_ARGS += -f tb_yarp.f

# enable waveform dumping
WAVES = 1

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb_yarp_top

# MODULE is the basename of the Python test file
MODULE = test_yarp_top

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: filelist
filelist:
	bender script flist > tb_yarp.f

# make clean
clean::
	$(RM) -r __pycache__
	$(RM) results.xml
	$(RM) tb_yarp.f
	$(RM) ../Bender.lock

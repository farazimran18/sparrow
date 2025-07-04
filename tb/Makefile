# Makefile

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES =
COMPILE_ARGS += -f filelist.f

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
	bender script flist > filelist.f

# make clean
clean::
	$(RM) -r __pycache__
	$(RM) results.xml
	$(RM) ../Bender.lock
	$(RM) ../*.log
	$(RM) ../.dvt/*.xml
	$(RM) -rf ../.dvt/.build_config_dict

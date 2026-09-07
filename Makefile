TOP       := TB
SOURCES   := $(wildcard Code/*.sv)
BUILD     := build
SIMULATOR := $(BUILD)/$(TOP).vvp

.PHONY: all sim clean
all: sim

$(SIMULATOR): $(SOURCES)
	@mkdir -p $(BUILD)
	iverilog -g2012 -o $@ -s $(TOP) $(SOURCES)

sim: $(SIMULATOR)
	cd Code && vvp ../$(SIMULATOR)

clean:
	rm -rf $(BUILD) Code/sim.vcd

filename = hdl/top
main_filename = hdl/top
testbench = testbench/top
visual_style_file = visual_style.gtkw
pcf_file = pcf/iceBlinkPico.pcf

build: $(filename).sv $(pcf_file)
	yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc --pcf-allow-unconstrained
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin

test:
	iverilog -g2012 -I./hdl -o $(testbench) $(testbench)_tb.sv && vvp $(testbench) && gtkwave $(testbench).vcd $(visual_style_file)

show:
	gtkwave $(testbench).vcd $(visual_style_file)

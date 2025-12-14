filename = rotary_encoder_test_top
main_filename = rotary_encoder
testbench = testbench
visual_style_file = visual_style.gtkw
pcf_file = ../../pcf/iceBlinkPico.pcf

build: $(filename).sv $(pcf_file)
	yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc --pcf-allow-unconstrained
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

clean:
	del /s /q $(filename).blif $(filename).asc $(filename).json $(filename).bin

test:
	iverilog -g2012 -o $(main_filename) $(main_filename)_tb.sv && vvp $(main_filename) && gtkwave $(main_filename).vcd visual_style.gtkw

show:
	gtkwave $(main_filename).vcd $(visual_style_file)


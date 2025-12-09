filename = top
main_filename = top
visual_style_file = visual_style.gtkw
pcf_file = pcf/iceBlinkPico.pcf
hdl_dir = hdl

build: $(hdl_dir)/$(filename).sv $(pcf_file)
	yosys -p "synth_ice40 -top top -json $(filename).json" $(hdl_dir)/$(filename).sv
	nextpnr-ice40 --up5k --package sg48 --top top --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin

test:
	iverilog -g2012 -o $(main_filename) $(main_filename)_tb.sv && vvp $(main_filename) && gtkwave $(main_filename).vcd visual_style.gtkw

show:
	gtkwave $(main_filename).vcd $(visual_style_file)


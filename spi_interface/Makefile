TESTBENCH = testbench.sv

all: $(RTL_TOP_FILE)
	iverilog -o wave -y ./ -y ./misc $(RTL_TOP_FILE) $(TESTBENCH)
	vvp -n wave -lxt2
	gtkwave wave.vcd

clean:
	rm ./wave ./wave.vcd

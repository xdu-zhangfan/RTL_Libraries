RTL_TOP_FILE = multiplier_unsigned.v
TESTBENCH = testbench.sv

all:
	iverilog -o wave -y ./ $(RTL_TOP_FILE) $(TESTBENCH)
	vvp -n wave -lxt2
	gtkwave wave.vcd

clean:
	rm ./wave ./wave.vcd

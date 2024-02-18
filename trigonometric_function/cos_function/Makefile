RTL_TOP_FILE = cos_function_x4.v cos_function_x1.v
TESTBENCH = testbench.sv

all:
	iverilog -o wave -y ./ $(RTL_TOP_FILE) $(TESTBENCH)
	vvp -n wave -lxt2
	gtkwave wave.vcd

clean:
	rm ./wave ./wave.vcd

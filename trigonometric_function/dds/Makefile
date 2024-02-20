TESTBENCH = testbench.sv

all:
	iverilog -o wave -y ./ -y ../cos_function $(RTL_TOP_FILE) $(TESTBENCH)
	vvp -n wave -lxt2
	gtkwave wave.vcd

clean:
	rm ./wave ./wave.vcd

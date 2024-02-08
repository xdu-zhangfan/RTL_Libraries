`timescale 1ns / 1ns

module testbench ();

  initial begin
    $dumpfile("wave.vcd");  //生成的vcd文件名称
    $dumpvars(0, testbench);  //tb模块名称
  end

  localparam CLK_PERIOD = 4;
  localparam MUL_BITWIDTH = 32;
  localparam SIM_TIME = 100000;

  reg clk = 0;
  always #(CLK_PERIOD / 2) clk = ~clk;

  reg rstn = 0;
  initial #(50 * CLK_PERIOD) rstn = 1;

  reg  [    MUL_BITWIDTH-1:0] in_a;
  reg  [    MUL_BITWIDTH-1:0] in_b;
  wire [(MUL_BITWIDTH*2)-1:0] out_p;

  multiplier_unsigned #(
      .BITWIDTH_INPUT(MUL_BITWIDTH)
  ) multiplier_unsigned_inst (
      .clk (clk),
      .rstn(rstn),

      .a(in_a),
      .b(in_b),
      .q(out_p)
  );

  initial begin
    in_a = {MUL_BITWIDTH{1'b0}};
    in_b = {MUL_BITWIDTH{1'b0}};

    #(60 * CLK_PERIOD);
    #(CLK_PERIOD / 2);

    for (in_a = {MUL_BITWIDTH{1'b0}}; in_a < 16; ++in_a) begin
      #(CLK_PERIOD);

      for (in_b = {MUL_BITWIDTH{1'b0}}; in_b < 16; ++in_b) begin
        #(CLK_PERIOD);
      end
    end

  end

  initial begin
    #(SIM_TIME) $finish;
  end

endmodule

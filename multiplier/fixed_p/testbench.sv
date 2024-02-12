`timescale 1ns / 1ns

module testbench ();

  localparam CLK_PERIOD = 4;
  localparam SIM_TIME = 10000000;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, testbench);
  end

  initial begin
    #(SIM_TIME) $finish;
  end

  reg clk = 1;
  always #(CLK_PERIOD / 2) clk = ~clk;

  reg rstn = 0;
  initial #(50 * CLK_PERIOD) rstn = 1;

  localparam INTEGER_BITWIDTH = 8;
  localparam FRACTION_BITWIDTH = 8;

  reg  [(INTEGER_BITWIDTH+FRACTION_BITWIDTH)-1:0] in_a;
  reg  [(INTEGER_BITWIDTH+FRACTION_BITWIDTH)-1:0] in_b;
  wire [(INTEGER_BITWIDTH+FRACTION_BITWIDTH)-1:0] out_p;

  multiplier_fixedpoint #(
      .INTEGER_BITWIDTH (INTEGER_BITWIDTH),
      .FRACTION_BITWIDTH(FRACTION_BITWIDTH)
  ) multiplier_fixedpoint_inst (
      .clk (clk),
      .rstn(rstn),

      .a(in_a),
      .b(in_b),
      .q(out_p)
  );

  localparam SIM_STEP = 16;

  initial begin
    in_a = {(INTEGER_BITWIDTH + FRACTION_BITWIDTH) {1'b0}};
    in_b = {(INTEGER_BITWIDTH + FRACTION_BITWIDTH) {1'b0}};

    #(60 * CLK_PERIOD);

    for (in_a = 0; in_a < 2 ** (INTEGER_BITWIDTH + FRACTION_BITWIDTH)-SIM_STEP; in_a = in_a + SIM_STEP) begin
      for (in_b = 0; in_b < 2 ** (INTEGER_BITWIDTH + FRACTION_BITWIDTH)-SIM_STEP; in_b = in_b + SIM_STEP) begin
        #(CLK_PERIOD);
      end
    end
  end

endmodule

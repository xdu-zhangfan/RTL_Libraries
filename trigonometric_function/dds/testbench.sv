`timescale 1ns / 1ns

module testbench ();

  localparam CLK_PERIOD = 4;
  localparam SIM_TIME = 10000;

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

  localparam DEPTH_BITWIDTH = 8;
  localparam DATA_BITWIDTH = 8;

  reg  [DEPTH_BITWIDTH-1:0] pword;
  wire [ DATA_BITWIDTH-1:0] cos;

  cos_function_x1 #(
      .DEPTH_BITWIDTH(DEPTH_BITWIDTH),
      .DATA_BITWIDTH (DATA_BITWIDTH)
  ) cos_function_inst (
      .clk (clk),
      .rstn(rstn),

      .pword(pword),
      .cos  (cos)
  );

  initial begin
    pword = 0;

    #(60 * CLK_PERIOD);

    for (pword = 0; 1; pword = pword + 1) #(CLK_PERIOD);

  end

endmodule

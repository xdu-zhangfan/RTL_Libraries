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
  reg  [DEPTH_BITWIDTH-1:0] fword;
  wire [ DATA_BITWIDTH-1:0] cos;
  wire [ DATA_BITWIDTH-1:0] sin;

  dds #(
      .DEPTH_BITWIDTH(DEPTH_BITWIDTH),
      .DATA_BITWIDTH (DATA_BITWIDTH)
  ) dds_inst (
      .clk (clk),
      .rstn(rstn),

      .pword(pword),
      .fword(fword),

      .cos(cos),
      .sin(sin)
  );

  initial begin
    pword = 0;
    fword = 2;

    #(60 * CLK_PERIOD);

    // for (pword = 0; 1; pword = pword + 1) #(CLK_PERIOD);

  end

endmodule

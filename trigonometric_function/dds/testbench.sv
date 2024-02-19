`timescale 1ns / 1ns

module testbench ();

  localparam CLK_PERIOD = 8;
  localparam SIM_TIME = 50000;

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

  localparam DEPTH_BITWIDTH = 16;
  localparam DATA_BITWIDTH = 14;

  localparam LOAD_FREQ_MHZ = 10;
  localparam S_FREQ_0_KHZ = 500;

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

  reg     [31:0] i;
  reg     [31:0] freq_0;
  integer        res_file;
  initial begin
    i        = 0;
    freq_0   = 0;
    pword    = 0;
    fword    = 2 ** DEPTH_BITWIDTH / (1000 / CLK_PERIOD / LOAD_FREQ_MHZ);

    res_file = $fopen("res.dat", "w");

    #(60 * CLK_PERIOD);

    for (i = 0; 1; i = i + 1) begin
      #(CLK_PERIOD);
      freq_0 = $sin(2 * 3.14159 / (1000000 / CLK_PERIOD / S_FREQ_0_KHZ) * i) * (2 ** (DEPTH_BITWIDTH - 2));
      pword  = freq_0 + (2 ** (DEPTH_BITWIDTH - 1));

      $fdisplay(res_file, "%04d", cos);
      $fflush(res_file);
    end

  end

endmodule

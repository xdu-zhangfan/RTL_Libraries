`timescale 1ns / 1ns

module testbench ();

  localparam CLK_PERIOD = 10;
  localparam SIM_TIME = 200000;

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

  reg           psel;
  reg           penable;
  reg           pwrite;
  reg  [31 : 0] paddr;
  reg  [31 : 0] pwdata;
  wire          pready;
  wire [31 : 0] prdata;

  task apb_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      psel    <= 1'b1;
      penable <= 1'b0;
      pwrite  <= 1'b1;
      paddr   <= addr;
      pwdata  <= data;

      @(posedge clk);
      penable <= 1'b1;

      while (pready != 1'b1) @(posedge clk);
      psel    <= 1'b0;
      penable <= 1'b0;
      pwrite  <= 1'b0;
      paddr   <= 32'b0;
      pwdata  <= 32'b0;
      repeat (2) @(posedge clk);
    end
  endtask

  task apb_read(input [31:0] addr, output [31:0] data);
    begin
      @(posedge clk);
      psel    <= 1'b1;
      penable <= 1'b0;
      pwrite  <= 1'b0;
      paddr   <= addr;

      @(posedge clk);
      penable <= 1'b1;

      while (pready != 1'b1) @(posedge clk);
      data    <= prdata;
      psel    <= 1'b0;
      penable <= 1'b0;
      pwrite  <= 1'b0;
      paddr   <= 32'b0;
      repeat (2) @(posedge clk);
    end
  endtask

  localparam CONV_BITWIDTH = 16;
  localparam CONV_CORE_DEPTH = 16;

  localparam FREQ_0_MHZ = 7;
  localparam FREQ_1_MHZ = 14;

  reg                      data_in_enable;
  reg  [CONV_BITWIDTH-1:0] data_in;

  wire                     data_pp_out_enable;
  wire [CONV_BITWIDTH-1:0] data_pp_out;
  wire                     data_res_out_enable;
  wire [CONV_BITWIDTH-1:0] data_res_out;

  convolution_core_timemultiplex #(
      .CONV_CORE_DEPTH(CONV_CORE_DEPTH),
      .DATA_BITWIDTH(CONV_BITWIDTH),
      .OUTPUT_SHIFT_BITS(12)
  ) convolution_core_timemultiplex_inst (
      .clk (clk),
      .rstn(rstn),

      .data_in_enable(data_in_enable),
      .data_in       (data_in),

      .data_pp_out_enable (data_pp_out_enable),
      .data_pp_out        (data_pp_out),
      .data_res_out_enable(data_res_out_enable),
      .data_res_out       (data_res_out),

      .p_sel  (psel),
      .p_strb (4'b1111),
      .p_addr (paddr),
      .p_wdata(pwdata),
      .p_ce   (penable),
      .p_we   (pwrite),
      .p_rdy  (pready),
      .p_rdata(prdata)
  );

  reg [31 : 0] conv_core_mem[0 : CONV_CORE_DEPTH - 1];
  initial begin
    $readmemh("./python/conv_core.dat", conv_core_mem);
  end

  reg     [31 : 0] conv_core_mem_i;
  reg     [31 : 0] data_i;
  reg     [31 : 0] freq_0;
  reg     [31 : 0] freq_1;
  integer          orgin_res_file;
  integer          proc_res_file;

  initial begin
    #(60 * CLK_PERIOD);

    $display("Initialized.");

    for (conv_core_mem_i = 0; conv_core_mem_i < CONV_CORE_DEPTH; conv_core_mem_i = conv_core_mem_i + 1) begin
      apb_write(conv_core_mem_i, conv_core_mem[conv_core_mem_i]);
    end

    $display("Wrote parameters.");
    // $finish;

    orgin_res_file = $fopen("orgin_res.dat", "w");
    proc_res_file  = $fopen("proc_res.dat", "w");


    for (data_i = 0; 1; data_i = data_i + 1) begin
      #(CONV_CORE_DEPTH * 2 * CLK_PERIOD);
      data_in_enable = 1;

      freq_0         = $sin(2 * 3.14159 / (1000 / CLK_PERIOD / FREQ_0_MHZ) * data_i) * (2 ** (CONV_BITWIDTH - 3));
      freq_1         = $sin(2 * 3.14159 / (1000 / CLK_PERIOD / FREQ_1_MHZ) * data_i) * (2 ** (CONV_BITWIDTH - 3));
      data_in        = freq_0 + freq_1 + (2 ** (CONV_BITWIDTH - 1));

      #(CLK_PERIOD);
      data_in_enable = 0;

      if (data_i > CONV_CORE_DEPTH * 2) begin
        $fdisplay(orgin_res_file, "%04d", data_pp_out);
        $fflush(orgin_res_file);
      end

      if (data_i > CONV_CORE_DEPTH + $clog2(CONV_CORE_DEPTH) + 2048) begin
        $finish;
      end
    end
  end

  always @(posedge data_res_out_enable) begin
    $fdisplay(proc_res_file, "%04d", data_res_out);
    $fflush(proc_res_file);
  end

endmodule

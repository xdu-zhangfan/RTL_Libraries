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

  localparam SPI_CLK_PERIOD = 1000;
  localparam SPI_TL = 16;
  reg  spi_m_sck = 0;
  reg  spi_m_csn;
  wire spi_m_miso;
  reg  spi_m_mosi;

  task spi_m_rw_0_byte(input [SPI_TL-1:0] send_data, output [SPI_TL-1:0] recv_data);
    begin
      spi_m_csn = 0;

      for (integer i = 0; i < SPI_TL; i = i + 1) begin
        spi_m_mosi = send_data[i];

        #(SPI_CLK_PERIOD / 2);
        recv_data[i] = spi_m_miso;
        spi_m_sck    = 1;

        #(SPI_CLK_PERIOD / 2);
        spi_m_sck = 0;
      end

      #(SPI_CLK_PERIOD);
      spi_m_csn = 1;

      #(SPI_CLK_PERIOD);
    end
  endtask

  task spi_m_rw_1_byte(input [SPI_TL-1:0] send_data, output [SPI_TL-1:0] recv_data);
    begin
      spi_m_csn = 0;
      #(SPI_CLK_PERIOD / 2);

      for (integer i = 0; i < SPI_TL; i = i + 1) begin
        #(SPI_CLK_PERIOD / 2);
        spi_m_mosi = send_data[i];
        spi_m_sck  = 1;

        #(SPI_CLK_PERIOD / 2);
        recv_data[i] = spi_m_miso;
        spi_m_sck    = 0;
      end

      #(SPI_CLK_PERIOD);
      spi_m_csn = 1;

      #(SPI_CLK_PERIOD);
    end
  endtask

  localparam SPI_TESTBUF_MAXLEN = 256;
  reg [SPI_TL-1:0] spi_m_send_buf[0:SPI_TESTBUF_MAXLEN-1];
  reg [SPI_TL-1:0] spi_m_recv_buf[0:SPI_TESTBUF_MAXLEN-1];
  task spi_m_rw_0_buffer(input [$clog2(SPI_TESTBUF_MAXLEN)-1:0] rw_length);
    reg [SPI_TL-1:0] send_data;
    reg [SPI_TL-1:0] recv_data;

    begin
      spi_m_csn = 0;

      for (integer j = 0; j < rw_length + 1; j = j + 1) begin
        send_data = spi_m_send_buf[j];

        for (integer i = 0; i < SPI_TL; i = i + 1) begin
          spi_m_mosi = send_data[i];

          #(SPI_CLK_PERIOD / 2);
          recv_data[i] = spi_m_miso;
          spi_m_sck    = 1;

          #(SPI_CLK_PERIOD / 2);
          spi_m_sck = 0;
        end

        recv_data_buf[j] = recv_data;
      end

      #(SPI_CLK_PERIOD);
      spi_m_csn = 1;

      #(SPI_CLK_PERIOD);
    end
  endtask
  task spi_m_rw_1_buffer(input [$clog2(SPI_TESTBUF_MAXLEN)-1:0] rw_length);
    reg [SPI_TL-1:0] send_data;
    reg [SPI_TL-1:0] recv_data;

    begin
      spi_m_csn = 0;

      for (integer j = 0; j < rw_length + 1; j = j + 1) begin
        send_data = spi_m_send_buf[j];

        for (integer i = 0; i < SPI_TL; i = i + 1) begin
          #(SPI_CLK_PERIOD / 2);
          spi_m_mosi = send_data[i];
          spi_m_sck  = 1;

          #(SPI_CLK_PERIOD / 2);
          recv_data[i] = spi_m_miso;
          spi_m_sck    = 0;
        end

        recv_data_buf[j] = recv_data;
      end

      #(SPI_CLK_PERIOD);
      spi_m_csn = 1;

      #(SPI_CLK_PERIOD);
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
  wire [CONV_BITWIDTH-1:0] data_res_out;

  spi_slave_interface #(
      .SPI_CPOL     (0),
      .SPI_CPHA     (0),
      .SPI_FSB      (0),
      .SPI_TL       (SPI_TL),
      .AXIS_ENDIAN  (0),
      .AXIS_BITWIDTH(256)
  ) spi_slave_interface_inst (
      .aclk   (clk),
      .aresetn(rstn),

      .axis_m_tvalid(),
      .axis_m_tready(1),
      .axis_m_tdata (),
      .axis_m_tlast (),
      .axis_m_tstrb (),
      .axis_m_tkeep (),

      .spi_s_sck (spi_m_sck),
      .spi_s_csn (spi_m_csn),
      .spi_s_miso(spi_m_miso),
      .spi_s_mosi(spi_m_mosi)
  );

  initial begin
    spi_m_send_buf[0] = 'h425a;
    spi_m_send_buf[1] = 'h78a5;
    spi_m_send_buf[2] = 'hff01;
    spi_m_send_buf[3] = 'h10ff;
  end

  reg [SPI_TL-1:0] recv_data_buf;
  initial begin
    spi_m_csn  = 1;
    spi_m_mosi = 0;
    #(60 * CLK_PERIOD);

    $display("Initialized.");

    spi_m_rw_0_byte('h3423, recv_data_buf);
    spi_m_rw_0_buffer(3);
  end

endmodule

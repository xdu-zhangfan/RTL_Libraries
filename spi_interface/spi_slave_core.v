module spi_slave_core #(
    parameter SPI_CPOL = 0,
    parameter SPI_CPHA = 0,
    parameter SPI_FSB  = 0,  // 0 - MSB First, 1 - LSB First
    parameter SPI_TL   = 8   // SPI transmission length, default 8
) (
    input clk,
    input rstn,

    input      [SPI_TL-1:0] spi_send_data,
    output reg              spi_send_data_ready,
    input                   spi_send_data_valid,

    output reg [SPI_TL-1:0] spi_recv_data,
    input                   spi_recv_data_ready,
    output reg              spi_recv_data_valid,

    // SPI
    input      spi_s_sck,
    input      spi_s_csn,
    output reg spi_s_miso,
    input      spi_s_mosi
);

  wire spi_start_int;
  wire spi_stop_int;
  misc_edge_detector misc_edge_detector_spi_s_csn (
      .clk (clk),
      .rstn(rstn),

      .signal      (spi_s_csn),
      .rising_edge (spi_stop_int),
      .falling_edge(spi_start_int)
  );

  wire spi_clk_front_edge;
  wire spi_clk_trailing_edge;
  generate
    if (SPI_CPOL == 0) begin : g_misc_edge_detector_spi_s_sck
      misc_edge_detector misc_edge_detector_spi_s_sck (
          .clk (clk),
          .rstn(rstn),

          .signal      (spi_s_sck & (~spi_s_csn)),
          .rising_edge (spi_clk_front_edge),
          .falling_edge(spi_clk_trailing_edge)
      );
    end else begin : g_misc_edge_detector_spi_s_sck
      misc_edge_detector misc_edge_detector_spi_s_sck (
          .clk (clk),
          .rstn(rstn),

          .signal      (spi_s_sck & (~spi_s_csn)),
          .rising_edge (spi_clk_trailing_edge),
          .falling_edge(spi_clk_front_edge)
      );
    end
  endgenerate

  wire spi_send_int;
  wire spi_recv_int;
  generate
    if (SPI_CPHA == 0) begin : g_spi_sr_int
      assign spi_send_int = spi_start_int | spi_clk_trailing_edge;
      assign spi_recv_int = spi_clk_front_edge;
    end else begin : g_spi_sr_int
      assign spi_send_int = spi_clk_front_edge;
      assign spi_recv_int = spi_clk_trailing_edge;
    end
  endgenerate

  reg [$clog2(SPI_TL):0] spi_send_cnt;
  reg [$clog2(SPI_TL):0] spi_recv_cnt;
  always @(posedge clk) begin
    if (!rstn) begin
      spi_send_cnt <= {($clog2(SPI_TL) + 1) {1'b0}};
      spi_recv_cnt <= {($clog2(SPI_TL) + 1) {1'b0}};
    end else begin
      if (spi_s_csn) begin
        spi_send_cnt <= {($clog2(SPI_TL) + 1) {1'b0}};
        spi_recv_cnt <= {($clog2(SPI_TL) + 1) {1'b0}};
      end else begin
        if (spi_send_cnt < SPI_TL) begin
          if (spi_send_int) begin
            spi_send_cnt <= spi_send_cnt + 1;
          end else begin
            spi_send_cnt <= spi_send_cnt;
          end
        end else begin
          if (spi_send_data_valid && spi_send_data_ready) begin
            spi_send_cnt <= {($clog2(SPI_TL) + 1) {1'b0}};
          end else begin
            spi_send_cnt <= spi_send_cnt;
          end
        end

        if (spi_recv_cnt < SPI_TL) begin
          if (spi_recv_int) begin
            spi_recv_cnt <= spi_recv_cnt + 1;
          end else begin
            spi_recv_cnt <= spi_recv_cnt;
          end
        end else begin
          if (spi_recv_data_valid && spi_recv_data_ready) begin
            spi_recv_cnt <= {($clog2(SPI_TL) + 1) {1'b0}};
          end else begin
            spi_recv_cnt <= spi_recv_cnt;
          end
        end
      end
    end
  end

  always @(posedge clk) begin
    if (!rstn) begin
      spi_send_data_ready <= 1'b0;
      spi_s_miso          <= 1'b0;
    end else begin
      if (spi_send_cnt < SPI_TL) begin
        spi_send_data_ready <= 0;
      end else begin
        if (spi_send_data_valid && spi_send_data_ready) begin
          spi_send_data_ready <= 0;
        end else begin
          spi_send_data_ready <= 1;
        end
      end

      if (spi_send_int) begin
        if (spi_send_cnt < SPI_TL) begin
          spi_s_miso <= spi_send_data[spi_send_cnt[$clog2(SPI_TL)-1:0]];
        end else begin
          if (spi_recv_data_ready && spi_recv_data_valid) begin
            spi_s_miso <= {SPI_TL{1'b0}};
          end else begin
            spi_s_miso <= spi_s_miso;
          end
        end
      end else begin
        spi_s_miso <= spi_s_miso;
      end
    end
  end

  always @(posedge clk) begin
    if (!rstn) begin
      spi_recv_data       <= {SPI_TL{1'b0}};
      spi_recv_data_valid <= 1'b0;
    end else begin
      if (spi_recv_cnt < SPI_TL) begin
        spi_recv_data_valid <= 0;
      end else begin
        if (spi_recv_data_valid && spi_recv_data_ready) begin
          spi_recv_data_valid <= 0;
        end else begin
          spi_recv_data_valid <= 1;
        end
      end

      if (spi_recv_int) begin
        if (spi_recv_cnt < SPI_TL) begin
          spi_recv_data[spi_recv_cnt[$clog2(SPI_TL)-1:0]] <= spi_s_mosi;
        end else begin
          if (spi_recv_data_ready && spi_recv_data_valid) begin
            spi_recv_data <= {SPI_TL{1'b0}};
          end else begin
            spi_recv_data <= spi_recv_data;
          end
        end
      end else begin
        spi_recv_data <= spi_recv_data;
      end
    end
  end

endmodule

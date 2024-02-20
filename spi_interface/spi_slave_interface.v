module spi_slave_interface #(
    parameter SPI_CPOL      = 0,
    parameter SPI_CPHA      = 0,   // Default mode 0
    parameter SPI_FSB       = 0,   // 0 - MSB First, 1 - LSB First
    parameter SPI_TL        = 8,   // SPI transmission length, default 8
    parameter AXIS_ENDIAN   = 0,   // 0 - little endian, 1 - big endian
    parameter AXIS_BITWIDTH = 256  // AXI-Stream bit width, default 256
) (
    input aclk,
    input aresetn,

    // AXI-Stream master
    output reg         axis_m_tvalid,
    input              axis_m_tready,
    output reg [255:0] axis_m_tdata,
    output reg         axis_m_tlast,
    output reg [ 31:0] axis_m_tstrb,
    output reg [ 31:0] axis_m_tkeep,

    // AXI-Stream slave
    input                              axis_s_tvalid,
    output reg                         axis_s_tready,
    input      [    AXIS_BITWIDTH-1:0] axis_s_tdata,
    input                              axis_s_tlast,
    input      [(AXIS_BITWIDTH/8)-1:0] axis_s_tstrb,
    input      [(AXIS_BITWIDTH/8)-1:0] axis_s_tkeep,

    // SPI
    input  spi_s_sck,
    input  spi_s_csn,
    output spi_s_miso,
    input  spi_s_mosi
);

  localparam AXIS_TL = AXIS_BITWIDTH / SPI_TL;

  reg  [SPI_TL-1:0] spi_send_data = 'h5a;
  wire              spi_send_data_ready;
  reg               spi_send_data_valid = 1;
  wire [SPI_TL-1:0] spi_recv_data;
  reg               spi_recv_data_ready = 1;
  wire              spi_recv_data_valid;
  spi_slave_core #(
      .SPI_CPOL(SPI_CPOL),
      .SPI_CPHA(SPI_CPHA),
      .SPI_FSB (SPI_FSB),
      .SPI_TL  (SPI_TL)
  ) spi_slave_core_inst (
      .clk (aclk),
      .rstn(aresetn),

      .spi_send_data      (spi_send_data),
      .spi_send_data_ready(spi_send_data_ready),
      .spi_send_data_valid(spi_send_data_valid),

      .spi_recv_data      (spi_recv_data),
      .spi_recv_data_ready(spi_recv_data_ready),
      .spi_recv_data_valid(spi_recv_data_valid),

      .spi_s_sck (spi_s_sck),
      .spi_s_csn (spi_s_csn),
      .spi_s_miso(spi_s_miso),
      .spi_s_mosi(spi_s_mosi)
  );



endmodule  //spi_recv

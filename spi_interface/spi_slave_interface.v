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

    // APB interface (configure)
    input             p_sel,
    input      [ 3:0] p_strb,
    input      [31:0] p_addr,
    input      [31:0] p_wdata,
    input             p_ce,
    input             p_we,
    output reg        p_rdy,
    output reg [31:0] p_rdata,

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

  // APB Logic
  localparam CONF_BUF_LENGTH = 8;
  localparam STATE_BUF_LENGTH = 8;
  reg  [31:0] conf_buf    [ 0:CONF_BUF_LENGTH - 1];
  wire [31:0] state_buf   [0:STATE_BUF_LENGTH - 1];
  reg  [31:0] conf_buf_ci;
  reg  [ 7:0] apb_state;
  localparam APB_RESET = 8'h00;
  localparam APB_IDEL = 8'h01;
  localparam APB_WRITE = 8'h02;
  localparam APB_READ = 8'h03;
  always @(posedge clk) begin
    if (!rstn) begin
      conf_buf_ci <= 32'h0;

      p_rdy       <= 1'b0;
      p_rdata     <= 32'h0;

      apb_state   <= APB_RESET;
    end else begin
      case (apb_state)
        APB_RESET: begin
          conf_buf[conf_buf_ci] <= 32'h0;

          if (conf_buf_ci < CONF_BUF_LENGTH - 1) begin
            conf_buf_ci <= conf_buf_ci + 1;
            apb_state   <= APB_RESET;
          end else begin
            conf_buf_ci <= 32'h0;
            apb_state   <= APB_IDEL;
          end

          p_rdy   <= 1'b0;
          p_rdata <= 32'h0;
        end
        APB_IDEL: begin
          conf_buf_ci <= 32'h0;

          p_rdy       <= 1'b0;
          p_rdata     <= 32'h0;

          if (p_sel) begin
            if (p_we) begin
              apb_state <= APB_WRITE;
            end else begin
              apb_state <= APB_READ;
            end
          end else begin
            apb_state <= APB_IDEL;
          end
        end
        APB_WRITE: begin
          conf_buf_ci <= 32'h0;

          if (p_ce) begin
            p_rdy            <= 1'b1;
            conf_buf[p_addr] <= p_wdata;

            apb_state        <= APB_IDEL;
          end else begin
            p_rdy <= 1'b0;
            if (p_addr < CONF_BUF_LENGTH) begin
              conf_buf[p_addr] <= conf_buf[p_addr];
            end

            apb_state <= APB_WRITE;
          end

          p_rdata <= 32'h0;
        end
        APB_READ: begin
          conf_buf_ci <= 32'h0;

          if (p_ce) begin
            p_rdy     <= 1'b1;
            p_rdata   <= (p_addr < CONF_BUF_LENGTH) ? conf_buf[p_addr] : state_buf[p_addr];

            apb_state <= APB_IDEL;
          end else begin
            p_rdy     <= 1'b0;
            p_rdata   <= 32'h0;

            apb_state <= APB_READ;
          end
        end
        default: begin
          conf_buf_ci <= 32'h0;

          p_rdy       <= 1'b0;
          p_rdata     <= 32'h0;

          apb_state   <= APB_RESET;
        end
      endcase
    end
  end

  localparam AXIS_TL = AXIS_BITWIDTH / SPI_TL;

  reg  [SPI_TL-1:0] spi_send_data;
  wire              spi_send_data_ready;
  reg               spi_send_data_valid;
  wire [SPI_TL-1:0] spi_recv_data;
  reg               spi_recv_data_ready;
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

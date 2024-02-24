module convolution_core_timemultiplex #(
    parameter CONV_CORE_DEPTH = 32,
    parameter DATA_BITWIDTH = 16,
    parameter OUTPUT_SHIFT_BITS = 4
) (
    input clk,
    input rstn,

    // Data flow
    input                     data_in_enable,
    input [DATA_BITWIDTH-1:0] data_in,

    output                         data_pp_out_enable,
    output     [DATA_BITWIDTH-1:0] data_pp_out,
    output reg                     data_res_out_enable,
    output reg [DATA_BITWIDTH-1:0] data_res_out,

    // APB interface
    input             p_sel,
    input      [ 3:0] p_strb,
    input      [31:0] p_addr,
    input      [31:0] p_wdata,
    input             p_ce,
    input             p_we,
    output reg        p_rdy,
    output reg [31:0] p_rdata
);

  // APB Logic
  localparam CONF_BUF_LENGTH = CONV_CORE_DEPTH;
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

  genvar gen_i;
  genvar gen_j;
  genvar gen_k;

  // Generate a pipeline for input data
  reg [DATA_BITWIDTH-1:0] conv_pipeline[0:CONV_CORE_DEPTH - 1];
  generate
    for (gen_i = 1; gen_i < CONV_CORE_DEPTH; gen_i = gen_i + 1) begin : g_conv_pipeline
      always @(posedge clk) begin
        if (!rstn) begin
          conv_pipeline[gen_i] <= {DATA_BITWIDTH{1'b0}};
        end else begin
          if (data_in_enable) begin
            conv_pipeline[gen_i] <= conv_pipeline[gen_i-1];
          end else begin
            conv_pipeline[gen_i] <= conv_pipeline[gen_i];
          end

        end
      end
    end
  endgenerate
  always @(posedge clk) begin
    if (!rstn) begin
      conv_pipeline[0] <= {DATA_BITWIDTH{1'b0}};
    end else begin
      if (data_in_enable) begin
        conv_pipeline[0] <= data_in;
      end else begin
        conv_pipeline[0] <= conv_pipeline[0];
      end
    end
  end
  assign data_pp_out = conv_pipeline[CONV_CORE_DEPTH-1];

  // generate data_pp_out enable signal
  reg [CONV_CORE_DEPTH - 1:0] data_pp_out_enable_buf;
  generate
    for (gen_i = 1; gen_i < CONV_CORE_DEPTH; gen_i = gen_i + 1) begin : g_data_pp_out_enable_buf
      always @(posedge clk) begin
        if (!rstn) begin
          data_pp_out_enable_buf[gen_i] <= 1'b0;
        end else begin
          data_pp_out_enable_buf[gen_i] <= data_pp_out_enable_buf[gen_i-1];
        end
      end
    end
  endgenerate
  always @(posedge clk) begin
    if (!rstn) begin
      data_pp_out_enable_buf[0] <= 1'b0;
    end else begin
      data_pp_out_enable_buf[0] <= data_in_enable;
    end
  end
  assign data_pp_out_enable = data_pp_out_enable_buf[CONV_CORE_DEPTH-1];

  //Multiplier
  reg [$clog2(CONV_CORE_DEPTH)-1:0] mul_op_index;
  always @(posedge clk) begin
    if (!rstn) begin
      mul_op_index <= {$clog2(CONV_CORE_DEPTH) {1'b0}};
    end else begin
      if (data_in_enable) begin
        mul_op_index <= {$clog2(CONV_CORE_DEPTH) {1'b0}};
      end else begin
        if (mul_op_index != {$clog2(CONV_CORE_DEPTH) {1'b1}}) begin
          mul_op_index <= mul_op_index + 1;
        end else begin
          mul_op_index <= mul_op_index;
        end
      end
    end
  end

  wire [               31:0] conv_arg = conf_buf[mul_op_index];
  wire [2*DATA_BITWIDTH-1:0] mul_res;
  multiplier_unsigned #(
      .BITWIDTH_INPUT(DATA_BITWIDTH)
  ) multiplier_unsigned_inst (
      .clk (clk),
      .rstn(rstn),

      .a(conv_pipeline[mul_op_index]),
      .b(conv_arg[DATA_BITWIDTH-1:0]),
      .q(mul_res)
  );

  reg [31:0] delay_cnt;
  always @(posedge clk) begin
    if (!rstn) begin
      delay_cnt <= {32{1'b0}};
    end else begin
      if (data_in_enable) begin
        delay_cnt <= {32{1'b0}};
      end else begin
        if (delay_cnt < $clog2(DATA_BITWIDTH) * 2 - 1) begin
          delay_cnt <= delay_cnt + 1;
        end else begin
          delay_cnt <= delay_cnt;
        end
      end
    end
  end

  reg [$clog2(CONV_CORE_DEPTH)-1:0] adder_cnt;
  reg [        2*DATA_BITWIDTH-1:0] adder_bufs_0;
  always @(posedge clk) begin
    if (!rstn) begin
      adder_cnt    <= {$clog2(CONV_CORE_DEPTH) {1'b0}};
      adder_bufs_0 <= {(2 * DATA_BITWIDTH) {1'b0}};
    end else begin
      if (delay_cnt < $clog2(DATA_BITWIDTH) * 2 - 1) begin
        adder_cnt    <= {$clog2(CONV_CORE_DEPTH) {1'b0}};
        adder_bufs_0 <= {(2 * DATA_BITWIDTH) {1'b0}};
      end else begin
        if (adder_cnt != CONV_CORE_DEPTH - 1) begin
          adder_cnt    <= adder_cnt + 1;
          adder_bufs_0 <= adder_bufs_0 + mul_res;
        end else begin
          adder_cnt    <= adder_cnt;
          adder_bufs_0 <= adder_bufs_0;
        end
      end
    end
  end

  reg [$clog2(CONV_CORE_DEPTH)-1:0] adder_cnt_buf[0:1];
  always @(posedge clk) begin
    if (!rstn) begin
      adder_cnt_buf[0] <= 1'b0;
      adder_cnt_buf[1] <= 1'b0;
    end else begin
      adder_cnt_buf[0] <= adder_cnt;
      adder_cnt_buf[1] <= adder_cnt_buf[0];
    end
  end

  wire [2*DATA_BITWIDTH-1:0] adder_bufs_1 = adder_bufs_0 + mul_res;
  always @(posedge clk) begin
    if (!rstn) begin
      data_res_out_enable <= 1'b0;
      data_res_out        <= {DATA_BITWIDTH{1'b0}};
    end else begin
      if ((adder_cnt_buf[0] == CONV_CORE_DEPTH - 1) && (adder_cnt_buf[1] != CONV_CORE_DEPTH - 1)) begin
        data_res_out_enable <= 1'b1;
        data_res_out        <= adder_bufs_1[DATA_BITWIDTH-1+OUTPUT_SHIFT_BITS:OUTPUT_SHIFT_BITS];
      end else begin
        data_res_out_enable <= 1'b0;
        data_res_out        <= {DATA_BITWIDTH{1'b0}};
      end
    end
  end

endmodule  //convolution_core

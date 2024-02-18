module dds #(
    parameter DEPTH_BITWIDTH = 8,
    parameter DATA_BITWIDTH  = 8
) (
    input clk,
    input rstn,

    input [DEPTH_BITWIDTH-1:0] pword,
    input [DEPTH_BITWIDTH-1:0] fword,

    output [DATA_BITWIDTH-1:0] cos,
    output [DATA_BITWIDTH-1:0] sin
);

  reg [DEPTH_BITWIDTH-1:0] cosf_cos_pword;

  cos_function_x1 #(
      .DEPTH_BITWIDTH(DEPTH_BITWIDTH),
      .DATA_BITWIDTH (DATA_BITWIDTH)
  ) cos_function_inst_cos (
      .clk (clk),
      .rstn(rstn),

      .pword(cosf_cos_pword + pword),
      .cos  (cos)
  );

  wire [DEPTH_BITWIDTH-1:0] cosf_sin_pword = cosf_cos_pword + 2 ** (DEPTH_BITWIDTH - 2);
  cos_function_x1 #(
      .DEPTH_BITWIDTH(DEPTH_BITWIDTH),
      .DATA_BITWIDTH (DATA_BITWIDTH)
  ) cos_function_inst_sin (
      .clk (clk),
      .rstn(rstn),

      .pword(cosf_sin_pword + pword),
      .cos  (sin)
  );

  always @(posedge clk) begin
    if (!rstn) begin
      cosf_cos_pword <= {DEPTH_BITWIDTH{1'b0}};
    end else begin
      cosf_cos_pword <= cosf_cos_pword + fword;
    end
  end

endmodule  //dds

module top #(
    parameter MUL_BITWIDTH = 32
) (
    input clk,
    input rstn,

    input  [    MUL_BITWIDTH-1:0] a,
    input  [    MUL_BITWIDTH-1:0] b,
    output [(MUL_BITWIDTH*2)-1:0] p
);

  multiplier_unsigned #(
      .BITWIDTH_INPUT(MUL_BITWIDTH)
  ) multiplier_unsigned_inst (
      .clk (clk),
      .rstn(rstn),

      .a(a),
      .b(b),
      .q(p)
  );

endmodule

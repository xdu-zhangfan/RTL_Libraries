module multiplier_fixedpoint #(
    parameter INTEGER_BITWIDTH  = 4,
    parameter FRACTION_BITWIDTH = 4
) (
    input clk,
    input rstn,

    input  [(INTEGER_BITWIDTH+FRACTION_BITWIDTH)-1:0] a,
    input  [(INTEGER_BITWIDTH+FRACTION_BITWIDTH)-1:0] b,
    output [(INTEGER_BITWIDTH+FRACTION_BITWIDTH)-1:0] q
);
  localparam BITWIDTH = INTEGER_BITWIDTH + FRACTION_BITWIDTH;

  wire [(BITWIDTH*2)-1:0] mul_q;

  multiplier_unsigned #(
      .BITWIDTH_INPUT(BITWIDTH)
  ) multiplier_unsigned_inst (
      .clk (clk),
      .rstn(rstn),

      .a(a),
      .b(b),
      .q(mul_q)
  );

  assign q = mul_q[BITWIDTH+FRACTION_BITWIDTH-1:FRACTION_BITWIDTH];

endmodule

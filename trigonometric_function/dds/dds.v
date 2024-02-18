module dds #(
    parameter DEPTH_BITWIDTH = 8,
    parameter DATA_BITWIDTH  = 8
) (
    input clk,
    input rstn,

    input [DEPTH_BITWIDTH-1:0] pword,
    input [DEPTH_BITWIDTH-1:0] fword,

    output reg [DATA_BITWIDTH-1:0] cos,
    output reg [DATA_BITWIDTH-1:0] sin
);

endmodule  //dds

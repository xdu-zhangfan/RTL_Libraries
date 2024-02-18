module cos_function_x4 #(
    parameter DEPTH_BITWIDTH = 8,
    parameter DATA_BITWIDTH  = 8
) (
    input clk,
    input rstn,

    input      [DEPTH_BITWIDTH-1:0] pword,
    output reg [ DATA_BITWIDTH-1:0] cos
);

  reg [DATA_BITWIDTH-1:0] cos_rom[0:2**DEPTH_BITWIDTH-1];
  initial $readmemh("./python/cos_data_x4.dat", cos_rom);

  always @(posedge clk) begin
    if (!rstn) begin
      cos <= {DATA_BITWIDTH{1'b0}};
    end else begin
      cos <= cos_rom[pword];
    end
  end

endmodule  //cos_function_x4

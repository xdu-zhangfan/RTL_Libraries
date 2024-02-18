module cos_function_x1 #(
    parameter DEPTH_BITWIDTH = 8,
    parameter DATA_BITWIDTH  = 8
) (
    input clk,
    input rstn,

    input      [DEPTH_BITWIDTH-1:0] pword,
    output reg [ DATA_BITWIDTH-1:0] cos
);
  localparam DEPTH = 2 ** (DEPTH_BITWIDTH - 2);
  localparam DATA_MAX_VALUE = 2 ** DATA_BITWIDTH;

  reg [DATA_BITWIDTH-1:0] cos_rom[0:DEPTH-1];
  initial $readmemh("./python/cos_data_x1.dat", cos_rom);

  always @(posedge clk) begin
    if (!rstn) begin
      cos <= {DATA_BITWIDTH{1'b0}};
    end else begin
      if (pword < DEPTH) begin
        cos <= cos_rom[pword];
      end else if ((pword >= DEPTH) && (pword < 2 * DEPTH)) begin
        cos <= DATA_MAX_VALUE - cos_rom[2*DEPTH-pword-1];
      end else if ((pword >= 2 * DEPTH) && (pword < 3 * DEPTH)) begin
        cos <= DATA_MAX_VALUE - cos_rom[pword-2*DEPTH];
      end else begin
        cos <= cos_rom[4*DEPTH-pword-1];
      end

    end
  end

endmodule  //cos_function_x1

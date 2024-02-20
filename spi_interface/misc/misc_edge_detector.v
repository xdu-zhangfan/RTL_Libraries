module misc_edge_detector (
    input clk,
    input rstn,

    input  signal,
    output rising_edge,
    output falling_edge
);

  reg [1:0] signal_buf;
  always @(posedge clk) begin
    if (!rstn) begin
      signal_buf[0] <= 1'b0;
      signal_buf[1] <= 1'b0;
    end else begin
      signal_buf[0] <= signal;
      signal_buf[1] <= signal_buf[0];
    end
  end

  assign falling_edge  = (~signal_buf[0]) && (signal_buf[1]);
  assign rising_edge = (signal_buf[0]) && (~signal_buf[1]);

endmodule

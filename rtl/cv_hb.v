// -*- text -*-

module cv_hb (
  clk,
  reset,

  hbout
);

input  clk;
input  reset;
output hbout;

parameter CLKFREQ = 16000000;

//////////////////////////////////////////////////
reg [29:0] hb_count;
reg        hb_led;

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    hb_count <= 30'b0;
    hb_led   <= 1'b0;
  end else if (hb_count == (CLKFREQ / 2 - 1)) begin
    hb_count <= 30'd0;
    hb_led   <= ~hb_led;
  end else
    hb_count <= hb_count + 30'd1;
end

assign hbout = hb_led;

endmodule

// -*- text -*-
`timescale 1ns/1ps

module cv_2b10b (
  input   [1:0] din,
  output  [9:0] dout);

////////////////////////////////////////

assign dout = (din == 2'b00 ? 10'b1101010100 :
               din == 2'b01 ? 10'b0010101011 :
	       din == 2'b10 ? 10'b0101010100 :
	                      10'b1010101011);

endmodule

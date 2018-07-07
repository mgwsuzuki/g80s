// -*- text -*-
`timescale 1ns/1ps

module cv_countbit # (
  parameter ISIZE = 8,
  parameter OSIZE = 3,
  parameter CBIT  = 1) (
  input  [ISIZE-1:0] din,
  output [OSIZE-1:0] dout);

////////////////////////////////////////

function [OSIZE-1:0] counting;
input [ISIZE-1:0] din;
integer i;
integer c;

begin
  c = 0;
  for (i = 0; i < ISIZE; i=i+1) begin
    if (din[i] == CBIT) begin
      c = c + 1;
    end
  end
  counting = c;
end
endfunction

assign dout = counting(din);

endmodule
  

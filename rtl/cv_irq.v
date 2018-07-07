// -*- text -*-
`timescale 1 ns / 1 ps

module cv_irq (
  input       clk,
  input       reset,

  input       v_end,
  input [1:0] r_virq,
  output      irq);

reg irq_reg;
////////////////////////////////////////

always @(posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    irq_reg <= 1'b0;
  else if (v_end == 1'b1)
    irq_reg <= 1'b1 & r_virq[0];
  else if (r_virq[1] == 1'b1)
    irq_reg <= 1'b0;
end

assign irq = irq_reg;

endmodule

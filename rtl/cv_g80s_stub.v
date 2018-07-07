// -*- text -*-
`timescale 1 ns / 1 ps

module cv_g80s (
  input         clk,
  input         reset,
  output        oserdes_reset,
  input   [2:0] btn,
  input   [1:0] sw,

  output  [9:0] hdmi_r,
  output  [9:0] hdmi_g,
  output  [9:0] hdmi_b,

  input         ps_c_clk,
  input  [18:0] ps_c_addr,
  input  [31:0] ps_c_din,
  input   [3:0] ps_c_we,
  input         ps_c_en,
  output [31:0] ps_c_dout,

  input         ps_s_clk,
  input  [18:0] ps_s_addr,
  input  [31:0] ps_s_din,
  input   [3:0] ps_s_we,
  input         ps_s_en,
  output [31:0] ps_s_dout,

  output        irq,
  output  [2:0] led
);

endmodule // cv_g80s

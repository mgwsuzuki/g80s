// -*- text -*-
`timescale 1 ns / 1 ps
`include "cv_defines.v"

module cv_csmem_bg # (
  parameter TILE_ADDR = `BG_TILE0_ADDR,
  parameter REG_ADDR  = `BG_REG0_ADDR) (
  input         clk,
  input         reset,

  input         ps_c_clk,
  input  [18:0] ps_c_addr,
  input  [31:0] ps_c_din,
  input   [3:0] ps_c_we,
  input         ps_c_en,
  output [31:0] ps_c_dout,
  output        ps_c_dout_en,

  input  [13:0] t_addr,
  input         t_ren,
  output  [9:0] t_dout,

  output  [9:0] r_yoffset,
  output  [9:0] r_xoffset,
  output  [1:0] r_bank
);


////////////////////////////////////////
//// tile memory
wire        ps_t_en = (ps_c_addr[18:15] == (TILE_ADDR >> 15));
reg         ps_t_en_reg;
wire  [9:0] ps_t_dout0;
wire  [9:0] ps_t_dout1;
wire  [9:0] t_dout0;
wire  [9:0] t_dout1;
reg         t_addr0_reg;

cv_tdpram_rf_d10 # (
  .A_WIDTH (13)) tmem0 (
  // port0
  .clk0    (ps_c_clk),
  .addr0   (ps_c_addr[14:2]),
  .en0     (ps_t_en ? ps_c_en : 1'b0),
  .we0     (ps_t_en ? ps_c_we[1:0] : 2'b0),
  .wrdata0 (ps_c_din[9:0]),
  .rddata0 (ps_t_dout0),

  // port1
  .clk1    (clk),
  .addr1   (t_addr[13:1]),
  .we1     (2'b0),
  .en1     (t_ren),
  .wrdata1 (10'b0),
  .rddata1 (t_dout0)
);

cv_tdpram_rf_d10 # (
  .A_WIDTH (13)) tmem1 (
  // port0
  .clk0    (ps_c_clk),
  .addr0   (ps_c_addr[14:2]),
  .en0     (ps_t_en ? ps_c_en : 1'b0),
  .we0     (ps_t_en ? ps_c_we[3:2] : 2'b0),
  .wrdata0 (ps_c_din[25:16]),
  .rddata0 (ps_t_dout1),

  // port1
  .clk1    (clk),
  .addr1   (t_addr[13:1]),
  .we1     (2'b0),
  .en1     (t_ren),
  .wrdata1 (10'b0),
  .rddata1 (t_dout1)
);

always @ (posedge clk)
begin
  if (t_ren == 1'b1)
    t_addr0_reg <= t_addr[0];
end

assign t_dout = (t_addr0_reg == 1'b0 ? t_dout0 : t_dout1);

always @ (posedge ps_c_clk)
begin
  ps_t_en_reg <= ps_t_en;
end

////////////////////////////////////////
//// registers
wire        rg_cs = (ps_c_addr[18:10] == (REG_ADDR >> 10) && ps_c_en == 1'b1);
wire  [7:0] rg_addr_lsb = ps_c_addr[9:2];
reg   [9:0] rg_yoffset_reg;
reg   [9:0] rg_xoffset_reg;
reg   [1:0] rg_bank_reg;
reg  [31:0] rg_dout_reg;
reg         rg_dout_en_reg;

always @ (posedge ps_c_clk, posedge reset)
begin
  if (reset == 1'b1) begin
    rg_yoffset_reg <= 10'b0;
    rg_xoffset_reg <= 10'b0;
    rg_bank_reg    <= 2'b0;
  end else if (rg_cs == 1'b1) begin
    if (rg_addr_lsb == 8'h00 && ps_c_we[1:0] == 2'b11) rg_yoffset_reg <= ps_c_din[9:0];
    if (rg_addr_lsb == 8'h00 && ps_c_we[3:2] == 2'b11) rg_xoffset_reg <= ps_c_din[25:16];
    if (rg_addr_lsb == 8'h01 && ps_c_we[0]   == 1'b1 ) rg_bank_reg    <= ps_c_din[1:0];
  end
end

assign r_yoffset = rg_yoffset_reg;
assign r_xoffset = rg_xoffset_reg;
assign r_bank    = rg_bank_reg;

//// register dout
always @ (posedge ps_c_clk, posedge reset)
begin
  if (reset == 1'b1) begin
    rg_dout_reg    <= 32'b0;
    rg_dout_en_reg <= 1'b0;
  end else begin
    rg_dout_en_reg <= rg_cs;
    if (rg_cs == 1'b1)
      rg_dout_reg <= (rg_addr_lsb == 8'h00 ? {6'b0, rg_xoffset_reg, 6'b0, rg_yoffset_reg} :
      		      rg_addr_lsb == 8'h01 ? {30'b0, rg_bank_reg} :
		      		     	      32'b0);
  end
end

////////////////////////////////////////
//// ps_c_dout

assign ps_c_dout = (ps_t_en_reg    == 1'b1 ? {6'b0, ps_t_dout1, 6'b0, ps_t_dout0} :
       		    rg_dout_en_reg == 1'b1 ? rg_dout_reg : 32'b0);
assign ps_c_dout_en = ps_t_en_reg | rg_dout_en_reg;

endmodule

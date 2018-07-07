// -*- text -*-
`timescale 1 ns / 1 ps
`include "cv_defines.v"

module cv_csmem (
  input         clk,
  input         reset,

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

  input  [13:0] c_addr,
  input         c_ren,
  output [63:0] c_dout,

  input   [1:0] bg_screen,
  input  [13:0] t_addr,
  input         t_ren,
  output  [9:0] t_dout,

  input  [13:0] s_addr,
  input         s_ren,
  output [63:0] s_dout,

  input   [9:0] p_addr,
  input         p_ren,
  output [63:0] p_dout,

  output  [9:0] r_bg_yoffset,
  output  [9:0] r_bg_xoffset,
  output  [1:0] r_bg_bank,

  output  [1:0] r_virq,
  input   [2:0] rend_order_sel,
  output  [7:0] r_rend_order,
  output [15:0] r_sp_count
);


////////////////////////////////////////////////////////////
////
//// BG char memory
////
wire        cmem0_en = (ps_c_addr[18:17] == (`BG_CHAR_ADDR >> 17) && ps_c_addr[2] == 1'b0);
wire        cmem1_en = (ps_c_addr[18:17] == (`BG_CHAR_ADDR >> 17) && ps_c_addr[2] == 1'b1);
reg         cmem0_en_reg;
reg         cmem1_en_reg;
wire [31:0] cmem0_dout;
wire [31:0] cmem1_dout;

cv_tdpram_rf_be # (
  .A_WIDTH (14)) cmem0 (
  // port0
  .clk0    (ps_c_clk),
  .addr0   (ps_c_addr[16:3]),
  .en0     (cmem0_en ? ps_c_en : 1'b0),
  .we0     (cmem0_en ? ps_c_we : 4'b0),
  .wrdata0 (ps_c_din),
  .rddata0 (cmem0_dout),

  // port1
  .clk1    (clk),
  .addr1   (c_addr),
  .en1     (c_ren),
  .we1     (4'b0),
  .wrdata1 (32'b0),
  .rddata1 (c_dout[31:0])
);

cv_tdpram_rf_be # (
  .A_WIDTH (14)) cmem1 (
  // port0
  .clk0    (ps_c_clk),
  .addr0   (ps_c_addr[16:3]),
  .en0     (cmem1_en ? ps_c_en : 1'b0),
  .we0     (cmem1_en ? ps_c_we : 4'b0),
  .wrdata0 (ps_c_din),
  .rddata0 (cmem1_dout),

  // port1
  .clk1    (clk),
  .addr1   (c_addr),
  .en1     (c_ren),
  .we1     (4'b0),
  .wrdata1 (32'b0),
  .rddata1 (c_dout[63:32])
);

always @ (posedge ps_c_clk)
begin
  cmem0_en_reg <= cmem0_en;
  cmem1_en_reg <= cmem1_en;
end

////////////////////////////////////////
////
//// BG tile memory & registers
////
wire [31:0] bg0_dout;
wire        bg0_dout_en;
wire  [9:0] bg0_t_dout;
wire  [9:0] bg0_r_yoffset;
wire  [9:0] bg0_r_xoffset;
wire  [1:0] bg0_r_bank;
wire [31:0] bg1_dout;
wire        bg1_dout_en;
wire  [9:0] bg1_t_dout;
wire  [9:0] bg1_r_yoffset;
wire  [9:0] bg1_r_xoffset;
wire  [1:0] bg1_r_bank;
wire [31:0] bg2_dout;
wire        bg2_dout_en;
wire  [9:0] bg2_t_dout;
wire  [9:0] bg2_r_yoffset;
wire  [9:0] bg2_r_xoffset;
wire  [1:0] bg2_r_bank;
wire [31:0] bg3_dout;
wire        bg3_dout_en;
wire  [9:0] bg3_t_dout;
wire  [9:0] bg3_r_yoffset;
wire  [9:0] bg3_r_xoffset;
wire  [1:0] bg3_r_bank;

cv_csmem_bg # (
  .TILE_ADDR (`BG_TILE0_ADDR),
  .REG_ADDR  (`BG_REG0_ADDR)) bg0 (
  .clk          (clk),
  .reset        (reset),
  .ps_c_clk     (ps_c_clk),
  .ps_c_addr    (ps_c_addr),
  .ps_c_din     (ps_c_din),
  .ps_c_we      (ps_c_we),
  .ps_c_en      (ps_c_en),
  .ps_c_dout    (bg0_dout),
  .ps_c_dout_en (bg0_dout_en),

  .t_addr       (t_addr),
  .t_ren        (t_ren & (bg_screen == 2'b00)),
  .t_dout       (bg0_t_dout),

  .r_yoffset    (bg0_r_yoffset),
  .r_xoffset    (bg0_r_xoffset),
  .r_bank       (bg0_r_bank)
);

cv_csmem_bg # (
  .TILE_ADDR (`BG_TILE1_ADDR),
  .REG_ADDR  (`BG_REG1_ADDR)) bg1 (
  .clk          (clk),
  .reset        (reset),
  .ps_c_clk     (ps_c_clk),
  .ps_c_addr    (ps_c_addr),
  .ps_c_din     (ps_c_din),
  .ps_c_we      (ps_c_we),
  .ps_c_en      (ps_c_en),
  .ps_c_dout    (bg1_dout),
  .ps_c_dout_en (bg1_dout_en),

  .t_addr       (t_addr),
  .t_ren        (t_ren & (bg_screen == 2'b01)),
  .t_dout       (bg1_t_dout),

  .r_yoffset    (bg1_r_yoffset),
  .r_xoffset    (bg1_r_xoffset),
  .r_bank       (bg1_r_bank)
);

cv_csmem_bg # (
  .TILE_ADDR (`BG_TILE2_ADDR),
  .REG_ADDR  (`BG_REG2_ADDR)) bg2 (
  .clk          (clk),
  .reset        (reset),
  .ps_c_clk     (ps_c_clk),
  .ps_c_addr    (ps_c_addr),
  .ps_c_din     (ps_c_din),
  .ps_c_we      (ps_c_we),
  .ps_c_en      (ps_c_en),
  .ps_c_dout    (bg2_dout),
  .ps_c_dout_en (bg2_dout_en),

  .t_addr       (t_addr),
  .t_ren        (t_ren & (bg_screen == 2'b10)),
  .t_dout       (bg2_t_dout),

  .r_yoffset    (bg2_r_yoffset),
  .r_xoffset    (bg2_r_xoffset),
  .r_bank       (bg2_r_bank)
);

cv_csmem_bg # (
  .TILE_ADDR (`BG_TILE3_ADDR),
  .REG_ADDR  (`BG_REG3_ADDR)) bg3 (
  .clk          (clk),
  .reset        (reset),
  .ps_c_clk     (ps_c_clk),
  .ps_c_addr    (ps_c_addr),
  .ps_c_din     (ps_c_din),
  .ps_c_we      (ps_c_we),
  .ps_c_en      (ps_c_en),
  .ps_c_dout    (bg3_dout),
  .ps_c_dout_en (bg3_dout_en),

  .t_addr       (t_addr),
  .t_ren        (t_ren & (bg_screen == 2'b11)),
  .t_dout       (bg3_t_dout),

  .r_yoffset    (bg3_r_yoffset),
  .r_xoffset    (bg3_r_xoffset),
  .r_bank       (bg3_r_bank)
);

assign t_dout = (bg_screen == 2'b00 ? bg0_t_dout :
       	      	 bg_screen == 2'b01 ? bg1_t_dout :
       	      	 bg_screen == 2'b10 ? bg2_t_dout : bg3_t_dout);

assign r_bg_yoffset = (bg_screen == 2'b00 ? bg0_r_yoffset :
       		       bg_screen == 2'b01 ? bg1_r_yoffset :
		       bg_screen == 2'b10 ? bg2_r_yoffset : bg3_r_yoffset);

assign r_bg_xoffset = (bg_screen == 2'b00 ? bg0_r_xoffset :
       		       bg_screen == 2'b01 ? bg1_r_xoffset :
       		       bg_screen == 2'b10 ? bg2_r_xoffset : bg3_r_xoffset);

assign r_bg_bank = (bg_screen == 2'b00 ? bg0_r_bank :
       		    bg_screen == 2'b01 ? bg1_r_bank :
       		    bg_screen == 2'b10 ? bg2_r_bank : bg3_r_bank);

////////////////////////////////////////
//// chip-wide control registers
wire [31:0] cwreg_dout;
wire        cwreg_dout_en;

cv_csmem_cwreg # (
  .ADDR_MSB(`BG_CW_REG_ADDR >> 12)) cwreg0 (
  .reset        (reset),

  .ps_c_clk     (ps_c_clk),
  .ps_c_addr    (ps_c_addr),
  .ps_c_din     (ps_c_din),
  .ps_c_we      (ps_c_we),
  .ps_c_en      (ps_c_en),
  .ps_c_dout    (cwreg_dout),
  .ps_c_dout_en (cwreg_dout_en),

  .r_virq         (r_virq),
  .rend_order_sel (rend_order_sel),
  .r_rend_order   (r_rend_order),
  .r_sp_count     (r_sp_count)
);

assign ps_c_dout = (cmem0_en_reg   == 1'b1 ? cmem0_dout :
       		    cmem1_en_reg   == 1'b1 ? cmem1_dout :
		    bg0_dout_en    == 1'b1 ? bg0_dout :
		    bg1_dout_en    == 1'b1 ? bg1_dout :
		    cwreg_dout_en  == 1'b1 ? cwreg_dout : 32'b0);

////////////////////////////////////////////////////////////
////
//// sprite char memory
////
wire        smem0_en = (ps_s_addr[18:17] == (`SP_CHAR_ADDR >> 17) && ps_s_addr[2] == 1'b0);
wire        smem1_en = (ps_s_addr[18:17] == (`SP_CHAR_ADDR >> 17) && ps_s_addr[2] == 1'b1);
reg         smem0_en_reg;
reg         smem1_en_reg;
wire [31:0] smem0_dout;
wire [31:0] smem1_dout;

cv_tdpram_rf_be # (
  .A_WIDTH (14)) smem0 (
  // port0
  .clk0    (ps_s_clk),
  .addr0   (ps_s_addr[16:3]),
  .en0     (smem0_en ? ps_s_en : 1'b0),
  .we0     (smem0_en ? ps_s_we : 4'b0),
  .wrdata0 (ps_s_din),
  .rddata0 (smem0_dout),

  // port1
  .clk1    (clk),
  .addr1   (s_addr),
  .we1     (4'b0),
  .en1     (s_ren),
  .wrdata1 (32'b0),
  .rddata1 (s_dout[31:0])
);

cv_tdpram_rf_be # (
  .A_WIDTH (14)) smem1 (
  // port0
  .clk0    (ps_s_clk),
  .addr0   (ps_s_addr[16:3]),
  .en0     (smem1_en ? ps_s_en : 1'b0),
  .we0     (smem1_en ? ps_s_we : 4'b0),
  .wrdata0 (ps_s_din),
  .rddata0 (smem1_dout),

  // port1
  .clk1    (clk),
  .addr1   (s_addr),
  .we1     (4'b0),
  .en1     (s_ren),
  .wrdata1 (32'b0),
  .rddata1 (s_dout[63:32])
);

always @ (posedge ps_s_clk)
begin
  smem0_en_reg <= smem0_en;
  smem1_en_reg <= smem1_en;
end

////////////////////////////////////////
////
//// sprite control memory
////
wire        pmem0_en = (ps_s_addr[18:13] == (`SP_CTRL_ADDR >> 13) && ps_s_addr[2] == 1'b0);
wire        pmem1_en = (ps_s_addr[18:13] == (`SP_CTRL_ADDR >> 13) && ps_s_addr[2] == 1'b1);
reg         pmem0_en_reg;
reg         pmem1_en_reg;
wire [31:0] pmem0_dout;
wire [31:0] pmem1_dout;

cv_tdpram_rf_be # (
  .A_WIDTH (10)) pmem0 (
  // port0
  .clk0    (ps_s_clk),
  .addr0   (ps_s_addr[12:3]),
  .en0     (pmem0_en ? ps_s_en : 1'b0),
  .we0     (pmem0_en ? ps_s_we : 4'b0),
  .wrdata0 (ps_s_din),
  .rddata0 (pmem0_dout),

  // port1
  .clk1    (clk),
  .addr1   (p_addr),
  .we1     (4'b0),
  .en1     (p_ren),
  .wrdata1 (32'b0),
  .rddata1 (p_dout[31:0])
);

cv_tdpram_rf_be # (
  .A_WIDTH (10)) pmem1 (
  // port0
  .clk0    (ps_s_clk),
  .addr0   (ps_s_addr[12:3]),
  .en0     (pmem1_en ? ps_s_en : 1'b0),
  .we0     (pmem1_en ? ps_s_we : 4'b0),
  .wrdata0 (ps_s_din),
  .rddata0 (pmem1_dout),

  // port1
  .clk1    (clk),
  .addr1   (p_addr),
  .we1     (4'b0),
  .en1     (p_ren),
  .wrdata1 (32'b0),
  .rddata1 (p_dout[63:32])
);

always @ (posedge ps_s_clk)
begin
  pmem0_en_reg <= pmem0_en;
  pmem1_en_reg <= pmem1_en;
end

assign ps_s_dout = (smem0_en_reg == 1'b1 ? smem0_dout :
       		    smem1_en_reg == 1'b1 ? smem1_dout :
       		    pmem0_en_reg == 1'b1 ? pmem0_dout :
       		    pmem1_en_reg == 1'b1 ? pmem1_dout : 32'b0);

endmodule

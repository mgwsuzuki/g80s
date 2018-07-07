// -*- text -*-
`timescale 1 ps / 1 ps

module cv_g80sfpga (
  inout [14:0] DDR_addr,
  inout  [2:0] DDR_ba,
  inout        DDR_cas_n,
  inout        DDR_ck_n,
  inout        DDR_ck_p,
  inout        DDR_cke,
  inout        DDR_cs_n,
  inout  [3:0] DDR_dm,
  inout [31:0] DDR_dq,
  inout  [3:0] DDR_dqs_n,
  inout  [3:0] DDR_dqs_p,
  inout        DDR_odt,
  inout        DDR_ras_n,
  inout        DDR_reset_n,
  inout        DDR_we_n,
  inout        FIXED_IO_ddr_vrn,
  inout        FIXED_IO_ddr_vrp,
  inout [53:0] FIXED_IO_mio,
  inout        FIXED_IO_ps_clk,
  inout        FIXED_IO_ps_porb,
  inout        FIXED_IO_ps_srstb,

  input        reset,
  input  [2:0] btn,
  input  [1:0] sw,
  output       seri_r_p,
  output       seri_r_n,
  output       seri_g_p,
  output       seri_g_n,
  output       seri_b_p,
  output       seri_b_n,
  output       seri_clk_p,
  output       seri_clk_n,
  output [3:0] led
);

////////////////////////////////////////
wire       sclk;
wire       pclk;
wire       pclk5x;
wire       resetn;
wire       oserdes_reset;
wire       irq;
wire [9:0] hdmi_r;
wire [9:0] hdmi_g;
wire [9:0] hdmi_b;
wire       seri_r;
wire       seri_g;
wire       seri_b;
wire       seri_clk;

wire [18:0] ps_c_addr;
wire        ps_c_clk;
wire [31:0] ps_c_din;
wire [31:0] ps_c_dout;
wire        ps_c_en;
wire  [3:0] ps_c_we;

wire [18:0] ps_s_addr;
wire        ps_s_clk;
wire [31:0] ps_s_din;
wire [31:0] ps_s_dout;
wire        ps_s_en;
wire  [3:0] ps_s_we;

wire  [2:0] ledout;

////////////////////////////////////////
  design_1 ps0 (
    .bramif_c_addr       (ps_c_addr),
    .bramif_c_clk        (ps_c_clk),
    .bramif_c_din        (ps_c_din),		// write data (output)
    .bramif_c_dout       (ps_c_dout),		// read data (input)
    .bramif_c_en         (ps_c_en),		// read/write enable
    .bramif_c_rst        (),			// active-H reset, ignore
    .bramif_c_we         (ps_c_we),		// byte write enable

    .bramif_s_addr       (ps_s_addr),
    .bramif_s_clk        (ps_s_clk),
    .bramif_s_din        (ps_s_din),		// write data (output)
    .bramif_s_dout       (ps_s_dout),		// read data (input)
    .bramif_s_en         (ps_s_en),		// read/write enable
    .bramif_s_rst        (),			// active-H reset, ignore
    .bramif_s_we         (ps_s_we),		// byte write enable

    .DDR_addr          (DDR_addr),
    .DDR_ba            (DDR_ba),
    .DDR_cas_n         (DDR_cas_n),
    .DDR_ck_n          (DDR_ck_n),
    .DDR_ck_p          (DDR_ck_p),
    .DDR_cke           (DDR_cke),
    .DDR_cs_n          (DDR_cs_n),
    .DDR_dm            (DDR_dm),
    .DDR_dq            (DDR_dq),
    .DDR_dqs_n         (DDR_dqs_n),
    .DDR_dqs_p         (DDR_dqs_p),
    .DDR_odt           (DDR_odt),
    .DDR_ras_n         (DDR_ras_n),
    .DDR_reset_n       (DDR_reset_n),
    .DDR_we_n          (DDR_we_n),
    .FIXED_IO_ddr_vrn  (FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp  (FIXED_IO_ddr_vrp),
    .FIXED_IO_mio      (FIXED_IO_mio),
    .FIXED_IO_ps_clk   (FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb  (FIXED_IO_ps_porb),
    .FIXED_IO_ps_srstb (FIXED_IO_ps_srstb),
    .btn_resetn        (resetn),
    .irq               (irq),
    .sclk              (sclk),
    .pclk              (pclk),
    .pclk5x            (pclk5x));

assign resetn = ~reset;

cv_g80s c0 (
  .clk           (sclk),
  .reset         (reset),
  .oserdes_reset (oserdes_reset),
  .btn           (btn),
  .sw            (sw),

  .hdmi_r (hdmi_r),
  .hdmi_g (hdmi_g),
  .hdmi_b (hdmi_b),

  .ps_c_clk  (ps_c_clk),
  .ps_c_addr (ps_c_addr),
  .ps_c_din  (ps_c_din),
  .ps_c_we   (ps_c_we),
  .ps_c_en   (ps_c_en),
  .ps_c_dout (ps_c_dout),

  .ps_s_clk  (ps_s_clk),
  .ps_s_addr (ps_s_addr),
  .ps_s_din  (ps_s_din),
  .ps_s_we   (ps_s_we),
  .ps_s_en   (ps_s_en),
  .ps_s_dout (ps_s_dout),

  .irq     (irq),
  .led     (ledout)
);

oserdese2_10b sr0 (
  .clk    (pclk5x),
  .clkdiv (pclk),
  .reset  (oserdes_reset),
  .din    (hdmi_r),
  .dout   (seri_r)
);

oserdese2_10b sg0 (
  .clk    (pclk5x),
  .clkdiv (pclk),
  .reset  (oserdes_reset),
  .din    (hdmi_b),
  .dout   (seri_b)
);

oserdese2_10b sb0 (
  .clk    (pclk5x),
  .clkdiv (pclk),
  .reset  (oserdes_reset),
  .din    (hdmi_g),
  .dout   (seri_g)
);

oserdese2_10b sc0 (
  .clk    (pclk5x),
  .clkdiv (pclk),
  .reset  (oserdes_reset),
  .din    (10'b00000_11111),
  .dout   (seri_clk)
);

OBUFDS #(
  .IOSTANDARD ("TMDS_33")) obufr0 (
  .I  (seri_r),
  .O  (seri_r_p),
  .OB (seri_r_n));

OBUFDS #(
  .IOSTANDARD ("TMDS_33")) obufg0 (
  .I  (seri_g),
  .O  (seri_g_p),
  .OB (seri_g_n));

OBUFDS #(
  .IOSTANDARD ("TMDS_33")) obufb0 (
  .I  (seri_b),
  .O  (seri_b_p),
  .OB (seri_b_n));

OBUFDS #(
  .IOSTANDARD ("TMDS_33")) obufc0 (
  .I  (seri_clk),
  .O  (seri_clk_p),
  .OB (seri_clk_n));

////////////////////////////////////////
// hb
cv_hb # (
  .CLKFREQ(120000000)) hb0 (
  .clk   (sclk),
  .reset (reset),
  .hbout (led[0])
);
/*
cv_hb # (
  .CLKFREQ(325000000)) hb1 (
  .clk   (clk5x),
  .reset (reset),
  .hbout (led1)
);
*/
assign led[3:1] = ledout;

endmodule


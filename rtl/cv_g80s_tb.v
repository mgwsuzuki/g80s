// -*- text -*-
`timescale 1ns/1ps

module cv_g80s_tb;

reg        clk;
reg        reset;
wire       oserdes_reset;

wire [9:0] hdmi_r;
wire [9:0] hdmi_g;
wire [9:0] hdmi_b;

wire        ps_c_clk;
reg  [18:0] ps_c_addr;
reg  [31:0] ps_c_din;
reg   [3:0] ps_c_we;
reg         ps_c_en;
wire [31:0] ps_c_dout;

wire        ps_s_clk;
reg  [18:0] ps_s_addr;
reg  [31:0] ps_s_din;
reg   [3:0] ps_s_we;
reg         ps_s_en;
wire [31:0] ps_s_dout;

wire        irq;
wire  [2:0] led;

parameter STEP = 100;
parameter DLY = 1;

//parameter [80*8:1] bus_vecname = "g80s_testvec0.txt";
parameter [80*8:1] bus_vecname = "testvec/g80s_bg_testvec0.txt";
// Sprite test
//parameter [80*8:1] bus_vecname = "testvec/g80s_sp_testvec0.txt";
//parameter [80*8:1] bus_vecname = "testvec/g80s_sp_testvec1.txt";

integer m;
parameter bus_vlen = 10000;
reg  [127:0] bus_pattern[0:bus_vlen-1], bus_pat;
reg    [7:0] bus_wait_reg;

////////////////////////////////////////
cv_g80s c0 (
  .clk           (clk),
  .reset         (reset),
  .oserdes_reset (oserdes_reset),
  .btn           (3'b0),
  .sw            (2'b0),

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
  .led     (led)
);

defparam  c0.tmg0.H_PRE    = 2;
defparam  c0.tmg0.H_ACTIVE = 127;
defparam  c0.tmg0.H_FRONT  = 7;
defparam  c0.tmg0.H_SYNC   = 19;
defparam  c0.tmg0.H_BACK   = 27;
defparam  c0.tmg0.V_ACTIVE = 47;
defparam  c0.tmg0.V_FRONT  = 3;
defparam  c0.tmg0.V_SYNC   = 7;
defparam  c0.tmg0.V_BACK   = 3;

////////////////////////////////////////
always
begin
  clk = 1'b0; #(STEP/2);
  clk = 1'b1; #(STEP/2);
end

assign ps_c_clk = clk;
assign ps_s_clk = clk;

initial
begin
  reset = 1'b1; #(STEP*2);
  forever begin
    reset = 1'b0; #(STEP * 10000000);
  end
end

////////////////////////////////////////
initial
begin
  #(STEP/2 + DLY);

  $readmemh(bus_vecname, bus_pattern);
  for (m = 0; m < bus_vlen; m = m + 1) begin
    bus_pat = bus_pattern[m];
    ps_c_addr    = bus_pat[126:108];
    ps_c_en      = bus_pat[104];
    ps_c_we      = bus_pat[103:100];
    ps_c_din     = bus_pat[99:68];
    ps_s_addr    = bus_pat[67:48];
    ps_s_en      = bus_pat[44];
    ps_s_we      = bus_pat[43:40];
    ps_s_din     = bus_pat[39:8];
    bus_wait_reg = bus_pat[7:0];
    while (bus_wait_reg != 8'b0) begin
      #STEP;
      bus_wait_reg = bus_wait_reg - 8'b1;
    end
  end
end

/*
initial
begin
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP*8 + STEP/2 + 1);
// memory access test
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b1111, 32'h0403_0201}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00004, 1'b1, 4'b1111, 32'h0807_0605}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00008, 1'b1, 4'b1111, 32'h0c0d_0a09}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0000c, 1'b1, 4'b1111, 32'h100f_0e0d}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00004, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00008, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0000c, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b0001, 32'h0000_00ef}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b0010, 32'h0000_be00}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b0100, 32'h00ad_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b1000, 32'hde00_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20000, 1'b1, 4'b1111, 32'haabb_ccdd}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20004, 1'b1, 4'b1111, 32'h1111_3333}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20000, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20004, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
// SpritePosMem
//{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20000, 1'b0, 4'b1111, 32'h0001_0002}; #(STEP);  // sprite0
//{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20004, 1'b0, 4'b1111, 32'h0000_0000}; #(STEP);
//{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20008, 1'b0, 4'b1111, 32'hfffd_ffff}; #(STEP);  // sprite1
//{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h2000c, 1'b0, 4'b1111, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20000, 1'b0, 4'b1111, 32'h0000_0000}; #(STEP);  // sprite0
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20004, 1'b0, 4'b1111, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h20008, 1'b0, 4'b1111, 32'h0009_001b}; #(STEP);  // sprite1
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h2000c, 1'b0, 4'b1111, 32'h0000_0001}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
// SpriteCharMem
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b1, 4'b1111, 32'h0001_8000}; #(STEP);  // char0 line0
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00004, 1'b1, 4'b1111, 32'h0003_0002}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00008, 1'b1, 4'b1111, 32'h0005_0004}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0000c, 1'b1, 4'b1111, 32'h0007_0006}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00010, 1'b1, 4'b1111, 32'h0099_0008}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00014, 1'b1, 4'b1111, 32'h000b_000a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00018, 1'b1, 4'b1111, 32'h000d_000c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0001c, 1'b1, 4'b1111, 32'h000f_000e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00200, 1'b1, 4'b1111, 32'h8011_0010}; #(STEP);  // line1
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00204, 1'b1, 4'b1111, 32'h0013_0012}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00208, 1'b1, 4'b1111, 32'h0015_0014}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0020c, 1'b1, 4'b1111, 32'h0017_0016}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00210, 1'b1, 4'b1111, 32'h0019_0018}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00214, 1'b1, 4'b1111, 32'h001b_001a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00218, 1'b1, 4'b1111, 32'h001d_001c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0021c, 1'b1, 4'b1111, 32'h001f_001e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00400, 1'b1, 4'b1111, 32'h0021_0020}; #(STEP);  // line2
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00404, 1'b1, 4'b1111, 32'h0023_0022}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00408, 1'b1, 4'b1111, 32'h0025_0024}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0040c, 1'b1, 4'b1111, 32'h0027_0026}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00410, 1'b1, 4'b1111, 32'h0029_0028}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00414, 1'b1, 4'b1111, 32'h002b_002a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00418, 1'b1, 4'b1111, 32'h002d_002c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0041c, 1'b1, 4'b1111, 32'h002f_002e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00600, 1'b1, 4'b1111, 32'h0031_0030}; #(STEP);  // line3
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00604, 1'b1, 4'b1111, 32'h0033_0032}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00608, 1'b1, 4'b1111, 32'h0035_0034}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0060c, 1'b1, 4'b1111, 32'h0037_0036}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00610, 1'b1, 4'b1111, 32'h0039_0038}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00614, 1'b1, 4'b1111, 32'h003b_003a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00618, 1'b1, 4'b1111, 32'h003d_003c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0061c, 1'b1, 4'b1111, 32'h003f_003e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00800, 1'b1, 4'b1111, 32'h0041_0040}; #(STEP);  // line4
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00804, 1'b1, 4'b1111, 32'h0043_0042}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00808, 1'b1, 4'b1111, 32'h0045_0044}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0080c, 1'b1, 4'b1111, 32'h0047_0046}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00810, 1'b1, 4'b1111, 32'h0049_0048}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00814, 1'b1, 4'b1111, 32'h004b_004a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00818, 1'b1, 4'b1111, 32'h004d_004c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0081c, 1'b1, 4'b1111, 32'h004f_004e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a00, 1'b1, 4'b1111, 32'h0051_0050}; #(STEP);  // line5
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a04, 1'b1, 4'b1111, 32'h0053_0052}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a08, 1'b1, 4'b1111, 32'h0055_0054}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a0c, 1'b1, 4'b1111, 32'h0057_0056}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a10, 1'b1, 4'b1111, 32'h0059_0058}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a14, 1'b1, 4'b1111, 32'h005b_005a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a18, 1'b1, 4'b1111, 32'h005d_005c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a1c, 1'b1, 4'b1111, 32'h005f_005e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00020, 1'b1, 4'b1111, 32'h0101_8100}; #(STEP);  // char1 line0
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00024, 1'b1, 4'b1111, 32'h0103_0102}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00028, 1'b1, 4'b1111, 32'h0105_0104}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0002c, 1'b1, 4'b1111, 32'h0107_0106}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00030, 1'b1, 4'b1111, 32'h0199_0108}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00034, 1'b1, 4'b1111, 32'h010b_010a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00038, 1'b1, 4'b1111, 32'h010d_010c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0003c, 1'b1, 4'b1111, 32'h010f_010e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00220, 1'b1, 4'b1111, 32'h8111_0110}; #(STEP);  // line1
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00224, 1'b1, 4'b1111, 32'h0113_0112}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00228, 1'b1, 4'b1111, 32'h0115_0114}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0022c, 1'b1, 4'b1111, 32'h0117_0116}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00230, 1'b1, 4'b1111, 32'h0119_0118}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00234, 1'b1, 4'b1111, 32'h011b_011a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00238, 1'b1, 4'b1111, 32'h011d_011c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0023c, 1'b1, 4'b1111, 32'h011f_011e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00420, 1'b1, 4'b1111, 32'h0121_0120}; #(STEP);  // line2
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00424, 1'b1, 4'b1111, 32'h0123_0122}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00428, 1'b1, 4'b1111, 32'h0125_0124}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0042c, 1'b1, 4'b1111, 32'h0127_0126}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00430, 1'b1, 4'b1111, 32'h0129_0128}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00434, 1'b1, 4'b1111, 32'h012b_012a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00438, 1'b1, 4'b1111, 32'h012d_012c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0043c, 1'b1, 4'b1111, 32'h012f_012e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00620, 1'b1, 4'b1111, 32'h0131_0130}; #(STEP);  // line3
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00624, 1'b1, 4'b1111, 32'h0133_0132}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00628, 1'b1, 4'b1111, 32'h0135_0134}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0062c, 1'b1, 4'b1111, 32'h0137_0136}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00630, 1'b1, 4'b1111, 32'h0139_0138}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00634, 1'b1, 4'b1111, 32'h013b_013a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00638, 1'b1, 4'b1111, 32'h013d_013c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0063c, 1'b1, 4'b1111, 32'h013f_013e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00820, 1'b1, 4'b1111, 32'h0141_0140}; #(STEP);  // line4
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00824, 1'b1, 4'b1111, 32'h0143_0142}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00828, 1'b1, 4'b1111, 32'h0145_0144}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0082c, 1'b1, 4'b1111, 32'h0147_0146}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00830, 1'b1, 4'b1111, 32'h0149_0148}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00834, 1'b1, 4'b1111, 32'h014b_014a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00838, 1'b1, 4'b1111, 32'h014d_014c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h0083c, 1'b1, 4'b1111, 32'h014f_014e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a20, 1'b1, 4'b1111, 32'h0151_0150}; #(STEP);  // line5
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a24, 1'b1, 4'b1111, 32'h0153_0152}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a28, 1'b1, 4'b1111, 32'h0155_0154}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a2c, 1'b1, 4'b1111, 32'h0157_0156}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a30, 1'b1, 4'b1111, 32'h0159_0158}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a34, 1'b1, 4'b1111, 32'h015b_015a}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a38, 1'b1, 4'b1111, 32'h015d_015c}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00a3c, 1'b1, 4'b1111, 32'h015f_015e}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_s_addr,ps_s_en,ps_s_we,ps_s_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
end

initial
begin
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP*8 + STEP/2 + 1);
// memory access test
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h40000, 1'b1, 4'b1111, 32'hffff_ffff}; #(STEP);
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h40004, 1'b1, 4'b1111, 32'h00ab_00cd}; #(STEP);
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h40000, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h40004, 1'b1, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h40000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h40000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h40000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
{ps_c_addr,ps_c_en,ps_c_we,ps_c_din} = {19'h00000, 1'b0, 4'b0000, 32'h0000_0000}; #(STEP);
end
*/

endmodule

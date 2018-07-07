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

wire        h_front;
wire        h_sync;
wire        h_back;
wire        h_active;
wire        h_en;
wire        h_end;
wire [10:0] h_count;
wire        v_front;
wire        v_sync;
wire        v_back;
wire        v_active;
wire        v_end;
wire  [9:0] v_count;
wire  [9:0] sp_v_count;
wire        sp_v_active;

reg   [5:0] h_en_reg;
reg   [5:0] v_sync_reg;
reg   [5:0] h_sync_reg;
reg   [5:0] v_active_reg;
reg   [5:0] h_active_reg;
reg   [9:0] v_count_reg;
reg  [10:0] h_count_reg;
reg  [10:0] h_count_reg1;	// temp

wire  [9:0] ctrl_encout_r;
wire  [9:0] ctrl_encout_g;
wire  [9:0] ctrl_encout_b;

wire        data_enc_en;
wire  [9:0] data_encout_r;
wire  [9:0] data_encout_g;
wire  [9:0] data_encout_b;

reg   [9:0] hdmi_r_reg;
reg   [9:0] hdmi_g_reg;
reg   [9:0] hdmi_b_reg;

reg  [2:0] reset_reg;

wire [13:0] c_addr;
wire        c_ren;
wire [63:0] c_dout;

wire [13:0] t_addr;
wire        t_ren;
wire  [9:0] t_dout;

wire [13:0] s_addr;
wire        s_ren;
wire [63:0] s_dout;

wire  [9:0] p_addr;
wire        p_ren;
wire [63:0] p_dout;

wire  [9:0] r_bg_yoffset;
wire  [9:0] r_bg_xoffset;
wire  [1:0] r_bg_bank;

wire  [1:0] r_virq;
wire  [2:0] rend_order_sel;
wire  [7:0] r_rend_order;
wire [15:0] r_sp_count;

wire  [9:0] l_rdaddr0;
wire  [9:0] l_rdaddr1;
wire  [9:0] l_rdaddr2;
wire  [9:0] l_rdaddr3;
wire        l_ren;
wire [63:0] l_rddata;
wire  [9:0] l_wraddr0;
wire  [9:0] l_wraddr1;
wire  [9:0] l_wraddr2;
wire  [9:0] l_wraddr3;
wire        l_wen0;
wire        l_wen1;
wire        l_wen2;
wire        l_wen3;
wire [63:0] l_wrdata;

wire  [9:0] bg_l_rdaddr0;
wire  [9:0] bg_l_rdaddr1;
wire  [9:0] bg_l_rdaddr2;
wire  [9:0] bg_l_rdaddr3;
wire        bg_l_ren;
wire  [9:0] bg_l_wraddr0;
wire  [9:0] bg_l_wraddr1;
wire  [9:0] bg_l_wraddr2;
wire  [9:0] bg_l_wraddr3;
wire        bg_l_wen0;
wire        bg_l_wen1;
wire        bg_l_wen2;
wire        bg_l_wen3;
wire [63:0] bg_l_wrdata;

wire        bg_render_end;

wire        sp_search_end;
wire        sp_render_end;
wire  [9:0] sp_l_rdaddr0;
wire  [9:0] sp_l_rdaddr1;
wire  [9:0] sp_l_rdaddr2;
wire  [9:0] sp_l_rdaddr3;
wire        sp_l_ren;
wire  [9:0] sp_l_wraddr0;
wire  [9:0] sp_l_wraddr1;
wire  [9:0] sp_l_wraddr2;
wire  [9:0] sp_l_wraddr3;
wire        sp_l_wen0;
wire        sp_l_wen1;
wire        sp_l_wen2;
wire        sp_l_wen3;
wire [63:0] sp_l_wrdata;

wire        rdc_bg_cs;
wire  [1:0] rdc_bg_screen;

wire        rdc_sp_cs;

wire  [9:0] pix_rdaddr;
wire        pix_ren;
wire [63:0] pix_rddata;

////////////////////////////////////////
cv_csmem csmem0 (
  .clk       (clk),
  .reset     (reset),

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

  .c_addr    (c_addr),
  .c_ren     (c_ren),
  .c_dout    (c_dout),

  .bg_screen (rdc_bg_screen),
  .t_addr    (t_addr),
  .t_ren     (t_ren),
  .t_dout    (t_dout),

  .s_addr    (s_addr),
  .s_ren     (s_ren),
  .s_dout    (s_dout),

  .p_addr    (p_addr),
  .p_ren     (p_ren),
  .p_dout    (p_dout),

  .r_bg_yoffset   (r_bg_yoffset),
  .r_bg_xoffset   (r_bg_xoffset),
  .r_bg_bank      (r_bg_bank),
  .r_virq         (r_virq),
  .rend_order_sel (rend_order_sel),
  .r_rend_order   (r_rend_order),
  .r_sp_count     (r_sp_count)
);

////////////////////////////////////////
cv_timing # (
  .H_PRE(2)) tmg0 (
  .clk        (clk),
  .reset      (reset),
  .cs         (1'b1),
  .h_front    (h_front),
  .h_sync     (h_sync),
  .h_back     (h_back),
  .h_preamble (),
  .h_guard    (),
  .h_active   (h_active),
  .h_en       (h_en),
  .h_end      (h_end),
  .h_count    (h_count),
  .v_front    (v_front),
  .v_sync     (v_sync),
  .v_back     (v_back),
  .v_active   (v_active),
  .v_end      (v_end),
  .v_count    (v_count),
  .sp_v_count (sp_v_count),
  .sp_v_active(sp_v_active)
);

////////////////////////////////////////
cv_rdctrl rdc0 (
  .clk   (clk),
  .reset (reset),

  .cs             (sp_v_active & ~h_end),
  .rend_order_sel (rend_order_sel),
  .r_rend_order   (r_rend_order),
  .bg_cs          (rdc_bg_cs),
  .bg_screen      (rdc_bg_screen),
  .bg_render_end  (bg_render_end),
  .sp_cs          (rdc_sp_cs),
  .sp_search_end  (sp_search_end),
  .sp_render_end  (sp_render_end)
);

////////////////////////////////////////
cv_bgrender bgr0 (
  .clk        (clk),
  .reset      (reset),

  .cs         (rdc_bg_cs),
  .v_count    (sp_v_count),
  .l_bank     (r_bg_bank),
  .r_yoffset  (r_bg_yoffset),
  .r_xoffset  (r_bg_xoffset),
  .render_end (bg_render_end),

  .c_rdaddr   (c_addr),
  .c_ren      (c_ren),
  .c_rddata   (c_dout),

  .t_rdaddr  (t_addr),
  .t_ren     (t_ren),
  .t_rddata  (t_dout),

  .l_rdaddr0 (bg_l_rdaddr0),
  .l_rdaddr1 (bg_l_rdaddr1),
  .l_rdaddr2 (bg_l_rdaddr2),
  .l_rdaddr3 (bg_l_rdaddr3),
  .l_ren     (bg_l_ren),
  .l_rddata  (l_rddata),
  .l_wraddr0 (bg_l_wraddr0),
  .l_wraddr1 (bg_l_wraddr1),
  .l_wraddr2 (bg_l_wraddr2),
  .l_wraddr3 (bg_l_wraddr3),
  .l_wen0    (bg_l_wen0),
  .l_wen1    (bg_l_wen1),
  .l_wen2    (bg_l_wen2),
  .l_wen3    (bg_l_wen3),
  .l_wrdata  (bg_l_wrdata)
);

////////////////////////////////////////
cv_sp sp0 (
  .clk          (clk),
  .reset        (reset),

  .cs           (sp_v_active & ~h_end),
  .v_count      (sp_v_count),
  .sprite_count (r_sp_count[9:0]),
  .search_end   (sp_search_end),
  .cs_render    (rdc_sp_cs),
  .render_end   (sp_render_end),

  .s_addr       (s_addr),
  .s_ren        (s_ren),
  .s_din        (s_dout),

  .p_addr       (p_addr),
  .p_ren        (p_ren),
  .p_din        (p_dout),

  .l_rdaddr0 (sp_l_rdaddr0),
  .l_rdaddr1 (sp_l_rdaddr1),
  .l_rdaddr2 (sp_l_rdaddr2),
  .l_rdaddr3 (sp_l_rdaddr3),
  .l_ren     (sp_l_ren),
  .l_rddata  (l_rddata),
  .l_wraddr0 (sp_l_wraddr0),
  .l_wraddr1 (sp_l_wraddr1),
  .l_wraddr2 (sp_l_wraddr2),
  .l_wraddr3 (sp_l_wraddr3),
  .l_wen0    (sp_l_wen0),
  .l_wen1    (sp_l_wen1),
  .l_wen2    (sp_l_wen2),
  .l_wen3    (sp_l_wen3),
  .l_wrdata  (sp_l_wrdata)
);

////////////////////////////////////////
cv_linebuf lbuf0 (
  .clk (clk),
  .reset (reset),

  .sp_rdaddr0      (l_rdaddr0),
  .sp_rdaddr1      (l_rdaddr1),
  .sp_rdaddr2      (l_rdaddr2),
  .sp_rdaddr3      (l_rdaddr3),
  .sp_ren          (l_ren),
  .sp_rddata       (l_rddata),
  .sp_wraddr0      (l_wraddr0),
  .sp_wraddr1      (l_wraddr1),
  .sp_wraddr2      (l_wraddr2),
  .sp_wraddr3      (l_wraddr3),
  .sp_wen0         (l_wen0),
  .sp_wen1         (l_wen1),
  .sp_wen2         (l_wen2),
  .sp_wen3         (l_wen3),
  .sp_wrdata       (l_wrdata),
  .sp_v_count_lsb  (sp_v_count[0]),
  .pix_rdaddr      (pix_rdaddr),
  .pix_ren         (pix_ren),
  .pixdata         (pix_rddata)
);

assign l_rdaddr0 = (rdc_bg_cs == 1'b1 ? bg_l_rdaddr0 : sp_l_rdaddr0);
assign l_rdaddr1 = (rdc_bg_cs == 1'b1 ? bg_l_rdaddr1 : sp_l_rdaddr1);
assign l_rdaddr2 = (rdc_bg_cs == 1'b1 ? bg_l_rdaddr2 : sp_l_rdaddr2);
assign l_rdaddr3 = (rdc_bg_cs == 1'b1 ? bg_l_rdaddr3 : sp_l_rdaddr3);
assign l_ren     = (rdc_bg_cs == 1'b1 ? bg_l_ren     : sp_l_ren);
assign l_wraddr0 = (rdc_bg_cs == 1'b1 ? bg_l_wraddr0 : sp_l_wraddr0);
assign l_wraddr1 = (rdc_bg_cs == 1'b1 ? bg_l_wraddr1 : sp_l_wraddr1);
assign l_wraddr2 = (rdc_bg_cs == 1'b1 ? bg_l_wraddr2 : sp_l_wraddr2);
assign l_wraddr3 = (rdc_bg_cs == 1'b1 ? bg_l_wraddr3 : sp_l_wraddr3);
assign l_wen0    = (rdc_bg_cs == 1'b1 ? bg_l_wen0    : sp_l_wen0);
assign l_wen1    = (rdc_bg_cs == 1'b1 ? bg_l_wen1    : sp_l_wen1);
assign l_wen2    = (rdc_bg_cs == 1'b1 ? bg_l_wen2    : sp_l_wen2);
assign l_wen3    = (rdc_bg_cs == 1'b1 ? bg_l_wen3    : sp_l_wen3);
assign l_wrdata  = (rdc_bg_cs == 1'b1 ? bg_l_wrdata  : sp_l_wrdata);

////////////////////////////////////////
cv_lb2hdmi l2h0 (
  .clk      (clk),
  .reset    (reset),

  .h_en     (h_en),
  .h_sync   (h_sync),
  .h_active (h_active),
  .h_count  (h_count[9:0]),
  .v_sync   (v_sync),
  .v_active (v_active),

  .l_rdaddr (pix_rdaddr),
  .l_ren    (pix_ren),
  .l_rddata (pix_rddata),

  .hdmi_r   (hdmi_r),
  .hdmi_g   (hdmi_g),
  .hdmi_b   (hdmi_b)
);

////////////////////////////////////////
cv_irq irq0 (
  .clk       (clk),
  .reset     (reset),

  .v_end     (v_end),
  .r_virq    (r_virq),
  .irq       (irq));

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    reset_reg <= 3'b111;
  else
    reset_reg <= {reset_reg[1:0], 1'b0};
end

assign oserdes_reset = reset_reg[2];

assign led = 3'b000;

endmodule

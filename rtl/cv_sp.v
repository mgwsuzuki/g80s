// -*- text -*-
`timescale 1 ns / 1 ps

module cv_sp (
  input         clk,
  input         reset,

  input         cs,
  input   [9:0] v_count,
  input   [9:0] sprite_count,
  output        search_end,
  input         cs_render,
  output        render_end,

  output [13:0] s_addr,
  output        s_ren,
  input  [63:0] s_din,

  output  [9:0] p_addr,
  output        p_ren,
  input  [63:0] p_din,

  output  [9:0] l_rdaddr0,
  output  [9:0] l_rdaddr1,
  output  [9:0] l_rdaddr2,
  output  [9:0] l_rdaddr3,
  output        l_ren,
  input  [63:0] l_rddata,
  output  [9:0] l_wraddr0,
  output  [9:0] l_wraddr1,
  output  [9:0] l_wraddr2,
  output  [9:0] l_wraddr3,
  output        l_wen0,
  output        l_wen1,
  output        l_wen2,
  output        l_wen3,
  output [63:0] l_wrdata);

wire [10:0] search_count;

wire  [9:0] sch_p_addr;
wire        sch_p_ren;
wire  [9:0] sch_waddr;
wire        sch_wen;
wire  [9:0] sch_wrdata;

wire  [9:0] sch_raddr;
wire        sch_ren;
wire  [9:0] sch_rddata;

wire  [9:0] rend_p_addr;
wire        rend_p_ren;

////////////////////////////////////////

cv_sp_search sch0 (
  .clk          (clk),
  .reset        (reset),

  .cs           (cs),
  .v_count      (v_count),
  .sprite_count (sprite_count),
  .search_end   (search_end),
  .search_count (search_count),

  .p_addr       (sch_p_addr),
  .p_ren        (sch_p_ren),
  .p_din        (p_din),

  .sch_addr     (sch_waddr),
  .sch_wen      (sch_wen),
  .sch_wrdata   (sch_wrdata)
);

////
//// search memory
////
cv_tdpram_rf # (
  .D_WIDTH (10),
  .A_WIDTH (10)) mem0 (
  // port0
  .clk0    (clk),
  .addr0   (sch_waddr),
  .wen0    (sch_wen),
  .ren0    (1'b0),
  .wrdata0 (sch_wrdata),
  .rddata0 (),

  // port1
  .clk1    (clk),
  .addr1   (sch_raddr),
  .wen1    (1'b0),
  .ren1    (sch_ren),
  .wrdata1 (10'b0),
  .rddata1 (sch_rddata)
);

////////////////////////////////////////

cv_sp_render rend0 (
  .clk   (clk),
  .reset (reset),

  .cs           (cs_render),
  .v_count      (v_count),
  .search_count (search_count),
  .render_end   (render_end),

  .sch_raddr  (sch_raddr),
  .sch_ren    (sch_ren),
  .sch_rddata (sch_rddata),

  .s_addr    (s_addr),
  .s_ren     (s_ren),
  .s_data    (s_din),

  .p_addr    (rend_p_addr),
  .p_ren     (rend_p_ren),
  .p_data    (p_din),

  .l_rdaddr0 (l_rdaddr0),
  .l_rdaddr1 (l_rdaddr1),
  .l_rdaddr2 (l_rdaddr2),
  .l_rdaddr3 (l_rdaddr3),
  .l_ren     (l_ren),
  .l_rddata  (l_rddata),
  .l_wraddr0 (l_wraddr0),
  .l_wraddr1 (l_wraddr1),
  .l_wraddr2 (l_wraddr2),
  .l_wraddr3 (l_wraddr3),
  .l_wen0    (l_wen0),
  .l_wen1    (l_wen1),
  .l_wen2    (l_wen2),
  .l_wen3    (l_wen3),
  .l_wrdata  (l_wrdata)
);

////
//// p_addr, p_ren arbiter
////
assign p_addr = (cs_render == 1'b1 ? rend_p_addr : sch_p_addr);
assign p_ren  = (cs_render == 1'b1 ? rend_p_ren  : sch_p_ren);

endmodule

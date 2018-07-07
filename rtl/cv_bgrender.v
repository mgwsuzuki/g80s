// -*- text -*-
`timescale 1 ns / 1 ps

module cv_bgrender (
  input         clk,
  input         reset,

  input         cs,
  input   [9:0] v_count,
  input   [1:0] l_bank,
  input   [9:0] r_yoffset,
  input   [9:0] r_xoffset,
  output        render_end,

  output [13:0] c_rdaddr,
  output        c_ren,
  input  [63:0] c_rddata,

  output [13:0] t_rdaddr,
  output        t_ren,
  input   [9:0] t_rddata,

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

reg   [1:0] st_reg;

reg   [7:0] h_count_reg;
wire        l_cry;

reg   [2:0] l_ctrl_reg;

reg         h_count_reg0;
reg   [7:0] l_rdaddr0_reg;
reg   [7:0] l_rdaddr1_reg;
reg   [7:0] l_rdaddr2_reg;
reg   [7:0] l_rdaddr3_reg;
reg         t_ren_reg;
reg   [1:0] xoffset_reg0;

reg   [9:0] l_wraddr0_reg;
reg   [9:0] l_wraddr1_reg;
reg   [9:0] l_wraddr2_reg;
reg   [9:0] l_wraddr3_reg;
reg         l_wen0_reg;
reg         l_wen1_reg;
reg         l_wen2_reg;
reg         l_wen3_reg;
reg   [1:0] xoffset_reg1;

wire  [9:0] v_count_a = v_count + r_yoffset;

////////////////////////////////////////
//
//             |      tmem cmem h
// state cs cry|state  ren  ren count
//  --    0  - | 00     0    0   11
//  00    1  - | 10     1    0   00   # start, tmem read
//  01    1  - | 10     1    0   00   # tmem read
//  10    1  0 | 01     1    1   01   # cmem read
//  10    1  1 | 11     1    1   01   # cmem read, end
//  11    1  - | 11     0    0   00


// h_count: -0:nop, 01:inc, 11:clear
//
// l_ctrl: --0:nop, 001:inc, 101:2nd init, 111:1st init(clear)
//
//          is     |      mem h     l
// state cs sft cry|state ren count ctrl
//   --  0   -   - |  00   0   11   111
//   00  1   0   - |  01   1   01   001
//   00  1   1   - |  01   1   01   101
//#without shift
//   01  1   -   0 |  01   1   01   001
//   01  1   -   1 |  11   1   11   001
//#end
//   11  1   -   - |  11   0   00   000

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    st_reg      <= 2'b00;
    h_count_reg <= 8'b0;
    l_ctrl_reg  <= 3'b0;

  end else if (cs == 1'b0) begin
    st_reg      <= 2'b00;
    h_count_reg <= r_xoffset[9:2];
    l_ctrl_reg  <= 3'b111;

  end else if (st_reg == 2'b00) begin
    st_reg      <= 2'b01;
    h_count_reg <= h_count_reg + 8'b1;
    l_ctrl_reg  <= (r_xoffset[1:0] == 2'b00 ? 3'b001 : 3'b101);

  end else if (st_reg == 2'b01) begin
    st_reg      <= (l_cry == 1'b0 ? 2'b01 : 2'b11);
    h_count_reg <= h_count_reg + 8'b1;
    l_ctrl_reg  <= 3'b001;

  end else if (st_reg == 2'b11) begin
    st_reg      <= 2'b11;
    h_count_reg <= 8'b0;
    l_ctrl_reg  <= 3'b000;
  end
end

assign t_rdaddr = {v_count_a[9:3], h_count_reg[7:1]};
assign t_ren = (st_reg == 2'b00 && cs == 1'b1) | (st_reg == 2'b01);

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    t_ren_reg     <= 1'b0;
    h_count_reg0  <= 1'b0;
    xoffset_reg0  <= 2'b0;
  end else begin
    t_ren_reg     <= t_ren;
    h_count_reg0  <= h_count_reg[0];
    xoffset_reg0  <= r_xoffset[1:0];
  end
end

assign c_rdaddr = {t_rddata[9:5], v_count_a[2:0], t_rddata[4:0], h_count_reg0};
assign c_ren = t_ren_reg;

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    l_rdaddr0_reg <= 8'b0;
    l_rdaddr1_reg <= 8'b0;
    l_rdaddr2_reg <= 8'b0;
    l_rdaddr3_reg <= 8'b0;
    l_wen0_reg    <= 1'b0;
    l_wen1_reg    <= 1'b0;
    l_wen2_reg    <= 1'b0;
    l_wen3_reg    <= 1'b0;
  end else if (l_ctrl_reg == 3'b111) begin
    l_rdaddr0_reg <= 8'b0;
    l_rdaddr1_reg <= 8'b0;
    l_rdaddr2_reg <= 8'b0;
    l_rdaddr3_reg <= 8'b0;
    l_wen0_reg    <= 1'b0;
    l_wen1_reg    <= 1'b0;
    l_wen2_reg    <= 1'b0;
    l_wen3_reg    <= 1'b0;
  end else if (l_ctrl_reg == 3'b101) begin
    //
    l_rdaddr0_reg <= l_rdaddr0_reg + 8'b1;
    l_wen0_reg    <= 1'b1;
    //
    if (xoffset_reg0 != 2'b11) begin
      l_rdaddr1_reg <= l_rdaddr1_reg + 8'b1;
      l_wen1_reg    <= 1'b1;
    end else begin
      l_rdaddr1_reg <= 8'b0;
      l_wen1_reg    <= 1'b0;
    end
    //
    if (xoffset_reg0[1] == 1'b0) begin
      l_rdaddr2_reg <= l_rdaddr2_reg + 8'b1;
      l_wen2_reg    <= 1'b1;
    end else begin
      l_rdaddr2_reg <= 8'b0;
      l_wen2_reg    <= 1'b0;
    end
    //
    if (xoffset_reg0 == 2'b00) begin
      l_rdaddr3_reg <= l_rdaddr3_reg + 8'b1;
      l_wen3_reg    <= 1'b1;
    end else begin
      l_rdaddr3_reg <= 8'b0;
      l_wen3_reg  <= 1'b0;
    end
  end else if (l_ctrl_reg == 3'b001) begin
    l_rdaddr0_reg <= l_rdaddr0_reg + 8'b1;
    l_rdaddr1_reg <= l_rdaddr1_reg + 8'b1;
    l_rdaddr2_reg <= l_rdaddr2_reg + 8'b1;
    l_rdaddr3_reg <= l_rdaddr3_reg + 8'b1;
    l_wen0_reg    <= 1'b1;
    l_wen1_reg    <= 1'b1;
    l_wen2_reg    <= 1'b1;
    l_wen3_reg    <= 1'b1;
  end else if (l_ctrl_reg[0] == 1'b0) begin
    l_wen0_reg    <= 1'b0;
    l_wen1_reg    <= 1'b0;
    l_wen2_reg    <= 1'b0;
    l_wen3_reg    <= 1'b0;
  end
end

assign l_rdaddr0 = {l_bank, l_rdaddr0_reg};
assign l_rdaddr1 = {l_bank, l_rdaddr1_reg};
assign l_rdaddr2 = {l_bank, l_rdaddr2_reg};
assign l_rdaddr3 = {l_bank, l_rdaddr3_reg};
assign l_ren = c_ren;

assign l_cry = (l_rdaddr3_reg == 8'd200);

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    l_wraddr0_reg <= 10'b0;
    l_wraddr1_reg <= 10'b0;
    l_wraddr2_reg <= 10'b0;
    l_wraddr3_reg <= 10'b0;
    xoffset_reg1  <= 2'b0;
  end else begin
    l_wraddr0_reg <= l_rdaddr0;
    l_wraddr1_reg <= l_rdaddr1;
    l_wraddr2_reg <= l_rdaddr2;
    l_wraddr3_reg <= l_rdaddr3;
    xoffset_reg1  <= xoffset_reg0;
  end
end

assign l_wraddr0 = l_wraddr0_reg;
assign l_wraddr1 = l_wraddr1_reg;
assign l_wraddr2 = l_wraddr2_reg;
assign l_wraddr3 = l_wraddr3_reg;
assign l_wen0 = l_wen0_reg & (l_wraddr0[7:0] < 8'd200);
assign l_wen1 = l_wen1_reg & (l_wraddr1[7:0] < 8'd200);
assign l_wen2 = l_wen2_reg & (l_wraddr2[7:0] < 8'd200);
assign l_wen3 = l_wen3_reg & (l_wraddr3[7:0] < 8'd200);

assign l_wrdata[15:0]  = (xoffset_reg1 == 2'b00 ? (c_rddata[15] == 1'b1 ? l_rddata[15:0]  : c_rddata[15:0]) :
       		       	  xoffset_reg1 == 2'b01 ? (c_rddata[31] == 1'b1 ? l_rddata[15:0]  : c_rddata[31:16]) :
       		       	  xoffset_reg1 == 2'b10 ? (c_rddata[47] == 1'b1 ? l_rddata[15:0]  : c_rddata[47:32]) :
       		       	                          (c_rddata[63] == 1'b1 ? l_rddata[15:0]  : c_rddata[63:48]));

assign l_wrdata[31:16]  = (xoffset_reg1 == 2'b00 ? (c_rddata[31] == 1'b1 ? l_rddata[31:16]  : c_rddata[31:16]) :
       		       	   xoffset_reg1 == 2'b01 ? (c_rddata[47] == 1'b1 ? l_rddata[31:16]  : c_rddata[47:32]) :
       		       	   xoffset_reg1 == 2'b10 ? (c_rddata[63] == 1'b1 ? l_rddata[31:16]  : c_rddata[63:48]) :
			   		   	   (c_rddata[15] == 1'b1 ? l_rddata[31:16]  : c_rddata[15:0]));

assign l_wrdata[47:32]  = (xoffset_reg1 == 2'b00 ? (c_rddata[47] == 1'b1 ? l_rddata[47:32]  : c_rddata[47:32]) :
       		       	   xoffset_reg1 == 2'b01 ? (c_rddata[63] == 1'b1 ? l_rddata[47:32]  : c_rddata[63:48]) :
			   xoffset_reg1 == 2'b10 ? (c_rddata[15] == 1'b1 ? l_rddata[47:32]  : c_rddata[15:0])  :
			   		   	   (c_rddata[31] == 1'b1 ? l_rddata[47:32]  : c_rddata[31:16]));

assign l_wrdata[63:48]  = (xoffset_reg1 == 2'b00 ? (c_rddata[63] == 1'b1 ? l_rddata[63:48]  : c_rddata[63:48]) :
			   xoffset_reg1 == 2'b01 ? (c_rddata[15] == 1'b1 ? l_rddata[63:48]  : c_rddata[15:0])  :
			   xoffset_reg1 == 2'b10 ? (c_rddata[31] == 1'b1 ? l_rddata[63:48]  : c_rddata[31:16]) :
			   		   	   (c_rddata[47] == 1'b1 ? l_rddata[63:48]  : c_rddata[47:32]));

assign render_end = (st_reg == 2'b11);

endmodule

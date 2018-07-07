// -*- text -*-
`timescale 1 ns / 1 ps

module cv_sp_search (
  input         clk,
  input         reset,

  input         cs,
  input   [9:0] v_count,
  input   [9:0] sprite_count,
  output        search_end,
  output [10:0] search_count,

  output  [9:0] p_addr,
  output        p_ren,
  input  [63:0] p_din,

  output  [9:0] sch_addr,
  output        sch_wen,
  output  [9:0] sch_wrdata
);

reg   [1:0] st_reg;
wire  [1:0] st_next;

reg   [7:0] tblout;

reg  [10:0] sp_count_reg;
wire  [1:0] sp_count_ctrl;
reg   [9:0] pmem_addr_reg0;
reg   [9:0] pmem_addr_reg1;
wire  [1:0] pmem_addr_ctrl;
wire        pmem_cry;

wire [10:0] u_v_count;
wire [10:0] u_diff;
wire        comp_hit;

////////////////////////////////////////
//begintable
//#         comp cry|      pmem pmem mem count
//#state cs hit   N |state ren  addr wen ctrl
//  --    0  -    - | 00    0    11   0   11
//  00    1  -    - | 01    1    01   0   11
//#
//  01    1  0    0 | 01    1    01   0   00
//  01    1  1    0 | 01    1    01   1   01
//  01    1  0    1 | 10    1    01   0   00
//  01    1  1    1 | 10    1    01   1   01
//#eval last data
//  10    1  0    - | 11    0    00   0   00
//  10    1  1    - | 11    0    00   1   01
//#
//  11    1  -    - | 11    0    00   0   00
//endtable

always @*
begin
  casex({st_reg, cs, comp_hit, pmem_cry})
  5'bxx_0_x_x: tblout = 8'b00_0_11_0_11;
  5'b00_1_x_x: tblout = 8'b01_1_01_0_11;
  5'b01_1_0_0: tblout = 8'b01_1_01_0_00;
  5'b01_1_1_0: tblout = 8'b01_1_01_1_01;
  5'b01_1_0_1: tblout = 8'b10_1_01_0_00;
  5'b01_1_1_1: tblout = 8'b10_1_01_1_01;
  5'b10_1_0_x: tblout = 8'b11_0_00_0_00;
  5'b10_1_1_x: tblout = 8'b11_0_00_1_01;
  5'b11_1_x_x: tblout = 8'b11_0_00_0_00;
  default:     tblout = 8'b0;
  endcase
end

assign st_next        = tblout[7:6];
assign p_ren          = tblout[5];
assign sch_wen        = tblout[2];
assign pmem_addr_ctrl = tblout[4:3];
assign sp_count_ctrl  = tblout[1:0];

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    st_reg <= 2'b0;
  else
    st_reg <= st_next;
end

assign search_end = (st_reg == 2'b11);

////////////////////////////////////////
//// pmem_addr, sp_count
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    pmem_addr_reg0 <= 10'b0;
    pmem_addr_reg1 <= 10'b0;
    sp_count_reg   <= 11'b0;
  end else begin
    // pmem_addr
    if (pmem_addr_ctrl == 2'b11)
      pmem_addr_reg0 <= 10'b0;
    else if (pmem_addr_ctrl == 2'b01)
      pmem_addr_reg0 <= pmem_addr_reg0 + 10'b1;

    pmem_addr_reg1 <= pmem_addr_reg0;

    // sp_count
    if (sp_count_ctrl == 2'b11)
      sp_count_reg <= 11'b0;
    else if (sp_count_ctrl == 2'b01)
      sp_count_reg <= sp_count_reg + 11'b1;
  end
end

assign p_addr   = pmem_addr_reg0;
assign pmem_cry = (pmem_addr_reg0 == sprite_count);
assign search_count = sp_count_reg;

assign sch_addr = sp_count_reg;
assign sch_wrdata = pmem_addr_reg1;

////////////////////////////////////////
//// compare
assign u_v_count = {1'b0, v_count};
assign u_diff = u_v_count - p_din[10:0];
assign comp_hit = (u_diff < 11'd16);


endmodule

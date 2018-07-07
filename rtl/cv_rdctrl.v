// -*- text -*-
`timescale 1 ns / 1 ps

module cv_rdctrl (
  input         clk,
  input         reset,

  input         cs,
  output  [2:0] rend_order_sel,
  input   [7:0] r_rend_order,
  output        bg_cs,
  output  [1:0] bg_screen,
  input         bg_render_end,
  output        sp_cs,
  input         sp_search_end,
  input         sp_render_end
);


////////////////////////////////////////
//begintable
//#              cry bg  sp   sp  |      bg sp
//#state cs cmd   7  end send rend|state cs cs count
//  ---   0 ----  -   -   -     - | 000   0  0  11
//  000   1 ----  -   -   -     - | 001   0  0  11
//#check cmd
//  001   1 0000  -   -   -     - | 111   0  0  00   #cmd end
//  001   1 0001  -   -   -     - | 010   0  0  00   #bg
//  001   1 0010  -   -   -     - | 100   0  0  00   #sprite
//#BG
//  010   1 ----  -   0   -     - | 010   1  0  00
//  010   1 ----  -   1   -     - | 110   0  0  00   #rend end
//#sprite
//  100   1 ----  -   -   0     - | 100   0  0  00
//  100   1 ----  -   -   1     - | 101   0  0  00
//  101   1 ----  -   -   -     0 | 101   0  1  00   #
//  101   1 ----  -   -   -     1 | 110   0  0  00   #
//#
//  110   1 ----  0   -   -     - | 001   0  0  01
//  110   1 ----  1   -   -     - | 111   0  0  00
//#
//  111   1 ----  -   -   -     - | 111   0  0  00
//endtable

reg  [2:0] st_reg;
reg  [6:0] tblout;
reg  [2:0] count_reg;
wire       cry7;

always @*
begin
  casex({st_reg, cs, r_rend_order[7:4], cry7, bg_render_end, sp_search_end, sp_render_end})
  12'bxxx_0_xxxx_x_x_x_x: tblout = 7'b000_0_0_11;
  12'b000_1_xxxx_x_x_x_x: tblout = 7'b001_0_0_11;
  12'b001_1_0000_x_x_x_x: tblout = 7'b111_0_0_00;
  12'b001_1_0001_x_x_x_x: tblout = 7'b010_0_0_00;
  12'b001_1_0010_x_x_x_x: tblout = 7'b100_0_0_00;
  12'b010_1_xxxx_x_0_x_x: tblout = 7'b010_1_0_00;
  12'b010_1_xxxx_x_1_x_x: tblout = 7'b110_0_0_00;
  12'b100_1_xxxx_x_x_0_x: tblout = 7'b100_0_0_00;
  12'b100_1_xxxx_x_x_1_x: tblout = 7'b101_0_0_00;
  12'b101_1_xxxx_x_x_x_0: tblout = 7'b101_0_1_00;
  12'b101_1_xxxx_x_x_x_1: tblout = 7'b110_0_0_00;
  12'b110_1_xxxx_0_x_x_x: tblout = 7'b001_0_0_01;
  12'b110_1_xxxx_1_x_x_x: tblout = 7'b111_0_0_00;
  12'b111_1_xxxx_x_x_x_x: tblout = 7'b111_0_0_00;
  endcase
end

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    st_reg <= 3'b000;
  else
    st_reg <= tblout[6:4];
end

assign bg_cs = tblout[3];
assign bg_screen = r_rend_order[1:0];

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    count_reg <= 3'b0;
  else if (tblout[1:0] == 2'b11)
    count_reg <= 3'b0;
  else if (tblout[1:0] == 2'b01)
    count_reg <= count_reg + 3'b1;
end

assign cry7 = (count_reg == 3'd7);
assign rend_order_sel = count_reg;

assign sp_cs = tblout[2];

endmodule

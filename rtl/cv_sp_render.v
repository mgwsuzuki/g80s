// -*- text -*-
`timescale 1 ns / 1 ps

module cv_sp_render (
  input         clk,
  input         reset,

  input         cs,
  input   [9:0] v_count,
  input  [10:0] search_count,
  output        render_end,

  output  [9:0] sch_raddr,
  output        sch_ren,
  input   [9:0] sch_rddata,

  output [13:0] s_addr,
  output        s_ren,
  input  [63:0] s_data,

  output  [9:0] p_addr,
  output        p_ren,
  input  [63:0] p_data,

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

reg   [2:0] st_reg;
wire  [2:0] st_next;
reg   [6:0] tblout;

reg  [10:0] sch_addr_reg;
wire        is_zero;

reg         p_ren_reg;
reg   [1:0] s_ren_reg;

wire [10:0] u_v_count;
wire [10:0] u_diff;

wire [13:0] s_addr_base;
reg  [13:0] s_addr_reg;

reg   [1:0] render_end_reg;

reg  [1:0] posx_reg0;
reg  [1:0] posx_reg1;

wire [8:0] lbuf_rdaddr0_base;
wire [8:0] lbuf_rdaddr1_base;
wire [8:0] lbuf_rdaddr2_base;
wire [8:0] lbuf_rdaddr3_base;
wire       lbuf_rdaddr0_msb;
wire       lbuf_rdaddr1_msb;
wire       lbuf_rdaddr2_msb;
wire       lbuf_rdaddr3_msb;
reg  [8:0] lbuf_rdaddr0_reg;
reg  [8:0] lbuf_rdaddr1_reg;
reg  [8:0] lbuf_rdaddr2_reg;
reg  [8:0] lbuf_rdaddr3_reg;
reg  [9:0] lbuf_wraddr0_reg;
reg  [9:0] lbuf_wraddr1_reg;
reg  [9:0] lbuf_wraddr2_reg;
reg  [9:0] lbuf_wraddr3_reg;
reg        lbuf_wen0_reg;
reg        lbuf_wen1_reg;
reg        lbuf_wen2_reg;
reg        lbuf_wen3_reg;

wire [63:0] lbuf_char_data;

////////////////////////////////////////

//begintable
//
//#sch_addr -0:nop, 01:dec, 11:load search_count
//#
//#         is  |      sch  sch c
//#state cs zero|state addr ren ren
//  ---   0  -  | 000   00   0   0
//  000   1  -  | 001   11   0   0
//  001   1  0  | 010   01   0   0
//  001   1  1  | 111   00   0   0  #no sprite
//#
//  010   1  -  | 011   00   1   1
//  011   1  -  | 100   00   0   1
//  100   1  -  | 101   00   0   1
//  101   1  0  | 010   01   0   1
//  101   1  1  | 111   00   0   1
//#end
//  111   1  -  | 111   00   0   0
//endtable

always @*
begin
  casex({st_reg, cs, is_zero})
  5'bxxx_0_x: tblout = 7'b000_00_0_0;
  5'b000_1_x: tblout = 7'b001_11_0_0;
  5'b001_1_0: tblout = 7'b010_01_0_0;
  5'b001_1_1: tblout = 7'b111_00_0_0;
  5'b010_1_x: tblout = 7'b011_00_1_1;
  5'b011_1_x: tblout = 7'b100_00_0_1;
  5'b100_1_x: tblout = 7'b101_00_0_1;
  5'b101_1_0: tblout = 7'b010_01_0_1;
  5'b101_1_1: tblout = 7'b111_00_0_1;
  5'b111_1_x: tblout = 7'b111_00_0_0;
  default: tblout = 7'b0;
  endcase
end

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    st_reg <= 3'b0;
  else
    st_reg <= tblout[6:4];
end


always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    render_end_reg <= 2'b0;
  else
    render_end_reg <= {render_end_reg[0], (st_reg == 3'b111)};
end

assign render_end = render_end_reg[1];

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    sch_addr_reg <= 11'b0;
  else if (tblout[3:2] == 2'b11)
    sch_addr_reg <= search_count;
  else if (tblout[3:2] == 2'b01)
    sch_addr_reg <= sch_addr_reg - 11'b1;
end

assign is_zero = (sch_addr_reg == 11'b0);
assign sch_raddr = sch_addr_reg[9:0];
assign sch_ren   = tblout[1];

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    p_ren_reg <= 1'b0;
    s_ren_reg <= 2'b0;
  end else begin
    p_ren_reg <= tblout[1];
    s_ren_reg <= {s_ren_reg[0], tblout[0]};
  end
end

assign p_addr = sch_rddata;
assign p_ren = p_ren_reg;
assign s_ren = s_ren_reg[1];

////////////////////////////////////////
//// compare
assign u_v_count = {1'b0, v_count};
assign u_diff = u_v_count - p_data[10:0];

////////////////////////////////////////
//// char addr
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    s_addr_reg <= 13'b0;
  else if (st_reg == 3'b100)
    s_addr_reg <= s_addr_base + 13'd1;
  else if (s_ren_reg[0] == 1'b1)
    s_addr_reg <= s_addr_reg + 13'd1;
end

assign s_addr_base = p_data[45:32] + {4'b0, u_diff[3:0], 6'b0};
assign s_addr = (st_reg == 3'b100 ? s_addr_base : s_addr_reg);


////////////////////////////////////////
//// line buf addr
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    posx_reg0 <= 2'b00;
    posx_reg1 <= 2'b00;
  end else begin
    posx_reg0 <= p_data[17:16];
    posx_reg1 <= posx_reg0;
  end
end

assign lbuf_rdaddr0_base = (p_data[17:16] == 2'b00 ? p_data[26:18] :
       		            p_data[17:16] == 2'b01 ? p_data[26:18] + 9'd1 :
       		            p_data[17:16] == 2'b10 ? p_data[26:18] + 9'd1 :
			  			     p_data[26:18] + 9'd1);

assign lbuf_rdaddr1_base = (p_data[17:16] == 2'b00 ? p_data[26:18] :
       		            p_data[17:16] == 2'b01 ? p_data[26:18] :
       		            p_data[17:16] == 2'b10 ? p_data[26:18] + 9'd1 :
			  			     p_data[26:18] + 9'd1);

assign lbuf_rdaddr2_base = (p_data[17:16] == 2'b00 ? p_data[26:18] :
       		            p_data[17:16] == 2'b01 ? p_data[26:18] :
       		            p_data[17:16] == 2'b10 ? p_data[26:18] :
			  	  		     p_data[26:18] + 9'd1);

assign lbuf_rdaddr3_base =  p_data[26:18];

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    lbuf_rdaddr0_reg <= 9'b0;
    lbuf_rdaddr1_reg <= 9'b0;
    lbuf_rdaddr2_reg <= 9'b0;
    lbuf_rdaddr3_reg <= 9'b0;
  end else begin
    if (st_reg == 3'b100) begin
      lbuf_rdaddr0_reg <= lbuf_rdaddr0_base + 9'd1;
      lbuf_rdaddr1_reg <= lbuf_rdaddr1_base + 9'd1;
      lbuf_rdaddr2_reg <= lbuf_rdaddr2_base + 9'd1;
      lbuf_rdaddr3_reg <= lbuf_rdaddr3_base + 9'd1;
    end else if (s_ren_reg[0] == 1'b1) begin
      lbuf_rdaddr0_reg <= lbuf_rdaddr0_reg + 9'd1;
      lbuf_rdaddr1_reg <= lbuf_rdaddr1_reg + 9'd1;
      lbuf_rdaddr2_reg <= lbuf_rdaddr2_reg + 9'd1;
      lbuf_rdaddr3_reg <= lbuf_rdaddr3_reg + 9'd1;
    end
  end
end

assign l_ren = s_ren;

assign lbuf_char_data = (posx_reg0 == 2'b00 ? s_data :
       		         posx_reg0 == 2'b01 ? {s_data[47:0], s_data[63:48]} :
       		         posx_reg0 == 2'b10 ? {s_data[31:0], s_data[63:32]} :
		    	     	              {s_data[15:0], s_data[63:16]});

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    lbuf_wraddr0_reg <= 10'b0;
    lbuf_wraddr1_reg <= 10'b0;
    lbuf_wraddr2_reg <= 10'b0;
    lbuf_wraddr3_reg <= 10'b0;
    lbuf_wen0_reg    <= 1'b0;
    lbuf_wen1_reg    <= 1'b0;
    lbuf_wen2_reg    <= 1'b0;
    lbuf_wen3_reg    <= 1'b0;
  end else begin
    lbuf_wraddr0_reg <= l_rdaddr0;
    lbuf_wraddr1_reg <= l_rdaddr1;
    lbuf_wraddr2_reg <= l_rdaddr2;
    lbuf_wraddr3_reg <= l_rdaddr3;
    lbuf_wen0_reg <= l_ren & !lbuf_rdaddr0_msb;
    lbuf_wen1_reg <= l_ren & !lbuf_rdaddr1_msb;
    lbuf_wen2_reg <= l_ren & !lbuf_rdaddr2_msb;
    lbuf_wen3_reg <= l_ren & !lbuf_rdaddr3_msb;
  end
end

assign {lbuf_rdaddr0_msb, l_rdaddr0[7:0]} = (st_reg == 3'b100 ? lbuf_rdaddr0_base : lbuf_rdaddr0_reg);
assign {lbuf_rdaddr1_msb, l_rdaddr1[7:0]} = (st_reg == 3'b100 ? lbuf_rdaddr1_base : lbuf_rdaddr1_reg);
assign {lbuf_rdaddr2_msb, l_rdaddr2[7:0]} = (st_reg == 3'b100 ? lbuf_rdaddr2_base : lbuf_rdaddr2_reg);
assign {lbuf_rdaddr3_msb, l_rdaddr3[7:0]} = (st_reg == 3'b100 ? lbuf_rdaddr3_base : lbuf_rdaddr3_reg);
assign l_rdaddr0[9:8] = p_data[49:48];
assign l_rdaddr1[9:8] = p_data[49:48];
assign l_rdaddr2[9:8] = p_data[49:48];
assign l_rdaddr3[9:8] = p_data[49:48];
assign l_wraddr0 = lbuf_wraddr0_reg;
assign l_wraddr1 = lbuf_wraddr1_reg;
assign l_wraddr2 = lbuf_wraddr2_reg;
assign l_wraddr3 = lbuf_wraddr3_reg;
assign l_wen0 = lbuf_wen0_reg & ~lbuf_char_data[15];
assign l_wen1 = lbuf_wen1_reg & ~lbuf_char_data[31];
assign l_wen2 = lbuf_wen2_reg & ~lbuf_char_data[47];
assign l_wen3 = lbuf_wen3_reg & ~lbuf_char_data[63];

assign l_wrdata = {1'b0, lbuf_char_data[62:48], 1'b0, lbuf_char_data[46:32],
		   1'b0, lbuf_char_data[30:16], 1'b0, lbuf_char_data[14:0]};


endmodule

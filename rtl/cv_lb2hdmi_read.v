// -*- text -*-
`timescale 1 ns / 1 ps

module cv_lb2hdmi_read (
  input         clk,
  input         reset,

  input         h_en,
  input		h_active,
  input	  [9:0]	h_count,
  input         v_active,

  output  [9:0] l_rdaddr,
  output        l_ren,
  input  [63:0] l_rddata,

  output [15:0] pixel_out
);

reg   [2:0] st_reg;
wire        read_trig;

reg  [63:0] mix_reg;

reg   [3:0] out_count;
reg  [15:0] mix_reg2;
reg  [15:0] mix_reg3;

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    st_reg <= 3'b0;
  else if (read_trig == 1'b1)
    st_reg <= 3'b001;
  else if (st_reg == 3'b001)
    st_reg <= 3'b010;
  else if (st_reg == 3'b010)
    st_reg <= 3'b011;
  else if (st_reg == 3'b011)
    st_reg <= 3'b100;
  else
    st_reg <= 3'b000;
end

assign read_trig = (st_reg == 3'b000 && v_active == 1'b1 && h_active == 1'b1 && h_count[1:0] == 2'b00 && h_en == 1'b1);

assign l_rdaddr = {(read_trig == 1'b1   ? 2'b11 :
       		    st_reg    == 3'b001 ? 2'b10 :
		    st_reg    == 3'b010 ? 2'b01 : 2'b00), h_count[9:2]};
assign l_ren = (read_trig == 1'b1 || st_reg == 3'b001 || st_reg == 3'b010 || st_reg == 3'b011);


always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    mix_reg <= 64'b0;
  else if (st_reg == 3'b001)
    mix_reg <= l_rddata;
  else if (st_reg == 3'b010 || st_reg == 3'b011 || st_reg == 3'b100) begin
    mix_reg[15:0]  <= (l_rddata[15] == 1'b0 ? l_rddata[15:0]  : mix_reg[15:0]);
    mix_reg[31:16] <= (l_rddata[31] == 1'b0 ? l_rddata[31:16] : mix_reg[31:16]);
    mix_reg[47:32] <= (l_rddata[47] == 1'b0 ? l_rddata[47:32] : mix_reg[47:32]);
    mix_reg[63:48] <= (l_rddata[63] == 1'b0 ? l_rddata[63:48] : mix_reg[63:48]);
  end
end

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    out_count <= 4'b1111;
  else if (st_reg == 3'b100)
    out_count <= 4'b0;
  else if (out_count != 4'b1111)
    out_count <= out_count + 4'b1;
end

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    mix_reg2 <= 16'b0;
    mix_reg3 <= 16'b0;
  end else if (out_count == 4'b0) begin
    mix_reg2 <= mix_reg[47:32];
    mix_reg3 <= mix_reg[63:48];
  end
end

assign pixel_out = (out_count == 4'h0 || out_count ==4'h1 || out_count == 4'h2 ? mix_reg[15:0] :
       		    out_count == 4'h3 || out_count ==4'h4 || out_count == 4'h5 ? mix_reg[32:16] :
       		    out_count == 4'h6 || out_count ==4'h7 || out_count == 4'h8 ? mix_reg2 : mix_reg3);

endmodule

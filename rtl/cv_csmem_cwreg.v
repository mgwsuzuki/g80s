// -*- text -*-
`timescale 1 ns / 1 ps

module cv_csmem_cwreg # (
  parameter ADDR_MSB = 7'b111_1101) (
  input         reset,

  input         ps_c_clk,
  input  [18:0] ps_c_addr,
  input  [31:0] ps_c_din,
  input   [3:0] ps_c_we,
  input         ps_c_en,
  output [31:0] ps_c_dout,
  output        ps_c_dout_en,

  output  [1:0] r_virq,
  input   [2:0] rend_order_sel,
  output  [7:0] r_rend_order,
  output [15:0] r_sp_count
);

wire         cs;
wire  [11:0] addr_lsb;
reg          virq_en_reg;
reg    [7:0] rend_order0_reg;
reg    [7:0] rend_order1_reg;
reg    [7:0] rend_order2_reg;
reg    [7:0] rend_order3_reg;
reg    [7:0] rend_order4_reg;
reg    [7:0] rend_order5_reg;
reg    [7:0] rend_order6_reg;
reg    [7:0] rend_order7_reg;
reg   [15:0] sp_count_reg;

reg  [31:0] dout_reg;
reg         dout_en_reg;

////////////////////////////////////////
//// write
assign cs = (ps_c_addr[18:12] == ADDR_MSB && ps_c_en == 1'b1);
assign addr_lsb = ps_c_addr[11:2];

always @ (posedge ps_c_clk, posedge reset)
begin
  if (reset == 1'b1) begin
    virq_en_reg <= 1'b0;
    rend_order0_reg <= 8'b0;
    rend_order1_reg <= 8'b0;
    rend_order2_reg <= 8'b0;
    rend_order3_reg <= 8'b0;
    rend_order4_reg <= 8'b0;
    rend_order5_reg <= 8'b0;
    rend_order6_reg <= 8'b0;
    rend_order7_reg <= 8'b0;
    sp_count_reg    <= 16'b0;
  end else if (cs == 1'b1) begin
    if (addr_lsb == 12'h000 && ps_c_we[0] == 1'b1) virq_en_reg <= ps_c_din[0];
    if (addr_lsb == 12'h008 && ps_c_we[0] == 1'b1) rend_order0_reg <= ps_c_din[7:0];
    if (addr_lsb == 12'h008 && ps_c_we[1] == 1'b1) rend_order1_reg <= ps_c_din[15:8];
    if (addr_lsb == 12'h008 && ps_c_we[2] == 1'b1) rend_order2_reg <= ps_c_din[23:16];
    if (addr_lsb == 12'h008 && ps_c_we[3] == 1'b1) rend_order3_reg <= ps_c_din[31:24];
    if (addr_lsb == 12'h009 && ps_c_we[0] == 1'b1) rend_order4_reg <= ps_c_din[7:0];
    if (addr_lsb == 12'h009 && ps_c_we[1] == 1'b1) rend_order5_reg <= ps_c_din[15:8];
    if (addr_lsb == 12'h009 && ps_c_we[2] == 1'b1) rend_order6_reg <= ps_c_din[23:16];
    if (addr_lsb == 12'h009 && ps_c_we[3] == 1'b1) rend_order7_reg <= ps_c_din[31:24];
    if (addr_lsb == 12'h00c && ps_c_we[1:0] == 2'b11) sp_count_reg <= ps_c_din[15:0];
  end
end

////////////////////////////////////////
//// trigger
assign r_virq[1] = (cs == 1'b1 && addr_lsb == 12'h004 && ps_c_we[0] == 1'b1);

////////////////////////////////////////
//// dout
always @ (posedge ps_c_clk, posedge reset)
begin
  if (reset == 1'b1) begin
    dout_reg    <= 32'b0;
    dout_en_reg <= 1'b0;
  end else begin
    dout_en_reg <= cs;
    if (cs == 1'b1)
      dout_reg <= (addr_lsb == 12'h000 ? {31'b0, virq_en_reg} :
      	       	   addr_lsb == 12'h008 ? {rend_order3_reg, rend_order2_reg, rend_order1_reg, rend_order0_reg} :
      	       	   addr_lsb == 12'h009 ? {rend_order7_reg, rend_order6_reg, rend_order5_reg, rend_order4_reg} :
		   addr_lsb == 12'h00c ? {16'b0, sp_count_reg} :
		   	       	         32'b0);
  end
end

assign ps_c_dout = dout_reg;
assign ps_c_dout_en = dout_en_reg;

assign r_virq[0] = virq_en_reg;

assign r_rend_order = (rend_order_sel == 3'd0 ? rend_order0_reg :
       		       rend_order_sel == 3'd1 ? rend_order1_reg :
       		       rend_order_sel == 3'd2 ? rend_order2_reg :
       		       rend_order_sel == 3'd3 ? rend_order3_reg :
       		       rend_order_sel == 3'd4 ? rend_order4_reg :
       		       rend_order_sel == 3'd5 ? rend_order5_reg :
       		       rend_order_sel == 3'd6 ? rend_order6_reg :
		       		      	      	rend_order7_reg);

assign r_sp_count = sp_count_reg;

endmodule

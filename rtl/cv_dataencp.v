// -*- text -*-
`timescale 1ns/1ps

//// pipelined data encoder

module cv_dataencp (
  input        clk,
  input        reset,
  input        cs,
  input  [7:0] din,
  input        din_en,
  output [9:0] dout,
  output       dout_en);

////////////////////////////////////////

wire [3:0] s1_din_bit1;
reg  [3:0] s1_din_bit1_reg;
reg  [7:0] s1_din_reg;
reg        s1_din_en_reg;

wire       s2_eval1;
wire [8:0] s2_q_m;
wire [3:0] s2_q_m_bit0;
wire [3:0] s2_q_m_bit1;
reg  [8:0] s2_q_m_reg;
reg  [3:0] s2_q_m_bit0_reg;
reg  [3:0] s2_q_m_bit1_reg;
reg        s2_din_en_reg;


reg  signed [7:0] s3_cnt_reg;

wire       s3_cnt_eq_zero;
wire       s3_cnt_gt_zero;
wire       s3_cnt_lt_zero;
wire       s3_qm1_eq_qm0;
wire       s3_qm1_gt_qm0;
wire       s3_qm0_gt_qm1;
wire       s3_eval2;
wire       s3_eval3;

reg  [4:0] s3_tblout;
wire [9:0] s3_dout;
reg  [9:0] s3_dout_reg;
reg        s3_dout_en_reg;

////////////////////////////////////////
//// stage 1
cv_countbit # (
  .ISIZE(8),
  .OSIZE(4),
  .CBIT (1)) cbit0 (
  .din  (din),
  .dout (s1_din_bit1));

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    s1_din_bit1_reg <= 4'b0;
    s1_din_reg      <= 8'b0;
    s1_din_en_reg   <= 1'b0;
  end else begin
    s1_din_bit1_reg <= s1_din_bit1;
    s1_din_reg      <= din;
    s1_din_en_reg   <= din_en;
  end
end

////////////////////////////////////////
//// stage 2

assign s2_eval1 = ((s1_din_bit1_reg > 3'd4) ||
                     (s1_din_bit1_reg == 3'd4 && s1_din_reg[0] == 0));
assign s2_q_m[0] = s1_din_reg[0];
assign s2_q_m[1] = s2_eval1 ^ s2_q_m[0] ^ s1_din_reg[1];
assign s2_q_m[2] = s2_eval1 ^ s2_q_m[1] ^ s1_din_reg[2];
assign s2_q_m[3] = s2_eval1 ^ s2_q_m[2] ^ s1_din_reg[3];
assign s2_q_m[4] = s2_eval1 ^ s2_q_m[3] ^ s1_din_reg[4];
assign s2_q_m[5] = s2_eval1 ^ s2_q_m[4] ^ s1_din_reg[5];
assign s2_q_m[6] = s2_eval1 ^ s2_q_m[5] ^ s1_din_reg[6];
assign s2_q_m[7] = s2_eval1 ^ s2_q_m[6] ^ s1_din_reg[7];
assign s2_q_m[8] = ~s2_eval1;

cv_countbit # (
  .ISIZE(8),
  .OSIZE(4),
  .CBIT (0)) cbit1 (
  .din  (s2_q_m[7:0]),
  .dout (s2_q_m_bit0));

cv_countbit # (
  .ISIZE(8),
  .OSIZE(4),
  .CBIT (1)) cbit2 (
  .din  (s2_q_m[7:0]),
  .dout (s2_q_m_bit1));

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    s2_q_m_reg      <= 9'b0;
    s2_q_m_bit0_reg <= 4'b0;
    s2_q_m_bit1_reg <= 4'b0;
    s2_din_en_reg   <= 1'b0;
  end else begin
    s2_q_m_reg      <= s2_q_m;
    s2_q_m_bit0_reg <= s2_q_m_bit0;
    s2_q_m_bit1_reg <= s2_q_m_bit1;
    s2_din_en_reg   <= s1_din_en_reg;
  end
end

////////////////////////////////////////
//// stage 3

assign s3_qm1_eq_qm0 = (s2_q_m_bit1_reg == s2_q_m_bit0_reg);
assign s3_qm1_gt_qm0 = (s2_q_m_bit1_reg >  s2_q_m_bit0_reg);
assign s3_qm0_gt_qm1 = (s2_q_m_bit0_reg >  s2_q_m_bit1_reg);

assign s3_eval2 = ( s3_cnt_eq_zero | s3_qm1_eq_qm0);
assign s3_eval3 = ((s3_cnt_gt_zero & s3_qm1_gt_qm0) | (s3_cnt_lt_zero & s3_qm0_gt_qm1));

// eval2 eval3 qm[8] | qout[9] qout[7:0] next_cnt
//   1     -     0   | ~qm[8]  ~qm[7:0]       qm0 - qm1 (00)
//   1     -     1   | ~qm[8]   qm[7:0]       qm1 - qm0 (01)
//   0     1     0   |    1    ~qm[7:0]       qm0 - qm1 (00)
//   0     1     1   |    1    ~qm[7:0]   2 + qm0 - qm1 (10)
//   0     0     0   |    0     qm[7:0]  -2 + qm1 - qm0 (11)
//   0     0     1   |    0     qm[7:0]       qm1 - qm0 (01)

always @*
begin
  casex ({s3_eval2, s3_eval3, s2_q_m_reg[8]})
  3'b1x0: s3_tblout = 5'b10_1_00;
  3'b1x1: s3_tblout = 5'b10_0_01;
  3'b010: s3_tblout = 5'b01_1_00;
  3'b011: s3_tblout = 5'b01_1_10;
  3'b000: s3_tblout = 5'b00_0_11;
  3'b001: s3_tblout = 5'b00_0_01;
  endcase
end

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    s3_cnt_reg <= 8'b0;
  else if (cs == 1'b0)
    s3_cnt_reg <= 8'b0;
  else if (s2_din_en_reg == 1'b0)
    s3_cnt_reg <= s3_cnt_reg;
  else if (s3_tblout[1:0] == 2'b00)   s3_cnt_reg <= s3_cnt_reg + s2_q_m_bit0_reg - s2_q_m_bit1_reg;
  else if (s3_tblout[1:0] == 2'b01)   s3_cnt_reg <= s3_cnt_reg + s2_q_m_bit1_reg - s2_q_m_bit0_reg;
  else if (s3_tblout[1:0] == 2'b10)   s3_cnt_reg <= s3_cnt_reg + s2_q_m_bit0_reg - s2_q_m_bit1_reg + 8'd2;
  else                                s3_cnt_reg <= s3_cnt_reg + s2_q_m_bit1_reg - s2_q_m_bit0_reg - 8'd2;
end

assign s3_cnt_eq_zero = (s3_cnt_reg == 8'b0);
assign s3_cnt_gt_zero = (s3_cnt_reg > 0);
assign s3_cnt_lt_zero = (s3_cnt_reg < 0);

assign s3_dout[9]   = (s3_tblout[4:3] == 2'b00 ? 1'b0 :
       	       	       s3_tblout[4:3] == 2'b01 ? 1'b1 : ~s2_q_m_reg[8]);
assign s3_dout[8]   =  s2_q_m_reg[8];
assign s3_dout[7:0] = (s3_tblout[2] == 1'b1 ? ~s2_q_m_reg[7:0] : s2_q_m_reg[7:0]);

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    s3_dout_reg    <= 10'b0;
    s3_dout_en_reg <= 1'b0;
  end else begin
    s3_dout_reg    <= s3_dout;
    s3_dout_en_reg <= s2_din_en_reg;
  end
end

assign dout = s3_dout_reg;
assign dout_en = s3_dout_en_reg;

endmodule

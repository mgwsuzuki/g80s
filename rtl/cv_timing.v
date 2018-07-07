// -*- text -*-
`timescale 1ns/1ps

module cv_timing # (
  parameter H_PRE    = 1,
  parameter H_ACTIVE = 799,	// 800
  parameter H_FRONT  = 39,	// 40
  parameter H_SYNC   = 127,	// 128
  parameter H_BACK   = 87,	// 88
  parameter V_ACTIVE = 599,	// 600
  parameter V_FRONT  = 0,	// 1
  parameter V_SYNC   = 3,	// 4
  parameter V_BACK   = 22)	// 23
(
  input         clk,
  input         reset,

  input         cs,
  output        h_front,
  output        h_sync,
  output        h_back,
  output        h_preamble,
  output        h_guard,
  output        h_active,
  output        h_en,
  output        h_end,
  output [10:0] h_count,
  output        v_front,
  output        v_sync,
  output        v_back,
  output        v_active,
  output        v_end,
  output  [9:0] v_count,
  output  [9:0] sp_v_count,
  output        sp_v_active
);

////////////////////////////////////////

wire        h_cry_pre;
wire        h_cry_active;
wire        h_cry_front;
wire        h_cry_sync;
wire        h_cry_back;

wire        v_cry_active;
wire        v_cry_front;
wire        v_cry_sync;
wire        v_cry_back;

reg   [1:0] h_pre_reg;
reg  [10:0] h_count_reg;
reg   [2:0] h_state_reg;
wire        h_cry;
reg  [10:0] v_count_reg;
reg   [2:0] v_state_reg;

parameter H_PREAMBLE_START = H_BACK - 9;
parameter H_GUARD_START = H_BACK - 1;

wire        h_preamble_start_cry;
wire        h_guard_start_cry;

////////////////////////////////////////
//// pre counter
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    h_pre_reg <= 2'b0;

  else if (cs == 1'b0)
    h_pre_reg <= 2'b0;

  else if (h_cry_pre == 1'b1)
    h_pre_reg <= 2'b0;

  else
    h_pre_reg <= h_pre_reg + 2'b1;
end

assign h_cry_pre = (h_pre_reg == H_PRE);
assign h_en = h_pre_reg == 2'b00 && cs == 1'b1;

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    h_count_reg <= 11'b0;
    h_state_reg <= 3'b0;

  end else if (cs == 1'b0) begin
    h_count_reg <= 11'b0;
    h_state_reg <= 3'b0;

  end else if (h_cry_pre == 1'b1)
    case (h_state_reg)
      3'b000: begin
        h_count_reg <= 11'b0;
        h_state_reg <= 3'b001;
      end

      3'b001:					// H_FRONT_PORCH
        if (h_cry_front == 1'b1) begin
          h_count_reg <= 11'd0;
          h_state_reg <= 3'b010;
        end else
          h_count_reg <= h_count_reg + 11'd1;

      3'b010:					// H_SYNC
        if (h_cry_sync == 1'b1) begin
          h_count_reg <= 11'd0;
          h_state_reg <= 3'b011;
        end else
          h_count_reg <= h_count_reg + 11'd1;

      3'b011:					// H_BACK
        if (h_cry_back == 1'b1) begin
          h_count_reg <= 11'd0;
          h_state_reg <= 3'b100;
        end else
          h_count_reg <= h_count_reg + 11'd1;

      3'b100:					// H_ACTIVE
        if (h_cry_active == 1'b1) begin
          h_count_reg <= 11'd0;
          h_state_reg <= 3'b001;
        end else
          h_count_reg <= h_count_reg + 11'd1;

      default: begin
        h_count_reg <= 11'b0;
        h_state_reg <= 3'b000;
      end
    endcase
end

assign h_cry_active = (h_count_reg == H_ACTIVE);
assign h_cry_front  = (h_count_reg == H_FRONT);
assign h_cry_sync   = (h_count_reg == H_SYNC);
assign h_cry_back   = (h_count_reg == H_BACK);

assign h_front  = (h_state_reg == 3'b001);
assign h_sync   = (h_state_reg == 3'b010);
assign h_back   = (h_state_reg == 3'b011);
assign h_active = (h_state_reg == 3'b100) & v_active;
assign h_count  = (h_state_reg == 3'b100 ?  h_count_reg : 11'b0);

assign h_end = (h_state_reg == 3'b100 && h_cry_active == 1'b1);

assign h_preamble_start_cry = (h_count_reg >= H_PREAMBLE_START);
assign h_guard_start_cry = (h_count_reg >= H_GUARD_START);

assign h_preamble = (h_preamble_start_cry & ~h_guard_start_cry) & h_back & v_active;
assign h_guard = h_guard_start_cry & h_back & v_active;


////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    v_count_reg <= 11'b0;
    v_state_reg <= 3'b0;

  end else if (cs == 1'b0) begin
    v_count_reg <= 11'b0;
    v_state_reg <= 3'b0;

  end else if (h_cry_active == 1'b1 && h_cry_pre == 1'b1) begin
    case (v_state_reg)
      3'b000: begin
        v_count_reg <= 11'b0;
        v_state_reg <= 3'b001;
      end

      3'b001:					// V_FRONT_PORCH
        if (v_cry_front == 1'b1) begin
          v_count_reg <= 11'd0;
          v_state_reg <= 3'b010;
        end else
          v_count_reg <= v_count_reg + 11'd1;

      3'b010:					// V_SYNC
        if (v_cry_sync == 1'b1) begin
          v_count_reg <= 11'd0;
          v_state_reg <= 3'b011;
        end else
          v_count_reg <= v_count_reg + 11'd1;

      3'b011:					// V_BACK
        if (v_cry_back == 1'b1) begin
          v_count_reg <= 11'd0;
          v_state_reg <= 3'b100;
        end else
          v_count_reg <= v_count_reg + 11'd1;

      3'b100:					// V_ACTIVE
        if (v_cry_active == 1'b1) begin
          v_count_reg <= 11'd0;
          v_state_reg <= 3'b001;
        end else
          v_count_reg <= v_count_reg + 11'd1;

      default: begin
        v_count_reg <= 11'b0;
        v_state_reg <= 3'b000;
      end
    endcase
  end
end

assign v_cry_active = (v_count_reg == V_ACTIVE);
assign v_cry_front  = (v_count_reg == V_FRONT);
assign v_cry_sync   = (v_count_reg == V_SYNC);
assign v_cry_back   = (v_count_reg == V_BACK);

assign v_front  = (v_state_reg == 3'b001);
assign v_sync   = (v_state_reg == 3'b010);
assign v_back   = (v_state_reg == 3'b011);
assign v_active = (v_state_reg == 3'b100);
assign v_count  = (v_state_reg == 3'b100 ?  v_count_reg[9:0] : 10'b0);

assign v_end = (v_state_reg == 3'b100 && v_cry_active == 1'b1 && h_end == 1'b1 && h_cry_pre == 1'b1);

assign sp_v_count = (v_state_reg == 3'b011 && v_cry_back == 1'b1 ? 10'd0 : v_count + 10'd1);
assign sp_v_active = (v_state_reg == 3'b011 && v_cry_back == 1'b1 ) |
       		     (v_state_reg == 3'b100 && v_cry_active == 1'b0);

endmodule

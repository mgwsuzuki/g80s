// -*- text -*-
`timescale 1ns/1ps

module cv_timing_tb;

reg         clk;
reg         reset;

wire        h_front;
wire        h_sync;
wire        h_back;
wire        h_preamble;
wire        h_guard;
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

wire  [9:0] hh_count;
wire        hh_en;

parameter STEP = 10;

////////////////////////////////////////

cv_timing # (
  .H_PRE    (1),
  .H_ACTIVE (127),	// 64
  .H_FRONT  (7),	// 4
  .H_SYNC   (19),	// 10
  .H_BACK   (27),	// 14
  .V_ACTIVE (47),
  .V_FRONT  (3),
  .V_SYNC   (7),
  .V_BACK   (3)) c0 (
  .clk        (clk),
  .reset      (reset),
  .cs         (1'b1),
  .h_front    (h_front),
  .h_sync     (h_sync),
  .h_back     (h_back),
  .h_preamble (h_preamble),
  .h_guard    (h_guard),
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
always
begin
  clk = 1'b0; #(STEP/2);
  clk = 1'b1; #(STEP/2);
end

initial
begin
  reset = 1'b1; #(STEP*2);
  forever begin
    reset = 1'b0; #(STEP * 10000000);
  end
end

assign hh_count = h_count[10:1];
assign hh_en = h_active & (h_count[0] == 1'b0);

endmodule

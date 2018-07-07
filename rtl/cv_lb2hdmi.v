// -*- text -*-
`timescale 1 ns / 1 ps

module cv_lb2hdmi (
  input         clk,
  input         reset,

  input         h_en,
  input         h_sync,
  input		h_active,
  input	  [9:0]	h_count,
  input	  	v_sync,
  input         v_active,

  output  [9:0] l_rdaddr,
  output        l_ren,
  input  [63:0] l_rddata,

  output  [9:0] hdmi_r,
  output  [9:0] hdmi_g,
  output  [9:0] hdmi_b
);

wire [15:0] pixel_out;

reg   [7:0] v_sync_reg;
reg   [7:0] h_sync_reg;
reg   [7:0] v_active_reg;
reg   [7:0] h_active_reg;
reg   [7:0] h_en_reg;

wire  [9:0] ctrl_encout_r;
wire  [9:0] ctrl_encout_g;
wire  [9:0] ctrl_encout_b;

wire  [9:0] data_encout_r;
wire  [9:0] data_encout_g;
wire  [9:0] data_encout_b;

reg   [9:0] hdmi_r_reg;
reg   [9:0] hdmi_g_reg;
reg   [9:0] hdmi_b_reg;

////////////////////////////////////////
cv_lb2hdmi_read read0 (
  .clk          (clk),
  .reset        (reset),

  .h_en         (h_en),
  .h_active     (h_active),
  .h_count      (h_count),
  .v_active     (v_active),

  .l_rdaddr     (l_rdaddr),
  .l_ren        (l_ren),
  .l_rddata     (l_rddata),

  .pixel_out    (pixel_out)
);

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    v_sync_reg   <= 8'b0;
    h_sync_reg   <= 8'b0;
    v_active_reg <= 8'b0;
    h_active_reg <= 8'b0;
    h_en_reg     <= 8'b0;
  end else begin
    v_sync_reg   <= {v_sync_reg[6:0], v_sync};
    h_sync_reg   <= {h_sync_reg[6:0], h_sync};
    v_active_reg <= {v_active_reg[6:0], v_active};
    h_active_reg <= {h_active_reg[6:0], h_active};
    h_en_reg     <= {h_en_reg[6:0], h_en};
  end
end

////////////////////////////////////////
cv_2b10b b2b10b (
  .din  ({v_sync_reg[7], h_sync_reg[7]}),
  .dout (ctrl_encout_b));

cv_2b10b b2b10g (
  .din  (2'b00),
  .dout (ctrl_encout_g));

cv_2b10b b2b10r (
  .din  (2'b00),
  .dout (ctrl_encout_r));

////////////////////////////////////////
cv_dataencp denc0 (
  .clk    (clk),
  .reset  (reset),
  .cs     (v_active_reg[4]),
  .din    ({pixel_out[14:10], 3'b0}),
  .din_en (h_en_reg[4]),
  .dout   (data_encout_r),
  .dout_en());

cv_dataencp denc1 (
  .clk    (clk),
  .reset  (reset),
  .cs     (v_active_reg[4]),
  .din    ({pixel_out[9:5], 3'b0}),
  .din_en (h_en_reg[4]),
  .dout   (data_encout_g),
  .dout_en());

cv_dataencp denc2 (
  .clk    (clk),
  .reset  (reset),
  .cs     (v_active_reg[4]),
  .din    ({pixel_out[4:0], 3'b0}),
  .din_en (h_en_reg[4]),
  .dout   (data_encout_b),
  .dout_en());

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    hdmi_b_reg <= 1'b0;
    hdmi_g_reg <= 1'b0;
    hdmi_r_reg <= 1'b0;
  end else if (h_en_reg[7] == 1'b1) begin
    hdmi_b_reg <= (h_active_reg[7] == 1'b1 ? data_encout_b : ctrl_encout_b);
    hdmi_g_reg <= (h_active_reg[7] == 1'b1 ? data_encout_g : ctrl_encout_g);
    hdmi_r_reg <= (h_active_reg[7] == 1'b1 ? data_encout_r : ctrl_encout_r);
  end
end

assign hdmi_b = hdmi_b_reg;
assign hdmi_g = hdmi_g_reg;
assign hdmi_r = hdmi_r_reg;

endmodule

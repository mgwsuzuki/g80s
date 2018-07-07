// -*- text -*-
`timescale 1 ns / 1 ps

module oserdese2_10b (
  input       clk,
  input       clkdiv,
  input       reset,
  input [9:0] din,
  output      dout
);

////////////////////////////////////////
wire shift0;
wire shift1;

////////////////////////////////////////

OSERDESE2 # (
  .DATA_RATE_OQ       ("DDR"),		// default
  .DATA_RATE_TQ       ("SDR"),		// default
  .DATA_WIDTH         (10),
  .SERDES_MODE        ("MASTER"),	// default
  .TRISTATE_WIDTH     (1),		// default
  .TBYTE_CTL          ("FALSE"),	// default
  .TBYTE_SRC          ("FALSE")		// default
) c0 (
  .OFB       (),
  .OQ        (dout),
  .SHIFTOUT1 (),
  .SHIFTOUT2 (),
  .TBYTEOUT  (),
  .TFB       (),
  .TQ        (),

  .CLK       (clk),
  .CLKDIV    (clkdiv),
  .D1        (din[0]),
  .D2        (din[1]),
  .D3        (din[2]),
  .D4        (din[3]),
  .D5        (din[4]),
  .D6        (din[5]),
  .D7        (din[6]),
  .D8        (din[7]),
  .OCE       (1'b1),
  .RST       (reset),
  .SHIFTIN1  (shift0),
  .SHIFTIN2  (shift1),
  .T1        (1'b0),
  .T2        (1'b0),
  .T3        (1'b0),
  .T4        (1'b0),
  .TBYTEIN   (1'b0),
  .TCE       (1'b0)
);

OSERDESE2 # (
  .DATA_RATE_OQ       ("DDR"),		// default
  .DATA_RATE_TQ       ("SDR"),		// default
  .DATA_WIDTH         (10),
  .SERDES_MODE        ("SLAVE"),	// default
  .TRISTATE_WIDTH     (1),		// default
  .TBYTE_CTL          ("FALSE"),	// default
  .TBYTE_SRC          ("FALSE")		// default
) c1 (
  .OFB       (),
  .OQ        (),
  .SHIFTOUT1 (shift0),
  .SHIFTOUT2 (shift1),
  .TBYTEOUT  (),
  .TFB       (),
  .TQ        (),

  .CLK       (clk),
  .CLKDIV    (clkdiv),
  .D1        (1'b0),
  .D2        (1'b0),
  .D3        (din[8]),
  .D4        (din[9]),
  .D5        (1'b0),
  .D6        (1'b0),
  .D7        (1'b0),
  .D8        (1'b0),
  .OCE       (1'b1),
  .RST       (reset),
  .SHIFTIN1  (1'b0),
  .SHIFTIN2  (1'b0),
  .T1        (1'b0),
  .T2        (1'b0),
  .T3        (1'b0),
  .T4        (1'b0),
  .TBYTEIN   (1'b0),
  .TCE       (1'b0)
);


endmodule

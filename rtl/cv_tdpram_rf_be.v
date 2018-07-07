// -*- text -*-
`timescale 1 ns / 1 ps

////////////////////////////////////////////////////////////
////
//// true 2port ram with byte-wide write enable
////
module cv_tdpram_rf_be # (
  parameter A_WIDTH = 10)
(
  // port0
  input                    clk0,
  input      [A_WIDTH-1:0] addr0,
  input                    en0,
  input              [3:0] we0,
  input             [31:0] wrdata0,
  output            [31:0] rddata0,

  // port1
  input                    clk1,
  input      [A_WIDTH-1:0] addr1,
  input                    en1,
  input              [3:0] we1,
  input             [31:0] wrdata1,
  output            [31:0] rddata1
);

////////////////////////////////////////////////////////////

reg         [31:0] mem [2**A_WIDTH-1:0] /* synthesis syn_ramstyle="no_rw_check" */; 
reg         [31:0] rddata0_reg;
reg         [31:0] rddata1_reg;

always @(posedge clk0)
begin   
  if (en0) begin
    if (we0[0]) mem[addr0][7:0]   <= wrdata0[7:0];
    if (we0[1]) mem[addr0][15:8]  <= wrdata0[15:8];
    if (we0[2]) mem[addr0][23:16] <= wrdata0[23:16];
    if (we0[3]) mem[addr0][31:24] <= wrdata0[31:24];
    rddata0_reg <= mem[addr0];
  end
end

assign rddata0 = rddata0_reg;

always @(posedge clk1)
begin   
  if (en1) begin
    if (we1[0]) mem[addr1][7:0]   <= wrdata1[7:0];
    if (we1[1]) mem[addr1][15:8]  <= wrdata1[15:8];
    if (we1[2]) mem[addr1][23:16] <= wrdata1[23:16];
    if (we1[3]) mem[addr1][31:24] <= wrdata1[31:24];
    rddata1_reg <= mem[addr1];
  end
end

assign rddata1 = rddata1_reg;

endmodule

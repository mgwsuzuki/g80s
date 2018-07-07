// -*- text -*-
`timescale 1 ns / 1 ps

////////////////////////////////////////////////////////////
////
//// true 2port ram with byte-wide write enable
//// data bit witdh: 10
////
module cv_tdpram_rf_d10 # (
  parameter A_WIDTH = 10)
(
  // port0
  input                    clk0,
  input      [A_WIDTH-1:0] addr0,
  input                    en0,
  input              [1:0] we0,
  input              [9:0] wrdata0,
  output             [9:0] rddata0,

  // port1
  input                    clk1,
  input      [A_WIDTH-1:0] addr1,
  input                    en1,
  input              [1:0] we1,
  input              [9:0] wrdata1,
  output             [9:0] rddata1
);

////////////////////////////////////////////////////////////

reg  [9:0] mem [2**A_WIDTH-1:0] /* synthesis syn_ramstyle="no_rw_check" */; 
reg  [9:0] rddata0_reg;
reg  [9:0] rddata1_reg;

always @(posedge clk0)
begin   
  if (en0) begin
    if (we0[0]) mem[addr0][7:0] <= wrdata0[7:0];
    if (we0[1]) mem[addr0][9:8] <= wrdata0[9:8];
    rddata0_reg <= mem[addr0];
  end
end

assign rddata0 = rddata0_reg;

always @(posedge clk1)
begin   
  if (en1) begin
    if (we1[0]) mem[addr1][7:0] <= wrdata1[7:0];
    if (we1[1]) mem[addr1][9:8] <= wrdata1[9:8];
    rddata1_reg <= mem[addr1];
  end
end

assign rddata1 = rddata1_reg;

endmodule

// -*- text -*-
`timescale 1 ns / 1 ps

////////////////////////////////////////////////////////////
////
//// true 2port ram (read-first-mode)
//// with data forwarding
////
module cv_tdpram_rf # (
  parameter D_WIDTH = 8,
  parameter A_WIDTH = 10)
(
  // port0
  input                    clk0,
  input      [A_WIDTH-1:0] addr0,
  input                    wen0,
  input                    ren0,
  input      [D_WIDTH-1:0] wrdata0,
  output     [D_WIDTH-1:0] rddata0,

  // port1
  input                    clk1,
  input      [A_WIDTH-1:0] addr1,
  input                    wen1,
  input                    ren1,
  input      [D_WIDTH-1:0] wrdata1,
  output     [D_WIDTH-1:0] rddata1
);

////////////////////////////////////////////////////////////

reg  [D_WIDTH-1:0] mem [2**A_WIDTH-1:0] /* synthesis syn_ramstyle="no_rw_check" */; 
reg  [D_WIDTH-1:0] rddata0_reg;
reg  [D_WIDTH-1:0] rddata1_reg;

reg  [A_WIDTH-1:0] rdaddr0_reg;
reg  [A_WIDTH-1:0] rdaddr1_reg;
reg  [A_WIDTH-1:0] wraddr0_reg;
reg  [A_WIDTH-1:0] wraddr1_reg;
reg  [D_WIDTH-1:0] wrdata0_reg;
reg  [D_WIDTH-1:0] wrdata1_reg;

wire               en0;
wire               en1;

assign en0 = ren0 | wen0;

always @(posedge clk0)
begin   
  if (en0) begin
    if (wen0)
      mem[addr0] <= wrdata0;
    rddata0_reg <= mem[addr0];
    rdaddr0_reg <= addr0;
  end
end

assign rddata0 = (rdaddr0_reg == wraddr1_reg ? wrdata1_reg : rddata0_reg);


assign en1 = ren1 | wen1;

always @(posedge clk1)
begin   
  if (en1) begin
    if (wen1)
      mem[addr1] <= wrdata1;
    rddata1_reg <= mem[addr1];
    rdaddr1_reg <= addr1;
  end
end

assign rddata1 = (rdaddr1_reg == wraddr0_reg ? wrdata0_reg : rddata1_reg);

always @(posedge clk1)
begin
  if (wen0) begin
    wraddr0_reg <= addr0;
    wrdata0_reg <= wrdata0;
  end
  if (wen1) begin
    wraddr1_reg <= addr1;
    wrdata1_reg <= wrdata1;
  end
end

endmodule

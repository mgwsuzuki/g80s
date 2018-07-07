// -*- text -*-
`timescale 1 ns / 1 ps

module cv_linebuf (
  input         clk,
  input         reset,

  input   [9:0] sp_rdaddr0,
  input   [9:0] sp_rdaddr1,
  input   [9:0] sp_rdaddr2,
  input   [9:0] sp_rdaddr3,
  input         sp_ren,
  output [63:0] sp_rddata,
  input   [9:0] sp_wraddr0,
  input   [9:0] sp_wraddr1,
  input   [9:0] sp_wraddr2,
  input   [9:0] sp_wraddr3,
  input         sp_wen0,
  input         sp_wen1,
  input         sp_wen2,
  input         sp_wen3,
  input  [63:0] sp_wrdata,
  input         sp_v_count_lsb,
  input   [9:0] pix_rdaddr,
  input         pix_ren,
  output [63:0] pixdata
);

wire  [9:0] mem00_rdaddr;
wire  [9:0] mem01_rdaddr;
wire  [9:0] mem02_rdaddr;
wire  [9:0] mem03_rdaddr;
wire        mem0_ren;
wire  [9:0] mem00_wraddr;
wire  [9:0] mem01_wraddr;
wire  [9:0] mem02_wraddr;
wire  [9:0] mem03_wraddr;
wire        mem00_wen;
wire        mem01_wen;
wire        mem02_wen;
wire        mem03_wen;
wire [15:0] mem00_rddata;
wire [15:0] mem01_rddata;
wire [15:0] mem02_rddata;
wire [15:0] mem03_rddata;
wire [15:0] mem00_wrdata;
wire [15:0] mem01_wrdata;
wire [15:0] mem02_wrdata;
wire [15:0] mem03_wrdata;

wire  [9:0] mem10_rdaddr;
wire  [9:0] mem11_rdaddr;
wire  [9:0] mem12_rdaddr;
wire  [9:0] mem13_rdaddr;
wire        mem1_ren;
wire  [9:0] mem10_wraddr;
wire  [9:0] mem11_wraddr;
wire  [9:0] mem12_wraddr;
wire  [9:0] mem13_wraddr;
wire        mem10_wen;
wire        mem11_wen;
wire        mem12_wen;
wire        mem13_wen;
wire [15:0] mem10_rddata;
wire [15:0] mem11_rddata;
wire [15:0] mem12_rddata;
wire [15:0] mem13_rddata;
wire [15:0] mem10_wrdata;
wire [15:0] mem11_wrdata;
wire [15:0] mem12_wrdata;
wire [15:0] mem13_wrdata;

reg         sp_v_count_lsb_reg;
reg   [9:0] pix_rdaddr_reg;
reg         pix_ren_reg;

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    pix_rdaddr_reg      <= 10'b00;
    pix_ren_reg         <= 1'b0;
    sp_v_count_lsb_reg  <= 1'b0;
  end else begin
    pix_rdaddr_reg      <= pix_rdaddr;
    pix_ren_reg         <= pix_ren;
    sp_v_count_lsb_reg  <= sp_v_count_lsb;
  end
end


assign mem00_rdaddr = (sp_v_count_lsb == 1'b1 ? pix_rdaddr  : sp_rdaddr0);
assign mem01_rdaddr = (sp_v_count_lsb == 1'b1 ? pix_rdaddr  : sp_rdaddr1);
assign mem02_rdaddr = (sp_v_count_lsb == 1'b1 ? pix_rdaddr  : sp_rdaddr2);
assign mem03_rdaddr = (sp_v_count_lsb == 1'b1 ? pix_rdaddr  : sp_rdaddr3);
assign mem0_ren     = (sp_v_count_lsb == 1'b1 ? pix_ren     : sp_ren);
assign mem10_rdaddr = (sp_v_count_lsb == 1'b0 ? pix_rdaddr  : sp_rdaddr0);
assign mem11_rdaddr = (sp_v_count_lsb == 1'b0 ? pix_rdaddr  : sp_rdaddr1);
assign mem12_rdaddr = (sp_v_count_lsb == 1'b0 ? pix_rdaddr  : sp_rdaddr2);
assign mem13_rdaddr = (sp_v_count_lsb == 1'b0 ? pix_rdaddr  : sp_rdaddr3);
assign mem1_ren     = (sp_v_count_lsb == 1'b0 ? pix_ren     : sp_ren);

assign mem00_wraddr = (sp_v_count_lsb == 1'b1 ? pix_rdaddr_reg : sp_wraddr0);
assign mem01_wraddr = (sp_v_count_lsb == 1'b1 ? pix_rdaddr_reg : sp_wraddr1);
assign mem02_wraddr = (sp_v_count_lsb == 1'b1 ? pix_rdaddr_reg : sp_wraddr2);
assign mem03_wraddr = (sp_v_count_lsb == 1'b1 ? pix_rdaddr_reg : sp_wraddr3);
assign mem00_wen    = (sp_v_count_lsb == 1'b1 ? pix_ren_reg    : sp_wen0);
assign mem01_wen    = (sp_v_count_lsb == 1'b1 ? pix_ren_reg    : sp_wen1);
assign mem02_wen    = (sp_v_count_lsb == 1'b1 ? pix_ren_reg    : sp_wen2);
assign mem03_wen    = (sp_v_count_lsb == 1'b1 ? pix_ren_reg    : sp_wen3);
assign mem00_wrdata = (sp_v_count_lsb == 1'b1 ? 16'h8000 : sp_wrdata[15:0]);
assign mem01_wrdata = (sp_v_count_lsb == 1'b1 ? 16'h8000 : sp_wrdata[31:16]);
assign mem02_wrdata = (sp_v_count_lsb == 1'b1 ? 16'h8000 : sp_wrdata[47:32]);
assign mem03_wrdata = (sp_v_count_lsb == 1'b1 ? 16'h8000 : sp_wrdata[63:48]);
assign mem10_wraddr = (sp_v_count_lsb == 1'b0 ? pix_rdaddr_reg : sp_wraddr0);
assign mem11_wraddr = (sp_v_count_lsb == 1'b0 ? pix_rdaddr_reg : sp_wraddr1);
assign mem12_wraddr = (sp_v_count_lsb == 1'b0 ? pix_rdaddr_reg : sp_wraddr2);
assign mem13_wraddr = (sp_v_count_lsb == 1'b0 ? pix_rdaddr_reg : sp_wraddr3);
assign mem10_wen    = (sp_v_count_lsb == 1'b0 ? pix_ren_reg    : sp_wen0);
assign mem11_wen    = (sp_v_count_lsb == 1'b0 ? pix_ren_reg    : sp_wen1);
assign mem12_wen    = (sp_v_count_lsb == 1'b0 ? pix_ren_reg    : sp_wen2);
assign mem13_wen    = (sp_v_count_lsb == 1'b0 ? pix_ren_reg    : sp_wen3);
assign mem10_wrdata = (sp_v_count_lsb == 1'b0 ? 16'h8000 : sp_wrdata[15:0]);
assign mem11_wrdata = (sp_v_count_lsb == 1'b0 ? 16'h8000 : sp_wrdata[31:16]);
assign mem12_wrdata = (sp_v_count_lsb == 1'b0 ? 16'h8000 : sp_wrdata[47:32]);
assign mem13_wrdata = (sp_v_count_lsb == 1'b0 ? 16'h8000 : sp_wrdata[63:48]);

////////////////////////////////////////
//// line buffer0
cv_tdpram_rf # (
  .D_WIDTH (16),
  .A_WIDTH (10)) mem00 (
  // port0
  .clk0    (clk),
  .addr0   (mem00_rdaddr),
  .wen0    (1'b0),
  .ren0    (mem0_ren),
  .wrdata0 (16'b0),
  .rddata0 (mem00_rddata),

  // port1
  .clk1    (clk),
  .addr1   (mem00_wraddr),
  .wen1    (mem00_wen),
  .ren1    (1'b0),
  .wrdata1 (mem00_wrdata),
  .rddata1 ()
);

cv_tdpram_rf # (
  .D_WIDTH (16),
  .A_WIDTH (10)) mem01 (
  // port0
  .clk0    (clk),
  .addr0   (mem01_rdaddr),
  .wen0    (1'b0),
  .ren0    (mem0_ren),
  .wrdata0 (16'b0),
  .rddata0 (mem01_rddata),

  // port1
  .clk1    (clk),
  .addr1   (mem01_wraddr),
  .wen1    (mem01_wen),
  .ren1    (1'b0),
  .wrdata1 (mem01_wrdata),
  .rddata1 ()
);

cv_tdpram_rf # (
  .D_WIDTH (16),
  .A_WIDTH (10)) mem02 (
  // port0
  .clk0    (clk),
  .addr0   (mem02_rdaddr),
  .wen0    (1'b0),
  .ren0    (mem0_ren),
  .wrdata0 (16'b0),
  .rddata0 (mem02_rddata),

  // port1
  .clk1    (clk),
  .addr1   (mem02_wraddr),
  .wen1    (mem02_wen),
  .ren1    (1'b0),
  .wrdata1 (mem02_wrdata),
  .rddata1 ()
);

cv_tdpram_rf # (
  .D_WIDTH (16),
  .A_WIDTH (10)) mem03 (
  // port0
  .clk0    (clk),
  .addr0   (mem03_rdaddr),
  .wen0    (1'b0),
  .ren0    (mem0_ren),
  .wrdata0 (16'b0),
  .rddata0 (mem03_rddata),

  // port1
  .clk1    (clk),
  .addr1   (mem03_wraddr),
  .wen1    (mem03_wen),
  .ren1    (1'b0),
  .wrdata1 (mem03_wrdata),
  .rddata1 ()
);

////////////////////////////////////////
//// line buffer1
cv_tdpram_rf # (
  .D_WIDTH (16),
  .A_WIDTH (10)) mem4 (
  // port0
  .clk0    (clk),
  .addr0   (mem10_rdaddr),
  .wen0    (1'b0),
  .ren0    (mem1_ren),
  .wrdata0 (16'b0),
  .rddata0 (mem10_rddata),

  // port1
  .clk1    (clk),
  .addr1   (mem10_wraddr),
  .wen1    (mem10_wen),
  .ren1    (1'b0),
  .wrdata1 (mem10_wrdata),
  .rddata1 ()
);

cv_tdpram_rf # (
  .D_WIDTH (16),
  .A_WIDTH (10)) mem5 (
  // port0
  .clk0    (clk),
  .addr0   (mem11_rdaddr),
  .wen0    (1'b0),
  .ren0    (mem1_ren),
  .wrdata0 (16'b0),
  .rddata0 (mem11_rddata),

  // port1
  .clk1    (clk),
  .addr1   (mem11_wraddr),
  .wen1    (mem11_wen),
  .ren1    (1'b0),
  .wrdata1 (mem11_wrdata),
  .rddata1 ()
);

cv_tdpram_rf # (
  .D_WIDTH (16),
  .A_WIDTH (10)) mem6 (
  // port0
  .clk0    (clk),
  .addr0   (mem12_rdaddr),
  .wen0    (1'b0),
  .ren0    (mem1_ren),
  .wrdata0 (16'b0),
  .rddata0 (mem12_rddata),

  // port1
  .clk1    (clk),
  .addr1   (mem12_wraddr),
  .wen1    (mem12_wen),
  .ren1    (1'b0),
  .wrdata1 (mem12_wrdata),
  .rddata1 ()
);

cv_tdpram_rf # (
  .D_WIDTH (16),
  .A_WIDTH (10)) mem7 (
  // port0
  .clk0    (clk),
  .addr0   (mem13_rdaddr),
  .wen0    (1'b0),
  .ren0    (mem1_ren),
  .wrdata0 (16'b0),
  .rddata0 (mem13_rddata),

  // port1
  .clk1    (clk),
  .addr1   (mem13_wraddr),
  .wen1    (mem13_wen),
  .ren1    (1'b0),
  .wrdata1 (mem13_wrdata),
  .rddata1 ()
);

assign sp_rddata = (sp_v_count_lsb_reg == 1'b0 ?
                    {mem03_rddata, mem02_rddata, mem01_rddata, mem00_rddata} :
		    {mem13_rddata, mem12_rddata, mem11_rddata, mem10_rddata});
assign pixdata = (sp_v_count_lsb_reg == 1'b0 ?
		  {mem13_rddata, mem12_rddata, mem11_rddata, mem10_rddata} :
                  {mem03_rddata, mem02_rddata, mem01_rddata, mem00_rddata});

endmodule

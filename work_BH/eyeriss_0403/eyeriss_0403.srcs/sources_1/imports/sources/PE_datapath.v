`timescale 1ns / 1ps

module PE_datapath #(
	parameter DATA_BITWIDTH = 16,
	parameter PSUM_BITWIDTH = 32,

	parameter IFMAP_ADDR_BITWIDTH = 4,
	parameter WGHT_ADDR_BITWIDTH = 8,
	parameter PSUM_ADDR_BITWIDTH = 5
)(
	input clk, rst,

	input ctrl_acc_sel,
	input ctrl_rst_psum,

	input [IFMAP_ADDR_BITWIDTH-1:0] ctrl_ifmap_ra,
	input [WGHT_ADDR_BITWIDTH-1:0] ctrl_wght_ra,
	input [PSUM_ADDR_BITWIDTH-1:0] ctrl_psum_ra,
	
	input [IFMAP_ADDR_BITWIDTH-1:0] ctrl_ifmap_wa,
	input [WGHT_ADDR_BITWIDTH-1:0]  ctrl_wght_wa,
	input [PSUM_ADDR_BITWIDTH-1:0] ctrl_psum_wa,

	input ctrl_ifmap_we,
	input ctrl_wght_we,
	input ctrl_psum_we,

	input signed [DATA_BITWIDTH-1:0] ifmap_in,
	input signed [DATA_BITWIDTH-1:0] wght_in,
	input signed [PSUM_BITWIDTH-1:0] psum_in,
	
	output signed [PSUM_BITWIDTH-1:0] psum_out
);

	wire signed [DATA_BITWIDTH-1:0] ifmap_rd;
	wire signed [DATA_BITWIDTH-1:0] wght_rd;
	wire signed [PSUM_BITWIDTH-1:0] psum_rd;

	RF #(
		.DATA_BITWIDTH(DATA_BITWIDTH),
		.ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH)
	) ifmap_RF (
		.clk(clk),
		.rst(rst),
		.ra(ctrl_ifmap_ra),
		.rd(ifmap_rd),
		.we(ctrl_ifmap_we),
		.wa(ctrl_ifmap_wa),
		.wd(ifmap_in)
	);

	SPad #(
		.DATA_BITWIDTH(DATA_BITWIDTH),
		.ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
	) spad_weight ( 
		.clk(clk), 
		.rst(rst), 
		.re(1'b1),
		.ra(ctrl_wght_ra),
		.rd(wght_rd),
		.we(ctrl_wght_we),
		.wa(ctrl_wght_wa),
		.wd(wght_in)
	);

	RF #(
		.DATA_BITWIDTH(PSUM_BITWIDTH),
		.ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
	) psum_RF (
		.clk(clk),
		.rst(rst),
		.ra(ctrl_psum_ra),
		.rd(psum_rd),
		.we(ctrl_psum_we),
		.wa(ctrl_psum_wa),
		.wd(psum_out)
	);

	reg [DATA_BITWIDTH-1:0] ifmap_reg;
	wire [PSUM_BITWIDTH-1:0] psum_reg;
	wire [DATA_BITWIDTH-1:0] wght_reg;

	always @(posedge clk) begin
		if(rst) begin
			ifmap_reg <= 0;
		end
		else begin
			ifmap_reg <= ifmap_rd;
		end
	end

	reg ctrl_rst_psum_reg;
	reg ctrl_acc_sel_reg;
	always @(posedge clk) begin
		if(rst) begin
			ctrl_rst_psum_reg <= 0;
			ctrl_acc_sel_reg <= 0;
		end
		else begin
			ctrl_rst_psum_reg <= ctrl_rst_psum;
			ctrl_acc_sel_reg <= ctrl_acc_sel;
		end
	end

	assign wght_reg = wght_rd;
	assign psum_reg = (ctrl_rst_psum_reg) ? 0 : psum_rd;

	
	reg [PSUM_BITWIDTH-1:0] mul_reg;
	always @(posedge clk) begin
		if(rst) begin
			mul_reg <= 0;
		end
		else begin
			mul_reg <= ifmap_reg * wght_reg;
		end
	end

	reg [PSUM_BITWIDTH-1:0] mul_reg_d;
	always @(posedge clk) begin
		if(rst) begin
			mul_reg_d <= 0;
		end
		else begin
			mul_reg_d <= mul_reg;
		end
	end

	assign psum_out = psum_reg + ((ctrl_acc_sel_reg) ? psum_in : mul_reg);

endmodule
`timescale 1ns / 1ps

module PE_datapath #(
	parameter DATA_BITWIDTH = 16,

	parameter IFMAP_ADDR_BITWIDTH = 4,
	parameter WGHT_ADDR_BITWIDTH = 8,
	parameter PSUM_ADDR_BITWIDTH = 5
)(
	input i_clk, i_rst,

	//input, output data
	input signed [DATA_BITWIDTH-1:0] i_ifmap,
	input signed [DATA_BITWIDTH-1:0] i_wght,
	input signed [DATA_BITWIDTH-1:0] i_psum,
	output signed [DATA_BITWIDTH-1:0] o_psum,

	//controller interface
	input i_acc_sel,
	input i_rst_psum,

	input [IFMAP_ADDR_BITWIDTH-1:0] i_ifmap_ra,
	input [WGHT_ADDR_BITWIDTH-1:0] i_wght_ra,
	input [PSUM_ADDR_BITWIDTH-1:0] i_psum_ra,
	
	input [IFMAP_ADDR_BITWIDTH-1:0] i_ifmap_wa,
	input [WGHT_ADDR_BITWIDTH-1:0]  i_wght_wa,
	input [PSUM_ADDR_BITWIDTH-1:0] i_psum_wa,

	input i_ifmap_we,
	input i_wght_we,
	input i_psum_we
);

	wire signed [DATA_BITWIDTH-1:0] ifmap_rd;
	wire signed [DATA_BITWIDTH-1:0] wght_rd;
	wire signed [DATA_BITWIDTH-1:0] psum_rd;

	reg [DATA_BITWIDTH-1:0] ifmap_reg, ifmap_reg_d;
	reg [DATA_BITWIDTH-1:0] psum_reg, psum_reg_d, psum_reg_d2 ;
	reg [DATA_BITWIDTH-1:0] wght_reg;

	reg i_acc_sel_reg;
	reg i_rst_psum_reg;

	RF #(
		.DATA_BITWIDTH(DATA_BITWIDTH),
		.ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH)
	) ifmap_RF (
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_ra(i_ifmap_ra),
		.o_rd(ifmap_rd),
		.i_we(i_ifmap_we),
		.i_wa(i_ifmap_wa),
		.i_wd(i_ifmap)
	);

	SPad #(
		.DATA_BITWIDTH(DATA_BITWIDTH),
		.ADDR_BITWIDTH(WGHT_ADDR_BITWIDTH)
	) spad_weight ( 
		.i_clk(i_clk), 
		.i_rst(i_rst), 
		.i_re(1'b1),
		.i_ra(i_wght_ra),
		.o_rd(wght_rd),
		.i_we(i_wght_we),
		.i_wa(i_wght_wa),
		.i_wd(i_wght)
	);

	RF #(
		.DATA_BITWIDTH(DATA_BITWIDTH),
		.ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
	) psum_RF (
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_ra(i_psum_ra),
		.o_rd(psum_rd),
		.i_we(i_psum_we),
		.i_wa(i_psum_wa),
		.i_wd(o_psum)
	);

	always @(posedge i_clk) begin
		if(i_rst) begin
			ifmap_reg <= 0;
			wght_reg <= 0;
			psum_reg <= 0;
			psum_reg_d <= 0;
			psum_reg_d2 <= 0;
			i_acc_sel_reg <= 0;
		end
		else begin
			ifmap_reg <= ifmap_rd;
			ifmap_reg_d <= ifmap_reg;
			wght_reg <= wght_rd;

			psum_reg <= psum_rd;
			psum_reg_d <= (i_rst_psum_reg) ? 0 : psum_reg;
			psum_reg_d2 <= psum_reg_d;

			i_acc_sel_reg <= i_acc_sel;
			i_rst_psum_reg <= i_rst_psum;
		end
	end


	reg [DATA_BITWIDTH-1:0] mul_reg;
	always @(posedge i_clk) begin
		if(i_rst) begin
			mul_reg <= 0;
		end
		else begin
			mul_reg <= ifmap_reg_d * wght_reg;
		end
	end

	assign o_psum = psum_reg_d2 + ((i_acc_sel_reg) ? i_psum : mul_reg);

endmodule
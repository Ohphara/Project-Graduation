`timescale 1ns / 1ps

module tb_PE_datapath;

	parameter DATA_BITWIDTH = 16;
	parameter PSUM_BITWIDTH = 32;

	parameter IFMAP_ADDR_BITWIDTH = 4;
	parameter WGHT_ADDR_BITWIDTH = 8;
	parameter PSUM_ADDR_BITWIDTH = 2;

	reg clk = 0;
	reg rst;

	reg ctrl_acc_sel;
	reg ctrl_rst_psum;

	reg [IFMAP_ADDR_BITWIDTH-1:0] ifmap_ra;
	reg [WGHT_ADDR_BITWIDTH-1:0] wght_ra;
	reg [PSUM_ADDR_BITWIDTH-1:0] psum_ra;

	reg [IFMAP_ADDR_BITWIDTH-1:0] ifmap_wa;
	reg [WGHT_ADDR_BITWIDTH-1:0]  wght_wa;
	reg [PSUM_ADDR_BITWIDTH-1:0] psum_wa;

	reg ifmap_we, wght_we, psum_we;

	reg signed [DATA_BITWIDTH-1:0] ifmap_in;
	reg signed [DATA_BITWIDTH-1:0] wght_in;
	reg signed [PSUM_BITWIDTH-1:0] psum_in;

	wire signed [PSUM_BITWIDTH-1:0] psum_out;

	PE_datapath #(
		.DATA_BITWIDTH(DATA_BITWIDTH),
		.PSUM_BITWIDTH(PSUM_BITWIDTH),
		.IFMAP_ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH),
		.WGHT_ADDR_BITWIDTH(WGHT_ADDR_BITWIDTH),
		.PSUM_ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
	) uut (
		.clk(clk),
		.rst(rst),
		.ctrl_acc_sel(ctrl_acc_sel),
		.ctrl_rst_psum(ctrl_rst_psum),
		.ifmap_ra(ifmap_ra),
		.wght_ra(wght_ra),
		.psum_ra(psum_ra),
		.ifmap_wa(ifmap_wa),
		.wght_wa(wght_wa),
		.psum_wa(psum_wa),
		.ifmap_we(ifmap_we),
		.wght_we(wght_we),
		.psum_we(psum_we),
		.ifmap_in(ifmap_in),
		.wght_in(wght_in),
		.psum_in(psum_in),
		.psum_out(psum_out)
	);

	always #5 clk = ~clk; // 10ns clock period

    integer i;
	initial begin
		$display("Start Testbench");

		// Reset
		rst = 1;
		ctrl_acc_sel = 0;
		ctrl_rst_psum = 0;
		ifmap_we = 0;
		wght_we = 0;
		psum_we = 0;
		ifmap_in = 0;
		wght_in = 0;
		psum_in = 0;
		#20;
		rst = 0;

		// Load ifmap: [1,2,3,4,5]
		for (i = 0; i < 5; i = i + 1) begin
			ifmap_wa = i;
			ifmap_in = i + 1;
			ifmap_we = 1;
			#10;
		end
		ifmap_we = 0;

		// Load weight: [1, 2, 3]
		for (i = 0; i < 3; i = i + 1) begin
			wght_wa = i;
			wght_in = (i == 0) ? 1 : (i == 1) ? 2 : 3;
			wght_we = 1;
			#10;
		end
		wght_we = 0;

		#10;
		ctrl_acc_sel = 0;
		psum_ra = 0;
		psum_wa = 0;
		psum_we = 0;
		#10;
		// Convolution (3 cycles)
		for (i = 0; i < 3; i = i + 1) begin
			ctrl_rst_psum = 0;
			ctrl_acc_sel = (i==0) ? 0 : 1;
			ifmap_ra = i;
			wght_ra = 0;
			psum_we = (i==0) ? 0 : 1;
			#10;
			ctrl_rst_psum = 1;
			ctrl_acc_sel = 0;
			ifmap_ra = i + 1;
			wght_ra = 1;
			psum_we = 1;
			#10;
			ctrl_rst_psum = 0;
			ctrl_acc_sel = 0;
			ifmap_ra = i + 2;
			wght_ra = 2;
			psum_we = 1;
			#10;
			ctrl_rst_psum = 0;
			ctrl_acc_sel = 0;
			psum_in = i+10;
			psum_we = 1;
			#10;
		end

		#50;
		$display("Finish Simulation");
		$finish;
	end
endmodule
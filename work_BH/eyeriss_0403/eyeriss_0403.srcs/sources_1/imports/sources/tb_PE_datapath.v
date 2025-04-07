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

	reg [IFMAP_ADDR_BITWIDTH-1:0] ctrl_ifmap_ra;
	reg [WGHT_ADDR_BITWIDTH-1:0] ctrl_wght_ra;
	reg [PSUM_ADDR_BITWIDTH-1:0] ctrl_psum_ra;

	reg [IFMAP_ADDR_BITWIDTH-1:0] ctrl_ifmap_wa;
	reg [WGHT_ADDR_BITWIDTH-1:0]  ctrl_wght_wa;
	reg [PSUM_ADDR_BITWIDTH-1:0] ctrl_psum_wa;

	reg ctrl_ifmap_we, ctrl_wght_we, ctrl_psum_we;

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
		.ctrl_ifmap_ra(ctrl_ifmap_ra),
		.ctrl_wght_ra(ctrl_wght_ra),
		.ctrl_psum_ra(ctrl_psum_ra),
		.ctrl_ifmap_wa(ctrl_ifmap_wa),
		.ctrl_wght_wa(ctrl_wght_wa),
		.ctrl_psum_wa(ctrl_psum_wa),
		.ctrl_ifmap_we(ctrl_ifmap_we),
		.ctrl_wght_we(ctrl_wght_we),
		.ctrl_psum_we(ctrl_psum_we),
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
		ctrl_ifmap_we = 0;
		ctrl_wght_we = 0;
		ctrl_psum_we = 0;
		ifmap_in = 0;
		wght_in = 0;
		psum_in = 0;
		#20;
		rst = 0;

		// Load ifmap: [1,2,3,4,5]
		for (i = 0; i < 5; i = i + 1) begin
			ctrl_ifmap_wa = i;
			ifmap_in = i + 1;
			ctrl_ifmap_we = 1;
			#10;
		end
		ctrl_ifmap_we = 0;

		// Load weight: [1, 2, 3]
		for (i = 0; i < 3; i = i + 1) begin
			ctrl_wght_wa = i;
			wght_in = (i == 0) ? 1 : (i == 1) ? 2 : 3;
			ctrl_wght_we = 1;
			#10;
		end
		ctrl_wght_we = 0;

		#10;
		ctrl_acc_sel = 0;
		ctrl_psum_ra = 0;
		ctrl_psum_wa = 0;
		ctrl_psum_we = 0;
		#10;
		// Convolution (3 cycles)
		for (i = 0; i < 3; i = i + 1) begin
			ctrl_rst_psum = 0;
			ctrl_acc_sel = (i==0) ? 0 : 1;
			ctrl_ifmap_ra = i;
			ctrl_wght_ra = 0;
			ctrl_psum_we = (i==0) ? 0 : 1;
			#10;
			ctrl_rst_psum = 1;
			ctrl_acc_sel = 0;
			ctrl_ifmap_ra = i + 1;
			ctrl_wght_ra = 1;
			ctrl_psum_we = 1;
			#10;
			ctrl_rst_psum = 0;
			ctrl_acc_sel = 0;
			ctrl_ifmap_ra = i + 2;
			ctrl_wght_ra = 2;
			ctrl_psum_we = 1;
			#10;
			ctrl_rst_psum = 0;
			ctrl_acc_sel = 0;
			psum_in = i+10;
			ctrl_psum_we = 1;
			#10;
		end

		#50;
		$display("Finish Simulation");
		$finish;
	end
endmodule
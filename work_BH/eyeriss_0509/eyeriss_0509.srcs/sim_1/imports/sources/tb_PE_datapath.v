`timescale 1ns / 1ps

module tb_PE_datapath;

	parameter DATA_BITWIDTH = 16;
	parameter PSUM_BITWIDTH = 32;

	parameter IFMAP_ADDR_BITWIDTH = 4;
	parameter WGHT_ADDR_BITWIDTH = 8;
	parameter PSUM_ADDR_BITWIDTH = 5;

    parameter P = 6;
    parameter Q = 4;
    parameter S = 3;

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

	reg [DATA_BITWIDTH-1:0] ifmap_in;
	reg [DATA_BITWIDTH-1:0] wght_in;
	reg [PSUM_BITWIDTH-1:0] psum_in;

	wire [PSUM_BITWIDTH-1:0] psum_out;

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

    integer i, j, k;
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

		repeat (10) @(negedge clk);
		rst = 0;

//////////////////////////////////////////////////////////

		// Load ifmap
		// [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
		for (i = 0; i < Q; i = i + 1) begin
			for (j = 0; j < S; j = j + 1) begin
				ctrl_ifmap_wa = (i * S) + j;
				ifmap_in = j + 1;
				ctrl_ifmap_we = 1;
				@(negedge clk);
			end
		end
		ctrl_ifmap_we = 0;

		// Load weight in a vertical order
		// [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
		// [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
		// [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
		// [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
		// [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
		// [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
		for (i = 0; i < Q; i = i + 1) begin
			for(j = 0; j < S; j = j + 1) begin
				for (k = 0; k < P; k = k + 1) begin
					ctrl_wght_wa = (i * S) + j + (k * Q * S);
					wght_in = j + 1;
					ctrl_wght_we = 1;
					@(negedge clk);
				end
			end
		end
		ctrl_wght_we = 0;

//////////////////////////////////////////////////////////

		repeat (10) @(negedge clk);

		// Convolution
		for (i = 0; i < Q; i = i + 1) begin
			for (j = 0; j < S; j = j + 1) begin
				for (k = 0; k < P; k = k + 1) begin
					@(negedge clk);
					ctrl_ifmap_ra = (i * S) + j;
					ctrl_wght_ra = (i * S) + j + (k * Q * S);
					ctrl_psum_ra = k;
					ctrl_psum_wa = (i==0 && j==0 && k<3) ? 0 : (k>=3) ? k-3 : k+3; // 3 cycle delay for valid psum_out
					ctrl_psum_we = (i==0 && j==0 && k<3) ? 0 : 1; // 3 cycle delay for valid psum_out
					ctrl_rst_psum = 0;
					ctrl_acc_sel = 0;
				end
			end
		end
		for (i = 0; i < 3; i = i + 1) begin
			@(negedge clk);
			ctrl_psum_wa = i + 3;
			ctrl_psum_we = 1;
		end
		@(negedge clk);
		ctrl_psum_we = 0;

//////////////////////////////////////////////////////////

		// Psum Accumulation
		for (i = 0; i < 6; i = i + 1) begin
			@(negedge clk);
			ctrl_psum_ra = i;
			ctrl_acc_sel = (i==0) ? 0 : 1; // 1 cycle delay
			psum_in = 10;
		end
		@(negedge clk);
		ctrl_acc_sel = 1;
		@(negedge clk);
		ctrl_acc_sel = 0;
		

//////////////////////////////////////////////////////////

		repeat (10) @(negedge clk);

		// Reset Accumulation without psum_in
		for (i = 0; i < 3; i = i + 1) begin
			@(negedge clk);
			psum_in = 0;
			ctrl_acc_sel = 1;
			ctrl_rst_psum = 1;
		end
		for (i = 0; i < 6; i = i + 1) begin
			@(negedge clk);
			ctrl_psum_wa = i;
			ctrl_psum_we = 1;
		end

		@(negedge clk);
		ctrl_rst_psum = 0;
		ctrl_acc_sel = 0;
		ctrl_psum_we = 0;


//////////////////////////////////////////////////////////

		repeat (10) @(negedge clk);

		// Reset Accumulation with psum_in
		for (i = 0; i < 3; i = i + 1) begin
			@(negedge clk);
			psum_in = 10;
			ctrl_acc_sel = 1;
			ctrl_rst_psum = 1;
		end
		for (i = 0; i < 6; i = i + 1) begin
			@(negedge clk);
			ctrl_psum_wa = i;
			ctrl_psum_we = 1;
		end

		@(negedge clk);
		ctrl_rst_psum = 0;
		ctrl_acc_sel = 0;
		ctrl_psum_we = 0;

//////////////////////////////////////////////////////////

		repeat (10) @(negedge clk);

		$display("Finish Simulation");
		$finish;
	end
endmodule
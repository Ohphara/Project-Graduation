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

	reg i_clk = 0;
	reg i_rst;

	reg i_acc_sel;
	reg i_rst_psum;

	reg [IFMAP_ADDR_BITWIDTH-1:0] i_ifmap_ra;
	reg [WGHT_ADDR_BITWIDTH-1:0] i_wght_ra;
	reg [PSUM_ADDR_BITWIDTH-1:0] i_psum_ra;

	reg [IFMAP_ADDR_BITWIDTH-1:0] i_ifmap_wa;
	reg [WGHT_ADDR_BITWIDTH-1:0]  i_wght_wa;
	reg [PSUM_ADDR_BITWIDTH-1:0] i_psum_wa;

	reg i_ifmap_we, i_wght_we, i_psum_we;

	reg [DATA_BITWIDTH-1:0] i_ifmap;
	reg [DATA_BITWIDTH-1:0] i_wght;
	reg [PSUM_BITWIDTH-1:0] i_psum;

	wire [PSUM_BITWIDTH-1:0] psum_out;

	PE_datapath #(
		.DATA_BITWIDTH(DATA_BITWIDTH),
		.PSUM_BITWIDTH(PSUM_BITWIDTH),
		.IFMAP_ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH),
		.WGHT_ADDR_BITWIDTH(WGHT_ADDR_BITWIDTH),
		.PSUM_ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
	) uut (
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_acc_sel(i_acc_sel),
		.i_rst_psum(i_rst_psum),
		.i_ifmap_ra(i_ifmap_ra),
		.i_wght_ra(i_wght_ra),
		.i_psum_ra(i_psum_ra),
		.i_ifmap_wa(i_ifmap_wa),
		.i_wght_wa(i_wght_wa),
		.i_psum_wa(i_psum_wa),
		.i_ifmap_we(i_ifmap_we),
		.i_wght_we(i_wght_we),
		.i_psum_we(i_psum_we),
		.i_ifmap(i_ifmap),
		.i_wght(i_wght),
		.i_psum(i_psum),
		.o_psum(o_psum)
	);

	always #5 i_clk = ~i_clk; // 10ns clock period

    integer i, j, k;
	initial begin
		$display("Start Testbench");

		// Reset
		i_rst = 1;
		i_acc_sel = 0;
		i_rst_psum = 0;
		i_ifmap_we = 0;
		i_wght_we = 0;
		i_psum_we = 0;
		i_ifmap = 0;
		i_wght = 0;
		i_psum = 0;

		repeat (10) @(negedge i_clk);
		i_rst = 0;

//////////////////////////////////////////////////////////

		// Load ifmap
		// [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
		for (i = 0; i < Q; i = i + 1) begin
			for (j = 0; j < S; j = j + 1) begin
				i_ifmap_wa = (i * S) + j;
				i_ifmap = j + 1;
				i_ifmap_we = 1;
				@(negedge i_clk);
			end
		end
		i_ifmap_we = 0;

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
					i_wght_wa = (i * S) + j + (k * Q * S);
					i_wght = j + 1;
					i_wght_we = 1;
					@(negedge i_clk);
				end
			end
		end
		i_wght_we = 0;

//////////////////////////////////////////////////////////

		repeat (10) @(negedge i_clk);

		// Convolution
		for (i = 0; i < Q; i = i + 1) begin
			for (j = 0; j < S; j = j + 1) begin
				for (k = 0; k < P; k = k + 1) begin
					@(negedge i_clk);
					i_ifmap_ra = (i * S) + j;
					i_wght_ra = (i * S) + j + (k * Q * S);
					i_psum_ra = k;
					i_psum_wa = (i==0 && j==0 && k<3) ? 0 : (k>=3) ? k-3 : k+3; // 3 cycle delay for valid psum_out
					i_psum_we = (i==0 && j==0 && k<3) ? 0 : 1; // 3 cycle delay for valid psum_out
					i_rst_psum = 0;
					i_acc_sel = 0;
				end
			end
		end
		for (i = 0; i < 3; i = i + 1) begin
			@(negedge i_clk);
			i_psum_wa = i + 3;
			i_psum_we = 1;
		end
		@(negedge i_clk);
		i_psum_we = 0;

//////////////////////////////////////////////////////////

		// Psum Accumulation
		for (i = 0; i < 6; i = i + 1) begin
			@(negedge i_clk);
			i_psum_ra = i;
			i_acc_sel = (i==0) ? 0 : 1; // 1 cycle delay
			i_psum = 10;
		end
		@(negedge i_clk);
		i_acc_sel = 1;
		@(negedge i_clk);
		i_acc_sel = 0;
		

//////////////////////////////////////////////////////////

		repeat (10) @(negedge i_clk);

		// Reset Accumulation without i_psum
		for (i = 0; i < 3; i = i + 1) begin
			@(negedge i_clk);
			i_psum = 0;
			i_acc_sel = 1;
			i_rst_psum = 1;
		end
		for (i = 0; i < 6; i = i + 1) begin
			@(negedge i_clk);
			i_psum_wa = i;
			i_psum_we = 1;
		end

		@(negedge i_clk);
		i_rst_psum = 0;
		i_acc_sel = 0;
		i_psum_we = 0;


//////////////////////////////////////////////////////////

		repeat (10) @(negedge i_clk);

		// Reset Accumulation with i_psum
		for (i = 0; i < 3; i = i + 1) begin
			@(negedge i_clk);
			i_psum = 10;
			i_acc_sel = 1;
			i_rst_psum = 1;
		end
		for (i = 0; i < 6; i = i + 1) begin
			@(negedge i_clk);
			i_psum_wa = i;
			i_psum_we = 1;
		end

		@(negedge i_clk);
		i_rst_psum = 0;
		i_acc_sel = 0;
		i_psum_we = 0;

//////////////////////////////////////////////////////////

		repeat (10) @(negedge i_clk);

		$display("Finish Simulation");
		$finish;
	end
endmodule
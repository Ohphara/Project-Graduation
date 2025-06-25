`timescale 1ns / 1ps

(* use_dsp = "yes" *) module PE_datapath #(
	parameter DATA_BITWIDTH = 16,
	parameter IFMAP_ADDR_BITWIDTH = 4,
	parameter WGHT_ADDR_BITWIDTH = 7,
	parameter PSUM_ADDR_BITWIDTH = 3
)(
	input i_clk, i_rst,

	//input, output data
	input signed [DATA_BITWIDTH-1:0] i_ifmap_data,
	input signed [DATA_BITWIDTH-1:0] i_wght_data,
	input signed [DATA_BITWIDTH-1:0] i_psum_data,
	output reg signed [DATA_BITWIDTH-1:0] o_psum_data,

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

	//delayed input psum data
	reg [DATA_BITWIDTH-1:0] ipsum_reg, ipsum_reg_d, ipsum_reg_d2;

	//delayed spad data
	wire signed [DATA_BITWIDTH-1:0] ifmap_rd;
	wire signed [DATA_BITWIDTH-1:0] wght_rd;
	wire signed [DATA_BITWIDTH-1:0] psum_rd;

	reg [DATA_BITWIDTH-1:0] ifmap_reg, ifmap_reg_d;
	reg [DATA_BITWIDTH-1:0] psum_reg, psum_reg_d, psum_reg_d2;
	reg [DATA_BITWIDTH-1:0] wght_reg;

	//delayed control signal
	reg [3:0] acc_sel_sft_reg;
	reg [2:0] rst_psum_sft_reg; // 2 cycle delay
	reg [PSUM_ADDR_BITWIDTH-1:0] psum_wa_reg, psum_wa_reg_d1, psum_wa_reg_d2, psum_wa_reg_d3; //3 cycle delay
	reg [3:0] psum_we_sftreg; //3 cycle delay

	wire rst_psum = rst_psum_sft_reg[2];
	wire psum_we = psum_we_sftreg[2];
	wire [PSUM_ADDR_BITWIDTH-1:0] psum_wa = psum_wa_reg_d2;

	wire acc_sel = acc_sel_sft_reg[2];
	wire acc_sel_d = acc_sel_sft_reg[3];

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
		.i_wd(i_ifmap_data)
	);

	true_dpbram #(
		.RAM_WIDTH(DATA_BITWIDTH),                       // Specify RAM data width
		.RAM_DEPTH(1<<WGHT_ADDR_BITWIDTH),    // Specify RAM depth (number of entries)
		.RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
		.INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
	) spad_weight (
		.addra(i_wght_ra),   // Port A address bus, width determined from RAM_DEPTH
		.addrb(i_wght_wa),   // Port B address bus, width determined from RAM_DEPTH
		.dina(),     // Port A RAM input data, width determined from RAM_WIDTH
		.dinb(i_wght_data),     // Port B RAM input data, width determined from RAM_WIDTH
		.clka(i_clk),     // Clock
		.wea(0),       // Port A write enable
		.web(i_wght_we),       // Port B write enable
		.ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
		.enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
		.rsta(i_rst),     // Port A output reset (does not affect memory contents)
		.rstb(i_rst),     // Port B output reset (does not affect memory contents)
		.regcea(1'b1), // Port A output register enable
		.regceb(1'b1), // Port B output register enable
		.douta(wght_rd),   // Port A RAM output data, width determined from RAM_WIDTH
		.doutb()    	   // Port B RAM output data, width determined from RAM_WIDTH
	);

	RF #(
		.DATA_BITWIDTH(DATA_BITWIDTH),
		.ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
	) psum_RF (
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_ra(i_psum_ra),
		.o_rd(psum_rd),
		.i_we(psum_we),
		.i_wa(psum_wa),
		.i_wd(o_psum_data)
	);

	always @(posedge i_clk) begin
		if(i_rst) begin
			ipsum_reg <= 0;
			ipsum_reg_d <= 0;
			ipsum_reg_d2 <= 0;

			ifmap_reg <= 0;
			ifmap_reg_d <= 0;
			wght_reg <= 0;
			psum_reg <= 0;
			psum_reg_d <= 0;
			psum_reg_d2 <= 0;

			psum_we_sftreg <= 0;
			psum_wa_reg <= 0;
			psum_wa_reg_d1 <= 0;
			psum_wa_reg_d2 <= 0;
			psum_wa_reg_d3 <= 0;

			rst_psum_sft_reg <= 0;
			acc_sel_sft_reg <= 0;
		end
		else begin
			ipsum_reg <= (rst_psum) ? 0 : i_psum_data ;
			ipsum_reg_d <= ipsum_reg;
			ipsum_reg_d2 <= ipsum_reg_d;

			ifmap_reg <= ifmap_rd;
			ifmap_reg_d <= ifmap_reg;
			wght_reg <= wght_rd;
			psum_reg <= psum_rd;
			psum_reg_d <= psum_reg;
			psum_reg_d2 <= (rst_psum) ? 0 : psum_reg_d;

			psum_we_sftreg <= {psum_we_sftreg[2:0], i_psum_we};
			psum_wa_reg <= i_psum_wa;
			psum_wa_reg_d1 <= psum_wa_reg;
			psum_wa_reg_d2 <= psum_wa_reg_d1;
			psum_wa_reg_d3 <= psum_wa_reg_d2;
			
			rst_psum_sft_reg <= {rst_psum_sft_reg[1:0], i_rst_psum};
			acc_sel_sft_reg <= {acc_sel_sft_reg[2:0], i_acc_sel};
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

	//assign o_psum_data = psum_reg_d2 + ((acc_sel) ? ipsum_reg_d3 : (rst_psum) ? 0 : mul_reg);
	always @(*) begin
		case({rst_psum, acc_sel})
			2'b00: o_psum_data = psum_reg_d2 + mul_reg;
			2'b01: o_psum_data = psum_reg_d2 + ipsum_reg_d2;
			2'b10: o_psum_data = 0;
			2'b11: o_psum_data = 0;
		endcase
	end


endmodule
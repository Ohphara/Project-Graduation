//instruction sram for 

module sram_inst #( 
	parameter DATA_BITWIDTH = 16,
	parameter ADDR_BITWIDTH = 9 
)( 
	input i_clk,
	input i_rst,
	input i_re,
	input i_we,
	input [ADDR_BITWIDTH-1 : 0] i_ra,
	input [ADDR_BITWIDTH-1 : 0] i_wa,
	input signed [DATA_BITWIDTH-1 : 0] i_wd,
	output signed [DATA_BITWIDTH-1 : 0] o_rd
);

    //ISA on FPGA side
    localparam CMD_NOP          = 3'b000;
    localparam CMD_SET          = 3'b001;
    localparam CMD_LOAD_IFMAP   = 3'b010;
    localparam CMD_LOAD_WGHT    = 3'b011;
    localparam CMD_CONV         = 3'b100;

	reg [DATA_BITWIDTH-1 : 0] mem [0 : (1 << ADDR_BITWIDTH) - 1]; 
	reg [DATA_BITWIDTH-1 : 0] data;

	initial begin
				mem_row[ 0] = {8'h00, 8'h00, 8'h00, 8'h01};
				mem_row[ 1] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_WMINJ};
				mem_row[ 2] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_IMINJ};
				mem_row[ 3] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_MAC};
				mem_row[ 4] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_IMINJ};
				mem_row[ 5] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_MACACC};
				mem_row[ 6] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_OMPOP};
				mem_row[ 7] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_NOP};
				mem_row[ 8] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_NOP};
				mem_row[ 9] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_NOP};
				mem_row[10] = {8'h00, 8'h00, 8'h00, 5'b0, SA_CMD_NOP};
	 end
	
	always@(posedge i_clk) begin : READ
		if(i_rst)
			data <= 0;
		else
		begin
			if(i_re) begin
				data <= mem[i_ra];
			end
			else begin
				data <= 10101;
			end
		end
	end

	assign o_rd = data;
	

	always@(posedge i_clk) begin : WRITE
		if(i_we && !i_rst) begin
			mem[i_wa] <= i_wd;
		end
	end
	
endmodule
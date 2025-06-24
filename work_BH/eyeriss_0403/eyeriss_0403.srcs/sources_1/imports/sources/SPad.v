`timescale 1ns / 1ps

module SPad #( 
	parameter DATA_BITWIDTH = 16,
	parameter ADDR_BITWIDTH = 9 
)( 
	input clk,
	input rst,
	input re,
	input we,
	input [ADDR_BITWIDTH-1 : 0] ra,
	input [ADDR_BITWIDTH-1 : 0] wa,
	input signed [DATA_BITWIDTH-1 : 0] wd,
	output signed [DATA_BITWIDTH-1 : 0] rd
);
	
	reg [DATA_BITWIDTH-1 : 0] mem [0 : (1 << ADDR_BITWIDTH) - 1]; 
	reg [DATA_BITWIDTH-1 : 0] data;
	
	always@(posedge clk) begin : READ
		if(rst)
			data <= 0;
		else
		begin
			if(re) begin
				data <= mem[ra];
			end
			else begin
				data <= 10101;
			end
		end
	end

	assign rd = data;
	

	always@(posedge clk) begin : WRITE
		if(we && !rst) begin
			mem[wa] <= wd;
		end
	end
	
endmodule
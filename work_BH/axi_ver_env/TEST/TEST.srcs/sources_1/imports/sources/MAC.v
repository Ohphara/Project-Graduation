`timescale 1ns / 1ps

module MAC #( parameter IN_BITWIDTH = 16,
			  parameter OUT_BITWIDTH = 32 )
			( input signed [IN_BITWIDTH-1 : 0] a_in,
			  input signed [IN_BITWIDTH-1 : 0] w_in,
			  input signed [IN_BITWIDTH-1 : 0] sum_in,
			  input en, clk,
			  output reg signed [OUT_BITWIDTH-1 : 0] out
			);
	
	reg signed [OUT_BITWIDTH-1:0] mult_out;
	
	always@(posedge clk) begin
		if(en) begin
			mult_out = a_in * w_in;
			out <= mult_out + sum_in;
		end
	end
	
endmodule

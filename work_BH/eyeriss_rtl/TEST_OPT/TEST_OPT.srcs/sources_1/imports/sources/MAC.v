`timescale 1ns / 1ps

(*use_dsp = "yes"*)
module MAC #( parameter IN_BITWIDTH = 16,
			  parameter OUT_BITWIDTH = 32 )
			( input signed [IN_BITWIDTH-1 : 0] a_in,
			  input signed [IN_BITWIDTH-1 : 0] w_in,
			  input signed [IN_BITWIDTH-1 : 0] sum_in,
			  input en, clk,
			  output reg signed [OUT_BITWIDTH-1 : 0] out
			);
	
	wire signed [OUT_BITWIDTH-1:0] mul_tmp;
	assign mul_tmp = a_in * w_in;
	
	always@(posedge clk) begin
		if(en) begin
			out <= mul_tmp + sum_in;
		end
	end
	
endmodule

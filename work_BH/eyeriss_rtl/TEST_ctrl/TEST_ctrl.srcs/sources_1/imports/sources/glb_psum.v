`timescale 1ns / 1ps


module glb_psum #( 
	parameter DATA_BITWIDTH = 16,
	parameter ADDR_BITWIDTH = 10,
	parameter X_dim=3,
	parameter Y_dim =3 
) ( 
	input clk,
	input reset,
	input read_req,
	input write_en,
	input [ADDR_BITWIDTH-1 : 0] r_addr,
	input [ADDR_BITWIDTH-1 : 0] w_addr,
	input signed [DATA_BITWIDTH-1 : 0] w_data,
	output signed [DATA_BITWIDTH-1 : 0] r_data,
	input [ADDR_BITWIDTH-1 : 0] r_addr_inter,
	input read_req_inter,
	output  [DATA_BITWIDTH*X_dim-1 : 0] r_data_inter,
	output reg read_en_inter
);
	
	reg [DATA_BITWIDTH-1 : 0] mem [0 : (1 << ADDR_BITWIDTH) - 1];  
	reg signed [DATA_BITWIDTH-1 : 0] data;
	reg [DATA_BITWIDTH*X_dim-1 : 0] data_inter;
	
	integer i;

	always@(posedge clk) begin : READ //READ GLB data and send to SPAD
		if(reset) begin
			data = 0;
		end
		else begin
			if(read_req) begin
				data = mem[r_addr];
			end else begin
				data = 10101; //Random default value to verify model
			end
		end
	end
	
	assign r_data = data;
	
	always@(posedge clk) begin : READ_INTER  //READ GLB interleaved data and send to SPAD
		if(reset)
		begin
			data_inter = 0;
			read_en_inter = 0;
		end
		else
		begin
			if(read_req_inter) 
			begin
				for (i = 0; i < X_dim; i = i + 1) begin: gen_concat
					data_inter[DATA_BITWIDTH * i +: DATA_BITWIDTH] = mem[r_addr_inter + i];
				end
				read_en_inter=1;
			end
			else 
			begin
				data_inter=0;
				read_en_inter=0;
			end
		end
	end

	assign r_data_inter = data_inter;
	
	always@(posedge clk) begin : WRITE //write data to GLB
		if(write_en && !reset) begin
			mem[w_addr] = w_data;
		end
	end	
endmodule
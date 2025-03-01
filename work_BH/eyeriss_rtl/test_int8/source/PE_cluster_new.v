`timescale 1ns / 1ps

module PE_cluster_new #(parameter DATA_BITWIDTH = 16,
					parameter ADDR_BITWIDTH = 9,
					
					parameter X_dim = 5,
					parameter Y_dim = 3,
   
					parameter kernel_size = 3,
					parameter act_size = 5,
					
					parameter W_READ_ADDR = 0,  
					parameter A_READ_ADDR = 100,
					
					parameter W_LOAD_ADDR = 0,  
					parameter A_LOAD_ADDR = 100,
					
					parameter PSUM_ADDR = 500
					)
					( 
					input clk, reset,
					input signed [DATA_BITWIDTH-1:0] act_in,
					input signed [DATA_BITWIDTH-1:0] filt_in,
					input [DATA_BITWIDTH*X_dim-1:0] pe_before,
					// output [7:0] filt_count_n,
//					input load_en, 
					input load_en_wght, load_en_act,
					input start,
					output reg [DATA_BITWIDTH*X_dim-1:0] pe_out,
					output  compute_done,
					output  load_done
					
		//extra 
		//			output reg [DATA_BITWIDTH-1:0] psum_out[0 : X_dim*Y_dim-1]
					);
		
		wire signed [DATA_BITWIDTH-1:0] psum_out[0 : X_dim*Y_dim-1];
		
		wire cluster_done[0 : X_dim*Y_dim-1];
		wire cluster_load_done[0 : X_dim*Y_dim-1];
		
		
		//instantiate PEs
		generate
		genvar i, j;
		for(i=0; i<X_dim; i=i+1) 
			begin:gen_X
				for(j=0; j<Y_dim; j=j+1)
					begin:gen_Y
					
						PE_new #( 	.DATA_BITWIDTH(DATA_BITWIDTH),
								.ADDR_BITWIDTH(ADDR_BITWIDTH),
								.kernel_size(kernel_size),
								.act_size(act_size),
								.W_READ_ADDR(W_READ_ADDR + kernel_size*j),  
								.A_READ_ADDR(A_READ_ADDR + act_size*j + i),
								.W_LOAD_ADDR(W_LOAD_ADDR),  
								.A_LOAD_ADDR(A_LOAD_ADDR),
								.PSUM_ADDR(PSUM_ADDR)
							)
						pe (	
								.clk(clk),
								.reset(reset),
								.act_in(act_in),
								.filt_in(filt_in),
								// .filt_count_n(filt_count_n),
//								.load_en(load_en),
								.load_en_wght(load_en_wght),
								.load_en_act(load_en_act),
								// .pe_before(pe_before),
								.start(start),
								.pe_out(psum_out[i*Y_dim+j]),
								.compute_done(cluster_done[i*Y_dim+j]),
								.load_done(cluster_load_done[i*Y_dim+j])
							);
					
					end
			end
		endgenerate
			
		

		reg [DATA_BITWIDTH-1:0] psum_col [0:X_dim-1];
		integer r, c;

		always @(*) begin
			for (c = 0; c < X_dim; c = c + 1) begin
				psum_col[c] = 0; // 초기화
				for (r = 0; r < Y_dim; r = r + 1) begin
					psum_col[c] = psum_col[c] + psum_out[c * Y_dim + r]; // 누적 합
				end
			end
		end

		// Add partial sums and register at pe_out
		always@(posedge clk) begin
			if(reset)
			begin
					pe_out <= 0;
			end 
			else
			begin
				for(r=0; r<X_dim; r=r+1) begin
					pe_out[r*DATA_BITWIDTH +: DATA_BITWIDTH] <= pe_before[r*DATA_BITWIDTH +: DATA_BITWIDTH] + psum_col[r];
				end
			end
		end


		assign compute_done = cluster_done[0];
		assign load_done = cluster_load_done[0];
			  
endmodule
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
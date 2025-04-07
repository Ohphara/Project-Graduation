`timescale 1ns / 1ps

module PE_cluster_new #(
	parameter DATA_BITWIDTH = 16,
	parameter ADDR_BITWIDTH = 9,
	
	parameter PE_ROW = 3,
	parameter PE_COL = 5,

	parameter kernel_size = 3,
	parameter act_size = 5,
	
	parameter W_READ_ADDR = 0,  
	parameter A_READ_ADDR = 100,
	
	parameter W_LOAD_ADDR = 0,  
	parameter A_LOAD_ADDR = 100,
	
	parameter PSUM_ADDR = 500
)(
	input clk, rst,
	input signed [DATA_BITWIDTH-1:0] act_in,
	input signed [DATA_BITWIDTH-1:0] filt_in,
	input [DATA_BITWIDTH*PE_COL-1:0] pe_before,

	input load_en_wght, load_en_act,
	input start,

	output reg [DATA_BITWIDTH*PE_COL-1:0] pe_out,
	output  compute_done,
	output  load_done
);
	
	reg [2:0] state;
	localparam IDLE = 3'b000;
	localparam LOAD_W = 3'b001;
	localparam LOAD_A = 3'b010;
	localparam RUN = 3'b011;
	localparam DONE = 3'b100;
	
	wire pe_load_done[0 : PE_COL*PE_ROW-1];
	wire pe_compute_done[0 : PE_COL*PE_ROW-1];
	

	
	//instantiate PEs
	wire signed [DATA_BITWIDTH-1:0] psum_out [0 : PE_ROW*PE_COL-1];
	generate
	genvar i, j;
	for(i=0; i<PE_ROW; i=i+1) 
		begin:gen_ROW
			for(j=0; j<PE_COL; j=j+1)
				begin:gen_COL
					PE_new #( 	
						.DATA_BITWIDTH(DATA_BITWIDTH),
						.ADDR_BITWIDTH(ADDR_BITWIDTH),
						.kernel_size(kernel_size),
						.act_size(act_size),
						.W_READ_ADDR(W_READ_ADDR),  
						.A_READ_ADDR(A_READ_ADDR),
						.W_LOAD_ADDR(W_LOAD_ADDR),  
						.A_LOAD_ADDR(A_LOAD_ADDR),
						.PSUM_ADDR(PSUM_ADDR)
					) pe(	
							.clk(clk),
							.rst(rst),
							.act_in(act_in),
							.filt_in(row_data[i]),
							
							.load_en_wght(load_en_wght),
							.load_en_act(load_en_act),
							
							.start(start),

							.pe_out(psum_out[i*PE_COL+j]),
							.compute_done(pe_compute_done[i*PE_ROW+j]),
							.load_done(pe_load_done[i*PE_ROW+j])
						);
				end
		end
	endgenerate
		

	reg [1:0] row_select;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row_select <= 0;
        end else begin
            row_select <= (row_select == PE_ROW - 1) ? 0 : row_select + 1;
        end
    end

    reg signed [DATA_BITWIDTH-1:0] row_data [0:PE_ROW-1];  // filt_in 값을 각 행에 저장하는 레지스터
    always @(posedge clk) begin
        if (rst) begin
            row_data[0] <= 0;
            row_data[1] <= 0;
            row_data[2] <= 0;
        end else begin
            row_data[row_select] <= filt_in; // 현재 row_select 위치에 filt_in 저장
        end
    end


	// FSM for PE cluster
	always@(posedge clk) begin
		if(rst) begin

		end
		else begin
			case(state)
				IDLE:begin
				end

				LOAD_W:begin
				end

				LOAD_A:begin
				end
				
				RUN: begin
				end

				DONE: begin
				end
			endcase
		end
	end
	

	reg [DATA_BITWIDTH-1:0] psum_col [0:PE_COL-1];
	integer r, c;

	always @(*) begin
		for (c = 0; c < PE_COL; c = c + 1) begin
			psum_col[c] = 0; // 초기화
			for (r = 0; r < PE_ROW; r = r + 1) begin
				psum_col[c] = psum_col[c] + psum_out[c * PE_ROW + r]; // 누적 합
			end
		end
	end

	// Add partial sums and register at pe_out
	always@(posedge clk) begin
		if(rst)
		begin
				pe_out <= 0;
		end 
		else
		begin
			for(r=0; r<PE_COL; r=r+1) begin
				pe_out[r*DATA_BITWIDTH +: DATA_BITWIDTH] <= pe_before[r*DATA_BITWIDTH +: DATA_BITWIDTH] + psum_col[r];
			end
		end
	end


	assign compute_done = pe_compute_done[0];
	assign load_done = pe_load_done[0];



			  
endmodule
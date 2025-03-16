`timescale 1ns / 1ps

module router_iact #(
	parameter DATA_BITWIDTH = 16,
	parameter ADDR_BITWIDTH_GLB = 10,
	parameter ADDR_BITWIDTH_SPAD = 9,
	
	parameter PE_ROW = 3,
	parameter PE_COL = 5,
	parameter kernel_size = 3,
	parameter act_size = 5,
	
	parameter A_READ_ADDR =100, 
	parameter A_LOAD_ADDR = 0
) (	
	input clk,
	input rst,
	
	//for reading glb
	input signed [DATA_BITWIDTH-1 : 0] r_data_glb_iact,
	output reg [ADDR_BITWIDTH_GLB-1 : 0] r_addr_glb_iact,
	output reg read_req_glb_iact,
	
	//for writing to spad
	output reg signed [DATA_BITWIDTH-1 : 0] w_data_spad,
	output reg load_en_spad,
	
	//Input from control unit to load weights to spad
	input load_spad_ctrl
);				
					
	// enum reg [2:0] {IDLE=3'b000, READ_GLB=3'b001, WRITE_SPAD=3'b010, READ_GLB_0=3'b011} state;
	reg [2:0] state;		
	localparam IDLE=3'b000;
	localparam READ_GLB=3'b001;
	localparam WRITE_SPAD=3'b010;
	
	reg [6:0] filt_count;
	
	always@(posedge clk) begin
		if(rst) begin
			read_req_glb_iact <= 0;
			r_addr_glb_iact <= 0;
			load_en_spad <= 0;
			filt_count <= 0;
			state <= IDLE;
		end else begin
			case(state)
				IDLE:begin
					if(load_spad_ctrl) begin
						read_req_glb_iact <= 1;
						r_addr_glb_iact <= A_READ_ADDR;
						load_en_spad <= 0;
						state <= READ_GLB;
					end else begin
						read_req_glb_iact <= 0;
						load_en_spad <= 0;
						state <= IDLE;
					end
				end
				
				READ_GLB:begin
					filt_count <= filt_count + 1;
					r_addr_glb_iact <= r_addr_glb_iact + 1;
					w_data_spad <= r_data_glb_iact;
					state <= WRITE_SPAD;
				end
				
				WRITE_SPAD:begin
					load_en_spad <= 1;
					if(filt_count == (act_size**2)-1) begin
						w_data_spad <= r_data_glb_iact;
						filt_count <= 0;
						r_addr_glb_iact <= A_READ_ADDR;
						///////////////////////
						read_req_glb_iact <= 0;
						load_en_spad <=0;
						///////////////////////
						state <= IDLE;

					end else begin
						w_data_spad <= r_data_glb_iact;
						filt_count <= filt_count + 1;
						r_addr_glb_iact <= r_addr_glb_iact + 1;
						state <= WRITE_SPAD;
					end
				end
				default:
					state <= IDLE;
			endcase
		end
	end
endmodule


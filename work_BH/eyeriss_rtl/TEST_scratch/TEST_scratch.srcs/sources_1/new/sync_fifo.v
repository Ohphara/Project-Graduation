`timescale 1ns / 1ps
module sync_fifo 
# (
	parameter   DATA_BITWIDTH = 32,
	parameter   FIFO_DEPTH    = 4
)
(
	input           				clk,
	input           				rst,

	input           				s_valid,
	output         				 	s_ready,
	input   [DATA_BITWIDTH-1:0] 	s_data,

	output          				m_valid,
	input           				m_ready,
	output  [DATA_BITWIDTH-1:0] 	m_data
);

// ================================================	//
// 					 parameters  					//
// ================================================	//

parameter   FIFO_ADDR_DEPTH = $clog2(FIFO_DEPTH);

// ================================================	//
// 					 	wires	  					//
// ================================================	//

wire o_full;

wire i_hs;
wire o_hs;

// ================================================	//
// 					 registers  					//
// ================================================	//

reg     [FIFO_ADDR_DEPTH-1:0] 	wptr, wptr_nxt;
reg             				wptr_round, wptr_round_nxt;
reg     [FIFO_ADDR_DEPTH-1:0] 	rptr, rptr_nxt;
reg             				rptr_round, rptr_round_nxt;
reg     [DATA_BITWIDTH-1:0] 	buf_data[FIFO_DEPTH-1:0];

// ================================================	//
// 					 combination  					//
// ================================================	//

assign i_hs = s_valid & s_ready;
assign o_hs = m_valid & m_ready;

assign o_empty  = (wptr == rptr) && (wptr_round == rptr_round);
assign o_full = (wptr == rptr) && (wptr_round != rptr_round);

assign s_ready = ~o_full;
assign m_valid = ~o_empty;
assign m_data = buf_data[rptr];

always @(*) begin
	if (wptr == (FIFO_DEPTH-1)) begin
		wptr_nxt = 0;
		wptr_round_nxt = ~wptr_round;
	end else begin
		wptr_nxt = wptr + 'd1;
		wptr_round_nxt = wptr_round;
	end
end

always @(*) begin
	if (rptr == (FIFO_DEPTH-1)) begin
		rptr_nxt = 0;
		rptr_round_nxt = ~rptr_round;
	end else begin
		rptr_nxt = rptr + 'd1;
		rptr_round_nxt = rptr_round;
	end
end

// ================================================	//
// 					 Sequential  					//
// ================================================	//

integer i;
always @(posedge clk ) begin
	if (rst) begin
		wptr <= 0;
		wptr_round <= 0;
		for (i=0; i<FIFO_DEPTH; i=i+1)
			buf_data[i] <= {(DATA_BITWIDTH){1'b0}};
	end else if (i_hs) begin
		buf_data[wptr] <= s_data;
		{wptr_round,wptr}<= {wptr_round_nxt,wptr_nxt};
	end
end


always @(posedge clk) begin
	if (rst) begin
		rptr <= 0;
		rptr_round <= 0;
	end else if (o_hs) begin
		{rptr_round,rptr} <= {rptr_round_nxt,rptr_nxt};
	end
end

endmodule
`timescale 1ns / 1ps
(* USE_DSP = "yes" *) module PE #(
    parameter IFMAP_ADDR_BITWIDTH  = 7,
    parameter WEIGHT_ADDR_BITWIDTH = 9,
    parameter PSUM_ADDR_BITWIDTH   = 6,
    parameter DATA_BITWIDTH        = 8,
    parameter PSUM_BITWIDTH        = 21
)
(
    input clk,
    input rst,

    // SPad control signals
    input ifmap_write_en,
    input weight_write_en,
    input psum_write_en,

    // ready valid handshake for FIFO interface
    input signed [DATA_BITWIDTH-1:0] i_ifmap_data,
    input i_ifmap_valid,
    output o_ifmap_ready,

    input signed [DATA_BITWIDTH-1:0] i_weight_data,
    input i_weight_valid,
    output o_weight_ready,

    input signed [PSUM_BITWIDTH-1:0] i_psum_in_data,
    input i_external_psum_valid,
    output o_external_psum_ready,

    output signed [PSUM_BITWIDTH-1:0] o_psum_out_data,
    output o_psum_out_valid,
    input i_psum_out_ready,

    input mul_sel, // 0: psum_reg + mul_reg, 1: psum_reg + external psum
				
	input  			       	psum_enq_en,
	input  			       	do_load_en,
	output 			       	cal_fin,
			
	input					iact_write_fin_clear,
	input					weight_write_fin_clear,
	output 					all_write_fin,
	
	input					psum_spad_clear
);

// ================================================	//
// FIFO instantiation
// ================================================	//

    wire signed [DATA_BITWIDTH-1:0] FIFO_in_weight_data;
    wire FIFO_in_weight_ready;
    wire FIFO_in_weight_valid;

    wire signed [DATA_BITWIDTH-1:0] FIFO_out_weight_data;
    wire FIFO_out_weight_ready;
    wire FIFO_out_weight_valid;
    
    wire signed [DATA_BITWIDTH-1:0] FIFO_in_ifmap_data;
    wire FIFO_in_ifmap_ready;
    wire FIFO_in_ifmap_valid;

    wire signed [DATA_BITWIDTH-1:0] FIFO_out_ifmap_data;
    wire FIFO_out_ifmap_ready;
    wire FIFO_out_ifmap_valid;

    wire signed [PSUM_BITWIDTH-1:0] FIFO_in_psum_in_data;
    wire FIFO_in_psum_in_ready;
    wire FIFO_in_psum_in_valid;

    wire signed [PSUM_BITWIDTH-1:0] FIFO_out_psum_in_data;
    wire FIFO_out_psum_in_ready;
    wire FIFO_out_psum_in_valid;

    wire signed [PSUM_BITWIDTH-1:0] FIFO_in_psum_out_data;
    wire FIFO_in_psum_out_ready;
    wire FIFO_in_psum_out_valid;

    wire signed [PSUM_BITWIDTH-1:0] FIFO_out_psum_out_data;
    wire FIFO_out_psum_out_ready;
    wire FIFO_out_psum_out_valid;


    sync_fifo #(
        .DATA_BITWIDTH(DATA_BITWIDTH)
    )
    FIFO_weight
    (
        .clk(clk),
        .rst(rst),
        .s_valid(FIFO_in_weight_valid),
        .s_ready(FIFO_in_weight_ready),
        .s_data(FIFO_in_weight_data),
        .m_valid(FIFO_out_weight_valid),
        .m_ready(FIFO_out_weight_ready),
        .m_data(FIFO_out_weight_data)
    );

    sync_fifo #(
        .DATA_BITWIDTH(DATA_BITWIDTH)
    )
    FIFO_ifmap
    (
        .clk(clk),
        .rst(rst),
        .s_valid(FIFO_in_ifmap_valid),
        .s_ready(FIFO_in_ifmap_ready),
        .s_data(FIFO_in_ifmap_data),
        .m_valid(FIFO_out_ifmap_valid),
        .m_ready(FIFO_out_ifmap_ready),
        .m_data(FIFO_out_ifmap_data)
    );

    sync_fifo #(
        .DATA_BITWIDTH(DATA_BITWIDTH)
    )
    FIFO_psum_in
    (
        .clk(clk),
        .rst(rst),
        .s_valid(FIFO_in_psum_in_valid),
        .s_ready(FIFO_in_psum_in_ready),
        .s_data(FIFO_in_psum_in_data),
        .m_valid(FIFO_out_psum_in_valid),
        .m_ready(FIFO_out_psum_in_ready),
        .m_data(FIFO_out_psum_in_data)
    );

    sync_fifo #(
        .DATA_BITWIDTH(DATA_BITWIDTH)
    )
    FIFO_psum_out
    (
        .clk(clk),
        .rst(rst),
        .s_valid(FIFO_in_psum_out_valid),
        .s_ready(FIFO_in_psum_out_ready),
        .s_data(FIFO_in_psum_out_data),
        .m_valid(FIFO_out_psum_out_valid),
        .m_ready(FIFO_out_psum_out_ready),
        .m_data(FIFO_out_psum_out_data)
    );

// ================================================	//
// SPAD instantiation
// ================================================	//

    // SPad wires
    wire signed [DATA_BITWIDTH-1:0] ifmap_data;
    wire signed [DATA_BITWIDTH-1:0] weight_data;
    wire signed [PSUM_BITWIDTH-1:0] psum_data;

    // Pipeline registers
    reg signed [DATA_BITWIDTH-1:0] ifmap_reg, weight_reg;
    reg signed [PSUM_BITWIDTH-1:0] psum_reg;
    reg signed [(2*DATA_BITWIDTH)-1:0] mul_reg;

    reg signed [PSUM_BITWIDTH-1:0] psum_out;

    // SPad instantiation
    SPad #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH)
    )
    ifmap_spad (
        .clk(clk),
        .rst(rst),
        .re(ctrl_ifmap_re),
        .we(ctrl_ifmap_we),
        .r_addr(ifmap_r_addr),
        .w_addr(ifmap_w_addr),
        .w_data(ifmap_w_data),
        .r_data(ifmap_data)
    );

    SPad #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .ADDR_BITWIDTH(WEIGHT_ADDR_BITWIDTH)
    )
    weight_spad (
        .clk(clk),
        .rst(rst),
        .re(ctrl_weight_re),
        .we(weight_write_en),
        .r_addr(weight_r_addr),
        .w_addr(weight_w_addr),
        .w_data(weight_w_data),
        .r_data(weight_data)
    );

    SPad #(
        .DATA_BITWIDTH(PSUM_BITWIDTH), 
        .ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
    )
    psum_spad (
        .clk(clk),
        .rst(rst),
        .re(mac_en),
        .we(psum_write_en),
        .r_addr(psum_r_addr), 
        .w_addr(psum_w_addr),
        .w_data(psum_out),
        .r_data(psum_data)
    );

// ================================================	//
// sequential logic
// ================================================	//

    wire load_en;
    reg load_done;
    // Pipeline stage 1 (LOAD)
    always @(posedge clk) begin
        if (rst) begin
            ifmap_reg  <= 0;
            weight_reg <= 0;
            load_done <= 0;
        end 
        else if (load_en) begin
            ifmap_reg  <= ifmap_data;
            weight_reg <= weight_data;
            load_done <= 1;
        end
    end

    // Pipeline stage 2 (MULT)
    wire mul_en = load_done;
    reg mul_done;

    always @(posedge clk) begin
        if (rst) begin
            mul_reg <= 0;
            psum_reg <= 0;
            mul_done <= 0;
        end else if (mul_en) begin
            mul_reg <= ifmap_reg * weight_reg;
            psum_reg <= psum_data;
            mul_done <= 1;
        end
    end
    
    // Pipeline stage 3 (ADD + WB)
    wire add_en = mul_done;
    reg add_done;

    always @(posedge clk) begin
        if (rst) begin
            psum_out <= 0;
        end 
        else begin
            if(add_en) begin
                case (mul_sel)
                    1'b0 : psum_out <= psum_reg + mul_reg;      // psum_reg + mul_reg
                    1'b1 : psum_out <= psum_reg + i_psum_in_data; // psum_reg + 외부 psum
                endcase
            end
        end
    end
    
    

endmodule
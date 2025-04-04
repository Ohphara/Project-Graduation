`timescale 1ns / 1ps

module PE_control #(
	parameter DATA_BITWIDTH = 16,
	parameter PSUM_BITWIDTH = 32,

	parameter IFMAP_ADDR_BITWIDTH = 4,
	parameter WGHT_ADDR_BITWIDTH = 8,
	parameter PSUM_ADDR_BITWIDTH = 5,

    parameter P = 24,   // # of different filters that one PE simultaneously process
    parameter Q = 4,     // # of different channels that one PE simultaneously process
    parameter S = 3,    // filter width
    parameter U = 1     // stride
)(
    input clk,
    input rst,

    input run,

    output o_idle,
    output o_load,
    output o_conv,
    output o_done,

    //// Interface to PE_datapath.v ////
	output reg [IFMAP_ADDR_BITWIDTH-1:0] ifmap_ra,
	output reg [WGHT_ADDR_BITWIDTH-1:0] wght_ra,
	output reg [PSUM_ADDR_BITWIDTH-1:0] psum_ra,
	
	output reg [IFMAP_ADDR_BITWIDTH-1:0] ifmap_wa,
	output reg [WGHT_ADDR_BITWIDTH-1:0] wght_wa,
	output reg [PSUM_ADDR_BITWIDTH-1:0] psum_wa,

	output reg ifmap_we,
	output reg wght_we,
	output reg psum_we,

    output reg ctrl_acc_sel,
    output reg ctrl_rst_psum
);

    localparam  IDLE             = 2'h0;
    localparam  LOAD             = 2'h1;
    localparam  CONV             = 2'h2;
    localparam  DONE             = 2'h3;

    reg [1:0] state;
    reg [1:0] n_state;
    
    reg [IFMAP_ADDR_BITWIDTH-1:0] ifmap_load_cnt;
    reg [WGHT_ADDR_BITWIDTH-1:0] wght_load_cnt;
    wire ifmap_load_done, wght_load_done;
    wire load_done, conv_done;



    //FSM : state register update
    always @(posedge clk) begin
        if(rst) begin
            state <= 0;
        end
        else begin
            n_state <= state;
        end
    end

    //FSM : next state logic
    always @(*) begin
        case(state)
            IDLE: begin
                if(run)
                    n_state = LOAD;
                else
                    n_state = IDLE;
            end
            LOAD: begin
                if(load_done)
                    n_state = CONV;
                else
                    n_state = LOAD;
            end
            CONV: begin
                if(conv_done)
                    n_state = DONE;
                else
                    n_state = CONV;
            end
            DONE: begin
                n_state = IDLE;
            end
        endcase
    end

    //FSM : output logic - LOAD state 
    always @(posedge clk) begin
        if(rst) begin
            ifmap_wa <= 0;
            wght_wa <= 0;
            ifmap_we <= 0;
            wght_we <= 0;
        end
        else if(state == LOAD) begin
            if(load_done) begin
                ifmap_wa <= 0;
                wght_wa <= 0;
                ifmap_we <= 0;
                wght_we <= 0;
            end
            else begin
                if(ifmap_load_done) begin
                    ifmap_wa <= ifmap_wa;
                    ifmap_we <= 0;
                end
                else begin
                    ifmap_wa <= ifmap_wa + 1;
                    ifmap_we <= 1;
                end

                if(wght_load_done) begin
                    wght_wa <= wght_wa;
                    wght_we <= 0;
                end
                else begin
                    wght_wa <= wght_wa + 1;
                    wght_we <= 1;
                end
            end
        end
    end

    assign ifmap_load_done = (ifmap_wa == Q * S);
    assign wght_load_done = (wght_wa == P * Q * S);
    assign load_done = ifmap_load_done && wght_load_done;


    //FSM : output logic - CONV state
    reg [5:0] iter_cnt;
    always @(posedge clk) begin
        if(rst) begin
            ifmap_ra <= 0;
            wght_ra <= 0;
            psum_ra <= 0;
            psum_wa <= 0;
            psum_we <= 0;
            ctrl_acc_sel <= 0;
            ctrl_rst_psum <= 0;

            iter_cnt <= 0;
        end
        else if(state == CONV) begin
            if(conv_done) begin
                ifmap_ra <= 0;
                wght_ra <= 0;
                psum_ra <= 0;
                psum_wa <= 0;
                psum_we <= 0;
                ctrl_acc_sel <= 0;
                ctrl_rst_psum <= 0;

                iter_cnt <= 0;
            end
            else begin
                ifmap_ra <= iter_cnt / P;
                wght_ra <= (iter_cnt * Q * S) + (iter_cnt / P);
                psum_ra <= iter_cnt % P;
                psum_wa <= iter_cnt % P;
                psum_we <= 1;
                ctrl_acc_sel <= (iter_cnt == P * S - 1);
                ctrl_rst_psum <= 0;

                iter_cnt <= (ctrl_acc_sel) ? iter_cnt : iter_cnt + 1;
            end
        end
    end
    assign conv_done = (iter_cnt == P * Q * S);

    //FSM : output logic - state
    assign o_idle = (state == IDLE);
    assign o_load = (state == LOAD);
    assign o_conv = (state == CONV);
    assign o_done = (state == DONE);

endmodule
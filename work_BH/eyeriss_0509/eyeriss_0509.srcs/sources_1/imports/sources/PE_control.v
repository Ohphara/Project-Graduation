`timescale 1ns / 1ps

//TODO : fifo implementation
//TODO : stride implementation

module PE_control #(
	parameter DATA_BITWIDTH = 16,
	parameter PSUM_BITWIDTH = 32,

	parameter IFMAP_ADDR_BITWIDTH = 4,
	parameter WGHT_ADDR_BITWIDTH = 8,
	parameter PSUM_ADDR_BITWIDTH = 5,

    parameter P = 6,   // # of different filters that one PE simultaneously process
    parameter Q = 4,     // # of different channels that one PE simultaneously process
    parameter S = 3,    // filter width
    parameter U = 1     // stride
)(
    input i_clk,
    input i_rst,

    input i_start,

    output o_idle,
    output o_load,
    output o_conv,
    output o_done,

    //// Interface to PE_datapath.v ////
	output reg [IFMAP_ADDR_BITWIDTH-1:0] o_ifmap_ra,
	output reg [WGHT_ADDR_BITWIDTH-1:0] o_wght_ra,
	output reg [PSUM_ADDR_BITWIDTH-1:0] o_psum_ra,
	
	output reg [IFMAP_ADDR_BITWIDTH-1:0] o_ifmap_wa,
	output reg [WGHT_ADDR_BITWIDTH-1:0] o_wght_wa,
	output reg [PSUM_ADDR_BITWIDTH-1:0] o_psum_wa,

	output reg o_ifmap_we,
	output reg o_wght_we,
	output reg o_psum_we,

    output reg o_acc_sel,
    output reg o_rst_psum
);

    localparam  IDLE             = 3'h0;
    localparam  LOAD             = 3'h1;
    localparam  CONV             = 3'h2;
    localparam  ACC              = 3'h3;
    localparam  DONE             = 3'h4;

    reg [2:0] state;
    reg [2:0] n_state;
    
    reg [IFMAP_ADDR_BITWIDTH-1:0] ifmap_load_cnt;
    reg [WGHT_ADDR_BITWIDTH-1:0] wght_load_cnt;
    wire ifmap_load_done, wght_load_done;
    wire load_done, conv_done;

    
    function integer clog2(input integer value);
        integer i;
        begin
            clog2 = 0;
            for (i = value - 1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    //FSM : state register update
    always @(posedge i_clk) begin
        if(i_rst) begin
            state <= 0;
        end
        else begin
            state <= n_state;
        end
    end

    //FSM : next state logic
    always @(*) begin
        case(state)
            IDLE: begin
                if(i_start)
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

    //counter logic
    reg [clog2(P)-1:0] cnt_P, cnt_P_d1, cnt_P_d2, cnt_P_d3;
    reg [clog2(Q)-1:0] cnt_Q;
    reg [clog2(S)-1:0] cnt_S;
    
    wire [clog2(P * Q * S)-1:0] cnt_sum = cnt_P + (P * cnt_S) + (P * S * cnt_Q);
    
    always @(posedge i_clk) begin
        if(i_rst) begin
            cnt_P <= 0; 
            cnt_Q <= 0; 
            cnt_S <= 0; 

            cnt_P_d1 <= 0;
            cnt_P_d2 <= 0;
            cnt_P_d3 <= 0;
        end
        else begin
            if(n_state != state) begin
                cnt_P <= 0; 
                cnt_S <= 0; 
                cnt_Q <= 0;

                cnt_P_d1 <= 0;
                cnt_P_d2 <= 0;
                cnt_P_d3 <= 0;
            end
            else begin
                cnt_P <= (cnt_P == P - 1) ? 0 : cnt_P + 1; 
                cnt_S <= (cnt_P == P - 1) ? ((cnt_S == S - 1) ? 0 : cnt_S + 1) : cnt_S;
                cnt_Q <= (cnt_P == P - 1) ? ((cnt_S == S - 1) ? ((cnt_Q == Q - 1) ? 0 : cnt_Q + 1) : cnt_Q) : cnt_Q;

                cnt_P_d1 <= cnt_P;
                cnt_P_d2 <= cnt_P_d1;
                cnt_P_d3 <= cnt_P_d2;
            end
        end
    end


    always @(posedge i_clk) begin
        if(i_rst) begin
            o_ifmap_wa <= 0;
            o_wght_wa <= 0;

            o_ifmap_we <= 0;
            o_wght_we <= 0;

            o_psum_ra <= 0;
            o_psum_wa <= 0;
            o_psum_we <= 0;

            o_acc_sel <= 0;
            o_rst_psum <= 0;
        end
        case(state)
            LOAD: begin
                if(load_done) begin
                    o_ifmap_wa <= 0;
                    o_wght_wa <= 0;

                    o_ifmap_we <= 0;
                    o_wght_we <= 0;
                end
                else begin
                    if(ifmap_load_done) begin
                        o_ifmap_wa <= 0;
                        o_ifmap_we <= 0;
                    end
                    else begin
                        o_ifmap_wa <= cnt_S + (S * cnt_Q);
                        o_ifmap_we <= 1;
                    end

                    if(wght_load_done) begin
                        o_wght_wa <= 0;
                        o_wght_we <= 0;
                    end
                    else begin
                        o_wght_wa <= cnt_P + (P * cnt_S) + (P * S * cnt_Q);
                        o_wght_we <= 1;
                    end
                end
            end

            CONV: begin
                if(conv_done) begin
                    o_ifmap_ra <= 0;
                    o_wght_ra <= 0;

                    o_psum_ra <= 0;
                    o_psum_wa <= 0;
                    o_psum_we <= 0;

                    o_rst_psum <= 0;
                end
                else begin
                    o_ifmap_ra <= cnt_S + (S * cnt_Q);
                    o_wght_ra <= cnt_P + (P * cnt_S) + (P * S * cnt_Q);

                    o_psum_ra <= cnt_P;
                    o_psum_wa <= cnt_P_d3;
                    o_psum_we <= (cnt_P_d3 + cnt_S + cnt_Q != 0);

                    o_rst_psum <= (cnt_S == 0) && (cnt_Q == 0);
                end
            end

            ACC: begin
                if(acc_done) begin
                    o_psum_ra <= 0;
                    o_acc_sel <= 0;
                end
                else begin
                    o_psum_ra <= cnt_P;
                    o_acc_sel <= (cnt_P_d1 != 0);
                end
            end
        endcase
    end

    assign ifmap_load_done = (cnt_sum >= (Q * S) - 1);
    assign wght_load_done = (cnt_sum >= (P * Q * S) - 1);

    assign load_done = ifmap_load_done && wght_load_done;
    assign conv_done = (cnt_sum == (P * Q * S) - 1 + 3); // due to 3 cycle delay of psum wr
    assign acc_done = (cnt_sum == P - 1 + 1); // due to 1 cycle delay or psum rd
    assign i_rst_done = (cnt_sum == (P - 1 + 3)); // due to 3 cycle delay of psum wr

    assign o_idle = (state == IDLE);
    assign o_load = (state == LOAD);
    assign o_conv = (state == CONV);
    assign o_done = (state == DONE);

endmodule
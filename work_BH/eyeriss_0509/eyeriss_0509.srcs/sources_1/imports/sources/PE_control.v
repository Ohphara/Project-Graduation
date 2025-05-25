`timescale 1ns / 1ps

module PE_control #(
	parameter DATA_BITWIDTH = 16,

	parameter IFMAP_ADDR_BITWIDTH = 4,
	parameter WGHT_ADDR_BITWIDTH = 8,
	parameter PSUM_ADDR_BITWIDTH = 5
)(
    input i_clk,
    input i_rst,

    //// Interface to TOP CTRL ////
    input i_start,
    input [2:0] i_opcode, //NOP, SET, LOAD_IFMAP, LOAD_WGHT, CONV
    input [8:0] i_conv_info, // p[2:0], q[2:0], s[2:0]

    //// Interface to INST FIFO ////
    input i_valid_fifo_inst,
    output reg o_ready_fifo_inst,

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

    //ISA on FPGA side
    localparam CMD_NOP          = 3'b000;
    localparam CMD_SET          = 3'b001;
    localparam CMD_LOAD_IFMAP   = 3'b010;
    localparam CMD_LOAD_WGHT    = 3'b011;
    localparam CMD_CONV         = 3'b100;

    //States
    localparam  IDLE             = 4'h0;
    localparam  DEC              = 4'h1;
    localparam  NOP              = 4'h2;
    localparam  SET              = 4'h3;    //scan configuration bit and adjust setting
    localparam  LOAD_IFMAP       = 4'h4;
    localparam  LOAD_WGHT        = 4'h5;
    localparam  CONV             = 4'h6;
    localparam  ACC              = 4'h7;
    localparam  RST              = 4'h8;
    localparam  DONE             = 4'h9;

    reg [8:0] conv_info_reg;
    reg [3:0] state;
    reg [3:0] n_state;

    //counter
    reg [2:0] cnt_P;
    reg [2:0] cnt_Q;
    reg [2:0] cnt_S;
    reg [6:0] counter;
    
    wire [2:0] P, Q, S;
    assign {P, Q, S} = conv_info_reg;

    //FSM : state register update
    always @(posedge i_clk) begin
        if(i_rst) begin
            state <= 0;
        end
        else begin
            state <= n_state;
        end
    end

    //capture configuration bit
    always @(posedge i_clk) begin
        if(i_rst)
            conv_info_reg <= 0;
        else if(state == SET)
            conv_info_reg <= i_conv_info;
    end

    //capture opcode
    reg [2:0] opcode_reg;
    always@(posedge i_clk) begin 
        if(i_rst)
            opcode_reg <= 0;
        if(i_start && state==IDLE)
            opcode_reg <= i_opcode;
        else
            opcode_reg <= opcode_reg;
    end


    //FSM : next state logic
    always @(*) begin
        case(state)
            IDLE: begin
                if(i_start)
                    n_state = DEC;
                else
                    n_state = IDLE;
            end
            DEC : begin 
                if (counter == 0) begin
                    case(opcode_reg) // transition state by captured opcode.
                        CMD_NOP         : n_state = NOP;
                        CMD_SET         : n_state = SET;
                        CMD_LOAD_IFMAP  : n_state = LOAD_IFMAP;
                        CMD_LOAD_WGHT   : n_state = LOAD_WGHT;
                        CMD_CONV        : n_state = CONV;
                        default         : n_state = IDLE;
                    endcase 
                end else begin 
                    n_state = DEC;
                end
            end
            NOP: begin
                if(counter == 0)
                    n_state = DONE;
                else
                    n_state = NOP;
            end
            SET: begin
                if(counter == 0)
                    n_state = DONE;
                else
                    n_state = SET;
            end
            LOAD_IFMAP: begin
                if(counter == 0)
                    n_state = DONE;
                else
                    n_state = LOAD_IFMAP;
            end
            LOAD_WGHT: begin
                if(counter == 0)
                    n_state = DONE;
                else
                    n_state = LOAD_WGHT;
            end
            CONV: begin
                if(counter == 0)
                    n_state = ACC;
                else
                    n_state = CONV;
            end
            ACC: begin
                if(counter == 0)
                    n_state = DONE;
                else
                    n_state = ACC;
            end
            RST: begin
                if(counter == 0)
                    n_state = DONE;
                else
                    n_state = RST;
            end
            DONE: begin
                n_state = IDLE;
            end
        endcase
    end
    

    //counter for general purpose
    always @(posedge i_clk) begin
        if (i_rst) begin
            counter <= 0;
        end else begin
            if (counter > 0) begin
                counter <= counter - 1;
            end else begin
                case (n_state)
                    // Defines how many cycles the system should stay in the current state
                    IDLE            : counter <= 0;
                    DEC             : counter <= 0;
                    SET             : counter <= 0;
                    NOP             : counter <= 0;
                    LOAD_IFMAP      : counter <= Q * S - 1;
                    LOAD_WGHT       : counter <= P * Q * S - 1;
                    CONV            : counter <= P * Q * S - 1;
                    ACC             : counter <= P - 1;
                    DONE            : counter <= 0;
                    default           : counter <= 0;
                endcase
            end
        end
    end

    //counter for convolution
    always @(posedge i_clk) begin
        if(i_rst) begin
            cnt_P <= 0; 
            cnt_Q <= 0; 
            cnt_S <= 0; 
        end
        else begin
            if(n_state != state) begin
                cnt_P <= 0; 
                cnt_S <= 0; 
                cnt_Q <= 0;
            end
            else if(state == CONV || state == ACC) begin
                cnt_P <= (cnt_P == P - 1) ? 0 : cnt_P + 1; 
                cnt_S <= (cnt_P == P - 1) ? ((cnt_S == S - 1) ? 0 : cnt_S + 1) : cnt_S;
                cnt_Q <= (cnt_P == P - 1) ? ((cnt_S == S - 1) ? ((cnt_Q == Q - 1) ? 0 : cnt_Q + 1) : cnt_Q) : cnt_Q;
            end
            else begin
                cnt_P <= 0; 
                cnt_S <= 0; 
                cnt_Q <= 0;
            end
        end
    end


    always @(*) begin
        case(state)
            IDLE: begin
                o_ready_fifo_inst = 0;

                o_ifmap_ra = 0;
                o_wght_ra = 0;
                o_psum_ra = 0;
            
                o_ifmap_wa = 0;
                o_wght_wa = 0;
                o_psum_wa = 0;
                o_ifmap_we = 0;
                o_wght_we = 0;
                o_psum_we = 0;
                o_acc_sel = 0;
                o_rst_psum = 0;
            end
            DEC: begin
                o_ready_fifo_inst = 1;

                o_ifmap_ra = 0;
                o_wght_ra = 0;
                o_psum_ra = 0;
            
                o_ifmap_wa = 0;
                o_wght_wa = 0;
                o_psum_wa = 0;
                o_ifmap_we = 0;
                o_wght_we = 0;
                o_psum_we = 0;
                o_acc_sel = 0;
                o_rst_psum = 0;
            end
            NOP: begin
                o_ready_fifo_inst = 0;

                o_ifmap_ra = 0;
                o_wght_ra = 0;
                o_psum_ra = 0;
            
                o_ifmap_wa = 0;
                o_wght_wa = 0;
                o_psum_wa = 0;
                o_ifmap_we = 0;
                o_wght_we = 0;
                o_psum_we = 0;
                o_acc_sel = 0;
                o_rst_psum = 0;
            end
            LOAD_IFMAP: begin
                o_ready_fifo_inst = 0;

                o_ifmap_ra = 0;
                o_wght_ra = 0;
                o_psum_ra = 0;
            
                o_ifmap_wa = cnt_S + (S * cnt_Q);
                o_ifmap_we = 1;

                o_wght_wa = 0;
                o_wght_we = 0;

                o_psum_wa = 0;
                o_psum_we = 0;

                o_acc_sel = 0;
                o_rst_psum = 0;
            end
            LOAD_WGHT: begin
                o_ready_fifo_inst = 0;

                o_ifmap_ra = 0;
                o_wght_ra = 0;
                o_psum_ra = 0;
            
                o_ifmap_wa = 0;
                o_ifmap_we = 0;

                o_wght_wa = cnt_P + (P * cnt_S) + (P * S * cnt_Q);
                o_wght_we = 1;

                o_psum_wa = 0;
                o_psum_we = 0;

                o_acc_sel = 0;
                o_rst_psum = 0;
            end
            CONV: begin
                o_ready_fifo_inst = 0;

                o_ifmap_ra = cnt_S + (S * cnt_Q);
                o_wght_ra = cnt_P + (P * cnt_S) + (P * S * cnt_Q);
                o_psum_ra = cnt_P;
            
                o_ifmap_wa = 0;
                o_ifmap_we = 0;

                o_wght_wa = 0;
                o_wght_we = 0;

                o_psum_wa = cnt_P;
                o_psum_we = 1;

                o_acc_sel = 0;
                o_rst_psum = (cnt_S == 0) && (cnt_Q == 0);
            end
            ACC: begin
                o_ready_fifo_inst = 0;

                o_ifmap_ra = 0;
                o_wght_ra = 0;
                o_psum_ra = cnt_P;
            
                o_ifmap_wa = 0;
                o_ifmap_we = 0;

                o_wght_wa = 0;
                o_wght_we = 0;

                o_psum_wa = 0;
                o_psum_we = 0;

                o_acc_sel = 1;
                o_rst_psum = 0;
            end
            DONE: begin
                o_ready_fifo_inst = 0;

                o_ifmap_ra = 0;
                o_wght_ra = 0;
                o_psum_ra = 0;
            
                o_ifmap_wa = 0;
                o_ifmap_we = 0;

                o_wght_wa = 0;
                o_wght_we = 0;

                o_psum_wa = 0;
                o_psum_we = 0;

                o_acc_sel = 0;
                o_rst_psum = 0;
            end
        endcase
    end

endmodule
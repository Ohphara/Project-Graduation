`timescale 1ns / 1ps
(* USE_DSP = "yes" *) module PE_new #(
    parameter IFMAP_ADDR_BITWIDTH  = 7,
    parameter WEIGHT_ADDR_BITWIDTH = 9,
    parameter PSUM_ADDR_BITWIDTH   = 6,
    parameter DATA_BITWIDTH        = 8,
    parameter PSUM_BITWIDTH        = 21
)
(
    input clk,
    input rst,

    input mul_sel, // 0: psum_reg + mul_reg, 1: psum_reg + external psum

    input [DATA_BITWIDTH-1:0] ifmap_data,
    input [DATA_BITWIDTH-1:0] weight_data,

    input spad
);

// ================================================	//
// SPAD instantiation
// ================================================	//


    // SPad wires
    wire signed [PSUM_BITWIDTH-1:0] psum_data;

    // Pipeline registers
    reg signed [DATA_BITWIDTH-1:0] ifmap_reg, weight_reg;
    reg signed [PSUM_BITWIDTH-1:0] psum_reg;
    reg signed [(2*DATA_BITWIDTH)-1:0] mul_reg;

    reg signed [PSUM_BITWIDTH-1:0] psum_out;

/*
    SPad #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH)
    )
    ifmap_spad (
        .clk(clk),
        .rst(rst),
        .re(ifmap_re),
        .we(ifmap_we),
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
        .re(weight_re),
        .we(weight_we),
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
        .re(psum_re),
        .we(psum_we),
        .r_addr(psum_r_addr), 
        .w_addr(psum_w_addr),
        .w_data(psum_out),
        .r_data(psum_data)
    );
*/

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
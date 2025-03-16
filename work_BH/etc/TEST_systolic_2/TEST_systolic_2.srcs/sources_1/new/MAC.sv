`timescale 1 ns / 1 ps

module MAC
#(
    parameter IFMAP_BITWIDTH                                            = 8,
    parameter W_BITWIDTH                                                = 8,
    parameter PSUM_BITWIDTH                                             = 16
)
(
    input logic clk,
    input logic rst_n,

    input logic ifmap_enable_in,
    input logic signed [IFMAP_BITWIDTH-1:0] ifmap_data_in,

    input logic w_enable_in,
    input logic signed [W_BITWIDTH-1:0] w_data_in,

    input logic psum_enable_in,
    input logic signed [PSUM_BITWIDTH-1:0] psum_data_in,

    output logic ifmap_valid_out,
    output logic signed [IFMAP_BITWIDTH-1:0] ifmap_data_out,

    output logic signed [W_BITWIDTH-1:0] w_data_out,
    
    output logic psum_valid_out,
    output logic signed [PSUM_BITWIDTH-1:0] psum_data_out
);

    always @(posedge clk) begin
        // wegiht prefetch logic
        if (!rst_n) begin
            w_data_out          <=      {(W_BITWIDTH){1'b0}};
        end
        else if (w_enable_in) begin
            w_data_out          <=      w_data_in;
        end
        else begin
            w_data_out          <=      w_data_out;
        end

        // ifmap forwarding logic
        if (!rst_n) begin
            ifmap_data_out      <=      {(IFMAP_BITWIDTH){1'b0}};
            ifmap_valid_out     <=      0;
        end
        else if (ifmap_enable_in)begin
            ifmap_data_out      <=      ifmap_data_in;
            ifmap_valid_out     <=      ifmap_enable_in;
        end
        else begin
            ifmap_data_out      <=      ifmap_data_out;
            ifmap_valid_out     <=      0;
        end

        // psum MAC operation & psum forwarding logic
        if (!rst_n) begin
            psum_data_out       <=      {(PSUM_BITWIDTH){1'b0}};
            psum_valid_out      <=      0;
        end
        else if (ifmap_valid_out && psum_enable_in) begin
            psum_data_out       <=      psum_data_in + ifmap_data_out * w_data_out;
            psum_valid_out      <=      psum_enable_in;
        end
        else begin
            psum_data_out       <=      psum_data_out;
            psum_valid_out      <=      psum_valid_out;
        end 
    end
endmodule
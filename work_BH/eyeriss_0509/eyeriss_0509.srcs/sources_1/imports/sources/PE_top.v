`timescale 1ns / 1ps

module PE_top #(
    parameter DATA_BITWIDTH = 16,
    parameter PSUM_BITWIDTH = 32,
    parameter IFMAP_ADDR_BITWIDTH = 4,
    parameter WGHT_ADDR_BITWIDTH = 8,
    parameter PSUM_ADDR_BITWIDTH = 5,
    parameter P = 6,
    parameter Q = 4,
    parameter S = 3
)(
    input clk,
    input rst,

    input start,

	input signed [DATA_BITWIDTH-1:0] ifmap_in,
	input signed [DATA_BITWIDTH-1:0] wght_in,
	input signed [PSUM_BITWIDTH-1:0] psum_in,

    output o_idle, o_load, o_conv, o_done,

    output signed [PSUM_BITWIDTH-1:0] psum_out
);

    wire [IFMAP_ADDR_BITWIDTH-1:0] ifmap_ra, ifmap_wa;
    wire [WGHT_ADDR_BITWIDTH-1:0]  wght_ra, wght_wa;
    wire [PSUM_ADDR_BITWIDTH-1:0]  psum_ra, psum_wa;

    wire ifmap_we, wght_we, psum_we;
    wire acc_sel, rst_psum;

    PE_control #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .PSUM_BITWIDTH(PSUM_BITWIDTH),
        .IFMAP_ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH),
        .WGHT_ADDR_BITWIDTH(WGHT_ADDR_BITWIDTH),
        .PSUM_ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH),
        .P(P),
        .Q(Q),
        .S(S)
    ) control (
        .clk(clk),
        .rst(rst),
        .start(start),
        .o_idle(o_idle),
        .o_load(o_load),
        .o_conv(o_conv),
        .o_done(o_done),
        .ifmap_ra(ifmap_ra),
        .wght_ra(wght_ra),
        .psum_ra(psum_ra),
        .ifmap_wa(ifmap_wa),
        .wght_wa(wght_wa),
        .psum_wa(psum_wa),
        .ifmap_we(ifmap_we),
        .wght_we(wght_we),
        .psum_we(psum_we),
        .acc_sel(acc_sel),
        .rst_psum(rst_psum)
    );

    PE_datapath #(
        .DATA_BITWIDTH(DATA_BITWIDTH),

        .IFMAP_ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH),
        .WGHT_ADDR_BITWIDTH(WGHT_ADDR_BITWIDTH),
        .PSUM_ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
    ) u_PE_datapath (
        .i_clk(),
        .i_rst(),

        .i_ifmap_data(),
        .i_wght_data(),
        .i_psum_data(),
        .o_psum_data(),

        //controller interface
        .i_acc_sel(),
        .i_rst_psum(),

        .i_ifmap_ra(),
        .i_wght_ra(),
        .i_psum_ra(),
        
        .i_ifmap_wa(),
        .i_wght_wa(),
        .i_psum_wa(),

        .i_ifmap_we(),
        .i_wght_we(),
        .i_psum_we()
    );

endmodule
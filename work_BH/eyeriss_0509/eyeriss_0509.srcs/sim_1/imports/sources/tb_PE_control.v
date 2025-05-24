
`timescale 1ns / 1ps

module tb_PE_control;

    // Parameters
    parameter DATA_BITWIDTH = 16;
    parameter PSUM_BITWIDTH = 32;

    parameter IFMAP_ADDR_BITWIDTH = 4;
    parameter WGHT_ADDR_BITWIDTH = 8;
    parameter PSUM_ADDR_BITWIDTH = 5;

    parameter P = 6;
    parameter Q = 4;
    parameter S = 3;

    // DUT I/Os
    reg i_clk, i_rst, i_start;
    wire o_idle, o_load, o_conv, o_done;

    wire [IFMAP_ADDR_BITWIDTH-1:0] ifmap_ra;
    wire [WGHT_ADDR_BITWIDTH-1:0] wght_ra;
    wire [PSUM_ADDR_BITWIDTH-1:0] psum_ra;
    wire [IFMAP_ADDR_BITWIDTH-1:0] ifmap_wa;
    wire [WGHT_ADDR_BITWIDTH-1:0] wght_wa;
    wire [PSUM_ADDR_BITWIDTH-1:0] psum_wa;
    wire ifmap_we, wght_we, psum_we;
    wire o_acc_sel, o_rst_psum;

    // Clock generation
    initial i_clk = 0;
    always #5 i_clk = ~i_clk; // 100MHz

    // DUT instantiation
    PE_control #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .PSUM_BITWIDTH(PSUM_BITWIDTH),
        .IFMAP_ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH),
        .WGHT_ADDR_BITWIDTH(WGHT_ADDR_BITWIDTH),
        .PSUM_ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH),
        .P(P),
        .Q(Q),
        .S(S)
    ) dut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(i_start),
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
        .o_acc_sel(o_acc_sel),
        .o_rst_psum(o_rst_psum)
    );

    // Monitoring and counters
    integer ifmap_we_count = 0;
    integer wght_we_count = 0;
    integer psum_we_count = 0;

    always @(posedge i_clk) begin
        if (ifmap_we) ifmap_we_count = ifmap_we_count + 1;
        if (wght_we)  wght_we_count = wght_we_count + 1;
        if (psum_we)  psum_we_count = psum_we_count + 1;
    end

    initial begin
        // Initial state
        i_rst = 1;
        i_start = 0;

        #20;
        i_rst = 0;
        #10;

        // Trigger i_start
        i_start = 1;
        #10;
        i_start = 0;

        // Wait for DONE signal
        wait (o_done);
        #10;

        // Show results
        $display("=== Test Summary ===");
        $display("ifmap_we_count = %0d (expected %0d)", ifmap_we_count, Q * S);
        $display("wght_we_count  = %0d (expected %0d)", wght_we_count, P * Q * S);
        $display("psum_we_count  = %0d (expected %0d)", psum_we_count, P * Q * S);

        if (ifmap_we_count == Q*S && wght_we_count == P*Q*S && psum_we_count == P*Q*S)
            $display("Test PASSED");
        else
            $display("Test FAILED");

        $stop;
    end

endmodule

`timescale 1ns / 1ps

module tb_PE_primitive;

    parameter DATA_BITWIDTH = 8;
    parameter PSUM_BITWIDTH = 20;

    reg clk, reset;
    reg [DATA_BITWIDTH-1:0] ifmap_data;
    reg [DATA_BITWIDTH-1:0] weight_data;
    reg mac_en;

    wire [PSUM_BITWIDTH-1:0] psum_out;
    wire psum_valid;

    // DUT
    PE_primitive #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .PSUM_BITWIDTH(PSUM_BITWIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .ifmap_data(ifmap_data),
        .weight_data(weight_data),
        .mac_en(mac_en),
        .psum_out(psum_out),
        .psum_valid(psum_valid)
    );

    // Clock
    always #5 clk = ~clk;

    // integer 선언은 initial 바깥에서
    integer i;

    reg [7:0] ifmap_stream [0:5];  // 6 elements
    reg [7:0] weight_stream [0:2]; // 3 elements

    initial begin
        clk = 0;
        reset = 1;
        mac_en = 0;
        ifmap_data = 0;
        weight_data = 0;

        #10;
        reset = 0;

        // Initialize streams
        ifmap_stream[0] = 1;
        ifmap_stream[1] = 2;
        ifmap_stream[2] = 3;
        ifmap_stream[3] = 4;
        ifmap_stream[4] = 5;
        ifmap_stream[5] = 6;

        weight_stream[0] = 1;
        weight_stream[1] = 2;
        weight_stream[2] = 3;

        // 1st psum
        for (i = 0; i < 3; i = i + 1) begin
            ifmap_data <= ifmap_stream[i];
            weight_data <= weight_stream[i];
            mac_en <= 1;
            #10;
        end
        mac_en <= 0;
        #10;

        // 2nd psum
        for (i = 1; i < 4; i = i + 1) begin
            ifmap_data <= ifmap_stream[i];
            weight_data <= weight_stream[i-1];
            mac_en <= 1;
            #10;
        end
        mac_en <= 0;
        #10;

        // 3rd psum
        for (i = 2; i < 5; i = i + 1) begin
            ifmap_data <= ifmap_stream[i];
            weight_data <= weight_stream[i-2];
            mac_en <= 1;
            #10;
        end
        mac_en <= 0;
        #10;

        repeat (5) #10;
        $stop;
    end

endmodule
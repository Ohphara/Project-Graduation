`timescale 1ns / 1ps

module tb_PE_core;

    // Parameters
    localparam DATA_BITWIDTH   = 8;
    localparam PSUM_BITWIDTH   = 20;
    localparam PSUM_SPAD_ADDR  = 9;
    localparam OFMAP_SIZE      = 3;

    // DUT Signals
    reg clk;
    reg reset;
    reg start;

    // Target conv information
    reg [9:0] ifmap_width;
    reg [2:0] kernel_width;
    reg [7:0] o_channel;
    reg [2:0] stride;
    reg [2:0] padding;
    

    reg [DATA_BITWIDTH-1:0] ifmap_data;
    reg [DATA_BITWIDTH-1:0] weight_data;

    reg [PSUM_SPAD_ADDR-1:0] ctrl_psum_ra;
    reg [PSUM_SPAD_ADDR-1:0] ctrl_psum_wa;
    reg ctrl_psum_we;
    reg ctrl_op_mode;

    reg [PSUM_BITWIDTH-1:0] psum_in;

    wire [PSUM_BITWIDTH-1:0] psum_out;
    wire o_idle, o_run, o_done;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    // Instantiate DUT
    PE_core #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .PSUM_BITWIDTH(PSUM_BITWIDTH),
        .PSUM_SPAD_ADDR(PSUM_SPAD_ADDR),
        .OFMAP_SIZE(OFMAP_SIZE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .ifmap_data(ifmap_data),
        .weight_data(weight_data),
        .ctrl_psum_ra(ctrl_psum_ra),
        .ctrl_psum_wa(ctrl_psum_wa),
        .ctrl_psum_we(ctrl_psum_we),
        .ctrl_op_mode(ctrl_op_mode),
        .psum_in(psum_in),
        .psum_out(psum_out),
        .o_idle(o_idle),
        .o_run(o_run),
        .o_done(o_done)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset pulse
    initial begin
        reset = 0;
        #10;
        reset = 1;
        #10;
        reset = 0;
    end

    // Set up conv parameters
    initial begin
        ifmap_width = 640;    // Input size
        kernel_width = 3;     // Kernel width
        o_channel = 32;       // Output channels
        stride = 3;           // Stride (변경 가능)
        padding = 0;          // Padding (변경 가능)
    end

    //initialize
    initial begin
        start = 0;
        ifmap_data = 0;
        weight_data = 0;
        ctrl_psum_ra = 0;
        ctrl_psum_wa = 0;
        ctrl_psum_we = 0;
        ctrl_op_mode = 0; // CONV 모드
        psum_in = 0;
    end

    initial begin
        #10
        start = 1;
        ctrl_op_mode = 0;

        #10
        start = 0;
        

    end

        // 9번 공급
        for (i = 0; i < 9; i = i + 1) begin
            if(i==0)
                start = 1;
            if(i==1)
                start = 0;
            ifmap_data = ifmap_pattern[i];
            weight_data = weight_pattern[i];
            if(i%3 == 2) begin
                ctrl_psum_we = 1;
            end
            else begin
                ctrl_psum_we = 0;
            end
            #10;
        end

        // 결과 기다림
        wait (o_done == 1);
        #10;

        $display("=== Simulation Complete ===");
        $display("psum_out = %d", psum_out);
        $finish;
    end

endmodule

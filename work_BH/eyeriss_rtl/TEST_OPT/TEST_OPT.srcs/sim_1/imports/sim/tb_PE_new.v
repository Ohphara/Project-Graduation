`timescale 1ns / 1ps
module tb_PE_new();

    parameter DATA_BITWIDTH = 16;
    parameter kernel_size = 3;
    parameter act_size = 5;
    
    integer i;

	reg clk, rst;

	reg signed [DATA_BITWIDTH-1:0] act_in;
	reg signed [DATA_BITWIDTH-1:0] filt_in;

	reg start;
	reg load_en_wght, load_en_act;
	
	wire signed [DATA_BITWIDTH-1:0] pe_out;

	wire compute_done;
	wire load_done;

    PE_new dut(
        .clk(clk),
        .rst(rst),
        .act_in(act_in),
        .filt_in(filt_in),
        .start(start),
        .load_en_wght(load_en_wght),
        .load_en_act(load_en_act),
        .pe_out(pe_out),
        .compute_done(compute_done),
        .load_done(load_done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        act_in = 0;
        filt_in = 0;
        start = 0;
        load_en_wght = 0;
        load_en_act = 0;

        // Reset Pulse
        #20;
        rst = 0;
        #20;

        // Step 1: Load Weights
        $display("=== Loading Weights ===");
        load_en_wght = 1;
        for(i=0; i<kernel_size; i=i+1) begin
            filt_in = i+1;  // Example weight
            #10;
        end
        load_en_wght = 0;

        // Step 2: Load Activations
        wait (load_done == 1);
        #30
        $display("=== Loading Activations ===");
        load_en_act = 1;
        for(i=0; i<act_size; i=i+1) begin
            act_in = i+1;
            #10;
        end
        load_en_act = 0;

        // Step 3: Start Computation
        wait (load_done == 1);
        #50;
        $display("=== Starting Computation ===");
        start = 1;
        #10;
        start = 0;

        // Wait for computation to complete
        wait (compute_done == 1);

        // Finish Simulation
        #100;
        $display("=== Test Completed ===");
        $finish;
    end

endmodule
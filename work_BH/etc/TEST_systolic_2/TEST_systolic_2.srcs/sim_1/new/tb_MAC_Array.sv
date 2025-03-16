module tb_MAC_Array;

    // Parameters
    parameter MAC_ROW = 3;
    parameter MAC_COL = 3;
    parameter IFMAP_BITWIDTH = 8;
    parameter W_BITWIDTH = 8;
    parameter PSUM_BITWIDTH = 16;
    parameter CLK_PERIOD = 10; // 10ns 주기 (100MHz)

    // Signals
    logic clk;
    logic rst_n;

    // Inputs to MAC_Array
    logic w_prefetch_in;
    logic w_enable_in;
    logic signed [MAC_COL-1:0][W_BITWIDTH-1:0] w_data_in;
    logic ifmap_start_in;
    logic [MAC_ROW-1:0] ifmap_enable_in;
    logic signed [MAC_ROW-1:0][IFMAP_BITWIDTH-1:0] ifmap_data_in;

    // Outputs from MAC_Array
    logic [MAC_COL-1:0] ofmap_valid_out;
    logic signed [MAC_COL-1:0][PSUM_BITWIDTH-1:0] ofmap_data_out;

    // Clock Generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // MAC_Array Instantiation
    MAC_Array #(
        .MAC_ROW(MAC_ROW),
        .MAC_COL(MAC_COL),
        .IFMAP_BITWIDTH(IFMAP_BITWIDTH),
        .W_BITWIDTH(W_BITWIDTH),
        .OFMAP_BITWIDTH(PSUM_BITWIDTH)
    ) mac_array_inst (
        .clk(clk),
        .rst_n(rst_n),
        .w_prefetch_in(w_prefetch_in),
        .w_enable_in(w_enable_in),
        .w_data_in(w_data_in),
        .ifmap_start_in(ifmap_start_in),
        .ifmap_enable_in(ifmap_enable_in),
        .ifmap_data_in(ifmap_data_in),
        .ofmap_valid_out(ofmap_valid_out),
        .ofmap_data_out(ofmap_data_out)
    );

    // Testbench Procedure
    initial begin
        // Initialize test matrices
        logic [MAC_COL-1:0][W_BITWIDTH-1:0] weight_mat [MAC_ROW];
        logic [MAC_ROW-1:0][IFMAP_BITWIDTH-1:0] ifmap_mat [MAC_COL];
        
        // Reset
        clk = 0;
        rst_n = 0;
        w_prefetch_in = 0;
        w_enable_in = 0;
        foreach(w_data_in[i,j]) w_data_in[i][j] = '0;
        ifmap_start_in = 0;
        foreach(ifmap_enable_in[i]) ifmap_enable_in[i] = '0;
        foreach(ifmap_data_in[i,j]) ifmap_data_in[i][j] = '0;
        repeat(3) @(posedge clk);
        rst_n = 1;
        
        // Initialize test matrices with simple values
        for (int i = 0; i < MAC_ROW; i++) begin
            for (int j = 0; j < MAC_COL; j++) begin
                weight_mat[i][j]    = MAC_ROW*i + j + 1;
                ifmap_mat[i][j]     = MAC_ROW*i + j + 1;
            end
        end

        // Load weights into MAC array
        w_enable_in = 1;
        for(int i=0; i<MAC_ROW; i=i+1) begin
            w_data_in = weight_mat[(MAC_ROW-1)-i];
            #CLK_PERIOD;
        end        
        w_enable_in = 0;

        #CLK_PERIOD;

        // Provide input activations to the MAC array
        for (int cycle = 0; cycle < (2 * MAC_COL - 1); cycle++) begin
            // 초기화
            ifmap_enable_in = '0;
            ifmap_data_in = '{default: '0};

            for (int row = 0; row < MAC_ROW; row++) begin
                int col = cycle - row;

                if (col >= 0 && col < MAC_COL) begin // 유효한 인덱스일 때만 값 공급
                    ifmap_enable_in[row] = 1'b1;
                    ifmap_data_in[row] = ifmap_mat[row][col];
                end
            end
            #CLK_PERIOD;
        end

        ifmap_enable_in = '0;
        ifmap_data_in = '{default: '0};
        #CLK_PERIOD;


        // Wait for computations to propagate through MAC array
        repeat(2*MAC_ROW) @(posedge clk);

        
        // End simulation
        #100;
        $finish;
    end

    // Monitor outputs
    always @(posedge clk) begin
        $display("MAC_Array Output: ofmap_valid_out=%b, ofmap_data_out=%d, %d, %d",
            ofmap_valid_out, ofmap_data_out[0], ofmap_data_out[1], ofmap_data_out[2]);
    end

endmodule
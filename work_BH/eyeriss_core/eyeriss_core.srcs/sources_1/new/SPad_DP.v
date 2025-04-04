module SPad_DP #(
    parameter DATA_BITWIDTH = 8,                        // Specify RAM data width
    parameter ADDR_BITWIDTH = 9,                   // Specify RAM address depth (i.e., log2(RAM_DEPTH))
    parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one
)(
    input clk,
    input [ADDR_BITWIDTH-1:0] addra,               // Port A address bus
    input [ADDR_BITWIDTH-1:0] addrb,               // Port B address bus
    input [DATA_BITWIDTH-1:0] dinb,                     // Port B RAM input data
    input web,                                      // Port B write enable
    output [DATA_BITWIDTH-1:0] douta                    // Port A RAM output data
);

    localparam RAM_DEPTH = (1 << ADDR_BITWIDTH);   // Compute actual RAM depth

    reg [DATA_BITWIDTH-1:0] BRAM [0:RAM_DEPTH-1];
    reg [DATA_BITWIDTH-1:0] ram_data_a = {DATA_BITWIDTH{1'b0}};

    // Memory initialization for Xilinx FPGA
    generate
        if (INIT_FILE != "") 
        begin: use_init_file
            initial
                $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
        end 
        else 
        begin: init_bram_to_zero
            integer ram_index;
            initial begin
                for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
                    BRAM[ram_index] = {DATA_BITWIDTH{1'b0}};
            end
        end
    endgenerate

    //read only port a
    always @(posedge clk) begin
        ram_data_a <= BRAM[addra];
    end

    assign douta = ram_data_a;

    //write only port b
    always @(posedge clk) begin
        if (web)
            BRAM[addrb] <= dinb;
    end

endmodule
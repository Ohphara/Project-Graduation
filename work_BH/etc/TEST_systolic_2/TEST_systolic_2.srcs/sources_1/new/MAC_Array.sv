`timescale 1 ns / 1 ps

module MAC_Array
#(
    parameter MAC_ROW                                                       = 3,
    parameter MAC_COL                                                       = 3,
    parameter IFMAP_BITWIDTH                                                = 8,
    parameter W_BITWIDTH                                                    = 8,
    parameter OFMAP_BITWIDTH                                                = 16
)
(
    input  logic                                                            clk,
    input  logic                                                            rst_n,

    input  logic                                                            w_prefetch_in,      // Not used in this module

    input  logic                                                            w_enable_in,
    input  logic signed [MAC_COL-1:0][W_BITWIDTH-1:0]                       w_data_in,

    input  logic                                                            ifmap_start_in,     // Not used in this module

    input  logic        [MAC_ROW-1:0]                                       ifmap_enable_in,
    input  logic signed [MAC_ROW-1:0][IFMAP_BITWIDTH-1:0]                   ifmap_data_in,

    output logic        [MAC_COL-1:0]                                       ofmap_valid_out,
    output logic signed [MAC_COL-1:0][OFMAP_BITWIDTH-1:0]                   ofmap_data_out
);
    // your code here

    // Below are wire for PE interconnection
    logic [MAC_ROW-1:0]                     ifmap_valid [MAC_COL:0];
    logic [MAC_ROW-1:0][IFMAP_BITWIDTH-1:0] ifmap_data  [MAC_COL:0];
    
    logic [MAC_COL-1:0][W_BITWIDTH-1:0]     w_data      [MAC_ROW:0];

    logic [MAC_COL-1:0]                     psum_valid  [MAC_ROW:0];
    logic [MAC_COL-1:0][OFMAP_BITWIDTH-1:0] psum_data   [MAC_ROW:0];


    assign                                  ifmap_valid [0]     =   ifmap_enable_in;
    assign                                  ifmap_data  [0]     =   ifmap_data_in;

    assign                                  w_data      [0]     =   w_data_in;

    // to initiate psum accumulation with traversing PEs
    assign                                  psum_valid  [0]     =   {(MAC_COL){1'b1}};
    assign                                  psum_data   [0]     =   {(MAC_COL * W_BITWIDTH){1'b0}};

    // Not [MAC_ROW-1]!! because these are wires from last row of PE array 
    assign                                  ofmap_valid_out     =   psum_valid  [MAC_ROW];
    assign                                  ofmap_data_out      =   psum_data   [MAC_ROW];

    // i for row, j for col
    genvar i, j;
    generate
        for (i = 0; i < MAC_ROW; i++) begin: row_iter
            for (j = 0; j < MAC_COL; j++) begin: col_iter
                MAC
                #(
                    .IFMAP_BITWIDTH                         ( IFMAP_BITWIDTH            ),
                    .W_BITWIDTH                             ( W_BITWIDTH                ),
                    .PSUM_BITWIDTH                          ( OFMAP_BITWIDTH            )   
                )
                MACunit
                // vertically forwarding    -> mapping via [i][j]
                // horizontally forwarding  -> mapping via [j][i]
                (
                    .clk                                    ( clk                       ),
                    .rst_n                                   ( rst_n                      ),
                    
                    .ifmap_enable_in                        ( ifmap_valid   [j][i]      ),
                    .ifmap_data_in                          ( ifmap_data    [j][i]      ),

                    .w_enable_in                            ( w_enable_in               ),
                    .w_data_in                              ( w_data        [i][j]      ),

                    .psum_enable_in                         ( psum_valid    [i][j]      ),
                    .psum_data_in                           ( psum_data     [i][j]      ),

                    .ifmap_valid_out                        ( ifmap_valid   [j+1][i]    ),
                    .ifmap_data_out                         ( ifmap_data    [j+1][i]    ),
                    
                    .w_data_out                             ( w_data        [i+1][j]    ),

                    .psum_valid_out                         ( psum_valid    [i+1][j]    ),
                    .psum_data_out                          ( psum_data     [i+1][j]    )        
                );
            end
        end
    endgenerate

endmodule
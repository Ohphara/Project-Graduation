//global input network for communication between GLB and PE Array.
module GIN_YBUS #(
    parameter DATA_BITWIDTH = 16,
    parameter COL_LEN = 6
)(
    input i_clk,
    input i_rst,

    //fifo interface
    input i_fifo_data,
    input i_fifo_valid,
    output o_fifo_ready,

    //top control interface
    input [5:0] i_tag,

    //xbus interface
    input [COL_LEN-1:0] i_bus_ready,
    output o_bus_valid
    output [DATA_BITWIDTH-1:0] o_bus_data,
    output [2:0] o_tag
);

    wire [2:0] tag_row, tag_col;
    assign {tag_row, tag_col} = i_tag;

    wire                ybus_ready;
    wire [COL_LEN-1:0]  xbus_ready;
    
    assign ybus_ready = & xbus_ready; 
    assign o_fifo_ready = ybus_ready;

    genvar i;
    generate
        for(i=0; i<COL_LEN; i=i+1) begin: YBUS_MC_gen
            MC #(
                .DATA_BITWIDTH(DATA_BITWIDTH)
            ) u_MC (
                .i_clk(i_clk),
                .i_rst(i_rst),

                .i_id(i), //comes from config scan chain
                .i_tag(tag_row), //determined by GIN X-BUS and Y-BUS
                
                .i_data(i_data),
                .i_valid(i_fifo_valid),
                .o_ready(xbus_ready[i]),

                .i_ready(xbus_ready[i]),
                .o_valid(ybus_valid),
                .o_data(o_data)
            );
        end
    endgenerate


    fifo #(
        .QUEUE_PTR_BANDWIDTH(),
        .ELE_BANDWIDTH(),
    ) u_fifo (
        .i_clk(),
        .i_rst(),

        //FIFO interface as rx
        .i_push_data(),
        .i_valid(),
        .o_ready(),

        //FIFO interface as tx
        .i_ready(),         
        .o_valid(),
        .o_pop_data()
    );



endmodule
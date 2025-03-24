module PE_core #(
    parameter DATA_BITWIDTH = 8,
    parameter PSUM_BITWIDTH = 20,
    parameter PSUM_SPAD_DEPTH = 512,
    parameter PSUM_SPAD_ADDR = 9
)(
    input clk, rst,

    input [DATA_BITWIDTH-1:0] ifmap_data,
    input [DATA_BITWIDTH-1:0] weight_data,

    input [PSUM_SPAD_ADDR-1:0] psum_spad_ra,
    input [PSUM_SPAD_ADDR-1:0] psum_spad_wa,

    input [PSUM_BITWIDTH-1:0] psum_in,

    input mux_sel,

    input status,

    output [PSUM_BITWIDTH-1:0] psum_out,
    output o_done
);


    reg [2*DATA_BITWIDTH-1:0] mul_reg;
    always @(posedge clk)
    begin
        if(rst)
        begin
            mul_reg <= 0;
        end
        else
        begin
            mul_reg <= ifmap_data * weight_data;
        end 
    end

    reg [PSUM_BITWIDTH-1:0] mux_out;
    always @(*)
    begin
        if(mux_sel)
            mux_out = psum_in;
        else
            mux_out = mul_reg;
    end

    wire [PSUM_BITWIDTH-1:0] spad_psum_rd;
    assign psum_out = spad_psum_rd + mux_out;

    SPad_DP #(
        .RAM_WIDTH(PSUM_BITWIDTH),                       // Specify RAM data width
        .RAM_DEPTH(PSUM_SPAD_DEPTH)                     // Specify RAM depth (number of entries)
    ) psum_spad (
        .clk(clk),

        .addra(psum_ra),   // Port A address bus, width determined from RAM_DEPTH
        .addrb(psum_wa),   // Port B address bus, width determined from RAM_DEPTH

        .douta(spad_psum_rd),   // Port A RAM output data, width determined from RAM_WIDTH

        .dinb(psum_acc),     // Port B RAM input data, width determined from RAM_WIDTH
        .web(psum_we)       // Port B write enable
    );


endmodule
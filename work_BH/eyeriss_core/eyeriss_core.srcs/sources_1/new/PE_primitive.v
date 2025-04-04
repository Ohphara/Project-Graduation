module PE_primitive #(
    parameter DATA_BITWIDTH = 8,
    parameter PSUM_BITWIDTH = 20
)(
    input clk, reset,

    input [DATA_BITWIDTH-1:0] ifmap_data,
    input [DATA_BITWIDTH-1:0] weight_data,
    input mac_en,

    output [PSUM_BITWIDTH-1:0] psum_out,
    output psum_valid
);

    wire [PSUM_BITWIDTH-1:0] mac_res;
    wire [PSUM_BITWIDTH-1:0] mux_out;

    reg [DATA_BITWIDTH-1:0] ifmap_reg;
    reg [DATA_BITWIDTH-1:0] weight_reg;

    reg mac_en_reg;
    reg mac_en_reg_d;

    reg [PSUM_BITWIDTH-1:0] psum_reg;

    reg [15:0] ofmap_cnt;

    assign mux_out = (mac_en_reg_d) ? psum_reg : {PSUM_BITWIDTH{1'b0}};
    assign mac_res = (mac_en_reg) ? (ifmap_reg * weight_reg) + mux_out : {PSUM_BITWIDTH{1'b0}};
    assign psum_valid = !mac_en_reg && mac_en_reg_d;
    assign psum_out = psum_reg;

    always @(posedge clk) begin
        if(reset) begin
            ifmap_reg <= 0;
            weight_reg <= 0;
            mac_en_reg <= 0;
            mac_en_reg_d <= 0;
            psum_reg <= 0;
        end
        else begin
            ifmap_reg <= ifmap_data;
            weight_reg <= weight_data;
            mac_en_reg <= mac_en;
            mac_en_reg_d <= mac_en_reg;
            psum_reg <= mac_res;
        end
    end
endmodule
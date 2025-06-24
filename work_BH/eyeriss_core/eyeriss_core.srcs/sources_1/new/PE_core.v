`timescale 1ns / 1ps

module PE_core #(
    parameter DATA_BITWIDTH  = 8,
    parameter PSUM_BITWIDTH  = 20
)(
    input clk,
    input reset,

    // 데이터 입력
    input [DATA_BITWIDTH-1:0] ifmap_data,
    input [DATA_BITWIDTH-1:0] weight_data,
    input mac_en,

    // 연산 횟수 (출력할 psum 개수)
    input [15:0] output_feature_size,

    // 출력
    output [PSUM_BITWIDTH-1:0] psum_out,
    output psum_valid,
    output reg done
);

    // 내부용 feature counter
    reg [15:0] ofmap_cnt;

    wire [PSUM_BITWIDTH-1:0] internal_psum;
    wire internal_valid;

    // PE primitive instantiation
    PE_primitive #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .PSUM_BITWIDTH(PSUM_BITWIDTH)
    ) u_primitive (
        .clk(clk),
        .reset(reset),
        .ifmap_data(ifmap_data),
        .weight_data(weight_data),
        .mac_en(mac_en),
        .psum_out(internal_psum),
        .psum_valid(internal_valid)
    );

    assign psum_out   = internal_psum;
    assign psum_valid = internal_valid;

    // feature count + done 신호 처리
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ofmap_cnt <= 0;
            done <= 0;
        end else if (internal_valid) begin
            if (ofmap_cnt == output_feature_size - 1) begin
                done <= 1;
            end else begin
                ofmap_cnt <= ofmap_cnt + 1;
            end
        end
    end

endmodule
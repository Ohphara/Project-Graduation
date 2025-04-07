`timescale 1ns / 1ps

module SPad 
#(
    parameter DATA_BITWIDTH = 16,
    parameter ADDR_BITWIDTH = 9
)
(
    input                         clk,
    input                         rst,
    input                         re,
    input                         we,
    input  [ADDR_BITWIDTH-1:0]    r_addr,
    input  [ADDR_BITWIDTH-1:0]    w_addr,
    input  signed [DATA_BITWIDTH-1:0] w_data,
    output signed [DATA_BITWIDTH-1:0] r_data
);

    // ----------------------------------------
    // Memory declaration
    // ----------------------------------------
    reg [DATA_BITWIDTH-1:0] mem [0:(1 << ADDR_BITWIDTH) - 1]; 
    reg [DATA_BITWIDTH-1:0] data;

    // ----------------------------------------
    // READ logic
    // ----------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            data <= 0;
        end else if (re) begin
            data <= mem[r_addr];
        end else begin
            data <= 10101;
        end
    end

    assign r_data = data;

    // ----------------------------------------
    // WRITE logic
    // ----------------------------------------
    always @(posedge clk) begin
        if (!rst && we) begin
            mem[w_addr] <= w_data;
        end
    end

endmodule
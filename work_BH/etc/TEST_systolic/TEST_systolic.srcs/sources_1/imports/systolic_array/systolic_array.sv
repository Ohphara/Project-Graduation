`timescale 1ns / 1ps

// Parameterized Systolic Array for matrix multiplication
// Uses DSP48E1 for MAC operations
module systolic_array #(
    parameter ARRAY_SIZE = 8,    // NxN array size
    parameter DATA_WIDTH = 8     // Input data width
)(
    input  logic                                 clk,
    input  logic                                 rst_n,
    input  logic                                 valid_in,
    input  logic [DATA_WIDTH-1:0]                a_inputs [ARRAY_SIZE-1:0], // Input matrix A
    input  logic [DATA_WIDTH-1:0]                b_inputs [ARRAY_SIZE-1:0], // Input matrix B
    output logic [DATA_WIDTH*2+ARRAY_SIZE-1:0]   c_outputs [ARRAY_SIZE-1:0], // Output matrix C
    output logic                                 valid_out
);

    // Internal signals for PE connections
    logic [DATA_WIDTH-1:0] a_wires [ARRAY_SIZE:0][ARRAY_SIZE:0];
    logic [DATA_WIDTH-1:0] b_wires [ARRAY_SIZE:0][ARRAY_SIZE:0];
    logic [DATA_WIDTH*2+ARRAY_SIZE-1:0] c_wires [ARRAY_SIZE:0][ARRAY_SIZE:0];
    
    // Valid signal propagation
    logic valid_regs [ARRAY_SIZE:0][ARRAY_SIZE:0];
    
    // Input assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < ARRAY_SIZE; i++) begin
                a_wires[0][i] <= '0;
                b_wires[i][0] <= '0;
                valid_regs[0][i] <= '0;
                valid_regs[i][0] <= '0;
            end
        end else begin
            for (int i = 0; i < ARRAY_SIZE; i++) begin
                a_wires[0][i] <= a_inputs[i];
                b_wires[i][0] <= b_inputs[i];
                valid_regs[0][i] <= valid_in;
                valid_regs[i][0] <= valid_in;
            end
        end
    end

    // Generate the PE array
    genvar i, j;
    generate
        for (i = 0; i < ARRAY_SIZE; i++) begin : ROW
            for (j = 0; j < ARRAY_SIZE; j++) begin : COL
                processing_element #(
                    .ARRAY_SIZE(ARRAY_SIZE),
                    .DATA_WIDTH(DATA_WIDTH)
                ) pe (
                    .clk(clk),
                    .rst_n(rst_n),
                    .valid_in(valid_regs[i][j]),
                    .a_in(a_wires[i][j]),
                    .b_in(b_wires[i][j]),
                    .c_in((i == 0 || j == 0) ? 0 : c_wires[i][j]),
                    .a_out(a_wires[i+1][j]),
                    .b_out(b_wires[i][j+1]),
                    .c_out(c_wires[i+1][j]),
                    .valid_out(valid_regs[i+1][j+1])
                );
            end
        end
    endgenerate

    // Output assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < ARRAY_SIZE; i++) begin
                c_outputs[i] <= '0;
            end
            valid_out <= 1'b0;
        end else begin
            for (int i = 0; i < ARRAY_SIZE; i++) begin
                c_outputs[i] <= c_wires[ARRAY_SIZE][i];
            end
            valid_out <= valid_regs[ARRAY_SIZE][ARRAY_SIZE];
        end
    end

endmodule

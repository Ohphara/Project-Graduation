// Processing Element (PE) module
module processing_element #(
    parameter ARRAY_SIZE = 8,
    parameter DATA_WIDTH = 8
)(
    input  logic                                 clk,
    input  logic                                 rst_n,
    input  logic                                 valid_in,
    input  logic [DATA_WIDTH-1:0]               a_in,
    input  logic [DATA_WIDTH-1:0]               b_in,
    input  logic [DATA_WIDTH*2+ARRAY_SIZE-1:0]  c_in,
    output logic [DATA_WIDTH-1:0]               a_out,
    output logic [DATA_WIDTH-1:0]               b_out,
    output logic [DATA_WIDTH*2+ARRAY_SIZE-1:0]  c_out,
    output logic                                valid_out
);

    // Registered outputs
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= '0;
            b_out <= '0;
            c_out <= '0;
            valid_out <= 1'b0;
        end else begin
            a_out <= a_in;
            b_out <= b_in;
            // MAC operation using DSP48E1
            c_out <= c_in + (a_in * b_in);
            valid_out <= valid_in;
        end
    end

endmodule
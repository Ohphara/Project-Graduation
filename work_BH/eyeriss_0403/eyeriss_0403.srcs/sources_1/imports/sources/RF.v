module RF #(
    parameter DATA_BITWIDTH = 32,
    parameter ADDR_BITWIDTH = 5 // 2^5 = 32 registers
)(
    input  wire                   clk,
    input  wire                   rst,
    
    // Read Port
    input  wire [ADDR_BITWIDTH-1:0]  ra,
    output wire [DATA_BITWIDTH-1:0]  rd,

    // Write Port
    input  wire                      we,
    input  wire [ADDR_BITWIDTH-1:0]  wa,
    input  wire [DATA_BITWIDTH-1:0]  wd
);

    localparam REG_COUNT = 1 << ADDR_BITWIDTH;

    integer i;

    // Register file memory
    reg [DATA_BITWIDTH-1:0] registers [0:REG_COUNT-1];

    // Write operation (synchronous)
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < REG_COUNT; i = i + 1) begin
                registers[i] <= {DATA_BITWIDTH{1'b0}};
            end
        end 
        else if(we) begin
            registers[wa] <= wd;
        end
    end

    // Read operation (combinational)
    assign rd = registers[ra];
    
endmodule
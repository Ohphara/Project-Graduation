module bram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4  // 16개 데이터 저장 가능
)(
    input wire clk,
    input wire rst,

    // AXI Stream 인터페이스
    input wire [DATA_WIDTH-1:0] tdata,  // DMA에서 들어오는 데이터
    input wire tvalid,                  // 데이터 유효 신호
    output reg tready,                   // 데이터 수신 가능 상태

    // Read/Write 인터페이스
    input wire [ADDR_WIDTH-1:0] addr,    // BRAM 읽기/쓰기 주소
    input wire we,                       // Write Enable
    input wire re,                       // Read Enable
    input wire [DATA_WIDTH-1:0] data_in, // BRAM에 저장할 데이터
    output reg [DATA_WIDTH-1:0] data_out // BRAM에서 읽어온 데이터
);

    // 내부 BRAM 메모리 선언 (Synthesis 가능)
    reg [DATA_WIDTH-1:0] bram_mem [0:(1<<ADDR_WIDTH)-1];

    reg [ADDR_WIDTH-1:0] write_addr;  // AXI-Stream 데이터 저장 주소

    always @(posedge clk) begin
        if (rst) begin
            write_addr <= 0;
            tready <= 1;
        end
        else if (tvalid && tready) begin
            bram_mem[write_addr] <= tdata;
            write_addr <= write_addr + 1;
        end
    end

    // Read/Write Logic (Synthesis 가능하도록 변경)
    always @(posedge clk) begin
        if (we) begin
            bram_mem[addr] <= data_in;  // Write Enable 신호가 활성화되면 데이터 저장
        end
        if (re) begin
            data_out <= bram_mem[addr]; // Read Enable 신호가 활성화되면 데이터 출력
        end
    end
endmodule

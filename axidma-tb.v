`timescale 1ns / 1ps

module axi_dma_tb;

    reg clk;
    reg rst;
    reg [31:0] tdata;
    reg tvalid;
    wire tready;
    integer i;

    // BRAM 인스턴스
    bram uut (
        .clk(clk),
        .rst(rst),
        .tdata(tdata),
        .tvalid(tvalid),
        .tready(tready)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        tvalid = 0;
        #20 rst = 0;

        // 데이터 전송 시작
        for (i = 0; i < 16; i = i + 1) begin
            #10;
            tdata = i + 100;
            tvalid = 1;
            while (!tready) #5;
            #10;
        end

        tvalid = 0;

        // BRAM 데이터 확인
        #50;
        $display("BRAM Data:");
        for (i = 0; i < 16; i = i + 1) begin
            $display("BRAM[%0d] = %0d", i, uut.bram_mem[i]);
        end

        #50;
        $finish;
    end

endmodule

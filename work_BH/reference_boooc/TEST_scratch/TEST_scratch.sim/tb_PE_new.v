`timescale 1ns/1ps
module tb_PE_new();

    reg clk;
    reg rst;

    initial begin
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        clk = 0;
        rst = 0;
        #10 rst = 1;
        #30 rst = 0;

        
    end

endmodule
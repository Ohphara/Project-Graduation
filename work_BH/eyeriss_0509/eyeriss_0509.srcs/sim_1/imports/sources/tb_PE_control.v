`timescale 1ns / 1ps

module tb_PE_control;

    parameter DATA_BITWIDTH = 16;
    parameter IFMAP_ADDR_BITWIDTH = 4;
    parameter WGHT_ADDR_BITWIDTH = 8;
    parameter PSUM_ADDR_BITWIDTH = 5;

    parameter P = 6;
    parameter Q = 4;
    parameter S = 3;

    // Inputs
    reg i_clk = 0;
    reg i_rst;
    reg i_start;
    reg [2:0] i_opcode;
    reg [8:0] i_conv_info;

    // Outputs
    wire o_ready_fifo_inst;
    wire [IFMAP_ADDR_BITWIDTH-1:0] o_ifmap_ra;
    wire [WGHT_ADDR_BITWIDTH-1:0] o_wght_ra;
    wire [PSUM_ADDR_BITWIDTH-1:0] o_psum_ra;
    wire [IFMAP_ADDR_BITWIDTH-1:0] o_ifmap_wa;
    wire [WGHT_ADDR_BITWIDTH-1:0] o_wght_wa;
    wire [PSUM_ADDR_BITWIDTH-1:0] o_psum_wa;
    wire o_ifmap_we, o_wght_we, o_psum_we;
    wire o_acc_sel, o_rst_psum;

    // Instantiate DUT
    PE_control #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .IFMAP_ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH),
        .WGHT_ADDR_BITWIDTH(WGHT_ADDR_BITWIDTH),
        .PSUM_ADDR_BITWIDTH(PSUM_ADDR_BITWIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(i_start),
        .i_opcode(i_opcode),
        .i_conv_info(i_conv_info),
        .i_valid_fifo_inst(1'b0), // not used
        .o_ready_fifo_inst(o_ready_fifo_inst),
        .o_ifmap_ra(o_ifmap_ra),
        .o_wght_ra(o_wght_ra),
        .o_psum_ra(o_psum_ra),
        .o_ifmap_wa(o_ifmap_wa),
        .o_wght_wa(o_wght_wa),
        .o_psum_wa(o_psum_wa),
        .o_ifmap_we(o_ifmap_we),
        .o_wght_we(o_wght_we),
        .o_psum_we(o_psum_we),
        .o_acc_sel(o_acc_sel),
        .o_rst_psum(o_rst_psum)
    );

    // Clock
    always #5 i_clk = ~i_clk;

    // Signal counters
    integer ifmap_we_count = 0;
    integer wght_we_count = 0;
    integer psum_we_count = 0;

    always @(posedge i_clk) begin
        if (o_ifmap_we) ifmap_we_count = ifmap_we_count + 1;
        if (o_wght_we)  wght_we_count  = wght_we_count + 1;
        if (o_psum_we)  psum_we_count  = psum_we_count + 1;
    end

    // Wait until state becomes DONE
    task wait_done();
        begin
            wait (dut.state == 4'h9); // DONE
            @(posedge i_clk);
            @(posedge i_clk);
        end
    endtask

    // Send one command
    task send_cmd(input [2:0] opcode);
        begin
            i_opcode = opcode;
            i_start = 1;
            @(posedge i_clk);
            i_start = 0;
            wait_done();
        end
    endtask

    initial begin
        $display("=== PE_control Full Functional Testbench ===");

        // Reset
        i_rst = 1;
        i_start = 0;
        i_opcode = 0;
        i_conv_info = 0;
        #20;

        i_rst = 0;
        @(posedge i_clk);

        // 0. NOP
        send_cmd(3'b000); // NOP

        // 1. SET (P=6, Q=4, S=3)
        i_conv_info = {P[2:0], Q[2:0], S[2:0]};
        send_cmd(3'b001); // SET

        // 2. LOAD_IFMAP (Q*S = 12)
        send_cmd(3'b010); // LOAD_IFMAP

        // 3. LOAD_WGHT (P*Q*S = 72)
        send_cmd(3'b011); // LOAD_WGHT

        // 4. CONV (P*Q*S = 72 cycles + ACC)
        send_cmd(3'b100); // CONV

        // 결과 출력
        $display("=== Test 결과 ===");
        $display("ifmap_we_count = %0d (예상: %0d)", ifmap_we_count, Q*S);
        $display("wght_we_count  = %0d (예상: %0d)", wght_we_count, P*Q*S);
        $display("psum_we_count  = %0d (예상: %0d)", psum_we_count, P*Q*S);

        if (ifmap_we_count == Q*S &&
            wght_we_count  == P*Q*S &&
            psum_we_count  == P*Q*S)
            $display("✅ 테스트 통과");
        else
            $display("❌ 테스트 실패");

        $stop;
    end

endmodule

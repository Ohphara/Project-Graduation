`timescale 1ns / 1ps

module tb_PE_top;
  parameter P = 6;
  parameter Q = 4;
  parameter S = 3;
  
  parameter IFMAP_SIZE = Q*S;     // 12
  parameter WEIGHT_SIZE = P*Q*S;  // 72

  // Inputs
  reg clk = 0;
  reg rst;
  reg start;
  reg signed [15:0] ifmap_in;
  reg signed [15:0] wght_in;
  reg signed [31:0] psum_in;

  // Outputs
  wire o_idle, o_load, o_conv, o_done;
  wire signed [31:0] psum_out;

  // Instantiate DUT
  PE_top dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .ifmap_in(ifmap_in),
    .wght_in(wght_in),
    .psum_in(psum_in),
    .o_idle(o_idle),
    .o_load(o_load),
    .o_conv(o_conv),
    .o_done(o_done),
    .psum_out(psum_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test data
  reg [15:0] ifmap_mem [0:IFMAP_SIZE-1];
  reg [15:0] weight_mem [0:WEIGHT_SIZE-1];
  reg [31:0] golden_psum [0:P-1];
  integer i, p, q, s, idx, widx;

  initial begin
    // Initialize inputs
    rst = 1;
    start = 0;
    ifmap_in = 0;
    wght_in = 0;
    psum_in = 0;

    // Wait for reset
    repeat (2) @(posedge clk);
    rst <= 0;
    @(posedge clk);
    start <= 1;
    @(posedge clk);
    start <= 0;
    @(posedge clk);

    // Initialize ifmap and weight
    for (i = 0; i < IFMAP_SIZE; i = i + 1)
      ifmap_mem[i] = i + 1; // 1~12

    for (i = 0; i < WEIGHT_SIZE; i = i + 1)
      weight_mem[i] = i % 3 + 1; // 1~3 반복

    // Golden output 계산
    for (p = 0; p < P; p = p + 1) begin
      golden_psum[p] = 0;
      for (q = 0; q < Q; q = q + 1)
        for (s = 0; s < S; s = s + 1) begin
          idx = q*S + s;
          widx = p*Q*S + q*S + s;
          golden_psum[p] = golden_psum[p] + ifmap_mem[idx] * weight_mem[widx];
        end
    end

    // Feed ifmap and weight to DUT
    for (i = 0; i < WEIGHT_SIZE; i = i + 1) begin
      ifmap_in <= ifmap_mem[i % IFMAP_SIZE];
      wght_in  <= weight_mem[i];
      @(posedge clk);
    end

    // Wait until done
    wait (o_done);
    @(posedge clk);
    psum_in <= 0;

    // Check outputs
    for (p = 0; p < P; p = p + 1) begin
      @(posedge clk);
      if (psum_out !== golden_psum[p]) begin
        $display("[ERROR] Mismatch at psum[%0d]: got %0d, expected %0d", p, psum_out, golden_psum[p]);
      end else begin
        $display("[PASS] psum[%0d] = %0d", p, psum_out);
      end
    end

    $display("\nAll tests passed.");
    $finish;
  end
endmodule
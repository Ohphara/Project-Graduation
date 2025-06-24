`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 16:58:39
// Design Name: 
// Module Name: tb_PE_dataloader
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_PE_dataloader;
  // Parameters
  parameter IFMAP_ADDR_BITWIDTH  = 7;
  parameter WEIGHT_ADDR_BITWIDTH = 9;
  parameter DATA_BITWIDTH        = 8;

  // Clock and reset
  reg clk;
  reg reset;

  // Target conv information
  reg [9:0] ifmap_width;
  reg [2:0] kernel_width;
  reg [7:0] o_channel;
  reg [2:0] stride;
  reg [2:0] padding;

  // Interface signals to PE_dataloader
  reg load_req;
  reg conv_req;
  wire [2:0] load_state;
  wire [1:0] conv_state;

  // FIFO interface signals
  reg ifmap_fifo_empty;
  reg signed [DATA_BITWIDTH-1:0] ifmap_fifo_data;
  reg weight_fifo_empty;
  reg signed [DATA_BITWIDTH-1:0] weight_fifo_data;

  // Outputs to PE_core
  wire signed [DATA_BITWIDTH-1:0] ifmap_data;
  wire signed [DATA_BITWIDTH-1:0] weight_data;
  wire mac_en;

  // Instantiate the device under test (DUT)
  PE_dataloader #(
      .IFMAP_ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH),
      .WEIGHT_ADDR_BITWIDTH(WEIGHT_ADDR_BITWIDTH),
      .DATA_BITWIDTH(DATA_BITWIDTH)
  ) dut (
      .clk(clk),
      .reset(reset),
      .ifmap_width(ifmap_width),
      .kernel_width(kernel_width),
      .o_channel(o_channel),
      .stride(stride),
      .padding(padding),
      .load_req(load_req),
      .conv_req(conv_req),
      .load_state(load_state),
      .conv_state(conv_state),
      .ifmap_fifo_empty(ifmap_fifo_empty),
      .ifmap_fifo_data(ifmap_fifo_data),
      .weight_fifo_empty(weight_fifo_empty),
      .weight_fifo_data(weight_fifo_data),
      .ifmap_data(ifmap_data),
      .weight_data(weight_data),
      .mac_en(mac_en)
  );

  // Clock generation: 10 ns period
  initial begin
      clk = 0;
      forever #5 clk = ~clk;
  end

  // Reset pulse
  initial begin
      reset = 0;
      #10;
      reset = 1;
      #10;
      reset = 0;
  end

  // Set up conv parameters
  initial begin
      ifmap_width = 640;    // Input size
      kernel_width = 3;     // Kernel width
      o_channel = 32;       // Output channels
      stride = 3;           // Stride (변경 가능)
      padding = 0;          // Padding (변경 가능)
  end

  // Drive load_req and conv_req signals
  initial begin
      load_req = 0;
      conv_req = 0;
      #30;
      load_req = 1;         // 시작 시 로드 요청
      #10;
      load_req = 0;
      
      // 데이터 로드 완료 후 충분한 시간 후에 convolution 요청
      #10;
      conv_req = 1;
      #20;
      conv_req = 0;
  end

  // FIFO 데이터 생성: 입력 FIFO와 weight FIFO는 항상 데이터가 존재한다고 가정
  // ifmap 데이터: 1,2,3,... (계속 증가)
  // weight 데이터: 1,2,3,1,2,3,... 반복
  reg [31:0] ifmap_counter;
  reg [31:0] weight_counter;

  initial begin
      #30
      ifmap_counter = 1;
      weight_counter = 1;
      ifmap_fifo_empty = 0;    // FIFO 비어있지 않음
      weight_fifo_empty = 0;
  end

  always @(posedge clk) begin
      if (ifmap_fifo_empty == 0) begin
          // DATA_BITWIDTH가 8비트이므로, 8비트 범위 내의 값만 사용
          ifmap_fifo_data <= ifmap_counter[DATA_BITWIDTH-1:0];
          ifmap_counter <= ifmap_counter + 1;
      end
      
      if (weight_fifo_empty == 0) begin
          // weight: 1,2,3 반복
          weight_fifo_data <= ((weight_counter - 1) % 3) + 1;
          weight_counter <= weight_counter + 1;
      end
  end

  // 시뮬레이션 종료 시간 (예: 2000 ns 후 종료)
  initial begin
      #4000;
      $finish;
  end

endmodule
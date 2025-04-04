`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Piljun Oh
// 
// Create Date: 2025/03/25 12:36:00
// Design Name: 
// Module Name: PE_dataloader
// Project Name: 25_grad
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

module PE_dataloader #(
    parameter IFMAP_ADDR_BITWIDTH  = 7,
    parameter WEIGHT_ADDR_BITWIDTH = 9,
    parameter DATA_BITWIDTH        = 8
    )(
    //// Basic input signals ////
    input clk,
    input reset,

    //// Target conv information ////
    input [9:0] ifmap_width,
    input [2:0] kernel_width,
    input [7:0] o_channel,    // Number of output channels
    input [2:0] stride,
    input [2:0] padding,

    //// Interface to PE_top.v ////
    input load_req,
    input conv_req,
    output reg [2:0] load_state,
    output reg [1:0] conv_state,

    //// ifmap FIFO ////
    input ifmap_fifo_empty,
    input signed [DATA_BITWIDTH-1:0] ifmap_fifo_data,

    //// weight FIFO ////
    input weight_fifo_empty,
    input signed [DATA_BITWIDTH-1:0] weight_fifo_data,

    //// Output to PE_core.v ////
    output signed [DATA_BITWIDTH-1:0] ifmap_data,
    output signed [DATA_BITWIDTH-1:0] weight_data,
    output reg mac_en
);

    //////////////////////////////////////////////////////////////////////////////
    // Localparams (FSM States)
    //////////////////////////////////////////////////////////////////////////////
    localparam  IDLE             = 3'b000,
                LOAD             = 3'b001,
                LOAD_IFMAP_DONE  = 3'b011,
                LOAD_WEIGHT_DONE = 3'b101,
                DONE             = 3'b111;

    localparam  CONV_IDLE        = 2'b00,
                CONV_RUN         = 2'b01,
                CONV_DONE        = 2'b10;

    //////////////////////////////////////////////////////////////////////////////
    // Registers for Address Pointers and Iteration Counters
    //////////////////////////////////////////////////////////////////////////////
    reg [9:0]                       ifmap_w_virtual_addr;
    reg [9:0]                       weight_w_virtual_addr;

    reg [9:0]                       ifmap_r_virtual_addr_pointer;
    reg [9:0]                       weight_r_virtual_addr_pointer;

    reg [2:0]                       kernel_index;

    wire [IFMAP_ADDR_BITWIDTH-1:0]  ifmap_w_addr_pointer;
    wire [WEIGHT_ADDR_BITWIDTH-1:0] weight_w_addr_pointer;

    wire [9:0] ifmap_r_virtual_addr;
    wire [9:0] weight_r_virtual_addr;

    wire [IFMAP_ADDR_BITWIDTH-1:0]  ifmap_r_addr;
    wire [WEIGHT_ADDR_BITWIDTH-1:0] weight_r_addr;

    assign ifmap_w_addr_pointer = ifmap_w_virtual_addr[IFMAP_ADDR_BITWIDTH-1:0];
    assign weight_w_addr_pointer = weight_w_virtual_addr[WEIGHT_ADDR_BITWIDTH-1:0];

    // 읽기 가상 주소에 kernel_index를 더한 결과
    assign ifmap_r_virtual_addr = ifmap_r_virtual_addr_pointer + kernel_index;
    assign weight_r_virtual_addr = weight_r_virtual_addr_pointer + kernel_index;

    // 물리적 주소는 가상 주소의 하위 비트만 사용
    assign ifmap_r_addr = ifmap_r_virtual_addr[IFMAP_ADDR_BITWIDTH-1:0];
    assign weight_r_addr = weight_r_virtual_addr[WEIGHT_ADDR_BITWIDTH-1:0];

    wire [10-IFMAP_ADDR_BITWIDTH-1:0] ifmap_w_iter;
    wire [10-WEIGHT_ADDR_BITWIDTH-1:0] weight_w_iter;

    wire [10-IFMAP_ADDR_BITWIDTH-1:0] ifmap_r_iter;
    wire [10-WEIGHT_ADDR_BITWIDTH-1:0] weight_r_iter;

    assign ifmap_w_iter   = ifmap_w_virtual_addr[9:IFMAP_ADDR_BITWIDTH];
    assign weight_w_iter  = weight_w_virtual_addr[9:WEIGHT_ADDR_BITWIDTH];

    assign ifmap_r_iter   = ifmap_r_virtual_addr_pointer[9:IFMAP_ADDR_BITWIDTH];
    assign weight_r_iter  = weight_r_virtual_addr_pointer[9:WEIGHT_ADDR_BITWIDTH];

    //////////////////////////////////////////////////////////////////////////////
    // Wire Declarations for SPAD Interfaces
    //////////////////////////////////////////////////////////////////////////////
    wire ifmap_and_weight_spad_read_req;

    // ifmap SPAD wires
    wire                            ifmap_spad_write_en;
    wire signed [DATA_BITWIDTH-1:0] ifmap_spad_w_data;
    
    // weight SPAD wires
    wire                            weight_spad_write_en;
    wire signed [DATA_BITWIDTH-1:0] weight_spad_w_data;
    
    //////////////////////////////////////////////////////////////////////////////
    // SPAD Write Enable Logic
    // 조건: fifo가 비어있지 않고, load_state의 특정 비트가 조건에 맞을 때 활성화
    // (ifmap: load_state[0]가 1이고 load_state[1]이 0일 때,
    //  weight: load_state[0]가 1이고 load_state[2]가 0일 때)
    //////////////////////////////////////////////////////////////////////////////
    assign ifmap_spad_write_en =    (~ifmap_fifo_empty) && load_state[0] && (~load_state[1]);
    assign weight_spad_write_en =   (~weight_fifo_empty) && load_state[0] && (~load_state[2]);

    //////////////////////////////////////////////////////////////////////////////
    // SPAD Read Enable Logic
    // 조건: {ifmap_w_iter,ifmap_w_addr_pointer} > {ifmap_r_iter,ifmap_r_addr}
    //       && {weight_w_iter,weight_w_addr_pointer} > {weight_r_iter,weight_r_addr}
    //       && conv_state == CONV_RUN        
    //////////////////////////////////////////////////////////////////////////////
    assign ifmap_and_weight_spad_read_req = ((ifmap_w_virtual_addr > ifmap_r_virtual_addr)
                                            && (weight_w_virtual_addr > weight_r_virtual_addr)
                                            && (conv_state == CONV_RUN));

    //////////////////////////////////////////////////////////////////////////////
    // FSM: Load ifmap & weight control
    //////////////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            load_state <= IDLE;
        end else begin
            case (load_state)
                IDLE: begin 
                    if (load_req)
                        load_state <= LOAD;
                    else
                        load_state <= IDLE;
                end
                LOAD: begin
                    if (ifmap_width == ifmap_w_virtual_addr)
                        load_state <= LOAD_IFMAP_DONE;
                    else if (o_channel == weight_w_virtual_addr)
                        load_state <= LOAD_WEIGHT_DONE;
                    else
                        load_state <= LOAD;
                end
                LOAD_IFMAP_DONE: begin
                    if (o_channel == weight_w_virtual_addr)
                        load_state <= DONE;
                    else
                        load_state <= LOAD_IFMAP_DONE;
                end
                LOAD_WEIGHT_DONE: begin
                    if (ifmap_width == ifmap_w_virtual_addr)
                        load_state <= DONE;
                    else
                        load_state <= LOAD_WEIGHT_DONE;
                end
                DONE: begin
                    if (conv_state == CONV_DONE)
                        load_state <= IDLE;
                    else
                        load_state <= DONE;
                end
                default: load_state <= IDLE;
            endcase
        end
    end

    //////////////////////////////////////////////////////////////////////////////
    // FSM: Convolution Control
    // 종료 조건: ifmap의 {ifmap_r_iter, ifmap_r_virtual_addr_pointer}가 ifmap_width와 같고,
    //          weight의 {weight_r_iter, weight_r_virtual_addr_pointer}가 o_channel과 같으면 CONV_DONE
    //////////////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            conv_state <= CONV_IDLE;
        end else begin
            case (conv_state)
                CONV_IDLE: begin
                    if (conv_req)
                        conv_state <= CONV_RUN;
                    else
                        conv_state <= CONV_IDLE;
                end
                CONV_RUN: begin
                    if ((ifmap_width == ifmap_r_virtual_addr) &&
                        (o_channel   == weight_r_virtual_addr))
                        conv_state <= CONV_DONE;
                    else
                        conv_state <= CONV_RUN;
                end
                CONV_DONE: begin
                    conv_state <= CONV_IDLE;
                end
                default: conv_state <= CONV_IDLE;
            endcase
        end
    end

    //////////////////////////////////////////////////////////////////////////////
    // SPAD Instances
    //////////////////////////////////////////////////////////////////////////////
    spad #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .ADDR_BITWIDTH(IFMAP_ADDR_BITWIDTH)
    )
    ifmap_spad (
        .clk(clk),
        .reset(reset),
        .read_req(ifmap_and_weight_spad_read_req),
        .write_en(ifmap_spad_write_en),
        .r_addr(ifmap_r_addr),
        .w_addr(ifmap_w_addr_pointer),
        .w_data(ifmap_fifo_data),
        .r_data(ifmap_data)
    );

    spad #(
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .ADDR_BITWIDTH(WEIGHT_ADDR_BITWIDTH)
    )
    weight_spad (
        .clk(clk),
        .reset(reset),
        .read_req(ifmap_and_weight_spad_read_req),
        .write_en(weight_spad_write_en),
        .r_addr(weight_r_addr),
        .w_addr(weight_w_addr_pointer),
        .w_data(weight_fifo_data),
        .r_data(weight_data)
    );

    //////////////////////////////////////////////////////////////////////////////
    // ifmap SPAD Write Address Pointer and Iteration Update
    //////////////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ifmap_w_virtual_addr <= 0;
        end else if (ifmap_spad_write_en) begin
            ifmap_w_virtual_addr <= ifmap_w_virtual_addr + 1;
        end else begin
            ifmap_w_virtual_addr <= ifmap_w_virtual_addr;
        end
    end

    //////////////////////////////////////////////////////////////////////////////
    // weight SPAD Write Address Pointer and Iteration Update
    //////////////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            weight_w_virtual_addr <= 0;
        end else if (weight_spad_write_en) begin
            weight_w_virtual_addr <= weight_w_virtual_addr + 1;
        end else begin
            weight_w_virtual_addr <= weight_w_virtual_addr;
        end
    end

    //////////////////////////////////////////////////////////////////////////////
    // kernel_index Update
    //////////////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            kernel_index <= 0;
        end else if ((conv_state==CONV_RUN) && (ifmap_and_weight_spad_read_req) && (kernel_index != kernel_width)) begin
            kernel_index <= kernel_index + 1;
        end else if ((conv_state==CONV_RUN) && (ifmap_and_weight_spad_read_req) && (kernel_index == kernel_width)) begin
            kernel_index <= 0;
        end else begin
            kernel_index <= kernel_index;
        end
    end

    //////////////////////////////////////////////////////////////////////////////
    // Read Pointer Update for ifmap and weight SPADs
    // ifmap_and_weight_spad_read_req가 1이고, kernel_index가 kernel_width에 도달한 경우,
    // read pointer (ifmap_r_virtual_addr_pointer, weight_r_virtual_addr_pointer)를 stride만큼 증가
    //////////////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ifmap_r_virtual_addr_pointer <= 0;
            weight_r_virtual_addr_pointer <= 0;
        end else if (ifmap_and_weight_spad_read_req && (kernel_index == kernel_width)) begin
            // ifmap 포인터는 stride만큼 증가
            ifmap_r_virtual_addr_pointer <= ifmap_r_virtual_addr_pointer + stride;

            // weight 포인터는 ifmap_r_virtual_addr가 ifmap_width-1에 도달했을 때 kernel_width만큼 증가
            if (ifmap_r_virtual_addr == (ifmap_width - 1))
                weight_r_virtual_addr_pointer <= weight_r_virtual_addr_pointer + kernel_width;
            else
                weight_r_virtual_addr_pointer <= weight_r_virtual_addr_pointer;
        end else begin
            ifmap_r_virtual_addr_pointer <= ifmap_r_virtual_addr_pointer;
            weight_r_virtual_addr_pointer <= weight_r_virtual_addr_pointer;
        end
    end

    //////////////////////////////////////////////////////////////////////////////
    // MAC Enable Control
    // conv_state가 CONV_RUN일 때, kernel_index가 kernel_width이면 mac_en은 0,
    // 그 외의 경우(또는 conv_state가 CONV_RUN가 아닐 때) mac_en은 1 (혹은 0)로 설정
    // 여기서는 conv_state가 CONV_RUN이고 kernel_index != kernel_width인 경우에만 mac_en을 1로 함
    //////////////////////////////////////////////////////////////////////////////
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mac_en <= 0;
        end else if (conv_state == CONV_RUN) begin
            if (kernel_index == kernel_width)
                mac_en <= 0;
            else
                mac_en <= 1;
        end else begin
            mac_en <= 0;
        end
    end

endmodule

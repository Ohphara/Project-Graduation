//////////////////////////////////////////////////////////////////////////////////
// Company: Personal
// Engineer: Matbi / Austin
//
// License : https://github.com/matbi86/matbi_fpga_season_1/blob/master/LICENSE
// Create Date:
// Design Name: matbi_dma_ip_control_s_axi
// Module Name: matbi_dma_ip_control_s_axi
// Project Name:
// Target Devices: Zybo Z7-20
// Tool Versions:
// Description: matbi dma ip control.
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module matbi_dma_ip_control_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 6, //byte addressable, 2^6 = 64byte, 16 register
    C_S_AXI_DATA_WIDTH = 32
)(
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire                          interrupt,

    output wire [31:0]                   rdma_transfer_byte,
    output wire [31:0]                   rdma_mem_ptr,
    output wire [31:0]                   wdma_transfer_byte,
    output wire [31:0]                   wdma_mem_ptr,
    output wire [31:0]                   axi00_ptr0,
    output wire [31:0]                   value_to_add,
    output wire                          ap_start,
    input  wire                          ap_done,
    input  wire                          ap_ready,
    input  wire                          ap_idle
);
//------------------------Address Info-------------------
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read/COR)
//        bit 7  - auto_restart (Read/Write)
//        bit 9  - interrupt (Read)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0 - enable ap_done interrupt (Read/Write)
//        bit 1 - enable ap_ready interrupt (Read/Write)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/COR)
//        bit 0 - ap_done (Read/COR)
//        bit 1 - ap_ready (Read/COR)
//        others - reserved
// 0x10 : Data signal of rdma_transfer_byte
//        bit 31~0 - rdma_transfer_byte[31:0] (Read/Write)
// 0x14 : Data signal of rdma_mem_ptr
//        bit 31~0 - rdma_mem_ptr[31:0] (Read/Write)
// 0x18 : Data signal of wdma_transfer_byte
//        bit 31~0 - wdma_transfer_byte[31:0] (Read/Write)
// 0x1c : Data signal of wdma_mem_ptr
//        bit 31~0 - wdma_mem_ptr[31:0] (Read/Write)
// 0x20 : Data signal of axi00_ptr0
//        bit 31~0 - axi00_ptr0[31:0] (Read/Write)
// 0x24 : value_to_add
//        bit 31~0 - value_to_add[31:0] (Read/Write)
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    //register map
    ADDR_AP_CTRL                   = 6'h00,
    ADDR_GIE                       = 6'h04,
    ADDR_IER                       = 6'h08,
    ADDR_ISR                       = 6'h0c,
    ADDR_RDMA_TRANSFER_BYTE_DATA_0 = 6'h10,
    ADDR_RDMA_MEM_PTR_DATA_0       = 6'h14,
    ADDR_WDMA_TRANSFER_BYTE_DATA_0 = 6'h18,
    ADDR_WDMA_MEM_PTR_DATA_0       = 6'h1c,
    ADDR_AXI00_PTR0_DATA_0         = 6'h20,
    ADDR_VALUE_TO_ADD	           = 6'h24,
    //states
    WRIDLE                         = 2'd0,
    WRDATA                         = 2'd1,
    WRRESP                         = 2'd2,
    WRRESET                        = 2'd3,
    RDIDLE                         = 2'd0,
    RDDATA                         = 2'd1,
    RDRESET                        = 2'd2,
    ADDR_BITS                = 6;

//------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRRESET;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [C_S_AXI_DATA_WIDTH-1:0] wmask;
    wire                          aw_hs;
    wire                          w_hs;

    reg  [1:0]                    rstate = RDRESET;
    reg  [1:0]                    rnext;
    reg  [C_S_AXI_DATA_WIDTH-1:0] rdata;
    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;

    // internal registers
    reg                           int_ap_idle;
    reg                           int_ap_ready = 1'b0;
    wire                          task_ap_ready;
    reg                           int_ap_done = 1'b0;
    wire                          task_ap_done;
    reg                           int_task_ap_done = 1'b0;
    reg                           int_ap_start = 1'b0;
    reg                           int_interrupt = 1'b0;
    reg                           int_auto_restart = 1'b0;
    reg                           auto_restart_status = 1'b0;
    wire                          auto_restart_done;
    reg                           int_gie = 1'b0;
    reg  [1:0]                    int_ier = 2'b0;
    reg  [1:0]                    int_isr = 2'b0;
    reg  [31:0]                   int_rdma_transfer_byte = 'b0;
    reg  [31:0]                   int_rdma_mem_ptr = 'b0;
    reg  [31:0]                   int_wdma_transfer_byte = 'b0;
    reg  [31:0]                   int_wdma_mem_ptr = 'b0;
    reg  [31:0]                   int_axi00_ptr0 = 'b0;
    reg  [31:0]                   int_value_to_add = 'b0;

//------------------------Instantiation------------------


//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // assume OKAY
assign BVALID  = (wstate == WRRESP);
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
    if (ARESET)
        wstate <= WRRESET;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= AWADDR[ADDR_BITS-1:0];
    end
end


//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
    if (ARESET)
        rstate <= RDRESET;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 'b0;
            case (raddr)
                ADDR_AP_CTRL: begin
                    rdata[0] <= int_ap_start;
                    rdata[1] <= int_task_ap_done;
                    rdata[2] <= int_ap_idle;
                    rdata[3] <= int_ap_ready;
                    rdata[7] <= int_auto_restart;
                    rdata[9] <= int_interrupt;
                end
                ADDR_GIE: begin
                    rdata <= int_gie;
                end
                ADDR_IER: begin
                    rdata <= int_ier;
                end
                ADDR_ISR: begin
                    rdata <= int_isr;
                end
                ADDR_RDMA_TRANSFER_BYTE_DATA_0: begin
                    rdata <= int_rdma_transfer_byte[31:0];
                end
                ADDR_RDMA_MEM_PTR_DATA_0: begin
                    rdata <= int_rdma_mem_ptr[31:0];
                end
                ADDR_WDMA_TRANSFER_BYTE_DATA_0: begin
                    rdata <= int_wdma_transfer_byte[31:0];
                end
                ADDR_WDMA_MEM_PTR_DATA_0: begin
                    rdata <= int_wdma_mem_ptr[31:0];
                end
                ADDR_AXI00_PTR0_DATA_0: begin
                    rdata <= int_axi00_ptr0[31:0];
				end  
                ADDR_VALUE_TO_ADD: begin
                    rdata <= int_value_to_add[31:0];
                end
            endcase
        end
    end
end


//------------------------Register logic-----------------
assign interrupt          = int_interrupt;
assign ap_start           = int_ap_start;
assign task_ap_done       = (ap_done && !auto_restart_status) || auto_restart_done;
assign task_ap_ready      = ap_ready && !int_auto_restart;
assign auto_restart_done  = auto_restart_status && (ap_idle && !int_ap_idle);
assign rdma_transfer_byte = int_rdma_transfer_byte;
assign rdma_mem_ptr       = int_rdma_mem_ptr;
assign wdma_transfer_byte = int_wdma_transfer_byte;
assign wdma_mem_ptr       = int_wdma_mem_ptr;
assign axi00_ptr0         = int_axi00_ptr0;
assign value_to_add       = int_value_to_add;
// int_interrupt
always @(posedge ACLK) begin
    if (ARESET)
        int_interrupt <= 1'b0;
    else if (ACLK_EN) begin
        if (int_gie && (|int_isr))
            int_interrupt <= 1'b1;
        else
            int_interrupt <= 1'b0;
    end
end

// int_ap_start
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_start <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0] && WDATA[0])
            int_ap_start <= 1'b1;
        else if (ap_ready)
            int_ap_start <= int_auto_restart; // clear on handshake/auto restart
    end
end

// int_ap_done
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_done <= 1'b0;
    else if (ACLK_EN) begin
            int_ap_done <= ap_done;
    end
end

// int_task_ap_done
always @(posedge ACLK) begin
    if (ARESET)
        int_task_ap_done <= 1'b0;
    else if (ACLK_EN) begin
        if (task_ap_done)
            int_task_ap_done <= 1'b1;
        else if (ar_hs && raddr == ADDR_AP_CTRL)
            int_task_ap_done <= 1'b0; // clear on read
    end
end

// int_ap_idle
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_idle <= 1'b0;
    else if (ACLK_EN) begin
            int_ap_idle <= ap_idle;
    end
end

// int_ap_ready
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_ready <= 1'b0;
    else if (ACLK_EN) begin
        if (task_ap_ready)
            int_ap_ready <= 1'b1;
        else if (ar_hs && raddr == ADDR_AP_CTRL)
            int_ap_ready <= 1'b0;
    end
end

// int_auto_restart
always @(posedge ACLK) begin
    if (ARESET)
        int_auto_restart <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0])
            int_auto_restart <=  WDATA[7];
    end
end

// auto_restart_status
always @(posedge ACLK) begin
    if (ARESET)
        auto_restart_status <= 1'b0;
    else if (ACLK_EN) begin
        if (int_auto_restart)
            auto_restart_status <= 1'b1;
        else if (ap_idle)
            auto_restart_status <= 1'b0;
    end
end

// int_gie
always @(posedge ACLK) begin
    if (ARESET)
        int_gie <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_GIE && WSTRB[0])
            int_gie <= WDATA[0];
    end
end

// int_ier
always @(posedge ACLK) begin
    if (ARESET)
        int_ier <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_IER && WSTRB[0])
            int_ier <= WDATA[1:0];
    end
end

// int_isr[0]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[0] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[0] & ap_done)
            int_isr[0] <= 1'b1;
        else if (ar_hs && raddr == ADDR_ISR)
            int_isr[0] <= 1'b0; // clear on read
    end
end

// int_isr[1]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[1] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[1] & ap_ready)
            int_isr[1] <= 1'b1;
        else if (ar_hs && raddr == ADDR_ISR)
            int_isr[1] <= 1'b0; // clear on read
    end
end

// int_rdma_transfer_byte[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_rdma_transfer_byte[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_RDMA_TRANSFER_BYTE_DATA_0)
            int_rdma_transfer_byte[31:0] <= (WDATA[31:0] & wmask) | (int_rdma_transfer_byte[31:0] & ~wmask);
    end
end

// int_rdma_mem_ptr[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_rdma_mem_ptr[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_RDMA_MEM_PTR_DATA_0)
            int_rdma_mem_ptr[31:0] <= (WDATA[31:0] & wmask) | (int_rdma_mem_ptr[31:0] & ~wmask);
    end
end

// int_wdma_transfer_byte[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_wdma_transfer_byte[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WDMA_TRANSFER_BYTE_DATA_0)
            int_wdma_transfer_byte[31:0] <= (WDATA[31:0] & wmask) | (int_wdma_transfer_byte[31:0] & ~wmask);
    end
end

// int_wdma_mem_ptr[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_wdma_mem_ptr[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WDMA_MEM_PTR_DATA_0)
            int_wdma_mem_ptr[31:0] <= (WDATA[31:0] & wmask) | (int_wdma_mem_ptr[31:0] & ~wmask);
    end
end

// int_axi00_ptr0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_axi00_ptr0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AXI00_PTR0_DATA_0)
            int_axi00_ptr0[31:0] <= (WDATA[31:0] & wmask) | (int_axi00_ptr0[31:0] & ~wmask);
    end
end

// int_axi00_ptr0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_value_to_add[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VALUE_TO_ADD)
            int_value_to_add[31:0] <= (WDATA[31:0] & wmask) | (int_value_to_add[31:0] & ~wmask);
    end
end


//synthesis translate_off
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (int_gie & ~int_isr[0] & int_ier[0] & ap_done)
            $display ("// Interrupt Monitor : interrupt for ap_done detected @ \"%0t\"", $time);
        if (int_gie & ~int_isr[1] & int_ier[1] & ap_ready)
            $display ("// Interrupt Monitor : interrupt for ap_ready detected @ \"%0t\"", $time);
    end
end
//synthesis translate_on

//------------------------Memory logic-------------------

endmodule
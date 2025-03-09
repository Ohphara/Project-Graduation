`timescale 1ns / 1ps

module top #(
    // Users to add parameters here
	parameter ADDR_BITWIDTH_GLB = 10,
	parameter ADDR_BITWIDTH_SPAD = 9,
	parameter DATA_BITWIDTH = 16,
	
    parameter A_READ_ADDR = 100,
	parameter A_LOAD_ADDR = 100,
	parameter W_READ_ADDR = 0,
	parameter W_LOAD_ADDR = 0,
	parameter PSUM_READ_ADDR = 0,
	parameter PSUM_LOAD_ADDR = 0,
	parameter PSUM_ADDR= 500,
    parameter X_dim = 3,
    parameter Y_dim = 3,
    parameter kernel_size = 3,
    parameter act_size = 5,
    parameter NUM_GLB_IACT = 1,
    parameter NUM_GLB_PSUM = 1,
    parameter NUM_GLB_WGHT = 1,
    // User parameters ends

    // Do not modify the parameters beyond this line
    // Width of S_AXI data bus
    parameter integer C_S00_AXI_DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer C_S00_AXI_ADDR_WIDTH	= 6
)
(
    // Users to add ports here
    // User ports end

    // Do not modify the ports beyond this line

    // Ports of Axi Slave Bus Interface S00_AXI
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready
);

//-----------------------------------------------------------------------------
// Global Signals
//-----------------------------------------------------------------------------
wire        clk, reset;
wire        start;
wire        compute_done, load_done;

//-----------------------------------------------------------------------------
// Activation Interface
//-----------------------------------------------------------------------------
// Enable signals
wire        write_en_iact_west_0, write_en_iact_west_1, 
            write_en_iact_east_0, write_en_iact_east_1;
// Data signals
wire signed [DATA_BITWIDTH-1:0] 
            w_data_iact_west_0, w_data_iact_west_1, 
            w_data_iact_east_0,  w_data_iact_east_1;
// Address signals
wire [ADDR_BITWIDTH_GLB-1:0] 
            w_addr_iact_west_0, w_addr_iact_west_1, 
            w_addr_iact_east_0,  w_addr_iact_east_1;

//-----------------------------------------------------------------------------
// Weight Interface
//-----------------------------------------------------------------------------
// Enable signals
wire        write_en_wght_west_0, write_en_wght_west_1, 
            write_en_wght_east_0, write_en_wght_east_1;
// Data signals
wire signed [DATA_BITWIDTH-1:0] 
            w_data_wght_west_0, w_data_wght_west_1, 
            w_data_wght_east_0, w_data_wght_east_1;
// Address signals
wire [ADDR_BITWIDTH_GLB-1:0] 
            w_addr_wght_west_0, w_addr_wght_west_1, 
            w_addr_wght_east_0, w_addr_wght_east_1;

//-----------------------------------------------------------------------------
// PSUM Interface
//-----------------------------------------------------------------------------
// Read address signals
wire [ADDR_BITWIDTH_GLB-1:0] 
            r_addr_psum_west_0, r_addr_psum_west_1, 
            r_addr_psum_east_0, r_addr_psum_east_1,
            r_addr_psum_inter_west_0, r_addr_psum_inter_west_1, 
            r_addr_psum_inter_east_0, r_addr_psum_inter_east_1;
// Request signals
wire        r_req_psum_west_0, r_req_psum_west_1, 
            r_req_psum_east_0, r_req_psum_east_1,
            r_req_psum_inter_west_0, r_req_psum_inter_west_1, 
            r_req_psum_inter_east_0, r_req_psum_inter_east_1;
// Data output signals
wire signed [DATA_BITWIDTH-1:0] 
            r_data_psum_west_0, r_data_psum_west_1, 
            r_data_psum_east_0, r_data_psum_east_1;

//-----------------------------------------------------------------------------
// Router Control Signals
//-----------------------------------------------------------------------------
// Enable signals
wire        west_enable_i_west_0_wght, west_enable_i_west_0_iact,
            west_enable_i_west_1_wght, west_enable_i_west_1_iact,
            west_enable_i_east_0_wght, west_enable_i_east_0_iact,
            west_enable_i_east_1_wght, west_enable_i_east_1_iact;
// Mode signals (4-bit)
wire [3:0]  router_mode_west_0_wght, router_mode_west_0_iact, router_mode_west_0_psum,
            router_mode_west_1_wght, router_mode_west_1_iact, router_mode_west_1_psum,
            router_mode_east_0_wght, router_mode_east_0_iact, router_mode_east_0_psum,
            router_mode_east_1_wght, router_mode_east_1_iact, router_mode_east_1_psum;


// Instantiation of Axi Bus Interface S00_AXI
	axi4_lite # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) u_axi4_lite_test (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		// User ports
        .start(start),
        .reset(reset),
        .compute_done(compute_done),
        .load_done(load_done)
        // User ports end
	);




    HMNOC_4cluster_wpsum #(
        .ADDR_BITWIDTH_GLB(ADDR_BITWIDTH_GLB),
        .ADDR_BITWIDTH_SPAD(ADDR_BITWIDTH_SPAD),
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .A_READ_ADDR(A_READ_ADDR),
        .A_LOAD_ADDR(A_LOAD_ADDR),
        .W_READ_ADDR(W_READ_ADDR),
        .W_LOAD_ADDR(W_LOAD_ADDR),
        .PSUM_READ_ADDR(PSUM_READ_ADDR),
        .PSUM_LOAD_ADDR(PSUM_LOAD_ADDR),
        .PSUM_ADDR(PSUM_ADDR),
        .X_dim(X_dim),
        .Y_dim(Y_dim),
        .kernel_size(kernel_size),
        .act_size(act_size),
        .NUM_GLB_IACT(NUM_GLB_IACT),
        .NUM_GLB_PSUM(NUM_GLB_PSUM),
        .NUM_GLB_WGHT(NUM_GLB_WGHT)
    )
    u_HMNOC_4cluster_wpsum (
        // Clock and Reset
        .clk                       (clk),
        .reset                     (reset),
        
        // PE interfaces
        .start                     (start),
        .compute_done              (compute_done),
        .load_done                 (load_done),
        
        // GLB Interfaces - West 0
        .write_en_iact_west_0      (write_en_iact_west_0),
        .w_data_iact_west_0        (w_data_iact_west_0),
        .w_addr_iact_west_0        (w_addr_iact_west_0),
        .w_data_wght_west_0        (w_data_wght_west_0),
        .w_addr_wght_west_0        (w_addr_wght_west_0),
        .write_en_wght_west_0      (write_en_wght_west_0),
        .r_addr_psum_west_0        (r_addr_psum_west_0),
        .r_data_psum_west_0        (r_data_psum_west_0),
        .r_req_psum_west_0         (r_req_psum_west_0),
        .r_addr_psum_inter_west_0  (r_addr_psum_inter_west_0),
        .r_req_psum_inter_west_0   (r_req_psum_inter_west_0),
        
        // GLB Interfaces - West 1
        .write_en_iact_west_1      (write_en_iact_west_1),
        .w_data_iact_west_1        (w_data_iact_west_1),
        .w_addr_iact_west_1        (w_addr_iact_west_1),
        .w_data_wght_west_1        (w_data_wght_west_1),
        .w_addr_wght_west_1        (w_addr_wght_west_1),
        .write_en_wght_west_1      (write_en_wght_west_1),
        .r_addr_psum_west_1        (r_addr_psum_west_1),
        .r_data_psum_west_1        (r_data_psum_west_1),
        .r_req_psum_west_1         (r_req_psum_west_1),
        .r_addr_psum_inter_west_1  (r_addr_psum_inter_west_1),
        .r_req_psum_inter_west_1   (r_req_psum_inter_west_1),
        
        // GLB Interfaces - East 0
        .write_en_iact_east_0      (write_en_iact_east_0),
        .w_data_iact_east_0        (w_data_iact_east_0),
        .w_addr_iact_east_0        (w_addr_iact_east_0),
        .w_data_wght_east_0        (w_data_wght_east_0),
        .w_addr_wght_east_0        (w_addr_wght_east_0),
        .write_en_wght_east_0      (write_en_wght_east_0),
        .r_addr_psum_east_0        (r_addr_psum_east_0),
        .r_data_psum_east_0        (r_data_psum_east_0),
        .r_req_psum_east_0         (r_req_psum_east_0),
        .r_addr_psum_inter_east_0  (r_addr_psum_inter_east_0),
        .r_req_psum_inter_east_0   (r_req_psum_inter_east_0),
        
        // GLB Interfaces - East 1
        .write_en_iact_east_1      (write_en_iact_east_1),
        .w_data_iact_east_1        (w_data_iact_east_1),
        .w_addr_iact_east_1        (w_addr_iact_east_1),
        .w_data_wght_east_1        (w_data_wght_east_1),
        .w_addr_wght_east_1        (w_addr_wght_east_1),
        .write_en_wght_east_1      (write_en_wght_east_1),
        .r_addr_psum_east_1        (r_addr_psum_east_1),
        .r_data_psum_east_1        (r_data_psum_east_1),
        .r_req_psum_east_1         (r_req_psum_east_1),
        .r_addr_psum_inter_east_1  (r_addr_psum_inter_east_1),
        .r_req_psum_inter_east_1   (r_req_psum_inter_east_1),
        
        // Router Control Signals
        .west_enable_i_west_0_wght (west_enable_i_west_0_wght),
        .west_enable_i_west_0_iact (west_enable_i_west_0_iact),
        .west_enable_i_west_1_wght (west_enable_i_west_1_wght),
        .west_enable_i_west_1_iact (west_enable_i_west_1_iact),
        .west_enable_i_east_0_wght (west_enable_i_east_0_wght),
        .west_enable_i_east_0_iact (west_enable_i_east_0_iact),
        .west_enable_i_east_1_wght (west_enable_i_east_1_wght),
        .west_enable_i_east_1_iact (west_enable_i_east_1_iact),
        
        // Router Mode Signals
        .router_mode_west_0_wght   (router_mode_west_0_wght),
        .router_mode_west_0_iact   (router_mode_west_0_iact),
        .router_mode_west_0_psum   (router_mode_west_0_psum),
        .router_mode_west_1_wght   (router_mode_west_1_wght),
        .router_mode_west_1_iact   (router_mode_west_1_iact),
        .router_mode_west_1_psum   (router_mode_west_1_psum),
        .router_mode_east_0_wght   (router_mode_east_0_wght),
        .router_mode_east_0_iact   (router_mode_east_0_iact),
        .router_mode_east_0_psum   (router_mode_east_0_psum),
        .router_mode_east_1_wght   (router_mode_east_1_wght),
        .router_mode_east_1_iact   (router_mode_east_1_iact),
        .router_mode_east_1_psum   (router_mode_east_1_psum)
    );

    assign clk = s00_axi_aclk;
    assign reset = ~(s00_axi_aresetn);
    
endmodule

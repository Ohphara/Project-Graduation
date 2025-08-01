// ==============================================================
// RTL generated by Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.1 (64-bit)
// Version: 2022.1
// Copyright (C) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="matbi_hls_rdma_matbi_hls_rdma,hls_ip_2022_1,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7z020-clg400-1,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=7.300000,HLS_SYN_LAT=-1,HLS_SYN_TPT=none,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=903,HLS_SYN_LUT=1266,HLS_VERSION=2022_1}" *)

module matbi_hls_rdma (
        ap_clk,
        ap_rst_n,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        m_axi_gmem_AWVALID,
        m_axi_gmem_AWREADY,
        m_axi_gmem_AWADDR,
        m_axi_gmem_AWID,
        m_axi_gmem_AWLEN,
        m_axi_gmem_AWSIZE,
        m_axi_gmem_AWBURST,
        m_axi_gmem_AWLOCK,
        m_axi_gmem_AWCACHE,
        m_axi_gmem_AWPROT,
        m_axi_gmem_AWQOS,
        m_axi_gmem_AWREGION,
        m_axi_gmem_AWUSER,
        m_axi_gmem_WVALID,
        m_axi_gmem_WREADY,
        m_axi_gmem_WDATA,
        m_axi_gmem_WSTRB,
        m_axi_gmem_WLAST,
        m_axi_gmem_WID,
        m_axi_gmem_WUSER,
        m_axi_gmem_ARVALID,
        m_axi_gmem_ARREADY,
        m_axi_gmem_ARADDR,
        m_axi_gmem_ARID,
        m_axi_gmem_ARLEN,
        m_axi_gmem_ARSIZE,
        m_axi_gmem_ARBURST,
        m_axi_gmem_ARLOCK,
        m_axi_gmem_ARCACHE,
        m_axi_gmem_ARPROT,
        m_axi_gmem_ARQOS,
        m_axi_gmem_ARREGION,
        m_axi_gmem_ARUSER,
        m_axi_gmem_RVALID,
        m_axi_gmem_RREADY,
        m_axi_gmem_RDATA,
        m_axi_gmem_RLAST,
        m_axi_gmem_RID,
        m_axi_gmem_RUSER,
        m_axi_gmem_RRESP,
        m_axi_gmem_BVALID,
        m_axi_gmem_BREADY,
        m_axi_gmem_BRESP,
        m_axi_gmem_BID,
        m_axi_gmem_BUSER,
        tranfer_byte,
        mem,
        out_r_din,
        out_r_full_n,
        out_r_write
);

parameter    ap_ST_fsm_state1 = 10'd1;
parameter    ap_ST_fsm_state2 = 10'd2;
parameter    ap_ST_fsm_state3 = 10'd4;
parameter    ap_ST_fsm_state4 = 10'd8;
parameter    ap_ST_fsm_state5 = 10'd16;
parameter    ap_ST_fsm_state6 = 10'd32;
parameter    ap_ST_fsm_state7 = 10'd64;
parameter    ap_ST_fsm_state8 = 10'd128;
parameter    ap_ST_fsm_state9 = 10'd256;
parameter    ap_ST_fsm_state10 = 10'd512;
parameter    C_M_AXI_GMEM_ID_WIDTH = 1;
parameter    C_M_AXI_GMEM_ADDR_WIDTH = 32;
parameter    C_M_AXI_GMEM_DATA_WIDTH = 64;
parameter    C_M_AXI_GMEM_AWUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_ARUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_WUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_RUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_BUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_USER_VALUE = 0;
parameter    C_M_AXI_GMEM_PROT_VALUE = 0;
parameter    C_M_AXI_GMEM_CACHE_VALUE = 3;
parameter    C_M_AXI_DATA_WIDTH = 32;

parameter C_M_AXI_GMEM_WSTRB_WIDTH = (64 / 8);
parameter C_M_AXI_WSTRB_WIDTH = (32 / 8);

input   ap_clk;
input   ap_rst_n;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output   m_axi_gmem_AWVALID;
input   m_axi_gmem_AWREADY;
output  [C_M_AXI_GMEM_ADDR_WIDTH - 1:0] m_axi_gmem_AWADDR;
output  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_AWID;
output  [7:0] m_axi_gmem_AWLEN;
output  [2:0] m_axi_gmem_AWSIZE;
output  [1:0] m_axi_gmem_AWBURST;
output  [1:0] m_axi_gmem_AWLOCK;
output  [3:0] m_axi_gmem_AWCACHE;
output  [2:0] m_axi_gmem_AWPROT;
output  [3:0] m_axi_gmem_AWQOS;
output  [3:0] m_axi_gmem_AWREGION;
output  [C_M_AXI_GMEM_AWUSER_WIDTH - 1:0] m_axi_gmem_AWUSER;
output   m_axi_gmem_WVALID;
input   m_axi_gmem_WREADY;
output  [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_WDATA;
output  [C_M_AXI_GMEM_WSTRB_WIDTH - 1:0] m_axi_gmem_WSTRB;
output   m_axi_gmem_WLAST;
output  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_WID;
output  [C_M_AXI_GMEM_WUSER_WIDTH - 1:0] m_axi_gmem_WUSER;
output   m_axi_gmem_ARVALID;
input   m_axi_gmem_ARREADY;
output  [C_M_AXI_GMEM_ADDR_WIDTH - 1:0] m_axi_gmem_ARADDR;
output  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_ARID;
output  [7:0] m_axi_gmem_ARLEN;
output  [2:0] m_axi_gmem_ARSIZE;
output  [1:0] m_axi_gmem_ARBURST;
output  [1:0] m_axi_gmem_ARLOCK;
output  [3:0] m_axi_gmem_ARCACHE;
output  [2:0] m_axi_gmem_ARPROT;
output  [3:0] m_axi_gmem_ARQOS;
output  [3:0] m_axi_gmem_ARREGION;
output  [C_M_AXI_GMEM_ARUSER_WIDTH - 1:0] m_axi_gmem_ARUSER;
input   m_axi_gmem_RVALID;
output   m_axi_gmem_RREADY;
input  [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_RDATA;
input   m_axi_gmem_RLAST;
input  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_RID;
input  [C_M_AXI_GMEM_RUSER_WIDTH - 1:0] m_axi_gmem_RUSER;
input  [1:0] m_axi_gmem_RRESP;
input   m_axi_gmem_BVALID;
output   m_axi_gmem_BREADY;
input  [1:0] m_axi_gmem_BRESP;
input  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_BID;
input  [C_M_AXI_GMEM_BUSER_WIDTH - 1:0] m_axi_gmem_BUSER;
input  [31:0] tranfer_byte;
input  [31:0] mem;
output  [63:0] out_r_din;
input   out_r_full_n;
output   out_r_write;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg out_r_write;

 reg    ap_rst_n_inv;
(* fsm_encoding = "none" *) reg   [9:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg    gmem_blk_n_AR;
wire    ap_CS_fsm_state2;
wire   [0:0] icmp_ln11_fu_100_p2;
wire   [28:0] tranfer_cnt_fu_90_p4;
wire   [31:0] zext_ln9_fu_106_p1;
wire  signed [28:0] trunc_ln_fu_110_p4;
reg   [28:0] trunc_ln_reg_146;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_done;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_idle;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_ready;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWVALID;
wire   [31:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWADDR;
wire   [0:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWID;
wire   [31:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWLEN;
wire   [2:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWSIZE;
wire   [1:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWBURST;
wire   [1:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWLOCK;
wire   [3:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWCACHE;
wire   [2:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWPROT;
wire   [3:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWQOS;
wire   [3:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWREGION;
wire   [0:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWUSER;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WVALID;
wire   [63:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WDATA;
wire   [7:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WSTRB;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WLAST;
wire   [0:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WID;
wire   [0:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WUSER;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARVALID;
wire   [31:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARADDR;
wire   [0:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARID;
wire   [31:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARLEN;
wire   [2:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARSIZE;
wire   [1:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARBURST;
wire   [1:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARLOCK;
wire   [3:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARCACHE;
wire   [2:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARPROT;
wire   [3:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARQOS;
wire   [3:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARREGION;
wire   [0:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARUSER;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_RREADY;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_BREADY;
wire   [63:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_out_r_din;
wire    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_out_r_write;
wire   [28:0] grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_tranfer_cnt;
wire    gmem_AWREADY;
wire    gmem_WREADY;
reg    gmem_ARVALID;
wire    gmem_ARREADY;
reg   [31:0] gmem_ARADDR;
reg   [31:0] gmem_ARLEN;
wire    gmem_RVALID;
reg    gmem_RREADY;
wire   [63:0] gmem_RDATA;
wire   [6:0] gmem_RFIFONUM;
wire    gmem_BVALID;
reg    grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start_reg;
wire    ap_CS_fsm_state9;
wire    ap_CS_fsm_state10;
wire  signed [31:0] sext_ln11_fu_120_p1;
reg    ap_block_state2_io;
reg    ap_block_state10_on_subcall_done;
reg   [9:0] ap_NS_fsm;
reg    ap_ST_fsm_state1_blk;
reg    ap_ST_fsm_state2_blk;
wire    ap_ST_fsm_state3_blk;
wire    ap_ST_fsm_state4_blk;
wire    ap_ST_fsm_state5_blk;
wire    ap_ST_fsm_state6_blk;
wire    ap_ST_fsm_state7_blk;
wire    ap_ST_fsm_state8_blk;
wire    ap_ST_fsm_state9_blk;
reg    ap_ST_fsm_state10_blk;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 10'd1;
#0 grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start_reg = 1'b0;
end

matbi_hls_rdma_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1 grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .ap_start(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start),
    .ap_done(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_done),
    .ap_idle(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_idle),
    .ap_ready(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_ready),
    .m_axi_gmem_AWVALID(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWVALID),
    .m_axi_gmem_AWREADY(1'b0),
    .m_axi_gmem_AWADDR(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWADDR),
    .m_axi_gmem_AWID(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWID),
    .m_axi_gmem_AWLEN(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWLEN),
    .m_axi_gmem_AWSIZE(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWSIZE),
    .m_axi_gmem_AWBURST(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWBURST),
    .m_axi_gmem_AWLOCK(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWLOCK),
    .m_axi_gmem_AWCACHE(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWCACHE),
    .m_axi_gmem_AWPROT(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWPROT),
    .m_axi_gmem_AWQOS(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWQOS),
    .m_axi_gmem_AWREGION(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWREGION),
    .m_axi_gmem_AWUSER(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_AWUSER),
    .m_axi_gmem_WVALID(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WVALID),
    .m_axi_gmem_WREADY(1'b0),
    .m_axi_gmem_WDATA(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WDATA),
    .m_axi_gmem_WSTRB(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WSTRB),
    .m_axi_gmem_WLAST(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WLAST),
    .m_axi_gmem_WID(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WID),
    .m_axi_gmem_WUSER(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_WUSER),
    .m_axi_gmem_ARVALID(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARVALID),
    .m_axi_gmem_ARREADY(gmem_ARREADY),
    .m_axi_gmem_ARADDR(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARADDR),
    .m_axi_gmem_ARID(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARID),
    .m_axi_gmem_ARLEN(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARLEN),
    .m_axi_gmem_ARSIZE(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARSIZE),
    .m_axi_gmem_ARBURST(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARBURST),
    .m_axi_gmem_ARLOCK(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARLOCK),
    .m_axi_gmem_ARCACHE(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARCACHE),
    .m_axi_gmem_ARPROT(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARPROT),
    .m_axi_gmem_ARQOS(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARQOS),
    .m_axi_gmem_ARREGION(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARREGION),
    .m_axi_gmem_ARUSER(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARUSER),
    .m_axi_gmem_RVALID(gmem_RVALID),
    .m_axi_gmem_RREADY(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_RREADY),
    .m_axi_gmem_RDATA(gmem_RDATA),
    .m_axi_gmem_RLAST(1'b0),
    .m_axi_gmem_RID(1'd0),
    .m_axi_gmem_RFIFONUM(gmem_RFIFONUM),
    .m_axi_gmem_RUSER(1'd0),
    .m_axi_gmem_RRESP(2'd0),
    .m_axi_gmem_BVALID(1'b0),
    .m_axi_gmem_BREADY(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_BREADY),
    .m_axi_gmem_BRESP(2'd0),
    .m_axi_gmem_BID(1'd0),
    .m_axi_gmem_BUSER(1'd0),
    .out_r_din(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_out_r_din),
    .out_r_full_n(out_r_full_n),
    .out_r_write(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_out_r_write),
    .sext_ln11(trunc_ln_reg_146),
    .tranfer_cnt(grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_tranfer_cnt)
);

matbi_hls_rdma_gmem_m_axi #(
    .CONSERVATIVE( 1 ),
    .USER_MAXREQS( 5 ),
    .NUM_READ_OUTSTANDING( 4 ),
    .NUM_WRITE_OUTSTANDING( 4 ),
    .MAX_READ_BURST_LENGTH( 16 ),
    .MAX_WRITE_BURST_LENGTH( 16 ),
    .USER_RFIFONUM_WIDTH( 7 ),
    .C_M_AXI_ID_WIDTH( C_M_AXI_GMEM_ID_WIDTH ),
    .C_M_AXI_ADDR_WIDTH( C_M_AXI_GMEM_ADDR_WIDTH ),
    .C_M_AXI_DATA_WIDTH( C_M_AXI_GMEM_DATA_WIDTH ),
    .C_M_AXI_AWUSER_WIDTH( C_M_AXI_GMEM_AWUSER_WIDTH ),
    .C_M_AXI_ARUSER_WIDTH( C_M_AXI_GMEM_ARUSER_WIDTH ),
    .C_M_AXI_WUSER_WIDTH( C_M_AXI_GMEM_WUSER_WIDTH ),
    .C_M_AXI_RUSER_WIDTH( C_M_AXI_GMEM_RUSER_WIDTH ),
    .C_M_AXI_BUSER_WIDTH( C_M_AXI_GMEM_BUSER_WIDTH ),
    .C_USER_VALUE( C_M_AXI_GMEM_USER_VALUE ),
    .C_PROT_VALUE( C_M_AXI_GMEM_PROT_VALUE ),
    .C_CACHE_VALUE( C_M_AXI_GMEM_CACHE_VALUE ),
    .USER_DW( 64 ),
    .USER_AW( 32 ))
gmem_m_axi_U(
    .AWVALID(m_axi_gmem_AWVALID),
    .AWREADY(m_axi_gmem_AWREADY),
    .AWADDR(m_axi_gmem_AWADDR),
    .AWID(m_axi_gmem_AWID),
    .AWLEN(m_axi_gmem_AWLEN),
    .AWSIZE(m_axi_gmem_AWSIZE),
    .AWBURST(m_axi_gmem_AWBURST),
    .AWLOCK(m_axi_gmem_AWLOCK),
    .AWCACHE(m_axi_gmem_AWCACHE),
    .AWPROT(m_axi_gmem_AWPROT),
    .AWQOS(m_axi_gmem_AWQOS),
    .AWREGION(m_axi_gmem_AWREGION),
    .AWUSER(m_axi_gmem_AWUSER),
    .WVALID(m_axi_gmem_WVALID),
    .WREADY(m_axi_gmem_WREADY),
    .WDATA(m_axi_gmem_WDATA),
    .WSTRB(m_axi_gmem_WSTRB),
    .WLAST(m_axi_gmem_WLAST),
    .WID(m_axi_gmem_WID),
    .WUSER(m_axi_gmem_WUSER),
    .ARVALID(m_axi_gmem_ARVALID),
    .ARREADY(m_axi_gmem_ARREADY),
    .ARADDR(m_axi_gmem_ARADDR),
    .ARID(m_axi_gmem_ARID),
    .ARLEN(m_axi_gmem_ARLEN),
    .ARSIZE(m_axi_gmem_ARSIZE),
    .ARBURST(m_axi_gmem_ARBURST),
    .ARLOCK(m_axi_gmem_ARLOCK),
    .ARCACHE(m_axi_gmem_ARCACHE),
    .ARPROT(m_axi_gmem_ARPROT),
    .ARQOS(m_axi_gmem_ARQOS),
    .ARREGION(m_axi_gmem_ARREGION),
    .ARUSER(m_axi_gmem_ARUSER),
    .RVALID(m_axi_gmem_RVALID),
    .RREADY(m_axi_gmem_RREADY),
    .RDATA(m_axi_gmem_RDATA),
    .RLAST(m_axi_gmem_RLAST),
    .RID(m_axi_gmem_RID),
    .RUSER(m_axi_gmem_RUSER),
    .RRESP(m_axi_gmem_RRESP),
    .BVALID(m_axi_gmem_BVALID),
    .BREADY(m_axi_gmem_BREADY),
    .BRESP(m_axi_gmem_BRESP),
    .BID(m_axi_gmem_BID),
    .BUSER(m_axi_gmem_BUSER),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .I_ARVALID(gmem_ARVALID),
    .I_ARREADY(gmem_ARREADY),
    .I_ARADDR(gmem_ARADDR),
    .I_ARLEN(gmem_ARLEN),
    .I_RVALID(gmem_RVALID),
    .I_RREADY(gmem_RREADY),
    .I_RDATA(gmem_RDATA),
    .I_RFIFONUM(gmem_RFIFONUM),
    .I_AWVALID(1'b0),
    .I_AWREADY(gmem_AWREADY),
    .I_AWADDR(32'd0),
    .I_AWLEN(32'd0),
    .I_WVALID(1'b0),
    .I_WREADY(gmem_WREADY),
    .I_WDATA(64'd0),
    .I_WSTRB(8'd0),
    .I_BVALID(gmem_BVALID),
    .I_BREADY(1'b0)
);

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start_reg <= 1'b0;
    end else begin
        if ((1'b1 == ap_CS_fsm_state9)) begin
            grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start_reg <= 1'b1;
        end else if ((grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_ready == 1'b1)) begin
            grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start_reg <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln11_fu_100_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        trunc_ln_reg_146 <= {{mem[31:3]}};
    end
end

always @ (*) begin
    if ((1'b1 == ap_block_state10_on_subcall_done)) begin
        ap_ST_fsm_state10_blk = 1'b1;
    end else begin
        ap_ST_fsm_state10_blk = 1'b0;
    end
end

always @ (*) begin
    if ((ap_start == 1'b0)) begin
        ap_ST_fsm_state1_blk = 1'b1;
    end else begin
        ap_ST_fsm_state1_blk = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_block_state2_io)) begin
        ap_ST_fsm_state2_blk = 1'b1;
    end else begin
        ap_ST_fsm_state2_blk = 1'b0;
    end
end

assign ap_ST_fsm_state3_blk = 1'b0;

assign ap_ST_fsm_state4_blk = 1'b0;

assign ap_ST_fsm_state5_blk = 1'b0;

assign ap_ST_fsm_state6_blk = 1'b0;

assign ap_ST_fsm_state7_blk = 1'b0;

assign ap_ST_fsm_state8_blk = 1'b0;

assign ap_ST_fsm_state9_blk = 1'b0;

always @ (*) begin
    if (((1'b0 == ap_block_state10_on_subcall_done) & (1'b1 == ap_CS_fsm_state10))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b0))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_state10_on_subcall_done) & (1'b1 == ap_CS_fsm_state10))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln11_fu_100_p2 == 1'd0) & (1'b0 == ap_block_state2_io) & (1'b1 == ap_CS_fsm_state2))) begin
        gmem_ARADDR = sext_ln11_fu_120_p1;
    end else if (((1'b1 == ap_CS_fsm_state9) | ((icmp_ln11_fu_100_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state10)))) begin
        gmem_ARADDR = grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARADDR;
    end else begin
        gmem_ARADDR = 'bx;
    end
end

always @ (*) begin
    if (((icmp_ln11_fu_100_p2 == 1'd0) & (1'b0 == ap_block_state2_io) & (1'b1 == ap_CS_fsm_state2))) begin
        gmem_ARLEN = zext_ln9_fu_106_p1;
    end else if (((1'b1 == ap_CS_fsm_state9) | ((icmp_ln11_fu_100_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state10)))) begin
        gmem_ARLEN = grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARLEN;
    end else begin
        gmem_ARLEN = 'bx;
    end
end

always @ (*) begin
    if (((icmp_ln11_fu_100_p2 == 1'd0) & (1'b0 == ap_block_state2_io) & (1'b1 == ap_CS_fsm_state2))) begin
        gmem_ARVALID = 1'b1;
    end else if (((1'b1 == ap_CS_fsm_state9) | ((icmp_ln11_fu_100_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state10)))) begin
        gmem_ARVALID = grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_ARVALID;
    end else begin
        gmem_ARVALID = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state9) | ((icmp_ln11_fu_100_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state10)))) begin
        gmem_RREADY = grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_m_axi_gmem_RREADY;
    end else begin
        gmem_RREADY = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln11_fu_100_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state2))) begin
        gmem_blk_n_AR = m_axi_gmem_ARREADY;
    end else begin
        gmem_blk_n_AR = 1'b1;
    end
end

always @ (*) begin
    if (((icmp_ln11_fu_100_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state10))) begin
        out_r_write = grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_out_r_write;
    end else begin
        out_r_write = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            if (((icmp_ln11_fu_100_p2 == 1'd1) & (1'b0 == ap_block_state2_io) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_state10;
            end else if (((icmp_ln11_fu_100_p2 == 1'd0) & (1'b0 == ap_block_state2_io) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_state3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end
        end
        ap_ST_fsm_state3 : begin
            ap_NS_fsm = ap_ST_fsm_state4;
        end
        ap_ST_fsm_state4 : begin
            ap_NS_fsm = ap_ST_fsm_state5;
        end
        ap_ST_fsm_state5 : begin
            ap_NS_fsm = ap_ST_fsm_state6;
        end
        ap_ST_fsm_state6 : begin
            ap_NS_fsm = ap_ST_fsm_state7;
        end
        ap_ST_fsm_state7 : begin
            ap_NS_fsm = ap_ST_fsm_state8;
        end
        ap_ST_fsm_state8 : begin
            ap_NS_fsm = ap_ST_fsm_state9;
        end
        ap_ST_fsm_state9 : begin
            ap_NS_fsm = ap_ST_fsm_state10;
        end
        ap_ST_fsm_state10 : begin
            if (((1'b0 == ap_block_state10_on_subcall_done) & (1'b1 == ap_CS_fsm_state10))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state10;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state10 = ap_CS_fsm[32'd9];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state9 = ap_CS_fsm[32'd8];

always @ (*) begin
    ap_block_state10_on_subcall_done = ((icmp_ln11_fu_100_p2 == 1'd0) & (grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_done == 1'b0));
end

always @ (*) begin
    ap_block_state2_io = ((icmp_ln11_fu_100_p2 == 1'd0) & (gmem_ARREADY == 1'b0));
end

always @ (*) begin
    ap_rst_n_inv = ~ap_rst_n;
end

assign grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start = grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_ap_start_reg;

assign grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_tranfer_cnt = {{tranfer_byte[31:3]}};

assign icmp_ln11_fu_100_p2 = ((tranfer_cnt_fu_90_p4 == 29'd0) ? 1'b1 : 1'b0);

assign out_r_din = grp_matbi_hls_rdma_Pipeline_VITIS_LOOP_11_1_fu_80_out_r_din;

assign sext_ln11_fu_120_p1 = trunc_ln_fu_110_p4;

assign tranfer_cnt_fu_90_p4 = {{tranfer_byte[31:3]}};

assign trunc_ln_fu_110_p4 = {{mem[31:3]}};

assign zext_ln9_fu_106_p1 = tranfer_cnt_fu_90_p4;

endmodule //matbi_hls_rdma

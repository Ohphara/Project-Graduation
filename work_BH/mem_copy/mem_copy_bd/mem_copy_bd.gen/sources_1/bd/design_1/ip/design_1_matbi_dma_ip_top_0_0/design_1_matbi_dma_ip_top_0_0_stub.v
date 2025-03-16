// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Mar  9 19:00:53 2025
// Host        : DESKTOP-SQHMHKD running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/LAB/Project_Graduation/Project-Graduation/work_BH/mem_copy_bd/mem_copy_bd.gen/sources_1/bd/design_1/ip/design_1_matbi_dma_ip_top_0_0/design_1_matbi_dma_ip_top_0_0_stub.v
// Design      : design_1_matbi_dma_ip_top_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "matbi_dma_ip_top,Vivado 2022.1" *)
module design_1_matbi_dma_ip_top_0_0(ap_clk, ap_rst_n, m00_axi_awvalid, 
  m00_axi_awready, m00_axi_awaddr, m00_axi_awid, m00_axi_awlen, m00_axi_awsize, 
  m00_axi_awburst, m00_axi_awlock, m00_axi_awcache, m00_axi_awprot, m00_axi_awqos, 
  m00_axi_awregion, m00_axi_awuser, m00_axi_wvalid, m00_axi_wready, m00_axi_wdata, 
  m00_axi_wstrb, m00_axi_wlast, m00_axi_wid, m00_axi_wuser, m00_axi_arvalid, m00_axi_arready, 
  m00_axi_araddr, m00_axi_arid, m00_axi_arlen, m00_axi_arsize, m00_axi_arburst, 
  m00_axi_arlock, m00_axi_arcache, m00_axi_arprot, m00_axi_arqos, m00_axi_arregion, 
  m00_axi_aruser, m00_axi_rvalid, m00_axi_rready, m00_axi_rdata, m00_axi_rlast, m00_axi_rid, 
  m00_axi_ruser, m00_axi_rresp, m00_axi_bvalid, m00_axi_bready, m00_axi_bresp, m00_axi_bid, 
  m00_axi_buser, s_axi_control_awvalid, s_axi_control_awready, s_axi_control_awaddr, 
  s_axi_control_wvalid, s_axi_control_wready, s_axi_control_wdata, s_axi_control_wstrb, 
  s_axi_control_arvalid, s_axi_control_arready, s_axi_control_araddr, 
  s_axi_control_rvalid, s_axi_control_rready, s_axi_control_rdata, s_axi_control_rresp, 
  s_axi_control_bvalid, s_axi_control_bready, s_axi_control_bresp, interrupt)
/* synthesis syn_black_box black_box_pad_pin="ap_clk,ap_rst_n,m00_axi_awvalid,m00_axi_awready,m00_axi_awaddr[31:0],m00_axi_awid[0:0],m00_axi_awlen[7:0],m00_axi_awsize[2:0],m00_axi_awburst[1:0],m00_axi_awlock[1:0],m00_axi_awcache[3:0],m00_axi_awprot[2:0],m00_axi_awqos[3:0],m00_axi_awregion[3:0],m00_axi_awuser[0:0],m00_axi_wvalid,m00_axi_wready,m00_axi_wdata[63:0],m00_axi_wstrb[7:0],m00_axi_wlast,m00_axi_wid[0:0],m00_axi_wuser[0:0],m00_axi_arvalid,m00_axi_arready,m00_axi_araddr[31:0],m00_axi_arid[0:0],m00_axi_arlen[7:0],m00_axi_arsize[2:0],m00_axi_arburst[1:0],m00_axi_arlock[1:0],m00_axi_arcache[3:0],m00_axi_arprot[2:0],m00_axi_arqos[3:0],m00_axi_arregion[3:0],m00_axi_aruser[0:0],m00_axi_rvalid,m00_axi_rready,m00_axi_rdata[63:0],m00_axi_rlast,m00_axi_rid[0:0],m00_axi_ruser[0:0],m00_axi_rresp[1:0],m00_axi_bvalid,m00_axi_bready,m00_axi_bresp[1:0],m00_axi_bid[0:0],m00_axi_buser[0:0],s_axi_control_awvalid,s_axi_control_awready,s_axi_control_awaddr[11:0],s_axi_control_wvalid,s_axi_control_wready,s_axi_control_wdata[31:0],s_axi_control_wstrb[3:0],s_axi_control_arvalid,s_axi_control_arready,s_axi_control_araddr[11:0],s_axi_control_rvalid,s_axi_control_rready,s_axi_control_rdata[31:0],s_axi_control_rresp[1:0],s_axi_control_bvalid,s_axi_control_bready,s_axi_control_bresp[1:0],interrupt" */;
  input ap_clk;
  input ap_rst_n;
  output m00_axi_awvalid;
  input m00_axi_awready;
  output [31:0]m00_axi_awaddr;
  output [0:0]m00_axi_awid;
  output [7:0]m00_axi_awlen;
  output [2:0]m00_axi_awsize;
  output [1:0]m00_axi_awburst;
  output [1:0]m00_axi_awlock;
  output [3:0]m00_axi_awcache;
  output [2:0]m00_axi_awprot;
  output [3:0]m00_axi_awqos;
  output [3:0]m00_axi_awregion;
  output [0:0]m00_axi_awuser;
  output m00_axi_wvalid;
  input m00_axi_wready;
  output [63:0]m00_axi_wdata;
  output [7:0]m00_axi_wstrb;
  output m00_axi_wlast;
  output [0:0]m00_axi_wid;
  output [0:0]m00_axi_wuser;
  output m00_axi_arvalid;
  input m00_axi_arready;
  output [31:0]m00_axi_araddr;
  output [0:0]m00_axi_arid;
  output [7:0]m00_axi_arlen;
  output [2:0]m00_axi_arsize;
  output [1:0]m00_axi_arburst;
  output [1:0]m00_axi_arlock;
  output [3:0]m00_axi_arcache;
  output [2:0]m00_axi_arprot;
  output [3:0]m00_axi_arqos;
  output [3:0]m00_axi_arregion;
  output [0:0]m00_axi_aruser;
  input m00_axi_rvalid;
  output m00_axi_rready;
  input [63:0]m00_axi_rdata;
  input m00_axi_rlast;
  input [0:0]m00_axi_rid;
  input [0:0]m00_axi_ruser;
  input [1:0]m00_axi_rresp;
  input m00_axi_bvalid;
  output m00_axi_bready;
  input [1:0]m00_axi_bresp;
  input [0:0]m00_axi_bid;
  input [0:0]m00_axi_buser;
  input s_axi_control_awvalid;
  output s_axi_control_awready;
  input [11:0]s_axi_control_awaddr;
  input s_axi_control_wvalid;
  output s_axi_control_wready;
  input [31:0]s_axi_control_wdata;
  input [3:0]s_axi_control_wstrb;
  input s_axi_control_arvalid;
  output s_axi_control_arready;
  input [11:0]s_axi_control_araddr;
  output s_axi_control_rvalid;
  input s_axi_control_rready;
  output [31:0]s_axi_control_rdata;
  output [1:0]s_axi_control_rresp;
  output s_axi_control_bvalid;
  input s_axi_control_bready;
  output [1:0]s_axi_control_bresp;
  output interrupt;
endmodule

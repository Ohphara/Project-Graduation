// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Mar  9 19:00:39 2025
// Host        : DESKTOP-SQHMHKD running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/LAB/Project_Graduation/Project-Graduation/work_BH/mem_copy_bd/mem_copy_bd.gen/sources_1/bd/design_1/ip/design_1_processing_system7_0_0/design_1_processing_system7_0_0_stub.v
// Design      : design_1_processing_system7_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "processing_system7_v5_5_processing_system7,Vivado 2022.1" *)
module design_1_processing_system7_0_0(USB0_PORT_INDCTL, USB0_VBUS_PWRSELECT, 
  USB0_VBUS_PWRFAULT, M_AXI_GP0_ARVALID, M_AXI_GP0_AWVALID, M_AXI_GP0_BREADY, 
  M_AXI_GP0_RREADY, M_AXI_GP0_WLAST, M_AXI_GP0_WVALID, M_AXI_GP0_ARID, M_AXI_GP0_AWID, 
  M_AXI_GP0_WID, M_AXI_GP0_ARBURST, M_AXI_GP0_ARLOCK, M_AXI_GP0_ARSIZE, M_AXI_GP0_AWBURST, 
  M_AXI_GP0_AWLOCK, M_AXI_GP0_AWSIZE, M_AXI_GP0_ARPROT, M_AXI_GP0_AWPROT, M_AXI_GP0_ARADDR, 
  M_AXI_GP0_AWADDR, M_AXI_GP0_WDATA, M_AXI_GP0_ARCACHE, M_AXI_GP0_ARLEN, M_AXI_GP0_ARQOS, 
  M_AXI_GP0_AWCACHE, M_AXI_GP0_AWLEN, M_AXI_GP0_AWQOS, M_AXI_GP0_WSTRB, M_AXI_GP0_ACLK, 
  M_AXI_GP0_ARREADY, M_AXI_GP0_AWREADY, M_AXI_GP0_BVALID, M_AXI_GP0_RLAST, 
  M_AXI_GP0_RVALID, M_AXI_GP0_WREADY, M_AXI_GP0_BID, M_AXI_GP0_RID, M_AXI_GP0_BRESP, 
  M_AXI_GP0_RRESP, M_AXI_GP0_RDATA, S_AXI_HP0_ARREADY, S_AXI_HP0_AWREADY, S_AXI_HP0_BVALID, 
  S_AXI_HP0_RLAST, S_AXI_HP0_RVALID, S_AXI_HP0_WREADY, S_AXI_HP0_BRESP, S_AXI_HP0_RRESP, 
  S_AXI_HP0_BID, S_AXI_HP0_RID, S_AXI_HP0_RDATA, S_AXI_HP0_RCOUNT, S_AXI_HP0_WCOUNT, 
  S_AXI_HP0_RACOUNT, S_AXI_HP0_WACOUNT, S_AXI_HP0_ACLK, S_AXI_HP0_ARVALID, 
  S_AXI_HP0_AWVALID, S_AXI_HP0_BREADY, S_AXI_HP0_RDISSUECAP1_EN, S_AXI_HP0_RREADY, 
  S_AXI_HP0_WLAST, S_AXI_HP0_WRISSUECAP1_EN, S_AXI_HP0_WVALID, S_AXI_HP0_ARBURST, 
  S_AXI_HP0_ARLOCK, S_AXI_HP0_ARSIZE, S_AXI_HP0_AWBURST, S_AXI_HP0_AWLOCK, 
  S_AXI_HP0_AWSIZE, S_AXI_HP0_ARPROT, S_AXI_HP0_AWPROT, S_AXI_HP0_ARADDR, S_AXI_HP0_AWADDR, 
  S_AXI_HP0_ARCACHE, S_AXI_HP0_ARLEN, S_AXI_HP0_ARQOS, S_AXI_HP0_AWCACHE, S_AXI_HP0_AWLEN, 
  S_AXI_HP0_AWQOS, S_AXI_HP0_ARID, S_AXI_HP0_AWID, S_AXI_HP0_WID, S_AXI_HP0_WDATA, 
  S_AXI_HP0_WSTRB, FCLK_CLK0, FCLK_RESET0_N, MIO, DDR_CAS_n, DDR_CKE, DDR_Clk_n, DDR_Clk, DDR_CS_n, 
  DDR_DRSTB, DDR_ODT, DDR_RAS_n, DDR_WEB, DDR_BankAddr, DDR_Addr, DDR_VRN, DDR_VRP, DDR_DM, DDR_DQ, 
  DDR_DQS_n, DDR_DQS, PS_SRSTB, PS_CLK, PS_PORB)
/* synthesis syn_black_box black_box_pad_pin="USB0_PORT_INDCTL[1:0],USB0_VBUS_PWRSELECT,USB0_VBUS_PWRFAULT,M_AXI_GP0_ARVALID,M_AXI_GP0_AWVALID,M_AXI_GP0_BREADY,M_AXI_GP0_RREADY,M_AXI_GP0_WLAST,M_AXI_GP0_WVALID,M_AXI_GP0_ARID[11:0],M_AXI_GP0_AWID[11:0],M_AXI_GP0_WID[11:0],M_AXI_GP0_ARBURST[1:0],M_AXI_GP0_ARLOCK[1:0],M_AXI_GP0_ARSIZE[2:0],M_AXI_GP0_AWBURST[1:0],M_AXI_GP0_AWLOCK[1:0],M_AXI_GP0_AWSIZE[2:0],M_AXI_GP0_ARPROT[2:0],M_AXI_GP0_AWPROT[2:0],M_AXI_GP0_ARADDR[31:0],M_AXI_GP0_AWADDR[31:0],M_AXI_GP0_WDATA[31:0],M_AXI_GP0_ARCACHE[3:0],M_AXI_GP0_ARLEN[3:0],M_AXI_GP0_ARQOS[3:0],M_AXI_GP0_AWCACHE[3:0],M_AXI_GP0_AWLEN[3:0],M_AXI_GP0_AWQOS[3:0],M_AXI_GP0_WSTRB[3:0],M_AXI_GP0_ACLK,M_AXI_GP0_ARREADY,M_AXI_GP0_AWREADY,M_AXI_GP0_BVALID,M_AXI_GP0_RLAST,M_AXI_GP0_RVALID,M_AXI_GP0_WREADY,M_AXI_GP0_BID[11:0],M_AXI_GP0_RID[11:0],M_AXI_GP0_BRESP[1:0],M_AXI_GP0_RRESP[1:0],M_AXI_GP0_RDATA[31:0],S_AXI_HP0_ARREADY,S_AXI_HP0_AWREADY,S_AXI_HP0_BVALID,S_AXI_HP0_RLAST,S_AXI_HP0_RVALID,S_AXI_HP0_WREADY,S_AXI_HP0_BRESP[1:0],S_AXI_HP0_RRESP[1:0],S_AXI_HP0_BID[5:0],S_AXI_HP0_RID[5:0],S_AXI_HP0_RDATA[63:0],S_AXI_HP0_RCOUNT[7:0],S_AXI_HP0_WCOUNT[7:0],S_AXI_HP0_RACOUNT[2:0],S_AXI_HP0_WACOUNT[5:0],S_AXI_HP0_ACLK,S_AXI_HP0_ARVALID,S_AXI_HP0_AWVALID,S_AXI_HP0_BREADY,S_AXI_HP0_RDISSUECAP1_EN,S_AXI_HP0_RREADY,S_AXI_HP0_WLAST,S_AXI_HP0_WRISSUECAP1_EN,S_AXI_HP0_WVALID,S_AXI_HP0_ARBURST[1:0],S_AXI_HP0_ARLOCK[1:0],S_AXI_HP0_ARSIZE[2:0],S_AXI_HP0_AWBURST[1:0],S_AXI_HP0_AWLOCK[1:0],S_AXI_HP0_AWSIZE[2:0],S_AXI_HP0_ARPROT[2:0],S_AXI_HP0_AWPROT[2:0],S_AXI_HP0_ARADDR[31:0],S_AXI_HP0_AWADDR[31:0],S_AXI_HP0_ARCACHE[3:0],S_AXI_HP0_ARLEN[3:0],S_AXI_HP0_ARQOS[3:0],S_AXI_HP0_AWCACHE[3:0],S_AXI_HP0_AWLEN[3:0],S_AXI_HP0_AWQOS[3:0],S_AXI_HP0_ARID[5:0],S_AXI_HP0_AWID[5:0],S_AXI_HP0_WID[5:0],S_AXI_HP0_WDATA[63:0],S_AXI_HP0_WSTRB[7:0],FCLK_CLK0,FCLK_RESET0_N,MIO[53:0],DDR_CAS_n,DDR_CKE,DDR_Clk_n,DDR_Clk,DDR_CS_n,DDR_DRSTB,DDR_ODT,DDR_RAS_n,DDR_WEB,DDR_BankAddr[2:0],DDR_Addr[14:0],DDR_VRN,DDR_VRP,DDR_DM[3:0],DDR_DQ[31:0],DDR_DQS_n[3:0],DDR_DQS[3:0],PS_SRSTB,PS_CLK,PS_PORB" */;
  output [1:0]USB0_PORT_INDCTL;
  output USB0_VBUS_PWRSELECT;
  input USB0_VBUS_PWRFAULT;
  output M_AXI_GP0_ARVALID;
  output M_AXI_GP0_AWVALID;
  output M_AXI_GP0_BREADY;
  output M_AXI_GP0_RREADY;
  output M_AXI_GP0_WLAST;
  output M_AXI_GP0_WVALID;
  output [11:0]M_AXI_GP0_ARID;
  output [11:0]M_AXI_GP0_AWID;
  output [11:0]M_AXI_GP0_WID;
  output [1:0]M_AXI_GP0_ARBURST;
  output [1:0]M_AXI_GP0_ARLOCK;
  output [2:0]M_AXI_GP0_ARSIZE;
  output [1:0]M_AXI_GP0_AWBURST;
  output [1:0]M_AXI_GP0_AWLOCK;
  output [2:0]M_AXI_GP0_AWSIZE;
  output [2:0]M_AXI_GP0_ARPROT;
  output [2:0]M_AXI_GP0_AWPROT;
  output [31:0]M_AXI_GP0_ARADDR;
  output [31:0]M_AXI_GP0_AWADDR;
  output [31:0]M_AXI_GP0_WDATA;
  output [3:0]M_AXI_GP0_ARCACHE;
  output [3:0]M_AXI_GP0_ARLEN;
  output [3:0]M_AXI_GP0_ARQOS;
  output [3:0]M_AXI_GP0_AWCACHE;
  output [3:0]M_AXI_GP0_AWLEN;
  output [3:0]M_AXI_GP0_AWQOS;
  output [3:0]M_AXI_GP0_WSTRB;
  input M_AXI_GP0_ACLK;
  input M_AXI_GP0_ARREADY;
  input M_AXI_GP0_AWREADY;
  input M_AXI_GP0_BVALID;
  input M_AXI_GP0_RLAST;
  input M_AXI_GP0_RVALID;
  input M_AXI_GP0_WREADY;
  input [11:0]M_AXI_GP0_BID;
  input [11:0]M_AXI_GP0_RID;
  input [1:0]M_AXI_GP0_BRESP;
  input [1:0]M_AXI_GP0_RRESP;
  input [31:0]M_AXI_GP0_RDATA;
  output S_AXI_HP0_ARREADY;
  output S_AXI_HP0_AWREADY;
  output S_AXI_HP0_BVALID;
  output S_AXI_HP0_RLAST;
  output S_AXI_HP0_RVALID;
  output S_AXI_HP0_WREADY;
  output [1:0]S_AXI_HP0_BRESP;
  output [1:0]S_AXI_HP0_RRESP;
  output [5:0]S_AXI_HP0_BID;
  output [5:0]S_AXI_HP0_RID;
  output [63:0]S_AXI_HP0_RDATA;
  output [7:0]S_AXI_HP0_RCOUNT;
  output [7:0]S_AXI_HP0_WCOUNT;
  output [2:0]S_AXI_HP0_RACOUNT;
  output [5:0]S_AXI_HP0_WACOUNT;
  input S_AXI_HP0_ACLK;
  input S_AXI_HP0_ARVALID;
  input S_AXI_HP0_AWVALID;
  input S_AXI_HP0_BREADY;
  input S_AXI_HP0_RDISSUECAP1_EN;
  input S_AXI_HP0_RREADY;
  input S_AXI_HP0_WLAST;
  input S_AXI_HP0_WRISSUECAP1_EN;
  input S_AXI_HP0_WVALID;
  input [1:0]S_AXI_HP0_ARBURST;
  input [1:0]S_AXI_HP0_ARLOCK;
  input [2:0]S_AXI_HP0_ARSIZE;
  input [1:0]S_AXI_HP0_AWBURST;
  input [1:0]S_AXI_HP0_AWLOCK;
  input [2:0]S_AXI_HP0_AWSIZE;
  input [2:0]S_AXI_HP0_ARPROT;
  input [2:0]S_AXI_HP0_AWPROT;
  input [31:0]S_AXI_HP0_ARADDR;
  input [31:0]S_AXI_HP0_AWADDR;
  input [3:0]S_AXI_HP0_ARCACHE;
  input [3:0]S_AXI_HP0_ARLEN;
  input [3:0]S_AXI_HP0_ARQOS;
  input [3:0]S_AXI_HP0_AWCACHE;
  input [3:0]S_AXI_HP0_AWLEN;
  input [3:0]S_AXI_HP0_AWQOS;
  input [5:0]S_AXI_HP0_ARID;
  input [5:0]S_AXI_HP0_AWID;
  input [5:0]S_AXI_HP0_WID;
  input [63:0]S_AXI_HP0_WDATA;
  input [7:0]S_AXI_HP0_WSTRB;
  output FCLK_CLK0;
  output FCLK_RESET0_N;
  inout [53:0]MIO;
  inout DDR_CAS_n;
  inout DDR_CKE;
  inout DDR_Clk_n;
  inout DDR_Clk;
  inout DDR_CS_n;
  inout DDR_DRSTB;
  inout DDR_ODT;
  inout DDR_RAS_n;
  inout DDR_WEB;
  inout [2:0]DDR_BankAddr;
  inout [14:0]DDR_Addr;
  inout DDR_VRN;
  inout DDR_VRP;
  inout [3:0]DDR_DM;
  inout [31:0]DDR_DQ;
  inout [3:0]DDR_DQS_n;
  inout [3:0]DDR_DQS;
  inout PS_SRSTB;
  inout PS_CLK;
  inout PS_PORB;
endmodule

`timescale 1ns / 1ps

module mytb();
	parameter ADDR_BITWIDTH_GLB = 10;
	parameter ADDR_BITWIDTH_SPAD = 10;
	parameter DATA_BITWIDTH = 8;
	parameter ADDR_BITWIDTH = 10;
    parameter A_READ_ADDR = 10;
	parameter A_LOAD_ADDR = 10;
	parameter W_READ_ADDR = 0;
	parameter W_LOAD_ADDR = 0;
	parameter PSUM_READ_ADDR = 0;
	parameter PSUM_LOAD_ADDR = 0;
	parameter PSUM_ADDR =110;
    parameter X_dim = 3;
    parameter Y_dim = 3;
    
    parameter kernel_size = 3;
    parameter act_size = 5;
    parameter NUM_GLB_IACT = 1;
    parameter NUM_GLB_PSUM = 1;
    parameter NUM_GLB_WGHT = 1;



    reg clk, reset;
//  PE interfaces                     //
	reg start;
	wire compute_done;
	wire load_done;



//          GLB Interfaces              //


//    west 0 glb interfaces             //
	reg write_en_iact_west_0;
	reg signed [DATA_BITWIDTH-1:0] w_data_iact_west_0;
	reg [ADDR_BITWIDTH-1:0] w_addr_iact_west_0;
	
	reg signed [DATA_BITWIDTH-1:0] w_data_wght_west_0;
	reg [ADDR_BITWIDTH-1:0] w_addr_wght_west_0;
	reg write_en_wght_west_0;

	reg [ADDR_BITWIDTH-1:0] r_addr_psum_west_0;
	wire signed [DATA_BITWIDTH-1:0] r_data_psum_west_0;
	reg r_req_psum_west_0;


	reg [ADDR_BITWIDTH-1:0] r_addr_psum_inter_west_0;
	reg r_req_psum_inter_west_0;


//    west 1 glb interfaces            //

	reg write_en_iact_west_1;
	reg signed [DATA_BITWIDTH-1:0] w_data_iact_west_1;
	reg [ADDR_BITWIDTH-1:0] w_addr_iact_west_1;
	
	reg signed [DATA_BITWIDTH-1:0] w_data_wght_west_1;
	reg [ADDR_BITWIDTH-1:0] w_addr_wght_west_1;
	reg write_en_wght_west_1;

	reg [ADDR_BITWIDTH-1:0] r_addr_psum_west_1;
	wire signed [DATA_BITWIDTH-1:0] r_data_psum_west_1;
	reg r_req_psum_west_1;

	reg [ADDR_BITWIDTH-1:0] r_addr_psum_inter_west_1;
	reg r_req_psum_inter_west_1;

//   east 0   glb interfaces          //

	reg write_en_iact_east_0;
	reg signed [DATA_BITWIDTH-1:0] w_data_iact_east_0;
	reg [ADDR_BITWIDTH-1:0] w_addr_iact_east_0;
	
	reg signed [DATA_BITWIDTH-1:0] w_data_wght_east_0;
	reg [ADDR_BITWIDTH-1:0] w_addr_wght_east_0;
	reg write_en_wght_east_0;

	reg [ADDR_BITWIDTH-1:0] r_addr_psum_east_0;
	wire signed [DATA_BITWIDTH-1:0] r_data_psum_east_0;
	reg r_req_psum_east_0;


	reg [ADDR_BITWIDTH-1:0] r_addr_psum_inter_east_0;
	reg r_req_psum_inter_east_0;



//   east 1 glb interfaces           //


	reg write_en_iact_east_1;
	reg signed [DATA_BITWIDTH-1:0] w_data_iact_east_1;
	reg [ADDR_BITWIDTH-1:0] w_addr_iact_east_1;
	
	reg signed [DATA_BITWIDTH-1:0] w_data_wght_east_1;
	reg [ADDR_BITWIDTH-1:0] w_addr_wght_east_1;
	reg write_en_wght_east_1;

	reg [ADDR_BITWIDTH-1:0] r_addr_psum_east_1;
	wire signed [DATA_BITWIDTH-1:0] r_data_psum_east_1;
	reg r_req_psum_east_1;


	reg [ADDR_BITWIDTH-1:0] r_addr_psum_inter_east_1;
	reg r_req_psum_inter_east_1;



//              ROUTER ctrl            //
 	reg west_enable_i_west_0_wght;
	
	reg west_enable_i_west_0_iact;

 	reg west_enable_i_west_1_wght;
	
	reg west_enable_i_west_1_iact;

	reg west_enable_i_east_0_wght;
	
	reg west_enable_i_east_0_iact;

	reg west_enable_i_east_1_wght;
	
	reg west_enable_i_east_1_iact;


//      MODE for 4 ROUTERS          //

	reg [3:0] router_mode_west_0_wght; 
 
	reg [3:0] router_mode_west_0_iact; 

	reg [3:0] router_mode_west_0_psum;

	reg [3:0] router_mode_west_1_wght; 
 
	reg [3:0] router_mode_west_1_iact; 

	reg [3:0] router_mode_west_1_psum;

	reg [3:0] router_mode_east_0_wght; 
 
	reg [3:0] router_mode_east_0_iact; 

	reg [3:0] router_mode_east_0_psum;

	reg [3:0] router_mode_east_1_wght; 
 
	reg [3:0] router_mode_east_1_iact; 

	reg [3:0] router_mode_east_1_psum;







//   test signal for tb    //
	// reg [DATA_BITWIDTH-1:0] west_data_o_west_0_psum_tb;
	// reg west_enable_o_west_0_psum_tb;
	// reg [DATA_BITWIDTH*X_dim-1:0] west_data_i_west_0_psum_tb;
	// reg [DATA_BITWIDTH*X_dim-1:0] east_data_o_west_0_psum_tb;
	// reg [ADDR_BITWIDTH-1:0] west_addr_o_west_0_psum_tb;
	// reg [DATA_BITWIDTH*X_dim-1:0] east_data_i_west_0_psum_tb;

	HMNOC_4cluster_wpsum

		#(
		 .ADDR_BITWIDTH_GLB(ADDR_BITWIDTH_GLB),
		 .ADDR_BITWIDTH_SPAD(ADDR_BITWIDTH_SPAD),
		 .DATA_BITWIDTH(DATA_BITWIDTH),
		 .ADDR_BITWIDTH(ADDR_BITWIDTH),
		 .A_LOAD_ADDR(A_LOAD_ADDR),
		 .A_READ_ADDR(A_READ_ADDR),
		 .W_LOAD_ADDR(W_LOAD_ADDR),
		 .W_READ_ADDR(W_READ_ADDR),
		 .PSUM_ADDR(PSUM_ADDR),
		 .X_dim(X_dim),
		 .Y_dim(Y_dim),

		 .kernel_size(kernel_size),
		 .act_size(act_size),
		 .NUM_GLB_IACT(NUM_GLB_IACT),
		 .NUM_GLB_PSUM(NUM_GLB_PSUM),
		 .NUM_GLB_WGHT(NUM_GLB_WGHT)
	     )
	HMNOC_4cluster_0
		(
		.clk(clk), 
		.reset(reset),
		.start(start),	  
		.compute_done(compute_done),
		.load_done(load_done),

		// west 0  Interfaces
		.write_en_iact_west_0(write_en_iact_west_0),
		.w_data_iact_west_0(w_data_iact_west_0),
		.w_addr_iact_west_0(w_addr_iact_west_0),

		.west_enable_i_west_0_iact(west_enable_i_west_0_iact),
		.router_mode_west_0_iact(router_mode_west_0_iact),



		.write_en_wght_west_0(write_en_wght_west_0),
		.w_data_wght_west_0(w_data_wght_west_0),
		.w_addr_wght_west_0(w_addr_wght_west_0),

		.west_enable_i_west_0_wght(west_enable_i_west_0_wght),
		.router_mode_west_0_wght(router_mode_west_0_wght),


		.r_req_psum_west_0(r_req_psum_west_0),
		.r_req_psum_inter_west_0(r_req_psum_inter_west_0),
		.r_addr_psum_west_0(r_addr_psum_west_0),
		.r_addr_psum_inter_west_0(r_addr_psum_inter_west_0),
		.r_data_psum_west_0(r_data_psum_west_0),
		.router_mode_west_0_psum(router_mode_west_0_psum),
//      west 1 interfaces
		.write_en_iact_west_1(write_en_iact_west_1),
		.w_data_iact_west_1(w_data_iact_west_1),
		.w_addr_iact_west_1(w_addr_iact_west_1),

		.west_enable_i_west_1_iact(west_enable_i_west_1_iact),
		.router_mode_west_1_iact(router_mode_west_1_iact),



		.write_en_wght_west_1(write_en_wght_west_1),
		.w_data_wght_west_1(w_data_wght_west_1),
		.w_addr_wght_west_1(w_addr_wght_west_1),

		.west_enable_i_west_1_wght(west_enable_i_west_1_wght),
		.router_mode_west_1_wght(router_mode_west_1_wght),


		.r_req_psum_west_1(r_req_psum_west_1),
		.r_req_psum_inter_west_1(r_req_psum_inter_west_1),
		.r_addr_psum_west_1(r_addr_psum_west_1),
		.r_addr_psum_inter_west_1(r_addr_psum_inter_west_1),
		.r_data_psum_west_1(r_data_psum_west_1),
		.router_mode_west_1_psum(router_mode_west_1_psum),
//      east 0 interfaces
		.write_en_iact_east_0(write_en_iact_east_0),
		.w_data_iact_east_0(w_data_iact_east_0),
		.w_addr_iact_east_0(w_addr_iact_east_0),

		.west_enable_i_east_0_iact(west_enable_i_east_0_iact),
		.router_mode_east_0_iact(router_mode_east_0_iact),



		.write_en_wght_east_0(write_en_wght_east_0),
		.w_data_wght_east_0(w_data_wght_east_0),
		.w_addr_wght_east_0(w_addr_wght_east_0),

		.west_enable_i_east_0_wght(west_enable_i_east_0_wght),
		.router_mode_east_0_wght(router_mode_east_0_wght),


		.r_req_psum_east_0(r_req_psum_east_0),
		.r_req_psum_inter_east_0(r_req_psum_inter_east_0),
		.r_addr_psum_east_0(r_addr_psum_east_0),
		.r_addr_psum_inter_east_0(r_addr_psum_inter_east_0),
		.r_data_psum_east_0(r_data_psum_east_0),
		.router_mode_east_0_psum(router_mode_east_0_psum),
//      east 1 interfaces
		.write_en_iact_east_1(write_en_iact_east_1),
		.w_data_iact_east_1(w_data_iact_east_1),
		.w_addr_iact_east_1(w_addr_iact_east_1),

		.west_enable_i_east_1_iact(west_enable_i_east_1_iact),
		.router_mode_east_1_iact(router_mode_east_1_iact),



		.write_en_wght_east_1(write_en_wght_east_1),
		.w_data_wght_east_1(w_data_wght_east_1),
		.w_addr_wght_east_1(w_addr_wght_east_1),

		.west_enable_i_east_1_wght(west_enable_i_east_1_wght),
		.router_mode_east_1_wght(router_mode_east_1_wght),


		.r_req_psum_east_1(r_req_psum_east_1),
		.r_req_psum_inter_east_1(r_req_psum_inter_east_1),
		.r_addr_psum_east_1(r_addr_psum_east_1),
		.r_addr_psum_inter_east_1(r_addr_psum_inter_east_1),
		.r_data_psum_east_1(r_data_psum_east_1),
		.router_mode_east_1_psum(router_mode_east_1_psum)
	);

	integer clk_prd = 10;
	integer i,j,a,m,n;
	localparam size=640;
	integer handle_west_0,handle_west_1,handle_east_0,handle_east_1;
	integer desc_west_0,desc_west_1,desc_east_0,desc_east_1;
	reg signed [DATA_BITWIDTH-1:0] mem[0:size*size-1];

	always begin
		clk = 0; #(clk_prd/2);
		clk = 1; #(clk_prd/2);
		//0.1GHz
	end	
	
	localparam ALL=0;
	localparam NORTH=1;
	localparam SOUTH=2;
	localparam WEST=3;
	localparam EAST=4;
	localparam EASTNORTH=5;
	localparam EASTSOUTH=6;
	localparam EASTWEST=7;
	localparam WESTNORTH=8;
	localparam WESTSOUTH=9;
	localparam WESTEAST = 10;
	localparam CLOSED=11;

	initial begin
		reset = 1; #30;
		reset = 0;
		start = 0;
		west_enable_i_west_0_wght = 0;
		west_enable_i_west_1_wght = 0;
		west_enable_i_east_0_wght = 0;
		west_enable_i_east_1_wght = 0;
		west_enable_i_east_0_iact = 0;
		west_enable_i_east_1_iact = 0;
		west_enable_i_west_0_iact = 0;
		west_enable_i_west_1_iact = 0;
		router_mode_west_0_wght = CLOSED;
		router_mode_east_0_wght = CLOSED;		
		router_mode_west_1_wght = CLOSED;		
		router_mode_east_1_wght = CLOSED;
		router_mode_east_0_iact = CLOSED;
		router_mode_east_1_iact = CLOSED;	
		router_mode_west_0_iact = CLOSED;
		router_mode_west_1_iact = CLOSED;
		router_mode_west_0_psum = CLOSED;
		router_mode_west_1_psum = CLOSED;
		router_mode_east_0_psum = CLOSED;
		router_mode_east_1_psum = CLOSED;
		

		#100;



////////////////////////////////////////////////

		//writing weights to glb_wght
		write_en_wght_west_0 = 1;	
		/*
		for(i=0; i<kernel_size**2;i=i+1) begin
			w_data_wght_west_0 = 1;
			w_addr_wght_west_0 = W_LOAD_ADDR+i;
			#(clk_prd);
		end
		*/
		w_data_wght_west_0 = 2;
		w_addr_wght_west_0 = W_LOAD_ADDR;
		#(clk_prd);
		w_data_wght_west_0 = 4;
		w_addr_wght_west_0 = W_LOAD_ADDR+1;
		#(clk_prd);
		w_data_wght_west_0 = -2;
		w_addr_wght_west_0 = W_LOAD_ADDR+2;
		#(clk_prd);
		w_data_wght_west_0 = -4;
		w_addr_wght_west_0 = W_LOAD_ADDR+3;
		#(clk_prd);
		w_data_wght_west_0 = 8;
		w_addr_wght_west_0 = W_LOAD_ADDR+4;
		#(clk_prd);
		w_data_wght_west_0 = 2;
		w_addr_wght_west_0 = W_LOAD_ADDR+5;
		#(clk_prd);
		w_data_wght_west_0 = 4;
		w_addr_wght_west_0 = W_LOAD_ADDR+6;
		#(clk_prd);
		w_data_wght_west_0 = -2;
		w_addr_wght_west_0 = W_LOAD_ADDR+7;
		#(clk_prd);
		w_data_wght_west_0 = 0;
		w_addr_wght_west_0 = W_LOAD_ADDR+8;
		#(clk_prd);

		write_en_wght_west_0 = 0;
		
////////////////////////////////////////////////

		write_en_iact_west_0 = 1;
		/*
		for(i=0; i<kernel_size**2;i=i+1) begin
			w_data_wght_west_0 = 1;
			w_addr_wght_west_0 = W_LOAD_ADDR+i;
			#(clk_prd);
		end
		*/
		// Row 0
		w_data_iact_west_0 = 8;       // (0,0): 0.50 * 16 = 8
		w_addr_iact_west_0 = A_LOAD_ADDR;
		#(clk_prd);
		w_data_iact_west_0 = -4;      // (0,1): -0.25 * 16 = -4
		w_addr_iact_west_0 = A_LOAD_ADDR+1;
		#(clk_prd);
		w_data_iact_west_0 = 12;      // (0,2): 0.75 * 16 = 12
		w_addr_iact_west_0 = A_LOAD_ADDR+2;
		#(clk_prd);
		w_data_iact_west_0 = 16;      // (0,3): 1.00 * 16 = 16
		w_addr_iact_west_0 = A_LOAD_ADDR+3;
		#(clk_prd);
		w_data_iact_west_0 = 4;       // (0,4): 0.25 * 16 = 4
		w_addr_iact_west_0 = A_LOAD_ADDR+4;
		#(clk_prd);

		// Row 1
		w_data_iact_west_0 = 16;      // (1,0): 1.00 * 16 = 16
		w_addr_iact_west_0 = A_LOAD_ADDR+5;
		#(clk_prd);
		w_data_iact_west_0 = 0;       // (1,1): 0.00 * 16 = 0
		w_addr_iact_west_0 = A_LOAD_ADDR+6;
		#(clk_prd);
		w_data_iact_west_0 = -8;      // (1,2): -0.50 * 16 = -8
		w_addr_iact_west_0 = A_LOAD_ADDR+7;
		#(clk_prd);
		w_data_iact_west_0 = 8;       // (1,3): 0.50 * 16 = 8
		w_addr_iact_west_0 = A_LOAD_ADDR+8;
		#(clk_prd);
		w_data_iact_west_0 = -4;      // (1,4): -0.25 * 16 = -4
		w_addr_iact_west_0 = A_LOAD_ADDR+9;
		#(clk_prd);

		// Row 2
		w_data_iact_west_0 = 4;       // (2,0): 0.25 * 16 = 4
		w_addr_iact_west_0 = A_LOAD_ADDR+10;
		#(clk_prd);
		w_data_iact_west_0 = 8;       // (2,1): 0.50 * 16 = 8
		w_addr_iact_west_0 = A_LOAD_ADDR+11;
		#(clk_prd);
		w_data_iact_west_0 = -12;     // (2,2): -0.75 * 16 = -12
		w_addr_iact_west_0 = A_LOAD_ADDR+12;
		#(clk_prd);
		w_data_iact_west_0 = 2;       // (2,3): 0.125 * 16 = 2
		w_addr_iact_west_0 = A_LOAD_ADDR+13;
		#(clk_prd);
		w_data_iact_west_0 = 0;       // (2,4): 0.00 * 16 = 0
		w_addr_iact_west_0 = A_LOAD_ADDR+14;
		#(clk_prd);

		// Row 3
		w_data_iact_west_0 = 8;       // (3,0): 0.50 * 16 = 8
		w_addr_iact_west_0 = A_LOAD_ADDR+15;
		#(clk_prd);
		w_data_iact_west_0 = -8;      // (3,1): -0.50 * 16 = -8
		w_addr_iact_west_0 = A_LOAD_ADDR+16;
		#(clk_prd);
		w_data_iact_west_0 = 16;      // (3,2): 1.00 * 16 = 16
		w_addr_iact_west_0 = A_LOAD_ADDR+17;
		#(clk_prd);
		w_data_iact_west_0 = -16;     // (3,3): -1.00 * 16 = -16
		w_addr_iact_west_0 = A_LOAD_ADDR+18;
		#(clk_prd);
		w_data_iact_west_0 = 12;      // (3,4): 0.75 * 16 = 12
		w_addr_iact_west_0 = A_LOAD_ADDR+19;
		#(clk_prd);

		// Row 4
		w_data_iact_west_0 = -4;      // (4,0): -0.25 * 16 = -4
		w_addr_iact_west_0 = A_LOAD_ADDR+20;
		#(clk_prd);
		w_data_iact_west_0 = 2;       // (4,1): 0.125 * 16 = 2
		w_addr_iact_west_0 = A_LOAD_ADDR+21;
		#(clk_prd);
		w_data_iact_west_0 = 8;       // (4,2): 0.50 * 16 = 8
		w_addr_iact_west_0 = A_LOAD_ADDR+22;
		#(clk_prd);
		w_data_iact_west_0 = -8;      // (4,3): -0.50 * 16 = -8
		w_addr_iact_west_0 = A_LOAD_ADDR+23;
		#(clk_prd);
		w_data_iact_west_0 = 0;       // (4,4): 0.00 * 16 = 0
		w_addr_iact_west_0 = A_LOAD_ADDR+24;
		#(clk_prd);


		write_en_iact_west_0 = 0;
		
////////////////////////////////////////////////

		$display("\n\nLoading Begins: Weights.....\n\n");
		// read_req_wght = 1;
		// r_addr_wght	= 0;
		#(clk_prd);
		#(clk_prd/2);

		west_enable_i_west_0_wght = 1;
		router_mode_west_0_wght = ALL;

		#(clk_prd);
		#(clk_prd);
		#(clk_prd);

		for(i=1; i<=kernel_size**2; i=i+1) begin
			#(clk_prd);
		end
		
		west_enable_i_west_0_wght = 0; 

		router_mode_west_0_wght = CLOSED;

		wait(load_done==1);

////////////////////////////////////////////////

		$display("\n\nLoading Begins: Iacts.....\n\n");
		// read_req_iact = 1;
		// r_addr_iact	= 0;
		#(clk_prd);
		west_enable_i_west_0_iact = 1;
		router_mode_west_0_iact = ALL;
		
		// load_en_iact = 1;
		#(clk_prd);
		#(clk_prd);
		#(clk_prd);
		for(i=1; i<=act_size**2; i=i+1) begin
			// r_addr_iact= i;
			#(clk_prd);
			// load_en_iact = 0;
		end

		west_enable_i_west_0_iact = 0;
		west_enable_i_west_1_iact = 0;
		west_enable_i_east_0_iact = 0;
		west_enable_i_east_1_iact = 0;
		router_mode_west_0_iact = CLOSED;
		router_mode_west_1_iact = CLOSED;
		router_mode_east_0_iact = CLOSED;
		router_mode_east_1_iact = CLOSED;

		wait(load_done==1);	

////////////////////////////////////////////////

		//start computing
		#(clk_prd);
		#(clk_prd);
		#(clk_prd);

		for(i=0; i<X_dim; i=i+1) begin
			start = 1; #25; 
			start = 0;
			wait (compute_done == 1);
			$display("\n\nrow %d",i+1);

			#80;
			r_req_psum_west_0 = 1;
			r_req_psum_west_1 = 1;
			r_req_psum_east_0 = 1;
			r_req_psum_east_1 = 1;

			for(j=0;j<X_dim;j=j+1)
			begin
				r_addr_psum_west_0 = PSUM_LOAD_ADDR + (i * X_dim) + j;
				r_addr_psum_west_1 = PSUM_LOAD_ADDR + (i * X_dim) + j;
				r_addr_psum_east_0 = PSUM_LOAD_ADDR + (i * X_dim) + j;
				r_addr_psum_east_1 = PSUM_LOAD_ADDR + (i * X_dim) + j;

				#(clk_prd);

				$display("col %d: %d\n",j+1, r_data_psum_west_0);
				//$display(desc_west_1,"%b",r_data_psum_west_1);
				//$display(desc_east_0,"%b",r_data_psum_east_0);
				//$display(desc_east_1,"%b",r_data_psum_east_1);
			end

			r_req_psum_west_0=0;
			r_req_psum_west_1=0;
			r_req_psum_east_0=0;
			r_req_psum_east_1=0;
		end
		$stop;
	end
endmodule
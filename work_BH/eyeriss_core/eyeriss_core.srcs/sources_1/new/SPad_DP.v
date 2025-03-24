
//  Xilinx True Dual Port RAM, No Change, Dual Clock
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  This is a no change RAM which retains the last read value on the output during writes
//  which is the most power efficient mode.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

module SPad_DP #(
    parameter RAM_WIDTH = 8,                       // Specify RAM data width
    parameter RAM_DEPTH = 512,                     // Specify RAM depth (number of entries)
    parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
)(
    input clk,
    input [clogb2(RAM_DEPTH-1)-1:0] addra,  // Port A address bus, width determined from RAM_DEPTH
    input [clogb2(RAM_DEPTH-1)-1:0] addrb,  // Port B address bus, width determined from RAM_DEPTH
    //input [RAM_WIDTH-1:0] dina,           // Port A RAM input data
    input [RAM_WIDTH-1:0] dinb,           // Port B RAM input data
    //input wea,                            // Port A write enable
    input web,                            // Port B write enable
    //input ena,                            // Port A RAM Enable, for additional power savings, disable port when not in use
    //input enb,                            // Port B RAM Enable, for additional power savings, disable port when not in use
    output [RAM_WIDTH-1:0] douta         // Port A RAM output data
    //output [RAM_WIDTH-1:0] doutb          // Port B RAM output data
);

    reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
    reg [RAM_WIDTH-1:0] ram_data_a = {RAM_WIDTH{1'b0}};
    reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};

    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
        if (INIT_FILE != "") 
        begin: use_init_file
            initial
                $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
        end 
        else 
        begin: init_bram_to_zero
            integer ram_index;
            initial begin
                for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
                BRAM[ram_index] = {RAM_WIDTH{1'b0}};
            end
        end
    endgenerate

    always @(posedge clk)
    begin
        ram_data_a <= BRAM[addra];
    end

    always @(posedge clk)
    begin
        if (web)
            BRAM[addrb] <= dinb;
    end

    assign douta = ram_data_a;
    assign doutb = ram_data_b;

    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
    endfunction

endmodule

// The following is an instantiation template for xilinx_true_dual_port_no_change_2_clock_ram
/*
  //  Xilinx True Dual Port RAM, No Change, Dual Clock
  xilinx_true_dual_port_no_change_2_clock_ram #(
    .RAM_WIDTH(18),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .addra(addra),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(addrb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(dina),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(dinb),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clka),     // Port A clock
    .clkb(clkb),     // Port B clock
    .wea(wea),       // Port A write enable
    .web(web),       // Port B write enable
    .ena(ena),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(enb),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .douta(douta),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(doutb)    // Port B RAM output data, width determined from RAM_WIDTH
  );
*/
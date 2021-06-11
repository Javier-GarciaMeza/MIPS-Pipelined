`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:29:28 11/18/2018
// Design Name:   CPU
// Module Name:   C:/Users/javis/OneDrive/Documents/School/CECS 440/Mips_Pipeline/CPU_tb.v
// Project Name:  Mips_Pipeline
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CPU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CPU_tb;

	// Inputs
	reg clk;
	reg rst;


	wire 			intr,intr_ack;
	wire [31:0] EXMEM_ALU,pc4_mux,M_Data,io_out;
	wire [15:0] EXMEM_M;
	// Instantiate the Unit Under Test (UUT)
	/////////////////////////////////////////////
	//Central Processing Unit
	/////////////////////////////////////////////
	CPU uut (
		.clk(clk), 
		.rst(rst),
		.intr_ack(intr_ack),
		.intr(io_intr),
		.EXMEM_ALU(EXMEM_ALU),
		.pc4_mux(pc4_mux),
		.EXMEM_M(EXMEM_M),
		.M_Data(M_Data),
		.io_out(io_out)
	);
	//////////////////////////////////////////////////////
	//Data memory module
	//////////////////////////////////////////////////////
	DataMemory 	uut2 (.clk(clk), 
						 .Address(EXMEM_ALU[11:0]), 
						 .D_In(pc4_mux), 
						 .dm_cs(EXMEM_M[6]), 
						 .dm_wr(EXMEM_M[5]), 
						 .dm_rd(EXMEM_M[4]), 
						 .D_Out(M_Data));
	
	////////////////////////////////////////////////////////
	//IO memory Module
	///////////////////////////////////////////////////////
	IO_Memory uut3 (.clk(clk), 
						.rst(rst), 
						.io_cs(EXMEM_M[9]), 
						.io_wr(EXMEM_M[8]), 
						.io_rd(EXMEM_M[7]), 
						.Address(EXMEM_ALU[11:0]), 
						.D_In(pc4_mux), 
						.D_Out(io_out), 
						.intr_ack(intr_ack), 
						.io_intr(io_intr));
	
	always #5 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;

		// Wait 100 ns for global reset to finish
		
		//$readmemh("iM_01.dat",uut.IU.IM.M);
		//$readmemh("dM_01.dat",uut2.M);
		//$readmemh("dM_02.dat",uut2.M);
		//$readmemh("iM_02.dat",uut.IU.IM.M);
		
		//$readmemh("iM_03.dat",uut.IU.IM.M);
		//$readmemh("dM_03.dat",uut2.M);
		//$readmemh("iM_04.dat",uut.IU.IM.M);
		//$readmemh("dM_04.dat",uut2.M);
		//$readmemh("iM_05.dat",uut.IU.IM.M);
		//$readmemh("dM_05.dat",uut2.M);
		//$readmemh("iM_06.dat",uut.IU.IM.M);
		//$readmemh("dM_06.dat",uut2.M);
		//$readmemh("iM_07.dat",uut.IU.IM.M);
		//$readmemh("dM_07.dat",uut2.M);
		//$readmemh("iM_08.dat",uut.IU.IM.M);
		//$readmemh("dM_08.dat",uut2.M);
		//$readmemh("iM_09.dat",uut.IU.IM.M);
		//$readmemh("dM_09.dat",uut2.M);
		$readmemh("iM_10.dat",uut.IU.IM.M);
		$readmemh("dM_10.dat",uut2.M);
		//$readmemh("iM_11.dat",uut.IU.IM.M);
		//$readmemh("dM_11.dat",uut2.M);
		//$readmemh("iM_12.dat",uut.IU.IM.M);
		//$readmemh("dM_12.dat",uut2.M);
		//$readmemh("iM_13.dat",uut.IU.IM.M);
		//$readmemh("dM_13.dat",uut2.M);
		//$readmemh("iM_14.dat",uut.IU.IM.M);
		//$readmemh("dM_14.dat",uut2.M);
		#10
		
		rst = 0;

	end
      
endmodule


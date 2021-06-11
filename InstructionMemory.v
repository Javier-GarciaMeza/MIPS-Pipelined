`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  InstructionMemory.v
 * Project:    Lab_Assignment_5
 * Designer:   Javier Garcia & Taylor Cochran
 * Email:      javis9526@yahoo.com,TayCochran123@gmail.com 
 * Rev. No.:   Version 1.2
 * Rev. Date:  10-20-18
 *
 * Purpose: 	The instructions that are used in this system are stored here
 *					in a memory register whos size is  [7:0] and depth is[4095].
 ****************************************************************************/
module InstructionMemory(clk,
								 Address, D_In,
								 im_cs,im_wr,im_rd,
								 D_Out);
//----------------------------------------------------------------------------------//		
	input 				clk;
	
	input 	[31:0] 	D_In; // iMem input

	input 	[11:0]  Address;
	input					im_cs,im_wr,im_rd;

	output	[31:0]	D_Out; // iMem output
	
	reg		 [7:0]	M	[4095:0];// memory of width: 8, depth: 4096
	
	wire		[31:0] 	D_Out;
	
	//////////////////////////////////////////////////////////////////////////////
	// Synchronous block that writes to the memory. An instruction takes 32-bits,
	// but since the memory is byte adressible we must access 4-memory location
	// per instruction.
	//////////////////////////////////////////////////////////////////////////////
	always@(posedge clk)
		if(im_wr & im_cs){M[Address],M[Address+1],M[Address+2],M[Address+3]} = D_In;
	
	/////////////////////////////////////////////////////////////
	//Asynchronous block that reads from the memory.
	/////////////////////////////////////////////////////////////
	assign D_Out =(im_rd&im_cs)? {M[Address],M[Address+1],M[Address+2],M[Address+3]}:
											32'bz;
	
endmodule

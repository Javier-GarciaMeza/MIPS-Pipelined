`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:13:56 11/18/2018 
// Design Name: 
// Module Name:    PC_CU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PC_CU(EXMEM_M,Branch_s,Stall,
				  pc_ld, pc_inc, im_cs, im_wr, im_rd);
//----------------------------------------------------------------------------------//
	input [15:0] EXMEM_M; // memory control word
	input 		 Branch_s; // branch signal
	input			 Stall;
	
	output pc_ld,pc_inc; // load,increment
	output im_cs,im_wr,im_rd;// chip select, write, read
	
	////////////////////////////////////////////////////////////////////////
	// The pc load and increment signals are determined by 3 cases:
	// •if entering/leaving the ISR or jumping or branching : load the new PC
	// •if there is a stall signal neither load or increment
	// •otherwise continuasly increment the PC
	////////////////////////////////////////////////////////////////////////
	assign {pc_ld,pc_inc} =(EXMEM_M[15]|EXMEM_M[12]| EXMEM_M[11] | 
														EXMEM_M[10] | Branch_s)? 2'b10:
																			 (Stall)? 2'b00:
																						 2'b01;
	
	// When ever there is a stall stop reading from the instruction memory
	// otherwise continuasly read.
	assign {im_cs,im_wr,im_rd} = (Stall)? 3'b0: 3'b101;
	
	

endmodule

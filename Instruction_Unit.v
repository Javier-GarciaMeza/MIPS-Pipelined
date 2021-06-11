`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  Instruction_Unit.v
 * Project:    Lab_Assignment_5
 * Designer:   Javier Garcia & Taylor Cochran
 * Email:      javis9526@yahoo.com,TayCochran123@gmail.com 
 * Rev. No.:   Version 1.2
 * Rev. Date:  10-20-18
 *
 * Purpose: This module keeps track of the instructions. PC is found here and
 *				updated after every instruction is executed. The instructions are
 *				stored in the instruction memory module.
 ****************************************************************************/
module Instruction_Unit(clk,rst,ISR,LISR,
								PC_in,pc_ld,pc_inc,
								im_cs,im_wr,im_rd,
								Stall,Flush,
								PC_out,
								IFID_IR);
//----------------------------------------------------------------------------------//								
	input 				clk , rst;
	input					ISR; // interrupt sevice routine
	input   	 [2:0]   LISR; // leave interrupt
	input 				pc_ld , pc_inc; // load, increment
	input 	[31:0] 	PC_in; // input
	input 				im_cs , im_wr , im_rd; //chip select, write, read
	input					Stall,Flush;
	
	output reg	[31:0]	PC_out , IFID_IR ; // pc, instruction register
	
	

	wire		[31:0]   D_Out; // instruction memory output
	
	/////////////////////////////////////////////////////////////////////////////
	// The program counter is determines synchronously in order to access a new
	// instruction every clock tick. 
	/////////////////////////////////////////////////////////////////////////////
	always@(posedge clk,posedge rst) begin
		if(rst)  PC = 32'b0;	 else  // reset the program counter
		if(pc_ld)  PC = PC_in;else  // when the load is high load the new pc
		if(ISR|LISR)  PC = PC;else  // if entering/leaving the ISR, stall
		if(pc_inc) PC = PC + 4;else // increment the pc by 4 
					  PC = PC;			 // Stall
	end
	
	// 32-bit wire that carrys the pc value out 
	// of the module.
	assign PC_out = PC;
	
	///////////////////////////////////////////////////////////////////////////
	// This block is the memory that contains all the instructions. Because 
	// the memory is byte addressable the PC is in increments of 4.
	// We never write to this memory, we only read.
	// Note: the address only uses 12-bits because out biggest accesible 
	//       address is 0xFFF.
	///////////////////////////////////////////////////////////////////////////
	InstructionMemory IM (.clk(clk),
								 .Address(PC_out[11:0]), .D_In(32'h0),
								 .im_cs(im_cs),.im_wr(im_wr),.im_rd(im_rd),
								 .D_Out(D_Out));
	
	///////////////////////////////////////////////////////////////////////////
	// Synchronously load the first pipeline stage register that contains the
	// instruction. This instruction will determine all the following pipeline
	// stage control words.
	///////////////////////////////////////////////////////////////////////////
	always@(posedge clk, posedge rst)begin
		if(rst) IFID_IR = 32'b0;else		// reset the instruction register
		if(Flush) IFID_IR = 32'b0;else 	// flush the instruction register
		if(Stall) IFID_IR = IFID_IR;else // stall the instruction register
					 IFID_IR = D_Out;			// load the new instruction
	end

endmodule

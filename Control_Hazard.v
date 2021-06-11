`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:45:09 11/20/2018 
// Design Name: 
// Module Name:    Control_Hazard 
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
module Control_Hazard(IFID_IR,IDEX_TA,IDEX_M,EXMEM_M,
							 Branch_s,
							 Stall,Flush);
//----------------------------------------------------------------------------------//							 
	input [31:0] IFID_IR; // instruction register
	input [4:0] IDEX_TA; // t register address
	input [15:0] IDEX_M, EXMEM_M; // control words
	input			Branch_s; // branch signal
	
	output reg Stall;
	output reg Flush;
	
	///////////////////////////////////////////////////////////
	// This combo logic block determines wether the pipeline
	// needs to be flushed. Flushes usually occur when there
	// is a hazard due to a branch/jump.
	///////////////////////////////////////////////////////////
	always @(*) begin
		// if there is a jump_r,jump,or branch instruction
		// flush the pipeline.
		if(EXMEM_M[11]|EXMEM_M[10]| Branch_s)
			Flush = 1;
		else 
			Flush = 0;end
	
	///////////////////////////////////////////////////////////
	// This combo logic determines wether we need to stall the 
	// pipeline.
	////////////////////////////////////////////////////////////
	always @(*) begin
		Stall = 0;
		// when a load word is detected
		if(IDEX_M[4])
			// if the destination equals the next instructions source
			// then stall.
			if((IFID_IR[25:21] == IDEX_TA))
					Stall = 1;
			else 
			// if the destination equals the next instructions source
			// then stall.
			if(IFID_IR[20:16] == IDEX_TA)
					Stall = 1;
	end
	
	
	
	

endmodule

`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  ALU.v
 * Project:    Lab_Assignment_1
 * Designer:   Javier Garcia
 * Email:      javis9526@yahoo.com
 * Rev. No.:   Version 1.4
 * Rev. Date:  9-12-18
 *
 * Purpose: Wrapper function that contains the 3 modules needed to implement 
 *          an ALU. The 3 modules take care of defining all results from an 
 *				operation as well as the flags for said operations.
 ****************************************************************************/
module ALU_32(	S,T,FS,
				Y_hi,Y_lo,
				C,V,N,Z);
				
	input  [31:0]	S,T;
	input	 [9:0] 	FS;
	output      	N,Z,V,C;
	output [31:0] 	Y_hi,Y_lo;

	wire 			N,Z,V,C; 	//flags
	wire [31:0]	Y_hi,Y_lo;  // outputs
	
	wire [63:0] prod;		//wire for multiplication
	wire [31:0] Q,R,OP_R;	//quotient,remainder,operation_result
	wire [31:0] bsl,bsr,bsa;
	wire [3:0]  sllF,srlF,sraF;
	wire [3:0]  DFLAGS,MFLAGS,FLAGS; // flags for the modules
	
	
	//////////////////////////////////////////////////////
	// Modules that are used to perform the arithmatic
	// functions of the alu.
	//////////////////////////////////////////////////////
	DIV_32	DIVISION 		(S,T,R,Q,DFLAGS);	
	MPY_32 	MULTIPTLI		(S,T,prod,MFLAGS);
	Shift_left 			SLL		(T,FS[9:5],bsl,sllF);
	Shif_right_logic	SRL		(T,FS[9:5],bsr,srlF);
	Shift_right_arithmetic	SRA	(T,FS[9:5],bsa,sraF);
	MIPS_32	MIPS 				(S,T,FS,OP_R,FLAGS);
	
	// mux that assigns the outputs based on the select FS.
	assign {Y_hi,Y_lo,C,V,N,Z} = (FS[4:0] ==5'h1F)? 	{R,Q,DFLAGS}://div
										  (FS[4:0] ==5'h1E)?	{prod,MFLAGS}://mul
										  (FS[4:0] == 5'h0C)?  {32'b0,bsl,sllF}://sll
										  (FS[4:0] == 5'h0D)?  {32'b0,bsr,srlF}://srl
										  (FS[4:0] == 5'h0E)?  {32'b0,bsa,sraF}://sra
																{32'b0,OP_R,FLAGS};//basic alu
	
	
endmodule

`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  MIPS_32.v
 * Project:    Lab_Assignment_1
 * Designer:   Javier Garcia
 * Email:      javis9526@yahoo.com
 * Rev. No.:   Version 1.8
 * Rev. Date:  9-12-18
 *
 * Purpose: Perform the basic operations for the ALU. Here simple arithmatic
 *          functions are performed as well as logic, and shifts. The respective
 *				flags for each function are also set. 
 * Notes: All operations here are signed except for ADDU,SUBU STLU.
 *
 ****************************************************************************/
module MIPS_32( S,T,FS,
					 Y_lo,
					 {C,V,N,Z});
					 
   input  [31:0]	S,T;
	input	 [9:0] 	FS;
	output      	N,Z,V,C;
	output [31:0] 	Y_lo;

	reg 			N,Z,V,C;
	reg [31:0]	Y_lo;
	
	integer ts,tt;
	
 
	
	always @(S,T,FS) begin
		{N,Z,V,C} = 4'b0; 
		{ts,tt} = {S,T};
		casex(FS[4:0])
			5'h00: begin//**********************Pass S*******************************
						Y_lo = S; C = 1'bx;	 	N = Y_lo[31];  	V = 1'bx; 	
					 end 
			5'h01: begin //**********************Pass T******************************
						Y_lo =T; C = 1'bx; 	 	N = Y_lo[31];  	V =1'bx; 
					 end 
			5'h02: begin//***************************ADD***************************** 
						{C,Y_lo} = S+T;	N = Y_lo[31];		V = (S[31] == Y_lo[31])?0:1;
					 end
			5'h03: begin //*************************SUB******************************
						{C,Y_lo} = S-T;	N = Y_lo[31];		V = (S[31] == Y_lo[31])?0:1;
					 end 
			5'h04: begin //***********************ADDU*******************************
						{C,Y_lo} = S+T;	N = 0;				V = (S[31] == Y_lo[31])?0:1;
					 end 
			5'h05: begin //***********************SUBU*******************************
						{C,Y_lo} = S-T;	N = 0;				V = (S[31] == Y_lo[31])?0:1;
					 end 
			5'h06: begin //***********************SLT********************************
						Y_lo = (ts<tt)? 1: 0; C = 1'bx;		N = Y_lo[31];		V = 1'bx;
					 end 
			5'h07: begin //**********************SLTU********************************
						Y_lo = (S<T)? 1:0; C = 1'bx;			N = 0;				V =1'bx ;
					 end 
			5'h08: begin //***********************AND********************************
						Y_lo = S&T; C = 1'bx;		N = Y_lo[31];		V = 1'bx;
					 end 
			5'h09: begin //************************OR********************************
						Y_lo = S|T;	C = 1'bx;	N = Y_lo[31];		V = 1'bx;
					 end 
			5'h0A: begin //***********************XOR********************************
						Y_lo = S^T;	C = 1'bx;	N = Y_lo[31];		V =1'bx ;
					 end 
			5'h0B: begin //***********************NOR********************************
						Y_lo= ~(S | T);C = 1'bx;	N = Y_lo[31];		V = 1'bx;
					 end 
			5'h0F: begin //***********************INC********************************
						{C,Y_lo} = S + 1;		N = Y_lo[31];	V = (S[31] == Y_lo[31])?0:1;
					 end 
			5'h10: begin //***********************DEC********************************
						{C,Y_lo} = S-1;		N = Y_lo[31];	V = (S[31] == Y_lo[31])?0:1;
					 end 
			5'h11: begin //***********************INC4*******************************
						{C,Y_lo} = S+4;		N = Y_lo[31];	V = (S[31] == Y_lo[31])?0:1;
					 end 
			5'h12: begin //***********************DEC4*******************************
						{C,Y_lo} = S-4;		N = Y_lo[31];	V = (S[31] == Y_lo[31])?0:1;
					 end 
			5'h13: begin //**********************ZEROS*******************************
						Y_lo = 32'h0;	C = 1'bx;	N = Y_lo[31];	V =1'bx ;
					 end 
			5'h14: begin //***********************ONES*******************************
						Y_lo = 32'hFFFFFFFF;		C = 1'bx;	N = Y_lo[31];	V =1'bx ;
					 end
			5'h15: begin //*********************SP_INIT******************************
						Y_lo = 32'h3FC;			C = 1'bx;		N = Y_lo[31];	V = 1'bx;
					 end 
			5'h16: begin //***********************ANDI*******************************
						Y_lo = S&{16'h0,T[15:0]};C = 1'bx;	N = Y_lo[31];	V = 1'bx;
					 end 
			5'h17: begin //************************ORI*******************************
						Y_lo = S|{16'h0,T[15:0]};	C = 1'bx;N = Y_lo[31];	V = 1'bx;
					 end 
			5'h18: begin //************************LUI*******************************
						Y_lo ={T[15:0],16'h0};	C = 1'bx; N = Y_lo[31];	V = 1'bx;
					 end 
			5'h19: begin //***********************XORI*******************************
						Y_lo = S^{16'h0,T[15:0]};	C = 1'bx;N = Y_lo[31];	V = 1'bx;
					 end 
						
			default:begin //*********************Default*****************************
						Y_lo = Y_lo;		 C=C; 			N = Y_lo[31]; 			V = V;
					 end
		endcase
		// and the output with zero and store flag
		Z = !(32'hFFFFFFFF & Y_lo);
	end

endmodule

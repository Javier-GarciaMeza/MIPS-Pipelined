`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  DIV_32.v
 * Project:    Lab_Assignment_1
 * Designer:   Javier Garcia
 * Email:      javis9526@yahoo.com
 * Rev. No.:   Version 1.6
 * Rev. Date:  9-29-18
 *
 * Purpose: Divide the S operand by T and then store the quotient in Y_hi 
 *          and the remainder in Y_lo.
 *
 ****************************************************************************/
module DIV_32(	S,T,
					R,Q,
					{C,V,N,Z});
					
		input [31:0] S,T;
		
		output reg [31:0] Q,R; // quotient, remainder
		
		output reg N,V,Z,C; // flags
		
		integer si,ti; // temporary integer
		
		always @(*)begin
		    si = S; // pass s to temp integer
			 ti = T; // pass t to temp integer
			 Q = si/ti; // divide s by t; Q is quotient R is the remainder
			 R = si%ti; // r gets s mod t
			 N = Q[31];	//negativ flag
			 V = 1'bx;	//overlow not affected
			 C = 1'bx;	//carry not affected
			 Z = !(32'hFFFFFFFF & Q);	// check for zero
		end

endmodule

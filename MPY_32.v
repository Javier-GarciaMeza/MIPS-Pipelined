`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  MPY_32.v
 * Project:    Lab_Assignment_1
 * Designer:   Javier Garcia
 * Email:      javis9526@yahoo.com
 * Rev. No.:   Version 1.5
 * Rev. Date:  9-30-18
 *
 * Purpose: Multiply the 32-bit operands S and T and store the 64-bit result
 *          in {Y_hi,Y_lo}.
 ****************************************************************************/
module MPY_32(	S,T,
					{Y_Hi,Y_Lo},
					{C,V,N,Z});
		
		input [31:0] S,T;
		
		output reg [31:0] Y_Hi,Y_Lo;
		
		output reg 		N,V,Z,C;
		
		integer si,ti; // temporary integers 
		
		always @(*) begin
			si = S; //pass s to temp integer
			ti = T; // pass t to temp integer
			{Y_Hi,Y_Lo} = si*ti; // store product of S&T 
			N = 0; // set negative flag
			V = 1'bx;	// overflow not affected
			C = 1'bx;	//carry not affected
			Z = !(32'hFFFFFFFF & {Y_Hi,Y_Lo}); // find zero flag
		end
endmodule

`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  regfile32.v
 * Project:    Lab_Assignment_5
 * Designer:   Javier Garcia, Taylor Cochran
 * Email:      javis9526@yahoo.com,TayCochran123@gmail.com 
 * Rev. No.:   Version 1.7
 * Rev. Date:  10-22-2018
 *
 * Purpose: This module contains the memory registers that hold the operands 
 *          for the integer datapath. Results from the ALU are also written
 *				back into these registers.
 *
 * Notes: reg32 is a 32x32 bit matrix, that containts 32 registers all of 
 *			 which are 32-bits wide. Register 0 will always contain 0.
 ****************************************************************************/
module regfile32(	clk, rst, D, 
						S_Addr, T_Addr,
						D_En, D_Addr,
						S,T);
						
	input 			 	clk, rst, D_En;
	input 	[31:0] 	D; // Data In
	input 	[4:0] 	S_Addr, T_Addr, D_Addr;
	output	[31:0]	S , T;
	wire 		[31:0] 	S, T;

	reg [31:0] reg32 [31:0]; // register file
	/////////////////////////////////////////////////////
	//WRITE the incoming bits to the designated register.
	/////////////////////////////////////////////////////
	
	always @ (posedge clk, posedge rst) begin
			if(rst)
				reg32[0] = 32'b0;
			else if(D_En) 
					if(D_Addr!=0) reg32[D_Addr]= D ;

 
			
	end
	
	//////////////////////////////////////////////////////
	//READ the contents of a register based on an address.
	// Writing to the source register causes a forward in
	// data.
	//////////////////////////////////////////////////////
	
	assign S = (D_En &(D_Addr == S_Addr))? D: reg32[S_Addr];
	
	assign T = (D_En &(D_Addr == T_Addr))? D: reg32[T_Addr];
	
	 
	

endmodule

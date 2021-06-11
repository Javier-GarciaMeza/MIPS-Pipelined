`timescale 1ns / 1ps
/************************************************************************************
* Designer:   Javier Garcia & Taylor Cochran
* Email:      javis9526@yahoo.com,TayCochran123@gmail.com
* Filename: Data_Memory.v
* Date:     October 18, 2018
* Version:  1.1
*
* Notes: The Data Memory of the MIPS Processor has the ability to write synchronously
*        with the clock.  Reading is Asynchronous. A 'Chip Select' must be asserted to
*        either READ or WRITE, along with the 'Read' and 'Write' controls.  
*
*                                                                  (End of Page Width)
*************************************************************************************/
module DataMemory(clk,
						Address, D_In,
						dm_cs,dm_wr,dm_rd,
						D_Out);
	
	input 				clk;
	input 	[31:0] 	D_In;
	input 	[11:0]  Address;
	input					dm_cs,dm_wr,dm_rd;

	output	[31:0]	D_Out;
	
	reg		 [7:0]	M	[4095:0];// memory of width: 8, depth: 4096
	

	////////////////////////////////////////////////
	//Synchronous block that writes to the memory
	////////////////////////////////////////////////
	always@(posedge clk)
		if(dm_wr & dm_cs) {M[Address],M[Address+1],M[Address+2],M[Address+3]} = D_In;
	
	////////////////////////////////////////////////
	//Asynchronous block that reads from the memory
	////////////////////////////////////////////////
	assign D_Out =(dm_rd&dm_cs)? {M[Address],M[Address+1],M[Address+2],M[Address+3]}:
											32'bz;
	
endmodule

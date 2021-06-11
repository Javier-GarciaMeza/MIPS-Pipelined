`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:50 11/15/2018 
// Design Name: 
// Module Name:    PipeLine_Stage_5 
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
module PipeLine_Stage_5(clk,rst,MEMWB_WB,MEMWB_MData,MEMWB_IO,
								MEMWB_ALU,MEMWB_Waddr,WB_Data,WB_Addr,WB_D_EN);
								
		input clk,rst;
		 
		input  [3:0]	MEMWB_WB;
		input [31:0]	MEMWB_MData,MEMWB_IO,MEMWB_ALU;
		input  [4:0]	MEMWB_Waddr;
		
		output wire [31:0] WB_Data;//Write Back Data
		output wire	[4:0] WB_Addr;//Write Back Address
		output wire 		WB_D_EN; // Write Back Data Enable
		
		//////////////////////////////////////////////////////////
		// When the Break flag is detected terminate the program.
		//////////////////////////////////////////////////////////
		always@(*) 
			if(MEMWB_WB[3]) $finish;
			
								//pass the data from IO
		assign WB_Data = (MEMWB_WB[2:1] == 2'b10)? MEMWB_IO:
							  // pass the data from memory module
							  (MEMWB_WB[2:1] == 2'b01)? MEMWB_MData : 
																MEMWB_ALU ; // pass ALU
		
		assign WB_Addr = MEMWB_Waddr; // write back address
		
		assign WB_D_EN = MEMWB_WB[0]; // Write Data Enable
		
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:07:07 11/19/2018 
// Design Name: 
// Module Name:    Fowarding 
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
module Fowarding(IDEX_SA,IDEX_TA,
						EXMEM_WB,EXMEM_Waddr,
						MEMWB_WB,MEMWB_Waddr,S_sel,T_sel);
	input [4:0] IDEX_SA,IDEX_TA;
	input 		EXMEM_WB,MEMWB_WB;	

	input	[4:0] EXMEM_Waddr,MEMWB_Waddr;
	
	output reg [1:0] S_sel, T_sel;
	
	////////////////////////////////////////////////////////////////////////////////
	// The combo block represents the forwarding logic. Note that this only 
	// handles data dependencies that are not latches. Those are handled by the 
	// register file itself.
	//////////////////////////////////////////////////////////////////////////////
	always @(*) begin
		// if source S matches destination from EXMEM and Write Enable
		if((IDEX_SA == EXMEM_Waddr)& EXMEM_WB)
			 S_sel = 2'b01; // forward the data from EXMEM
		else
		//  if source S matches destination from EXMEM and Write Enable
		if((IDEX_SA == MEMWB_Waddr) & MEMWB_WB)
				S_sel = 2'b10;// forward the data from MEMWB
		else 
			S_sel = 0; // dont forward any data
		////////////////////////////////////////////////////////////////////	
		// if source T matches destination from EXMEM and Write Enable
		if((IDEX_TA == EXMEM_Waddr)&EXMEM_WB)
			T_sel = 2'b01;// forward the data from EXMEM
	
		else
		//  if source T matches destination from EXMEM and Write Enable
		if((IDEX_TA == MEMWB_Waddr)&MEMWB_WB)
			 T_sel = 2'b10;// forward the data from MEMWB
		else 
			T_sel = 0;// dont forward any data
		
	end
		

endmodule

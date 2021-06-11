`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:36 11/15/2018 
// Design Name: 
// Module Name:    PipeLine_Stage_4 
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
module PipeLine_Stage_4(clk,rst,IE,IDEX_PC,
								EXMEM_M,EXMEM_WB,
								EXMEM_Baddr,EXMEM_Jaddr,
								EXMEM_FLAGS,
								EXMEM_ALU, EXMEM_MData,EXMEM_Waddr,M_Data,io_out,
								MEMWB_WB,
								MEMWB_MData,MEMWB_IO,MEMWB_ALU,MEMWB_Waddr,PC_out,
								Branch_s,pc4_mux);
								
		input clk,rst,IE;
		input	[31:0] IDEX_PC;
		input  [15:0]	EXMEM_M;
		input	 [3:0]	EXMEM_WB;
		input	[31:0]	EXMEM_Baddr,EXMEM_Jaddr;
		input	 [3:0]	EXMEM_FLAGS;
		input	[4:0]		EXMEM_Waddr;
		input [31:0]	EXMEM_ALU,EXMEM_MData,M_Data,io_out;
		
		
		output reg  [3:0]	MEMWB_WB;
		output reg [31:0]	MEMWB_MData,MEMWB_ALU,MEMWB_IO;
		output reg  [4:0]	MEMWB_Waddr;
		output 	  [31:0] PC_out,pc4_mux;
		output 	         Branch_s;
		
		reg	[4:0]   t_Flags;
		wire [31:0]		flag_mux,pc4_mux;
		wire [31:0]   PC_out,b_mux,j_mux;
		wire 				Branch_s;
		
		////////////////////////////////////////////////////////////////////////////
		// Branch logic that raises a branch signal whenver a branch is to occur.
		// This signal notifies the pc_cu that it needs to load the new PC address.
		////////////////////////////////////////////////////////////////////////////
									//Branch Equal flag and zero flag are high
		assign Branch_s = 	(EXMEM_M[0] & EXMEM_FLAGS[0] )? 1'b1: //branch
									//Branch Not Equal Falg and Not zerro flag
									(EXMEM_M[1] & ~EXMEM_FLAGS[0])? 1'b1: // branch
									//B Less/equal zero flag and the or of zero, negative
									(EXMEM_M[2] & (EXMEM_FLAGS[1] | EXMEM_FLAGS[0]))? 1'b1:
									//B greater than zero flag and not negative not zero
									(EXMEM_M[3] & ~EXMEM_FLAGS[1] & ~EXMEM_FLAGS[0])? 1'b1:
																				0;//dont branch
		
		
		//syncronous register that takes in the interupt enable flag and the alu flags
		always @(posedge clk, posedge rst)begin
			if(rst) t_Flags = 5'b0;else
					  t_Flags = {IE,EXMEM_FLAGS};
		end
		
		// when flags select pass the flass, else pass the register data
		assign flag_mux = (EXMEM_M[13])? t_Flags:EXMEM_MData;
		// when storing pc pass the pc else pass the above result 
		assign pc4_mux = (EXMEM_M[14])? IDEX_PC: flag_mux;
		
		////////////////////////////////////////////////////////////////////////////
		// The below muxes take care of passing the correct pc to stage 1.
		// These values are based on the jump and branch instructions.
		//////////////////////////////////////////////////////////////////////////////
		
		// when a branch signal pass the branch addr. else pas the jump reg(ALU)
		assign b_mux  = (Branch_s)? EXMEM_Baddr: EXMEM_ALU;
		// when the jump flag is high pass the jump addr. else pass above result
		assign j_mux = (EXMEM_M[10])? EXMEM_Jaddr:b_mux;
		// when entering/leaving ISR get the PC from the stack else from above result
		assign PC_out = (EXMEM_M[15] | EXMEM_M[12])? M_Data:j_mux;
		
	
		
		/////////////////////////////////////////////////////////////////
		// Pipeline Registers are synchronously loaded.
		//////////////////////////////////////////////////////////////////
		always @(posedge clk,posedge rst)begin
			if(rst)begin
				MEMWB_WB =4'b0;
				MEMWB_MData = 32'b0;
				MEMWB_IO= 32'b0;
				MEMWB_ALU = 32'b0;
				MEMWB_Waddr = 5'b0;
			end
			else begin
				MEMWB_WB = EXMEM_WB;		//Write Back control
				MEMWB_MData = M_Data;	// Memory module output
				MEMWB_IO = io_out;		// IO module output
				MEMWB_ALU = EXMEM_ALU;	// ALU output
				MEMWB_Waddr = EXMEM_Waddr;// Write Address
			end
		end
endmodule

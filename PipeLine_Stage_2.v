`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:19 11/15/2018 
// Design Name: 
// Module Name:    PipeLine_Stage_2 
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
module PipeLine_Stage_2(clk,rst,IFID_IR,PC,ISR,LISR,
								WB_Data,WB_Addr,WB_D_EN,
								Flush,Stall,EX,M,WB,
								IDEX_EX,IDEX_M,IDEX_WB,
								IDEX_SA,IDEX_TA,IDEX_DA,
								IDEX_SE,IDEX_PC,IDEX_S,IDEX_T,IDEX_JA);
//----------------------------------------------------------------------------------//	
		//////////////////////////////////////////////////////////
		// Inputs 
		//////////////////////////////////////////////////////////
		input 			clk,rst,Flush,Stall;
		input  [2:0] 	LISR; // Leave Interrupt Sevice Routine
		input 			ISR;  // Interrupt Service Routine
		input [31:0] 	IFID_IR,PC,WB_Data;
		input  [4:0]	WB_Addr; // Write Back Address
		input				WB_D_EN; // Write Back Data Enable
		
		input	[15:0]	EX;	// Execute control word
		input	[15:0]	M ;	// Memory Control Word
		input	 [3:0]	WB;	// Write Back Contro Word
		///////////////////////////////////////////////////////////
		// Outputs for the IDEX pipeline stage
		///////////////////////////////////////////////////////////
		output reg 	[15:0] 	IDEX_EX; // Execute Control Word
		output reg	[15:0]	IDEX_M ; // Memory Control Word
		output reg	 [3:0]	IDEX_WB; // Write Back Control Word
							//signExtend,   PC,    S,      T,   Jump Address
		output reg  [31:0] 	IDEX_SE,IDEX_PC,IDEX_S,IDEX_T,IDEX_JA;
		output reg	 [4:0] 	IDEX_SA, IDEX_TA,IDEX_DA;
								 // Saddr , Tadd ,  Daddr
		
	
		//mux for the source address
		wire [4:0]  Saddr_mux;
		
		// wires for the register file outputs
		wire [31:0] S, T;
		
		/////////////////////////////////////////////////////////////////
		// 						REGISTER FILE
		// Internal memory that the Datapath uses to access operands.
		//////////////////////////////////////////////////////////////////
		
		// When Entering/Leaving the ISR use the stack pointer register
		// as the source register, else use the S source register.
		assign Saddr_mux = (ISR | LISR)? 5'd29: IFID_IR[25:21];
		
		// 32 32-bit registers that are used as the sources and destination
		// for most of the instructions.
		regfile32 	RF	(.clk(clk), .rst(rst), .D(WB_Data), 
							 .S_Addr(Saddr_mux), .T_Addr(IFID_IR[20:16]),
							 .D_En(WB_D_EN), .D_Addr(WB_Addr),
							 .S(S),.T(T));
		
		/////////////////////////////////////////////////////////////////
		// Pipeline Registers are synchronously loaded.
		//////////////////////////////////////////////////////////////////		
		always @ ( posedge clk, posedge rst) begin
			if(rst)begin 					// upon reset reset all the registers
					IDEX_EX = EX;			// except the control words, because they
					IDEX_M  = M;			// intialize the stack pointer on reset.
					IDEX_WB = WB;			
					IDEX_SA = 5'b0;
					IDEX_TA = 5'b0;
					IDEX_DA = 5'b0;
					IDEX_SE = 32'b0;
					IDEX_PC = 32'b0;
					IDEX_S  = 32'b0;
					IDEX_T  = 32'b0;
					IDEX_JA = 32'b0;end
			// When flushing, clear all the registers completetly.		
			else if(Flush | Stall) begin
					IDEX_EX = 17'b0;
					IDEX_M  = 12'b0;
					IDEX_WB = 4'b0;
					IDEX_SA = 5'b0;
					IDEX_TA = 5'b0;
					IDEX_DA = 5'b0;
					IDEX_SE = 32'b0;
					IDEX_PC = 32'b0;
					IDEX_S  = 32'b0;
					IDEX_T  = 32'b0;
					IDEX_JA = 32'b0;
			end
			else begin
					IDEX_EX = EX;	// Execute Control
					IDEX_M  = M;   // Memory Control
					IDEX_WB = WB;  // Write Back Control
					IDEX_SA = Saddr_mux; // Source addres
					IDEX_TA = IFID_IR[20:16]; // T Address
					IDEX_DA = IFID_IR[15:11]; // D Address
					IDEX_SE = {{16{IFID_IR[15]}},IFID_IR[15:0]}; // sign extend 16
					IDEX_PC = (ISR)? PC-8:PC; 	// ISR clears 2 inst. so pc-8, else pc
					IDEX_S  = S;				// S register
					IDEX_T  = T;				// T register
					IDEX_JA = {PC[31:28],IFID_IR[25:0],2'b00}; // jump address
			end 
		end
endmodule

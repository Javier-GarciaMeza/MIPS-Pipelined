`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:27 11/15/2018 
// Design Name: 
// Module Name:    PipeLine_Stage_3 
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
module PipeLine_Stage_3(clk, rst,Flush,IDEX_EX,IDEX_M,IDEX_WB,
								IDEX_SA,IDEX_TA,IDEX_DA,
								IDEX_SE,IDEX_PC,IDEX_S,IDEX_T,IDEX_JA,
								M_Data,
								MEMWB_WB, 
								WB_Data, 
								MEMWB_Waddr,
								EXMEM_M,EXMEM_WB,
								EXMEM_Baddr,EXMEM_Jaddr,
								EXMEM_FLAGS,
								EXMEM_ALU,EXMEM_MData,EXMEM_Waddr);
								
		input clk, rst,Flush;
		input	[15:0] IDEX_EX;
		input	[15:0]	IDEX_M ;
		input	[3:0]	IDEX_WB;
		input			MEMWB_WB; 
		input [31:0] WB_Data,M_Data; 
		input	[4:0]	 MEMWB_Waddr;
		input [31:0] IDEX_SE,IDEX_PC,IDEX_S,IDEX_T,IDEX_JA;
		input	 [4:0] IDEX_SA,IDEX_TA,IDEX_DA;
	 
		output reg 	[15:0]	EXMEM_M;
		output reg	[3:0]	EXMEM_WB;
		output reg [31:0]	EXMEM_Baddr,EXMEM_Jaddr;
		output reg	[3:0] EXMEM_FLAGS;
		output reg [31:0]	EXMEM_ALU,EXMEM_MData;
		output reg [4:0]	EXMEM_Waddr;
		
		
		reg	[31:0] HI,LO;
		
		
		wire [31:0] B_addr,Y_hi,Y_lo,ALU_OUT;
		
		wire [31:0] For_s, For_t;
		
		wire [31:0] T_Mux;
		
		wire [4:0] W_Addr;
		
		wire [1:0] S_sel,T_sel;
		
		wire 	C,N,V,Z;
		
		//////////////////////////////////////////////////////////////
		// Forwarding Unit
		// Handles any dependencies when executing instructions, by 
		// forwarding the appropriate data.
		//////////////////////////////////////////////////////////////
		Fowarding FU (
			.IDEX_SA(IDEX_SA), //S address
			.IDEX_TA(IDEX_TA), //T address
			.EXMEM_WB(EXMEM_WB[0]),  //Write Back Enable
			.EXMEM_Waddr(EXMEM_Waddr), //Write Back Address
			.MEMWB_WB(MEMWB_WB),      //Write back control
			.MEMWB_Waddr(MEMWB_Waddr),//Write back address 
			.S_sel(S_sel),  //Select the s forward
			.T_sel(T_sel));   // select the t forward
		
		
		////////////////////////////////////////////////////////////////
		//        For_s & For_t
		// mux that forwards the appropriate data based on the results 
		// of the forwading unit.
		////////////////////////////////////////////////////////////////
		assign For_s = (S_sel == 1)? EXMEM_ALU://forward alu result
							(S_sel == 2)? WB_Data: // forward write back 
												IDEX_S; // dont forward
												
		assign For_t = (T_sel == 1)? EXMEM_ALU: //forward alu result
							(T_sel == 2)? WB_Data: // forward write back
												IDEX_T; // dont forward
												
		/////////////////////////////////////////////////////////////////
		//								T MUX
		// Mux decides if the opernad comes from the register files
		// or the external memory.
		/////////////////////////////////////////////////////////////////					 
		
	   assign T_Mux =(IDEX_EX[14])? IDEX_SE : For_t;
		
		/////////////////////////////////////////////////////////////////
		//									W_Addr
		// Selects the write back address based on the control word for 
		// the execute stage.
		/////////////////////////////////////////////////////////////////
		assign W_Addr = (IDEX_EX[13:12] == 0)? IDEX_DA:
							 (IDEX_EX[13:12] == 1)? IDEX_TA:
							 (IDEX_EX[13:12] == 2)? 5'd31:
							 (IDEX_EX[13:12] == 3)? 5'd29:
														IDEX_DA;
													
		
		/////////////////////////////////////////////////////////////////
		//						ARITHMETIC LOGIC UNIT
		// Logic unit that process all the basic arithmatic functions.
		//
		////////////////////////////////////////////////////////////////
		
		ALU_32 	ALU  	(.S(For_s),.T(T_Mux),.FS(IDEX_EX[9:0]),
							 .Y_hi(Y_hi),.Y_lo(Y_lo),
							 .C(C),.V(V),.N(N),.Z(Z));
		
		/////////////////////////////////////////////////////////////////
		//							HILO REGISTERS
		// Temporary registers that are only used to hold the outcomes
		// of the division and multiplication functions.
		//////////////////////////////////////////////////////////////////
		
		always @(posedge clk, posedge rst) begin
			if(rst) 		{HI,LO} = 64'b0;else
			if(IDEX_EX[15])	{HI,LO} = {Y_hi,Y_lo};
		end
		
		
		/////////////////////////////////////////////////////////////////
		//									Y MUX
		// This mux decides what will be output from the ALU.
		//
		//////////////////////////////////////////////////////////////////
		
		assign ALU_OUT = 	(IDEX_EX[11:10] == 2'd0)?	Y_lo:
								(IDEX_EX[11:10] == 2'd1)?	LO:
								(IDEX_EX[11:10] == 2'd2)? HI:
								(IDEX_EX[11:10] == 2'd3)?	IDEX_PC:
														      Y_lo;
														
		assign B_addr = IDEX_PC + {IDEX_SE[29:0],2'b0};										
		/////////////////////////////////////////////////////////////////
		// Pipeline Registers are synchronously loaded.
		//////////////////////////////////////////////////////////////////
		
		always @(posedge clk, posedge rst) begin
			// upon reset completely clear the all the pipeline registers.
			if (rst)begin 
				EXMEM_M = 13'b0;
				EXMEM_WB = 4'b0;
				EXMEM_Baddr = 32'b0;
				EXMEM_Jaddr = 32'b0;
				EXMEM_FLAGS = 4'b0;
				EXMEM_ALU = 32'b0;
				EXMEM_MData = 32'b0;
				EXMEM_Waddr  = 32'b0; end
			else 
			// upon flush, clear all the pipeline registes.
			if(Flush) begin
				EXMEM_M = 13'b0;
				EXMEM_WB = 4'b0;
				EXMEM_Baddr = 32'b0;
				EXMEM_Jaddr = 32'b0;
				EXMEM_FLAGS = 4'b0;
				EXMEM_ALU = 32'b0;
				EXMEM_MData = 32'b0;
				EXMEM_Waddr  = 32'b0;
			end
			//synchronously update the pipelien registers
			else begin
				EXMEM_M = IDEX_M; // Memory Control
				EXMEM_WB = IDEX_WB; // Write Back Control
				EXMEM_Baddr = B_addr; // Branch Address
				EXMEM_Jaddr = IDEX_JA ; // Jump Addrss
				// when popping get flags from memory otherwise get from alu
				EXMEM_FLAGS = ((EXMEM_ALU == 31'h400) & EXMEM_M[4])? M_Data[3:0]:{C,V,N,Z};
				EXMEM_ALU = ALU_OUT; // ALU Output
				EXMEM_MData = For_t; // T data from the mux
				EXMEM_Waddr  = W_Addr; // Write Address
			end
		
		end

endmodule

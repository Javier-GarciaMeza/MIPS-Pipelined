`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:23:06 11/16/2018 
// Design Name: 
// Module Name:    DataPath 
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
module DataPath(clk,rst,IE,ISR,LISR,
					 EX,M,WB,Flush,Stall,
					 IFID_IR,PC_out, M_Data,io_out,IDEX_TA,IDEX_M,
					 EXMEM_M,pc4_mux, EXMEM_ALU,PC_in,Branch_s);
	
	input clk,rst,IE,ISR;// clock, reset, interrrupt enable, interr. servie routine
	input [2:0] LISR; // leave interrupt service
	input	[15:0] EX; // execute control words
	input	[15:0]	M ; // memory control words
	input	[3:0]	WB; // write back control words
//----------------------------------------------------------------------------------//	
	input 		Flush,Stall;
	
	input 	[31:0] IFID_IR,PC_out,M_Data,io_out;//instruction,pc, memory, io
	
	output 	 [4:0] IDEX_TA;// t register address
	
	output	[15:0] IDEX_M,EXMEM_M;// memory control words
	
	output 	[31:0] pc4_mux, EXMEM_ALU,PC_in;//data to memory, alu, pc
	
	output			Branch_s; //branch signal
	
	wire 	[31:0]	 PC_in, IFID_IR ;	//pc , instruction register
	
	wire 	[15:0] IDEX_EX;
	wire	[15:0] IDEX_M ;
	wire	[3:0]	 IDEX_WB;	
	wire  [31:0] IDEX_SE,IDEX_PC,IDEX_S,IDEX_T,IDEX_JA;
	wire	 [4:0] IDEX_SA,IDEX_TA,IDEX_DA;
	
	wire	[15:0]	EXMEM_M;
	wire	 [3:0]	EXMEM_WB;
	wire  [31:0]	EXMEM_Baddr,EXMEM_Jaddr;
	wire	 [3:0] EXMEM_FLAGS;
	wire  [31:0]	EXMEM_ALU,EXMEM_MData;
	wire   [4:0] EXMEM_Waddr;
	
	wire   [3:0]	MEMWB_WB;
	wire	[31:0]	MEMWB_MData,MEMWB_IO,MEMWB_ALU;
	wire   [4:0]	MEMWB_Waddr;
	
	wire 	[31:0] WB_Data;
	wire	 [4:0] WB_Addr;
	wire 			WB_D_EN;
	
	
	//////////////////////////////////////////////////////////////////////////
	// Note: many of the wires have an index at the beginning of their 		//
	//			name to signify their origin.	Their origin being the pipeline	//
	//			stage registers that they come from.									//
	//																								//
	//	• IFID  : Instruction Fetch/ Instruction Decode registers				//
	//	• IDEX  : Instruction Decode/ Execution registers 							//
	// • EXMEM : Execution/ Memory registers											//
	//	• MEMWB : Memory/ Write Back registers 										//
	//////////////////////////////////////////////////////////////////////////
	
	///////////////////////////////////////////////////////////////////////////////////
	// Stage 2 of Pipepline is the Decode stage where the instruction is read and 
	// the pertaining control words are set. This stage also houses the register files
	// containing the source/destination registers. 
	///////////////////////////////////////////////////////////////////////////////////
	PipeLine_Stage_2	PS2	(.clk(clk),.rst(rst),// clock and reset
									.IFID_IR(IFID_IR),	// Instruction Register
									.PC(PC_out),			// Program Counter
									.ISR(ISR),				// Interupt Service Routine
									.LISR(LISR),			// Leave Interrupt Service Routine
									.WB_Data(WB_Data),	// Write Back Data
									.WB_Addr(WB_Addr),	// Write Back Address
									.WB_D_EN(WB_D_EN),	// Write Back Enable
									.Flush(Flush),			// Flush
									.Stall(Stall),			// Stall
									.EX(EX),					// Execute Control Word
									.M(M),					// Memory Control Word
									.WB(WB),					// Write Back Control Word
									.IDEX_EX(IDEX_EX),	// Execute Control Word
									.IDEX_M(IDEX_M),		// Memory Control Word
									.IDEX_WB(IDEX_WB),	// Write Back Control Word
									.IDEX_SA(IDEX_SA),	// Source Register S Address
									.IDEX_TA(IDEX_TA),	// Source/Dest. Register T Address
									.IDEX_DA(IDEX_DA),	// Destination Register D Address
									.IDEX_SE(IDEX_SE),	// Sign Extended 16
									.IDEX_PC(IDEX_PC),	// Program counter 
									.IDEX_S(IDEX_S),		//	Source S contents
									.IDEX_T(IDEX_T),		// Source T contents
									.IDEX_JA(IDEX_JA));	// Jump Address
									
	///////////////////////////////////////////////////////////////////////////////////
	// Stage 3 of the pipeline is the execution stage. After decodeing and setting the
	// approriate key words the alu will perform the appropriate operations. 
	// This stage also houses the forwarding unit that handles any data dependencies.
	///////////////////////////////////////////////////////////////////////////////////								
	PipeLine_Stage_3	PS3	(.clk(clk), .rst(rst),		 // clock and reset
									.Flush(Flush),					 // Flush
									.IDEX_EX(IDEX_EX), 			 // Execute Control Word
									.IDEX_M(IDEX_M), 				 // Memory Control Words
									.IDEX_WB(IDEX_WB), 			 // Write Back Control Words
									.IDEX_SA(IDEX_SA),			 // Source S Address
									.IDEX_TA(IDEX_TA),			 // Source/Dest. T Address
									.IDEX_DA(IDEX_DA), 			 // Destination D Address
									.IDEX_SE(IDEX_SE), 			 // Sign Extended 16
									.IDEX_PC(IDEX_PC), 			 // Program Counter
									.IDEX_S(IDEX_S), 				 // Source S Contents
									.IDEX_T(IDEX_T), 				 // Source T Contents
									.IDEX_JA(IDEX_JA),			 // Jump Address
									.M_Data(M_Data),				 // Memory Data
									.MEMWB_WB(MEMWB_WB[0]),     // Write Back Data Enable
									.WB_Data(WB_Data), 			 // Write Back Data
									.MEMWB_Waddr(MEMWB_Waddr),	 // Write Back Address								
									.EXMEM_M(EXMEM_M),			 // Memory Control Words
									.EXMEM_WB(EXMEM_WB),			 // Write Back Control Words
									.EXMEM_Baddr(EXMEM_Baddr),	 // Branch Address
									.EXMEM_Jaddr(EXMEM_Jaddr),  // Jump Address
									.EXMEM_FLAGS(EXMEM_FLAGS),  // ALU Flags
									.EXMEM_ALU(EXMEM_ALU), 		 // ALU output
									.EXMEM_MData(EXMEM_MData),  // Memory Data
									.EXMEM_Waddr(EXMEM_Waddr)); // Write Back Adress
									
	///////////////////////////////////////////////////////////////////////////////////
	// Stage 4 of the pipeline is the memory stage. This stage will access both the 
	// memory and the IO. However they are not located in here the wires for the modules
	// are passed out to the cpu. This State also handles the branch and jump
	// instructions.
	///////////////////////////////////////////////////////////////////////////////////							
	PipeLine_Stage_4	PS4	(.clk(clk), .rst(rst),		 // clock, reset
									 .IE(IE),						 // Interupt Enable
									 .IDEX_PC(IDEX_PC), 		 	 // Program Counter
									 .EXMEM_M(EXMEM_M), 			 // Memory Control Words
									 .EXMEM_WB(EXMEM_WB), 		 // Write Back Control Words
									 .EXMEM_Baddr(EXMEM_Baddr), // Branch Address
									 .EXMEM_Jaddr(EXMEM_Jaddr), // Jump Address
									 .EXMEM_FLAGS(EXMEM_FLAGS), // Flags
									 .M_Data(M_Data),  			 // Memory Data
									 .io_out(io_out),				 // IO Data
									 .EXMEM_ALU(EXMEM_ALU),		 // ALU
									 .EXMEM_MData(EXMEM_MData), // Memory Data
									 .EXMEM_Waddr(EXMEM_Waddr), // Write Back Address
									 .MEMWB_WB(MEMWB_WB),   	 // Write Back Control Words
									 .MEMWB_MData(MEMWB_MData), // Memory Data
									 .MEMWB_IO(MEMWB_IO), 		 // IO  Data
									 .MEMWB_ALU(MEMWB_ALU), 	 // ALU
									 .MEMWB_Waddr(MEMWB_Waddr), // Write Back Address
									 .PC_out(PC_in),				 // Program Counter input
									 .Branch_s(Branch_s),		 // Branch signal
									 .pc4_mux(pc4_mux));			 // Data going to memory

	///////////////////////////////////////////////////////////////////////////////////
	// Stage 5 of the pipeline is the write back to the register file stage. However 
	// this is more of a pseudo-module that takes the control words and passes the 
	// correct values back to the state 2 module for storing. This is because the 
	// register files are only found int Stage 2.
	///////////////////////////////////////////////////////////////////////////////////							
	PipeLine_Stage_5	PS5	(.clk(clk), .rst(rst),     // clock , reset
									.MEMWB_WB(MEMWB_WB),			// Write Back
									.MEMWB_MData(MEMWB_MData),	// Memory Data
									.MEMWB_IO(MEMWB_IO),			// IO Data
									.MEMWB_ALU(MEMWB_ALU),		// ALU
									.MEMWB_Waddr(MEMWB_Waddr), // Write Back Address
									.WB_Data(WB_Data), 			// Write Back Data
									.WB_Addr(WB_Addr), 			// Write Back Address
									.WB_D_EN(WB_D_EN));			// Write Back Data Enable
								
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:20:35 11/17/2018 
// Design Name: 
// Module Name:    CPU 
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
module CPU(clk,rst,intr_ack,
		intr,EXMEM_ALU,
		pc4_mux,
		EXMEM_M,
		M_Data,io_out);

		input 		 clk, rst;
		input 		 intr; // interrupt
		input	[31:0] M_Data,io_out; //memory outputs
		
		output 		  intr_ack; //interrupt acknowledge
		output [31:0] EXMEM_ALU,pc4_mux;//ALU, data to mem
		output [15:0] EXMEM_M; // Memory Control Word
		
		wire 			Branch_s,ISR,IE;//Branch, Interrupt service, Interrupt Enable
		wire [31:0] IFID_IR; //instruction register
	
		wire  [2:0] LISR; //leave interrupt service routine
		wire [15:0] EX; //execute control
		wire [15:0] M; // memory control
		wire  [3:0] WB; // write back control
		
	
		wire 			 pc_ld , pc_inc;
		wire 	[31:0] PC_in;
		wire 			 im_cs , im_wr , im_rd;
		wire	[31:0] PC ;
		wire 	[15:0] IDEX_M;
		wire	 [4:0] IDEX_TA;
		wire	[31:0] D_Out;
		wire 	[31:0] PC_out,M_Data;
		wire 	[15:0] EXMEM_M;
		wire	[31:0] pc4_mux, EXMEM_ALU;
		
		wire Stall,Flush;
	
		///////////////////////////////////////////////////////////////////////////
		//									CONTROL UNIT
		//The control unit handles setting up the control words for every 
		//instruction. It outputs new control words every clock cycle due to 
		//design being a pipeline. The control unit also handles setting up and 
		//leaving the ISR.
		//////////////////////////////////////////////////////////////////////////
		
		Control_Unit CU(.clk(clk),					//clock
							.rst(rst),					//reset
							.IE(IE),						//Interrupt Enable
							.ISR(ISR),					//Interrupt Sevice Routine
							.LISR(LISR),				//Leave Interrupt Sevice Routine
							.EXMEM_M(EXMEM_M),		//Memory Control Word
							.IFID_IR(IFID_IR),		//Instruction Register
							.Branch_s(Branch_s),		//Branch Signal
							.intr(intr),				//Interrupt
							.intr_ack(intr_ack),		//Interrupt Acknowledg
							.EX(EX),						//Execute Control Words
							.M(M),						//Memory Control Words
							.WB(WB));					//Write Back Control Words
		
		////////////////////////////////////////////////////////////////////////////
		//								HAZARD CONTROL UNIT
		//This unit takes care of any hazards in the pipeline based on an 
		//instruction. The main purpose is to flush or stall the pipeline when 
		//necessary.
		////////////////////////////////////////////////////////////////////////////
		Control_Hazard CHU 	(.IFID_IR(IFID_IR), 	//Instruction Register
									.IDEX_TA(IDEX_TA),  	//T Address
									.IDEX_M(IDEX_M),		//Memory Control Words(stage 3)
									.EXMEM_M(EXMEM_M), 	//Memory Control Words(stage 4)
									.Branch_s(Branch_s), //Branch Signal
									.Stall(Stall), 		//Stall
									.Flush(Flush));		//Flush
				
		////////////////////////////////////////////////////////////////////////////
		//							PROGRAM COUNTER CONTROL UNIT
		//This control unit simple takes care of setting the appropriate signals 
		//for the program counter.
		////////////////////////////////////////////////////////////////////////////
		
		PC_CU  PCU 	(.EXMEM_M(EXMEM_M), 	//Memory Control Words
						.Branch_s(Branch_s),	//Branch Signal
						.Stall(Stall),			//Stall
						.pc_ld(pc_ld), 		//PC Load
						.pc_inc(pc_inc), 		//PC Increment
						.im_cs(im_cs), 		//im chip select
						.im_wr(im_wr), 		//im write
						.im_rd(im_rd));		//im read
						
		////////////////////////////////////////////////////////////////////////////
		//									INSTRUCTION UNIT
		//Conatains both the PC and the instruction memory. This is also the 
		//first stage to the pipeline where the instructions are fetched.
		////////////////////////////////////////////////////////////////////////////
		Instruction_Unit	IU (.clk(clk), 			//clock
									.rst(rst), 				//reset
									.ISR(ISR),				//Interrupt Service routine
									.LISR(LISR),			//Leave ISR
									.PC_in(PC_in), 		//Program Counter Input
									.pc_ld(pc_ld), 		//Program Counter Load
									.pc_inc(pc_inc), 		//PC Increment
									.im_cs(im_cs), 		//im chip select
									.im_wr(im_wr), 		//im write
									.im_rd(im_rd), 		//im read
									.Stall(Stall),			// Stall
									.Flush(Flush),			//Flush
									.PC_out(PC_out), 		//Program Counter Output 
									.IFID_IR(IFID_IR));	//Instruction Register

		////////////////////////////////////////////////////////////////////////////
		//                         	DATAPATH
		//The rest of the pipeline stages are located here. As well as all other 
		// operations are performed in the datapath.
		////////////////////////////////////////////////////////////////////////////						
		DataPath		DP	(.clk(clk), 				//clock
							.rst(rst),					//reset
							.IE(IE),						//Interrupt Enable
							.ISR(ISR),					//Interrupt Service Routin
							.LISR(LISR),				//Leave ISR
							.EX(EX), 					//Execute Control Words
							.M(M), 						//Memory Control Words
							.WB(WB), 					//Write Back Control Words
							.Flush(Flush),				//Flush
							.Stall(Stall),				//Stall
							.IFID_IR(IFID_IR), 		//Instruction Register
							.PC_out(PC_out), 			//Program Counter
							.M_Data(M_Data),			//Memory Data
							.io_out(io_out),			//IO Module out
							.IDEX_TA(IDEX_TA),		//T Address
							.IDEX_M(IDEX_M),			//Memory Control Words(stage3)
							.EXMEM_M(EXMEM_M), 		//Memory Control Words(stage34)
							.pc4_mux(pc4_mux), 		//data to memory 				
							.EXMEM_ALU(EXMEM_ALU),	//ALU
							.PC_in(PC_in),				//Program Counter Input
							.Branch_s(Branch_s));	//Branch Signal
							
							
							

							

endmodule

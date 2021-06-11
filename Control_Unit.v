`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:20:56 11/17/2018 
// Design Name: 
// Module Name:    Control_Unit 
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
module Control_Unit(clk,rst,IE,ISR,LISR,EXMEM_M,IFID_IR,Branch_s,intr,intr_ack,
							EX,M,WB );
	
	input 				clk,rst; // clock, reset
	input 				Branch_s; // branch signal
	input 				intr; 	// interrupt
	input 	  [15:0] EXMEM_M; //EXMEM memory control word
	input 	  [31:0]	IFID_IR; // instruction register
	
	output 		[2:0] LISR;   // leave interrupt service routine
	output reg			intr_ack; // interrupt acknowledge
	output reg [15:0] EX;		 // execute control word - origin
	output reg [15:0] M;			 // memory control word - origin
	output reg  [3:0] WB;		 // write back control word - origin
	
//----------------------------------------------------------------------------------//
	////////////////////////////////////////////////////////////////////////////
	//		  Control Word BreakDown
	//		  ______________________________________________________
	// EX: | HILO_L | T_mux | Addr_mux | Y_mux | Shamt | Function |
	//		        15      14 13      12 11   10 9     5 4         0	
	//
	//		  ________________________________________IO___________M_______________
	// M:  | L | PC4 | Flag | IF | PC_in | JF | (cs,wr,rd) | (cs,wr,rd) | Branch |
	//       15    14     13   12      11   10 9          7 6          4 3      0 
	//      ________________________
	// WB: | Break | WB_Data | D_En |
	//            3 2       1      0
	////////////////////////////////////////////////////////////////////////////
	output wire ISR; // interupt sevice routine (used for setup)
	
	output reg IE; // interrupt enable
	 
	reg [2:0] LISR; // leave interrupt service routine
	
	////////////////////////////////////////////////////////////////////////////
	// All the R-type instructions are given parameter names in order to improve
	// legibility in the control block.
	////////////////////////////////////////////////////////////////////////////
	parameter r_type = 6'h00,	sll  = 6'h00,	srl  = 6'h02,	sra = 6'h03, 
				 jr 	  = 6'h08, 	mfhi = 6'h10, 	mflo = 6'h12, 	mul = 6'h18, 
				 div 	  = 6'h1A, 	add  = 6'h20,	addu = 6'h21,	sub = 6'h22, 
				 subu   = 6'h23, 	And  = 6'h24, 	Or   = 6'h25, 	Xor = 6'h26,
				 Nor 	  = 6'h27, 	slt  = 6'h2A,	sltu = 6'h2B, 	Break = 6'h0D, 
				 setie = 6'h1F;
	
	////////////////////////////////////////////////////////////////////////////
	// Just as the above instructions, all other instuctions are also given a 
	// parameter name.
	////////////////////////////////////////////////////////////////////////////
	parameter beq 	= 6'h04,	bne  = 6'h05,	blez  = 6'h06,	bgtz = 6'h07, 
				 addi = 6'h08,	slti = 6'h0A, 	sltiu = 6'h0B,	andi = 6'h0C, 
				 ori 	= 6'h0D, xori = 6'h0E, 	lui 	= 6'h0F, lw   = 6'h23,
				 sw   = 6'h2B, j 	  = 6'h02,  jal 	= 6'h03, Input = 6'h1C, 
				 Output = 6'h1D, reti = 6'h1E, e_key = 6'h1F;
				 
	 
	//	Start the interupt service routine when the interupt enable is active,
	// interupt is active high, and it has not been acknowledged yet.
	assign ISR = intr & IE & !intr_ack;			 
	
	

   reg	[3:0] ISR_StepWire; // These registers are used as counters in order
   reg   [3:0] ISR_StepReg;  // to allow the ISR to properly set up.
   
	////////////////////////////////////////////////////////////////////////////
	// Here the counter for the ISR is incremented on every clock tick 
	// allowing for proper stage to stage setup.
	////////////////////////////////////////////////////////////////////////////
   always@(posedge clk, posedge rst)
      if(rst) ISR_StepReg <= 4'b0;
      else    ISR_StepReg <= ISR_StepWire;
   
	////////////////////////////////////////////////////////////////////////////
	// This counter is used to allow the cpu to exit the ISR allowing it 
	// enough time to properly pop the pc and flags.
	////////////////////////////////////////////////////////////////////////////
	always@(posedge clk, posedge rst)
		if(rst) LISR = 0;else
		if(LISR) LISR = LISR +1 ;
					
	////////////////////////////////////////////////////////////////////////////
	// Synchronous block that acknowldges the interrupt once the setup has been
	// completed. Acknowledging the interrupt ends the setup and enters the ISR.
	////////////////////////////////////////////////////////////////////////////
	always@(posedge clk, posedge rst)
		if(rst) intr_ack = 0;else
		if(EXMEM_M[12]) intr_ack = 1'b1;else // when int. flag is high ack = 1
		if(intr_ack &(intr == 0)) intr_ack = 0;else // turn of ack after
										 intr_ack = intr_ack; // idle state
										 
	////////////////////////////////////////////////////////////////////////////
	// The control unit, the control words for each instructions coming into the 
	// pipeline are determenined here based on the type of instruction as well
	// as the op codes and values in the instruction register(IR).
	////////////////////////////////////////////////////////////////////////////
	always @(*)begin
		if(rst)begin				
			EX = 16'b0_0_11_00_00000_10101; 	//$sp setup mod 13
			M = 16'b0_0_0_0_0_0_000_000_0000;//
			WB = 4'b0_0_0_1;					   //
		

			IE = 1'b0;
			ISR_StepWire= 0;
			
		end
		else if(ISR)begin
				case(ISR_StepReg)
         
				//store flags
            4'h0: begin//Step 1 stores current PC at $ra *NOTE: This is just for module 13, 14 will do the $sp pointer store
                  //also increment the ISR_Step
                  //Control_EX  = Set up the YMUX to pass in the PC4 Value, and toggle the WB Dest. to be $ra
                  //Control_M   = Do nothing in this stage
                  //Control_WB  = WRITE to R[31] the $ra
							EX = 16'b0_0_11_00_00000_10001;
							M = 16'b0_0_1_0_0_0_000_110_0000;
							WB = 4'b0_00_1;
                     ISR_StepWire = 4'h1;
                  end
                  
            4'h1: begin
								//store pc
								//Step Loads the PC with the the value from dMEM[0x3FC]
                       //need to add in the appropriate hardware for this to work
                       //Control_EX  = use appropriate setup for getting RS to be $31 = $ra
                       //Control_M   = Take the Value read from dMEM[0x3FC] and jump to it *add hardware
                       //Control_WB  = do nothing
								EX = 16'b0_0_11_00_00000_10001;
								M = 16'b0_1_0_0_0_0_000_110_0000;
								WB = 4'b0_00_1; 
								ISR_StepWire = 4'h2;
								
								
							
                  end
					4'h2:begin
					// jump to isr
								EX = 16'b0_0_00_00_00000_10101;
								M = 16'b0_0_0_1_0_0_000_101_0000;
								WB = 4'b0_00_0; 
								ISR_StepWire = 4'h3;
					end
         endcase
 
	
	
		end
		else
		if(LISR)	//
			case(LISR)	
			//
			 3'b001:begin
				EX = 16'b0_0_11_00_00000_10010;
				M = 16'b0_0_0_0_0_0_000_101_0000;
				WB = 4'b0_00_1; end
			 //
			 3'b010:begin
				EX = 16'b0_0_11_00_00000_10010;
				M = 16'b0_0_0_0_0_0_000_101_0000;
				WB = 4'b0_00_1;end
			 //
			 3'b011:begin
				EX = 16'b0_0_11_00_00000_10010;
				M = 16'b0_0_0_0_0_0_000_101_0000;
				WB = 4'b0_00_1;end
			 //
			 3'b100:begin
				EX = 16'b0_0_11_00_00000_10010;
				M = 16'b0_0_0_0_0_0_000_101_0000;
				WB = 4'b0_00_0;end
			endcase
		else
		case(IFID_IR[31:26])
			r_type:
				case(IFID_IR[5:0])
					add: begin
							EX = 16'b0_0_00_00_00000_00010;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
	
					sll: begin
							EX = {6'b0_0_00_00,IFID_IR[10:6],5'b01100};
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					srl: begin
							EX = {6'b0_0_00_00,IFID_IR[10:6],5'b01101};
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					sra: begin
							EX = {6'b0_0_00_00,IFID_IR[10:6],5'b001110};
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					/////////////////////////////////////		
					jr: begin
							EX = 16'b0_0_00_00_00000_00000;
							M = 16'b0_0_0_0_1_0_000_000_0000;
							WB = 4'b0_0_0_0; end
					mfhi: begin
							EX = 16'b0_0_00_10_00000_00000;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					mflo: begin
							EX = 16'b0_0_00_01_00000_00000;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					mul: begin
							EX = 16'b1_0_00_00_00000_11110;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_0; end
					div: begin
							EX = 16'b1_0_00_00_00000_11111;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_0; end
					//////////////////////////////////////
			
					addu: begin
							EX = 16'b0_0_00_00_00000_00100;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					sub: begin
							EX = 16'b0_0_00_00_00000_00011;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					subu: begin
							EX = 16'b0_0_00_00_00000_00101;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					And: begin
							EX = 16'b0_0_00_00_00000_01000;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					Or: begin
							EX = 16'b0_0_00_00_00000_01001;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					Xor: begin
							EX = 16'b0_0_00_00_00000_01010;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					Nor: begin
							EX = 16'b0_0_00_00_00000_01011;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					slt: begin
							EX = 16'b0_0_00_00_00000_00110;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
					sltu: begin
							EX = 16'b0_0_00_00_00000_00111;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
							
					Break: begin
							EX = 16'b0_0_00_00_00000_00000;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b1_0_0_0; end
							
					setie: begin
							EX = 16'b0_0_00_00_00000_00000;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_0; 
							IE = 1'b1;end
							
				endcase
			addi: begin
							EX = 16'b0_1_01_00_00000_00010;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
			slti: begin
							EX = 16'b0_1_01_00_00000_00110;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
			sltiu: begin
							EX = 16'b0_1_01_00_00000_00111;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
		   andi: begin
							EX = 16'b0_1_01_00_00000_10110;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
			lui: begin
							EX = 16'b0_1_01_00_00000_11000;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end				
			ori: begin
							EX = 16'b0_1_01_00_00000_10111;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
			xori: begin
							EX = 16'b0_1_01_00_00000_11001;
							M = 16'b0_0_0_0_0_0_000_000_0000;
							WB = 4'b0_0_0_1; end
			sw: begin
							EX = 16'b0_1_00_00_00000_00010;
							M = 16'b0_0_0_0_0_0_000_110_0000;
							WB = 4'b0_0_0_0; end
			lw: begin
							EX = 16'b0_1_01_00_00000_00010;
							M = 16'b0_0_0_0_0_0_000_101_0000;
							WB = 4'b0_0_1_1; end
							
			beq: begin
							EX = 16'b0_0_00_00_00000_00011;
							M = 16'b0_0_0_0_0_0_000_000_0001;
							WB = 4'b0_0_0_0; end
							
			bne: begin
							EX = 16'b0_0_00_00_00000_00011;;
							M = 16'b0_0_0_0_0_0_000_000_0010;
							WB = 4'b0_00_0; end
			blez: begin
							EX = 16'b0_0_00_00_00000_00011;
							M = 16'b0_0_0_0_0_0_000_000_0100;
							WB = 4'b0_00_0; end
			bgtz: begin
							EX = 16'b0_0_00_00_00000_00011;
							M = 16'b0_0_0_0_0_0_000_000_1000;
							WB = 4'b0_00_0; end
							
			j: begin
							EX = 16'b0_0_10_11_00000_00000;
							M = 16'b0_0_0_0_0_1_000_000_0000;
							WB = 4'b0_00_0; end
			jal: begin
							EX = 16'b0_0_10_11_00000_00010;
							M = 16'b0_0_0_0_0_1_000_000_0000;
							WB = 4'b0_00_1; end
			Output: begin
							EX = 16'b0_1_00_00_00000_00010;
							M = 16'b0_0_0_0_0_0_110_000_0000;
							WB = 4'b0_00_0; end
			Input: begin
							EX = 16'b0_1_01_00_00000_00010;
							M = 16'b0_0_0_0_0_0_101_000_0000;
							WB = 4'b0_10_1; end
							
			reti: begin
							EX = 16'b0_0_11_00_00000_00000;
							M = 16'b1_0_0_0_0_0_000_101_0000;
							WB = 4'b0_00_1; 
							LISR = 1; end
		endcase
	end

endmodule

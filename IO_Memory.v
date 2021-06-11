`timescale 1ns / 1ps
/************************************************************************************
* Authors:  Javier Garcia     
*           Taylor Cochran
*
* Emails:   javis9526@yahoo.com
*           TayCochran123@gmail.com
*
* Filename: Data_Memory.v
* Date:     November 24, 2018
* Version:  1.2
*
* Notes:    *add comments here*
*
*
*                                                                  (End of Page Width)
*************************************************************************************/
module IO_Memory(clk, rst, io_cs, io_wr, io_rd, Address, D_In, D_Out, 
                 intr_ack, io_intr);

   //Inputs
   input   clk, rst;

   input io_cs,  //Chip Select control signal.  Used to either read or write
         io_wr,  //      Write control signal.  MUST BE ON TO WRITE 
         io_rd;  //       Read control signal.  MUST BE ON TO READ
   
   input intr_ack;//Interrupt Acknowledge for handhsake

   input  [11:0]  Address; //12-bit address field for D_Out
   input  [31:0]  D_In;    //32-bit Data Input
                  
   //Outputs
   output    reg     io_intr; //Psuedo external interrupt for accessing ISR.

   output [31:0]  D_Out;   //32-bit Output field for Data Path to read
                           //If not being read, D_Out will be in Tri-State Hi-Z mode     
//----------------------------------------------------------------------------------//
   ////////////////////////////////////
   //    4096x8 Big Endian Memory    //
   //--------------------------------//
   //    Effective 1024x32 Memory    //
   ////////////////////////////////////
   
   reg   [7:0] Memory [4095:0]; //Width:    7 bits &  Depth: 4096 bits
   
   //Synchronous Write
   always@(posedge clk)
      if(io_cs & io_wr) {Memory[Address + 12'h0],
                         Memory[Address + 12'h1],
                         Memory[Address + 12'h2],
                         Memory[Address + 12'h3]} <= D_In;
   //Asynchronous Read
   assign D_Out = (io_cs & io_rd) ? {Memory[Address + 12'h0],
                                     Memory[Address + 12'h1],
                                     Memory[Address + 12'h2],
                                     Memory[Address + 12'h3]} : 32'bZ;

//----------------------------------------------------------------------------------//
   ////////////////////////////////////
   //      Interrupt  Handshake      //
   ////////////////////////////////////


		initial begin
		io_intr = 0;
		
      #200 io_intr = 1;
      end
		
		
     always @(posedge intr_ack) begin
            io_intr = 0;
      end

//----------------------------------------------------------------------------------//
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:47:09 11/21/2018 
// Design Name: 
// Module Name:    Shif_right_logic 
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
module Shif_right_logic(T,shamt,Y_lo,{C,V,N,Z});

		input [31:0] T;
		input [4:0] shamt;
		output  reg [31:0]Y_lo;
		output	reg C,V,N,Z;
		
		/////////////////////////////////////////////////////////////////////
		// Barrel shifter allows to shift more than one bit to the right.
		////////////////////////////////////////////////////////////////////
		always @(*) begin
			C = T[0]; 		N = Y_lo[31];	V =1'bx ;
			case(shamt) // shift amount;
				5'd0: Y_lo = T;// dont shift
				5'd1: Y_lo = {1'b0,T[31:1]};// shift right 1-bit
				5'd2: Y_lo = {2'b0,T[31:2]};// shift right 2-bit
				5'd3: Y_lo = {3'b0,T[31:3]};// shift right 3-bit
				5'd4: Y_lo = {4'b0,T[31:4]};// shift right 4-bit
				5'd5: Y_lo = {5'b0,T[31:5]};// shift right 5-bit
				5'd6: Y_lo = {6'b0,T[31:6]};// shift right 6-bit
				5'd7: Y_lo = {7'b0,T[31:7]};// shift right 7-bit
				5'd8: Y_lo = {8'b0,T[31:8]};// shift right 8-bit
				5'd9: Y_lo = {9'b0,T[31:9]};// shift right 9-bit
				5'd10: Y_lo = {10'b0,T[31:10]};// shift right 10-bit
				5'd11: Y_lo = {11'b0,T[31:11]};// shift right 11-bit
				5'd12: Y_lo = {12'b0,T[31:12]};// shift right 12-bit
				5'd13: Y_lo = {13'b0,T[31:13]};// shift right 13-bit
				5'd14: Y_lo = {14'b0,T[31:14]};// shift right 14-bit
				5'd15: Y_lo = {15'b0,T[31:15]};// shift right 15-bit
				5'd16: Y_lo = {16'b0,T[31:16]};// shift right 16-bit
				5'd17: Y_lo = {17'b0,T[31:17]};// shift right 17-bit
				5'd18: Y_lo = {18'b0,T[31:18]};// shift right 18-bit
				5'd19: Y_lo = {19'b0,T[31:19]};// shift right 19-bit 
				5'd20: Y_lo = {20'b0,T[31:20]};// shift right 20-bit
				5'd21: Y_lo = {21'b0,T[31:21]};// shift right 21-bit
				5'd22: Y_lo = {22'b0,T[31:22]};// shift right 22-bit
				5'd23: Y_lo = {23'b0,T[31:23]};// shift right 23-bit
				5'd24: Y_lo = {24'b0,T[31:24]};// shift right 24-bit
				5'd25: Y_lo = {25'b0,T[31:25]};// shift right 25-bit 
				5'd26: Y_lo = {26'b0,T[31:26]};// shift right 26-bit
				5'd27: Y_lo = {27'b0,T[31:27]};// shift right 27-bit
				5'd28: Y_lo = {28'b0,T[31:28]};// shift right 28-bit
				5'd29: Y_lo = {29'b0,T[31:29]};// shift right 29-bit
				5'd30: Y_lo = {30'b0,T[31:30]};// shift right 30-bit
				5'd31: Y_lo = {31'b0,T[31]};// shift right 31-bit
				default: Y_lo = T; // dont shift
		endcase
		end
	 endmodule

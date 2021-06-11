`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:46:50 11/21/2018 
// Design Name: 
// Module Name:    Shift_left 
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
module Shift_left(T,shamt,Y_lo,{C,V,N,Z});

		input [31:0] T;
		input [4:0] shamt;
		output reg [31:0] Y_lo;
		output reg	C,V,N,Z;
		
		/////////////////////////////////////////////////////////////
		// Barrel Shifter allows to shift more than one bit to the 
		// left.
		/////////////////////////////////////////////////////////////
		always @(*) begin
			C = T[31]; 	N = Y_lo[31];	V =1'bx ;
			case(shamt) // shift amount
				5'd0:	Y_lo = T; // dont shift
				5'd1: Y_lo = {T[30:0],1'b0};// shift left 1-bit 
				5'd2: Y_lo = {T[29:0],2'b0};// shift left 2-bit 
				5'd3: Y_lo = {T[28:0],3'b0};// shift left 3-bit 
				5'd4: Y_lo = {T[27:0],4'b0};// shift left 4-bit 
				5'd5: Y_lo = {T[26:0],5'b0};// shift left 5-bit 
				5'd6: Y_lo = {T[25:0],6'b0};// shift left 6-bit 
				5'd7: Y_lo = {T[24:0],7'b0};// shift left 7-bit 
				5'd8: Y_lo = {T[23:0],8'b0};// shift left 8-bit 
				5'd9: Y_lo = {T[22:0],9'b0};// shift left 9-bit 
				5'd10: Y_lo = {T[21:0],10'b0};// shift left 10-bit 
				5'd11: Y_lo = {T[20:0],11'b0};// shift left 11-bit 
				5'd12: Y_lo = {T[19:0],12'b0};// shift left 12-bit 
				5'd13: Y_lo = {T[18:0],13'b0};// shift left 13-bit 
				5'd14: Y_lo = {T[17:0],14'b0};// shift left 14-bit 
				5'd15: Y_lo = {T[16:0],15'b0};// shift left 15-bit 
				5'd16: Y_lo = {T[15:0],16'b0};// shift left 16-bit 
				5'd17: Y_lo = {T[14:0],17'b0};// shift left 17-bit 
				5'd18: Y_lo = {T[13:0],18'b0};// shift left 18-bit 
				5'd19: Y_lo = {T[12:0],19'b0};// shift left 19-bit 
				5'd20: Y_lo = {T[11:0],20'b0};// shift left 20-bit 
				5'd21: Y_lo = {T[10:0],21'b0};// shift left 21-bit 
				5'd22: Y_lo = {T[9:0],22'b0};// shift left 22-bit 
				5'd23: Y_lo = {T[8:0],23'b0};// shift left 23-bit 
				5'd24: Y_lo = {T[7:0],24'b0};// shift left 24-bit 
				5'd25: Y_lo = {T[6:0],25'b0};// shift left 25-bit 
				5'd26: Y_lo = {T[5:0],26'b0};// shift left 26-bit 
				5'd27: Y_lo = {T[4:0],27'b0};// shift left 27-bit 
				5'd28: Y_lo = {T[3:0],28'b0};// shift left 28-bit 
				5'd29: Y_lo = {T[2:0],29'b0};// shift left 29-bit 
				5'd30: Y_lo = {T[1:0],30'b0};// shift left 30-bit 
				5'd31: Y_lo = {T[0],31'b0};// shift left 31-bit 
				default:  Y_lo = 0;// dont shift
			endcase
			end
endmodule

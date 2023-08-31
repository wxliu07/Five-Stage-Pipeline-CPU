`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/26 22:18:38
// Design Name: 
// Module Name: ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"
module ctrl(

	input wire										rst,

	input wire                   stallreq_from_id,

  //来自执行阶段的暂停请求
	input wire                   stallreq_from_ex,
	output reg[5:0]              stall       
	
);

	always @ (*) 
	begin
		if(rst == `RstEnable) begin
			stall <= 6'b000000;
		end 
		else if(stallreq_from_ex ==`Stop) begin
			stall <= 6'b001111;
		end 
		else if(stallreq_from_id ==`Stop) begin
			stall <= 6'b000111;			
		end 
		else begin
			stall <= 6'b000000;
		end    //if
	end      //always
			

endmodule

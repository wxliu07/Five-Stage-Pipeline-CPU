`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 20:33:32
// Design Name: 
// Module Name: mem_wb
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

module mem_wb(
    input wire clk,
    input wire rst,
    //流水线暂停
    input wire[5:0]               stall,
    //访存阶段的结果
    input wire[`reg_addr_bus] mem_wd,
    input wire mem_wreg,
    input wire[ `reg_bus] mem_wdata,
    //送到回写阶段的信息
    output reg[`reg_addr_bus] wb_wd,
    output reg wb_wreg,
    output reg[`reg_bus] wb_wdata
    );

    always @(posedge clk ) begin
        if(rst ==`RstEnable) begin
            wb_wd<=`NOP_reg_addr;
            wb_wreg<=`WriteDisable;
            wb_wdata<=`ZeroWord;
             
		end else if(stall[4] == `Stop && stall[5] == `NoStop) begin
			wb_wd <=`NOP_reg_addr;
			wb_wreg <= `WriteDisable;
		  wb_wdata <= `ZeroWord;	  	  
		end else if(stall[4] == `NoStop) begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;		
		end
    end
endmodule

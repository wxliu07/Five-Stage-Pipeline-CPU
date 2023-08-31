`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 20:13:09
// Design Name: 
// Module Name: ex_mem
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

module ex_mem(
    input wire clk,
    input  wire rst,
    	input wire[5:0]	 stall,	
    //来自执行阶段的信息
    input wire [`reg_addr_bus] ex_wd,
    input wire ex_wreg,
    input wire[ `reg_bus] ex_wdata,
    //送到访存阶段的信息
    output reg[ `reg_addr_bus] mem_wd,
    output reg mem_wreg,
    output reg[`reg_bus] mem_wdata
    );
    always @(posedge clk ) begin
        if(rst ==`RstEnable) begin
                mem_wd<=`NOP_reg_addr;
                mem_wreg<=`WriteDisable;
                mem_wdata<=`ZeroWord;
            end 
            else begin
                mem_wd<=ex_wd;
                mem_wreg<=ex_wreg;
                mem_wdata <= ex_wdata;
            end
    end
endmodule

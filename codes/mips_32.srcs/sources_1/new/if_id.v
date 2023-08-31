`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 11:47:54
// Design Name: 
// Module Name: if_id
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

module if_id(
    input rst,
    input clk,
    input [`inst_addr_bus] if_pc,
    input [`inst_bus] if_inst,
	//来自控制模块的信息
	input wire[5:0] stall,
    output reg[`inst_addr_bus] id_pc,
    output reg[`inst_bus] id_inst
    );
    always @(posedge clk) begin
        if(rst == `RstEnable)begin
            id_pc <=`ZeroWord;
            id_inst <= `ZeroWord;
        end
        else if(stall[1] == `Stop && stall[2] == `NoStop)begin
            id_pc <=`ZeroWord;
            id_inst <= `ZeroWord;
        end 
        else if(stall[1] == `NoStop) begin
                id_pc <= if_pc;
                id_inst <= if_inst;
            end
    end
endmodule

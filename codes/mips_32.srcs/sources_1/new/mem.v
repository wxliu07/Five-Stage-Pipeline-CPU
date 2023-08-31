`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 20:20:27
// Design Name: 
// Module Name: mem
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

module mem(
    input wire rst,
    input wire clk,
    //来自执行阶段的信息
    input wire[`reg_addr_bus] wd_i,
    input wire wreg_i,
    input wire [`reg_bus] wdata_i,
    input wire read_ena,
    input [`reg_bus]read_data,
    //访存阶段的结果
    output reg [`reg_addr_bus] wd_o,
    output reg wreg_o,
    output reg[`reg_bus] wdata_o
    );
    always@(*)begin
        if(rst ==`RstEnable) begin
            wd_o<=`NOP_reg_addr;
            wreg_o<=`WriteDisable;
            wdata_o <= `ZeroWord;
        end
        else if(read_ena == 1'b1) begin
            wd_o<= wd_i;
            wreg_o<= wreg_i;
            wdata_o <= read_data;
        end 
        else begin
            wd_o<= wd_i;
            wreg_o<= wreg_i;
            wdata_o <= wdata_i;
        end
    end

endmodule

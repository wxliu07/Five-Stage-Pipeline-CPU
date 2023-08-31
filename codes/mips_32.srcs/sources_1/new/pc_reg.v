`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 11:22:50
// Design Name: 
// Module Name: pc_reg
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

module pc_reg(
    input rst,
    input clk,
    input wire[5:0] stall,//流水暂停
	//来自译码阶段的信息
	input wire            branch_flag_i,
	input wire[`reg_bus]   branch_target_address_i,

    output reg[`inst_addr_bus] pc,
    output reg      ce//使能信号
    );
    always @(posedge clk)
    begin
        if(rst == `RstEnable)begin
            ce<=`ChipDisable;
        end
        else begin
            ce<=`ChipEnable;
        end
    end
    always @ (posedge clk)begin
        if(ce == `ChipDisable) begin
            pc <= 32'h00000000;
        end
        else if(stall[0] == `NoStop)begin
            if(branch_flag_i == `Branch) begin
				pc <= branch_target_address_i;
            end
            else begin
                pc <= pc+4;
            end
        end
    end
endmodule

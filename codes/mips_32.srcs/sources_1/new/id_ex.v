`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 16:05:24
// Design Name: 
// Module Name: id_ex
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

module id_ex(
    input wire clk,
    input wire rst,
    //控制模块信息
    input wire[5:0]	stall,
    //从译码阶段传递过来的信息
    input wire[ `alu_op_bus] id_aluop,
    input wire[ `alu_sel_bus] id_alusel,
    input wire[ `reg_bus] id_reg1,
    input wire[ `reg_bus] id_reg2,
    input wire[ `reg_addr_bus] id_wd,
    input wire id_wreg,
    input wire[`reg_bus]   id_link_address,
	input wire  id_is_in_delayslot,
	input wire   next_inst_in_delayslot_i,	
    //传递到执行阶段的信息
    output reg[`alu_op_bus] ex_aluop,
    output reg[ `alu_sel_bus] ex_alusel,
    output reg[ `reg_bus] ex_reg1,
    output reg[ `reg_bus] ex_reg2,
    output reg [ `reg_addr_bus] ex_wd,
    output reg[`reg_bus] ex_link_address,
    output reg   ex_is_in_delayslot,
	output reg  is_in_delayslot_o,	
    output reg ex_wreg
    );
    always @(posedge clk) begin
        if (rst ==`RstEnable) begin
            ex_aluop<=`EXE_NOP_OP;
            ex_alusel<=`EXE_RES_NOP;
            ex_reg1<=`ZeroWord;
            ex_reg2<=`ZeroWord;
            ex_wd <=`NOP_reg_addr;
            ex_wreg<=`WriteDisable;
			ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
	        is_in_delayslot_o <= `NotInDelaySlot;	
		end else if(stall[2] == `Stop && stall[3] == `NoStop) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOP_reg_addr;
			ex_wreg <= `WriteDisable;	
			ex_link_address <= `ZeroWord;
	        ex_is_in_delayslot <= `NotInDelaySlot;			
		end else if(stall[2] == `NoStop) begin		
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd   <= id_wd;
			ex_wreg <= id_wreg;		
			ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;
	        is_in_delayslot_o <= next_inst_in_delayslot_i;				
		end
end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 19:50:46
// Design Name: 
// Module Name: ex
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

module ex(
    input wire rst,
    //译码阶段送到执行阶段的信息
    input wire[`alu_op_bus] aluop_i,
    input wire[`alu_sel_bus] alusel_i,
    input wire[`reg_bus] reg1_i,
    input wire[`reg_bus] reg2_i,
    input wire[`reg_addr_bus] wd_i,
    input wire wreg_i,
	//是否转移、以及link address
	input wire[`reg_bus]           link_address_i,
	input wire   is_in_delayslot_i,	
    //执行的结果
    output reg[`reg_addr_bus] wd_o,
    output reg wreg_o,
    output reg[`reg_bus] wdata_o,
    output reg	stallreq,
    output reg	read_ena,
    output reg[`reg_bus] data_mem_addr
    );
    reg[`reg_bus] logicout;
    reg[`reg_bus] shiftout;
    reg[`reg_bus] mathout;
    
    //------------第一段，跟你举aluop_i指示的运算子类型进行运算
    always @(*)begin
    if(rst==`RstEnable) begin
        logicout<=`ZeroWord;
        shiftout<=`ZeroWord;
        mathout<=`ZeroWord;
        end 
        else begin
            case (aluop_i)
            `EXE_OR_OP: begin
                logicout <= reg1_i | reg2_i;
                read_ena<= 1'b0;
                end
            `AND_OP: begin
                logicout <= reg1_i & reg2_i;
                read_ena<= 1'b0;
                end
            `XOR_OP:begin
                logicout <= reg1_i ^ reg2_i;
                read_ena<= 1'b0;
            end
            `NOR_OP:begin
                logicout <= ~(reg1_i ^ reg2_i);
                read_ena<= 1'b0;
            end
            `SLL_OP:begin
                shiftout<=reg2_i<<reg1_i[4:0];
                read_ena<= 1'b0;
            end
            `SRL_OP:begin
                shiftout<=reg2_i<<reg1_i[4:0];
                read_ena<= 1'b0;
            end
            `SRA_OP:begin
                shiftout<=({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) 
												| reg2_i >> reg1_i[4:0];
                read_ena<= 1'b0;
            end
            `ADD_OP:begin
                mathout<=reg1_i+reg2_i;
                read_ena<= 1'b0;
            end
            `SUB_OP:begin
                mathout<=reg1_i-reg2_i;
                read_ena<= 1'b0;
            end
            `SLL_OP:begin
                mathout<= (reg1_i<reg2_i)?1'b1:1'b0;
                read_ena<= 1'b0;
            end
            `MUL_OP:begin
                mathout<=reg1_i*reg2_i;
                read_ena<= 1'b0;
            end
            `DIV_OP:begin
                mathout<= reg1_i/reg2_i;
                read_ena<= 1'b0;
            end
            `LW_OP:begin
                data_mem_addr<= reg1_i+reg2_i;
                read_ena<= 1'b1;
            end
            default: begin
                logicout<=`ZeroWord;
                end
                
            endcase
        end //ifend
    end// always
//----------------------------------------------------
//第二段，根据alusel_i指示运算类型，选择一个运算结果为最终结果
//------------------------------------------------------
    always @(*)begin
        wd_o<= wd_i;// wd_o等于wd_i，要写的目的寄存器地址
        wreg_o<= wreg_i;// wreg_o等于wreg_i，表示是否要写目的寄存器
        case ( alusel_i)
            `EXE_RES_LOGIC:begin
                wdata_o<= logicout; // wdata_o中存放运算结果
            end
            `EXE_RES_SHIFT:begin
                wdata_o<=shiftout;//移位运算结果
            end
            `EXE_RES_MATH:begin
                wdata_o<= mathout;
            end
            `EXE_RES_JUMP_BRANCH:begin
                wdata_o<=link_address_i;
            end
            `EXE_RES_LW:begin
                wdata_o<= data_mem_addr;
            end
            default:begin
                wdata_o<=`ZeroWord;
            end
        endcase
    end

endmodule

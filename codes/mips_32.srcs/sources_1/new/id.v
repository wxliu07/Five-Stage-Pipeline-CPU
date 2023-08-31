`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 15:13:56
// Design Name: 
// Module Name: id
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

module id(
    input wire rst,
    input wire[`inst_addr_bus] pc_i,
    input wire[ `inst_bus] inst_i,

    //处于执行阶段的指令的运算结果
    input wire ex_wreg_i,
    input wire[`reg_bus] ex_wdata_i,
    input wire[`reg_addr_bus] ex_wd_i,
    //处于访存阶段的指令的运算结果
    input wire mem_wreg_i,
    input wire[`reg_bus] mem_wdata_i,
    input wire[`reg_addr_bus] mem_wd_i,

    //如果上一条指令是转移指令，那么下一条指令在译码的时候is_in_delayslot为true
    input wire  is_in_delayslot_i,



    //读取的Regfile的值
    input wire[`reg_bus] reg1_data_i,
    input wire[`reg_bus] reg2_data_i,
    //输出到Regfile的信息
    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`reg_addr_bus] reg1_addr_o,
    output reg[`reg_addr_bus] reg2_addr_o,
    //送到执行阶段的信息
    output reg[`alu_op_bus] aluop_o,
    output reg[`alu_sel_bus] alusel_o,
    output reg[`reg_bus] reg1_o,
    output reg[`reg_bus] reg2_o,
    output reg[`reg_addr_bus] wd_o,
    output reg wreg_o,
    output reg             next_inst_in_delayslot_o,
        
    output reg           branch_flag_o,
    output reg[`reg_bus]  branch_target_address_o,       
    output reg[`reg_bus]  link_addr_o,
    output reg             is_in_delayslot_o,
    output wire  stallreq
);
 assign stallreq = `NoStop;
//取得指令的指令码,功能码
//对于ori指令只需通过判断第26-31bit的值，即可判断是否是ori指令wire[5:0] op= inst_i[31:26];
wire[5:0] op = inst_i[31:26];
//wire[4:0]op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
//wire[4:0] op4= inst_i[20:16];
wire[4:0]sa = inst_i[10:6];
//保存指令执行需要的立即数
reg[`reg_bus] imm;
//指示指令是否有效
reg instvalid;



//分支跳转处理
wire[`reg_bus] pc_plus_8;
wire[`reg_bus] pc_plus_4;
wire[`reg_bus] beq_target;  
  
assign pc_plus_8 = pc_i + 8;//保存后两条指令
assign pc_plus_4 = pc_i +4;//保存后一条
//beq_target对应分支指令中的offset左移两位，再符号扩展至32位的值
assign beq_target = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };  

//对指令进行译码-------------------------------------------
always @(*) begin
if(rst ==`RstEnable) begin
    aluop_o<=`EXE_NOP_OP;
    alusel_o <=`EXE_RES_NOP;
    wd_o<=`NOP_reg_addr;
    wreg_o<=`WriteDisable;
    instvalid <=`inst_valid;
    reg1_read_o<= 1'b0;
    reg2_read_o<=1'b0;
    reg1_addr_o<=`NOP_reg_addr;
    reg2_addr_o <=`NOP_reg_addr;
    imm<=32'h0;
	link_addr_o <= `ZeroWord;
	branch_target_address_o <= `ZeroWord;
	branch_flag_o <= `NoBranch;
	next_inst_in_delayslot_o <= `NotInDelaySlot;
end else begin
    aluop_o<=`EXE_NOP_OP;
    alusel_o<=`EXE_RES_NOP;
    wd_o<= inst_i[15:11];
    wreg_o<=`WriteDisable;
    instvalid<=`inst_invalid;
    reg1_read_o<= 1'b0;
    reg2_read_o <= 1'b0;
    reg1_addr_o <= inst_i[25:21];//默认通过Regfile读端口1读取的寄存器地址
    reg2_addr_o <= inst_i[20:16]; //默认通过Regfile读端口2读取的寄存器地址
    imm<= `ZeroWord;
	link_addr_o <= `ZeroWord;
	branch_target_address_o <= `ZeroWord;
	branch_flag_o <= `NoBranch;	
	next_inst_in_delayslot_o <= `NotInDelaySlot; 
    case (op)
        `EXE_ORI: begin
            // ori指令需要将结果写入目的寄存器，所以wreg_o为 writeEnable
            wreg_o<=`WriteEnable;
            //运算的子类型是逻辑“或”运算
            aluop_o<=`EXE_OR_OP;
            //运算类型是逻辑运算
            alusel_o<=`EXE_RES_LOGIC;
            //需要通过Regfile的读端口1读取寄存器
            reg1_read_o<= 1'b1;
            //不需要通过Regfile的读端口2读取寄存器
            reg2_read_o<= 1'b0;
            //指令执行需要的立即数
            imm<={16'h0,inst_i[15:0]};
            //指令执行要写的目的寄存器地址
            wd_o<= inst_i[20:16];
            // ori指令是有效指令
            instvalid<=`inst_valid;
        end
        `ANDI:begin
            wreg_o<=`WriteEnable;
            wd_o<=inst_i[20:16];
            aluop_o<=`AND_OP;
            alusel_o<=`EXE_RES_LOGIC;
            reg1_read_o <=1'b1;
            reg2_read_o<=1'b0;
            imm<=inst_i[15:0];
            instvalid<=`inst_valid;
        end
        `XORI:begin
            wreg_o<=`WriteEnable;
            wd_o<=inst_i[20:16];
            aluop_o<=`XOR_OP;
            alusel_o<=`EXE_RES_LOGIC;
            reg1_read_o <=1'b1;
            reg2_read_o<=1'b0;
            imm<=inst_i[15:0];
            instvalid<=`inst_valid;
        end
        `ADDI:begin
            wreg_o<=1'b1;
            wd_o<=inst_i[20:16];
            aluop_o<=`ADD_OP;
            alusel_o<=`EXE_RES_MATH;
            reg1_read_o<=1'b1;
            reg2_read_o<=1'b0;
            imm<= {16'b0,inst_i[15:0]};
            instvalid = `inst_invalid;
        end
        `MUL:begin
            case (op3)
            `fun_MUL:begin
                wreg_o<=1'b1;
                wd_o<=inst_i[15:11];
                aluop_o<=`MUL_OP;
                alusel_o<= `EXE_RES_MATH;
                reg1_read_o<=1'b1;
                reg2_read_o<=1'b1;
                instvalid = `inst_invalid;
            end 
            `fun_DIV:begin
                wreg_o<=1'b1;
                wd_o<= inst_i[15:11];
                aluop_o<= `DIV_OP;
                alusel_o<= `EXE_RES_MATH;
                reg1_read_o<= 1'b1;
                reg2_read_o<=1'b1;
                instvalid = `inst_invalid;
            end
            default: begin
                    
                end
            endcase
        end
        `J:begin
	  		wreg_o <= `WriteDisable;		
            aluop_o <= `EXE_NOP_OP;
	  		alusel_o <= `EXE_RES_NOP; 
            reg1_read_o <= 1'b0;	
            reg2_read_o <= 1'b0;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;		  	
			instvalid <= `inst_invalid;	
        end
        `BEQ:begin
		  	wreg_o <= `WriteDisable;		
            aluop_o <= `EXE_NOP_OP;
		  	alusel_o <= `EXE_RES_NOP; 
            reg1_read_o <= 1'b1;	
            reg2_read_o <= 1'b1;
		  	instvalid <= `inst_invalid;	
		  	if(reg1_o == reg2_o) begin
			    branch_target_address_o <= pc_plus_4 + beq_target;
			    branch_flag_o <= `Branch;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			end
        end
        `LW:begin
            wreg_o<=1'b1;
            wd_o<=inst_i[20:16];
            aluop_o<= `LW_OP;
            alusel_o<=`EXE_RES_LW;
            reg1_read_o<=1'b1;
            reg2_read_o<=1'b0;
            imm<={{16{inst_i[15]}},inst_i[15:0]};
            instvalid = `inst_valid;
        end
        `LOGIC:begin
            case (op3)
                `fun_OR:begin
                    wreg_o<= 1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`EXE_OR_OP;
                    alusel_o<=`EXE_RES_LOGIC;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`inst_valid;
                end 
                `fun_AND:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`AND_OP;
                    alusel_o<=`EXE_RES_LOGIC;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`inst_valid;
                end
                `fun_XOR:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`XOR_OP;
                    alusel_o<=`EXE_RES_LOGIC;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`inst_valid;
                end
                `fun_NOR:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`NOR_OP;
                    alusel_o<=`EXE_RES_LOGIC;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`inst_valid;
                end
                `fun_SLL:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`SLL_OP;
                    alusel_o<=`EXE_RES_SHIFT;
                    reg1_read_o<=1'b0;
                    reg2_read_o<=1'b1;
                    imm<={27'b0,sa};
                    instvalid<=`inst_valid;
                end
                `fun_SRL:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`SRL_OP;
                    alusel_o<=`EXE_RES_SHIFT;
                    reg1_read_o<=1'b0;
                    reg2_read_o<=1'b1;
                    imm<={27'b0,sa};
                    instvalid<=`inst_valid;
                end
                `fun_SRA:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`SRA_OP;
                    alusel_o<=`EXE_RES_SHIFT;
                    reg1_read_o<=1'b0;
                    reg2_read_o<=1'b1;
                    imm<={27'b0,sa};
                    instvalid<=`inst_valid;
                end
                `fun_ADD:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`ADD_OP;
                    alusel_o<=`EXE_RES_MATH;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`inst_valid;
                end
                `fun_SUB:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`SUB_OP;
                    alusel_o<=`EXE_RES_MATH;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`inst_valid;
                end
                `fun_SLT:begin
                    wreg_o<=1'b1;
                    wd_o<=inst_i[15:11];
                    aluop_o<=`SLT_OP;
                    alusel_o<=`EXE_RES_MATH;
                    reg1_read_o<=1'b1;
                    reg2_read_o<=1'b1;
                    instvalid<=`inst_valid;
                end
                `fun_JR:begin
					wreg_o <= `WriteDisable;		
                    aluop_o <= `EXE_NOP_OP;
		  			alusel_o <= `EXE_RES_NOP;   
                    reg1_read_o <= 1'b1;	
                    reg2_read_o <= 1'b0;
		  			link_addr_o <= `ZeroWord;//返回地址		
			        branch_target_address_o <= reg1_o;
			        branch_flag_o <= `Branch;
			        next_inst_in_delayslot_o <= `InDelaySlot;
			        instvalid <= `inst_invalid;
                end
                default: begin
                end
            endcase
        end
        default: begin
        end
    endcase
        
    end 
end

//给reg1_o赋值的过程增加了两种情况;
//1．如果 Regfile模块读端口1要读取的寄存器就是执行阶段要写的目的寄存器,
//那么直接把执行阶段的结果ex _wdata i作为reg1_o的值;
//2．如果Regfile模块读端口1要读取的寄存器就是访存阶段要写的目的寄存器，
//那么直接把访存阶段的结果mem wdata i作为reg1 o的值;


//-----------确定源操作数1------------------------
always @(*)begin
    if(rst ==`RstEnable) begin
        reg1_o<=`ZeroWord;
    end else if ((reg1_read_o == 1'b1)&&(ex_wreg_i == 1'b1)
                    &&(ex_wd_i == reg1_addr_o)) begin
        reg1_o<=ex_wdata_i;
    end else if((reg1_read_o == 1'b1)&&(mem_wreg_i == 1'b1)
                    &&(mem_wd_i == reg1_addr_o)) begin
        reg1_o<=mem_wdata_i;
    end else if(reg1_read_o==1'b1)begin
        reg1_o <= reg1_data_i;// Regfile读端口1的输出值
    end else if(reg1_read_o == 1'b0) begin
        reg1_o <= imm;//立即数
    end else begin
        reg1_o <= `ZeroWord;
    end
end
//--------------确定源操作数2--------------
always @(*)begin
    if(rst ==`RstEnable) begin
        reg2_o<=`ZeroWord;
    end else if ((reg2_read_o == 1'b1)&&(ex_wreg_i == 1'b1)
                    &&(ex_wd_i == reg2_addr_o)) begin
        reg2_o<=ex_wdata_i;
    end else if((reg2_read_o == 1'b1)&&(mem_wreg_i == 1'b1)
                    &&(mem_wd_i == reg2_addr_o)) begin
        reg2_o<=mem_wdata_i;
    end else if(reg2_read_o==1'b1)begin
        reg2_o <= reg2_data_i;// Regfile读端口1的输出值
    end else if(reg2_read_o == 1'b0) begin
        reg2_o <= imm;//立即数
    end else begin
        reg2_o <= `ZeroWord;
    end
end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 20:39:13
// Design Name: 
// Module Name: openmips
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

module mips(
    input wire clk,rst,
    input wire[`reg_bus] rom_data_i,
    output wire[`reg_bus] rom_addr_o,
    output wire rom_ce_o
    );
    //连接IF/ID模块与译码阶段ID模块的变量
    wire[`inst_addr_bus] pc;
    wire[`inst_addr_bus] id_pc_i;
    wire[`inst_bus] id_inst_i;
    //连接译码阶段工D模块输出与ID/EX模块的输入的变量
    wire[`alu_op_bus] id_aluop_o;
    wire[`alu_sel_bus]id_alusel_o;
    wire[`reg_bus] id_reg1_o;
    wire[`reg_bus]id_reg2_o;
    wire id_wreg_o;
    wire[`reg_addr_bus] id_wd_o;
	wire id_is_in_delayslot_o;
    wire[`reg_bus] id_link_address_o;	
    //连接ID/Ex模块输出与执行阶段EX模块的输入的变量
    wire[`alu_op_bus] ex_aluop_i;
    wire[`alu_sel_bus] ex_alusel_i;
    wire[`reg_bus] ex_reg1_i;
    wire[`reg_bus] ex_reg2_i;
    wire ex_wreg_i;
    wire[`reg_addr_bus] ex_wd_i;
	wire ex_is_in_delayslot_i;	
    wire[`reg_bus] ex_link_address_i;
    //连接执行阶段EX模块的输出与EX/MEM模块的输入的变量
    wire ex_wreg_o;
    wire[`reg_addr_bus]ex_wd_o;
    wire[`reg_bus] ex_wdata_o;
    //连接EX/MEM模块的输出与访存阶段 MEM模块的输入的变量
    wire mem_wreg_i;
    wire[`reg_addr_bus] mem_wd_i;
    wire[`reg_bus] mem_wdata_i;
    //连接访存阶段MEM模块的输出与MEM/WB模块的输入的变量
    wire mem_wreg_o;
    wire[`reg_addr_bus] mem_wd_o;
    wire[`reg_bus] mem_wdata_o;
    //连接MEM/WB模块的输出与回写阶段的输入的变量
    wire wb_wreg_i;
    wire[`reg_addr_bus] wb_wd_i;
    wire[`reg_bus] wb_wdata_i;
    //连接译码阶段ID模块与通用寄存器Regfile模块的变量
    wire reg1_read;
    wire reg2_read;
    wire [`reg_bus] reg1_data;
    wire[`reg_bus] reg2_data;
    wire[`reg_addr_bus] reg1_addr;
    wire [`reg_addr_bus]reg2_addr;
	wire id_branch_flag_o;
	wire[`reg_bus] branch_target_address;

	wire[5:0] stall;
	wire stallreq_from_id;	
	wire stallreq_from_ex;
    wire read_ena;
	wire[`reg_bus]read_data;
    wire[`reg_bus]mem_addr;
    // pc_reg例化
    // module pc_reg(
    // input rst,
    // input clk,
    // output reg[`inst_addr_bus] pc,
    // output reg      ce//使能信号
    // );
    pc_reg pc_reg0(
    .clk(clk), 
    .rst(rst),
    .pc(pc), 
	.stall(stall),
    .branch_flag_i(id_branch_flag_o),
    .branch_target_address_i(),
    .ce(rom_ce_o));
    assign rom_addr_o = pc;//指令存储器的输入地址就是pc的值
    //IF/ID模块例化
    // module if_id(
    // input rst,
    // input clk,
    // input [`inst_addr_bus] if_pc,
    // input [`inst_bus] if_inst,
    // output reg[`inst_addr_bus] id_pc,
    // output reg[`inst_bus] id_inst
    // );
    if_id if_id0(
    .clk(clk),
    .rst(rst),
	.stall(stall),
    .if_pc(pc),
    .if_inst(rom_data_i),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
    ) ;
    //译码阶段ID模块例化
    // module id(
    // input wire rst,
    // input wire[`inst_addr_bus] pc_i,
    // input wire[ `inst_bus] inst_i,

    // //读取的Regfile的值
    // input wire[`reg_bus] reg1_data_i,
    // input wire[`reg_bus] reg2_data_i,
    // //输出到Regfile的信息
    // output reg reg1_read_o,
    // output reg reg2_read_o,
    // output reg[`reg_addr_bus] reg1_addr_o,
    // output reg[`reg_addr_bus] reg2_addr_o,
    // //送到执行阶段的信息
    // output reg[`alu_op_bus] aluop_o,
    // output reg[`alu_sel_bus] alusel_o,
    // output reg[`reg_bus] reg1_o,
    // output reg[`reg_bus] reg2_o,
    // output reg[`reg_addr_bus] wd_o,
    // output reg wreg_o
    // );
    id id0(
    .rst(rst),
    .pc_i(id_pc_i) ,
    .inst_i(id_inst_i),
    //来自 Regfile模块的输入
    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),
	//处于执行阶段的指令要写入的目的寄存器信息
	.ex_wreg_i(ex_wreg_o),
	.ex_wdata_i(ex_wdata_o),
	.ex_wd_i(ex_wd_o),

	//处于访存阶段的指令要写入的目的寄存器信息
	.mem_wreg_i(mem_wreg_o),
	.mem_wdata_i(mem_wdata_o),
	.mem_wd_i(mem_wd_o),

	.is_in_delayslot_i(is_in_delayslot_i),
    //送到regfile模块的信息
    .reg1_read_o(reg1_read),
    .reg2_read_o (reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),
    //送到ID/EX模块的信息
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),
	.next_inst_in_delayslot_o(next_inst_in_delayslot_o),	
	.branch_flag_o(id_branch_flag_o),
	.branch_target_address_o(branch_target_address),       
	.link_addr_o(id_link_address_o),
		
	.is_in_delayslot_o(id_is_in_delayslot_o),
		
	.stallreq(stallreq_from_id)	
    );
    //通用寄存器Regfile模块例化
    // module regfile(
    // input rst,clk,we,re1,re2,
    // input [`reg_addr_bus] waddr,raddr1,raddr2,
    // input [`reg_bus] wdata,
    // output [`reg_bus] rdata1,rdata2
    // );
    regfile regfile1(
    .clk (clk) ,
    .rst (rst),
    .we (wb_wreg_i),
    .waddr (wb_wd_i) ,
    .wdata (wb_wdata_i),
    .re1(reg1_read) ,
    .raddr1(reg1_addr) ,
    .rdata1(reg1_data) ,
    .re2(reg2_read) ,
    .raddr2(reg2_addr),
    .rdata2(reg2_data)
    );
    // ID/EX模块例化
    // module id_ex(
    // input wire clk,
    // input wire rst,
    // //从译码阶段传递过来的信息
    // input wire[ `alu_op_bus] id_aluop,
    // input wire[ `alu_sel_bus] id_alusel,
    // input wire[ `reg_bus] id_reg1,
    // input wire[ `reg_bus] id_reg2,
    // input wire[ `reg_addr_bus] id_wd,
    // input wire id_wreg,
    // //传递到执行阶段的信息
    // output reg[`alu_op_bus] ex_aluop,
    // output reg[ `alu_sel_bus] ex_alusel,
    // output reg[ `reg_bus] ex_reg1,
    // output reg[ `reg_bus] ex_reg2,
    // output reg [ `reg_addr_bus] ex_wd,
    // output reg ex_wreg
    // );
    id_ex id_ex0(
    .clk(clk),
    .rst(rst),
	.stall(stall),
    //从译码阶段ID模块传递过来的信息
    .id_aluop(id_aluop_o), 
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o) ,
    .id_reg2 (id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
	.id_link_address(id_link_address_o),
	.id_is_in_delayslot(id_is_in_delayslot_o),
	.next_inst_in_delayslot_i(next_inst_in_delayslot_o),
    //传递到执行阶段EX模块的信息
    .ex_aluop(ex_aluop_i),
    .ex_alusel (ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
	.ex_link_address(ex_link_address_i),
  	.ex_is_in_delayslot(ex_is_in_delayslot_i),
	.is_in_delayslot_o(is_in_delayslot_i)
    );
    //EX模块例化
    // module ex(
    // input wire rst,
    // //译码阶段送到执行阶段的信息
    // input wire[`alu_op_bus] aluop_i,
    // input wire[`alu_sel_bus] alusel_i,
    // input wire[`reg_bus] reg1_i,
    // input wire[`reg_bus] reg2_i,
    // input wire[`reg_addr_bus] wd_i,
    // input wire wreg_i,
    // //执行的结果
    // output reg[`reg_addr_bus] wd_o,
    // output reg wreg_o,
    // output reg[`reg_bus] wdata_o
    // );
    ex ex0(
    .rst(rst),
    //从ID/EX模块传递过来的的信息
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    //输出到EX/MEM模块的信息
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .link_address_i(ex_link_address_i),
	.is_in_delayslot_i(ex_is_in_delayslot_i),	
	.stallreq(stallreq_from_ex),
    .read_ena(read_ena),
    .data_mem_addr(mem_addr)  
    );
    //访存
    blk_mem_gen_0 data_mem (
        .clka(clk),    // input wire clka
        .ena(read_ena),      // input wire ena
        .addra(mem_addr[9:0]),  // input wire [9 : 0] addra
        .douta(read_data)  // output wire [31 : 0] douta
        );
    //EX/MEM模块例化
    ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
	.stall(stall),
    //来自执行阶段Ex模块的信息
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    //送到访存阶段 MEM模块的信息
    .mem_wd (mem_wd_i),
    .mem_wreg (mem_wreg_i),
    .mem_wdata (mem_wdata_i)
    );
    //MEM模块例化
    mem mem0(
    .rst (rst),
    .clk(clk),
    .read_ena(read_ena),
    .read_data(read_data),
    //来自EX/MEM模块的信息
    .wd_i (mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i (mem_wdata_i),
    //送到MEM/WB模块的信息
    .wd_o(mem_wd_o),
    .wreg_o (mem_wreg_o),
    .wdata_o(mem_wdata_o)
    );
    //MEM/WB模块例化
    mem_wb mem_wb0(
    .clk(clk) ,
    .rst(rst),
    .stall(stall),
    //来自访存阶段MEM模块的信息
    .mem_wd (mem_wd_o) ,
    .mem_wreg(mem_wreg_o),
    . mem_wdata (mem_wdata_o),
    //送到回写阶段的信息
    .wb_wd (wb_wd_i),
    .wb_wreg(wb_wreg_i) ,
    .wb_wdata(wb_wdata_i)
    );
	ctrl ctrl0(
	.rst(rst),
	.stallreq_from_id(stallreq_from_id),
	
  	//来自执行阶段的暂停请求
    .stallreq_from_ex(stallreq_from_ex),

	.stall(stall)       	
	);
endmodule


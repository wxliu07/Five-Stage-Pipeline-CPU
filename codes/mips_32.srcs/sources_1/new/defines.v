
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 11:01:38
// Design Name: 
// Module Name: defines
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

//全局宏定义
`define RstEnable       1'b1
`define RstDisable      1'b0
`define ZeroWord        32'h00000000
`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0
`define alu_op_bus      7:0
`define alu_sel_bus     2:0
`define inst_valid      1'b0
`define inst_invalid    1'b1
`define True_v          1'b1
`define False_v         1'b0
`define ChipEnable      1'b1
`define ChipDisable     1'b0


//流水线暂停
`define Stop            1'b1
`define NoStop          1'b0

//分支
`define Branch          1'b1
`define NoBranch        1'b0
`define NotInDelaySlot  1'b0//在延迟槽
`define InDelaySlot     1'b1//不在延迟槽

//op
`define EXE_ORI         6'b001101//位扩展16->32
`define EXE_NOP         6'b000000//空指令
`define ANDI            6'b001100
`define XORI            6'b001110
`define LOGIC           6'b000001
`define ADDI            6'b001000
`define MUL             6'b011100//special2?
`define J               6'b000010
`define BEQ             6'b000100
`define LW              6'b100011


//r_func
`define fun_AND         6'b000001
`define fun_OR          6'b000010
`define fun_XOR         6'b000011
`define fun_NOR         6'b000100
`define fun_SLL         6'b000101
`define fun_SRL         6'b000110
`define fun_SRA         6'b000111
`define fun_ADD         6'b001000
`define fun_SUB         6'b001001
`define fun_SLT         6'b001010
`define fun_MUL         6'b001011
`define fun_DIV         6'b001100
`define fun_JR          6'b001101
//ALUOP
`define EXE_OR_OP       8'b00100101
`define EXE_NOP_OP      8'b00000000
`define AND_OP          8'b00000001
`define XOR_OP          8'b00000010
`define NOR_OP          8'b00000011
`define SLL_OP          8'b00000100
`define SRL_OP          8'b00000101
`define SRA_OP          8'b00000110
`define ADD_OP          8'b00000111
`define SUB_OP          8'b00001000
`define SLT_OP          8'b00001001
`define MUL_OP          8'b00001010
`define DIV_OP          8'b00001011
`define LW_OP           8'b00001100

//ALUSEL
`define EXE_RES_LOGIC            3'b001
`define EXE_RES_NOP             3'b000
`define EXE_RES_SHIFT           3'b010
`define EXE_RES_MATH            3'b011
`define EXE_RES_JUMP_BRANCH     3'b100
`define EXE_RES_LW               3'b101

//存储器相关宏定义
`define inst_addr_bus   31:0        //地址总线宽度
`define inst_bus        31:0        //数据总线宽度
`define inst_mem_num    131071      //ROM的实际大小为128KB
`define inst_mem_numlog2 17         //rom实际使用的地址线宽度
`define reg_addr_bus    4:0
`define reg_bus         31:0
`define reg_width       32
`define double_reg_width 64
`define double_reg_bus  63:0
`define reg_num         32
`define reg_num_log2    32          //寻址通用寄存器所用的地址位数
`define NOP_reg_addr    5'b00000







`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/27 00:56:02
// Design Name: 
// Module Name: mips_and_rom
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
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 23:05:03
// Design Name: 
// Module Name: openmips_min_sopc
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


module mips_and_rom(
    input wire clk,
    input wire rst,
    output wire[15:0]led
    );
    //连接指令存储器
    wire[ `inst_addr_bus] inst_addr;
    wire[ `inst_bus] inst;
    wire rom_ce;
    //例化处理器MIPS
    mips mips0(
    .clk(clk),
    .rst(rst),
    .rom_addr_o(inst_addr), 
    .rom_data_i(inst),
    .rom_ce_o(rom_ce)
    );
    //例化指令存储器ROM
    inst_rom inst_rom0(
    .ce(rom_ce),
    .addr (inst_addr),
    .inst(inst)
    );
    assign led = inst[31:16];
endmodule


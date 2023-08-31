`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 22:38:08
// Design Name: 
// Module Name: inst_rom
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

module inst_rom(
    input wire ce,
    input wire[`inst_addr_bus] addr,
    output reg[`inst_bus] inst
    );
    reg[`inst_bus] inst_mem[0:`inst_mem_num];
    //E:\\MIPS_CPU\\inst_rom.txt
    //E:\\MIPS_CPU\\op_test\\op.txt
    initial $readmemh("E:\\MIPS_CPU\\inst_rom.txt ",inst_mem);
    always @(*)begin
    if(ce == `ChipDisable) begin
    inst<=`ZeroWord;
    end else begin
    inst <= inst_mem [addr[ `inst_mem_numlog2+1:2]];end
    end

endmodule

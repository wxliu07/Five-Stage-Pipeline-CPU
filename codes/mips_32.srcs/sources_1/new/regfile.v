`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/23 11:56:12
// Design Name: 
// Module Name: regfile
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

module regfile(
    input rst,clk,we,re1,re2,
    input [`reg_addr_bus] waddr,raddr1,raddr2,
    input [`reg_bus] wdata,
    output reg[`reg_bus] rdata1,rdata2
    );
    reg [`reg_bus] regs[0:`reg_num];
    initial begin
        regs[0]<= 32'b0;
    end
    always @(posedge clk ) begin
        if(rst == `RstDisable)begin
            if((we == `WriteEnable)&& (waddr !=`reg_num_log2'h0))begin
                regs[waddr]<= wdata;
            end
        end
    end
    always @(*) begin
        if(rst == `RstEnable)begin
            rdata1<= `ZeroWord;
        end 
        else if(raddr1 == `reg_num_log2'h0)begin
            rdata1<= `ZeroWord;
        end
        else if((raddr1 == waddr)&&(we == `WriteEnable)
                    &&(re1 == `ReadEnable))begin
            rdata1<= wdata;
        end
        else if(re1 == `ReadEnable)begin
            rdata1<= regs[raddr1];
        end
        else begin
            rdata1 <= `ZeroWord;
        end
    end


    always @(*) begin
        if(rst == `RstEnable)begin
            rdata2<= `ZeroWord;
        end 
        else if(raddr2 == `reg_num_log2'h0)begin
            rdata2<= `ZeroWord;
        end
        else if((raddr2 == waddr)&&(we == `WriteEnable)
                    &&(re2 == `ReadEnable))begin
            rdata2<= wdata;
        end
        else if(re2 == `ReadEnable)begin
            rdata2<= regs[raddr2];
        end
        else begin
            rdata2 <= `ZeroWord;
        end
    end
endmodule

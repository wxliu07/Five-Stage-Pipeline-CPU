`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/26 19:31:04
// Design Name: 
// Module Name: textbench
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
module textbench(
        input clk,
 	 	input rst_n,
        output wire[15:0] led
        );
       wire clk_bps;
	 	wire rst;
	 	assign rst = ~rst_n;
  counter counter(
	 		.clk( clk ),
	 		.rst( rst ),
	 		.clk_bps( clk_bps )
	 	);
//   reg     CLOCK_50;
//   reg     rst;
//   initial begin
//     CLOCK_50 = 1'b0;
//     forever #10 CLOCK_50 = ~CLOCK_50;
//   end
      
//   initial begin
//     rst = `RstEnable;
//     #195 rst= `RstDisable;
//     #1000 $stop;
//   end


  mips_and_rom mips_and_rom0(
		.clk(clk_bps),
		.rst(rst)	,
    .led(led)
	);
endmodule

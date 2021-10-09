`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 10:51:19
// Design Name: 
// Module Name: mem_inst
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

// INSTRUCTION MEMORY MODULE

module mem_inst (
	input						rst,
	input						clk,
	input			[31:0]	pc,
	output reg	[31:0]	instr
);

reg	[31:0]	RAM	[31:0];

always @(posedge clk or posedge rst) begin
	if (rst) begin
		$readmemh("prog.s", RAM);
		instr <= RAM[pc];
	end
	else
		instr <= RAM[pc];		
end

endmodule

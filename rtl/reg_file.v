`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 10:26:51
// Design Name: 
// Module Name: mem16_20
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

// REGISTRY FILE

module reg_file (
	input						rst,
	input						clk,
	input			[5:0]		ra1,
	input			[5:0]		ra2,
	input			[5:0]		wa,
	input			[31:0]	wd,
	input						we,
	output reg	[31:0]	rd1,
	output reg	[31:0]	rd2
);

reg	[16 : 0]	REG	[31 : 0];

always @(posedge clk or posedge rst) begin
	if (rst)
		$readmemh("reg.s", REG);
	else begin
		if (we && wa != 3'b000)
			REG[wa] <= wd;
		rd1 <= REG[ra1];
		rd2 <= REG[ra2];
	end
end

endmodule

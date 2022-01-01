`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 10:26:51
// Design Name: RISC-V
// Module Name: mem16_20
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//   module implements 32 registers 32 bit each in 3-port registry file and can
//   store 32 bit value to register by its address and read two 32 bit values by
//   their addresses
// Parameters:
//   rst   - reset signal
//   clk   - clock signal
//   ra1	  - 5 bit address of first register to read
//   ra2   - 5 bit address of second register to read
//   wa    - 5 bit address for register to write
//   we    - flag that allows writing to register
//   rd1   - 32 bit return value that stores in register with address `ra1`
//   rd2   - 32 bit return value that stores in register with address `ra2`
//
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module reg_file (
	input						rst,
	input						clk,
	input			[4:0]		ra1,
	input			[4:0]		ra2,
	input			[4:0]		wa,
	input			[31:0]	wd,
	input						we,
	output 		[31:0]	rd1,
	output 		[31:0]	rd2
);

reg	[31 : 0]	REG	[0:31];

assign rd1 = REG[ra1];
assign rd2 = REG[ra2];

always @(posedge clk or posedge rst) begin
	if (rst)
		$readmemh("../../../../../rtl/reg.bin", REG);
	else begin
		if (we && wa != 3'b000)
			REG[wa] <= wd;
	end
end

endmodule

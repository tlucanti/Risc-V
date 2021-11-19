`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 10:51:19
// Design Name: RISC-V
// Module Name: mem_inst
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//   Module reads 32 bit instructions from file `prog.s` in hex
//   format and stores them in 1024 bit readonly RAM
// Parameters:
//   rst   - reset signal
//   clk   - clock signal
//   pc    - program counter: number of current instruction to return
//   instr - return value of 32 bit instruction with index equals `pc`
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mem_inst (
	input						rst,
	input						clk,
	input			[31:0]	pc,
	output		[31:0]	instr
);

reg	[31:0]	RAM	[255:0];
always @(posedge clk or posedge rst) begin
	if (rst) begin
		$readmemb("../../../../../rtl/prog.bin", RAM);
	end
end

assign instr = RAM[pc];

endmodule

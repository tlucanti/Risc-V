`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 11:05:30
// Design Name: 
// Module Name: risk-5
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


module risk_5 (
	input			rst,
	input			clk,
	input	[8:0]	sw
);

wire	[31:0]	instr;
wire	[19:0]	op1;
wire	[19:0]	op2;
wire			flag;
reg		[31:0]	wd;
wire	[31:0]	alu;

reg	[31:0]	pc;

mem_inst INSTRUCTION (
	.rst		(rst),
	.clk		(clk),
	.pc		(pc),
	.instr	(instr)
);

reg_file REG_FILE (
	.rst		(rst),
	.clk		(clk),
	.ra1		(instr[22:18]),
	.ra2		(instr[17:13]),
	.wa		(instr[12:8]),
	.wd		(wd),
	.we		(instr[29]),
	.rd1		(op1),
	.rd2		(op2)
);

miriscv_alu	ALU (
	.operator_i					(instr[26:23]),
	.operand_a_i				(op1),
	.operand_b_i				(op2),
	.result_o					(alu),
	.comparison_result_o		(flag)
);

always @(posedge clk) begin
	if (rst) begin
		pc <= 4'b0;
	end
	else begin
		pc <= pc + ((instr[31]) | ((instr[30]) & (flag))) ? (31'b0 | instr[7:0]) : (31'b1);
		case (instr[28:27])
			2'b00: wd <= 32'h00_00_00_00 | instr[7:0];
			2'b01: wd <= sw;
			2'b10: wd <= alu;
		endcase;
	end
end

endmodule

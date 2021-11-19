`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 09:33:53
// Design Name: RISC-V
// Module Name: miriscv_alu
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   async module
//   Module takes two 32 bit numbers - do operation with them and returns 32 bit
//   result of computatuin
// Parameters:
//   operator_i  - index of ALU operation to be done
//   operand_a_i - first (left) operand of compution
//   operand_b_i - second (right) operand of compution
//   result_o    - result of compution
//   flag_o      - result flag of comparison
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`define ALU_OP_WIDTH 4
`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_XOR 4'b0010
`define ALU_OR  4'b0011
`define ALU_AND 4'b0100
`define ALU_SRA 4'b0101
`define ALU_SRL 4'b0110
`define ALU_SLL 4'b0111
`define ALU_LTS 4'b1000
`define ALU_LTU 4'b1001
`define ALU_GES 4'b1010
`define ALU_GEU 4'b1011
`define ALU_EQ  4'b1100
`define ALU_NE  4'b1101

module miriscv_alu (
	input			[`ALU_OP_WIDTH-1:0]	operator_i,
	input			[31:0]					operand_a_i,
	input			[31:0]					operand_b_i,
	output 		[31:0]					result_o,
	output 									flag_o
);

assign result_o = alu_solve(operator_i, operand_a_i, operand_b_i);
assign flag_o = alu_compare(operator_i, operand_a_i, operand_b_i);

function [31:0] alu_solve(
	input [`ALU_OP_WIDTH-1:0] operator_i,
	input [31:0] operand_a_i,
	input [31:0] operand_b_i
);
	case (operator_i)
		`ALU_ADD: alu_solve = operand_a_i  +  operand_b_i;
		`ALU_SUB: alu_solve = operand_a_i  -  operand_b_i;
		`ALU_XOR: alu_solve = operand_a_i  ^  operand_b_i;
		`ALU_OR : alu_solve = operand_a_i  |  operand_b_i;
		`ALU_AND: alu_solve = operand_a_i  &  operand_b_i;
		`ALU_SRL: alu_solve = operand_a_i >>  operand_b_i;
		`ALU_SLL: alu_solve = operand_a_i <<  operand_b_i;
		`ALU_LTU: alu_solve = operand_a_i  <  operand_b_i;
		`ALU_GEU: alu_solve = operand_a_i >=  operand_b_i;
		`ALU_EQ : alu_solve = operand_a_i ==  operand_b_i;
		`ALU_NE : alu_solve = operand_a_i !=  operand_b_i;
		`ALU_SRA: alu_solve = $signed(operand_a_i) >>> $signed(operand_b_i);
		`ALU_LTS: alu_solve = $signed(operand_a_i)  <  $signed(operand_b_i);
		`ALU_GES: alu_solve = $signed(operand_a_i) >=  $signed(operand_b_i);
	endcase
endfunction

function [31:0] alu_compare(
	input [`ALU_OP_WIDTH-1:0] operator_i,
	input [31:0] operand_a_i,
	input [31:0] operand_b_i
);
	case (operator_i)
		`ALU_ADD: alu_compare = 0;
		`ALU_SUB: alu_compare = 0;
		`ALU_XOR: alu_compare = 0;
		`ALU_OR : alu_compare = 0;
		`ALU_AND: alu_compare = 0;
		`ALU_SRA: alu_compare = 0;
		`ALU_SRL: alu_compare = 0;
		`ALU_SLL: alu_compare = 0;
		`ALU_LTS: alu_compare = result_o;
		`ALU_LTU: alu_compare = result_o;
		`ALU_GES: alu_compare = result_o;
		`ALU_GEU: alu_compare = result_o;
		`ALU_EQ : alu_compare = result_o;
		`ALU_NE : alu_compare = result_o;
	endcase
endfunction

endmodule

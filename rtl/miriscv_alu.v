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
//   operator_i  - 5 bit index of ALU operation to be done
//   operand_a_i - 32 bit first (left) operand of compution
//   operand_b_i - 32 bit second (right) operand of compution
//   result_o    - 32 bit result of compution
//   flag_o      - result flag of comparison
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`include "miriscv_defines.v"

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

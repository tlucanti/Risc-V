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
// 
// Dependencies:
//   miriscv_defines.v
// 
// Revision: v1.1
//   v0.1 - file Created
//   v1.0 - done for stage-1
//   v2.0 - remade for RISC-V i32 instruction set
//   v2.1 - remastered comments and I/O
//   
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`include "miriscv_defines.v"

module miriscv_alu (operator_i, operand_a_i, operand_b_i, result_o, flag_o);

// ---------------------------------- ALU I/O ----------------------------------
input		[`ALU_OP_WIDTH-1:0]	operator_i;
/*
	operation code for computation

	will be used to do this operation between `operand_a_i` and `operand_b_i`
	and store result in	arithmetic (calculation) result `result_o` if operator_i
	is logic operation - `result_o` value will be copied to `flag_o`

	if `operator_i` is not one of valid 14 operations - values in `result_o` and
	`flag_o` are undefined
*/
input		[31:0]				operand_a_i;
/*
	first (left) arithmetic operand for compution

	will be used for compute operation `operator_i` and store result in
	arithmetic (calculation) result `result_o` and logic (comparison) result in
	`flag_o`
*/
input		[31:0]				operand_b_i;
/*
	second (right) arithmetic operand for compution

	will be used for compute operation `operator_i` and store result in
	arithmetic (calculation) result `result_o` and logic (comparison) result in
	`flag_o`
*/
output 		[31:0]				result_o;
/*
	result of arithmetic computation between `operand_a_i` and `operand_b_i`
	for `operator_i` operation
*/
output 							flag_o;
/*
	logic comparison flag `operand_a_i` and `operand_b_i` for `operator_i` operation

	if `operator_i` is comparison operation - `flag_o` equals `result_o`, else
	`flag_o` equals zero
*/

// =============================================================================
// -------------------------------- WIRE ASSIGNS -------------------------------
assign	result_o	= alu_solve(operator_i, operand_a_i, operand_b_i);
assign	flag_o		= alu_compare(operator_i, operand_a_i, operand_b_i);

// --------------------------------- FUNCTIONS ---------------------------------
function automatic [31:0] alu_solve;
/*
	main function that performs decoding `operator_i` and returning result of
	computation
*/
	input [`ALU_OP_WIDTH-1:0] operator_i;
	input [31:0] operand_a_i;
	input [31:0] operand_b_i;

	begin
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
	end
endfunction

function automatic [31:0] alu_compare;
/*
	main function that performs decoding `operator_i` and returning result of
	comparison if `operator_i` is logic operation, and returning zero if
	`operator_i` is arithmetic operation
*/
	input [`ALU_OP_WIDTH-1:0] operator_i;
	input [31:0] operand_a_i;
	input [31:0] operand_b_i;

	begin
		case (operator_i)
			`ALU_ADD: alu_compare = 32'b0;
			`ALU_SUB: alu_compare = 32'b0;
			`ALU_XOR: alu_compare = 32'b0;
			`ALU_OR : alu_compare = 32'b0;
			`ALU_AND: alu_compare = 32'b0;
			`ALU_SRA: alu_compare = 32'b0;
			`ALU_SRL: alu_compare = 32'b0;
			`ALU_SLL: alu_compare = 32'b0;
			`ALU_LTS: alu_compare = result_o;
			`ALU_LTU: alu_compare = result_o;
			`ALU_GES: alu_compare = result_o;
			`ALU_GEU: alu_compare = result_o;
			`ALU_EQ : alu_compare = result_o;
			`ALU_NE : alu_compare = result_o;
		endcase
	end
endfunction

endmodule

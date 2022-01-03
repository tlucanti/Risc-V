`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2021 09:33:53
// Design Name: 
// Module Name: miriscv_alu
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

`define ALU_OP_WIDTH 7
`define ALU_ADD 6'b011000
`define ALU_SUB 6'b011001
`define ALU_XOR 6'b101111
`define ALU_OR  6'b101110
`define ALU_AND 6'b010101
`define ALU_SRA 6'b100100
`define ALU_SRL 6'b100101
`define ALU_SLL 6'b100111
`define ALU_LTS 6'b000000
`define ALU_LTU 6'b000001
`define ALU_GES 6'b001010
`define ALU_GEU 6'b001011
`define ALU_EQ  6'b001100
`define ALU_NE  6'b001101

module miriscv_alu (
	input			[`ALU_OP_WIDTH-1:0]	operator_i,
	input			[32:0]					operand_a_i,
	input			[32:0]					operand_b_i,
	output reg	[32:0]					result_o,
	output reg								comparison_result_o
);

always @(*) begin
	case (operator_i)
		`ALU_ADD: result_o <= operand_a_i  +  operand_b_i;
		`ALU_SUB: result_o <= operand_a_i  -  operand_b_i;
		`ALU_XOR: result_o <= operand_a_i  ^  operand_b_i;
		`ALU_OR : result_o <= operand_a_i  |  operand_b_i;
		`ALU_AND: result_o <= operand_a_i  &  operand_b_i;
		`ALU_SRL: result_o <= operand_a_i >>  operand_b_i;
		`ALU_SLL: result_o <= operand_a_i <<  operand_b_i;
		`ALU_LTU: result_o <= operand_a_i  <  operand_b_i;
		`ALU_GEU: result_o <= operand_a_i >=  operand_b_i;
		`ALU_EQ : result_o <= operand_a_i ==  operand_b_i;
		`ALU_NE : result_o <= operand_a_i !=  operand_b_i;
		`ALU_SRA: result_o <= $signed(operand_a_i) >>> $signed(operand_b_i);
		`ALU_LTS: result_o <= $signed(operand_a_i)  <  $signed(operand_b_i);
		`ALU_GES: result_o <= $signed(operand_a_i) >=  $signed(operand_b_i);
	endcase
	case (operator_i)
		`ALU_ADD: comparison_result_o <= 0;
		`ALU_SUB: comparison_result_o <= 0;
		`ALU_XOR: comparison_result_o <= 0;
		`ALU_OR : comparison_result_o <= 0;
		`ALU_AND: comparison_result_o <= 0;
		`ALU_SRA: comparison_result_o <= 0;
		`ALU_SRL: comparison_result_o <= 0;
		`ALU_SLL: comparison_result_o <= 0;
		`ALU_LTS: comparison_result_o <= result_o;
		`ALU_LTU: comparison_result_o <= result_o;
		`ALU_GES: comparison_result_o <= result_o;
		`ALU_GEU: comparison_result_o <= result_o;
		`ALU_EQ : comparison_result_o <= result_o;
		`ALU_NE : comparison_result_o <= result_o;
	endcase
end

endmodule

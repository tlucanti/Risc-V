`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 11:05:30
// Design Name: RISC-V
// Module Name: risk-5
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//   module implements minimal RISC-V processor microarchitecture
// Parameters:
//   rst   - reset signal
//   clk   - clock signal
//   sw    - values from switches
//   ┌──┬──┬──┬─────┬───────────┬──────────────┬──────────────┬────────────┬───────────────┐
//   │31│30│29│28 27│26 25 24 23│22 21 20 19 18│17 16 15 14 13│12 11 10 9 8│7 6 5 4 3 2 1 0│
//   └┬─┴┬─┴┬─┴┬────┴┬──────────┴┬─────────────┴┬─────────────┴┬───────────┴┬──────────────┘
//    │  │  │  │     │           │              │              │            └─ [const] 8 bit Immidiate value 
//    │  │  │  │     │           │              │              └─ [WA] 6 bit address of the register in the register file
//    │  │  │  │     │           │              │                 where the record will be made
//    │  │  │  │     │           │              └─ [RA2] 6 bit address in register file for the second operand of the alu
//    │  │  │  │     │           └─ [RA1] 6 bit address in register file for the first operand of the alu
//    │  │  │  │     └─ [ALUop] the operation code to perform on the alu
//    │  │  │  │        alu operations:
//    │  │  │  │       ┌───────┬───────┬────────────────┐
//    │  │  │  │       │op-code│op-name│op-visualisation│
//    │  │  │  │       ├───────┼───────┼────────────────┤
//    │  │  │  │       │ 00000 │ALU_ADD│ x1 = x2  +  x3 │
//    │  │  │  │       │ 01000 │ALU_SUB│ x1 = x2  -  x3 │
//    │  │  │  │       │ 00100 │ALU_XOR│ x1 = x2  ^  x3 │
//    │  │  │  │       │ 00110 │ALU_OR │ x1 = x2  |  x3 │
//    │  │  │  │       │ 00111 │ALU_AND│ x1 = x2  &  x3 │
//    │  │  │  │       │ 01101 │ALU_SRA│ x1 = x2 >>> x3 │ (SIGNED OPERATION)
//    │  │  │  │       │ 00101 │ALU_SRL│ x1 = x2 >>  x3 │
//    │  │  │  │       │ 00001 │ALU_SLL│ x1 = x2 <<  x3 │
//    │  │  │  │       │ 11100 │ALU_LTS│ x1 = x2  <  x3 │ (SIGNED OPERATION)
//    │  │  │  │       │ 11110 │ALU_LTU│ x1 = x2  <  x3 │
//    │  │  │  │       │ 11101 │ALU_GES│ x1 = x2 >=  x  │ (SIGNED OPERATION)
//    │  │  │  │       │ 11111 │ALU_GEU│ x1 = x2 >=  x  │
//    │  │  │  │       │ 11000 │ALU_EQ │ x1 = x2 ==  x  │
//    │  │  │  │       │ 11001 │ALU_NE │ x1 = x2 !=  x  │
//    │  │  │  │       └───────┴───────┴────────────────┘
//    │  │  │  └─ [WS] data source for writing to a register file:
//    │  │  │     ┌────┬─────────────────────────┐
//    │  │  │     │ WS │ interpritation          │
//    │  │  │     ├────┼─────────────────────────┤
//    │  │  │     │ 00 │ constant from Immidiate │
//    │  │  │     │ 01 │ data from switches      │
//    │  │  │     │ 10 │ ALU result              │
//    │  │  │     │ 11 │ not set                 │
//    │  │  │     └────┴─────────────────────────┘
//    │  │  └─ [WE] premission to write to register file
//    │  └─ [C] if 1 - do codition jump
//    └─ [B] if 1 - do uncodition jump 
// 
// Dependencies: mem_inst.v reg_file.v mirisc_alu.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module risk_5 (
	input			rst,
	input			clk,
	input	[7:0]	sw
);

wire	[31:0]	instr;
wire	[31:0]	op1;
wire	[31:0]	op2;
wire				flag;
wire	[31:0]	wd;
wire	[31:0]	alu;

reg	[31:0]	pc;

mem_inst INSTRUCTION (
	.rst		(rst),	// reset
	.clk		(clk),	// clock
	.pc		(pc),		// 32 bit program counter
	.instr	(instr)	// 32 bit instruction
);

reg_file REG_FILE (
	.rst		(rst),				// reset
	.clk		(clk),				// clock
	.ra1		(instr[22:18]),	// 5 bit read address 1
	.ra2		(instr[17:13]),	// 5 bit read address 2
	.wa		(instr[12:8]),		// 5 bit write address
	.wd		(wd),					// 32 bit write data
	.we		(instr[29]),		// write enable
	.rd1		(op1),				// 32 bit read data 1
	.rd2		(op2)					// 32 bit read data 2
);

miriscv_alu	ALU (
	.operator_i		(instr[26:23]),	// 4 bit ALU operation
	.operand_a_i	(op1),				// 32 bit first (left) operand
	.operand_b_i	(op2),				// 32 bit second (righ) operand
	.result_o		(alu),				// 32 bit result of compution
	.flag_o			(flag)				// comparison flag
);

// assign wd = get_write_source(instr);
assign wd = instr[28] ? alu : (instr[27] ? sw : bit_extend(instr[7:0]));

always @(posedge clk) begin
	if (rst) begin
		pc <= 4'b0;
	end
	else begin
		if (instr[31] || (instr[30] && flag))	// jump instruction
			pc <= pc + bit_extend(instr[7:0]);	// add immidiate to program counter
		else
			pc <= pc + 31'b1;							// dont jump
	end
end

function [31:0] bit_extend(input [7:0] const);
	if (instr[7] == 1'b1) begin		// negative constant
		bit_extend = {24'b111111111111111111111111, instr[7:0]};
	end else begin							// positive constant
		bit_extend = {24'b000000000000000000000000, instr[7:0]};
	end
endfunction

function [31:0] get_write_source(input [31:0] instr);
case (instr[28:27])												// WS case
	2'b00: get_write_source = bit_extend(instr[7:0]);	// write const value to register
	2'b01: get_write_source = sw;								// write switches value to register
	2'b10: get_write_source = alu;							// write alu result to register
endcase
endfunction

endmodule

////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 20.11.2021 15:13:33
// Design Name: RISC-V
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   verilog header
//   contains defines for miriscv_decode module and other modules to use
//
// Dependencies: none
// 
// Revision: v1.1
//  - v1.0 - file Created
//  - v1.1 - add header
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`ifndef MIRISCV_DEFINES
`define MIRISCV_DEFINES

`define RESET_ADDR 32'h00000000

`define ALU_OP_WIDTH  5

// arithmetics
`define ALU_ADD   5'b00000		// a + b
`define ALU_SUB   5'b01000		// a - b

// bitwise
`define ALU_XOR   5'b00100		// a ^ b
`define ALU_OR    5'b00110		// a | b
`define ALU_AND   5'b00111		// a & b

// shifts
`define ALU_SRA   5'b01101		// a >>> b (signed)
`define ALU_SRL   5'b00101		// a >> b
`define ALU_SLL   5'b00001		// a << b

// comparisons
`define ALU_LTS   5'b11100		// a < b (signed)
`define ALU_LTU   5'b11110		// a < b
`define ALU_GES   5'b11101		// a >= b (signed)
`define ALU_GEU   5'b11111		// a >= b
`define ALU_EQ    5'b11000		// a == b
`define ALU_NE    5'b11001		// a != b

// set lower than operations
`define ALU_SLTS  5'b00010
`define ALU_SLTU  5'b00011

// opcodes
`define LOAD_OPCODE      5'b00_000
`define MISC_MEM_OPCODE  5'b00_011
`define OP_IMM_OPCODE    5'b00_100
`define AUIPC_OPCODE     5'b00_101
`define STORE_OPCODE     5'b01_000
`define OP_OPCODE        5'b01_100
`define LUI_OPCODE       5'b01_101
`define BRANCH_OPCODE    5'b11_000
`define JALR_OPCODE      5'b11_001
`define JAL_OPCODE       5'b11_011
`define FENCE_OPCODE     5'b00_011
`define SYSTEM_OPCODE    5'b11_100

// dmem type load store
`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101

// operand a selection
`define OP_A_RS1         2'b00
`define OP_A_CURR_PC     2'b01
`define OP_A_ZERO        2'b10

// operand b selection
`define OP_B_RS2         3'b000
`define OP_B_IMM_I       3'b001
`define OP_B_IMM_U       3'b010
`define OP_B_IMM_S       3'b011
`define OP_B_INCR        3'b100

// writeback source selection
`define WB_EX_RESULT     1'b0
`define WB_LSU_DATA      1'b1

`endif

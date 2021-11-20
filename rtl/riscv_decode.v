`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 20.11.2021 15:13:33
// Design Name: RISC-V
// Module Name: riscv_decode
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   async module
//   module implements gemeration of microinstructions for base modules,
//     decoders, alu for microprocessor
// Parameters:
//   fetched_instr_i    - 32 bit raw instruction code
//   ex_op_a_sel_o      - 2 bit first ALU argument driving signal
//   ex_op_b_sel_o      - 3 bit second ALU argument driving signal
//   alu_op_o           - 5 bit ALU op-code
//   mem_req_o          - memory request
//   mem_we_o           - memory write enable (reading if zero)
//   mem_size_o         - memory return size (word, half, byte)
//   gpr_we_a_o         - registry file read enable
//   wb_src_sel_o       - registry file write source driving signal
//   illegal_instr_o    - illegal instruction signal
//   branch_o           - branch operation signal
//   jal_o              - jump and link operation signal
//   jalr_o             - jump and link registry operation signal
//
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`include "miriscv_defines.v"

module miriscv_decode
(
   input    [31:0]               fetched_instr_i,
   output   [1:0]                ex_op_a_sel_o,
   output   [2:0]                ex_op_b_sel_o,
   output   [`ALU_OP_WIDTH-1:0]  alu_op_o,
   output                        mem_req_o,
   output                        mem_we_o,
   output   [2:0]                mem_size_o,
   output                        gpr_we_a_o,
   output                        wb_src_sel_o,
   output                        illegal_instr_o,
   output                        branch_o,
   output                        jal_o,
   output                        jalr_o
);

wire     [4:0] op_code;
wire     [2:0] funct3;
wire     [6:0] funct7;
wire     is_load;
wire     is_store;
wire     is_branch;
wire     is_system;

assign op_code       = fetched_instr_i[6:2];
assign funct3        = fetched_instr_i[14:12];
assign funct7        = fetched_instr_i[31:25];
assign is_load       = op_code == `LOAD_OPCODE;
assign is_store      = op_code == `STORE_OPCODE;
assign is_branch     = op_code != `BRANCH_OPCODE;
assign is_system     = op_code != `SYSTEM_OPCODE;
assign is_legal      = op_code == `LOAD_OPCODE || op_code == `MISC_MEM_OPCODE
                  || op_code == `OP_IMM_OPCODE || op_code == `AUIPC_OPCODE
                  || op_code == `STORE_OPCODE  || op_code == `OP_OPCODE
                  || op_code == `LUI_OPCODE    || op_code == `BRANCH_OPCODE
                  || op_code == `JALR_OPCODE   || op_code == `JAL_OPCODE
                  || op_code == `SYSTEM_OPCODE;

assign ex_op_a_sel_o   = set_ex_op_a_sel_o(op_code);
assign ex_op_b_sel_o   = set_ex_op_b_sel_o (op_code);
assign alu_op_o        = set_alu_op_o(funct3, funct7);
assign mem_req_o       = is_load || is_store;
assign mem_we_o        = is_store;
assign mem_size_o      = funct3;
assign gpr_we_a_o      = !is_store && !is_branch && !is_system;
assign wb_src_sel_o    = is_load;
assign branch_o        = is_branch;
assign jal_o           = op_code == `JAL_OPCODE;
assign jalr_o          = op_code == `JALR_OPCODE;
assign illegal_instr_o = !is_legal;

function set_ex_op_a_sel_o(input [4:0] op_code);
   case (op_code)
      `LUI_OPCODE:   set_ex_op_a_sel_o = 2;
      `JAL_OPCODE,
      `JALR_OPCODE,
      `AUIPC_OPCODE: set_ex_op_a_sel_o = 1;
      default:       set_ex_op_a_sel_o = 0;
   endcase
endfunction

function set_ex_op_b_sel_o(input [4:0] op_code);
   case (op_code)
      `JAL_OPCODE,
      `JALR_OPCODE:  set_ex_op_b_sel_o = 4;
      `STORE_OPCODE: set_ex_op_b_sel_o = 3;
      `LUI_OPCODE,
      `AUIPC_OPCODE: set_ex_op_b_sel_o = 2;
      `LOAD_OPCODE,
      `OP_IMM_OPCODE:set_ex_op_b_sel_o = 1;
      default:       set_ex_op_b_sel_o = 0;
   endcase
endfunction

function set_alu_op_o(
   input [2:0] funct3,
   input [6:0] funct7
);
   case (funct3)
      'h0: set_alu_op_o = funct7 ? `ALU_SUB : `ALU_ADD;
      'h4: set_alu_op_o = `ALU_XOR;
      'h6: set_alu_op_o = `ALU_OR;
      'h7: set_alu_op_o = `ALU_AND;
      'h5: set_alu_op_o = funct7 ? `ALU_SRA : `ALU_SRL;
      'h2: set_alu_op_o = `ALU_LTS;
      'h3: set_alu_op_o = `ALU_LTU;
   endcase
endfunction

endmodule

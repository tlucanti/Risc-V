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
//   mem_size_o         - 2 - bit memory return size
//                          000 - signed byte (8 bit)
//                          001 - signed half (16 bit)
//                          010 - word (32 bit)
//                          100 - unsigned byte (8 bit)
//                          101 - unsigned half (16 bit)
//   gpr_we_a_o         - registry file write enable
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
wire     alu_op;
wire     [3:0] op_code_no3;

assign op_code       = fetched_instr_i[6:2];
assign funct3        = fetched_instr_i[14:12];
assign funct7        = fetched_instr_i[31:25];
assign alu_op        = op_code_no3 == 4'b0100;
assign op_code_no6   = {op_code[3], op_code[2:0]};

assign ex_op_a_sel_o = ex_op_a_sel_o_set(op_code);
assign ex_op_b_sel_o = ex_op_b_sel_o_set(op_code);
assign alu_op_o      = alu_op_o_set(branch_o, alu_op, funct3, funct7[5]);
assign mem_req_o     = op_code_no3 == 4'b0000 & !illegal_instr_o;
assign mem_we_o      = op_code == `LOAD_OPCODE;
assign mem_size_o    = funct3;
assign gpr_we_a_o    = op_code[3:0] != 4'b1000 & !illegal_instr_o;
assign wb_src_sel_o  = mem_we_o;
assign branch_o      = op_code == `BRANCH_OPCODE;
assign jal_o         = op_code == `JAL_OPCODE;
assign jalr_o        = op_code == `JALR_OPCODE;

assign illegal_instr_o = 0;

function ex_op_a_sel_o_set (input [4:0] op_code);
   if (op_code[2:0] == 2'b00) begin
      ex_op_a_sel_o_set = 2'd0;
   end else if (op_code[3:2] == 2'b11) begin
      ex_op_a_sel_o_set = 2'd2;
   end else begin
      ex_op_a_sel_o_set = 2'd1;
   end
endfunction

function ex_op_b_sel_o_set (input [4:0] op_code);
   if (op_code == `STORE_OPCODE) begin
      ex_op_b_sel_o_set = 3'd3;
   end else if ({op_code[4], op_code[0]} == 2'b11) begin
      ex_op_b_sel_o_set = 3'd4;
   end else if (op_code[0]) begin
      ex_op_b_sel_o_set = 3'd2;
   end begin
      ex_op_b_sel_o_set = {0, 0, ~op_code[3]};
   end
endfunction

function alu_op_o_set (
   input branch_o,
   input alu_op,
   input [2:0] funct3,
   input f7,
);
   if (branch_o) begin
      alu_op_o = {2'b11, funct3};
   end else if (alu_op) begin
      alu_op_o = {1'b0, f7, funct3};
   end else begin
      alu_op_o = `ALU_ADD;
   end
endfunction


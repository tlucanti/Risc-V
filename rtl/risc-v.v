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
//   module implements RISC-V single tact processor microarchitecture
// Parameters:
//   RESET   - reset signal
//   CLK     - clock signal
//   SW      - values from switches
//
// Instruction types:
// - R-type: -------------------------------------------------------------------
//     instructions:
//       slli, srli, srai, add, sub, sll, slt, sltu, xor, srl, sra, or, ans
//
//    31    25 24    20 19    15 14    12 11     7 6      0
//   ┌┴──────┴┬┴──────┴┬┴──────┴┬┴──────┴┬┴──────┴┬┴──────┴┐
//   │ funct7 │   rs2  │   rs1  │ funct3 │   rd   │ opcode │              R-TYPE
//   └────────┴────────┴────────┴────────┴────────┴────────┘
// 
// - I-type: -------------------------------------------------------------------
//     instructions:
//       jalr, lb, lh, lw, lbu, lhu, addi, slti, sltiu, xori, ori, andi, fence,
//       ecall, ebreak
//
//    31                  20 19    15 14    12 11     7 6      0
//   ┌┴────────────────────┴┬┴──────┴┬┴──────┴┬┴──────┴┬┴──────┴┐
//   │       imm[11:0]      │  rs1   │ funct3 │   rd   │ opcode │         I-TYPE
//   └──────────────────────┴────────┴────────┴────────┴────────┘
// 
// - S-type: -------------------------------------------------------------------
//     instructions:
//       sb, sh, sw
//
//    31       25 24    20 19    15 14    12 11       7 6      0   
//   ┌┴─────────┴┬┴──────┴┬┴──────┴┬┴──────┴┬┴────────┴┬┴──────┴┐
//   │ imm[11:5] │   rs2  │   rs1  │ funct3 │ imm[4:0] │ opcode │         S-TYPE
//   └───────────┴────────┴────────┴────────┴──────────┴────────┘
//
// - B-type: -------------------------------------------------------------------
//     instructions:
//       beq, bne, blt, bge, bltu, bgeu
//
//    31          25 24    20 19    15 14    12 11          7 6      0   
//   ┌┴────────────┴┬┴──────┴┬┴──────┴┬┴──────┴┬┴───────────┴┬┴──────┴┐
//   │ imm[12|10:5] │   rs2  │   rs1  │ funct3 │ imm[4:1|11] │ opcode │   B-TYPE
//   └──────────────┴────────┴────────┴────────┴─────────────┴────────┘
// 
// - U-type: -------------------------------------------------------------------
//     instructions:
//       lui, auipc
//
//    31                                    12 11     7 6      0
//   ┌┴──────────────────────────────────────┴┬┴──────┴┬┴──────┴┐
//   │               imm[31:12]               │   rd   │ opcode │         U-TYPE
//   └────────────────────────────────────────┴────────┴────────┘
// 
// - J-type: -------------------------------------------------------------------
//     instructions:
//       jal
//
//    31                                    12 11     7 6      0
//   ┌┴──────────────────────────────────────┴┬┴──────┴┬┴──────┴┐
//   │          imm[20|10:1|11|19:12]         │   rd   │ opcode │         J-TYPE
//   └────────────────────────────────────────┴────────┴────────┘
// 
// Dependencies: mem_inst.v reg_file.v mirisc_alu.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module risk_5 (
    input           reset,
    input           clk,
    input   [7:0]   sw
);

wire            pc_do_branch;
/*

*/

wire            imm_I;
/*

*/
wire            imm_S;
/*

*/
wire            imm_J;
/*

*/
wire            imm_B;
/*

*/

// --------------------------------- ALU WIRES ---------------------------------
wire    [31:0]  alu_op1_i;
/*
    first operand for alu
*/
wire    [31:0]  alu_op2_i;
/*
    second operand for alu
*/
wire    [`ALU_OP_WIDTH - 1:0]   alu_opcode_i;
/*
    opcode for operation on alu
*/

wire            alu_flag_o;
/*
    alu comparison flag of `alu_opcode_i` operation
*/
wire    [31:0]  alu_sol_o;
/*
    alu compute result of `alu_opcode_i` operation
*/

// ---------------------------- REGISTER FILE WIRES ----------------------------
wire    [4:0]   rf_ra1_i;
/*
    input address of first register to read for reg file
*/
wire    [4:0]   rf_ra2_i;
/*
    input address of second register to read for reg file
*/
wire    [4:0]   rf_wa_i;
/*
    input address of register to write for reg file
*/
wire    [31:0]  rf_wd_i;
/*
    data to write to reg file by `rf_wa_i` address
*/
wire            rf_we_i;
/*
    input write enable flag for reg file
*/

wire    [31:0]  rf_rd1_o;
/*
    reg file output data from reg file from `rf_ra1_i` address
*/
wire    [31:0]  rf_rd2_o;
/*
    reg file output data from reg file from `rf_ra1_i` address
*/

// ------------------------- INSTRUCTION MEMORY WIRES --------------------------
wire    [31:0]  instr_addr_i;
/*
    input address of instruction for instruction memory
*/

wire    [31:0]  instr_instr_o;
/*
    32 bit instruction from instruction memory from `instr_addr_i` address
*/

// ----------------------------- MAIN DECODER WIRES ----------------------------
wire    [31:0]  dcode_isntr_i;
/*
    32 bit raw RISC-V i32 instruction to decode in main decoder, one of
    6 types: R-TYPE, I-TYPE, S-TYPE, B-TYPE, U-TYPE, J-TYPE
*/

wire    [1:0]   dcode_alu_op1_sel_o;
/*
    driving signal for alu first (left) operand `alu_op1_i`, one of:

    0 - `rf_rd1_o`  | data from (rd1) reg file
    1 - `reg_pc`    | program counter
    2 - zero        | 32 bit extended zero
*/
wire    [2:0]   dcode_alu_op1_sel_o;
/*
    driving signal for alu second (right) operand `alu_op2_i`, one of:

    0 - `rf_rd2_o`  | data from (rd2) reg file
    1 - ``    | program counter
    2 - zero        | 32 bit extended zero
*/
wire    [`ALU_OP_WIDTH-1:0] dcode_alu_opode_o;
/*

*/
wire            dcode_mem_req_o;
/*

*/
wire            dcode_mem_we_o;
/*

*/
wire    [2:0]   dcode_mem_size_o;
/*

*/
wire            dcode_rf_we_o;
/*

*/
wire            dcode_rf_wd_sel_o;
/*

*/
wire            illegal_instr_o;
/*

*/

wire            branch_o;
/*

*/
wire            jal_o;
/*

*/
wire            jalr_o;
/*

*/


// --------------------------------- REGISTER ----------------------------------
reg     [31:0]  reg_pc;
/*
    program counter register of address of current instruction from instrutcion
    memory  
*/

// =============================================================================
// ---------------------------------- MODULES ----------------------------------
miriscv_alu ALU (
    .operand_a_i    (alu_op1_i),          // 32 bit | first (left) operand
    .operand_b_i    (alu_op2_i),          // 32 bit | second (righ) operand
    .operator_i     (alu_opcode_i),       //  4 bit | ALU opcode
    .flag_o         (alu_flag_o),         //  1 bit | comparison flag
    .result_o       (alu_sol_o)           // 32 bit | result of compution
);

reg_file REG_FILE (
    .rst            (RESET),              //  1 bit | reset
    .clk            (CLK),                //  1 bit | clock
    .ra1            (rf_ra1_i),           //  5 bit | read address 1
    .ra2            (rf_ra2_i),           //  5 bit | read address 2
    .wa             (rf_wa_i),            //  5 bit | write address
    .wd             (rf_wd_i),            // 32 bit | write data
    .we             (rf_we_i),            //  1 bit | write enable
    .rd1            (rf_rd1_o),           // 32 bit | read data 1
    .rd2            (rf_rd2_o)            // 32 bit | read data 2
);
      
mem_inst INSTRUCTION_MEMORY (
    .rst            (RESET),              //  1 bit | reset
    .clk            (CLK),                //  1 bit | clock
    .pc             (instr_addr_i),       // 32 bit | program counter
    .instr          (instr_instr_o)       // 32 bit | instruction
);

miriscv_decode MAIN_DECODER (
    .fetched_instr_i(dcode_isntr_i),      //  bit |
    .ex_op_a_sel_o  (dcode_alu_op1_sel_o),//  bit |
    .ex_op_b_sel_o  (dcode_alu_op1_sel_o),//  bit |
    .alu_op_o       (dcode_alu_opode_o),  //  bit |
    .mem_req_o      (dcode_mem_req_o),    //  bit |
    .mem_we_o       (dcode_mem_we_o),     //  bit |
    .mem_size_o     (dcode_mem_size_o),   //  bit |
    .gpr_we_a_o     (dcode_rf_we_o),      //  bit |
    .wb_src_sel_o   (dcode_rf_wd_sel_o),  //  bit |
    .illegal_instr_o(illegal_instr_o),    //  bit |
    .branch_o       (branch_o),           //  bit |
    .jal_o          (jal_o),              //  bit |
    .jalr_o         (jalr_o)              //  bit |
);

// -------------------------------- WIRE ASSIGNS -------------------------------
assign  alu_op1_i       = decoder_3 (
    dcode_alu_op1_sel_o,                  //  2 bit | driving select
    rf_rd1_o,                             // 32 bit | select 0
    reg_pc,                               // 32 bit | select 1
    32'b0                                 // 32 bit | select 2
);
assign  alu_op2_i       = decoder_5 (
    dcode_alu_op2_sel_o,                  //  3 bit | driving select
    rf_rd2_o,                             // 32 bit | select 0
    imm_I                                 // 32 bit | select 1
    {instr_instr_o[31:12], 20'b0},        // 32 bit | select 2
    imm_S,                                // 32 bit | select 3
    32'd4                                 // 32 bit | select 4
);

assign  rf_ra1_i        = instr_instr_o[19:15];
assign  rf_ra2_i        = instr_instr_o[24:20];
assign  rf_wa_i         = instr_instr_o[11:7];
assign  rf_wd_i         = dcode_rf_wd_sel_o ?  : alu_sol_o;
assign  rf_we_i         = dcode_rf_we_o;

assign  instr_addr_i    = reg_pc;

assign  dcode_isntr_i   = instr_instr_o;

assign  pc_do_branch    = jalr_o || (alu_flag_o && branch_o);

assign  imm_I           = ;
assign  imm_S           = ;
assign  imm_J           = ;
assign  imm_B           = ;

// --------------------------------- FUNCTIONS ---------------------------------
function automatic [31:0] decoder_3;
/*

*/
    input [1:0]     select;
    input [31:0]    out_0;
    input [31:0]    out_1;
    input [31:0]    out_2;

    begin
        case (select)
            2'd0: decoder_3 = out_0;
            2'd1: decoder_3 = out_1;
            2'd2: decoder_3 = out_2;
        endcase
    end
endfunction

function automatic [31:0] decoder_5;
/*

*/
    input [2:0]     select;
    input [31:0]    out_0;
    input [31:0]    out_1;
    input [31:0]    out_2;
    input [31:0]    out_3;
    input [31:0]    out_4;

    begin
        case (select)
            2'd0: decoder_5 = out_0;
            2'd1: decoder_5 = out_1;
            2'd2: decoder_5 = out_2;
            2'd2: decoder_5 = out_3;
            2'd2: decoder_5 = out_4;
        endcase
    end
endfunction

always @(posedge CLK) begin
    if (RESET) begin
        reg_pc <= 32'b0;
    end
    else begin
        if (jalr_o) begin
            reg_pc <= rf_rd1_o + imm_I;
        end else begin
            if (pc_do_branch) begin
                reg_pc <= reg_pc + branch_o ? imm_B : imm_J;
            end else begin
                reg_pc <= reg_pc + 31'd4;
            end
        end
    end

endmodule

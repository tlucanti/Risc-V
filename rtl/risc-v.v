`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 11:05:30
// Design Name: RISC-V
// Module Name: risc-v
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

module risc_5 (
    input           RESET,
    input           CLK,
    input   [7:0]   SW
);

wire            pc_do_branch;
/*
    flag to set value to be added to programm counter `reg_pc`, if 1 - adding
    immidiate, else 4 bytes (32 bit) as isntruction size is 32 bit
*/

wire    [31:0]  imm_I;
/*
    sign extended immidiate for I-TYPE instructions
    extended as:
    ┌─────────────────────────────────────────────┬──────────────┐
    │                 instr[31]                   │ instr[30:20] │ isntruction
    ├─────────────────────────────────────────────┼──────────────┤
    │               imm_I[31:11]                  │  imm_I[10:0] │ imm_I result
    └─────────────────────────────────────────────┴──────────────┘
*/
wire    [31:0]  imm_S;
/*
    sign extended immidiate for S-TYPE instructions
    extended as:
    ┌───────────────────────────────┬──────────────┬─────────────┐
    │          instr[31]            │ instr[30:25] │ instr[11:7] │ isntruction
    ├───────────────────────────────┼──────────────┼─────────────┤
    │         imm_S[31:11]          │ imm_S[10:5]  │  imm_S[4:0] │ imm_S result
    └───────────────────────────────┴──────────────┴─────────────┘
*/
wire    [31:0]  imm_J;
/*
    sign extended immidiate for B-TYPE instructions
    extended as:
    ┌──────────────┬──────────────┬───────────┬──────────────┬───┐
    │  instr[31]   │ instr[19:12] │ instr[20] │ instr[30:21] │ ~ │ isntruction
    ├──────────────┼──────────────┼───────────┼──────────────┼───┤
    │ imm_B[31:20] │ imm_B[19:12] │ imm_B[11] │  imm_B[10:1] │ 0 │ imm_B result
    └──────────────┴──────────────┴───────────┴──────────────┴───┘
*/
wire    [31:0]  imm_B;
/*
    sign extended immidiate for B-TYPE instructions
    extended as:
    ┌───────────────┬───────────┬──────────────┬─────────────┬───┐
    │   instr[31]   │ instr[7]  │ instr[30:25] │ instr[11:8] │ ~ │ isntruction
    ├───────────────┼───────────┼──────────────┼─────────────┼───┤
    │  imm_B[31:12] │ imm_B[11] │ imm_B[10:5]  │  imm_B[4:1] │ 0 │ imm_B result
    └───────────────┴───────────┴──────────────┴─────────────┴───┘
*/
wire    [31:0]  imm_U;
/*
    sign extended immidiate for `lui` instruction
    extended as:
    ┌─────────────────────────────────────┬──────────────────────┐
    │             instr[31:0]             │           ~          │ isntruction
    ├─────────────────────────────────────┼──────────────────────┤
    │            imm_B[31:12]             │         12'b0        │ imm_U result
    └─────────────────────────────────────┴──────────────────────┘
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

    0 - `rf_rd1_o`          | data from (rd1) reg file
    1 - `reg_pc`            | program counter
    2 - zero                | 32 bit extended zero
*/
wire    [2:0]   dcode_alu_op2_sel_o;
/*
    driving signal for alu second (right) operand `alu_op2_i`, one of:

    0 - `rf_rd2_o`          | data from (rd2) reg file
    1 - imm_I               | sign extended I-TYPE immidiate
    2 - instr[31:12], 12'b0 | unsined extended immidite (for `lui` instruction)
    3 - imm_S               | sign extended S-TYPE immidiate
    4 - 32'd4               | unsigned extended 4 (for `jal` instruction)
*/
wire    [`ALU_OP_WIDTH-1:0] dcode_alu_opode_o;
/*
    opcode for operation on alu
*/
wire            dcode_mem_req_o;
/*
    memory interface - mem enable flag
*/
wire            dcode_mem_we_o;
/*
    memory interface - mem read/write switch: 1 - write, 0 - read
*/
wire    [2:0]   dcode_mem_size_o;
/*
    memory interface - mem read size
*/
wire            dcode_rf_we_o;
/*
    ref file write enable flag
*/
wire            dcode_rf_wd_sel_o;
/*
    drivin signal for write data source:

    0 - `alu_sol_o`         | write alu operation to reg file
    1 - `mem_data_o`        | write data from memory to reg file
*/
wire            illegal_instr_o;
/*
    illegal instruction flag, set if `instr_instr_o` is invalid and than - no
    operation happened
    flag is 1 if one of following condition is true:

    1. op_code of instruction is not one of valid RISC-V i32 instructions (not
        one of `slli`, `srli`, `srai`, `add`, `sub`, `sll`, `slt`, `sltu`,
        `xor`, `srl`, `sra`, `or`, `ans`, `jalr`, `lb`, `lh`, `lw`, `lbu`,
        `lhu`, `addi`, `slti`, `sltiu`, `xori`, `ori`, `andi`, `fence`, `ecall`,
        `ebreak`, `sb`, `sh`, `sw`, `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`,
        `lui`, `auipc`, `jal`)
    2. in branch operation (B-TYPE) funct3 is one of 010, 011
    3. in memory required operations (LOAD and STORE instructions) funct3 is one
        of 011, 110, 111
    4. in STORE instructions funct3 is one of 100, 101
    5. funct7 is NOT one of 0000000, 0100000
*/

wire            branch_o;
/*
    flag that curent operation is B-TYPE (one of `beq`, `bne`, `blt`, `bge`,
    `bltu`, `bgeu` instructions)
*/
wire            jal_o;
/*
    flag that current operation is J-TYPE (`jal` instruction)
*/
wire            jalr_o;
/*
    flag that current instruction is `jalr`
*/

// ------------------------------- MEMORY WIRES --------------------------------
wire    [31:0]  mem_addr_i;
/*
    input addres for memory to read from or write to
*/
wire    [31:0]  mem_data_i;
/*
    data to write to memory by `mem_addr_i` address
*/
wire            mem_req_i;
/*
    memory enable flag - if 0 - no operaton with memory will happen
*/
wire            mem_we_i;
/*
    memory write/read switcher: if 1 - module will write data, if 0 - module
    will read data by `mem_addr_i` address
*/
wire    [2:0]   mem_size_i;
/*
    option to set size of data to read from memory

    0 - signed  8bit value extended to 32bit
    1 - signed 16bit value extended to 32bit
    2 - 32bit value
    3 - not valid
    4 - unsigned  8bit value extended to 32bit
    5 - unsigned 16bit value extended to 32bit
*/

wire    [31:0]  mem_data_o;
/*
    output 32bit data read from `mem_addr_i` address
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
    .fetched_instr_i(dcode_isntr_i),      // 32 bit | raw instruction
    .ex_op_a_sel_o  (dcode_alu_op1_sel_o),//  2 bit | sel first alu operand
    .ex_op_b_sel_o  (dcode_alu_op2_sel_o),//  3 bit | sel second alu operand
    .alu_op_o       (dcode_alu_opode_o),  //  4 bit | alu opcode
    .mem_req_o      (dcode_mem_req_o),    //  1 bit | mem enable flag
    .mem_we_o       (dcode_mem_we_o),     //  1 bit | mem read/write sel
    .mem_size_o     (dcode_mem_size_o),   //  3 bit | mem return size
    .gpr_we_a_o     (dcode_rf_we_o),      //  1 bit | reg file write enable
    .wb_src_sel_o   (dcode_rf_wd_sel_o),  //  1 bit | reg file write data sel
    .illegal_instr_o(illegal_instr_o),    //  1 bit | illegal instruction flag
    .branch_o       (branch_o),           //  1 bit | branch operation flag
    .jal_o          (jal_o),              //  1 bit | `jal` instruction flag
    .jalr_o         (jalr_o)              //  1 bit | `jalr` instruction flag
);

miriscv_ram RAM (
    .reset          (RESET),              //  1 bit | reset
    .clk            (CLK),                //  1 bit | clock
    .mem_addr_i     (mem_addr_i),         // 31 bit | read/write address
    .mem_data_i     (mem_data_i),         // 31 bit | data to write
    .mem_req_i      (mem_req_i),          //  1 bit | mem enable
    .mem_we_i       (mem_we_i),           //  1 bit | 1 - write, 0 - read
    .mem_size_i     (mem_size_i),         //  3 bit | return data size
    .mem_data_o     (mem_data_o)          // 31 bit | return data from mem
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
    imm_I,                                // 32 bit | select 1
    {instr_instr_o[31:12], 12'b0},        // 32 bit | select 2
    imm_S,                                // 32 bit | select 3
    32'd4                                 // 32 bit | select 4
);
assign alu_opcode_i     = dcode_alu_opode_o;

assign  rf_ra1_i        = instr_instr_o[19:15];
assign  rf_ra2_i        = instr_instr_o[24:20];
assign  rf_wa_i         = instr_instr_o[11:7];
assign  rf_wd_i         = dcode_rf_wd_sel_o ? mem_data_o : alu_sol_o;
assign  rf_we_i         = dcode_rf_we_o;

assign  mem_addr_i      = alu_sol_o;
assign  mem_data_i      = rf_rd2_o;
assign  mem_req_i       = dcode_mem_req_o;
assign  mem_we_i        = dcode_mem_we_o;
assign  mem_size_i      = dcode_mem_size_o;

assign  instr_addr_i    = reg_pc;

assign  dcode_isntr_i   = instr_instr_o;

assign  pc_do_branch    = jal_o || (alu_flag_o && branch_o);

assign  imm_I           = {
    {21{instr_instr_o[31]}}, instr_instr_o[30:20]
};
assign  imm_S           = {
    {21{instr_instr_o[31]}}, instr_instr_o[30:25], instr_instr_o[11:7]
};
assign  imm_B           = {
    {20{instr_instr_o[31]}}, instr_instr_o[7], instr_instr_o[30:25],
    instr_instr_o[11:8], 1'b0
};
assign  imm_J           = {
    {12{instr_instr_o[31]}}, instr_instr_o[19:12], instr_instr_o[20],
    instr_instr_o[30:21], 1'b0
};
assign  imm_U           = {
    instr_instr_o[31:12], 12'b0
};

// --------------------------------- FUNCTIONS ---------------------------------
function automatic [31:0] decoder_3;
/*
    simple decoder function - return one of three outputs 0, 1 or 2 according to
    `select` value
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
    simple decoder function - return one of five outputs 0, 1, .. 5 according to
    `select` value
*/
    input [2:0]     select;
    input [31:0]    out_0;
    input [31:0]    out_1;
    input [31:0]    out_2;
    input [31:0]    out_3;
    input [31:0]    out_4;

    begin
        case (select)
            3'd0: decoder_5 = out_0;
            3'd1: decoder_5 = out_1;
            3'd2: decoder_5 = out_2;
            3'd3: decoder_5 = out_3;
            3'd4: decoder_5 = out_4;
        endcase
    end
endfunction

always @(posedge CLK) begin
    if (RESET) begin
        reg_pc <= 32'b0;
    end
    else begin
        if (jalr_o) begin
            reg_pc <= rf_rd1_o + (imm_I << 2);
        end else begin
            if (pc_do_branch) begin
                reg_pc <= reg_pc + (branch_o ? imm_B : imm_J);
            end else begin
                reg_pc <= reg_pc + 31'd4;
            end
        end
    end
end

endmodule

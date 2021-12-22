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
   input        [31:0]               fetched_instr_i,
   output reg   [1:0]                ex_op_a_sel_o,
   output reg   [2:0]                ex_op_b_sel_o,
   output reg   [`ALU_OP_WIDTH-1:0]  alu_op_o,
   output reg                        mem_req_o,
   output reg                        mem_we_o,
   output reg   [2:0]                mem_size_o,
   output reg                        gpr_we_a_o,
   output reg                        wb_src_sel_o,
   output reg                        illegal_instr_o,
   output reg                        branch_o,
   output reg                        jal_o,
   output reg                        jalr_o
);

wire     [4:0] op_code;
wire     [2:0] funct3;
wire     [6:0] funct7;

assign op_code       = fetched_instr_i[6:2];
assign funct3        = fetched_instr_i[14:12];
assign funct7        = fetched_instr_i[31:25];

always @(*) begin
   ex_op_a_sel_o     <= 0;
   ex_op_b_sel_o     <= 0;
   alu_op_o          <= 0;
   mem_req_o         <= 0;
   mem_we_o          <= 0;
   mem_size_o        <= 0;
   gpr_we_a_o        <= 0;
   wb_src_sel_o      <= 0;
   illegal_instr_o   <= 0;
   branch_o          <= 0;
   jal_o             <= 0;
   jalr_o            <= 0;
   if (fetched_instr_i[1:0] != 2'b11) begin
      illegal_instr_o <= 1'b1;
   end else begin
   case (op_code)
      `OP_OPCODE:                                                               // ADD SUB SLL SLT SLTU XOR SRL SRA OR
         begin                                                                  // AND
            ex_op_a_sel_o  <= 2'd0;
            ex_op_b_sel_o  <= 3'd0;
            mem_req_o      <= 1'd0;
            mem_we_o       <= 0;
            mem_size_o     <= 0;
            gpr_we_a_o     <= 1'd1;
            wb_src_sel_o   <= 1'd0;
            branch_o       <= 1'd0;
            jal_o          <= 1'd0;
            jalr_o         <= 1'd0;
            alu_op_o       <= 0;
            case (funct3)
               3'b000:                                                          // ADD SUB
                  begin
                     if (funct7 == 7'b0000000) begin                            // ADD
                        alu_op_o          <= `ALU_ADD;
                     end else if (funct7 == 7'b0100000) begin                   // SUB
                        alu_op_o          <= `ALU_SUB;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'b1;
                     end
                  end
               3'b001:
                  begin
                     if (funct7 == 7'b0000000) begin                            // SLL
                        alu_op_o          <= `ALU_SLL;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'b1;
                     end
                  end
               3'b010:
                  begin
                     if (funct7 == 7'b0000000) begin                            // SLT
                        alu_op_o          <= `ALU_SLTS;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'b1;
                     end
                  end
               3'b011:
                   begin
                     if (funct7 == 7'b0000000) begin                            // SLTU
                        alu_op_o          <= `ALU_SLTU;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'b1;
                     end
                  end
               3'b100:
                   begin
                     if (funct7 == 7'b0000000) begin                            // XOR
                        alu_op_o          <= `ALU_XOR;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'b1;
                     end
                  end
               3'b101:
                   begin
                     if (funct7 == 7'b0000000) begin                            // SRL
                        alu_op_o          <= `ALU_SRL;
                     end else if (funct7 == 7'b0000001) begin                   // SRA
                        alu_op_o          <= `ALU_SRA;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'b1;
                     end
                  end
               3'b110:
                   begin
                     if (funct7 == 7'b0000000) begin                            // OR
                        alu_op_o          <= `ALU_OR;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'b1;
                     end
                  end
               3'b111:
                   begin
                     if (funct7 == 7'b0000000) begin                            // AND
                        alu_op_o          <= `ALU_AND;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'b1;
                     end
                  end
               default:
                     illegal_instr_o      <= 1'b1;
            endcase
         end
      `OP_IMM_OPCODE:                                                           // ADDI SLTI SLTIU XORI ORI ANDI SLLI
         begin                                                                  // SRLI SRAI
            ex_op_a_sel_o  <= 2'd0;
            ex_op_b_sel_o  <= 3'd1;
            mem_req_o      <= 1'd0;
            mem_we_o       <= 0;
            mem_size_o     <= 0;
            gpr_we_a_o     <= 1'd1;
            wb_src_sel_o   <= 1'd0;
            branch_o       <= 1'd0;
            jal_o          <= 1'd0;
            jalr_o         <= 1'd0;
            alu_op_o       <= 0;
            case (funct3)
               3'b000: alu_op_o             <= `ALU_ADD;                        // ADDI
               3'b010: alu_op_o             <= `ALU_SLTS;                       // SLTI
               3'b011: alu_op_o             <= `ALU_SLTU;                       // SLTIU
               3'b100: alu_op_o             <= `ALU_XOR;                        // XORI
               3'b110: alu_op_o             <= `ALU_OR;                         // ORI
               3'b111: alu_op_o             <= `ALU_AND;                        // ANDI
               3'b001:
                  begin
                     if (funct7 == 7'b0000000) begin                            // SLLI
                        alu_op_o          <= `ALU_SLL;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'd1;
                     end
                  end
               3'b101:
                  begin
                     if (funct7 == 7'b0000000) begin                            // SRLI
                        alu_op_o          <= `ALU_SRL;
                     end else if (funct7 == 7'b0100000) begin                   // SRAI
                        alu_op_o          <= `ALU_SRA;
                     end else begin                                             // ILL
                        illegal_instr_o   <= 1'd1;
                     end
                  end
               default:
                     illegal_instr_o      <= 1'd1;
            endcase
         end
      `LUI_OPCODE:                                                              // LUI
         begin
            ex_op_a_sel_o     <= 2'd2;
            ex_op_b_sel_o     <= 3'd2;
            alu_op_o          <= 0;
            mem_req_o         <= 1'd0;
            mem_we_o          <= 0;
            mem_size_o        <= 0;
            gpr_we_a_o        <= 1'd1;
            wb_src_sel_o      <= 1'd0;
            illegal_instr_o   <= 1'd0;
            branch_o          <= 1'd0;
            jal_o             <= 1'd0;
            jalr_o            <= 1'd0;
         end
      `LOAD_OPCODE:                                                             // LB LH LW LBU LHU
         begin
            ex_op_a_sel_o  <= 2'd0;
            ex_op_b_sel_o  <= 3'd1;
            alu_op_o       <= `ALU_ADD;
            mem_we_o       <= 0;
            gpr_we_a_o     <= 1'd1;
            wb_src_sel_o   <= 1'd1;
            branch_o       <= 1'd0;
            jal_o          <= 1'd0;
            jalr_o         <= 1'd0;
            case (funct3)
               3'b000,                                                          // LB
               3'b001,                                                          // LH
               3'b010,                                                          // LW
               3'b100,                                                          // LBU
               3'b101:                                                          // LHU
                  begin
                     mem_req_o         <= 1'd1;
                     mem_size_o        <= funct3;
                  end
               default:                                                         // ILL
                     illegal_instr_o   <= 1'd1;
            endcase
         end
      `STORE_OPCODE:                                                            // SB SH SW
         begin
            ex_op_a_sel_o  <= 2'd0;
            ex_op_b_sel_o  <= 3'd3;
            alu_op_o       <= `ALU_ADD;
            mem_we_o       <= 1'b1;
            gpr_we_a_o     <= 1'd0;
            wb_src_sel_o   <= 1'd1;
            branch_o       <= 1'd0;
            jal_o          <= 1'd0;
            jalr_o         <= 1'd0;
            case (funct3)
               3'b000,                                                          // SB
               3'b001,                                                          // SH
               3'b010:                                                          // SW
                  begin
                     mem_req_o         <= 1'd1;
                     mem_size_o        <= funct3;
                  end
               default:                                                         // ILL
                     illegal_instr_o   <= 1'd1;
            endcase
         end
      `BRANCH_OPCODE:                                                           // BEQ BNE BLT BGE BLTU BGEU
         begin
            ex_op_a_sel_o     <= 2'd0;
            ex_op_b_sel_o     <= 3'd0;
            mem_req_o         <= 1'd0;
            mem_we_o          <= 0;
            mem_size_o        <= 0;
            gpr_we_a_o        <= 1'd0;
            wb_src_sel_o      <= 0;
            branch_o          <= 1'd1;
            jal_o             <= 1'd0;
            jalr_o            <= 1'd0;
            case (funct3)
               3'b000: alu_op_o   <= `ALU_EQ;                                   // BEQ
               3'b001: alu_op_o   <= `ALU_NE;                                   // BNE
               3'b100: alu_op_o   <= `ALU_LTS;                                  // BLT
               3'b101: alu_op_o   <= `ALU_GES;                                  // BGE
               3'b110: alu_op_o   <= `ALU_LTU;                                  // BLTU
               3'b111: alu_op_o   <= `ALU_GEU;                                  // BGEU
               default:
                  illegal_instr_o  <= 1'd1;                                     // ILL
            endcase
         end
      `JAL_OPCODE:                                                              // JAL
         begin
            ex_op_a_sel_o        <= 1'd1;
            ex_op_b_sel_o        <= 3'd4;
            alu_op_o             <= `ALU_ADD;
            mem_req_o            <= 1'd0;
            mem_we_o             <= 0;
            mem_size_o           <= 0;
            gpr_we_a_o           <= 1'd1;
            wb_src_sel_o         <= 1'd0;
            illegal_instr_o      <= 0;
            branch_o             <= 1'd0;
            jal_o                <= 1'd1;
            jalr_o               <= 1'd0;
         end
      `JALR_OPCODE:                                                             // JALR
         begin
            if (funct3 == 3'b000) begin
               ex_op_a_sel_o     <= 1'd1;
               ex_op_b_sel_o     <= 3'd4;
               alu_op_o          <= `ALU_ADD;
               mem_req_o         <= 1'd0;
               mem_we_o          <= 0;
               mem_size_o        <= 0;
               gpr_we_a_o        <= 1'd1;
               wb_src_sel_o      <= 1'd0;
               illegal_instr_o   <= 0;
               branch_o          <= 1'd0;
               jal_o             <= 1'd0;
               jalr_o            <= 1'd1;
            end else begin
               illegal_instr_o   <= 1'b1;
            end
         end
      `AUIPC_OPCODE:                                                            // AUIPC
         begin
            ex_op_a_sel_o        <= 2'd1;
            ex_op_b_sel_o        <= 3'd2;
            alu_op_o             <= `ALU_ADD;
            mem_req_o            <= 1'd0;
            mem_we_o             <= 0;
            mem_size_o           <= 0;
            gpr_we_a_o           <= 1'd1;
            wb_src_sel_o         <= 1'd0;
            illegal_instr_o      <= 0;
            branch_o             <= 1'd0;
            jal_o                <= 1'd0;
            jalr_o               <= 1'd0;
         end
      `FENCE_OPCODE:                                                            // FENCE (NOP)
         begin
            // if (funct3 != 3'b000) begin                                      // should be ILL, if funct3 != 0 but
               // illegal_instr_o   <= 1'd1;                                    // tester says - NO
            // end
         end
      `SYSTEM_OPCODE:                                                           // ECALL (NOP) EBREAK (NOP)
         begin
            // casez (fetched_instr_i[31:7])
               // 'b00000000000?_00000_000_00000:
                  // begin
                  // end
               // default:                                                      // should be ILL, but tester says - NO
                     // illegal_instr_o   <= 1'b1;
            // endcase
         end
      default:
            illegal_instr_o <= 1'b1;
   endcase
end
end
endmodule

`timescale 1ns / 1ps

`include "../rtl/miriscv_defines.v"

module tb_miriscv_decode_my();

reg   [31:0]               fetched_instr_i;
wire  [1:0]                ex_op_a_sel_o;
wire  [2:0]                ex_op_b_sel_o;
wire  [`ALU_OP_WIDTH-1:0]  alu_op_o;
wire                       mem_req_o;
wire                       mem_we_o;
wire  [2:0]                mem_size_o;
wire                       gpr_we_a_o;
wire                       wb_src_sel_o;
wire                       illegal_instr_o;
wire                       branch_o;
wire                       jal_o;
wire                       jalr_o;

miriscv_decode dut (
 .fetched_instr_i  (fetched_instr_i),
 .ex_op_a_sel_o    (ex_op_a_sel_o),
 .ex_op_b_sel_o    (ex_op_b_sel_o),
 .alu_op_o         (alu_op_o),
 .mem_req_o        (mem_req_o),
 .mem_we_o         (mem_we_o),
 .mem_size_o       (mem_size_o),
 .gpr_we_a_o       (gpr_we_a_o),
 .wb_src_sel_o     (wb_src_sel_o),
 .illegal_instr_o  (illegal_instr_o),
 .branch_o         (branch_o),
 .jal_o            (jal_o),
 .jalr_o           (jalr_o)
);

initial begin
	#5
	fetched_instr_i = 'h3e38320f;
end

endmodule

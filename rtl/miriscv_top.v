`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 20.11.2021 15:13:33
// Design Name: RISC-V
// Module Name: miriscv_top
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//
// Parameters:
//
// Dependencies:
// 
// Revision: v2.0
//  - v0.1 - file Created
//  - v1.0 - done for stage-5
//  - v2.0 - move from system verilog to verilog, add header, done for stage-6
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module miriscv_top
(
  input clk_i,
  input rst_n_i,
  input [31:0] int_req_i
);

  wire  [31:0]  instr_rdata_core;
  wire  [31:0]  instr_addr_core;

  wire  [31:0]  data_rdata_core;
  wire          data_req_core;
  wire          data_we_core;
  wire  [3:0]   data_be_core;
  wire  [31:0]  data_addr_core;
  wire  [31:0]  data_wdata_core;

  wire  [31:0]  data_rdata_ram;
  wire          data_req_ram;
  wire          data_we_ram;
  wire  [3:0]   data_be_ram;
  wire  [31:0]  data_addr_ram;
  wire  [31:0]  data_wdata_ram;

  wire  [31:0]  core_int_mie;
  wire          core_int_rst;
  wire  [31:0]   int_core_mcause;
  wire          int_core_int;

  assign data_rdata_core  = data_rdata_ram;
  assign data_req_ram     = data_req_core;
  assign data_we_ram      = data_we_core;
  assign data_be_ram      = data_be_core;
  assign data_addr_ram    = data_addr_core;
  assign data_wdata_ram   = data_wdata_core;

  core rv_core (
    .CLK             (clk_i           ),
    .RESET           (!rst_n_i        ),

    .raw_instr_mi    (instr_rdata_core),
    .core_mem_pc_mo  (instr_addr_core ),

    .mem_lsu_data_mi (data_rdata_core ),
    .lsu_mem_req_mo  (data_req_core   ),
    .lsu_mem_we_mo   (data_we_core    ),
    .lsu_mem_mask_mo (data_be_core    ),
    .lsu_mem_addr_mo (data_addr_core  ),
    .lsu_mem_data_mo (data_wdata_core ),

    .int_i           (int_core_int    ),
    .dcode_int_rst_o (core_int_rst    ),
    .int_csr_mcause_i(int_core_mcause ),
    .csr_int_mie_o   (core_int_mie    )
  );

  interrupt_controller intr (
    .clk             (clk_i          ),
    .reset           (!rst_n_i       ),
    .int_int_req_i   (int_req_i      ),
    .int_mie_i       (core_int_mie   ),
    .int_rst_i       (core_int_rst   ),
    .int_mcause_i    (int_core_mcause),
    .int_int_o       (int_core_int   )
  );

  miriscv_ram ram (
    .clk_i         (clk_i           ),
    .rst_n_i       (rst_n_i         ),

    .instr_rdata_o (instr_rdata_core),
    .instr_addr_i  (instr_addr_core ),

    .data_rdata_o  (data_rdata_ram  ),
    .data_req_i    (data_req_ram    ),
    .data_we_i     (data_we_ram     ),
    .data_be_i     (data_be_ram     ),
    .data_addr_i   (data_addr_ram   ),
    .data_wdata_i  (data_wdata_ram  )
  );


endmodule

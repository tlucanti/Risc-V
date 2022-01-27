`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 20.11.2021 15:13:33
// Design Name: RISC-V
// Module Name: 
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
// Revision: v0.1
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module miriscv_addr_decoder(clk, reset, instr_rdata_core_o, instr_addr_core_i,
    dev_we_i, dev_mask_i, dev_addr_i, dev_wr_data_i, int_rst_i, dev_int_o);

// clock, reset
input   clk;
/*

*/
input   reset;
/*

*/

// memory
input   [31:0]  instr_addr_core_i;
/*
    instruction address for ram memory
*/
output  [31:0]  instr_rdata_core_o;
/*
    instruction data from ram memory by `instr_addr_core_i` address
*/
wire            mem_req;
/*
    ram request flag
*/
wire    [31:0]  mem_data;
/*
    data from ram
*/

// keyboard
wire            kb_req_o;
/*
    keyboard request flag
*/
wire    [31:0]  kb_data;
/*
    keyboard register data
*/
wire            kb_int;
/*
    keyboard interrupt flag
*/

// flash
wire            fl_req_o;
/*
    flash request flag
*/
wire    [31:0]  fl_data;
/*
    flsh register data
*/
wire            fl_int;
/*
    flash interrupt flag
*/

// dev data and address
input           dev_we_i;
/*
    device write enable flag (ignored if request flag is not active)
*/
input   [3:0]   dev_mask_i;
/*
    byte select mask for write data
*/
input   [31:0]  dev_addr_i;
/*
    global address to decode and forward to right device
*/
input   [31:0]  dev_wr_data_i;
/*
    write data to write to device register
*/

// interrupt
input           int_rst_i;
/*
    interrupt reset flag
*/
output  [31:0]  dev_int_o;
/*
    devices interrupt flags
*/


miriscv_ram ram (
    .clk_i         (clk               ),
    .rst_n_i       (!reset            ),

    .instr_rdata_o (instr_rdata_core_o),
    .instr_addr_i  (instr_addr_core_i ),

    .data_rdata_o  (mem_data          ),
    .data_req_i    (mem_req           ),
    .data_we_i     (dev_we_i          ),
    .data_be_i     (dev_mask_i        ),
    .data_addr_i   (dev_addr_i        ),
    .data_wdata_i  (dev_wr_data_i     )
);

keyboard kb (
    .clk            (clk          ),
    .reset          (reset        ),
    .kb_req_i       (kb_req       ),
    .kb_we_i        (dev_we_i     ),
    .reg_addr_i     (dev_addr_i - 32'h80),
    .reg_wdata_i    (dev_wr_data_i),
    .reg_mask_i     (dev_mask_i   ),
    .reg_rdata_o    (kb_data      ),
    .kb_int_o       (kb_int       ),
    .kb_int_rst_i   (int_rst_i    )
);

flash fl (
    .clk             (clk          ),
    .reset           (reset        ),
    .fl_req_i        (fl_req_o     ),
    .fl_we_i         (dev_we_i     ),
    .reg_addr_i      (dev_addr_i - 32'h84),
    .reg_wdata_i     (dev_wr_data_i),
    .reg_mask_i      (dev_mask_i   ),
    .reg_rdata_o     (fl_data      ),
    .fl_int_o        (fl_int       ),
    .fl_int_rst_i    (int_rst_i    )
);

assign kb_req       = dev_addr_i == 32'h80;
assign fl_req_i     = dev_addr_i >= 32'h84 && dev_addr_i <= 32'ha0;
assign dev_int_o    = {kb_int, fl_int, 30'b0};

endmodule

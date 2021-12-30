`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 10:26:51
// Design Name: RISC-V
// Module Name: miriscv_lsu
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//   module implements memory load/store interface for RAM module
// Parameters:
//   lsu_addr_i - address to write/read from data
//   lsu_we_i   - read/write switcher 1 - write, 0 - read
//   lsu_size_i - size of data to write
//     3'd0: signed byte (8 bit)
//     3'd1: signed half (16 bit)
//     3'd2: word (32 bit)
//     3'd4: unsigned byte (8 bit)
//     3'd5: unsigned half (16 bit)
//  lsu_data_i  - data to write by `lsu_addr_i`
//  lsu_req_i   - memory enable flag
//
//  lsu_busy_o  - flag to wait and not update pc if data not ready from RAM
//  lsu_data_o  - sign extended and aligned data from `mem_data_mi`
//    relation to lsu_size_i and offset (`lsu_addr_i[1:0]`):
//      3'd0: 1 byte:
//        data:   00000000|00000000|00000000|00000000
//        offset:     3        2        1        0
//      3'd1: 2 bytes:
//
//  mem_data_mi - data from RAM
//
//  mem_req_mo  - `lsu_req_i` forward from outer scope to RAM
//  mem_we_mo   - `lsu_we_i` forward from outer scope to RAM
//  mem_mask_mo - byte write mask - chose what bytes from `mem_data_mo` will
//    be written to RAM by `mem_addr_mo`
//  mem_addr_mo - `lsu_addr_i` forward from outer scope to RAM
//  mem_data_mo - `lsu_data_i` forward from outer scope to RAM
//
// Dependencies: miriscv_ram
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//  _i  suffix means - signal came from outer scope
//  _o  suffix means - signal going to outer scope
//  _mi suffix means - signal came from RAM
//  _mo suffix means - signal going to RAM
// 
////////////////////////////////////////////////////////////////////////////////

module miriscv_lsu (
    input   clk,
    input   reset,

    // core protocol
    input       [31:0]  lsu_addr_i,
    input               lsu_we_i,
    input       [2:0]   lsu_size_i,
    input       [31:0]  lsu_data_i,
    input               lsu_req_i,

    output              lsu_busy_o,     //
    output reg  [31:0]  lsu_data_o,     //

    // memory protocol
    input       [31:0]  mem_data_mi,
    
    output              mem_req_mo,     //
    output              mem_we_mo,      //
    output reg  [3:0]   mem_mask_mo,    //
    output      [31:0]  mem_addr_mo,    //
    output      [31:0]  mem_data_mo     //
);

wire    [1:0]   offset          = lsu_addr_i[1:0];
wire    [31:0]  shifted_data    = mem_data_mi >> (offset[1:0] << 3);

assign  lsu_busy_o  = 1'b0;
assign  mem_req_mo  = lsu_req_i;
assign  mem_we_mo   = lsu_we_i;
assign  mem_addr_mo = lsu_addr_i;
assign  mem_data_mo = lsu_data_i;

always @(*) begin
    case (lsu_size_i)
        3'b000: lsu_data_o    <= sign_8extend(shifted_data);
        3'b001: lsu_data_o    <= sign_16extend(shifted_data);
        3'b010: lsu_data_o    <= mem_data_mi;
        3'b100: lsu_data_o    <= shifted_data & 'hff;
        3'b101: lsu_data_o    <= shifted_data & 'hffff;
    endcase

    case (lsu_size_i)
        3'b100,
        3'b000: mem_mask_mo   <= 4'b1  << offset_shift;
        3'b001,
        3'b101: mem_mask_mo   <= 4'b11 << offset_shift;
        3'b010: mem_mask_mo   <= offset_shift;
    endcase
end

function [31:0] automatic sign_8extend;
    input [7:0] val;
    begin
        sign_8extend = {{24{val[7]}}, val[7:0]};
    end
endfunction

function [31:0] automatic sign_16extend;
    input [15:0] val;
    begin
        sign_16extend = {{16{val[15]}}, val[15:0]};
    end

endmodule

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
//
//  lsu_busy_o  - flag to wait and not update pc if data not ready from RAM
//  lsu_data_o  - sign extended and aligned data from `mem_data_mi` (from RAM)
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
// Revision: v0.1
//  - v0.1 - file Created
//  - v1.0 - done for stage-5
//
// Additional Comments:
//  _i  suffix means - signal came from outer scope
//  _o  suffix means - signal going to outer scope
//  _mi suffix means - signal came from RAM
//  _mo suffix means - signal going to RAM
// 
////////////////////////////////////////////////////////////////////////////////

module miriscv_lsu (clk, reset, lsu_addr_i, lsu_we_i, lsu_size_i, lsu_data_i,
    lsu_req_i, lsu_busy_o, lsu_data_o, mem_data_mi, mem_req_mo, mem_we_mo,
    mem_mask_mo, mem_addr_mo, mem_data_mo);

// ---------------------------------- LSU I/O ----------------------------------
input   clk;
/*
    input clock signal
*/
input   reset;
/*
    input reset signal (not inverted)
*/

// core protocol
input       [31:0]  lsu_addr_i;
/*
    address where `lsu_data_i` (data from register) will be written (if STORE
    instruction), and where from in RAM data will be read (if LOAD instruction)

    forwarding to `mem_addr_mo`
*/
input               lsu_we_i;
/*
    read/write switcher from RAM: 1 - write, 0 - read

    forwarding to `mem_we_mo`
*/
input       [2:0]   lsu_size_i;
/*
    size of data to write
      3'd0 (0b000): signed byte (8 bit)
      3'd1 (0b001): signed half (16 bit)
      3'd2 (0b010): word (32 bit)
      3'd4 (0b100): unsigned byte (8 bit)
      3'd5 (0b101): unsigned half (16 bit)

    will be used with offset to set `mem_mask_mo` for RAM
*/
input       [31:0]  lsu_data_i;
/*
    raw 32 bit data (data from register) that will be cut by RAM and written by
    `lsu_addr_i` address
*/
input               lsu_req_i;
/*
    memory enable flag

    forwarding to `mem_req_mo`
*/

output              lsu_busy_o;
/*
    flag to stop programm counter from increasing while data from RAM not yet
    ready, or data not yet written to RAM

    should br forwarded to pc_enable in `core` module
*/
output reg  [31:0]  lsu_data_o;
/*
    sign extended and alligned data from `mem_data_mi`

    will be using `lsu_size_i` to cut and sign extend raw `mem_data_mi` data
    from ram and return it to write to register file
*/

// memory protocol
input       [31:0]  mem_data_mi;
/*
    raw 32 bit data from RAM read by `lsu_addr_i` address
*/

output              mem_req_mo;
/*
    memory enable flag

    forwarded from `lsu_req_i`
*/
output              mem_we_mo;
/*
    read/write switcher from RAM: 1 - write, 0 - read

    forwarded from `lsu_we_i`
*/
output reg  [3:0]   mem_mask_mo;
/*
    binary mask to enable bytes from `mem_data_mo` to be written to
    `mem_addr_mo` address

    `mem_mask_mo` relation to lsu_size_i and offset (`lsu_addr_i[1:0]`):
              msb                             lsb
      data:   00000000|00000000|00000000|00000000
      offset:     3        2        1        0
*/
output      [31:0]  mem_addr_mo;
/*
    address to read from, or write to, depending on `mem_we_mo`
*/
output reg  [31:0]  mem_data_mo;
/*
    cut and sign extended data from `lsu_data_i` to send to RAM

    from this data bytes will written by `mem_addr_mo` address according to
    `mem_mask_mo` mask
*/

// =============================================================================
// -------------------------------- WIRE ASSIGNS -------------------------------
wire    [1:0]   offset          = lsu_addr_i[1:0];
wire    [31:0]  x8offset        = offset << 3;
wire    [31:0]  srl_rdata       = mem_data_mi >> x8offset;

assign  lsu_busy_o  = 1'b0;
assign  mem_req_mo  = lsu_req_i;
assign  mem_we_mo   = lsu_we_i;
assign  mem_addr_mo = lsu_addr_i;

// -------------------------------- MAIN BLOCK ---------------------------------
always @(*) begin
    case (lsu_size_i)
        3'b000: lsu_data_o    <= sign_8extend(srl_rdata);
        3'b001: lsu_data_o    <= sign_16extend(srl_rdata);
        3'b010: lsu_data_o    <= srl_rdata;
        3'b100: lsu_data_o    <= srl_rdata & 'hff;
        3'b101: lsu_data_o    <= srl_rdata & 'hffff;
    endcase

    case (lsu_size_i)
        3'b100,
        3'b000: mem_mask_mo   <= 4'b1  << offset;
        3'b001,
        3'b101: mem_mask_mo   <= 4'b11 << offset;
        3'b010: mem_mask_mo   <= 4'b1111;
    endcase

    case (lsu_size_i)
        3'b000: mem_data_mo   <= {4{lsu_data_i[7:0]}};
        3'b001: mem_data_mo   <= {2{lsu_data_i[15:0]}};
        3'b010: mem_data_mo   <= lsu_data_i;
    endcase
end

// --------------------------------- FUNCTIONS ---------------------------------
function automatic [31:0] sign_8extend;
    input [7:0] val;
    begin
        sign_8extend = {{24{val[7]}}, val[7:0]};
    end
endfunction

function automatic [31:0] sign_16extend;
    input [15:0] val;
    begin
        sign_16extend = {{16{val[15]}}, val[15:0]};
    end
endfunction

endmodule

`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 20.11.2021 15:13:33
// Design Name: RISC-V
// Module Name: interrupt_controller
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
//  - v0.1 - file Created
//  - v1.0 - done for stage-6
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module interrupt_controller();

// ---------------------------------- IC I/O -----------------------------------
input   clk;
/*

*/
input   reset;
/*

*/

input   [31:0]  int_int_req_i;
/*
    input bus from devices with interrupt requierments
*/
input   [31:0]  int_mie_i;
/*
    mask interrupt enable
*/
input           int_rst_i
/*
    interrupt done flag
*/

output  [31:0]  int_mcause_i;
/*
    id of interrupt
*/
output          int_int_o;
/*
    interrupt strobe flag
*/

// =============================================================================

reg             int;
reg     [4:0]   cnt;
wire    [31:0]  int_accepted_bus = int_mie_i & int_int_req_i & (31'b1 << cnt);
wire            int_accepted = | int_accepted_bus;
assign          int_int_o = int ^ int_accepted;
assign          int_mcause_i = cnt;

// -------------------------------- MAIN BLOCK ---------------------------------

always (posedge clk) begin
    if (reset) begin
        int <= 0;
        cnt <= 0;
    end
    else if (int_accepted == 1'd0) begin
        cnt <= cnt + 32'd1;
    end
    int <= int_accepted;
end

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

module flash(clk, reset, fl_req_i, fl_we_i, reg_addr_i, reg_wdata_i, reg_mask_i,
    reg_rdata_o, fl_int_o, fl_int_rst_i);

input   clk;
/*

*/
input   reset;
/*

*/

input           fl_req_i;
/*
    flash register request
*/
input           fl_we_i;
/*
    write enable register flag
*/
input   [31:0]  reg_addr_i;
/*
    address for flash register write to/read from
*/
input   [31:0]  reg_wdata_i;
/*
    data to write to flash register by `reg_addr_i` address
*/
input   [3:0]   reg_mask_i;
/*
    byte select mask for write by `reg_addr_i` address
*/

output  [31:0]  reg_rdata_o;
/*
    data from flash register by `reg_addr_i`
*/
output          fl_int_o;
/*
    interrupt signal (flash is not generating interrupt signals)
*/
input           fl_int_rst_i;
/*
    interrupt done signal (not used because flash not generating interrupts)
*/

reg     [31:0]  flash [7:0];
/*
    addresses:
        0: 0x84
        1: 0x88
        2: 0x8c
        3: 0x90
        4: 0x94
        5: 0x98
        6: 0x9c
        7: 0xa0
*/

assign reg_rdata_o  = flash[reg_addr_i];
assign fl_int_o     = 1'd0;

always @(posedge clk) begin
    if (reset) begin
        flash[0] <= 31'd0;
        flash[1] <= 31'd0;
        flash[2] <= 31'd0;
        flash[3] <= 31'd0;
        flash[4] <= 31'd0;
        flash[5] <= 31'd0;
        flash[6] <= 31'd0;
        flash[7] <= 31'd0;
    end else begin
        if (fl_req_i) begin
            if (fl_we_i && reg_mask_i[0])
                flash[reg_addr_i[31:2]] [7:0]   <= reg_wdata_i[7:0];

            if (fl_we_i && reg_mask_i[1])
                flash[reg_addr_i[31:2]] [15:8]  <= reg_wdata_i[15:8];

            if (fl_we_i && reg_mask_i[2])
                flash[reg_addr_i[31:2]] [23:16] <= reg_wdata_i[23:16];

            if (fl_we_i && reg_mask_i[3])
                flash[reg_addr_i[31:2]] [31:24] <= reg_wdata_i[31:24];
        end
    end
end

endmodule

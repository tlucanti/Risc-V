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

module keyboard(clk, reset, kb_req_i, kb_we_i, reg_addr_i, reg_wdata_i,
    reg_mask_i, reg_rdata_o, kb_int_o, kb_int_rst_i);

input   clk;
/*

*/
input   reset;
/*

*/

input           kb_req_i;
/*
    keyboard register request
*/
input           kb_we_i;
/*
    write enable register flag
*/
input   [31:0]  reg_addr_i;
/*
    address for keyboard register (here is unused, because keyboard has only one
    register)
*/
input   [31:0]  reg_wdata_i;
/*
    data to write to keyboard register
*/
input   [3:0]   reg_mask_i;
/*
    byte select mask for write to
*/

output  [31:0]  reg_rdata_o;
/*
    data from keyboard register
*/
output  reg     kb_int_o;
/*
    interrupt signal
*/
input           kb_int_rst_i;
/*
    interrupt done signal
*/

reg     [4:0]   cnt;
reg     [7:0]   pressed;
/*
    address - 0x80
*/

assign  reg_rdata_o = pressed;

always @(posedge clk) begin
    if (reset) begin
        kb_int_o    <= 1'b0;
        cnt         <= 4'd0;
    end else begin
        if (kb_req_i) begin
            if (kb_we_i && reg_mask_i[0]) begin
                pressed <= reg_wdata_i[7:0];
            end
        end

        if (kb_int_o && kb_int_rst_i) begin
            kb_int_o <= 1'b0;
        end else if (cnt == 4'b1111) begin
            kb_int_o <= 1'b1;
        end
        if (kb_int_o == 1'b0) begin
            cnt <= cnt + 4'b1;
        end
    end
end

endmodule

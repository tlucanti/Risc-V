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
//  - v1.0 - done for stage-5
//  - v1.1 - add header, change RAM size
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module miriscv_ram
(
  // clock, reset
  input clk_i,
  input rst_n_i,

  // instruction memory interface
  output        [31:0]  instr_rdata_o,
  input         [31:0]  instr_addr_i,

  // data memory interface
  output       [31:0]   data_rdata_o,
  input                 data_req_i,
  input                 data_we_i,
  input         [3:0]   data_be_i,
  input         [31:0]  data_addr_i,
  input         [31:0]  data_wdata_i
);

  localparam    RAM_SIZE = 128;

  reg [31:0]    mem [0:RAM_SIZE-1];

  //Instruction port
  assign instr_rdata_o = mem[instr_addr_i / 4];
  assign data_rdata_o  = mem[data_addr_i / 4];

  always@(posedge clk_i) begin
    if(!rst_n_i) begin
      $readmemh("../../../../../rtl/ram.bin", mem);
    end
    else if(data_req_i) begin
      
      if(data_we_i && data_be_i[0])
        mem [data_addr_i[31:2]] [7:0]  <= data_wdata_i[7:0];

      if(data_we_i && data_be_i[1])
        mem [data_addr_i[31:2]] [15:8] <= data_wdata_i[15:8];

      if(data_we_i && data_be_i[2])
        mem [data_addr_i[31:2]] [23:16] <= data_wdata_i[23:16];

      if(data_we_i && data_be_i[3])
        mem [data_addr_i[31:2]] [31:24] <= data_wdata_i[31:24];

    end
  end


endmodule

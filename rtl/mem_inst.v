`timescale 1ns / 1ps

/* ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
   
   DEPRECATED MODULE, IT NOW REPLACED WITH miriscv_lsu MODULE

*/

////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 10:51:19
// Design Name: RISC-V
// Module Name: mem_inst
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//   Module reads 32 bit instructions from file `prog.s` in hex
//   format and stores them in 1024 bit readonly RAM
//
// Parameters:
//   rst   - reset signal
//   clk   - clock signal
//   pc    - 32 bit program counter: number of current instruction to return
//   instr - 32 bit return value of 32 bit instruction with index equals `pc`
// 
// Dependencies: None
// 
// Revision: deprecated
//   v0.1 - file Created
//   v0.2 - done for stage-2
//   v1.0 - remade for RISC-V i32 instruction set
//   ---- - module deprecated and no longer used
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mem_inst (
   input                rst,
   input                clk,
   input       [31:0]   pc,
   output      [31:0]   instr
);

reg   [31:0]   RAM   [31:0];

always @(posedge clk or posedge rst) begin
   if (rst) begin
      $readmemh("../../../../../rtl/prog.bin", RAM);
   end
end

assign instr = RAM[pc >> 2];

endmodule

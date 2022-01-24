`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2022 18:42:21
// Design Name: 
// Module Name: tb_miriscv_lsu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_miriscv_lsu();


reg clk;
reg reset;
wire [7:0] sw = 8'b00000011;

miriscv_top dut (
    .rst_n_i (~reset),
    .clk_i   (clk   )
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 0;
    @(negedge clk);
    reset = 1;
    repeat(2) begin
      @(negedge clk);
    end
    reset = 0;
    #2000;
    
    $finish();
end
endmodule

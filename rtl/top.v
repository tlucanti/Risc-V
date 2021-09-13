
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: MIET
// Engineer: CHEL
// 
// Create Date: 17.02.2021 14:33:44
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: LOL
// 
////////////////////////////////////////////////////////////////////////////////

module tester (
	input clk,
	input reset,

	output reg out,
	output reg sign,
  output reg [31 : 0] my_cnt
);

reg		[31 : 0]	cnt;
reg					sig;
assign my_cnt = cnt;
always @(posedge clk or posedge reset) begin
  if (reset) begin
          sig <= 0;
		cnt <= 0;
  end
	else begin
          cnt <= cnt + 1;
		case (cnt)
			2:
				sig <= 1;
			3:
				sig <= 0;
			4:
				sig <= 1;
			5:
				sig <= 0;
			6:
				sig <= 0;
			7:
				sig <= 1;
			8:
				sig <= 1;
			9:
				sig <= 1;
			10:
				sig <= 1;
			11:
				sig <= 0;
			12:
				sig <= 0;
			13:
				sig <= 0;
		endcase
	end
end

bipolar_3_level_encode ENCODER (
	.CPU_RESET(reset),
	.CLK(clk),
	.SIGNAL(sig),

	.ENCODED(out),
	.SIGN(sign)
);

endmodule

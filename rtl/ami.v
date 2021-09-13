
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: MIET
// Engineer: CHEL
// 
// Create Date: 17.02.2021 14:33:44
// Design Name: 
// Module Name: nrz
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

module bipolar_3_level_encode (
	input				CPU_RESET,
	input				CLK,
	input				SIGNAL,

	output reg			ENCODED,
	output reg			SIGN

);

// -----------------------------------------------------------------------------
reg						prev;

// -----------------------------------------------------------------------------
always @(posedge CLK or posedge CPU_RESET) begin
	if (CPU_RESET) begin
		SIGN <=1'b0;
	end
	else begin
		if (SIGNAL) begin
                  if (prev == 0) begin
                    SIGN <= 1;
                  end
                  else begin
                  	SIGN <= ~SIGN;
                  end
		  ENCODED <= 1'b0;
		end
		else begin
                  if (prev == 1) begin
                    if (SIGN) begin
                      SIGN <= ~SIGN;
                    end
                  end
			ENCODED <= 1'b1;
		end
		prev <= SIGNAL;
	end
end

endmodule

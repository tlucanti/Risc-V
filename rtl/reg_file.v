`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 10:26:51
// Design Name: RISC-V
// Module Name: mem16_20
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//   module implements 32 registers 32 bit each in 3-port registry file and can
//   store 32 bit value to register by its address and read two 32 bit values by
//   their addresses
// Parameters:
//   rst   - reset signal
//   clk   - clock signal
//   ra1	  - address of first register to read
//   ra2   - address of second register to read
//   wa    - address for register to write
//   we    - flag that allows writing to register
//   rd1   - return value that stores in register with address `ra1`
//   rd2   - return value that stores in register with address `ra2`
//
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

// REGISTRY FILE

module reg_file (
	input						rst,
	input						clk,
	input			[4:0]		ra1,
	input			[4:0]		ra2,
	input			[4:0]		wa,
	input			[31:0]	wd,
	input						we,
	output 		[31:0]	rd1,
	output 		[31:0]	rd2
);

wire	[1023 : 0]	REG;

assign rd1 = read_reg(rd1);
assign rd2 = read_reg(rd2);
assign REG = write_reg(rst, wd, wa, we);

function [31:0] read_reg (input [4:0] ra);
	case (ra)
		5'b00000: read_reg = 32'b0;
		5'b00001: read_reg = REG[  63: 32];
		5'b00010: read_reg = REG[  95: 64];
		5'b00011: read_reg = REG[ 127: 96];
		5'b00100: read_reg = REG[ 159:128];
		5'b00101: read_reg = REG[ 191:160];
		5'b00110: read_reg = REG[ 223:192];
		5'b00111: read_reg = REG[ 255:224];
		5'b01000: read_reg = REG[ 287:256];
		5'b01001: read_reg = REG[ 319:288];
		5'b01010: read_reg = REG[ 351:320];
		5'b01011: read_reg = REG[ 383:352];
		5'b01100: read_reg = REG[ 415:384];
		5'b01101: read_reg = REG[ 447:416];
		5'b01110: read_reg = REG[ 479:448];
		5'b01111: read_reg = REG[ 511:480];
		5'b10000: read_reg = REG[ 543:512];
		5'b10001: read_reg = REG[ 575:544];
		5'b10010: read_reg = REG[ 607:576];
		5'b10011: read_reg = REG[ 639:608];
		5'b10100: read_reg = REG[ 671:640];
		5'b10101: read_reg = REG[ 703:672];
		5'b10110: read_reg = REG[ 735:704];
		5'b10111: read_reg = REG[ 767:736];
		5'b11000: read_reg = REG[ 799:768];
		5'b11001: read_reg = REG[ 831:800];
		5'b11010: read_reg = REG[ 863:832];
		5'b11011: read_reg = REG[ 895:864];
		5'b11100: read_reg = REG[ 927:896];
		5'b11101: read_reg = REG[ 959:928];
		5'b11110: read_reg = REG[ 991:960];
		5'b11111: read_reg = REG[1023:992];
	endcase
endfunction

function [1023:0] write_reg (
	input rst,
	input [31:0] wd,
	input [4:0] wa,
	input we
);
	if (rst) begin
		write_reg = 1024'b0;
	end else if (we) begin
		case (wa)
			5'b00001: write_reg = {REG[1023: 64], wd[31:0], REG[ 31:0]};
			5'b00010: write_reg = {REG[1023: 96], wd[31:0], REG[ 63:0]};
			5'b00011: write_reg = {REG[1023:128], wd[31:0], REG[ 95:0]};
			5'b00100: write_reg = {REG[1023:160], wd[31:0], REG[127:0]};
			5'b00101: write_reg = {REG[1023:192], wd[31:0], REG[159:0]};
			5'b00110: write_reg = {REG[1023:224], wd[31:0], REG[191:0]};
			5'b00111: write_reg = {REG[1023:256], wd[31:0], REG[223:0]};
			5'b01000: write_reg = {REG[1023:288], wd[31:0], REG[255:0]};
			5'b01001: write_reg = {REG[1023:320], wd[31:0], REG[287:0]};
			5'b01010: write_reg = {REG[1023:352], wd[31:0], REG[319:0]};
			5'b01011: write_reg = {REG[1023:384], wd[31:0], REG[351:0]};
			5'b01100: write_reg = {REG[1023:416], wd[31:0], REG[383:0]};
			5'b01101: write_reg = {REG[1023:448], wd[31:0], REG[415:0]};
			5'b01110: write_reg = {REG[1023:480], wd[31:0], REG[447:0]};
			5'b01111: write_reg = {REG[1023:512], wd[31:0], REG[479:0]};
			5'b10000: write_reg = {REG[1023:544], wd[31:0], REG[511:0]};
			5'b10001: write_reg = {REG[1023:576], wd[31:0], REG[543:0]};
			5'b10010: write_reg = {REG[1023:608], wd[31:0], REG[575:0]};
			5'b10011: write_reg = {REG[1023:640], wd[31:0], REG[607:0]};
			5'b10100: write_reg = {REG[1023:672], wd[31:0], REG[639:0]};
			5'b10101: write_reg = {REG[1023:704], wd[31:0], REG[671:0]};
			5'b10110: write_reg = {REG[1023:736], wd[31:0], REG[703:0]};
			5'b10111: write_reg = {REG[1023:768], wd[31:0], REG[735:0]};
			5'b11000: write_reg = {REG[1023:800], wd[31:0], REG[767:0]};
			5'b11001: write_reg = {REG[1023:832], wd[31:0], REG[799:0]};
			5'b11010: write_reg = {REG[1023:864], wd[31:0], REG[831:0]};
			5'b11011: write_reg = {REG[1023:896], wd[31:0], REG[863:0]};
			5'b11100: write_reg = {REG[1023:928], wd[31:0], REG[895:0]};
			5'b11101: write_reg = {REG[1023:960], wd[31:0], REG[927:0]};
			5'b11110: write_reg = {REG[1023:992], wd[31:0], REG[959:0]};
			5'b11111: write_reg = {wd, REG[991:0]};
		endcase
	end else begin
		write_reg = REG;
	end
endfunction

endmodule

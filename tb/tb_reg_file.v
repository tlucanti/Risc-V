`timescale 1ns / 1ps

module tb_reg_file ();

	reg clk;
	reg reset;
	wire [7:0] sw = 8'b00000011;

	risk_5 test (
		.rst(reset),
		.clk(clk),
		.sw(sw)
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
	#1000;
	
	$finish();
end

endmodule

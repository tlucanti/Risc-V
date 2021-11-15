`timescale 1ns / 1ps

module tb_reg_file ();

	reg clk;
	reg reset;
	wire [8:0] sw;

	risk_5 test (
		.rst(reset),
		.clk(clk),
		.sw(sw)
	);
always #5 clk = ~clk;
initial begin
	clk = 0;
	reset = 0;
	@(posedge clk);
	reset = 1;
	repeat(2) begin
	  @(posedge clk);
	end
	reset = 0;
	#100;
	
	$finish();
end

endmodule

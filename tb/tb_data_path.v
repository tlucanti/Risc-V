
module tb_data_path ();

reg clk;
reg reset;
wire [7:0] sw = 8'b00000011;

risc_5	dut(
    .RESET  (reset),
    .CLK    (clk),
    .SW     (sw)
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

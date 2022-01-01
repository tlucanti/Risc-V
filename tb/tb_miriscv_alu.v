`timescale 1ns / 1ps

`ifdef TB_MIRISCV_ALU
`define ALU_OP_WIDTH 7
`define ALU_ADD 6'b011000
`define ALU_SUB 6'b011001
`define ALU_XOR 6'b101111
`define ALU_OR  6'b101110
`define ALU_AND 6'b010101
`define ALU_SRA 6'b100100
`define ALU_SRL 6'b100101
`define ALU_SLL 6'b100111
`define ALU_LTS 6'b000000
`define ALU_LTU 6'b000001
`define ALU_GES 6'b001010
`define ALU_GEU 6'b001011
`define ALU_EQ  6'b001100
`define ALU_NE  6'b001101
`endif

module tb_miriscv_alu();	
	reg [6:0]   operation;
	reg [32:0]  oper_a;
	reg [32:0]  oper_b;
	wire [32:0] result;
	wire        comp_res;
	integer     i 	;
	integer     j;
	reg         flag;
	
	miriscv_alu testing(
	.operator_i(operation),
	.operand_a_i(oper_a),
	.operand_b_i(oper_b),
	.result_o(result),
	.comparison_result_o(comp_res)
	);
	
	initial 
	begin
		$display("Start testing:");
		
		//ADD
		begin
			$display("\tALU_ADD: ");
			operation = `ALU_ADD;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 + 0 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (2 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 + 0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (-2 != result)
				$display("\t\tError 7 test");
			else
				$display("\tADD OK\n");
		end
		//SUB 
		begin
			$display("\tALU_SUB: ");
			operation = `ALU_SUB;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0!= result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (-1 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (-2 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (0 != result)
				$display("\t\tError 7 test");
			else
				$display("\tSUB OK\n");
		end
		//XOR
		begin
			$display("\tALU_XOR: ");
			operation = `ALU_XOR;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (-2 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (0 != result)
				$display("\t\tError 7 test");
			else
				$display("\tXOR OK\n");
		end
		//OR
		begin
			$display("\tALU_OR: ");
			operation = `ALU_OR;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 + 0 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 + 0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (-1 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (-1 != result)
				$display("\t\tError 7 test");
			else
				$display("\tOR OK\n");
		end
		//AND
		begin
			$display("\tALU_AND: ");
			operation = `ALU_AND;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0!= result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (-1 != result)
				$display("\t\tError 7 test");
			else
				$display("\tSUB OK\n");
		end
		//SRA
		begin
			$display("\tALU_SRA: ");
			operation = `ALU_SRA;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (($signed(-1) >>> $signed(1)) != $signed(result))
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (($signed(oper_a) >>> $signed(oper_b)) != $signed(result))
				$display("\t\tError 7 test");
			else
				$display("\tSRA OK\n");
		end
		//SLL
		begin
			$display("\tALU_SLL: ");
			operation = `ALU_SLL;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (2 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 + 0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (-2 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (0 != result)
				$display("\t\tError 7 test");
			else
				$display("\tSLL OK\n");
		end 
		//SRL
		begin
			$display("\tALU_SRL: ");
			operation = `ALU_SRL;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0!= result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 64;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 3 test");
			oper_a <= 16;
			oper_b <= 1;
			#2;
			if (8 != result)
				$display("\t\tError 4 test");
			oper_a <= 8;
			oper_b <= 1;
			#2;
			if (4 != result)
				$display("\t\tError 5 test");
			oper_a <= 'b1000000000000000000000000000001;
			oper_b <= 1;
			#2;
			// if ((oper_a & 'h7fffffff) != result)
			if ('b11111 != result)
				$display("\t\tError 6 test %d", result);
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (0 != result)
				$display("\t\tError 7 test");
			else
				$display("\tSRL OK\n");
		end
		
		//LTS
		begin
			$display("\tALU_LTS: ");
			operation = `ALU_LTS;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (0 != result)
				$display("\t\tError 7 test");
			else
				$display("\tLTS OK\n");
		end
		//LTU
		begin
			$display("\tALU_LTU: ");
			operation = `ALU_LTU;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 + 0 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (0 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (0 + 0 != result)
				$display("\t\tError 5 test");
			oper_a <= 1;
			oper_b <= -1;
			#2;
			if (1 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (0 != result)
				$display("\t\tError 7 test");
			else
				$display("\tLTU OK\n");
		end
		//GES
		begin
			$display("\tALU_GES: ");
			operation = `ALU_GES;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (1 != result)
				$display("\t\tError 7 test");
			else
				$display("\tGES OK\n");
		end
		//GEU
		begin
			$display("\tALU_GEU: ");
			operation = `ALU_GEU;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 1 test");
			oper_a <= 1;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError 2 test");
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (0 != result)
				$display("\t\tError 3 test");
			oper_a <= 1;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 4 test");
			oper_a <= 0;
			oper_b <= -1;
			#2;
			if (0 != result)
				$display("\t\tError 5 test");
			oper_a <= -1;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError 6 test");
			oper_a <= -1;
			oper_b <= -1;
			#2;
			if (1 != result)
				$display("\t\tError 7 test");
			else
				$display("\tGEU OK\n");
		end
		
		begin
			$display("\tALU_EQ:");
			operation = `ALU_EQ;
			oper_a <= 0;
			oper_b <= 0;
			#2;
			if (1 != result)
				$display("\t\tError EQ");
			else
				$display("\tEQ OK\n");
		end
		
		begin
			$display("\tALU_NE:");
			operation = `ALU_NE;
			oper_a <= 0;
			oper_b <= 1;
			#2;
			if (1 != result)
				$display("\t\tError NE");
			else
				$display("\tNE OK\n");
		end
	end

endmodule

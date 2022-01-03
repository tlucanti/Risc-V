`timescale 1ns / 1ps

`include "../rtl/miriscv_defines.v"

module tb_miriscv_decode();

  parameter sleep = 4;
  parameter for_border = 100; // per one opcode

  reg   [31:0]               fetched_instr_i;
  wire  [1:0]                ex_op_a_sel_o;
  wire  [2:0]                ex_op_b_sel_o;
  wire  [`ALU_OP_WIDTH-1:0]  alu_op_o;
  wire                       mem_req_o;
  wire                       mem_we_o;
  wire  [2:0]                mem_size_o;
  wire                       gpr_we_a_o;
  wire                       wb_src_sel_o;
  wire                       illegal_instr_o;
  wire                       branch_o;
  wire                       jal_o;
  wire                       jalr_o;
  reg  [1:0]                 ex_op_a_sel;
  reg  [2:0]                 ex_op_b_sel;
  reg  [`ALU_OP_WIDTH-1:0]   alu_op;
  reg                        mem_req;
  reg                        mem_we;
  reg  [2:0]                 mem_size;
  reg                        gpr_we_a;
  reg                        wb_src_sel;
  reg                        illegal_instr;
  reg                        branch;
  reg                        jal;
  reg                        jalr;

  miriscv_decode dut (
    .fetched_instr_i  (fetched_instr_i),
    .ex_op_a_sel_o    (ex_op_a_sel_o),
    .ex_op_b_sel_o    (ex_op_b_sel_o),
    .alu_op_o         (alu_op_o),
    .mem_req_o        (mem_req_o),
    .mem_we_o         (mem_we_o),
    .mem_size_o       (mem_size_o),
    .gpr_we_a_o       (gpr_we_a_o),
    .wb_src_sel_o     (wb_src_sel_o),
    .illegal_instr_o  (illegal_instr_o),
    .branch_o         (branch_o),
    .jal_o            (jal_o),
    .jalr_o           (jalr_o)
  );

  wire [1:0] op_code_ones;
  wire [2:0] funct3;
  wire [4:0] op_code;
  wire [6:0] funct7;
  assign op_code_ones = fetched_instr_i[1:0];
  assign funct3 = fetched_instr_i[14:12];
  assign op_code = fetched_instr_i[6:2];
  assign funct7 = fetched_instr_i[31:25];

  always @(*) begin
    branch = (&op_code[4:3]) & (~|op_code[2:0]);
    jal = (&op_code[4:3]) & (&(op_code+4'h4));
    jalr = (&op_code[4:3]) & (&{~op_code[2:1], op_code[0]});
    gpr_we_a = (~op_code[3] & ~op_code[1]) |
                   (~op_code[4] &  op_code[2]) |
                   ( op_code[4] &  op_code[0]);
    case (1'b1)
      (~|op_code):
        mem_we = op_code[4];
      (op_code[3] & ~|{op_code[4], op_code[2:0]}):
        mem_we = op_code_ones[0];
      default:
        mem_we = mem_we_o;
    endcase

    mem_req = ~|{op_code[4], op_code[2:0]};
    case (1'b1)
      ~|op_code:
        wb_src_sel = 1'b1;
      ~op_code[4] & op_code[2] & ~op_code[1],
      op_code[4] & op_code[3] & ~op_code[2] & op_code[0]:
        wb_src_sel = 1'b0;
      default: wb_src_sel = wb_src_sel_o;
    endcase

    case (1'b1)
      (~|op_code[1:0]) & (~&op_code[4:2]):
        ex_op_a_sel = op_code[2] ? op_code[1:0] : op_code[2:1];
      &{op_code[4:3], op_code[0], ~op_code[2]}:
        ex_op_a_sel = op_code[1] ? op_code[2:1] : op_code[1:0];
      ~|{op_code[4], op_code[1], ~op_code[2], ~op_code[0]}:
        ex_op_a_sel = op_code[3] ? op_code[2:1] : op_code[1:0];
      default:
        ex_op_a_sel = ex_op_a_sel_o;
    endcase

    case (1'b1)
      (op_code[4]^op_code[2]) & (~|op_code[1:0]) & op_code[3]:
        ex_op_b_sel = op_code[2] ? ~{op_code[3], op_code[3:2]}: op_code[2:0];
      ~|{op_code[4:3], op_code[1:0]}:
        ex_op_b_sel = op_code[4:2] + (~^op_code);
      ~|{op_code[4], op_code[1], ~op_code[2], ~op_code[0]}:
        ex_op_b_sel = ~op_code[2:0];
      ~|{op_code[2:0], op_code[4]} & op_code[3]:
        ex_op_b_sel = {op_code[1], op_code_ones};
      &{op_code[4:3], ~op_code[2], op_code[0]}:
        ex_op_b_sel = op_code[3:1] - op_code[1];
      default:
        ex_op_b_sel = ex_op_b_sel_o;
    endcase

    illegal_instr = ~&op_code_ones;
    case (1'b1)
      ~|{op_code[2:0], op_code[4]}: begin
        if (~illegal_instr)
          illegal_instr = op_code[3] ? (funct3[2] | (&funct3[1:0])) :
                                   (&funct3[1:0] | &funct3[2:1]);
        mem_size = funct3;
      end
      default:
        mem_size = mem_size_o;
    endcase

    casez (op_code)
      5'b0?000,
      5'b110?1,
      5'b00101: begin
        alu_op = `ALU_ADD;
        if (op_code[4] & ~op_code[1] & |funct3)
          illegal_instr = 1'b1;
      end

      `OP_IMM_OPCODE: begin
        casez ({funct7, funct3})
          {7'h??, 3'h0}: alu_op = `ALU_ADD;
          {7'h00, 3'h1}: alu_op = `ALU_SLL;
          {7'h??, 3'h2}: alu_op = `ALU_SLTS;
          {7'h??, 3'h3}: alu_op = `ALU_SLTU;
          {7'h??, 3'h4}: alu_op = `ALU_XOR;
          {7'h00, 3'h5}: alu_op = `ALU_SRL;
          {7'h20, 3'h5}: alu_op = `ALU_SRA;
          {7'h??, 3'h6}: alu_op = `ALU_OR;
          {7'h??, 3'h7}: alu_op = `ALU_AND;
          default: illegal_instr = 1'b1;
        endcase
      end

      `OP_OPCODE: begin
        case ({funct7, funct3})
          {7'h00, 3'h0}: alu_op = `ALU_ADD;
          {7'h20, 3'h0}: alu_op = `ALU_SUB;
          {7'h00, 3'h1}: alu_op = `ALU_SLL;
          {7'h00, 3'h2}: alu_op = `ALU_SLTS;
          {7'h00, 3'h3}: alu_op = `ALU_SLTU;
          {7'h00, 3'h4}: alu_op = `ALU_XOR;
          {7'h00, 3'h5}: alu_op = `ALU_SRL;
          {7'h20, 3'h5}: alu_op = `ALU_SRA;
          {7'h00, 3'h6}: alu_op = `ALU_OR;
          {7'h00, 3'h7}: alu_op = `ALU_AND;
          default: illegal_instr = 1'b1;
        endcase
        if (~illegal_instr) begin
        end
      end

      `LUI_OPCODE: begin
        if (~illegal_instr) begin
          casez (alu_op_o)
            `ALU_ADD,
            `ALU_OR,
            `ALU_XOR:
              alu_op = alu_op_o;
            default: alu_op = `ALU_ADD;
          endcase
        end
      end

      `BRANCH_OPCODE: begin
        case (funct3)
          3'h0: alu_op = `ALU_EQ;
          3'h1: alu_op = `ALU_NE;
          3'h4: alu_op = `ALU_LTS;
          3'h5: alu_op = `ALU_GES;
          3'h6: alu_op = `ALU_LTU;
          3'h7: alu_op = `ALU_GEU;
          default: illegal_instr = 1'b1;
        endcase
      end

      `MISC_MEM_OPCODE,
      `SYSTEM_OPCODE: begin
        alu_op = alu_op_o;
      end

      default: illegal_instr = 1'b1;
    endcase

    if (illegal_instr) begin
      ex_op_a_sel = ex_op_a_sel_o;
      ex_op_b_sel = ex_op_b_sel_o;
      alu_op = alu_op_o;
      mem_we = mem_we_o;
      mem_req = 1'b0;
      mem_size = mem_size_o;
      wb_src_sel = wb_src_sel_o;
      gpr_we_a = 1'b0;
      branch = 1'b0;
      jal = 1'b0;
      jalr = 1'b0;
    end

  end

  reg [4:0] X;
  reg [$clog2(for_border+1)-1:0] V;
  integer error_cnt;

  initial begin
    $timeformat(-9, 2, " ns");
    error_cnt = 0;
  end


  always begin
    for (X=0; X<2**5-1; X=X+1) begin
      for (V=0; V<for_border; V=V+1) begin
        fetched_instr_i[1:0]  = 2'b11;
        fetched_instr_i[6:2]  = X;
        fetched_instr_i[31:7] = $random;
        #sleep;
      end
    end
    for (V=0; V<for_border; V=V+1) begin
      fetched_instr_i = $random;
      #sleep;
    end

    if (|error_cnt)
      $display ("FAIL!\nThere are errors in the design, number of errors: %d", error_cnt);
    else
      $display ("SUCCESS!");
    $finish;
  end

  always begin
    @(fetched_instr_i);
    #1;
    if (not_equal(illegal_instr_o, illegal_instr))
      $display("Output 'illegal_instr_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
    if (~illegal_instr_o) begin
      if (not_equal(ex_op_a_sel_o, ex_op_a_sel))
        $display ("Output 'ex_op_a_sel_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(ex_op_b_sel_o, ex_op_b_sel))
        $display ("Output 'ex_op_b_sel_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(alu_op_o, alu_op))
        $display ("Output 'alu_op_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(mem_we_o, mem_we))
        $display ("Output 'mem_we_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(mem_size_o, mem_size))
        $display ("Output 'mem_size_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(mem_req_o, mem_req))
        $display ("Output 'mem_req_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(wb_src_sel_o, wb_src_sel))
        $display ("Output 'wb_src_sel_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(gpr_we_a_o, gpr_we_a))
        $display ("Output 'gpr_we_a_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(branch_o, branch))
        $display ("Output 'branch_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(jal_o, jal))
        $display ("Output 'jal_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
      if (not_equal(jalr_o, jalr))
        $display ("Output 'jalr_o' is incorrect, instruction: %x, time: %t", fetched_instr_i, $time);
    end

    if ((ex_op_a_sel_o != `OP_A_RS1) &
        (ex_op_a_sel_o != `OP_A_CURR_PC) &
        (ex_op_a_sel_o != `OP_A_ZERO)) begin
      $display ("Output 'ex_op_a_sel_o' must always have a legal value, instruction: %x, time: %t", fetched_instr_i, $time);
      error_cnt = error_cnt + 1;
    end
    if ((ex_op_b_sel_o != `OP_B_RS2) &
        (ex_op_b_sel_o != `OP_B_IMM_I) &
        (ex_op_b_sel_o != `OP_B_IMM_U) &
        (ex_op_b_sel_o != `OP_B_IMM_S) &
        (ex_op_b_sel_o != `OP_B_INCR)) begin
      $display ("Output 'ex_op_b_sel_o' must always have a legal value, instruction: %x, time: %t", fetched_instr_i, $time);
      error_cnt = error_cnt + 1;
    end
    if ((alu_op_o != `ALU_ADD)  & (alu_op_o != `ALU_SUB) &
        (alu_op_o != `ALU_XOR)  & (alu_op_o != `ALU_OR)  &
        (alu_op_o != `ALU_AND)  & (alu_op_o != `ALU_SRA) &
        (alu_op_o != `ALU_SRL)  & (alu_op_o != `ALU_SLL) &
        (alu_op_o != `ALU_LTS)  & (alu_op_o != `ALU_LTU) &
        (alu_op_o != `ALU_GES)  & (alu_op_o != `ALU_GEU) &
        (alu_op_o != `ALU_EQ)   & (alu_op_o != `ALU_NE)  &
        (alu_op_o != `ALU_SLTS) & (alu_op_o != `ALU_SLTU)) begin
      $display ("Output 'alu_op_o' must always have a legal value, instruction: %x, time: %t", fetched_instr_i, $time);
      error_cnt = error_cnt + 1;
    end
    if ((mem_size_o != `LDST_B) &
        (mem_size_o != `LDST_H) &
        (mem_size_o != `LDST_W) &
        (mem_size_o != `LDST_BU) &
        (mem_size_o != `LDST_HU)) begin
      $display ("Output 'mem_size_o' must always have a legal value, instruction: %x, time: %t", fetched_instr_i, $time);
      error_cnt = error_cnt + 1;
    end
    if ((wb_src_sel_o != `WB_EX_RESULT) &
        (wb_src_sel_o != `WB_LSU_DATA)) begin
      $display ("Output 'wb_src_sel_o' must always have a legal value, instruction: %x, time: %t", fetched_instr_i, $time);
      error_cnt = error_cnt + 1;
    end
  end

  function not_equal;
    input [31:0] first_arg, second_arg;
    if (first_arg === second_arg)
      not_equal = 1'b0;
    else begin
      not_equal = 1'b1;
      error_cnt = error_cnt + 1'b1;
    end
  endfunction

endmodule

`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 20.11.2021 15:13:33
// Design Name: RISC-V
// Module Name: riscv_csr
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//
// Parameters:
//
// Dependencies:
// 
// Revision: v1.0
//  - v0.1 - file Created
//  - v1.0 - done for stage-6
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module miriscv_csr(clk, reset, csr_opcode_i, csr_mcause_i, csr_pc_i,
    csr_address_i, csr_write_data_i, csr_mie_o, csr_mtvec_o, csr_mepc_o,
    csr_read_data_o);

// ---------------------------------- CSR I/O ----------------------------------
input           clk;
/*

*/
input           reset;
/*

*/

input   [2:0]   csr_opcode_i;
/*
    opcode for csr
    csr_opcode_i[2]:
      1: new interrupt occured, and `csr_pc_i` will be placed to `mepc` register
        and `csr_mcause_i` will be placed to `mcause` register
      0: currently no interruptions

    csr_opcode_i[1:0]:
      00: csr is disabled
      01: csrrw instruction operation
      10: csrrs instruction operation
      11: csrrc instruction operation
*/
input   [31:0]  csr_mcause_i;
/*
    interrupt cause (from interrupt controller)
*/
input   [31:0]  csr_pc_i;
/*
    program counter value to save it to `mepc` register
*/
input   [11:0]  csr_address_i;
/*
    address of csr register to read/write from
*/
input   [31:0]  csr_write_data_i;
/*
    data to write to csr registers
*/

output  [31:0]  csr_mie_o;
/*
    mask interrupt enable - mask shows which interrupts are disabled or enabled
*/
output  [31:0]  csr_mtvec_o;
/*
    forwarded value from mtvec register
*/
output  [31:0]  csr_mepc_o;
/*
    forwaeded value from mepc register
*/
output  [31:0]  csr_read_data_o;
/*
    data read from register by `address` address
*/

// =============================================================================
// --------------------------------- REGISTERS ---------------------------------
reg     [31:0]  mie;
/*
    machine interrupt-enable register - mask shows which interrupts are disabled
    or enabled
*/
reg     [31:0]  mtvec;
/*
    machine trap-handler base address - addres of interrupt handler subroutine
*/
reg     [31:0]  mscratch;
/*
    scratch register for trap handlers - address of stack top for interrupt
    handler to save registers values
*/
reg     [31:0]  mepc;
/*
    machine exception program counter - address of instruction where exception
    accured
*/
reg     [31:0]  mcause;
/*
    machine trap cause - id of interrution
*/

// -------------------------------- WIRE ASSIGNS -------------------------------
assign  csr_mie_o       = mie;
assign  csr_mtvec_o     = mtvec;
assign  csr_mepc_o      = mepc;
assign  csr_read_data_o = get_reg(csr_address_i);

// -------------------------------- MAIN BLOCK ---------------------------------

always @(posedge clk) begin
    if (reset) begin
        mie         <= ~(32'd0);
        mtvec       <= 32'd0;
        mscratch    <= 32'd0;
        mepc        <= 32'd0;
        mcause      <= 32'd0;
    end else if (csr_opcode_i[2]) begin
        mepc        <= csr_pc_i;
        mcause      <= csr_mcause_i;
    end else if (csr_opcode_i != 2'd0) begin
        case (csr_address_i)
            12'h304: mie      <= do_instr(mie);
            12'h305: mtvec    <= do_instr(mtvec);
            12'h340: mscratch <= do_instr(mscratch);
            12'h341: mepc     <= do_instr(mepc);
            12'h342: mcause   <= do_instr(mcause);
        endcase
    end
end

// --------------------------------- FUNCTIONS ---------------------------------
function automatic [31:0] do_instr;
/*

*/
    input   [31:0]  reg_val;

    begin
        case (csr_opcode_i[1:0])
            2'd1: do_instr = csr_write_data_i;
            2'd2: do_instr = csr_write_data_i | reg_val;
            2'd3: do_instr = ~csr_write_data_i & reg_val;
        endcase
    end
endfunction

function automatic [31:0] get_reg;
/*

*/
    input   [11:0]  address;

    begin
        case (address)
            12'h304: get_reg = mie;
            12'h305: get_reg = mtvec;
            12'h340: get_reg = mscratch;
            12'h341: get_reg = mepc;
            12'h342: get_reg = mcause;
            default: get_reg = 32'd0;
        endcase
    end
endfunction

endmodule

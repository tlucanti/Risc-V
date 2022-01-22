`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Miet
// Engineer: Kostya
// 
// Create Date: 25.09.2021 11:05:30
// Design Name: RISC-V
// Module Name: miriscv_ram
// Project Name: RISC-V
// Target Devices: any
// Tool Versions: 2021.2
// Description:
//   sync module
//   module implements random access memory with interface for risc-v processor
// Parameters:
//   RESET      - reset signal
//   CLK        - clock signal
//   mem_addr_i - address of memory to read or write to
//   mem_data_i - data to write by `mem_addr_i` address
//   mem_req_i  - memory enable flag
//   mem_we_i   - memory read/write switch 1 - write `mem_data_i` to
//     `mem_addr_i` address, 0 - read from `mem_addr_i` address to `mem_data_o`
//   mem_size_i - size of read/write address:
//     3'd0: signed byte (8 bit)
//     3'd1: signed half (16 bit)
//     3'd2: word (32 bit)
//     3'd4: unsigned byte (8 bit)
//     3'd5: unsigned half (16 bit)
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module miriscv_ram_my (
    input           clk,
    input           reset,
    input   [31:0]  mem_addr_i,
    input   [31:0]  mem_data_i,
    input           mem_req_i,
    input           mem_we_i,
    input   [2:0]   mem_size_i,
    output  [31:0]  mem_data_o
);

reg [31 : 0]    RAM [0:16];

assign  mem_data_o = get_mem(mem_addr_i, mem_size_i);

function automatic [31:0] get_mem;
/*
    return memory value of giving size sign or unsigned extended by `mem_addr_i`
    address, or write `mem_data_i` cut to giving size to `mem_addr_i` address
*/
    input   [31:0]  mem_addr;
    input   [2:0]   mem_size;

    begin
        case (mem_size)
            3'd0: get_mem = sign_8extend(RAM[mem_addr][7:0]);
            3'd1: get_mem = sign_16extend(RAM[mem_addr][15:0]);
            3'd2: get_mem = RAM[mem_addr];
            3'd4: get_mem = RAM[mem_addr][7:0];
            3'd5: get_mem = RAM[mem_addr][15:0];
            default: get_mem = 31'd0;
        endcase
    end
endfunction

always @(posedge clk or posedge reset) begin
    if (reset)
        $readmemh("../../../../../rtl/ram.bin", RAM);
    else begin
        if (mem_we_i) begin
            case (mem_size_i)
                3'd0: RAM[mem_addr_i][ 7:0] <= mem_data_i[7:0];
                3'd1: RAM[mem_addr_i][15:0] <= mem_data_i[15:0];
                3'd2: RAM[mem_addr_i]       <= mem_data_i;
            endcase
        end
    end
end

function automatic [31:0] sign_8extend;
    input [7:0] val;
    begin
        sign_8extend = {{24{val[7]}}, val[7:0]};
    end
endfunction

function automatic [31:0] sign_16extend;
    input [15:0] val;
    begin
        sign_16extend = {{16{val[15]}}, val[15:0]};
    end
endfunction

endmodule

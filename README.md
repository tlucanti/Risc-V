# RISC-V CPU

### implementation of RB32I in verilog

RISC-V single-stroke processor with i32 extension with support of hardware and software interrupts and DMA module for peripheral devices (in Verilog)

### Supported instructions
| Instr | Type | Opcode  | funct3 | funct7 | Explain | Comment |
| ----- |:----:|:-------:|:------:|:------:| ------- | ------- |
| lui   | U    | 0110111 |   -    |   -    |         |         |
| auipc | U    | 0010111 |   -    |   -    |         |         |
| jal   | J    | 1101111 |   -    |   -    |         |         |
| jalr  | I    |    ^    |  000   |   -    |         |         |
| beq   | B    | 1100011 |   -    |   -    |         |         |
| bne   | B    |    ^    |   -    |   -    |         |         |
| blt   | B    |    ^    |   -    |   -    |         |         |
| bge   | B    |    ^    |   -    |   -    |         |         |
| bltu  | B    |    ^    |   -    |   -    |         |         |
| bgeu  | B    |    ^    |   -    |   -    |         |         |
| lb    | I    | 0000011 |  000   |   -    |         |         |
| lh    | I    |    ^    |  001   |   -    |         |         |
| lb    | I    |    ^    |  010   |   -    |         |         |
| lbu   | I    |    ^    |  100   |   -    |         |         |
| lwu   | I    |    ^    |  101   |   -    |         |         |
| sb    | S    | 0100011 |  000   |   -    |         |         |
| sh    | S    |    ^    |  001   |   -    |         |         |
| sw    | S    |    ^    |  010   |   -    |         |         |
| addi  | I    | 0010011 |  000   |   -    |         |         |
| slti  | I    |    ^    |  010   |   -    |         |         |
| sltiu | I    |    ^    |  011   |   -    |         |         |
| xori  | I    |    ^    |  100   |   -    |         |         |
| ori   | I    |    ^    |  110   |   -    |         |         |
| andi  | I    |    ^    |  111   |   -    |         |         |
| slli  | R    | 0010011 |  001   |  0x0   |         |         |
| srli  | R    |    ^    |  101   |  0x0   |         |         |
| srai  | R    |    ^    |  101   |  0x20  |         |         |
| add   | R    | 0110011 |  000   |  0x0   |         |         |
| sub   | R    |    ^    |  000   |  0x20  |         |         |
| sll   | R    |    ^    |  001   |  0x0   |         |         |
| slt   | R    |    ^    |  010   |  0x0   |         |         |
| sltu  | R    |    ^    |  011   |  0x0   |         |         |
| xor   | R    |    ^    |  100   |  0x0   |         |         |
| slr   | R    |    ^    |  101   |  0x0   |         |         |
| sra   | R    |    ^    |  101   |  0x20  |         |         |
| or    | R    |    ^    |  110   |  0x0   |         |         |
| and   | R    |    ^    |  111   |  0x0   |         |         |
| fence | I    | 0001111 |  000   |  0x0   |         |         |
| fenceI| I    |    ^    |  001   |  0x0   |         |         |
| ecall | I    | 1110011 |  000   |  0x0   |         |         |
| ebreak| I    |    ^    |  000   |  0x1   |         |         |
| csrrw | I    | 1110011 |  001   |  csr   |         |         |
| csrrs | I    | 1110011 |  010   |  csr   |         |         |
| csrrc | I    | 1110011 |  011   |  csr   |         |         |
| csrrwi| I    | 1110011 |  101   |  csr   |         |         |
| csrrsi| I    | 1110011 |  110   |  csr   |         |         |
| csrrci| I    | 1110011 |  111   |  csr   |         |         |



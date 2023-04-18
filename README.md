# RISC-V CPU

### implementation of RB32I in verilog

RISC-V single-stroke processor with i32 extension with support of hardware and software interrupts and DMA module for peripheral devices (in Verilog)

### Supported instructions
| Instr | Type | Opcode  | funct3 | funct7 | Explain                                | Comment |
| ----- |:----:|:-------:|:------:|:------:| -------------------------------------- | ------- |
| lui   | U    | 0110111 |   -    |   -    | load upper immidiate                   |         |
| auipc | U    | 0010111 |   -    |   -    | add upper immidiate to pc              |         |
| jal   | J    | 1101111 |   -    |   -    | jump and link                          |         |
| jalr  | I    |    ^    |  000   |   -    | jump and link register                 |         |
| beq   | B    | 1100011 |   -    |   -    | brench if equal                        |         |
| bne   | B    |    ^    |   -    |   -    | branch if not equal                    |         |
| blt   | B    |    ^    |   -    |   -    | branch if less than                    |         |
| bge   | B    |    ^    |   -    |   -    | branch if greater or equal             |         |
| bltu  | B    |    ^    |   -    |   -    | branch if less than (unsigned)         |         |
| bgeu  | B    |    ^    |   -    |   -    | branch if greater or equal (unsigned)  |         |
| lb    | I    | 0000011 |  000   |   -    | load byte                              |         |
| lh    | I    |    ^    |  001   |   -    | load half                              |         |
| lw    | I    |    ^    |  010   |   -    | load word                              |         |
| lbu   | I    |    ^    |  100   |   -    | load byte (unsigned)                   |         |
| lhu   | I    |    ^    |  101   |   -    | load half (unsigned)                   |         |
| sb    | S    | 0100011 |  000   |   -    | store byte                             |         |
| sh    | S    |    ^    |  001   |   -    | store half                             |         |
| sw    | S    |    ^    |  010   |   -    | store word                             |         |
| addi  | I    | 0010011 |  000   |   -    | add immidiate                          |         |
| slti  | I    |    ^    |  010   |   -    | set less than immidiate                |         |
| sltiu | I    |    ^    |  011   |   -    | set less than immidiate (unsigned)     |         |
| xori  | I    |    ^    |  100   |   -    | bit xor with immidiate                 |         |
| ori   | I    |    ^    |  110   |   -    | bit or with immidiate                  |         |
| andi  | I    |    ^    |  111   |   -    | bit and with immidiate                 |         |
| slli  | R    | 0010011 |  001   |  0x0   | shift left logical to immidiate        |         |
| srli  | R    |    ^    |  101   |  0x0   | shift right logical to immidiate       |         |
| srai  | R    |    ^    |  101   |  0x20  | shift right arithmetic to immidiate    |         |
| add   | R    | 0110011 |  000   |  0x0   | add                                    |         |
| sub   | R    |    ^    |  000   |  0x20  | substruct                              |         |
| sll   | R    |    ^    |  001   |  0x0   | shift left logical                     |         |
| slt   | R    |    ^    |  010   |  0x0   | set less than                          |         |
| sltu  | R    |    ^    |  011   |  0x0   | set less than (unsigned)               |         |
| xor   | R    |    ^    |  100   |  0x0   | bit xor                                |         |
| srl   | R    |    ^    |  101   |  0x0   | shift right logical                    |         |
| sra   | R    |    ^    |  101   |  0x20  | shift right arithmetic                 |         |
| or    | R    |    ^    |  110   |  0x0   | bit or                                 |         |
| and   | R    |    ^    |  111   |  0x0   | bit and                                |         |
| fence | I    | 0001111 |  000   |  0x0   | memory fence                           |         |
| fenceI| I    |    ^    |  001   |  0x0   | memory fence                           |         |
| ecall | I    | 1110011 |  000   |  0x0   | enviroment call                        |         |
| ebreak| I    |    ^    |  000   |  0x1   | enviroment break                       |         |
| csrrw | I    | 1110011 |  001   |  csr   | control status register read/write     |         |
| csrrs | I    | 1110011 |  010   |  csr   | control status register set bits       |         |
| csrrc | I    | 1110011 |  011   |  csr   | control status register clear bits     |         |
| csrrwi| I    | 1110011 |  101   |  csr   | control status register write immidiate|         |
| csrrsi| I    | 1110011 |  110   |  csr   | control status register set immidiate  |         |
| csrrci| I    | 1110011 |  111   |  csr   | control status register clear immidiate|         |

- fence and fenceI instructions are interpreted as NOP
- ecall and ebreak instructions are raises trap

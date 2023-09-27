# RISC-V CPU

## implementation of RB32I in verilog

RISC-V 32bit single-stroke processor with i32 extension
with support of hardware and software interrupts
and DMA module for peripheral devices (in Verilog)

### Overview
Processor has 32 bit ALU and standard triple-ported
register file with 32 general purpuse 32-bit registers
ans x0 register always zero.
It can execute basic binary code compiled from
RISC-V assembly language.
Processor uses Harvard architecture,
so instructions are stored in instruction memory
and program data is stored in main memory

### Memory
Processor has builtin main memory (inside the processor itself).
Memory size is 0.5 kiB or 512 bytes or 128 32-bit words.
Memory size can be increased up to 2^32 32-bit words or 16 GiB
Processor has no protection in memory so,
it is possible to overwrite existing intructions in RAM.

### General Interface
processor has 2 input wires:
 - 1 bit clock
 - 1 bit negative reset signal

### Compilation

### Start
After start (or reset) processor loads
instsructions from constant memory to
RAM and sets its program counter to 0 address
and starts to execute instructions

### Interrpts
Processor supports multilevel software
and hardware interruptions with control status regissters manipulations.
Processor supports two types of interrupts:
 - hardware interrupts (caused by external devices)
 - software interrupts (caused by ecall/ebreak instruction)
Interrupt bus has no synchronization or any arbiter

### Control Status Registers
Processor has control status registers
to keep information about interrupts.
Interrupts can be disabled using
interrupt mask stored in `mie` register.
When interrupt occurs its cause is written to CSR mcause register.
After interrupt program counter is set
to value inside `mtvec` register added
to cause of interrupt (`mcause` register value).
Current program counter is saved to `mepc` register.
Current context is saved on stack.
Stack pointer is placed in `mscratch` register.
Registers `mie`, `mtvec`, `mscratch` are should be set
by user after processor started.

### External devices
Repository has a few builtin external devices
 - Flash memory with same interface as builtin memory.
   Flash memory size is 8 32-bit words or 256 bytes.
   Flash memory size can be increased up to 2^32 bytes or 2 GiB.
 - Keyboard implementation with 256 keys and
   interrupt support for pressed buttons.
 - Interrupt controller as external module.

### Memory interface
Processor communicates with builtin main memory
using control 3 bit bus and thee 32 bit data/address busses.
Control bus has 5 states to select
width and signedness of word in memory:
 - 0b000 - signed 8 bit
 - 0b001 - signed 16 bit
 - 0b010 - 32 bit value
 - 0b100 - unsigned 8 bit
 - 0b101 - unsigned 16 bit
Every access to memory is completed in one clock
(as well as any other instruction)

### Supported instructions
| Instr | Type | Opcode  | funct3 | funct7 | Explain                                |
| ----- |:----:|:-------:|:------:|:------:| -------------------------------------- |
| lui   |  U   | 0110111 |   -    |   -    | load upper immidiate                   |
| auipc |  U   | 0010111 |   -    |   -    | add upper immidiate to pc              |
| jal   |  J   | 1101111 |   -    |   -    | jump and link                          |
| jalr  |  I   |    ^    |  000   |   -    | jump and link register                 |
| beq   |  B   | 1100011 |   -    |   -    | brench if equal                        |
| bne   |  B   |    ^    |   -    |   -    | branch if not equal                    |
| blt   |  B   |    ^    |   -    |   -    | branch if less than                    |
| bge   |  B   |    ^    |   -    |   -    | branch if greater or equal             |
| bltu  |  B   |    ^    |   -    |   -    | branch if less than (unsigned)         |
| bgeu  |  B   |    ^    |   -    |   -    | branch if greater or equal (unsigned)  |
| lb    |  I   | 0000011 |  000   |   -    | load byte                              |
| lh    |  I   |    ^    |  001   |   -    | load half                              |
| lw    |  I   |    ^    |  010   |   -    | load word                              |
| lbu   |  I   |    ^    |  100   |   -    | load byte (unsigned)                   |
| lhu   |  I   |    ^    |  101   |   -    | load half (unsigned)                   |
| sb    |  S   | 0100011 |  000   |   -    | store byte                             |
| sh    |  S   |    ^    |  001   |   -    | store half                             |
| sw    |  S   |    ^    |  010   |   -    | store word                             |
| addi  |  I   | 0010011 |  000   |   -    | add immidiate                          |
| slti  |  I   |    ^    |  010   |   -    | set less than immidiate                |
| sltiu |  I   |    ^    |  011   |   -    | set less than immidiate (unsigned)     |
| xori  |  I   |    ^    |  100   |   -    | bit xor with immidiate                 |
| ori   |  I   |    ^    |  110   |   -    | bit or with immidiate                  |
| andi  |  I   |    ^    |  111   |   -    | bit and with immidiate                 |
| slli  |  R   | 0010011 |  001   |  0x0   | shift left logical to immidiate        |
| srli  |  R   |    ^    |  101   |  0x0   | shift right logical to immidiate       |
| srai  |  R   |    ^    |  101   |  0x20  | shift right arithmetic to immidiate    |
| add   |  R   | 0110011 |  000   |  0x0   | add                                    |
| sub   |  R   |    ^    |  000   |  0x20  | substruct                              |
| sll   |  R   |    ^    |  001   |  0x0   | shift left logical                     |
| slt   |  R   |    ^    |  010   |  0x0   | set less than                          |
| sltu  |  R   |    ^    |  011   |  0x0   | set less than (unsigned)               |
| xor   |  R   |    ^    |  100   |  0x0   | bit xor                                |
| srl   |  R   |    ^    |  101   |  0x0   | shift right logical                    |
| sra   |  R   |    ^    |  101   |  0x20  | shift right arithmetic                 |
| or    |  R   |    ^    |  110   |  0x0   | bit or                                 |
| and   |  R   |    ^    |  111   |  0x0   | bit and                                |
| fence |  I   | 0001111 |  000   |  0x0   | memory fence                           |
| fenceI|  I   |    ^    |  001   |  0x0   | memory fence                           |
| ecall |  I   | 1110011 |  000   |  0x0   | enviroment call                        |
| ebreak|  I   |    ^    |  000   |  0x1   | enviroment break                       |
| csrrw |  I   |    ^    |  001   |  csr   | control status register read/write     |
| csrrs |  I   |    ^    |  010   |  csr   | control status register set bits       |
| csrrc |  I   |    ^    |  011   |  csr   | control status register clear bits     |
| csrrwi|  I   |    ^    |  101   |  csr   | control status register write immidiate|
| csrrsi|  I   |    ^    |  110   |  csr   | control status register set immidiate  |
| csrrci|  I   |    ^    |  111   |  csr   | control status register clear immidiate|
| mret  |  I   |    ^    |  000   | 0x302  | return from interrupt                  |

- `fence` and `fenceI` instructions are interpreted as `NOP` due to sequential consistency of processor
- `ecall` and `ebreak` instructions are raises interruption
- `func7`value of the `mret` instruction is need to be zero extended and set to `imm[11:0]` field


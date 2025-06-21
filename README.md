# SimpleCPU Instruction Set Architecture (ISA)

## Registers

- 32 General Purpose Registers: R0–R31
- R0 is hardwired to 0 (reads always return 0, writes are ignored)

## Instruction Format

All instructions are 32 bits wide.

### R-Type Format (Register)

Fields: opcode (6) | rs (5) | rt (5) | rd (5) | shamt (5) | funct (6)

### I-Type Format (Immediate)

Fields: opcode (6) | rs (5) | rt (5) | immediate (16)

### J-Type Format (Jump)

Fields: opcode (6) | address (26)

## Instruction Set

R-Type Instructions:

- ADD : rd = rs + rt (opcode: 000000, funct: 100000)
- SUB : rd = rs - rt (opcode: 000000, funct: 100010)
- AND : rd = rs & rt (opcode: 000000, funct: 100100)
- OR : rd = rs | rt (opcode: 000000, funct: 100101)
- SLT : rd = (rs < rt) (opcode: 000000, funct: 101010)

I-Type Instructions:

- ADDI : rt = rs + imm (opcode: 001000)
- LW : rt = MEM[rs + imm] (opcode: 100011)
- SW : MEM[rs + imm] = rt (opcode: 101011)
- BEQ : if rs==rt, PC += imm << 2 (opcode: 000100)

J-Type Instructions:

- J : PC = {PC[31:28], address, 00} (opcode: 000010)

## Example Program

ADDI R1, R0, 5
ADDI R2, R0, 10
ADD R3, R1, R2
SW R3, 0(R0)
LW R4, 0(R0)
BEQ R1, R2, label
J end
label:
ADDI R5, R0, 100
end:
HALT

## Notes

- Immediate is sign-extended to 32 bits before use.
- BEQ uses PC-relative addressing: PC = PC + 4 + (imm << 2)
- Jump replaces lower 28 bits of PC: PC = {PC[31:28], address, 00}
- Memory is word-addressable and 32-bit wide.

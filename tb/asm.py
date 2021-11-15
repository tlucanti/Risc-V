# -*- coding: utf-8 -*-
# @Author: kostya
# @Date:   2021-11-15 15:18:12
# @Last Modified by:   kostya
# @Last Modified time: 2021-11-16 01:10:11

import sys

REGISTER_NUMBER = 32
IMMIDIATE_LIMIT = 255

class Instruction(object):
	"""
	A class used to code instruction using numeric values for registers,
	immidiate, alu operation, jump flags and data source flags

	instruction components:

	┌──┬──┬──┬─────┬───────────┬──────────────┬──────────────┬────────────┬───────────────┐
	│31│30│29│28 27│26 25 24 23│22 21 20 19 18│17 16 15 14 13│12 11 10 9 8│7 6 5 4 3 2 1 0│
	└┬─┴┬─┴┬─┴┬────┴┬──────────┴┬─────────────┴┬─────────────┴┬───────────┴┬──────────────┘
	 │  │  │  │     │           │              │              │            └─ [const] 8 bit Immidiate value 
	 │  │  │  │     │           │              │              └─ [WA] 6 bit address of the register in the register file
	 │  │  │  │     │           │              │                 where the record will be made
     │  │  │  │     │           │              └─ [RA2] 6 bit address in register file for the second operand of the alu
     │  │  │  │     │           └─ [RA1] 6 bit address in register file for the first operand of the alu
     │  │  │  │     └─ [ALUop] the operation code to perform on the alu
     │  │  │  │        alu operations:
     │  │  │  │        ┌───────┬───────┬────────────────┐
     │  │  │  │        │op-code│op-name│op-visualisation│
     │  │  │  │        ├───────┼───────┼────────────────┤
     │  │  │  │        │  0000 │ALU_LTS│ <              │
     │  │  │  │        │  0001 │ALU_LTU│ <u             │
     │  │  │  │        │  0010 │       │                │
     │  │  │  │        │  0011 │       │                │
     │  │  │  │        │  0100 │       │                │
     │  │  │  │        │  0101 │       │                │
     │  │  │  │        │  0110 │       │                │
     │  │  │  │        │  0111 │       │                │
     │  │  │  │        │  1000 │       │                │
     │  │  │  │        │  1001 │       │                │
     │  │  │  │        │  1010 │       │                │
     │  │  │  │        │  1011 │       │                │
     │  │  │  │        │  1100 │       │                │
     │  │  │  │        │  1101 │       │                │
     │  │  │  │        │  1110 │       │                │
     │  │  │  │        │  1111 │       │                │
     │  │  │  │        └───────┴───────┴────────────────┘
     │  │  │  └─ [WS] data source for writing to a register file:
     │  │  │     ┌────┬─────────────────────────┐
     │  │  │     │ WS │ interpritation          │
     │  │  │     ├────┼─────────────────────────┤
     │  │  │     │ 00 │ constant from Immidiate │
     │  │  │     │ 01 │ data from switches      │
     │  │  │     │ 10 │ ALU result              │
     │  │  │     │ 11 │ not set                 │
     │  │  │     └────┴─────────────────────────┘
     │  │  └─ [WE] premission to write to register file
     │  └─ [C] if 1 - do codition jump
     └─ [B] if 1 - do uncodition jump 

	Attributes
	----------
	B      :  int
		uncodition jump
	C      :  int
		codition jump
	WE     :  int
		premission to write to register file
	WS     :  int
		data source for writing to a register file
	ALUop  :  int
		ALU the operation code
	RA1    :  int
		read address for first operand
	RA2    :  int
		read address for second operand
	WA     :  int
		write address
	const  :  int
		Immidiate
	"""

	def __init__(self)
		self.B = 0
		self.C = 0
		self.WE = 0
		self.WS = 2
		self.ALUop = 0
		self.RA1 = 0
		self.RA2 = 0
		self.WA

	def compile(self):
		return bin_extend(self.B, 1)    \
			+ bin_extend(self.C, 1)     \
			+ bin_extend(self.WE, 1)    \
			+ bin_extend(self.WS, 2)    \
			+ bin_extend(self.ALUop, 4) \
			+ bin_extend(self.RA1, 5)   \
			+ bin_extend(self.RA2, 5)   \
			+ bin_extend(self.WA, 5)    \
			+ bin_extend(self.const, 8)

# ----------------------------- EXCEPTIONS CLASSES -----------------------------
class ImmidiateError(SyntaxError):
	def __init__(self, what):
		super().__init__(what)


class RegisterError(SyntaxError):
	def __init__(self, what):
		super().__init__(what)

# ------------------------------- UTILS FUNCTIONS ------------------------------
def contains_only(str, available):
	if len(set(str) | set(available)) > len(set(str)):
		return False
	else:
		return True


def bin_extend(num, cnt):
	st = bin(num)[2:]
	return '0' * (cnt - len(st)) + st

# ------------------------------- PARSE FUNCTIONS ------------------------------
def parse_reg(st):
	REGISTER_INDEX_MESSAGE = 'Invalid register index: {}'
	REGISTER_LIMIT_MESSAGE = 'Invalid register index: {}, limit is {}'
	REGISTER_FORMAT_MESSAGE = 'Invalid register format: {}'


	if not contains_only(st.lower(), '0123456789rasgfptxzeo'):
		raise RegisterError(REGISTER_FORMAT_MESSAGE.format(st))
	match st.lower:
		case 'zero':
			return parse_reg('x0')
		case 'ra':
			return parse_reg('x1')
		case 'sp':
			return parse_reg('x2')
		case 'gp':
			return parse_reg('x3')
		case 'tp':
			return parse_reg('x4')
		case 't0' | 't1' | 't2' as T:
			return parse_reg('x' + int(T[1]) + 6)
		case 's0' | 'fp':
			return parse_reg('x8')
		case 's1':
			return parse_reg('x9')

		if st.startswith('a', 't', 'x') and st[1].isdigit():
			try:
				reg_cnt = int(st[1:])
			except ValueError:
				raise RegisterError(REGISTER_INDEX_MESSAGE.format(st[1:]))
			match st[0]:
				case 'a':
					if reg_cnt > 7:
						raise RegisterError(REGISTER_LIMIT_MESSAGE.format(st[1:]), 7)
					return parse_reg('x' + str(reg_cnt + 10))
				case 't':
					if reg_cnt > 6:
						raise RegisterError(REGISTER_LIMIT_MESSAGE.format(st[1:]), 6)
					return parse_reg('x' + str(reg_cnt + 25))
				case 's':
					if reg_cnt > 11:
						raise RegisterError(REGISTER_LIMIT_MESSAGE.format(st[1:]), 11)
					return parse_reg('x' + str(reg_cnt + 16))
				case 'x':
					if reg_cnt > 31:
						raise RegisterError(REGISTER_LIMIT_MESSAGE.format(st[1:]), REGISTER_NUMBER)
					return reg_cnt
		else:
			raise RegisterError(REGISTER_FORMAT_MESSAGE.format(st))


def parse_imm(st):
	IMMIDIATE_ERROR_MESSAGE = 'Invalid Immidiate value with base {}: {}'
	IMMIDIATE_LIMIT_MESSAGE = 'Immidiate value to big: {}, limit is ' + str(IMMIDIATE_LIMIT)	
	IMMIDIATE_ERROR_BASE = 'Invalid Immidiate value: {}'

	match st[0:2]
		case '0x' | '0X':
			i = st[2:]
			base = 16
			if not contains_only(i, '0123456789abcdefABCDEF'):
				raise ImmidiateError(IMMIDIATE_ERROR_MESSAGE.format(16, i))
		case '0o' | '0O':
			i = st[2:]
			base = 8
			if not contains_only(i, '01234567'):
				raise ImmidiateError(IMMIDIATE_ERROR_MESSAGE.format(8, i))
		case '0b' | '0B':
			i = st[2:]
			base = 2
			if not contains_only(i, '01'):
				raise ImmidiateError(IMMIDIATE_ERROR_MESSAGE.format(2, i))
	else:
		i = st
		base = 10
	try:
		ans = int(i,  base=base)
		if ans > IMMIDIATE_LIMIT:
			raise ImmidiateError(IMMIDIATE_LIMIT_MESSAGE)
		return ans
	except ValueError:
		raise ImmidiateError(IMMIDIATE_ERROR.format(i))


def parse(line):
	instruction = Instruction()
	match line.split():
		case 'li', reg, imm, *other:
			if len(other) > 0:
				print('intruction `li` expecting only one operand')
				return None
			try:
				reg = parse_reg(reg)
				imm = parse_imm(imm)
				instruction.WA = reg
				instruction.const = imm
				instruction.WE = 1
			except ImmidiateError as exc:
				print(exc)
			except RegisterError as exc:
				print(exc)
		case 'ls', *other:

		case 'beq', *other:

		case 'add', *other:

		case 'sub', *other:

		case 'jal', *other:
	return instruction


def compile(prog):
	ERROR = False
	ans = []
	for line in prog.split('\n'):
		instr = parse(line)
		if instr is None:
			ERROR = True
		else if ERROR is False:
			ans.append(instr)
	if ERROR is True:
		return None
	else:
		return ans


if sys.argv < 2:
	print("usage: python asm [program.s]")
	print("  where [program.s] is file with RISC-V assembly code")
for file_name in sys.argv:
	try:
		if not file_name.endswith('.s'):
			if '.' not in file_name:
				print('unsupported file type')
			else:
				print(f'unsupported file type: .{file_name.spit()[-1]}')
			continue
		with open(file_name, 'r') as file:
			text = file.read()
		obj = compile(text)
		if obj is None:
			continue
		with open(file_name[:-2] + '.o', 'w') as file:
			file.write(obj)
	except FileNotFoundError:
		print(f'file not found: {file_name}')

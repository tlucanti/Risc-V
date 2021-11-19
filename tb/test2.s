###====------------------------====###
#   program multiplies 2 numbers     #
#       first operand in x1          #
#       second operand in switches   #
###====------------------------====###

# ls      x2                # x2 = switches
li      x1      11          # 0 # x1 = 13
li      x2      3           # 1 # x2 = 3
li      x3      1           # 2 # x3 = 1
li      x4      0           # 3 # x4 = 0
beq     x2      zero    4   # 4 # if (x2 == zero): pc += 4
  add   x4      x4      x1  # 5 # x4 += x1
  sub   x2      x2      x3  # 6 # x2 -= 1
  j     -3                  # 7 # goto beq
j       0                   # 8 # end (infinit loop)

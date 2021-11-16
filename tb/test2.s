###====------------------------====###
#   program multiplies 2 numbers     #
#       first operand in x1          #
#       second operand in switches   #
###====------------------------====###

li      x1      13          # x1 = 13
ls      x2                  # x2 = switches
li      x3      1           # x3 = 1
li      x4      0           # x4 = 0
beq     x2      zero    4   # if (x2 == zero): pc += 4
  add   x4      x4      x1  # x4 += x1
  sub   x2      x2      x3  # x2 -= 1
  j     -3                  # goto beq
j       0                   # end (infinit loop)

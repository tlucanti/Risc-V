inf = open('prog.asm')
out = open('prog.s', 'w')
l = inf.readline()
while 1:
	l = inf.readline()
	if l == '':
		break
	out.write(hex(int(l[6:-1].replace(' ',''), 2))[2:] + '\n')
out.close()
inf.close()

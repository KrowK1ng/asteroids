include config.mk

game: main.s
	gcc -no-pie ${CFLAGS} main.s -o game ${LIBS}

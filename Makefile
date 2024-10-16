include config.mk
FILES=main.s game.s player.s math.s input.s

game: ${FILES}
	gcc -no-pie ${CFLAGS} ${FILES} -o game ${LIBS}

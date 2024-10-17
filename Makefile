include config.mk
FILES=main.s game.s player.s math.s input.s meteors.s bullet.s

game: ${FILES}
	gcc -g -no-pie ${CFLAGS} ${FILES} -o game ${LIBS}

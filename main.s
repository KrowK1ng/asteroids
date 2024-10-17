.global main
.global readKeyCode
.global putLine
.global putDot
.global W
.global H
.global TIME

.data
W: .quad 640
H: .quad 360
TIME:  .quad 0
game_name:  .asciz "Asteroids in Assembly"

.text

readKeyCode:
	movq    $0, %rax
	ret

putDot:
	movq    $0, %rax
	ret


main:
	pushq   %rbp
	movq    %rsp,       %rbp

	# void InitWindow(int width, int height, const char *title);
	movl    W,          %edi
	movl    H,          %esi
	movq    $game_name, %rdx
	call    InitWindow

	movq    $40,        %rdi
	call    SetTargetFPS
	call    gameInit

.main_loop:
		call    BeginDrawing
		movq    $0xFFFF00000,     %rdi
		call    gameLoop
		cmpq    $0,     %rax
		je      .main_loop_end
		incq    TIME
		call    EndDrawing


		call    WindowShouldClose
		cmpq    $0,     %rax
		je      .main_loop
.main_loop_end:

	call    CloseWindow


	movq    %rbp,       %rsp
	popq    %rbp

	movq    $0,         %rax
	ret

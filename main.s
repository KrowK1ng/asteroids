.global main

.data
W: .quad 640
H: .quad 360
game_name:  .asciz "Asteroids in Assembly"

.text
main:
	pushq %rbp
	movq  %rsp,     %rbp

	# void InitWindow(int width, int height, const char *title);
	movq  W,            %rdi
	movq  H,            %rsi
	movq  $game_name,   %rdx
	call  InitWindow

	.main_loop:
		call    BeginDrawing
		movq    $0xFFFF00000,     %rdi
		call    ClearBackground;
		call    EndDrawing
		call    WindowShouldClose
		cmpq    $0,     %rax
		je      .main_loop

	call    CloseWindow


	movq  %rbp,     %rsp
	popq  %rbp

	movq  $0,       %rax
	ret

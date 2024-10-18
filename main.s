.global main
.global putBitmap
.global draw_col
.global W
.global H
.global TIME
.global pname
.global gstate
.global score

.data
W: .quad 640
H: .quad 360
TIME:  .quad 0
score:     .long 0
draw_col:   .long 0
game_name:  .asciz "Asteroids in Assembly"
pname:
	.byte  0, 15  # NAMESIZE
	.space  16    # NAMESIZE
gstate: .byte 0   # 0 -> sboard (scoreboard)
                  # 1 -> menu (write name)
                  # 2 -> game

.text
# void putBitmap(int64* addr, int x, int y)
putBitmap:
	pushq   %rbp
	movq    %rsp,       %rbp

	subq    $48,        %rsp
	movq    %r12,       -8(%rbp)
	movq    %r13,       -16(%rbp)
	movq    %r14,       -24(%rbp)
	movq    %r15,       -32(%rbp)
	movq    %rbx,       -40(%rbp)

	movq    %rdi,       %r12
	movl    %esi,       %r13d
	movl    %edx,       %r14d
	movw    (%r12),     %ax
	andq    $0xFFFF,    %rax
	movl    %eax,       -44(%rbp)   # save w in stack
	movl    %r13d,      -48(%rbp)   # save x in stack
	movw    2(%r12),    %bx
	andq    $0xFFFF,    %rbx
	addq    $4,         %r12

.pb_y_loop:
	movl    -48(%rbp),  %r13d
	movl    -44(%rbp),  %r15d
.pb_x_loop:

	cmpb    $0,         (%r12)
	je      .pb_loop_noPrint

	movl    %r13d,      %edi
	movl    %r14d,      %esi
	movl    draw_col,   %edx
	call    DrawPixel
.pb_loop_noPrint:
	incl    %r13d
	incq    %r12
	decl    %r15d
	jnz     .pb_x_loop
	incl    %r14d
	decl    %ebx
	jnz     .pb_y_loop

	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15
	movq    -40(%rbp),  %rbx

	movq    %rbp,       %rsp
	popq    %rbp
	ret


main:
	pushq   %rbp
	movq    %rsp,       %rbp

	# InitWindow(W, H, game_name)
	movl    W,          %edi
	movl    H,          %esi
	movq    $game_name, %rdx
	call    InitWindow

	movq    $40,        %rdi
	call    SetTargetFPS
	call    HideCursor
	call    sboard_init

.main_loop:
		call    BeginDrawing
		cmpb    $0,         gstate
		jne     .main_sloop_skip

		call    sboard_loop
		jmp     .main_loop_pend
.main_sloop_skip:

		cmpb    $1,         gstate
		jne     .main_mloop_skip

		call    menu_loop
		jmp     .main_loop_pend
.main_mloop_skip:

		cmpb    $2,         gstate
		jne     .main_loop_pend

		call    gameLoop
		cmpq    $0,     %rax
		je      .main_loop_end

.main_loop_pend:
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

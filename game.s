.macro line x0, y0, x1, y1, col
		movq	\x0, %rdi
		movq 	\y0, %rsi
		movq	\x1, %rdx
		movq 	\y1, %rcx
		movq 	\col, %r8
		call DrawLine
.endm

.macro checkDown key
		movl    \key,   %edi
		call    IsKeyDown
		cmpb    $1,     %al
.endm

.macro checkPressed key
		movl    \key,   %edi
		call    IsKeyPressed
		cmpb    $1,     %al
.endm

.file "src/game/game.s"

.global gameInit
.global gameLoop

.data
UIH: .long 40

.text
gameInit:
	call    player_init
	call    meteor_init_types
	movq    $player,    %rax
	movl    $64,        20(%rax)

	ret

# Player Input
# Player Movement
# Player Draw
# Meteorite Movement
# Meteorite Draw
# Bullet Movement
# Bullet Draw
# Bullet Remove
# TODO Player Death
# TODO Draw UI
gameLoop:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $48,        %rsp
	movq    %r12,       -8(%rbp)
	movq    %r13,       -16(%rbp)
	movq    %r14,       -24(%rbp)
	movq    %r15,       -32(%rbp)
	movq    %rbx,       -40(%rbp)

	movq    $0xFF0000000,     %rdi
	call    ClearBackground

	checkDown   $'F
	jne     .gl_fullscreen_skip
	call    ToggleFullscreen
.gl_fullscreen_skip:

	checkPressed   $'X
	jne     .gl_bullet_init_skip
	movq    $player,    %rax
	movl    (%rax),     %edi
	movl    4(%rax),    %esi
	movl    16(%rax),   %edx
	call    b_init
.gl_bullet_init_skip:

	checkDown   $'Q
	movb    %al,        %dil
	movq    $0,         %rax
	cmpb    $1,         %dil
	je      .gl_end

	checkDown   KLEFT
	jne     .end_increase_angle

	movq    $player,    %rax
	addl    $0x02000,   16(%rax)
	movl    DPI,        %ecx
	cmpl    %ecx,       16(%rax)
	jle     .end_increase_angle
	subl    %ecx,       16(%rax)
.end_increase_angle:

	checkDown   KRIGHT
	jne     .end_decrease_angle

	movq    $player,    %rax
	subl    $0x02000,   16(%rax)
	movl    DPI,        %ecx
	cmpl    $0,         16(%rax)
	jge     .end_decrease_angle
	addl    %ecx,       16(%rax)
.end_decrease_angle:

	checkDown   KUP
	jne     .unset_speed

.set_speed:
	movq    $player,    %rax
	movl    16(%rax),   %edi
	call    _cos
	movl    %eax,       %edi
	movl    $0x60000,    %esi
	call    mul
	movl    %eax,       %edi
	movq    $player,    %rax
	movl    %edi,       8(%rax)

	movl    16(%rax),   %edi
	call    _sin
	movl    %eax,       %edi
	movl    $0x60000,    %esi
	call    mul
	movl    $0,         %edi
	subl    %eax,       %edi
	movq    $player,    %rax
	movl    %edi,       12(%rax)

	jmp .end_set_speed


.unset_speed:
	movq    $player,    %rax
	movl    $0,         8(%rax)
	movl    $0,         12(%rax)
.end_set_speed:


	# Add speed
	movq    $player, %rax
	movl    8(%rax), %edx
	addl    %edx,    (%rax)
	movl    12(%rax),%edx
	addl    %edx,    4(%rax)

	movl    W,       %edi
	shll    $16,     %edi
	cmpl    $0,      (%rax)
	jl      .pos_x_small

	cmpl    %edi,    (%rax)
	jge     .pos_x_big
	jmp     .pos_x_end

.pos_x_small:
	addl    %edi,    (%rax)
	jmp     .pos_x_end
.pos_x_big:
	subl    %edi,    (%rax)
.pos_x_end:

	movl    UIH,     %edi
	shll    $16,     %edi
	cmpl    %edi,    4(%rax)
	jl      .pos_y_small
	movl    H,       %edi
	shll    $16,     %edi

	cmpl    %edi,    4(%rax)
	jge     .pos_y_big
	jmp     .pos_y_end

.pos_y_small:
	subl    %edi,    4(%rax)
	movl    H,       %edi
	shll    $16,     %edi
	addl    %edi,    4(%rax)
	jmp     .pos_y_end
.pos_y_big:
	subl    %edi,    4(%rax)
	movl    UIH,     %edi
	shll    $16,     %edi
	addl    %edi,    4(%rax)
.pos_y_end:


	# Add to vcnt if < 32
	movq    $player, %rax
	cmpl    $64,     20(%rax)
	jge     .gl_pcnt_noinc
	incl    20(%rax)
.gl_pcnt_noinc:

# TODO: TEMP, draws center of the player
	movl    player,  %edi
	movl    4(%rax), %esi
	shrl    $16,     %edi
	shrl    $16,     %esi
	movl    $0xFFFFFFFF,      %edx
	call    DrawPixel

	movq    $player, %rax
	movl    20(%rax),%edx
	andl    $8,      %edx
	jnz     .gl_pdraw_skip
	call    player_draw
.gl_pdraw_skip:

	movq    $meteors,         %r12
	movq    (%r12),           %rbx      # rbx = a_cnt
	addq    $16,              %r12      # r12 = a_pnt

	cmpq    $0,               %rbx
	je      .gl_a_move_loop_end
.gl_a_move_loop:
	# x += speedx
	movl    8(%r12),    %eax
	addl    %eax,       (%r12)

	# y += speedy
	movl    12(%r12),   %eax
	addl    %eax,       4(%r12)

	# angle += speeda;
	movl    20(%r12),   %eax
	addl    %eax,       16(%r12)

	# if (angle > DPI) angle -= DPI
	movl    DPI,        %eax
	cmpl    %eax,       16(%r12)
	jle     .gl_a_angle_not_bigger
	subl    %eax,       16(%r12)
.gl_a_angle_not_bigger:

	# if (angle < 0) angle += DPI
	movl    DPI,        %eax
	cmpl    $0,         16(%r12)
	jge     .gl_a_angle_not_smaller
	addl    %eax,       16(%r12)
.gl_a_angle_not_smaller:

	addq    $48,              %r12      # r12 = a_pnt++
	decq    %rbx
	jnz     .gl_a_move_loop
.gl_a_move_loop_end:




	movq    $meteors,         %r12
	movq    (%r12),           %rbx      # rbx = a_cnt
	addq    $16,              %r12      # r12 = a_pnt

	cmpq    $0,               %rbx
	je      .gl_a_draw_loop_end
.gl_a_draw_loop:
	movq    %r12,             %rdi
	call    a_draw

	addq    $48,              %r12      # r12 = a_pnt++
	decq    %rbx
	jnz     .gl_a_draw_loop
.gl_a_draw_loop_end:


	movq    $bullets,         %r12
	movq    (%r12),           %rbx      # rbx = b_cnt
	addq    $8,               %r12      # r12 = b_pnt

	cmpq    $0,               %rbx
	je      .gl_b_move_loop_end
.gl_b_move_loop:
	# x += xspeed
	movl    8(%r12),          %eax
	addl    %eax,             (%r12)

	# y += yspeed
	movl    12(%r12),         %eax
	addl    %eax,             4(%r12)

	addq    $16,              %r12      # r12 = b_pnt++ BSIZE
	decq    %rbx
	jnz     .gl_b_move_loop
.gl_b_move_loop_end:


	movq    $bullets,         %r12
	movq    (%r12),           %rbx      # rbx = b_cnt
	addq    $8,               %r12      # r12 = b_pnt

	cmpq    $0,               %rbx
	je      .gl_b_draw_loop_end
.gl_b_draw_loop:

	movl    (%r12),           %eax
	cdqe
	shrq    $16,              %rax
	movl    %eax,             %edi

	movl    4(%r12),          %eax
	cdqe
	shrq    $16,              %rax
	movl    %eax,             %esi

	movl    $2,               %edx
	movl    $2,               %ecx

	movl    $0xFFFFFFFF,      %r8d
	call    DrawRectangle

	addq    $16,              %r12      # r12 = b_pnt++ BSIZE
	decq    %rbx
	jnz     .gl_b_draw_loop
.gl_b_draw_loop_end:

	movq    $bullets,         %r12
	movq    (%r12),           %rbx      # rbx = b_cnt
	addq    $8,               %r12      # r12 = b_pnt

	cmpq    $0,               %rbx
	je      .gl_b_remove_loop_end
.gl_b_remove_loop:
	movl    W,                %eax
	shll    $16,              %eax
	cmpl    %eax,             (%r12)
	jge     .gl_b_rloop_remove
	cmpl    $0,               (%r12)
	jl      .gl_b_rloop_remove

	movl    H,                %eax
	shll    $16,              %eax
	cmpl    %eax,             4(%r12)
	jge     .gl_b_rloop_remove
	cmpl    $0,               4(%r12)
	jl      .gl_b_rloop_remove

	jmp     .gl_b_rloop_pre_end
.gl_b_rloop_remove:
	movq    %r12,             %rdi
	call    b_remove
	subq    $16,              %r12      # r12 = b_pnt-- BSIZE

.gl_b_rloop_pre_end:
	addq    $16,              %r12      # r12 = b_pnt++ BSIZE
	decq    %rbx
	jnz     .gl_b_remove_loop
.gl_b_remove_loop_end:

	movq    $0,     %rdi
	movq    $0,     %rsi
	movl    W,      %edx
	movl    UIH,    %ecx

	movl    $0xFF000000,    %r8d
	call    DrawRectangle

	movq    $pname, %rdi
	addq    $2,     %rdi
	movl    $24,    %esi
	movl    $8,     %edx
	movl    $0xFFFFFFFF,      %ecx
	call    draw_text

	movl    score,  %edi
	movl    $560,   %esi
	movl    $8,     %edx
	movl    $0xFFFFFFFF,      %ecx
	call    draw_signed


	movq    $1,     %rax
.gl_end:
	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15
	movq    -40(%rbp),  %rbx

	movq    %rbp,   %rsp
	popq    %rbp
	ret

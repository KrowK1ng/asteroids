.file "src/game/player.s"

.macro movarg x, y
		movl	\x,   %eax
		cdqe
		movq    %rax, \y
.endm

.macro line x0, y0, x1, y1, col
		movarg	\x0, %rdi
		movarg 	\y0, %rsi
		movarg	\x1, %rdx
		movarg 	\y1, %rcx
		movq 	\col, %r8
		call DrawLine
.endm

.macro trsx src, dst
		movl    \src,       %r15d
		addl    (%r13),     %r15d
		movq    $0,         %rdx
		movq    $0,         %rax
		movl    %r15d,      %eax
		cdqe
		movq    $1,         %r15
		shlq    $16,        %r15
		idivq   %r15
		movl    %eax,       \dst
.endm

.macro trsy src, dst
		movl    \src,       %r15d
		addl    4(%r13),    %r15d
		movq    $0,         %rdx
		movq    $0,         %rax
		movl    %r15d,      %eax
		cdqe
		movq    $1,         %r15
		shlq    $16,        %r15
		idivq   %r15
		movl    %eax,       \dst
.endm

.macro trrrs x, y
		movl    16(%r13),   %edi
		call    _cos
		movl    %eax,       %edi
		movl    \x,         %esi
		call    mul
		movl    %eax,       %r15d

		movl    16(%r13),   %edi
		call    _sin
		movl    %eax,       %edi
		movl    \y,         %esi
		call    mul
		subl    %eax,       %r15d

		movl    16(%r13),   %edi
		call    _sin
		movl    %eax,       %edi
		movl    \x,         %esi
		call    mul
		movl    $0,         %r14d
		subl    %eax,       %r14d

		movl    16(%r13),   %edi
		call    _cos
		movl    %eax,       %edi
		movl    \y,         %esi
		call    mul
		subl    %eax,       %r14d
.endm

.macro trs x, dstx, y, dsty
		trrrs   \x, \y
		trsx    %r15d,      \dstx
		trsy    %r14d,      \dsty
.endm

.macro trs2 x, dstx, y, dsty
		trrrs   \x, \y
		addl    (%r13),     %r15d
		addl    4(%r13),    %r14d
		movl    %r15d,      \dstx
		movl    %r14d,      \dsty
.endm

.global player
.global player_init
.global player_draw
.global player_die
.data
player:
.long 0 # x position
.long 0 # y position
.long 0 # x speed
.long 0 # y speed
.long 0 # angle
.long 0 # vcnt - vulnerability count (4 frames * 8)

player_p:
.long 0
.long 0
.long 0
.long 0
.long 0
.long 0


# TODO, better
.text

player_init:
	# Setting initial position for the player
	movq    $player,    %rax
	movq    W,          %rdx
	movl    %edx,       (%rax)
	movq    H,          %rdx
	movl    %edx,       4(%rax)

	# Divide by two
	shrl    $1,         (%rax)
	shrl    $1,         4(%rax)

	# Speed is 0
	movl    $0,         8(%rax)
	movl    $0,         12(%rax)

	shll    $16,        (%rax)
	shll    $16,        4(%rax)
	shll    $16,        8(%rax)
	shll    $16,        12(%rax)


	# Set the player angle
	movl    PI,         %edx
	shrl    $1,         %edx
	addl    $0x2,     %edx
	movl    %edx,       16(%rax)


	# Set the points position
	movq    $player_p,  %rax
	movl    $6,     (%rax)
	shll    $16,    (%rax)
	negl            (%rax)
	addq    $1,     (%rax)

	movl    $7,     4(%rax)
	shll    $16,    4(%rax)
	negl            4(%rax)
	addq    $1,     4(%rax)

	movl    $6,     8(%rax)
	shll    $16,    8(%rax)
	negl            8(%rax)
	addq    $1,     8(%rax)

	movl    $7,     12(%rax)
	shll    $16,    12(%rax)

	movl    $12,    16(%rax)
	shll    $16,    16(%rax)

	movl    $0,     20(%rax)
	shll    $16,    20(%rax)

	ret

player_draw:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $96,    %rsp
	movq    %r12,   -8(%rbp)
	movq    %r13,   -16(%rbp)
	movq    %r14,   -24(%rbp)
	movq    %r15,   -32(%rbp)
	movq    %rbx,   -40(%rbp)

	movq    $player_p,  %r12
	movq    $player,    %r13
	leaq    -96(%rbp),  %r14

	trs     (%r12),     -96(%rbp),  4(%r12),    -92(%rbp)
	trs     8(%r12),    -88(%rbp),  12(%r12),   -84(%rbp)
	trs     16(%r12),   -80(%rbp),  20(%r12),   -76(%rbp)

	line    -96(%rbp),  -92(%rbp),  -88(%rbp),  -84(%rbp), $0xFFFFFFFF
	line    -96(%rbp),  -92(%rbp),  -80(%rbp),  -76(%rbp), $0xFFFFFFFF
	line    -80(%rbp),  -76(%rbp),  -88(%rbp),  -84(%rbp), $0xFFFFFFFF

	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15
	movq    -40(%rbp),  %rbx

	movq    %rbp,   %rsp
	popq    %rbp
	ret


player_die:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $96,    %rsp
	movq    %r12,   -8(%rbp)
	movq    %r13,   -16(%rbp)
	movq    %r14,   -24(%rbp)
	movq    %r15,   -32(%rbp)
	movq    %rbx,   -40(%rbp)

	movq    $player_p,  %r12
	movq    $player,    %r13
	leaq    -96(%rbp),  %r14

	# If player is invulnerable, he can't die (obv, smh 🙄)
	movl    20(%r13),   %edi
	cmpl    $64,        %edi    # VCNT
	movq    $0,         %rax
	jl      .pd_end

	trs2    (%r12),     -96(%rbp),  4(%r12),    -92(%rbp)
	trs2    8(%r12),    -88(%rbp),  12(%r12),   -84(%rbp)
	trs2    16(%r12),   -80(%rbp),  20(%r12),   -76(%rbp)

	movq    $meteors,   %r12
	movq    (%r12),     %rax
	cmpq    $0,         %rax
	je      .pd_end
	movq    $48,        %rcx    # ASIZE
	mulq    %rcx
	addq    $16,        %r12
	addq    %r12,       %rax
	movq    %rax,       %r13

.pd_loop:

	movl    -96(%rbp),  %edi
	movl    -92(%rbp),  %esi
	movq    %r12,       %rdx
	call    point_in_poly
	cmpq    $0,         %rax
	jne     .pd_end

	movl    -88(%rbp),  %edi
	movl    -84(%rbp),  %esi
	movq    %r12,       %rdx
	call    point_in_poly
	cmpq    $0,         %rax
	jne     .pd_end

	movl    -80(%rbp),  %edi
	movl    -76(%rbp),  %esi
	movq    %r12,       %rdx
	call    point_in_poly
	cmpq    $0,         %rax
	jne     .pd_end

	addq    $48,        %r12    # ASIZE
	cmpq    %r12,       %r13
	jne     .pd_loop

	movq    $0,         %rax
.pd_end:
	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15
	movq    -40(%rbp),  %rbx

	movq    %rbp,   %rsp
	popq    %rbp
	ret

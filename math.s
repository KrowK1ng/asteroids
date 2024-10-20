.global mul
.global _sin
.global _cos
.global DPI
.global PI
.global pseudorand
.global randquad
.global randlong

.data
PI:  .long 0x3243F
DPI: .long 0x6487E
SEED:	.quad 0x06969
PRIME:	.quad 0x15B
ADD:	.quad 0x539

.text

# f mul(f x, f y)
mul:
	shlq    $32,    %rdi # keep only 32 bits
	shrq    $32,    %rdi

	shlq    $32,    %rsi # keep only 32 bits
	shrq    $32,    %rsi

	movq    %rsi,   %rax
	cdqe
	movq    %rax,   %rsi
	movq    %rdi,   %rax
	cdqe
	imulq   %rsi

	shrq    $16,    %rax # Keep our fixed point convension
	cdqe
	ret

# f _sin(f x)
_sin:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $32,    %rsp
	movq    %r12,   -8(%rbp)
	movq    %r13,   -16(%rbp)   # cnt -> 13
	movq    %r14,   -24(%rbp)   # a   -> 14
	movq    %r15,   -32(%rbp)   # ans -> 15

	shlq    $32,    %rdi        # keep only 32 bits
	shrq    $32,    %rdi
	movq    %rdi,   %r12        # r12 = x

	movq    $0,     %r13        # cnt = 0
	movq    $1,     %r14        # a   = 1
	shlq    $16,    %r14
	movq    $0,     %r15        # ans = 0

	_sin_loop:
		# cnt++
		incq    %r13

		# a = mul(a, x) / cnt
		movl    %r14d,  %edi
		movl    %r12d,  %esi
		call    mul
		movq    $0,     %rdx
		idivq   %r13
		movq    %rax,   %r14

		# end if value is too small
		cmpq    $0,     %r14
		je      _sin_end_loop

		movq    %r13,   %rax
		movq    $4,     %rdi
		movq    $0,     %rdx
		divq    %rdi

		movq    $1,     %rax    # RAX = 1

		cmpq    $1,     %rdx
		je      _sin_mod_1

		cmpq    $3,     %rdx
		je      _sin_mod_3

		jmp     _sin_loop

		_sin_mod_3:
		movq    $-1,    %rax

		_sin_mod_1:

		imulq   %r14
		addq    %rax,   %r15
		jmp     _sin_loop
	_sin_end_loop:


	movq    %r15,       %rax

	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15

	movq    %rbp,   %rsp
	popq    %rbp
	ret

# f _cos(f x)
_cos:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $32,    %rsp
	movq    %r12,   -8(%rbp)
	movq    %r13,   -16(%rbp)   # cnt -> 13
	movq    %r14,   -24(%rbp)   # a   -> 14
	movq    %r15,   -32(%rbp)   # ans -> 15

	shlq    $32,    %rdi        # keep only 32 bits
	shrq    $32,    %rdi
	movq    %rdi,   %r12        # r12 = x

	movq    $0,     %r13        # cnt = 0
	movq    $1,     %r14        # a   = 1
	shlq    $16,    %r14
	movq    $1,     %r15        # ans = 1
	shlq    $16,    %r15

	_cos_loop:
		# cnt++
		incq    %r13

		# a = mul(a, x) / cnt
		movl    %r14d,  %edi
		movl    %r12d,  %esi
		call    mul
		movq    $0,     %rdx
		idivq   %r13
		movq    %rax,   %r14

		# end if value is too small
		cmpq    $0,     %r14
		je      _cos_end_loop

		movq    %r13,   %rax
		movq    $4,     %rdi
		movq    $0,     %rdx
		divq    %rdi

		movq    $1,     %rax    # RAX = 1

		cmpq    $0,     %rdx
		je      _cos_mod_0

		cmpq    $2,     %rdx
		je      _cos_mod_2

		jmp     _cos_loop

		_cos_mod_2:
		movq    $-1,    %rax

		_cos_mod_0:

		imulq   %r14
		addq    %rax,   %r15
		jmp     _cos_loop
	_cos_end_loop:


	movq    %r15,       %rax

	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15

	movq    %rbp,   %rsp
	popq    %rbp
	ret

# f pseudorand()
pseudorand:
	push	%rbp	
	movq	%rsp,	%rbp

	movq	TIME,	%rdi
	movq	SEED, %rax
	mul	%rdi

	movq	PRIME,	%rdi
	mul     %rdi
	addq	ADD,	%rax
	movq	%rax,	SEED

	movq	%rbp, %rsp
	popq	%rbp
	ret

# f randint(int a, int b)
# a < b
randquad:
	pushq	%rbp
	movq	%rsp,	%rbp

	subq	%rdi,	%rsi
	incq	%rsi
	pushq	%rsi
	pushq	%rdi
	call pseudorand
	popq %rdi
	popq %rsi
	movq $0, %rdx
	idiv	%rsi
	addq	%rdi,	%rdx
	movq	%rdx,	%rax

	movq	%rbp,	%rsp
	popq	%rbp
	ret

randlong:
	pushq	%rbp
	movq	%rsp,	%rbp

	subl	%edi,	%esi
	incl	%esi
	pushq	%rsi
	pushq	%rdi
	call pseudorand
	popq %rdi
	popq %rsi
	movq $0, %rdx
	idiv	%esi
	addl	%edi,	%edx
	movl	%edx,	%eax

	movq	%rbp,	%rsp
	popq	%rbp
	ret

.global meteor_init_types
.global a_draw
.global meteors

.macro trans pos
	movl    \pos,   %eax
	cdqe
	shrq    $16,    %rax
	cdqe
.endm

.data
MMETEORS: .quad 256
meteors:
	.quad 0, 0
	.space 12288

# struct asteroid {
#   f x, y;
#   f vx, vy;
#   f angle, va;
#   .quad type
#   byte s
# } = 48 bytes

mtype_1:
	.quad 4
	.long -0x100000, 0x100000
	.long 0x100000, 0x100000
	.long 0x100000, -0x100000
	.long -0x100000, -0x100000
	.long -0x100000, 0x100000

.text
meteor_init_types:
	pushq   %rbp
	movq    %rsp,       %rbp

	movq    $meteors,   %rdi
	addq    $16,        %rdi

	movq    $mtype_1,   %rsi
	movq    %rsi,       24(%rdi)
	movl    $0x1000000,         (%rdi)
	movl    $0x1000000,         4(%rdi)
	movl    $0,         16(%rdi)
	movb    $3,         32(%rdi)

	movq    %rbp,   %rsp
	popq    %rbp
	ret


# void a_draw(int64* asteroid);
a_draw:
	pushq   %rbp
	movq    %rsp,       %rbp

	subq    $48,        %rsp
	movq    %r12,       -8(%rbp)   # pointer to asteroid
	movq    %r13,       -16(%rbp)  # pointer to a_type
	movq    %r14,       -24(%rbp)  # pointer to stack
	movq    %r15,       -32(%rbp)  #
	movq    %rbx,       -40(%rbp)  # vertex count

	movq    %rdi,       %r12
	movq    24(%r12),   %r13
	leaq    -8(%rsp),   %r14

	movq    (%r13),     %rbx
	incq    %rbx
	addq    $8,         %r13

.a_draw_loop1:
	# eax = cos(angle)
	movl    16(%r12),   %edi
	call    _cos

	# r15 = mul(eax, p_x)
	movl    %eax,       %edi
	movl    (%r13),     %esi
	call    mul
	movl    %eax,       %r15d

	# eax = sin(angle)
	movl    16(%r12),   %edi
	call    _sin

	# r15 -= mul(eax, p_y)
	movl    %eax,       %edi
	movl    4(%r13),    %esi
	call    mul
	subl    %eax,       %r15d

	# eax = r15 * size
	movl    %r15d,      %eax
	cdqe
	movzb   32(%r12),   %r15
	imulq   %r15

	# push (a_x + eax) / (2 ^ 16)
	addl    (%r12),     %eax
	cdqe
	shrq    $16,        %rax
	cdqe
	pushq   %rax

	# eax = sin(angle)
	movl    16(%r12),   %edi
	call    _sin

	# r15 = -mul(eax, p_x)
	movl    %eax,       %edi
	movl    (%r13),     %esi
	call    mul
	movl    $0,         %r15d
	subl    %eax,       %r15d

	# eax = cos(angle)
	movl    16(%r12),   %edi
	call    _cos

	# r15 -= mul(eax, p_y)
	movl    %eax,       %edi
	movl    4(%r13),    %esi
	call    mul
	subl    %eax,       %r15d

	# eax = r15 * size
	movl    %r15d,      %eax
	cdqe
	movzb   32(%r12),   %r15
	imulq   %r15

	# push (a_y + eax) / (2 ^ 16)
	addl    4(%r12),    %eax
	cdqe
	shrq    $16,        %rax
	cdqe
	pushq   %rax

	addq    $8,         %r13
	decq    %rbx
	jnz     .a_draw_loop1

	movq    24(%r12),   %r13
	movq    (%r13),     %rbx

.a_draw_loop2:
	movq    (%r14),      %rdi
	movq    -8(%r14),    %rsi
	movq    -16(%r14),   %rdx
	movq    -24(%r14),   %rcx
	movq    $0xFFFFFFFF, %r8
	call    DrawLine

	subq    $16,         %r14
	decq    %rbx
	jnz     .a_draw_loop2


/*	movq    %r13,   %rcx*/
/*	trans   8(%rcx)*/
/*	movq    %rax,       %rdi*/
/**/
/*	trans   12(%rcx)*/
/*	movq    %rax,       %rsi*/
/**/
/*	trans   16(%rcx)*/
/*	movq    %rax,       %r8*/
/**/
/*	trans   20(%rcx)*/
/*	movq    %rax,       %r9*/
/**/
/*	movq    %r8, %rdx*/
/*	movq    %r9, %rcx*/
/**/
/*	movq    $0xFFFFFFFF, %r8*/
/*	call    DrawLine*/
/**/
/*	movq    $mtype_1,   %rcx*/
/*	trans   16(%rcx)*/
/*	movq    %rax,       %rdi*/
/**/
/*	trans   20(%rcx)*/
/*	movq    %rax,       %rsi*/
/**/
/*	trans   24(%rcx)*/
/*	movq    %rax,       %r8*/
/**/
/*	trans   28(%rcx)*/
/*	movq    %rax,       %r9*/
/**/
/*	movq    %r8, %rdx*/
/*	movq    %r9, %rcx*/
/**/
/*	movq    $0xFFFFFFFF, %r8*/
/*	call    DrawLine*/



	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15
	movq    -40(%rbp),  %rbx

	movq    %rbp,   %rsp
	popq    %rbp
	ret

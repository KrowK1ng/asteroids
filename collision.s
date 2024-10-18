.data
sfmt: .asciz "%d\n"

.text


.global point_in_poly

# bool is_point_in_path(int x_player, int y_player, int64* meteorite)
point_in_poly:

	pushq	%rbp
	movq	%rsp,	%rbp
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	pushq	%rbx

	movq    %rdi,       %r10
	movq    %rsi,       %r11
	movq    %rdx,       %rdi

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

	# r15 += mul(eax, p_y)
	movl    %eax,       %edi
	movl    4(%r13),    %esi
	call    mul
	addl    %eax,       %r15d

	# eax = r15 * size
	movl    %r15d,      %eax
	cdqe
	movzb   32(%r12),   %r15
	imulq   %r15

	# push (a_x + eax) / (2 ^ 16)
	addl    (%r12),     %eax
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

	# r15 += mul(eax, p_y)
	movl    %eax,       %edi
	movl    4(%r13),    %esi
	call    mul
	addl    %eax,       %r15d

	# eax = r15 * size
	movl    %r15d,      %eax
	cdqe
	movzb   32(%r12),   %r15
	imulq   %r15

	# push (a_y + eax) / (2 ^ 16)
	addl    4(%r12),    %eax
	cdqe
	pushq   %rax

	addq    $8,         %r13
	decq    %rbx
	jnz     .a_draw_loop1


	movq    24(%r12),   %r13
	movq    (%r13),     %rcx
	movq	$0,	%r12# -> touch counter
	incq	%rcx
	movq	$0,	%rax
	movq    %r10,       %rdi
	movq    %r11,       %rsi



.loop:
	decq	%rcx
	cmpq	$0,	%rcx # %rcx -> number of point in asteroid 
	je	.epilogue


	popq	%r9 # -> y_i
	popq	%r8 # -> x_i
	popq	%r11 # -> y_{i+1}
	popq	%r10 # -> x_{i+1}
	pushq   %r10
	pushq   %r11

	# assure that y_i+1 <= y_i
	cmpl    %r11d, %r9d
	jge     .no_swap
	xorl    %r11d, %r9d
	xorl    %r9d, %r11d
	xorl    %r11d, %r9d

	xorl    %r10d, %r8d
	xorl    %r8d, %r10d
	xorl    %r10d, %r8d
.no_swap:

	cmpl	%esi,	%r11d
	jge     .loop

	cmpl	%esi,	%r9d
	jl      .loop


	# px < x1 + (x2 - x1)  * (y1 - py) / (y1 - y2)
	# (px - x1) * (y1 - y2) < (x2 - x1)  * (y1 - py)
	# (x1 - px) * (y1 - y2) > (x1 - x2)  * (y1 - py)

	# (x1 - px)
	movl    %r8d,   %eax
	subl    %edi,   %eax
	cdqe
	movq    %rax,   %r14

	# (y1 - y2)
	movl    %r9d,   %eax
	subl    %r11d,  %eax
	cdqe

	imulq   %r14
	movq    %rax,   %r14



	# (x1 - x2)
	movl    %r8d,   %eax
	subl    %r10d,  %eax
	cdqe
	movq    %rax,   %r15

	# (y1 - py)
	movl    %r9d,   %eax
	subl    %esi,   %eax
	cdqe

	imulq   %r15
	movq    %rax,   %r15


	cmpq    %r14,   %r15
	jg      .add

	jmp	.loop

.add:
	incq	%r12
	jmp	.loop

.epilogue:
	andq	$1,	%r12
	movq	%r12,	%rax


	popq	%rbx
	popq	%rbx
	popq	%rbx
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	movq	%rbp,	%rsp
	popq	%rbp
	ret	




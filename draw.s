.global draw_text

# void draw_text(char *s, int x, int y, int col)
draw_text:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $32,    %rsp
	movq    %r12,   -8(%rbp)
	movq    %r13,   -16(%rbp)
	movq    %r14,   -24(%rbp)
	movq    %r15,   -32(%rbp)

	movq    %rdi,   %r12
	movq    %rsi,   %r13
	movq    %rdx,   %r14
	movl    %ecx,   draw_col

	.draw_loop:
		movb    (%r12),     %al
		andq    $0xFF,      %rax
		movq    $font,      %rdi
		mulw    2(%rdi)
		addq    %rax,       %rdi
		addq    $4,         %rdi
		movq    %r13,       %rsi
		movq    %r14,       %rdx
		call    putBitmap
		addw    font,       %r13w
		incq    %r12
		cmpb    $0,         (%r12)
		jne     .draw_loop


	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15

	movq    %rbp,   %rsp
	popq    %rbp
	ret

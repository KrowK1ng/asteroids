.global draw_text
.global draw_signed

.data
emptyfmt: .asciz "----"

.text
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


# void draw_signed(int score, int x, int y, int col)
draw_signed:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $16,    %rsp
	movl    %ecx,   draw_col

	cmpl    $-1,    %edi
	jne     .ds_cont

	movq    $emptyfmt,      %rdi
	call    draw_text
	jmp     .ds_end
.ds_cont:
	movq    $0,             %rax
	movl    %edi,           %eax
	leaq    -9(%rbp),       %rdi
	movq    %rdx,           -8(%rbp)
	movq    $0,             %rdx
	movq    $10,            %r8

	# Null terminate
	movb    $0,             (%rdi)

	decq    %rdi
	divq    %r8
	addb    $'0,            %dl
	movb    %dl,            (%rdi)
	movb    $0,             %dl

	decq    %rdi
	divq    %r8
	addb    $'0,            %dl
	movb    %dl,            (%rdi)
	movb    $0,             %dl

	decq    %rdi
	divq    %r8
	addb    $'0,            %dl
	movb    %dl,            (%rdi)
	movb    $0,             %dl

	decq    %rdi
	divq    %r8
	addb    $'0,            %dl
	movb    %dl,            (%rdi)
	movb    $0,             %dl

	movq    -8(%rbp),       %rdx
	call    draw_text

.ds_end:
	movq    %rbp,   %rsp
	popq    %rbp
	ret

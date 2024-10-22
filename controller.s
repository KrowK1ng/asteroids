.global control_player
.data
fmt: .asciz "%x %x\n"

.text
control_player:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $48,    %rsp
	movq    %r12,   -8(%rbp)
	movq    %r13,   -16(%rbp)
	movq    %r14,   -24(%rbp)
	movq    %r15,   -32(%rbp)
	movq    %rbx,   -40(%rbp)

	cmpq    $0,     GAMEPAD
	je      .cp_end
	# GAMEPAD_AXIS_LEFT_X - 0
	# GAMEPAD_AXIS_LEFT_Y - 1

	# Get the X drift
	movq    $0,         %rdi
	movq    $0,         %rsi
	call    GetGamepadAxisMovement
	movq    %xmm0,      %rax  # X float
	shrl    $7,         %eax
	movl    %eax,       %r12d

	# Copy mantissa and add 1.xxx 💃
	andl    $0xFFFF,    %r12d
	orl     $0x10000,   %r12d
	shrl    $16,        %eax
	movl    $0,         %esi

	movzb   %al,        %rcx
	shrl    $8,         %eax   # Sign
	# If the value is too small, it becomes 0
	cmpq    $110,       %rcx
	jle     .cp_tr1_end

	movq    $127,       %rsi
	subq    %rcx,       %rsi
	movq    %rsi,       %rcx

.cp_tr1_loop:
	cmpq    $0,         %rcx
	jle     .cp_tr1_loop_end
	decq    %rcx
	shrl    $1,         %r12d
	jmp     .cp_tr1_loop
.cp_tr1_loop_end:

	andb    $1,         %al
	jz      .cp_tr1_pre_end

	# Negate the value
	notl    %r12d
	incl    %r12d
.cp_tr1_pre_end:
	movl    %r12d,      %esi
.cp_tr1_end:
	movl    %esi,       %r12d  # The X value



	# Get the Y drift
	movq    $0,         %rdi
	movq    $1,         %rsi
	call    GetGamepadAxisMovement
	movq    %xmm0,      %rax  # Y float
	shrl    $7,         %eax
	movl    %eax,       %r13d

	# Copy mantissa and add 1.xxx 🕺
	andl    $0xFFFF,    %r13d
	orl     $0x10000,   %r13d
	shrl    $16,        %eax
	movl    $0,         %esi

	movzb   %al,        %rcx
	shrl    $8,         %eax   # Sign
	# If the value is too small, it becomes 0
	cmpq    $110,       %rcx
	jle     .cp_tr2_end

	movq    $127,       %rsi
	subq    %rcx,       %rsi
	movq    %rsi,       %rcx

.cp_tr2_loop:
	cmpq    $0,         %rcx
	jle     .cp_tr2_loop_end
	decq    %rcx
	shrl    $1,         %r13d
	jmp     .cp_tr2_loop
.cp_tr2_loop_end:

	andb    $1,         %al # Inverted (negative is down)
	jnz     .cp_tr2_pre_end

	# Negate the value
	notl    %r13d
	incl    %r13d
.cp_tr2_pre_end:
	movl    %r13d,      %esi
.cp_tr2_end:
	movl    %esi,       %r13d  # The Y value


	# r14 will be distance^2
	movl    %r12d,      %edi
	movl    %r12d,      %esi
	call    mul
	movl    %eax,       %r14d

	movl    %r13d,      %edi
	movl    %r13d,      %esi
	call    mul
	addl    %eax,       %r14d

	# If the distance < 0.5 don't trigger
	cmpl    $0xc000,    %r14d
	jl      .cp_end


	# Get the X drift
	movq    $0,         %rdi
	movq    $0,         %rsi
	call    GetGamepadAxisMovement
	movq    %xmm0,      %rax  # X float
	pushq   %rax

	# Get the Y drift
	movq    $0,         %rdi
	movq    $1,         %rsi
	call    GetGamepadAxisMovement
	popq    %rax
	movq    %rax,       %xmm1
	movq    %xmm0,      %rax  # Y float
	pushq   %rax #negate
	xorb    $0x80,         3(%rsp)
	popq    %rax
	movq    %rax,       %xmm0


	call   atan2f
	movq    %xmm0,      %rax

	movl    %eax,       %r13d

	# Copy mantissa and add 1.xxx
	andl    $0x7FFFFF,  %r13d
	orl     $0x800000,  %r13d
	shrl    $23,        %eax
	movl    $0,         %esi

	movzb   %al,        %rcx
	shrl    $8,         %eax   # Sign
	# If the value is too small, it becomes 0
	cmpq    $110,       %rcx
	jle     .cp_tr3_end

	movq    $134,       %rsi
	subq    %rcx,       %rsi
	movq    %rsi,       %rcx

.cp_tr3_loop:
	cmpq    $0,         %rcx
	jle     .cp_tr3_loop_end
	decq    %rcx
	shrl    $1,         %r13d
	jmp     .cp_tr3_loop
.cp_tr3_loop_end:

	andb    $1,         %al
	jz      .cp_tr3_pre_end

	# Negate the value
	movl    DPI,        %r12d
	subl    %r13d,      %r12d
	movl    %r12d,      %r13d
.cp_tr3_pre_end:
	movl    %r13d,      %esi
.cp_tr3_end:
	movl    %esi,       %r12d

	movq    $player,    %r15
	movl    %r12d,      16(%r15)

	movq    $player,    %rax
	movl    16(%rax),   %edi
	call    _cos
	movl    %eax,       %edi
	movl    $0xA0000,   %esi
	call    mul
	movl    $0x10000,    %esi
	movl    %eax,       %edi
	call    mul
	movl    %eax,       %edi
	movq    $player,    %rax
	addl    %edi,       24(%rax)

	movl    16(%rax),   %edi
	call    _sin
	movl    %eax,       %edi
	movl    $0xA0000,   %esi
	call    mul
	movl    $0x10000,    %esi
	movl    %eax,       %edi
	call    mul
	movl    $0,         %edi
	subl    %eax,       %edi
	movq    $player,    %rax
	addl    %edi,       28(%rax)


.cp_end:
	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15
	movq    -40(%rbp),  %rbx

	movq    %rbp,   %rsp
	popq    %rbp
	ret

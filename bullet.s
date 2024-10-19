.global b_init
.global b_remove
.global bullets

.data
MBULLETS: .quad 256
BULLET_SPEED: .long 0x100000
bullets:
	.quad 0    # cnt
	.space 4096 # 16 bytes per object

d_brmsg: .asciz "Bullet removed. %d bullets left.\n"

.text


# void b_init(f x, f y, f a)
b_init:
	pushq   %rbp
	movq    %rsp,       %rbp

	subq    $16,        %rsp
	movq    %r12,       -8(%rbp)
	movq    %r13,       -16(%rbp)

	# Memory check. Don't add more bullets if the slots are full
	movq    $bullets,       %r12
	movq    bullets,        %rcx
	cmpq    %rcx,           MBULLETS
	je      .b_init_end

	incq    (%r12)
	addq    $8,             %r12
	shlq    $4,             %rcx       # rcx *= 16
	addq    %rcx,           %r12

	movl    %edi,           (%r12)     # b_x = x
	movl    %esi,           4(%r12)    # b_y = y
	movl    %edx,           %r13d

	# eax = cos(angle)
	movl    %r13d,          %edi
	call    _cos

	# xspeed = mul(eax, BULLET_SPEED)
	movl    %eax,           %edi
	movl    BULLET_SPEED,   %esi
	call    mul
	movl    %eax,           8(%r12)

	# eax = sin(angle)
	movl    %r13d,          %edi
	call    _sin

	# yspeed = -mul(eax, BULLET_SPEED)
	movl    %eax,           %edi
	movl    BULLET_SPEED,   %esi
	call    mul
	negl    %eax
	incl    %eax
	movl    %eax,           12(%r12)

.b_init_end:
	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13

	movq    %rbp,   %rsp
	popq    %rbp
	ret


# void b_remove(bullet *pntr)
b_remove:
	movq    $bullets,       %rsi
	decq    (%rsi)
	movq    (%rsi),         %rcx

	addq    $8,             %rsi
	shlq    $4,             %rcx    # BSIZE
	addq    %rcx,           %rsi

	cmpq    %rdi,           %rsi
	je      .b_remove_loop_end
.b_remove_loop:
	movq    16(%rdi),       %rax    # BSIZE
	movq    %rax,           (%rdi)
	addq    $8,             %rdi
	cmpq    %rdi,           %rsi
	jne     .b_remove_loop
.b_remove_loop_end:

	# TODO DEBUG
	pushq   %rax
	movq    $0,             %rax
	movq    $d_brmsg,       %rdi
	movq    bullets,        %rsi
	# call    printf
	popq    %rax

	ret

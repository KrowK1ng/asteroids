.global meteor_init_types
.global a_draw
.global a_remove
.global a_destroy
.global a_spawn
.global a_rem_middle
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
	.quad 0, 0     # cnt and total size (both <= 256)
	.space 12288
d_armsg: .asciz "Asteroid removed. %d asteroids left.\n"

mtype_1:
.quad 10
.long -0x13C63B, -0x38223
.long -0xF33EE, -0x12EC80
.long 0x4AD84, -0x188EF7
.long 0x149FF6, -0xBCD02
.long 0x1594E9, 0x2A868
.long 0xBB1CB, 0xF18B7
.long 0x17D07, 0x89C85
.long -0x366E, 0x10E764
.long -0xCA6BD, 0xC1EA8
.long -0xB9693, 0x2C39F
.long -0x13C63B, -0x38223
	.quad 10
	.long 0x0C0000, 0x140000
	.long 0x140000, -0x040000
	.long 0x0C0000, -0x0C0000
	.long 0x040000, -0x0C0000
	.long -0x040000, -0x140000
	.long -0x140000, -0x0C0000
	.long -0x0C0000, -0x040000
	.long -0x0C0000, 0x040000
	.long -0x040000, 0x0C0000
	.long -0x040000, 0x040000
	.long 0x0C0000, 0x140000


mtype_2:
.quad 7
.long -0x16BEFE, 0x2F675
.long -0xEB7D1, -0x114C69
.long 0x3D2A7, -0x153788
.long 0x1304CE, -0x8690A
.long 0x148C44, 0xE3D7C
.long 0xDC32, 0x8B270
.long -0x63650, 0x14BD33
.long -0x16BEFE, 0x2F675

	.quad 6
	.long 0x100000, 0x080000
	.long 0x000000, 0x180000
	.long -0x100000, 0x080000
	.long -0x100000, -0x080000
	.long 0x000000, -0x180000
	.long 0x100000, -0x080000
	.long 0x100000, 0x080000

mtype_3:
	.quad 8
	.long 0x180000, 0x080000
	.long 0x080000, 0x180000
	.long -0x080000, 0x180000
	.long -0x180000, 0x080000
	.long -0x180000, -0x080000
	.long -0x08000, -0x180000
	.long 0x080000, -0x180000
	.long 0x180000, -0x080000
	.long 0x180000, 0x080000


mtype_4:
	.quad 9
	.long 0x000000, 0x060000
	.long -0x0C0000, 0x120000
	.long -0x180000, 0x060000
	.long -0x0C0000, -0x120000
	.long 0x000000, -0x060000
	.long 0x0C0000, -0x120000
	.long 0x0C0000, -0x060000
	.long 0x180000, 0x060000
	.long 0x0C0000, 0x120000
	.long 0x000000, 0x060000

mtype_5:
	.quad 10

	.long 0x100000, 0x00000
	.long 0x0AAAAA, 0x0AAAAA
	.long 0x02AAAA, 0x0EAAAA
	.long -0x0AAAAA, 0x0AAAAA
	.long -0x100000, 0x055555
	.long -0x0EAAAA, 0x000000
	.long -0x100000, -0x0AAAAA
	.long -0x0AAAAA, -0x0EAAAA
	.long 0x02AAAA, -0x0AAAAA
	.long 0x0EAAAA, -0x0AAAAA
	.long 0x100000, 0x00000



# struct asteroid {
#   f x, y;
#   f vx, vy;
#   f angle, va;
#x   .quad type 
#x   byte s	1 <= s <= 3
# } = 48 bytes


.text
meteor_init_types:
	pushq   %rbp
	movq    %rsp,       %rbp

	movq    $meteors,   %rdi
	movq    $0,         (%rdi)    # a_cnt = 0
/*
	movq    $meteors,   %rdi
	addq    $2,         (%rdi)    # a_cnt = 2
	addq    $16,        %rdi

	movq    $mtype_3,   %rsi	#type
	movq    %rsi,       24(%rdi)
	movl    $0x1000000,         (%rdi) # x pos
	movl    $0x1000000,         4(%rdi) # y pos
	movl    $0x10000,         8(%rdi)  # vx
	movl    $-0x1f000,         12(%rdi) # vy
	movl    $0x1100,         16(%rdi)   # angle

	movl    $0,         20(%rdi)	#va
	movb    $1,         32(%rdi)	#size

	addq    $48,        %rdi
	movq    $mtype_1,   %rsi
	movq    %rsi,       24(%rdi)
	movl    $0x2000000,         (%rdi)
	movl    $0x10000,         4(%rdi)
	movl    $-0x10000,         8(%rdi)
	movl    $0xf000,         12(%rdi)
	movl    $0,         16(%rdi)
	movl    $0x1000,         20(%rdi)
	movb    $2,         32(%rdi)
//*/


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


	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15
	movq    -40(%rbp),  %rbx

	movq    %rbp,   %rsp
	popq    %rbp
	ret


a_spawn:
	pushq	 %rbp
	movq	 %rsp,	%rbp

	movq $0, %rdi
	movq $2, %rsi
	call randquad
	movq %rax, %rcx
	movq $0, %rdi
	movq $2, %rsi
	call randquad
	addq %rcx, %rax

	cmpq $0, %rax  # asteroids don't spawn 1/5 for shits 💩 and iggles 🤣
	je   .as_end

	call    a_init

.as_end:
	movq	%rbp,	%rsp
	popq	%rbp
	ret

/*

	movq    $meteors,   %rdi
	addq    $2,         (%rdi)    # a_cnt = 2
	addq    $16,        %rdi

	movq    $mytype_3,   24(%rdi)

	movl    $0x1000000,         (%rdi) # x pos
	movl    $0x1000000,         4(%rdi) # y pos
	movl    $0x10000,         8(%rdi)  # vx
	movl    $-0x1f000,         12(%rdi) # vy
	movl    $0x1100,         16(%rdi)   # angle

	movl    $0,         20(%rdi)	#va
	movb    $1,         32(%rdi)	#size
*/
# f a_init()
a_init:
	pushq	 %rbp
	movq	 %rsp,	%rbp 
	pushq	%rbx	# random number keeper
	pushq	%rbx
		

	movq	$meteors,	%r11
	cmpq	$256,	8(%r11)
	movq $0, %rdi
	jge	.end
	
	movq $0, %rdi
	movq $2, %rsi
	call randquad
	movq %rax, %rcx
	movq $0, %rdi
	movq $2, %rsi
	call randquad
	addq %rcx, %rax

	cmpq	$1,	%rax
	je	.fst_type

	cmpq	$2,	%rax
	je	.snd_type
	
	cmpq	$3, %rax
	je	.frt_type

	cmpq	$4, %rax
	je	.fth_type

	jmp	.trd_type

.fst_type:
	movq $mtype_1, %rdi
	jmp	.continue

.snd_type:
	movq $mtype_2, %rdi
	jmp	.continue

.trd_type:
	movq $mtype_3, %rdi
	jmp	.continue
.frt_type:
	movq $mtype_4, %rdi
	jmp	.continue

.fth_type:
	movq $mtype_5, %rdi
	jmp	.continue

.continue:
	movq $meteors,	%rcx

	movq (%rcx),	%rax # count of meteors until now
	movq $48, %rdx
	mul %rdx
	addq    $1,         (%rcx)    # a_cnt =+1
# TODO fix this because it doesnt have the right value
//	addq	%rax,	   8(%rcx)    # a_size =+ siz
	addq    $16,        %rcx 
	addq %rax, %rcx
	movq    %rdi,	    24(%rcx)

# TODO: change x and y to random outer-bound positions	

    call pseudorand
    rolq $1, %rax
    movq $0, %rdx
    movq %rax, %rbx
    movq $2, %rdi
    divq %rdi
    cmpq $0, %rdx
    je .case1

    jmp .case2


	.case1:

    call pseudorand
    rolq $1, %rax
    movq $0, %rdx
    movq %rax, %rbx
    movq $2, %rdi
    divq %rdi
    cmpq $0, %rdx
    je .case3


	movl	W, %edi
	addl	$80,  %edi      # BORDERDELTA
	movl	%edi, %eax
	shl	$16, %eax
	movl	%eax,	(%rcx)   # random x pos
	movl	$0, %edi
	movl	H, %esi
	call	randlong

	shl	$16, %eax
	movl    %eax,	4(%rcx)  # random y pos

	jmp .other_thing_m


	.case3:


	movl	$-80, %eax      # BORDERDELTA
	shl	$16, %eax
	movl	%eax,	(%rcx)   # random x pos
	movl	$0, %edi
	movl	H, %esi
	call	randlong

	shl	$16, %eax
	movl    %eax,	4(%rcx)  # random y pos



	jmp .other_thing_m
	.case4:


	movl	$0, %edi
	movl	W, %esi 
	call	randlong
	shl	$16, %eax
	movl	%eax,	(%rcx)   # random x pos
	movl $-80, %eax          # BORDERDELTA
	shl	$16, %eax
	movl    %eax,	4(%rcx)  # random y pos


	jmp .other_thing_m
	.case2:

    call pseudorand
    rolq $1, %rax
    movq $0, %rdx
    movq %rax, %rbx
    movq $2, %rdi
    divq %rdi
    cmpq $0, %rdx
    je .case4


	movl	$0, %edi
	movl	W, %esi 
	call	randlong
	shl	$16, %eax
	movl	%eax,	(%rcx)   # random x pos
	movl	H, %edi
	addl	$80, %edi       # BORDERDELTA
	movl	%edi , %eax

	shl	$16, %eax
	movl    %eax,	4(%rcx)  # random y pos

	.other_thing_m:



	movl	H, %r10d
	shl	$15, %r10d

	movl    $0x080, %edi
	movl    $0x100, %esi
	call    randlong
	shll    $8,    %eax
	movl    %eax,  %edx
	movl    4(%rcx),%eax
	subl	%r10d, %eax
	notl	%eax
	incl	%eax
	cdqe 
	shr $7, %rax
	movl    %eax,   %edi
	movl    %edx,   %esi
	call    mul
	movl	%eax,	12(%rcx)
	movl    $0,         %edi
	movl    $0x23000,  %esi
	call    randlong
	subl    $0x11800,   %eax
	addl	%eax,	12(%rcx)

	movl	W, %r11d
	shl	$15, %r11d

	movl    $0x080, %edi
	movl    $0x100, %esi
	call    randlong
	shll    $8,    %eax
	movl    %eax,  %edx
	movl    (%rcx),	%eax
	subl	%r11d, %eax
	notl	%eax
	incl	%eax
	cdqe 
	shr $7, %rax
	movl    %eax,   %edi
	movl    %edx,   %esi
	call    mul
	movl	%eax, 8(%rcx)
	movl    $0,         %edi
	movl    $0x23000,  %esi
	call    randlong
	subl    $0x11800,   %eax
	addl	%eax,	8(%rcx)


/*	movq $meteors,	%rcx*/
	.break:	
	
	movl	$0,	%edi
	movl	DPI,	%esi
	call	randlong
	movl	%eax, 16(%rcx)	

	
	movl	$2200,	%edi
	movl	$2800,	%esi
	call randlong
	movl	$2800,	20(%rcx)	


	movl	$1, %edi
	movl	$3, %esi
	call randlong
	movb    %al,	32(%rcx)

	movq $1, %rdi
.end:
	movq %rdi,      %rax
	popq %rbx
	popq %rbx
	movq	%rbp,	%rsp
	popq	%rbp
	ret

a_remove:
	movq    $meteors,       %rsi
	decq    (%rsi)
	movq    (%rsi),         %rcx

	addq    $16,            %rsi
	movq    $48,            %rax    # MSIZE
	mulq    %rcx
	addq    %rax,           %rsi

	cmpq    %rdi,           %rsi
	je      .a_remove_loop_end
.a_remove_loop:
	movq    48(%rdi),       %rax    # MSIZE
	movq    %rax,           (%rdi)
	addq    $8,             %rdi
	cmpq    %rdi,           %rsi
	jne     .a_remove_loop
.a_remove_loop_end:

	# TODO DEBUG
	pushq   %rax
	movq    $0,             %rax
	movq    $d_armsg,       %rdi
	movq    meteors,        %rsi
/*	call    printf*/
	popq    %rax

	ret


a_destroy:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $32,        %rsp
	movq    %r12,       -8(%rbp)
	movq    %r13,       -16(%rbp)
	movq    %r14,       -24(%rbp)


	movzb    32(%rdi),      %r12
	movl     (%rdi),        %r13d
	movl     4(%rdi),       %r14d

	addl     %r12d,         score
	call     a_remove

	# Split meteors into to
	decb     %r12b
	jz       .adst_end

	# TODO, do size while creating

	call     a_init
	cmpq     $0,            %rax
	je       .adst_end

	movq     $meteors,      %rdi
	movq     (%rdi),        %rax
	movq     $48,           %rcx
	mulq     %rcx
	addq     %rax,          %rdi
	subq     $32,           %rdi

	movl     %r13d,         (%rdi)
	movl     %r14d,         4(%rdi)
	movb     %r12b,         32(%rdi)

	call     a_init
	cmpq     $0,            %rax
	je       .adst_end

	movq     $meteors,      %rdi
	movq     (%rdi),        %rax
	movq     $48,           %rcx
	mulq     %rcx
	addq     %rax,          %rdi
	subq     $32,           %rdi


	movl     %r13d,         (%rdi)
	movl     %r14d,         4(%rdi)
	movb     %r12b,         32(%rdi)


	.adst_end:
	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14

	movq    %rbp,   %rsp
	popq    %rbp
	ret


a_rem_middle:
	pushq   %rbp
	movq    %rsp,   %rbp

	subq    $16,        %rsp
	movq    %r12,       -8(%rbp)
	movq    %rbx,       -16(%rbp)

	movq    $meteors,         %r12
	movq    (%r12),           %rbx      # rbx = a_cnt
	addq    $16,              %r12      # r12 = a_pnt

	cmpq    $0,               %rbx
	je      .arm_end
.arm_remove_loop:
	movl    W,                %eax
	shrl    $1,               %eax
	addl    $256,             %eax
	shll    $16,              %eax
	cmpl    %eax,             (%r12)
	jg      .arm_rloop_pre_end
	subl    $0x2000000,       %eax
	cmpl    %eax,             (%r12)
	jl      .arm_rloop_pre_end

	movl    H,                %eax
	shrl    $1,               %eax
	addl    $256,             %eax
	shll    $16,              %eax
	cmpl    %eax,             4(%r12)
	jg      .arm_rloop_pre_end
	subl    $0x2000000,       %eax
	cmpl    %eax,             4(%r12)
	jl      .arm_rloop_pre_end

	movq    %r12,             %rdi
	call    a_remove
	subq    $48,              %r12      # r12 = a_pnt-- MSIZE

.arm_rloop_pre_end:
	addq    $48,              %r12      # r12 = a_pnt++ MSIZE
	decq    %rbx
	jnz     .arm_remove_loop


.arm_end:
	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    %rbp,   %rsp
	popq    %rbp
	ret

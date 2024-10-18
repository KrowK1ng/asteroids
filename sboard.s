.global sboard_loop
.global sboard_init
.global sboard_add_score

.data
bfmt:   .asciz "Press [X] to start."
.quad 0 # allignment
sboard_list:
	.space  200   # [NAMESIZE (16) + score (4)] * SLISTSIZE

.text
# TODO, read from file
sboard_init:
	movq    $sboard_list,   %rdi
	movq    $10,            %rcx     # SLISTSIZE

.sboard_init_loop:
	movq    $0,             (%rdi)
	movq    $0,             8(%rdi)
	movl    $-1,            16(%rdi)
	movb    $' ,             (%rdi)
	addq    $20,            %rdi     # NAMESIZE
	loop    .sboard_init_loop

	ret



sboard_loop:
	pushq   %rbp
	movq    %rsp,       %rbp

	subq    $32,        %rsp
	movq    %r12,       -8(%rbp)
	movq    %r13,       -16(%rbp)
	movq    %r14,       -24(%rbp)
	movq    %r15,       -32(%rbp)

.sb_loop:
	call    GetKeyPressed
	cmpl    $0,         %eax
	je      .sb_loop_end

# Enter - 257
# Backspace - 259

	cmpl    $'F,        %eax
	jne     .sb_loop_fs_skip

	call    ToggleFullscreen
	jmp     .sb_loop
.sb_loop_fs_skip:

	cmpl    $'X,        %eax
	jne     .sb_loop

	call    menu_init
	movb    $1,         gstate
	jmp     .sboard_loop_end
.sb_loop_end:

	movq    $0xFF0000000,     %rdi
	call    ClearBackground

	movq    $bfmt,      %rdi
	movl    $25,        %esi
	movl    $10,        %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

	movq    $sboard_list,   %r12
	movq    $10,            %r13     # SLISTSIZE
	movq    $80,            %r14     # Y Coord

.sb_draw_loop:
	movq    %r12,           %rdi
	movq    $120,           %rsi
	movq    %r14,           %rdx
	movl    $0xFFFFFFFF,    %ecx
	call    draw_text

	movl    16(%r12),       %edi
	movq    $400,           %rsi
	movq    %r14,           %rdx
	movl    $0xFFFFFFFF,    %ecx
	call    draw_signed

	addq    $16,            %r14
	addq    $20,            %r12     # NAMESIZE
	decq    %r13
	jnz     .sb_draw_loop


.sboard_loop_end:
	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13
	movq    -24(%rbp),  %r14
	movq    -32(%rbp),  %r15

	movq    %rbp,       %rsp
	popq    %rbp
	ret


sboard_add_score:
	movq    $pname,         %rax

	addq    $2,             %rax
	movq    $10,            %rcx    # SLISTSIZE
	movq    $sboard_list,   %rsi
.sboard_as_loop:
	movl    16(%rsi),       %r8d    # NAMESIZE
	cmpl    score,          %r8d
	jge     .sboard_as_noswap
	movl    score,          %r9d
	movl    %r8d,           score
	movl    %r9d,           16(%rsi)# NAMESIZE

	movq    $pname,         %rax
	addq    $2,             %rax
	movq    %rsi,           %rdi
.sb_swap_string:
	movb    (%rax),         %r9b
	movb    (%rdi),         %r8b
	movb    %r8b,           (%rax)
	movb    %r9b,           (%rdi)
	incq    %rax
	incq    %rdi

	cmpb    $0,             %r9b
	jne     .sb_swap_string
	cmpb    $0,             %r8b
	jne     .sb_swap_string

.sboard_as_noswap:
	addq    $20,            %rsi   # NAMESIZE
	loop    .sboard_as_loop

	ret

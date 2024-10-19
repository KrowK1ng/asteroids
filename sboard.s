.global sboard_loop
.global sboard_init
.global sboard_add_score

.data
bfmt1:   .asciz "Press [C] to warp."
bfmt2:   .asciz "Press [X] to shoot."
bfmt3:   .asciz "Move with arrow keys."
bfmt4:   .asciz "Press [Enter] to start."
title1: .asciz "          :::     ::::::::::::::::::::::::::::::::::::::  ::::::::::::::::::::::::::::  :::::::: "
title2: .asciz "       :+: :+:  :+:    :+:   :+:    :+:       :+:    :+::+:    :+:   :+:    :+:    :+::+:    :+: "
title3: .asciz "     +:+   +:+ +:+          +:+    +:+       +:+    +:++:+    +:+   +:+    +:+    +:++:+         "
title4: .asciz "   +#++:++#++:+#++:++#++   +#+    +#++:++#  +#++:++#: +#+    +:+   +#+    +#+    +:++#++:++#++   "
title5: .asciz "  +#+     +#+       +#+   +#+    +#+       +#+    +#++#+    +#+   +#+    +#+    +#+       +#+    "
title6: .asciz " #+#     #+##+#    #+#   #+#    #+#       #+#    #+##+#    #+#   #+#    #+#    #+##+#    #+#     "
title7: .asciz "###     ### ########    ###    #############    ### ############################  ########       "
stitle: .asciz "Scoreboard"
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
	movb    $'-,             (%rdi)
	movb    $' ,            1(%rdi)
	movb    $'e,            2(%rdi)
	movb    $'m,            3(%rdi)
	movb    $'p,            4(%rdi)
	movb    $'t,            5(%rdi)
	movb    $'y,            6(%rdi)
	movb    $' ,            7(%rdi)
	movb    $'-,            8(%rdi)
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

	cmpl    $257,       %eax
	jne     .sb_loop

	call    menu_init
	movb    $1,         gstate
	jmp     .sboard_loop_end
.sb_loop_end:

	movq    $0xFF0000000,     %rdi
	call    ClearBackground

# Draw instructions
	movq    $bfmt1,     %rdi
	movl    $14,        %esi
	movl    $474,       %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

	movq    $bfmt2,     %rdi
	movl    $14,        %esi
	movl    $487,       %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

	movq    $bfmt3,     %rdi
	movl    $14,        %esi
	movl    $500,       %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

	movq    $bfmt4,     %rdi
	movl    $14,        %esi
	movl    $513,       %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

# Draw title
	movq    $140,           %r13     # X coord
	movq    $30,            %r14     # Y coord
	movl    $0xFFFFFFFF,    %r12d    # color

	movq    $title1,        %rdi
	movq    %r13,           %rsi
	movq    %r14,           %rdx
	addq    $13,            %r14
	movl    %r12d,          %ecx
	call    draw_text

	movq    $title2,        %rdi
	movq    %r13,           %rsi
	movq    %r14,           %rdx
	addq    $13,            %r14
	movl    %r12d,          %ecx
	call    draw_text

	movq    $title3,        %rdi
	movq    %r13,           %rsi
	movq    %r14,           %rdx
	addq    $13,            %r14
	movl    %r12d,          %ecx
	call    draw_text

	movq    $title4,        %rdi
	movq    %r13,           %rsi
	movq    %r14,           %rdx
	addq    $13,            %r14
	movl    %r12d,          %ecx
	call    draw_text

	movq    $title5,        %rdi
	movq    %r13,           %rsi
	movq    %r14,           %rdx
	addq    $13,            %r14
	movl    %r12d,          %ecx
	call    draw_text

	movq    $title6,        %rdi
	movq    %r13,           %rsi
	movq    %r14,           %rdx
	addq    $13,            %r14
	movl    %r12d,          %ecx
	call    draw_text

	movq    $title7,        %rdi
	movq    %r13,           %rsi
	movq    %r14,           %rdx
	addq    $13,            %r14
	movl    %r12d,          %ecx
	call    draw_text

	addq    $39,            %r14
	movq    $stitle,        %rdi
	movq    $445,           %rsi
	movq    %r14,           %rdx
	addq    $13,            %r14
	movl    %r12d,          %ecx
	call    draw_text

	# Draw the names
	movq    $sboard_list,   %r12
	movq    $10,            %r13     # SLISTSIZE

.sb_draw_loop:
	movq    %r12,           %rdi
	movq    $200,           %rsi
	movq    %r14,           %rdx
	movl    $0xFFFFFFFF,    %ecx
	call    draw_text

	movl    16(%r12),       %edi
	movq    $718,           %rsi
	movq    %r14,           %rdx
	movl    $0xFFFFFFFF,    %ecx
	call    draw_signed

	addq    $20,            %r14
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

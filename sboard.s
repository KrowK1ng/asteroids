.global sboard_loop

.data
bfmt:   .asciz "Press [X] to start."

.text
sboard_loop:
	pushq   %rax

.sb_loop:
	call    GetKeyPressed
	cmpl    $0,         %eax
	je      .sb_loop_end

# Enter - 257
# Backspace - 259

	cmpl    $'X,        %eax
	jne     .sb_loop

	call    menu_init
	movb    $1,         gstate
	popq    %rax
	ret
.sb_loop_end:

	movq    $0xFF0000000,     %rdi
	call    ClearBackground

	movq    $bfmt,      %rdi
	movl    $25,        %esi
	movl    $10,        %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

	popq    %rax
	ret

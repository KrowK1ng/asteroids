.global menu_loop
.global menu_init
.data
s_fmt: .asciz "%d\n"
test_text:   .asciz "Enter your name:"
textoak:   .asciz "Professor OAK: Hello there! My name is OAK! ...Erm. What was your name again?"
textinp:   .asciz "> "

.text
menu_init:
	# Reset name to empty
	movq    $pname,     %rax
	movb    $0,         (%rax)
	movb    1(%rax),    %cl
	andq    $0xFF,      %rcx
	incq    %rcx
	addq    $2,         %rax

.mi_loop:
	movb    $0,         (%rax)
	incq    %rax
	loop    .mi_loop

	ret


menu_loop:
	pushq   %rax

	# READ Characters
.ml_loop:
	call    GetCharPressed
	cmpl    $0,         %eax
	je      .ml_loop_end
	cmpl    $' ,        %eax # We don't allow spaces in the name
	je      .ml_loop_end

	movq    $pname,     %rdi
	movb    (%rdi),     %cl
	andq    $0xFF,      %rcx
	cmpb    %cl,        1(%rdi)
	je      .ml_loop_end
	movb    %al,        2(%rdi, %rcx)
	incb    (%rdi)

	jmp     .ml_loop
.ml_loop_end:

.ml_loop2:
	call    GetKeyPressed
	cmpl    $0,         %eax
	je      .ml_loop_end2

# Enter - 257
# Backspace - 259

	cmpl    $259,       %eax
	jne     .ml_loop_notBk

	movq    $pname,     %rdi
	movb    (%rdi),     %cl
	andq    $0xFF,      %rcx
	jz      .ml_loop2
	decq    %rcx
	decb    (%rdi)
	movb    $0,         2(%rdi, %rcx)

.ml_loop_notBk:
	cmpl    $257,       %eax
	jne     .ml_loop2
	cmpb    $0,         (pname)
	je     .ml_loop2

	call    gameInit
	movb    $2,         gstate

#TODO TEMP
/*	movq    $s_fmt,     %rdi*/
/*	movq    $score,     %rsi*/
/*	movq    $0,         %rax*/
/*	call    scanf*/
/*	call    sboard_add_score*/
/*	movb    $0,         gstate*/
	popq    %rax
	ret

.ml_loop_end2:


	movq    $0xFF0000000,     %rdi
	call    ClearBackground

	movq    $textoak, %rdi
	movl    $100,        %esi
	movl    $230,        %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

	movq    $textinp, %rdi
	movl    $100,        %esi
	movl    $243,        %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

	movq    $pname,     %rdi
	cmpb    $0,         (%rdi)
	je      .menuloop_end
	addq    $2,         %rdi
	movl    $114,        %esi
	movl    $243,        %edx
	movl    $0xFFFFFFFF,%ecx
	call    draw_text

.menuloop_end:
	popq    %rax
	ret

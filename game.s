/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/

.macro line x0, y0, x1, y1, col
		movq	\x0, %rdi
		movq 	\y0, %rsi
		movq	\x1, %rdx
		movq 	\y1, %rcx
		movq 	\col, %r8
		call DrawLine
.endm

.file "src/game/game.s"

.global gameInit
.global gameLoop

test_text:   .asciz "The quick brown fox jumps over the lazy dog. 0010"

.text
gameInit:
	call player_init

	ret

gameLoop:
	pushq   %rbp
	movq    %rsp,   %rbp

	movq    $0xFF0000000,     %rdi
	call    ClearBackground

	# movq    $player, %rax
	# addl    $0x00FFF,16(%rax)
	# movl    DPI,     %ecx
	# cmpl    %ecx,    16(%rax)
	# jle     glcont
	# subl    %ecx,    16(%rax)

.start_input:
	call readKeyCode
	cmpb    $0x00,  %al
	je      .end_input

	cmpb    $0xE0,  %al
	je      .arrow_input

	jmp     .start_input

.arrow_input:
	call readKeyCode

	cmpb    $0x48,  %al
	je      .down_up_input
	cmpb    $0x50,  %al
	je      .down_down_input
	cmpb    $0x4B,  %al
	je      .down_left_input
	cmpb    $0x4D,  %al
	je      .down_right_input

	cmpb    $0xC8,  %al
	je      .up_up_input
	cmpb    $0xD0,  %al
	je      .up_down_input
	cmpb    $0xCB,  %al
	je      .up_left_input
	cmpb    $0xCD,  %al
	je      .up_right_input

	jmp     .start_input
	.down_up_input:
		movb    $1,     input_up
		jmp     .start_input

	.down_down_input:
		movb    $1,     input_down
		jmp     .start_input

	.down_right_input:
		movb    $1,     input_right
		jmp     .start_input

	.down_left_input:
		movb    $1,     input_left
		jmp     .start_input

	.up_up_input:
		movb    $0,     input_up
		jmp     .start_input

	.up_down_input:
		movb    $0,     input_down
		jmp     .start_input

	.up_right_input:
		movb    $0,     input_right
		jmp     .start_input

	.up_left_input:
		movb    $0,     input_left
		jmp     .start_input


.end_input:

	cmpb    $1,         input_left
	je      .increase_angle
	jmp     .end_increase_angle


.increase_angle:
	movq    $player,    %rax
	addl    $0x02000,   16(%rax)
	movl    DPI,        %ecx
	cmpl    %ecx,       16(%rax)
	jle     .end_increase_angle
	subl    %ecx,       16(%rax)
.end_increase_angle:

	cmpb    $1,         input_right
	je      .decrease_angle
	jmp     .end_decrease_angle

.decrease_angle:
	movq    $player,    %rax
	subl    $0x02000,   16(%rax)
	movl    DPI,        %ecx
	cmpl    $0,         16(%rax)
	jge     .end_decrease_angle
	addl    %ecx,       16(%rax)
.end_decrease_angle:

	cmpb    $1,         input_up
	je      .set_speed
	jmp     .unset_speed

.set_speed:
	movq    $player,    %rax
	movl    16(%rax),   %edi
	call    _cos
	movl    %eax,       %edi
	movl    $0x40000,    %esi
	call    mul
	movl    %eax,       %edi
	movq    $player,    %rax
	movl    %edi,       8(%rax)

	movl    16(%rax),   %edi
	call    _sin
	movl    %eax,       %edi
	movl    $0x40000,    %esi
	call    mul
	movl    $0,         %edi
	subl    %eax,       %edi
	movq    $player,    %rax
	movl    %edi,       12(%rax)

	jmp .end_set_speed


.unset_speed:
	movq    $player,    %rax
	movl    $0,         8(%rax)
	movl    $0,         12(%rax)
.end_set_speed:


	# Add speed
	movq    $player, %rax
	movl    8(%rax), %edx
	addl    %edx,    (%rax)
	movl    12(%rax),%edx
	addl    %edx,    4(%rax)

	movl    W,       %edi
	shll    $16,     %edi
	cmpl    $0,      (%rax)
	jl      .pos_x_small

	cmpl    %edi,    (%rax)
	jge     .pos_x_big
	jmp     .pos_x_end

.pos_x_small:
	addl    %edi,    (%rax)
	jmp     .pos_x_end
.pos_x_big:
	subl    %edi,    (%rax)
	# jmp     .pos_x_end
.pos_x_end:

	movl    H,       %edi
	shll    $16,     %edi
	cmpl    $0,      4(%rax)
	jl      .pos_y_small

	cmpl    %edi,    4(%rax)
	jge     .pos_y_big
	jmp     .pos_y_end

.pos_y_small:
	addl    %edi,    4(%rax)
	jmp     .pos_y_end
.pos_y_big:
	subl    %edi,    4(%rax)
	# jmp     .pos_y_end
.pos_y_end:

	movl    player,  %edi
	movl    4(%rax), %esi
	shrl    $16,     %edi
	shrl    $16,     %esi
	movl    $0xFFFFFFFF,      %edx
	call    DrawPixel
	call    player_draw

	movq    $test_text, %rdi
	movq    $player,    %rax
	movl    (%rax),     %esi
	movl    4(%rax),    %edx
	shrl    $16,        %esi
	shrl    $16,        %edx
	addl    $20,        %esi
	subl    $20,        %edx
	movl    %esi,       %eax

	# call draw_text

	movq    %rbp,   %rsp
	popq    %rbp
	ret

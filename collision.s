.text


.global point_in_poly

# f is_point_in_path(int x_player, int y_player, int len_array)
point_in_poly:

	pushq	%rbp
	movq	%rsp,	%rbp
	pushq	%r12

	movq	$0,	%r12# -> touch counter
	incq	%rdx
	movq	$0,	%rax


.loop:
	decq	%rdx
	cmpq	$0,	%rdx # %rdx -> number of point in asteroid 
	je	.epilogue


	popq	%r9 # -> y_i
	popq	%r8 # -> x_i
	popq	%r11 # -> y_{i+1}
	popq	%r10 # -> x_{i+1}
#	... push all

	cmpl	%esi, %r9d
	jl	.second_cond

	cmpl	 %esi, %r11d
	jl	.x_check

	jmp	.loop

.second_cond:
	cmpl	%esi,	%r11d
	jg	.x_check
	jmp	.loop	


.x_check:

	subl	%r9d,	%esi	#yp-yi
	subl	%r9d,	%r11d	#yp-y{i+1}
	movl	%r10d,	%eax	# moved x{i+1} to rax
	subl	%r8d,	%eax	# subtract xi
	mul	%esi
	divl	%r11d
	addl	%r8d,	%eax
	cmpl	%edi,	%eax
	jge	.add

	jmp	.loop

.add:
	incq	%r12
	jmp	.loop

.epilogue:
	andq	$1,	%r12
	movq	%r12,	%rax
	popq	%r12
	movq	%rbp,	%rsp
	popq	%rbp
	ret	




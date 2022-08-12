; Ramenen I/O 
;		If you worked on this file, add yourself
;		to the CREDITS file in the root.

GLOBAL os_wait_for_key

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
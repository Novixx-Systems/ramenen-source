; ==================================================================
; Ramenen
; Copyright (C) 2022 Ramenen Developers
;
; "MOUSE" DRIVER
; It's actually the arrow key driver (;
;
;
;
;		If you worked on this file, add yourself
;		to the CREDITS file in the root.
;
;
; ==================================================================

EXTERN os_wait_for_key
EXTERN os_string_to_int

GLOBAL mouselib_range
GLOBAL mouselib_freemove
GLOBAL mouselib_locate
GLOBAL mouselib_scale
GLOBAL mouselib_int_cursor_x
GLOBAL mouselib_int_cursor_y

; -----------------------------------------------------
; mouselib_install_driver --- setup the mouse driver
; NOTE: don't use, it just RETurns
; IN/OUT: none

mouselib_install_driver:
	ret

;------------------------------------------------------
; mouselib_locate -- return the mouse coordinenats
; IN: none
; OUT: CX = Mouse X, DX = Mouse Y
	
mouselib_locate:
	; Move the scale mouse positions into the registers
	mov cx, [mouselib_int_x_position]
	mov dx, [mouselib_int_y_position]
	
	ret

	
; --------------------------------------------------
; mouselib_move -- set the mouse co-ordinents
; IN: CX = Mouse X, DX = Mouse Y
; OUT: none

mouselib_move:
	pusha
	
	; Set the scale mouse position
	mov ax, cx
	mov [mouselib_int_x_position], ax
	mov [mouselib_int_y_position], dx
	
	; To move the mouse we must set the raw position
	; If we don't the next mouse update will simple overwrite our scale position
	; So shift the mouse position by the scale factor
	mov cl, [mouselib_int_x_scale]
	shl ax, cl
	mov [mouselib_int_x_raw], ax
	
	mov cl, [mouselib_int_y_scale]
	shl dx, cl
	mov [mouselib_int_y_raw], dx
	
	popa
	ret


; --------------------------------------------------
; mouselib_show -- shows the cursor at current position
; IN: none
; OUT: none

mouselib_show:
	; THIS DOES NOT WORK IN GRAPHICS MODE!
	push ax
	
	; Basically show and hide just invert the current character
	; We use mouselib_int_cursor_x so that we can remember where we put the cursor
	; just in case it changes before we can hide it
	;
	cmp byte [mouselib_int_cursor_on], 1
	je .already_on
	
	mov ax, [mouselib_int_x_position]
	mov [mouselib_int_cursor_x], ax
	
	mov ax, [mouselib_int_y_position]
	mov [mouselib_int_cursor_y], ax
	
	call mouselib_int_toggle
	
	mov byte [mouselib_int_cursor_on], 1
	
	pop ax
	
.already_on:
	ret
	

; --------------------------------------------------
; mouselib_hide -- hides the cursor
; IN: none
; OUT: none
	
mouselib_hide:
	cmp byte [mouselib_int_cursor_on], 0
	je .already_off
	
	call mouselib_int_toggle
	
	mov byte [mouselib_int_cursor_on], 0
	
.already_off:
	ret
	

mouselib_int_toggle:
	pusha
	
	; Move the cursor into mouse position
	mov ah, 02h
	mov bh, 0
	mov dh, [mouselib_int_cursor_y]
	mov dl, [mouselib_int_cursor_x]
	int 10h
	
	; Find the color of the character
	mov ah, 08h
	mov bh, 0
	int 10h
	
	; Invert it to get its opposite
	not ah
	
	; Display new character
	mov bl, ah
	mov ah, 09h
	mov bh, 0
	mov cx, 1
	int 10h
	
	popa
	ret

; --------------------------------------------------
; mouselib_range -- sets the range maximum and 
;	minimum positions for mouse movement
; IN: AX = min X, BX = min Y, CX = max X, DX = max Y
; OUT: none

mouselib_range:
	; Just activate the range registers, the driver will handle the rest
	mov [mouselib_int_x_minimum], ax
	mov [mouselib_int_y_minimum], bx
	mov [mouselib_int_x_limit], cx
	mov [mouselib_int_y_limit], dx
	
	ret
	
; --------------------------------------------------
; mouselib_anyclick -- check if any mouse button is pressed
; IN: none
; OUT: none

mouselib_anyclick:
	cmp byte [mouselib_int_button_left], 1
	je .click
	
	cmp byte [mouselib_int_button_middle], 1
	je .click
	
	cmp byte [mouselib_int_button_right], 1
	je .click
	
	clc
	ret
	
.click:
	mov byte [mouselib_int_button_left], 0
	mov byte [mouselib_int_button_right], 0
	mov byte [mouselib_int_button_middle], 0
	stc
	ret
	

mouselib_gainclick:
	cmp byte [mouselib_int_button_left], 1
	je .click
	
	cmp byte [mouselib_int_button_middle], 1
	je .click3
	
	cmp byte [mouselib_int_button_right], 1
	je .click2
	
	jmp mouselib_anyclick

	
.click:
	mov byte [mouselib_int_button_left], 0
	mov byte [mouselib_int_button_right], 0
	mov byte [mouselib_int_button_middle], 0
	mov cx, 1
	ret
.click2:
	mov byte [mouselib_int_button_left], 0
	mov byte [mouselib_int_button_right], 0
	mov byte [mouselib_int_button_middle], 0
	mov cx, 2
	ret
.click3:
	mov byte [mouselib_int_button_left], 0
	mov byte [mouselib_int_button_right], 0
	mov byte [mouselib_int_button_middle], 0
	mov cx, 3
	ret
	

; --------------------------------------------------
; mouselib_leftclick -- checks if the left mouse button is pressed
; IN: none
; OUT: CF = set if pressed, otherwise clear

mouselib_leftclick:
	cmp byte [mouselib_int_button_left], 1
	je .pressed
	
	clc
	ret
	
.pressed:
	stc
	ret


; --------------------------------------------------
; mouselib_middleclick -- checks if the middle mouse button is pressed
; IN: none
; OUT: CF = set if pressed, otherwise clear

mouselib_middleclick:
	cmp byte [mouselib_int_button_middle], 1
	je .pressed
	
	clc
	ret
	
.pressed:
	stc
	ret
	
	
; --------------------------------------------------
; mouselib_rightclick -- checks if the right mouse button is pressed
; IN: none
; OUT: CF = set if pressed, otherwise clear

mouselib_rightclick:
	cmp byte [mouselib_int_button_right], 1
	je .pressed
	
	clc
	ret
	
.pressed:
	stc
	ret
	
	
; ------------------------------------------------------------------
; mouselib_input_wait -- waits for mouse or keyboard input
; IN: none
; OUT: CF = set if keyboard, clear if mouse

mouselib_input_wait:
	push ax
	
	; Clear the mouse update flag so we can tell when the driver had updated it
	mov byte [mouselib_int_changed], 0
	
.input_wait:
	; Check with BIOS if there is a keyboard key available - but don't collect the key
	mov ah, 11h
	int 16h
	jnz .keyboard_input
	
	
	; Check if the mouse driver had recieved anything
	cmp byte [mouselib_int_changed], 1
	je .mouselib_int_input
	
	hlt
	
	jmp .input_wait
	
.keyboard_input:
	pop ax
	stc
	ret
	
.mouselib_int_input:
	pop ax
	clc
	ret
	
	
; ------------------------------------------------------------------
; mouselib_scale -- scale mouse movment speed as 1:2^X
; IN: DL = mouse X scale, DH = mouse Y scale

mouselib_scale:
	; Set the scale factor and let the driver handle the rest
	mov [mouselib_int_x_scale], dl
	mov [mouselib_int_y_scale], dh
	ret

	
; ------------------------------------------------------------------
; mouselib_remove_driver --- restores the original mouse handler
; IN: nothing
; OUT: nothing

mouselib_remove_driver:
	ret
	
; ------------------------------------------------------------------
; mouselib_freemove --- allows the user to move the mouse around the screen
;                       stops when a mouse click or keyboard event occurs
; IN: none
; OUT:  AX = key pressed or zero if mouse click
;	CX = mouse x, DX = mouse y, CF = set if key press, clear if mouse click

mouselib_freemove:
    call os_wait_for_key
	call mouselib_hide

    cmp ah, 48h  ;Up Arrow key 
    je .up

    cmp ah, 50h  ;Down Arrow key 
    je .down

    cmp ah, 4Dh  ;Right Arrow key 
    je .right

    cmp ah, 4Bh  ;Left Arrow key 
    je .left
	
	cmp al, 13
	je .enter
	
    jmp .emn
.enter:
	mov byte [mouselib_int_button_left], 1
	clc
	ret

.up:
    dec word [mouselib_int_y_position]

    jmp .emn

.down:
    inc word [mouselib_int_y_position]

    jmp .emn

.right:
    inc word [mouselib_int_x_position]

    jmp .emn

.left:
    dec word [mouselib_int_x_position]

    jmp .emn
.emn:
	call mouselib_show
	stc
	ret
	

; All the data needed by the mouse driver and API
mouselib_int_data				db 0
mouselib_int_delta_x				db 0
mouselib_int_delta_y				db 0
mouselib_int_x_raw				dw 0
mouselib_int_y_raw				dw 0
mouselib_int_x_scale				db 0
mouselib_int_y_scale				db 0
mouselib_int_x_position				dw 0
mouselib_int_y_position				dw 0
mouselib_int_x_minimum				dw 0
mouselib_int_x_limit				dw 0
mouselib_int_y_minimum				dw 0
mouselib_int_y_limit				dw 0
mouselib_int_button_left			db 0
mouselib_int_button_middle			db 0
mouselib_int_button_right			db 0
mouselib_int_cursor_on				db 0
mouselib_int_cursor_x				dw 0
mouselib_int_cursor_y				dw 0
mouselib_int_changed				db 0
mouselib_int_originalhandler			dw 0
mouselib_int_originalseg			dw 0

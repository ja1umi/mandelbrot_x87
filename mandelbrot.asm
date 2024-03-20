[cpu 386]
stack	equ	0x7fff

[org 0x7c00]

		jmp	_start

;	module asciiart;
; var
ui16_ic	dw	0					; text color
ui16_i	dw	0
i16_x		dw	0
i16_y		dw	0
f_a			dd	0.0
f_b			dd	0.0
f_ca		dd	0.0
f_cb		dd	0.0
f_t			dd	0.0

f2F0			dd	2.0
f4F0			dd	4.0
f0F0458		dd	0.0458
f0F08333	dd	0.08333

colortbl:
		db	8, 1, 9, 2, 10, 3, 11, 4, 12, 5, 13, 6, 14, 7, 15, 15

_start:
		xor	ax, ax
		mov	ds, ax
		mov	ss, ax
		mov	sp, stack
		call	cls
		finit

;	for y:=-12 to 12 do
		mov	word [i16_y], -12
for_y:
		mov ax, word [i16_y]
		cmp	ax, 0
		jle	.skip
		cmp	ax, 12
		jbe	.skip
		jmp	exit_for_y
.skip:
;	for x:=-39 to 39 do
		mov	word [i16_x], -39
for_x:
		mov	ax, word [i16_x]
		cmp	ax, 0
		jle	.skip
		cmp	ax, 39
		jbe	.skip
		jmp	exit_for_x
.skip:
;		ca :=float(x) * 0.0458;
;		a := ca;
		fild	word [i16_x]
		fmul	dword [f0F0458]
		fst		dword [f_ca]
		fstp	dword [f_a]
;		cb := float(y) * 0.08333;
;		b := cb;
		fild	word [i16_y]
		fmul	dword [f0F08333]
		fst		dword [f_cb]
		fstp	dword [f_b]
;		i := 0;
		xor	ax, ax
		mov	word [ui16_i], ax
;		while i < 16 do
while_i:
		mov	ax, word [ui16_i]
		cmp	ax, 16
		jae	exit_while_i
;			t := a*a - b*b + ca;
		fld	dword [f_a]
		fmul	st0, st0
		fld	dword [f_b]
		fmul	st0, st0
		fsub
;		fld	dword [f_ca]
;		fadd
		fadd	dword [f_ca]
		fstp	dword [f_t]
;			b := 2.0*a*b + cb;
		fld	dword [f2F0]
		fmul	dword [f_a]
		fmul	dword [f_b]
		fadd	dword [f_cb]
		fstp	dword [f_b]
;			a := t;
		fld	dword [f_t]
		fstp	dword [f_a]
;			if (a*a + b*b) > 4 then
		fld	dword [f_a]
		fmul	st0, st0
		fld	dword [f_b]
		fmul	st0, st0
		fadd
		fcomp	dword [f4F0]
		fstsw	ax
		;					    C     CCC
		;					    3     210
		and		ax, 0b0_1_000_111_00000000	; take only condition code flags
		cmp		ax, 0b0_0_000_001_00000000	; bit 8 (C0) --> Carry flag
		jz	end_if_aa
		cmp		ax, 0b0_1_000_000_00000000	; bit 14 (C3) --> Zero flag
		jz	end_if_aa
;				setColor(i);
		mov	ax, [ui16_i]
		lea	bx, colortbl
		mov	ax, word [ui16_i]
		xlat
		mov	[ui16_ic], ax
;				if i > 9 then
		mov	ax, word [ui16_i]
		cmp	ax, 9
		jle	end_if_ile9
;					i := i + 7;
		add	word [ui16_i], 7
;				end;
end_if_ile9:
;				temp := chr(ord('0')+i);
;				write(temp);
		mov	ax, word [ui16_i]
		add	ax, '0'
		mov	bx, word [ui16_ic]	; set text color
		call	putch
;				i := 99;
		mov	word [ui16_i], 99
;			end;
end_if_aa:
;			i := i + 1;
		inc	word [ui16_i]
;		end;
		jmp	while_i
exit_while_i:
;		if i = 16 then
		mov	ax, word [ui16_i]
		cmp	ax, 16
		jne	exit_if_ieq16
;		write(' ');
		mov	ax, ' '
		call	putch
exit_if_ieq16:
;	end
		inc	word [i16_x]
		jmp	for_x
exit_for_x:
		call	crlf
;	end
		inc	word [i16_y]
		jmp	for_y
exit_for_y:
		jmp	exit_for_y
; end asciiart

putch:								; al = ASCII character to write
		mov	ah, 0xe
;		mov	bx, 15				; text color
		int	10h
		retn

crlf:
		mov	ax, 0x0d
		call	putch
		mov	ax, 0x0a
		call	putch
		retn

cls:									; clear screen
		mov	ax, 0xb800
		mov	es, ax
		mov	cx, 80 * 25
		mov	ah, 15
		mov	al, ' '
		xor	di, di
rep	stosw
		retn

times 510-($-$$) db 0
    dw 0xAA55
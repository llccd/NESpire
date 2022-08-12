#include "nes.inc"

nes_rom_file_mask:
	.string	"*.nes.tns"
title:
	.string	" NESpire v0.30 -- Shift=start, Esc=quit"
	.align	4

.globl rom_menu
rom_menu:
	push	{r4-r11, lr}

	ldr	r0, [r9, #s_path_filename]
	adr	r1, nes_rom_file_mask
	swi	e_strcpy

#define liststart r4
#define listend   r5
#define listmax   r8
	@ Using save ram as a buffer to hold list of filenames
	add	liststart, r9, #s_sram
	mov	listend, liststart
	add	listmax, liststart, #0x2000

	sub	sp, #308
	mov	r0, sp
	add	r1, r9, #s_path
	swi	e_NU_Get_First
	movs	r0, r0
	bne	no_files
next_file:
	@ Append filename to list
	mov	r0, listend
	add	r1, sp, #13
1:	teq	r0, listmax
	beq	filename_buf_full
	ldrb	r2, [r1], #1
	movs	r2, r2
	strb	r2, [r0], #1
	bne	1b
	mov	listend, r0

	mov	r0, sp
	swi	e_NU_Get_Next
	movs	r0, r0
	beq	next_file
filename_buf_full:
	mov	r0, sp
	swi	e_NU_Done
no_files:
	add	sp, #308

#define cursor r6
#define pagetop r7
#define pagebottom r8
#define keypressed r10
#define keyrepeat r11
	mov	cursor, liststart
	mov	pagetop, liststart
	mov	keypressed, #0
	mov	keyrepeat, #0

menu_redraw:
	adr	r0, title
	mov	r1, #0
	mov	r2, #40
	mov	r3, #-1
	bl	display_string

	mov	pagebottom, pagetop
	str	r10, [sp, #-4]!
	mov	r10, #640
menu_next_row:
	teq	pagebottom, cursor
	moveq	r0, #0x10
	movne	r0, #' '
	mov	r1, r10
	bl	display_char
	cmp	pagebottom, listend
	bcs	menu_draw_done
	mov	r0, pagebottom
	add	r1, r10, #1
	add	r2, r10, #40
	mov	r3, #0
	bl	display_string
1:	ldrb	r0, [pagebottom], #1
	movs	r0, r0
	bne	1b
	add	r10, #640
	teq	r10, #640 * 15
	bne	menu_next_row
menu_draw_done:
	ldr	r10, [sp], #4

menu_waitkey:
	mov	r0, #0
	mcr	p15, 0, r0, c7, c0, 4
	mov	lr, pc
	ldr	pc, [r9, #s_keypad_read_input]

	mov	r1, keypressed
	mov	keypressed, r0

	teq	r0, r1
	movne	keyrepeat, #25
	bne	1f
	movs	keyrepeat, keyrepeat
	subnes	keyrepeat, #1
	bne	menu_waitkey
	mov	keyrepeat, #5
1:

	tst	r0, #0x01
	bne	exit_emulator
	tst	r0, #0x10
	bne	menu_up
	tst	r0, #0x20
	bne	menu_down
	tst	r0, #0x08
	bne	menu_start
	b	menu_waitkey

menu_up:
	teq	cursor, liststart
	beq	menu_waitkey
1:	sub	cursor, #1
	teq	cursor, liststart
	ldrneb	r0, [cursor, #-1]
	movnes	r0, r0
	bne	1b
	cmp	cursor, pagetop
	movcc	pagetop, cursor
	b	menu_redraw

menu_down:
	mov	r0, cursor
1:	ldrb	r1, [r0], #1
	movs	r1, r1
	bne	1b
	cmp	r0, listend
	bcs	menu_waitkey
	mov	cursor, r0
	cmp	cursor, pagebottom
	bcc	menu_redraw
1:	ldrb	r0, [pagetop], #1
	movs	r0, r0
	bne	1b
	b	menu_redraw

menu_start:
	@ Append filename to directory
	ldr	r0, [r9, #s_path_filename]
	mov	r1, cursor
1:	ldrb	r2, [r1], #1
	movs	r2, r2
	strb	r2, [r0], #1
	bne	1b
	sub	r0, #8
	str	r0, [r9, #s_path_extension]

	@ Try to load ROM (full path)
	add	r0, r9, #s_path
	bl	load_rom
	movs	r0, r0
	beq	load_success

	@ Display error message
	mov	r1, #7
	mov	r2, #40
	mov	r3, #-1
	bl	display_string
	adr	r0, error_hdr
	mov	r1, #0
	mov	r2, #7
	mov	r3, #-1
	bl	display_string
	b	menu_waitkey
error_hdr:
	.string	"ERROR:"
	.align	4

load_success:
	@ Clear save ram (since we used it to hold filenames)
	add	r0, r9, #s_sram
	mov	r1, #0
	mov	r2, #0x2000
	swi	e_memset

	@ If game has battery-backed save ram, try to load from save file
	bl	sram_load

	pop	{r4-r11, pc}

@ r0 = character
@ r1 = position (row * 640 + column)
display_char:
	mov	r2, #0
@ r2 = color (0 = normal, -1 = reverse)
display_char_withcolor:
	push	{r4, lr}
	mov	r12, #0xC0000000
	ldr	r12, [r12, #0x10]
	adr	r4, font
	add	r4, r0, lsl #4
	mov	r3, #0x10
	ldr	r0, [r9, #s_hw_color]
	movs	r0, r0
	bne	display_char_16bpp
display_char_4bpp:
	add	r12, r1, lsl #2
2:	ldrb	r1, [r4], #1
	mvn	r0, r2
1:	ror	r0, #24
	lsrs	r1, #1
	eorcs	r0, #0x0F
	lsrs	r1, #1
	eorcs	r0, #0xF0
	adds	r3, #0x40000000
	bcc	1b
	str	r0, [r12], #160
	subs	r3, #1
	bne	2b
	pop	{r4, pc}
display_char_16bpp:
	add	r12, r1, lsl #4
2:	ldrb	r1, [r4], #1
	lsl	r1, #24
1:	mvn	r0, #0
	lsls	r1, #1
	andcs	r0, r0, lsl #16
	lsls	r1, #1
	andcs	r0, r0, lsr #16
	eor	r0, r2
	str	r0, [r12], #4
	adds	r3, #0x40000000
	bcc	1b
	add	r12, #640 - 16
	subs	r3, #1
	bne	2b
	pop	{r4, pc}
@ r0 = string
@ r1 = start position
@ r2 = end position
@ r3 = color (0 = normal, -1 = reverse)
.globl	display_string
display_string:
	push	{r4-r7, lr}
	mov	r4, r0
	mov	r5, r1
	mov	r6, r2
	mov	r7, r3

1:	ldrb	r0, [r4]
	movs	r0, r0
	addne	r4, #1
	mov	r1, r5
	add	r5, #1
	mov	r2, r7
	bl	display_char_withcolor
	cmp	r5, r6
	bcc	1b
	pop	{r4-r7, pc}
font:
	.incbin	"font.bin"

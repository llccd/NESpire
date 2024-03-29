#include "nes.inc"

.globl main
main:
	push	{r4-r11, lr}
	@ Allocate the state data structure from the stack and zero it out
	mov	r5, sp
	sub	sp, sp, #s_SIZE
	bic	sp, sp, #s_ALIGN - 1
	mov	r9, sp
	mov	r4, #0
	mov	r6, #s_SIZE
1:	subs	r6, r6, #4
	str	r4, [r9, r6]
	bne	1b
	str	r5, [r9, #s_saved_sp]

	@ Get our folder path
	add	r4, r9, #s_path
	mov	r2, r4
	subs	r5, r0, #1		@ argc - 1
	ldrpl	r1, [r1, r5, lsl #2]	@ argv[argc - 1]
	movpls	r1, r1
	ble	2f
1:	ldrb	r0, [r1], #1
	strb	r0, [r4], #1
	teq	r0, #'\'
	teqne	r0, #'/'
	moveq	r2, r4
	movs	r0, r0
	bne	1b
2:	str	r2, [r9, #s_path_filename]

	@ Check hardware type
	ldr	r0, =0x900A0000
	ldr	r0, [r0]
	bic	r0, #0xFF000000
	cmp	r0, #0x10
	bne	1f
	@ Non-CX
	mov	r0, #0xDC000000
	add	r0, #0x08
	adr	r1, interrupt_handler_noncx
	mvn	r2, #0
	mov	r3, #0
	mov	r4, #3
	b	2f
1:
	sub	r0, #0x100
	cmp	r0, #0x001
	beq	cx
	sub	r0, #0x100
	cmp	r0, #0x002 @ CX II
	bne	unknown_hardware
cx:
	@ CX
	mov	r0, #0xDC000000
	add	r0, #0x10
	adr	r1, interrupt_handler_cx
	mov	r2, #0
	mov	r3, #1
	mov	r4, #1
2:
	str	r0, [r9, #s_hw_irq_masks]
	str	r1, [r9, #s_hw_irq_handler]
	str	r2, [r9, #s_hw_keypad_invert]
	str	r3, [r9, #s_hw_color]
	str	r4, [r9, #s_frameskip]

	bl	init_interrupts
	bl	init_keypad
	bl	toggle_border
	bl	rom_menu
	bl	clear_screen

	@ Set CPU to power-on state
	mov	cpu_a, #0
	mov	cpu_x, #0
	mov	cpu_y, #0
	mov	cpu_sp, #0x100          @ RESET will bring this to 0x1FD
	mov	cpu_flags, #0

	@ Start CPU emulation
	b	reset

.globl	exit_emulator
exit_emulator:
	ldr	r0, [r9, #s_prg_ptr]
	swi	e_free
	ldr	r0, save_state_ptr
	swi	e_free
	bl	restore_interrupts
unknown_hardware:
	ldr	sp, [r9, #s_saved_sp]
	pop	{r4-r11, pc}

init_interrupts:
	str	r9, [pc, #state_ptr - (.+8)]

	msr	cpsr_c, #0xD3           @ Interrupts off

	@ Disable everything except the timer interrupt (IRQ 19)
	ldr	r0, [r9, #s_hw_irq_masks]
	ldr	r2, [r0]
	str	r2, [r9, #s_saved_irq_mask]
	str	r2, [r0, #4]
	mov	r2, #1 << 19
	str	r2, [r0]

	@ Set the IRQ vector 
	mov	r1, #0xA4000000
	ldr	r2, [r1, #0x38]
	str	r2, [r9, #s_saved_irq_handler]
	ldr	r2, [r9, #s_hw_irq_handler]
	str	r2, [r1, #0x38]

	msr	cpsr_c, #0x13           @ Interrupts on
	bx	lr

interrupt_handler_cx:
	push	{r0-r1, lr}
	ldr	r0, =0x900D0000
	mov	r1, #1
	str	r1, [r0, #0x0C]
	b	interrupt_handler_common
interrupt_handler_noncx:
	push	{r0-r1, lr}
	mov	r0, #0xDC000000
	ldr	r1, =0x900A0000
	ldr	lr, [r0, #0x24]
	ldr	lr, [r0, #0x28]
	mov	lr, #1
	str	lr, [r1, #0x20]
	mov	lr, #1 << 19
	str	lr, [r0, #0x04]
	mov	lr, #8
	str	lr, [r0, #0x2C]
interrupt_handler_common:
	@ Advance the frame timer by 3/300 of a second
	ldr	r1, [pc, #state_ptr - (.+8)]
	ldrb	lr, [r1, #s_frame_timer]
	add	lr, lr, #3
	strb	lr, [r1, #s_frame_timer]
	pop	{r0-r1, lr}
	subs	pc, lr, #4
	.pool
state_ptr:
	.word	0

restore_interrupts:
	msr	cpsr_c, #0xD3           @ Interrupts off

	ldr	r0, [r9, #s_hw_irq_masks]
	mvn	r2, #0
	str	r2, [r0, #4]
	ldr	r2, [r9, #s_saved_irq_mask]
	str	r2, [r0]

	mov	r1, #0xA4000000
	ldr	r2, [r9, #s_saved_irq_handler]
	str	r2, [r1, #0x38]
	bx	lr

save_state:
	ldr	r7, save_state_ptr
	cmp	r7, #0
	bne	1f
	mov	r0, #0x4400
	mov	r6, lr
	ldrb	r1, [r9, #s_rom_header + 5]
	movs	r1, r1
	addeq	r0, r0, #0x2000
	swi	e_malloc
	mov	lr, r6
	movs	r7, r0
	bxeq	lr
	str	r7, save_state_ptr

1:	mov	r6, #0x4400
	mov	r10, r9
sstate_loop:
	ldm	r10!, {r0-r3}
	stm	r7!, {r0-r3}
	subs	r6, r6, #16
	bne	sstate_loop
	ldrb	r1, [r9, #s_rom_header + 5]
	movs	r1, r1
	bne	1f
	mov	r6, #0x2000
	ldr	r10, [r9, #s_chr_ptr]
sstate_loop2:
	ldm	r10!, {r0-r3}
	stm	r7!, {r0-r3}
	subs	r6, r6, #16
	bne	sstate_loop2

1:	adr	r11, saved_state_cpu_status
	ldm	sp, {r0-r3, r6-r7, r10}
	stm	r11, {r0-r3, r6-r7, r10}
	bx	lr

load_state:
	ldr	r7, save_state_ptr
	cmp	r7, #0
	bxeq	lr
	mov	r6, #0x4400
	mov	r10, r9
lstate_loop:
	ldm	r7!, {r0-r3}
	stm	r10!, {r0-r3}
	subs	r6, r6, #16
	bne	lstate_loop
	ldrb	r1, [r9, #s_rom_header + 5]
	movs	r1, r1
	bne	1f
	mov	r6, #0x2000
	ldr	r10, [r9, #s_chr_ptr]
lstate_loop2:
	ldm	r7!, {r0-r3}
	stm	r10!, {r0-r3}
	subs	r6, r6, #16
	bne	lstate_loop2

1:	adr	r11, saved_state_cpu_status
	ldm	r11, {r0-r3, r6-r7, r10}
	stm	sp, {r0-r3, r6-r7, r10}
	bx	lr

save_state_ptr: .word 0

saved_state_cpu_status:
	.rept 7
	.word 0
	.endr

.globl newframe
newframe:
	str	lr, [sp, #-4]!

	ldrb	r0, [r9, #s_message_timer]
	subs	r0, #1
	strplb	r0, [r9, #s_message_timer]

	ldr	r0, [r9, #s_frameskip_cur]
	ldr	r10, [r9, #s_frameskip]
	subs	r0, r0, #1
	addmi	r0, r0, r10
	str	r0, [r9, #s_frameskip_cur]

	mov	r8, #0
pause_loop:

#define num_command_keys 10
	@ Scan keypad
	ldr	r3, [r9, #s_hw_keypad_invert]
	mov	r4, #0
	ldr	r5, =0x900E0010
	mov	r6, #num_command_keys - 1
	ldr	r7, [r9, #s_keypad_command_map]
1:	ldrb	r0, [r7, r6]
	and	r1, r0, #0x60
	ldr	r1, [r5, r1, lsr #3]
	eor	r1, r3, r1, ror r0
	and	r1, #1
	orr	r4, r1, lsl r6
	subs	r6, #1
	bpl	1b

	ldr	r5, [r9, #s_command_keys_pressed]
	str	r4, [r9, #s_command_keys_pressed]
	bic	r5, r4, r5

	tst	r5, #1 << 0;	blne	frameskip_inc
	tst	r5, #1 << 1;	blne	frameskip_dec
	tst	r5, #1 << 2;	blne	save_state
	tst	r5, #1 << 3;	blne	load_state
	tst	r5, #1 << 4;	blne	toggle_border   @ B (Border)
	tst	r5, #1 << 5;	mvnne	r8, r8          @ P (Pause)
	tst	r4, #1 << 6;	bne	exit_emulator   @ Q (Quit)
	tst	r5, #1 << 7;	blne	invert_colors   @ R (Reverse)
	tst	r5, #1 << 8;	blne	sram_save       @ S (Save SRAM)
	tst	r4, #1 << 9;	bne	fast_forward    @ *

	@ Keep looping until the frame timer reaches 5/300 (1/60) of a second
	ldrb	r0, [r9, #s_frame_timer]
	subs	r0, r0, #5
	movcc	r0, #0
	mcrcc	p15, 0, r0, c7, c0, 4
	bcc	pause_loop
	strb	r0, [r9, #s_frame_timer]
#ifdef DEBUG
	bl	fps_counter
#endif
	movs	r8, r8
	bne	pause_loop
fast_forward:
	mov	lr, pc
	ldr	pc, [r9, #s_keypad_read_input]
	str	r0, [r9, #s_input_status]

	ldr	pc, [sp], #4

init_keypad:
	push	{lr}
	swi	e_keypad_type
	ldrh	r0, [r0]
	cmp	r0, #4
	beq	init_keypad_tpad
	cmp	r0, #3
	beq	init_keypad_tpad
init_keypad_clickpad:
	adr	r1, clickpad_command_map
	adr	r2, clickpad_read_input
	b	init_keypad_save
init_keypad_tpad:
	mov	r0, #0xFF
	mov	r1, #0xFF
	adr	r2, touchpad_info_page
	swi	e_touchpad_write
	mov	r0, #0x04
	mov	r1, #0x07
	add	r2, r9, #s_touchpad_size
	swi	e_touchpad_read
	mov	r0, #0xFF
	mov	r1, #0xFF
	adr	r2, touchpad_main_page
	swi	e_touchpad_write

	adr	r1, touchpad_command_map
	adr	r2, touchpad_read_input
init_keypad_save:
	str	r1, [r9, #s_keypad_command_map]
	str	r2, [r9, #s_keypad_read_input]
	pop	{pc}

touchpad_info_page:
	.byte	0x10
touchpad_main_page:
	.byte	0x04

	@       +    -    7    9    B    P    Q    R    S    *
clickpad_command_map:
	.byte	0x11,0x21,0x37,0x33,0x64,0x28,0x26,0x24,0x22,0x31
touchpad_command_map:
	.byte	0x62,0x52,0x37,0x33,0x45,0x22,0x21,0x20,0x16,0x48

	.align	4

clickpad_read_input:
	mov	r2, #0
	ldr	r0, =0x900E0000
	ldr	r3, [r9, #s_hw_keypad_invert]
	ldr	r1, [r0, #0x14]
	eor	r1, r3
	tst	r1, #1 << 25;	orrne	r2, r2, #0x10000	@ x^2 (2P A)
	tst	r1, #1 << 9;	orrne	r2, r2, #0x20000	@ 10^x (2P B)
	tst	r1, #1 << 21;	orrne	r2, r2, #0x100000	@ 8 (2P Up)
	tst	r1, #1 << 5;	orrne	r2, r2, #0x200000	@ 5 (2P Down)
	tst	r1, #1 << 7;	orrne	r2, r2, #0x400000	@ 4 (2P Left)
	tst	r1, #1 << 3;	orrne	r2, r2, #0x800000	@ 6 (2P Right)

	ldrd	r0, [r0, #0x18]
	eor	r0, r3
	eor	r1, r3
	tst	r0, #1 << 25;	orrne	r2, r2, #0x08	@ Caps (Start)
	tst	r1, #1 << 7;	orrne	r2, r2, #0x01	@ Esc (A)
	tst	r1, #1 << 9;	orrne	r2, r2, #0x02	@ Tab (B)
	tst	r1, #1 << 16;	orrne	r2, r2, #0x10	@ Up
	tst	r1, #1 << 18;	orrne	r2, r2, #0x80	@ Right
	tst	r1, #1 << 20;	orrne	r2, r2, #0x20	@ Down
	tst	r1, #1 << 22;	orrne	r2, r2, #0x40	@ Left
	tst	r1, #1 << 24;	orrne	r2, r2, #0x04	@ Clear (Select)
	tst	r0, #1 << 23;	orrne	r2, r2, #0x40000	@ Var (2P Select)
	tst	r1, #1 << 25;	orrne	r2, r2, #0x80000	@ Ctrl (2P Start)
	tst	r1, #1 << 5;	orrne	r2, r2, #0x100	@ Menu (2P Microphone)

	mov	r0, r2
	bx	lr

touchpad_read_input:
	push	{r4, lr}
	mov	r4, #0

	ldr	r0, =0x900E0000
	ldr	r2, [r9, #s_hw_keypad_invert]
	ldr	r1, [r0, #0x14]
	eor	r1, r2
	tst	r1, #1 << 7;	orrne	r4, r4, #0x400000	@ 4 (2P Left)
	tst	r1, #1 << 3;	orrne	r4, r4, #0x800000	@ 6 (2P Right)

	ldrd	r0, [r0, #0x18]
	eor	r0, r2
	eor	r1, r2
	tst	r1, #1 << 7;	orrne	r4, r4, #0x01	@ Esc (A)
	tst	r1, #1 << 9;	orrne	r4, r4, #0x02	@ Tab (B)
	tst	r0, #1 << 25;	orrne	r4, r4, #0x04	@ Clear (Select)
	tst	r1, #1 << 24;	orrne	r4, r4, #0x08	@ Caps (Start)
	tst	r0, #1 << 7;	orrne	r4, r4, #0x10000	@ = (2P A)
	tst	r0, #1 << 9;	orrne	r4, r4, #0x20000	@ ^ (2P B)
	tst	r0, #1 << 17;	orrne	r4, r4, #0x40000	@ Var (2P Select)
	tst	r1, #1 << 25;	orrne	r4, r4, #0x80000	@ Ctrl (2P Start)
	tst	r1, #1 << 6;	orrne	r4, r4, #0x100000	@ 8 (2P Up)
	tst	r0, #1 << 22;	orrne	r4, r4, #0x200000	@ 5 (2P Down)
	tst	r1, #1 << 5;	orrne	r4, r4, #0x100	@ Menu (2P Microphone)

	sub	sp, #0x0C
	mov	r0, #0x02
	mov	r1, #0x0A
	add	r2, sp, #0x02
	swi	e_touchpad_read
	movs	r0, r0
	beq	1f
	ldrb	r0, [sp, #0x0A]
	tst	r0, #0x01
	beq	1f

	ldrb	r0, [sp, #0x02]
	ldrb	r1, [sp, #0x03]
	ldrb	r2, [r9, #s_touchpad_size]
	ldrb	r3, [r9, #s_touchpad_size+1]
	orr	r0, r1, r0, lsl #8
	orr	r2, r3, r2, lsl #8
	add	r0, r0, lsl #1
	cmp	r0, r2;         orrcc	r4, r4, #0x40	@ Left
	cmp	r0, r2, lsl #1; orrcs	r4, r4, #0x80	@ Right

	ldrb	r0, [sp, #0x04]
	ldrb	r1, [sp, #0x05]
	ldrb	r2, [r9, #s_touchpad_size+2]
	ldrb	r3, [r9, #s_touchpad_size+3]
	orr	r0, r1, r0, lsl #8
	orr	r2, r3, r2, lsl #8
	add	r0, r0, lsl #1
	cmp	r0, r2;         orrcc	r4, r4, #0x20	@ Down
	cmp	r0, r2, lsl #1; orrcs	r4, r4, #0x10	@ Up
1:
	add	sp, #0x0C

	mov	r0, r4
	pop	{r4, pc}

frameskip_inc:
	add	r10, #1
	cmp	r10, #7
	subeq r10, #1
	str	r10, [r9, #s_frameskip]
	bx lr

frameskip_dec:
	subs	r10, #1
	addeq r10, #1
	str	r10, [r9, #s_frameskip]
	bx lr

	.pool

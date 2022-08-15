#include "nes.inc"

map_prg_32kB:
	ldr	r1, [r9, #s_prg_size]
	ldr	r2, [r9, #s_prg_ptr]
	and	r0, r1, r0, lsl #15
	add	r0, r0, r2
map_prg_32kB_from_pointer:
	sub	r0, r0, #0x8000
	str	r0, [r9, #s_mem_map + 16]    @ 8000
	str	r0, [r9, #s_mem_map + 20]    @ A000
	str	r0, [r9, #s_mem_map + 24]    @ C000
	str	r0, [r9, #s_mem_map + 28]    @ E000
	bx	lr
map_prg_16kB_to_8000:
	ldr	r1, [r9, #s_prg_size]
	ldr	r2, [r9, #s_prg_ptr]
	and	r0, r1, r0, lsl #14
	add	r0, r0, r2
	sub	r0, r0, #0x8000
	str	r0, [r9, #s_mem_map + 16]    @ 8000
	str	r0, [r9, #s_mem_map + 20]    @ A000
	bx	lr
map_prg_16kB_to_C000:
	ldr	r1, [r9, #s_prg_size]
	ldr	r2, [r9, #s_prg_ptr]
	and	r0, r1, r0, lsl #14
	add	r0, r0, r2
	sub	r0, r0, #0xC000
	str	r0, [r9, #s_mem_map + 24]    @ C000
	str	r0, [r9, #s_mem_map + 28]    @ E000
	bx	lr

map_prg_8kB:
	ldr	r2, [r9, #s_prg_size]
	ldr	r3, [r9, #s_prg_ptr]
	and	r0, r2, r0, lsl #13
	add	r0, r0, r3
	sub	r0, r0, r1
	add	r1, r9, r1, lsr #11
	str	r0, [r1, #s_mem_map]
	bx	lr


map_chr_8kB:
	ldr	r1, [r9, #s_chr_size]
	ldr	r2, [r9, #s_chr_ptr]
	and	r0, r1, r0, lsl #13
	add	r0, r0, r2
	str	r0, [r9, #s_ppu_mem_map + 0x00]    @ 0000
	str	r0, [r9, #s_ppu_mem_map + 0x04]    @ 0400
	str	r0, [r9, #s_ppu_mem_map + 0x08]    @ 0800
	str	r0, [r9, #s_ppu_mem_map + 0x0C]    @ 0C00
	str	r0, [r9, #s_ppu_mem_map + 0x10]    @ 1000
	str	r0, [r9, #s_ppu_mem_map + 0x14]    @ 1400
	str	r0, [r9, #s_ppu_mem_map + 0x18]    @ 1800
	str	r0, [r9, #s_ppu_mem_map + 0x1C]    @ 1C00
	bx	lr
map_chr_4kB_to_0000:
	mov	r1, #0x0000
	b	map_chr_4kB
map_chr_4kB_to_1000:
	mov	r1, #0x1000
map_chr_4kB:
	ldr	r2, [r9, #s_chr_size]
	ldr	r3, [r9, #s_chr_ptr]
	and	r0, r2, r0, lsl #12
	add	r0, r0, r3
	sub	r0, r0, r1
	add	r1, r9, r1, lsr #8
	str	r0, [r1, #s_ppu_mem_map + 0x00]    @ +0000
	str	r0, [r1, #s_ppu_mem_map + 0x04]    @ +0400
	str	r0, [r1, #s_ppu_mem_map + 0x08]    @ +0800
	str	r0, [r1, #s_ppu_mem_map + 0x0C]    @ +0C00
	bx	lr
map_chr_2kB:
	ldr	r2, [r9, #s_chr_size]
	ldr	r3, [r9, #s_chr_ptr]
	and	r0, r2, r0, lsl #10
	add	r0, r0, r3
	sub	r0, r0, r1
	add	r1, r9, r1, lsr #8
	str	r0, [r1, #s_ppu_mem_map + 0x00]    @ +0000
	str	r0, [r1, #s_ppu_mem_map + 0x04]    @ +0400
	bx	lr
map_chr_1kB:
	ldr	r2, [r9, #s_chr_size]
	ldr	r3, [r9, #s_chr_ptr]
	and	r0, r2, r0, lsl #10
	add	r0, r0, r3
	sub	r0, r0, r1
	add	r1, r9, r1, lsr #8
	str	r0, [r1, #s_ppu_mem_map]
	bx	lr

mirror_1screen_lo:
	add	r0, r9, #s_name_table_ram - 0x2000
	b	mirror_1screen
mirror_1screen_hi:
	add	r0, r9, #s_name_table_ram + 0x0400 - 0x2000
mirror_1screen:
	str	r0, [r9, #s_ppu_mem_map + 0x20]    @ 2000
	sub	r0, r0, #0x0400
	str	r0, [r9, #s_ppu_mem_map + 0x24]    @ 2400
	sub	r0, r0, #0x0400
	str	r0, [r9, #s_ppu_mem_map + 0x28]    @ 2800
	sub	r0, r0, #0x0400
	str	r0, [r9, #s_ppu_mem_map + 0x2C]    @ 2C00
	sub	r0, r0, #0x0400
	str	r0, [r9, #s_ppu_mem_map + 0x30]    @ 3000
	sub	r0, r0, #0x0400
	str	r0, [r9, #s_ppu_mem_map + 0x34]    @ 3400
	sub	r0, r0, #0x0400
	str	r0, [r9, #s_ppu_mem_map + 0x38]    @ 3800
	sub	r0, r0, #0x0400
	str	r0, [r9, #s_ppu_mem_map + 0x3C]    @ 3C00
	bx	lr

mirror_vert:
	add	r0, r9, #s_name_table_ram - 0x2000
	str	r0, [r9, #s_ppu_mem_map + 0x20]    @ 2000
	str	r0, [r9, #s_ppu_mem_map + 0x24]    @ 2400
	add	r0, r9, #s_name_table_ram - 0x2800
	str	r0, [r9, #s_ppu_mem_map + 0x28]    @ 2800
	str	r0, [r9, #s_ppu_mem_map + 0x2C]    @ 2C00
	add	r0, r9, #s_name_table_ram - 0x3000
	str	r0, [r9, #s_ppu_mem_map + 0x30]    @ 3000
	str	r0, [r9, #s_ppu_mem_map + 0x34]    @ 3400
	add	r0, r9, #s_name_table_ram - 0x3800
	str	r0, [r9, #s_ppu_mem_map + 0x38]    @ 3800
	str	r0, [r9, #s_ppu_mem_map + 0x3C]    @ 3C00
	bx	lr

mirror_horiz:
	add	r0, r9, #s_name_table_ram - 0x2000
	str	r0, [r9, #s_ppu_mem_map + 0x20]    @ 2000
	add	r0, r9, #s_name_table_ram - 0x2400
	str	r0, [r9, #s_ppu_mem_map + 0x24]    @ 2400
	str	r0, [r9, #s_ppu_mem_map + 0x28]    @ 2800
	add	r0, r9, #s_name_table_ram - 0x2800
	str	r0, [r9, #s_ppu_mem_map + 0x2C]    @ 2C00
	add	r0, r9, #s_name_table_ram - 0x3000
	str	r0, [r9, #s_ppu_mem_map + 0x30]    @ 2000
	add	r0, r9, #s_name_table_ram - 0x3400
	str	r0, [r9, #s_ppu_mem_map + 0x34]    @ 2400
	str	r0, [r9, #s_ppu_mem_map + 0x38]    @ 2800
	add	r0, r9, #s_name_table_ram - 0x3800
	str	r0, [r9, #s_ppu_mem_map + 0x3C]    @ 2C00
	bx	lr

mirror_4screen:
	add	r0, r9, #s_name_table_ram - 0x2000
	str	r0, [r9, #s_ppu_mem_map + 0x20]    @ 2000
	str	r0, [r9, #s_ppu_mem_map + 0x24]    @ 2400
	str	r0, [r9, #s_ppu_mem_map + 0x28]    @ 2800
	str	r0, [r9, #s_ppu_mem_map + 0x2C]    @ 2C00
	add	r0, r9, #s_name_table_ram - 0x3000
	str	r0, [r9, #s_ppu_mem_map + 0x30]    @ 3000
	str	r0, [r9, #s_ppu_mem_map + 0x34]    @ 3400
	str	r0, [r9, #s_ppu_mem_map + 0x38]    @ 3800
	str	r0, [r9, #s_ppu_mem_map + 0x3C]    @ 3C00
	bx	lr

.globl	load_rom
load_rom:
	push	{r4-r11, lr}

	adr	r1, file_mode
	swi	e_fopen
	movs	r4, r0
	moveq	r5, #error_open - error_messages
	beq	error

	@ Read ROM header
	add	r0, r9, #s_rom_header
	mov	r1, #16
	mov	r2, #1
	mov	r3, r4
	swi	e_fread
	mov	r5, #error_bad_header - error_messages
	movs	r0, r0
	beq	error_fclose
	ldr	r1, [r9, #s_rom_header]
	ldr	r2, =0x1A53454E
	cmp	r1, r2
	bne	error_fclose

	ldrb	r5, [r9, #s_rom_header + 4]  @ Number of PRG-ROM banks
	movs	r5, r5, lsl #14
	moveq	r5, #0x400000
	sub	r0, r5, #1
	str	r0, [r9, #s_prg_size]

	ldrb	r7, [r9, #s_rom_header + 5]  @ Number of CHR-ROM banks
	movs	r6, r7, lsl #13
	moveq	r6, #0x2000
	sub	r0, r6, #1
	str	r0, [r9, #s_chr_size]

	add	r0, r5, r6
	swi	e_malloc
	movs	r0, r0
	moveq	r5, #error_no_memory - error_messages
	beq	error_fclose
	str	r0, [r9, #s_prg_ptr]
	add	r0, r5
	str	r0, [r9, #s_chr_ptr]

	@ Clear CHR-RAM if present
	movs	r1, r7
	moveq	r2, #0x2000
	moveq	r6, #0
	swieq	e_memset

	@ Read PRG-ROM and CHR-ROM from file
	ldr	r0, [r9, #s_prg_ptr]
	add	r1, r5, r6
	mov	r2, #1
	mov	r3, r4
	swi	e_fread
	movs	r0, r0
	moveq	r5, #error_rom_read - error_messages
	beq	error_fclose

	mov	r0, r4
	swi	e_fclose

	@ Initialize CPU memory map
	@ RAM
	str	r9, [r9, #s_mem_map + 0]     @ 0000
	@ SRAM
	add	r1, r9, #s_sram - 0x6000
	str	r1, [r9, #s_mem_map + 12]    @ 6000
	@ RAM wraparound
	sub	r1, r9, #0x10000
	str	r1, [r9, #s_mem_map + 32]    @ 10000

	@ Name table
	ldrb	r6, [r9, #s_rom_header + 6]
	adr	lr, 1f
	tst	r6, #8
	bne	mirror_4screen
	tst	r6, #1
	bne	mirror_vert
	beq	mirror_horiz
1:

	@ Get low 4 bits of mapper number
	mov	r0, r6, lsr #4
	@ Get high 4 bits of mapper number (unless it looks like
	@ there's junk in the header, in which case ignore them)
	ldr	r1, [r9, #s_rom_header + 12]
	movs	r1, r1
	ldreqb	r1, [r9, #s_rom_header + 7]
	andeq	r1, r1, #0xF0
	orreq	r0, r0, r1

	adr	r1, mapper_table
	adr	r2, mapper_table_end
1:	cmp	r2, r1
	moveq	r5, #error_bad_mapper - error_messages
	beq	error
	ldrh	r6, [r2, #-2]!
	ldrh	r5, [r2, #-2]!
	ldrh	r4, [r2, #-2]!
	cmp	r0, r4
	bne	1b
	add	r0, r1, r5
	str	r0, [r9, #s_mapper]

	adr	lr, 1f
	add	pc, r1, r6
1:	mov	r0, #0
	pop	{r4-r11, pc}
	.pool

file_mode:
	.string	"rb"
error_open:
	.string	"couldn't open file"
error_bad_header:
	.string	"not an NES file"
error_no_memory:
	.string	"not enough memory"
error_rom_read:
	.string	"couldn't read ROM"
error_bad_mapper:
	.string	"unimplemented mapper"
	.align	4

error_fclose:
	mov	r0, r4
	swi	e_fclose
error:
	ldr	r0, [r9, #s_prg_ptr]
	swi	e_free
	mov	r0, #0
	str	r0, [r9, #s_prg_ptr]
error_messages = .+8
	add	r0, pc, r5
	pop	{r4-r11, pc}

mapper_table:
.macro MAPPER n, addr, reset; .hword \n, \addr - mapper_table, \reset - mapper_table; .endm
	MAPPER   0, mapper_NROM, mapper_init_general
	MAPPER   1, mapper_MMC1, mapper_init_general
	MAPPER   2, mapper_UxROM, mapper_init_general
	MAPPER   3, mapper_CNROM, mapper_init_general
	MAPPER   4, mapper_MMC3, mapper_init_general
	MAPPER   7, mapper_AxROM, mapper_init_prg32k
	MAPPER   8, mapper_8, mapper_init_prg32k
	MAPPER  11, mapper_Color_Dreams, mapper_init_prg32k
	MAPPER  13, mapper_CPROM, mapper_init_general
	MAPPER  34, mapper_BxROM, mapper_init_prg32k
	MAPPER  39, mapper_BxROM, mapper_init_prg32k	@ same as 241
	MAPPER  66, mapper_GxROM, mapper_init_prg32k
	MAPPER  70, mapper_70, mapper_init_general
	MAPPER  76, mapper_76, mapper_init_general
	MAPPER  78, mapper_78, mapper_init_general
	MAPPER  81, mapper_81, mapper_init_general
	MAPPER  94, mapper_94, mapper_init_general
	MAPPER 107, mapper_107, mapper_init_prg32k
	MAPPER 144, mapper_144, mapper_init_prg32k
	MAPPER 148, mapper_148, mapper_init_prg32k
	MAPPER 149, mapper_149, mapper_init_general
	MAPPER 152, mapper_152, mapper_init_general
	MAPPER 155, mapper_MMC1, mapper_init_general
	MAPPER 177, mapper_177, mapper_init_prg32k
	MAPPER 180, mapper_180, mapper_init_general
	MAPPER 206, mapper_206, mapper_init_general
	MAPPER 228, mapper_Action_Enterprises, mapper_init_general
	MAPPER 241, mapper_BxROM, mapper_init_prg32k
mapper_table_end:

mapper_init_general:
	push	{lr}
	@ ROM low
	mov	r0, #0
	bl	map_prg_16kB_to_8000
	@ ROM high
	mov	r0, #-1
	bl	map_prg_16kB_to_C000
	@ Initialize PPU memory map
	mov	r0, #0
	pop	{lr}
mapper_CNROM:
	b	map_chr_8kB

mapper_init_prg32k:
	push	{lr}
	@ ROM
	mov	r0, #0
	bl	map_prg_32kB
	@ Initialize PPU memory map
	mov	r0, #0
	pop	{lr}
	b	map_chr_8kB

#define s_mmc1_shift_reg   (s_mapper_state)
#define s_mmc1_control     (s_mapper_state+4)
#define s_mmc1_chr0        (s_mapper_state+5)
#define s_mmc1_chr1        (s_mapper_state+6)
#define s_mmc1_prg         (s_mapper_state+7)
mapper_MMC1:
	push	{lr}
	tst	r0, #0x80
	bne	mmc1_reset
	ldrb	r3, [r9, #s_mmc1_shift_reg]
	and	r0, r0, #1
	movs	r3, r3, lsr #1
	orr	r0, r3, r0, lsl #4
	strb	r0, [r9, #s_mmc1_shift_reg]
	popcc	{pc}
	and	r2, r2, #0x6000
	add	r2, r9, r2, lsr #13
	strb	r0, [r2, #s_mmc1_control]
	b	mmc1_update
mmc1_reset:
	ldrb	r0, [r9, #s_mmc1_control]
	orr	r0, r0, #0x0C
	strb	r0, [r9, #s_mmc1_control]
mmc1_update:
	mov	r0, #0x10
	strb	r0, [r9, #s_mmc1_shift_reg]

	ldrb	r3, [r9, #s_mmc1_control]
	adr	lr, 1f
	and	r3, r3, #3
	add	pc, pc, r3, lsl #2
	nop
	b	mirror_1screen_lo
	b	mirror_1screen_hi
	b	mirror_vert
	b	mirror_horiz
1:

	@ Update CHR
	ldrb	r3, [r9, #s_mmc1_control]
	ldrb	r0, [r9, #s_mmc1_chr0]
	tst	r3, #0x10
	bne	1f
	mov	r0, r0, lsr #1
	bl	map_chr_8kB
	b	2f
1:	bl	map_chr_4kB_to_0000
	ldrb	r0, [r9, #s_mmc1_chr1]
	bl	map_chr_4kB_to_1000
2:

	@ Update PRG
	ldrb	r3, [r9, #s_mmc1_control]
	ldrb	r0, [r9, #s_mmc1_prg]
	@ Mode 0-1
	tst	r3, #0x08
	bne	1f
	mov	r0, r0, lsr #1
	pop	{lr}
	b	map_prg_32kB
1:

	@ Mode 2
	tst	r3, #0x04
	bne	1f
	bl	map_prg_16kB_to_C000
	mov	r0, #0
	bl	map_prg_16kB_to_8000
	pop	{pc}
	@ Mode 3
1:	bl	map_prg_16kB_to_8000
	mov	r0, #-1
	pop {lr}
mapper_180:
	b	map_prg_16kB_to_C000

mapper_CPROM:
	b	map_chr_4kB_to_1000

mapper_149:
	mov	r0, r0, lsr #7
	b	map_chr_8kB

#define s_mmc3_bank              (s_mapper_state)
#define s_mmc3_bank_select       (s_mapper_state+8)
#define s_mmc3_counter_reload    (s_mapper_state+9)
#define s_mmc3_counter           (s_mapper_state+10)
#define s_mmc3_counter_reset     (s_mapper_state+11)
#define s_mmc3_irq_enabled       (s_mapper_state+12)
mapper_MMC3:
	and	r1, r2, #0x6000
	and	r2, r2, #0x0001
	orr	r2, r2, r1, lsr #12
	add	pc, pc, r2, lsl #2
	nop
	b	mmc3_bank_select
	b	mmc3_bank_data
	b	mmc3_mirroring
mapper_NROM:
	bx	lr
	b	mmc3_irq_latch
	b	mmc3_irq_reload
	b	mmc3_irq_disable
	b	mmc3_irq_enable
mmc3_bank_select:
	strb	r0, [r9, #s_mmc3_bank_select]
	b	mmc3_update
mmc3_bank_data:
	ldrb	r1, [r9, #s_mmc3_bank_select]
	and	r3, r1, #7
	add	r3, r3, r9
	strb	r0, [r3, #s_mmc3_bank]
	b	mmc3_update
mmc3_mirroring:
	@ Don't do anything if game uses 4-screen mirroring
	ldrb	r3, [r9, #s_rom_header+6]
	tst	r3, #8
	bxne	lr
	tst	r0, #1
	beq	mirror_vert
	b	mirror_horiz
mmc3_irq_latch:
	strb	r0, [r9, #s_mmc3_counter_reload]
	bx	lr
mmc3_irq_reload:
	mov	r0, #0xFF
	strb	r0, [r9, #s_mmc3_counter_reset]
	bx	lr
mmc3_irq_disable:
	mov	r0, #0
	strb	r0, [r9, #s_irq_from_mapper]
mmc3_irq_enable:
	and	r0, r2, #1
	strb	r0, [r9, #s_mmc3_irq_enabled]
	bx	lr
.globl mmc3_scanline
mmc3_scanline:
	ldrb	r0, [r9, #s_mmc3_counter]

	ldrb	r1, [r9, #s_mmc3_counter_reset]
	bic	r1, r0, r1
	subs	r1, r1, #1
	ldrmib	r1, [r9, #s_mmc3_counter_reload]
	strb	r1, [r9, #s_mmc3_counter]
	mov	r2, #0
	strb	r2, [r9, #s_mmc3_counter_reset]

	cmp	r1, #0
	bxne	lr
	cmp	r0, #0
	bxeq	lr

	ldrb	r0, [r9, #s_mmc3_irq_enabled]
	strb	r0, [r9, #s_irq_from_mapper]
	bx	lr
mmc3_update:
	push	{r4, r5, lr}
	ldrb	r5, [r9, #s_mmc3_bank_select]

	mov	r4, #0x1000
	and	r4, r4, r5, lsl #5
	ldrb	r0, [r9, #s_mmc3_bank+0]; eor	r1, r4, #0x0000; bl	map_chr_2kB
	ldrb	r0, [r9, #s_mmc3_bank+1]; eor	r1, r4, #0x0800; bl	map_chr_2kB
	ldrb	r0, [r9, #s_mmc3_bank+2]; eor	r1, r4, #0x1000; bl	map_chr_1kB
	ldrb	r0, [r9, #s_mmc3_bank+3]; eor	r1, r4, #0x1400; bl	map_chr_1kB
	ldrb	r0, [r9, #s_mmc3_bank+4]; eor	r1, r4, #0x1800; bl	map_chr_1kB
	ldrb	r0, [r9, #s_mmc3_bank+5]; eor	r1, r4, #0x1C00; bl	map_chr_1kB

	mov	r4, #0x4000
	and	r4, r4, r5, lsl #8
	ldrb	r0, [r9, #s_mmc3_bank+6]; eor	r1, r4, #0x8000; bl	map_prg_8kB
	ldrb	r0, [r9, #s_mmc3_bank+7]; mov	r1,     #0xA000; bl	map_prg_8kB
	mov	r0, #-2;                  eor	r1, r4, #0xC000; bl	map_prg_8kB

	pop	{r4, r5, pc}

mapper_206:
	cmp	r2, #0xA000
	bxcs	lr
	tst	r2, #1
	bne	mmc3_bank_data
	and	r0, r0, #0x7
	strb	r0, [r9, #s_mmc3_bank_select]
	bx	lr

mapper_76:
	cmp	r2, #0xA000
	bxcs	lr
	tst	r2, #1
	bne	mmc3_bank_data
	and	r0, r0, #0x7
	strb	r0, [r9, #s_mmc3_bank_select]
	bx	lr
m76_bank_data:
	ldrb	r1, [r9, #s_mmc3_bank_select]
	and	r3, r1, #7
	add	r3, r3, r9
	strb	r0, [r3, #s_mmc3_bank]
	push	{lr}
	ldrb	r0, [r9, #s_mmc3_bank+2]; mov	r1, #0x0000; bl	map_chr_2kB
	ldrb	r0, [r9, #s_mmc3_bank+3]; mov	r1, #0x0800; bl	map_chr_2kB
	ldrb	r0, [r9, #s_mmc3_bank+4]; mov	r1, #0x1000; bl	map_chr_2kB
	ldrb	r0, [r9, #s_mmc3_bank+5]; mov	r1, #0x1800; bl	map_chr_2kB
	ldrb	r0, [r9, #s_mmc3_bank+6]; mov	r1, #0x8000; bl	map_prg_8kB
	ldrb	r0, [r9, #s_mmc3_bank+7]; mov	r1, #0xA000; bl	map_prg_8kB
	pop	{pc}

mapper_AxROM:
	push	{lr}
	mov	r3, r0
	tst	r3, #0x10
	bleq	mirror_1screen_lo
	blne	mirror_1screen_hi
	mov	r0, r3
	pop	{lr}
mapper_BxROM:
	b	map_prg_32kB

mapper_144:
	cmp	r2, #0x8000
	bxeq	lr
mapper_Color_Dreams:
	push	{lr}
	mov	r3, r0
	bl	map_prg_32kB
	mov	r0, r3, lsr #4
	pop	{lr}
	b	map_chr_8kB

mapper_177:
	push	{lr}
	mov	r3, r0
	tst	r3, #0x20
	bleq	mirror_vert
	blne	mirror_horiz
	mov	r0, r3
	pop	{lr}
	b	map_prg_32kB

mapper_GxROM:
	push	{lr}
	mov	r3, r0
	bl	map_chr_8kB
	mov	r0, r3, lsr #4
	pop	{lr}
	b	map_prg_32kB

mapper_107:
	push	{lr}
	mov	r3, r0
	bl	map_chr_8kB
	mov	r0, r3, lsr #1
	pop	{lr}
	b	map_prg_32kB

mapper_8:
	push	{lr}
	mov	r3, r0
	bl	map_chr_8kB
	mov	r0, r3, lsr #3
	pop	{lr}
mapper_UxROM:
	b	map_prg_16kB_to_8000

mapper_148:
	push	{lr}
	mov	r3, r0
	bl	map_chr_8kB
	mov	r0, r3, lsr #3
	pop	{lr}
	b	map_prg_32kB

mapper_70:
	push	{lr}
	mov	r3, r0
	bl	map_chr_8kB
	mov	r0, r3, lsr #4
	pop	{lr}
	b	map_prg_16kB_to_8000

mapper_152:
	push	{lr}
	mov	r3, r0
	bl	map_chr_8kB
	tst	r3, #0x80
	bleq	mirror_1screen_lo
	blne	mirror_1screen_hi
	mov	r0, r3, lsr #4
	pop	{lr}
	b	map_prg_16kB_to_8000

mapper_78:
	push	{lr}
	mov	r3, r0
	bl	map_prg_16kB_to_8000
	tst	r3, #0x08
	bleq	mirror_1screen_lo
	blne	mirror_1screen_hi
	mov	r0, r3, lsr #4
	pop	{lr}
	b	map_chr_8kB

mapper_Action_Enterprises:
	push	{r4, lr}
	mov	r4, r2
	and	r0, r0, #3
	orr	r0, r0, r2, lsl #2
	bl	map_chr_8kB
	mov	r0, r4, lsr #7
	and	r0, r0, #0x3F
	mov	r0, r0, lsl #15
	ldr	r1, [r9, #s_prg_size]
	ldr	r2, [r9, #s_prg_ptr]
	cmp	r0, r1
	andhi	r0, r0, r1
	add	r0, r0, r2
	bl	map_prg_32kB_from_pointer
	tst	r4, #0x20
	pop	{r4, lr}
	beq	mirror_vert
	bne	mirror_horiz

mapper_81:
	push	{r2, lr}
	and	r0, r2, #0xf
	bl	map_chr_8kB
	pop	{r0, lr}
mapper_94:
	mov	r0, r0, lsr #2
	b	map_prg_16kB_to_8000

.globl sram_load
sram_load:
	ldrb	r0, [r9, #s_rom_header+6]
	tst	r0, #0x02
	bxeq	lr
	push	{r4, lr}
	ldr	r0, [r9, #s_path_extension]
	adr	r1, save_ext
	swi	e_strcpy
	add	r0, r9, #s_path
	adr	r1, save_read_mode
	swi	e_fopen
	movs	r4, r0
	popeq	{r4, pc}
	add	r0, r9, #s_sram
	mov	r1, #0x2000
	mov	r2, #1
	mov	r3, r4
	swi	e_fread
	mov	r0, r4
	swi	e_fclose
	pop	{r4, pc}
.globl sram_save
sram_save:
	push	{r4-r5, lr}
	ldrb	r0, [r9, #s_rom_header+6]
	tst	r0, #0x02
	adreq	r5, no_saves
	beq	1f
	ldr	r0, [r9, #s_path_extension]
	adr	r1, save_ext
	swi	e_strcpy
	add	r0, r9, #s_path
	adr	r1, save_write_mode
	swi	e_fopen
	adr	r5, save_error
	movs	r4, r0
	beq	1f
	add	r0, r9, #s_sram
	mov	r1, #0x2000
	mov	r2, #1
	mov	r3, r4
	swi	e_fwrite
	movs	r0, r0
	adrne	r5, save_success
	mov	r0, r4
	swi	e_fclose
1:	mov	r0, r5
	pop	{r4-r5, lr}
	b	display_ingame_message
save_ext:
	.string	"sav.tns"
save_read_mode:
	.string	"rb"
save_write_mode:
	.string	"wb"
no_saves:
	.string	"Game has no save memory"
save_error:
	.string	"File error while saving"
save_success:
	.string	"Saved"
	.align	4

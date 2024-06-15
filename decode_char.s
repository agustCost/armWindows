.globl print_char
.globl print_int
.globl reset_position
.globl print_str
.data
    waiting_dash_bitmap: .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00
    characters: .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x5f, 0x5f, 0x06, 0x00, 0x00, 0x00, 0x03, 0x03, 0x00, 0x03, 0x03, 0x00, 0x00, 0x14, 0x7f, 0x7f, 0x14, 0x7f, 0x7f, 0x14, 0x00, 0x24, 0x2e, 0x6b, 0x6b, 0x3a, 0x12, 0x00, 0x00, 0x46, 0x66, 0x30, 0x18, 0x0c, 0x66, 0x62, 0x00, 0x30, 0x7a, 0x4f, 0x5d, 0x37, 0x7a, 0x48, 0x00, 0x04, 0x07, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x3e, 0x63, 0x41, 0x00, 0x00, 0x00, 0x00, 0x41, 0x63, 0x3e, 0x1c, 0x00, 0x00, 0x00, 0x08, 0x2a, 0x3e, 0x1c, 0x1c, 0x3e, 0x2a, 0x08, 0x08, 0x08, 0x3e, 0x3e, 0x08, 0x08, 0x00, 0x00, 0x00, 0x80, 0xe0, 0x60, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00, 0x60, 0x60, 0x00, 0x00, 0x00, 0x00, 0x60, 0x30, 0x18, 0x0c, 0x06, 0x03, 0x01, 0x00, 0x3e, 0x7f, 0x71, 0x59, 0x4d, 0x7f, 0x3e, 0x00, 0x40, 0x42, 0x7f, 0x7f, 0x40, 0x40, 0x00, 0x00, 0x62, 0x73, 0x59, 0x49, 0x6f, 0x66, 0x00, 0x00, 0x22, 0x63, 0x49, 0x49, 0x7f, 0x36, 0x00, 0x00, 0x18, 0x1c, 0x16, 0x53, 0x7f, 0x7f, 0x50, 0x00, 0x27, 0x67, 0x45, 0x45, 0x7d, 0x39, 0x00, 0x00, 0x3c, 0x7e, 0x4b, 0x49, 0x79, 0x30, 0x00, 0x00, 0x03, 0x03, 0x71, 0x79, 0x0f, 0x07, 0x00, 0x00, 0x36, 0x7f, 0x49, 0x49, 0x7f, 0x36, 0x00, 0x00, 0x06, 0x4f, 0x49, 0x69, 0x3f, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x66, 0x66, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xe6, 0x66, 0x00, 0x00, 0x00, 0x00, 0x08, 0x1c, 0x36, 0x63, 0x41, 0x00, 0x00, 0x00, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x00, 0x00, 0x00, 0x41, 0x63, 0x36, 0x1c, 0x08, 0x00, 0x00, 0x02, 0x03, 0x51, 0x59, 0x0f, 0x06, 0x00, 0x00, 0x3e, 0x7f, 0x41, 0x5d, 0x5d, 0x1f, 0x1e, 0x00, 0x7c, 0x7e, 0x13, 0x13, 0x7e, 0x7c, 0x00, 0x00, 0x41, 0x7f, 0x7f, 0x49, 0x49, 0x7f, 0x36, 0x00, 0x1c, 0x3e, 0x63, 0x41, 0x41, 0x63, 0x22, 0x00, 0x41, 0x7f, 0x7f, 0x41, 0x63, 0x3e, 0x1c, 0x00, 0x41, 0x7f, 0x7f, 0x49, 0x5d, 0x41, 0x63, 0x00, 0x41, 0x7f, 0x7f, 0x49, 0x1d, 0x01, 0x03, 0x00, 0x1c, 0x3e, 0x63, 0x41, 0x51, 0x73, 0x72, 0x00, 0x7f, 0x7f, 0x08, 0x08, 0x7f, 0x7f, 0x00, 0x00, 0x00, 0x41, 0x7f, 0x7f, 0x41, 0x00, 0x00, 0x00, 0x30, 0x70, 0x40, 0x41, 0x7f, 0x3f, 0x01, 0x00, 0x41, 0x7f, 0x7f, 0x08, 0x1c, 0x77, 0x63, 0x00, 0x41, 0x7f, 0x7f, 0x41, 0x40, 0x60, 0x70, 0x00, 0x7f, 0x7f, 0x0e, 0x1c, 0x0e, 0x7f, 0x7f, 0x00, 0x7f, 0x7f, 0x06, 0x0c, 0x18, 0x7f, 0x7f, 0x00, 0x1c, 0x3e, 0x63, 0x41, 0x63, 0x3e, 0x1c, 0x00, 0x41, 0x7f, 0x7f, 0x49, 0x09, 0x0f, 0x06, 0x00, 0x1e, 0x3f, 0x21, 0x71, 0x7f, 0x5e, 0x00, 0x00, 0x41, 0x7f, 0x7f, 0x09, 0x19, 0x7f, 0x66, 0x00, 0x26, 0x6f, 0x4d, 0x59, 0x73, 0x32, 0x00, 0x00, 0x03, 0x41, 0x7f, 0x7f, 0x41, 0x03, 0x00, 0x00, 0x7f, 0x7f, 0x40, 0x40, 0x7f, 0x7f, 0x00, 0x00, 0x1f, 0x3f, 0x60, 0x60, 0x3f, 0x1f, 0x00, 0x00, 0x7f, 0x7f, 0x30, 0x18, 0x30, 0x7f, 0x7f, 0x00, 0x43, 0x67, 0x3c, 0x18, 0x3c, 0x67, 0x43, 0x00, 0x07, 0x4f, 0x78, 0x78, 0x4f, 0x07, 0x00, 0x00, 0x47, 0x63, 0x71, 0x59, 0x4d, 0x67, 0x73, 0x00, 0x00, 0x7f, 0x7f, 0x41, 0x41, 0x00, 0x00, 0x00, 0x01, 0x03, 0x06, 0x0c, 0x18, 0x30, 0x60, 0x00, 0x00, 0x41, 0x41, 0x7f, 0x7f, 0x00, 0x00, 0x00, 0x08, 0x0c, 0x06, 0x03, 0x06, 0x0c, 0x08, 0x00, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00, 0x00, 0x03, 0x07, 0x04, 0x00, 0x00, 0x00, 0x20, 0x74, 0x54, 0x54, 0x3c, 0x78, 0x40, 0x00, 0x41, 0x7f, 0x3f, 0x48, 0x48, 0x78, 0x30, 0x00, 0x38, 0x7c, 0x44, 0x44, 0x6c, 0x28, 0x00, 0x00, 0x30, 0x78, 0x48, 0x49, 0x3f, 0x7f, 0x40, 0x00, 0x38, 0x7c, 0x54, 0x54, 0x5c, 0x18, 0x00, 0x00, 0x48, 0x7e, 0x7f, 0x49, 0x03, 0x02, 0x00, 0x00, 0x98, 0xbc, 0xa4, 0xa4, 0xf8, 0x7c, 0x04, 0x00, 0x41, 0x7f, 0x7f, 0x08, 0x04, 0x7c, 0x78, 0x00, 0x00, 0x44, 0x7d, 0x7d, 0x40, 0x00, 0x00, 0x00, 0x60, 0xe0, 0x80, 0x80, 0xfd, 0x7d, 0x00, 0x00, 0x41, 0x7f, 0x7f, 0x10, 0x38, 0x6c, 0x44, 0x00, 0x00, 0x41, 0x7f, 0x7f, 0x40, 0x00, 0x00, 0x00, 0x7c, 0x7c, 0x18, 0x38, 0x1c, 0x7c, 0x78, 0x00, 0x7c, 0x7c, 0x04, 0x04, 0x7c, 0x78, 0x00, 0x00, 0x38, 0x7c, 0x44, 0x44, 0x7c, 0x38, 0x00, 0x00, 0x84, 0xfc, 0xf8, 0xa4, 0x24, 0x3c, 0x18, 0x00, 0x18, 0x3c, 0x24, 0xa4, 0xf8, 0xfc, 0x84, 0x00, 0x44, 0x7c, 0x78, 0x4c, 0x04, 0x1c, 0x18, 0x00, 0x48, 0x5c, 0x54, 0x54, 0x74, 0x24, 0x00, 0x00, 0x00, 0x04, 0x3e, 0x7f, 0x44, 0x24, 0x00, 0x00, 0x3c, 0x7c, 0x40, 0x40, 0x3c, 0x7c, 0x40, 0x00, 0x1c, 0x3c, 0x60, 0x60, 0x3c, 0x1c, 0x00, 0x00, 0x3c, 0x7c, 0x70, 0x38, 0x70, 0x7c, 0x3c, 0x00, 0x44, 0x6c, 0x38, 0x10, 0x38, 0x6c, 0x44, 0x00, 0x9c, 0xbc, 0xa0, 0xa0, 0xfc, 0x7c, 0x00, 0x00, 0x4c, 0x64, 0x74, 0x5c, 0x4c, 0x64, 0x00, 0x00, 0x08, 0x08, 0x3e, 0x77, 0x41, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x77, 0x77, 0x00, 0x00, 0x00, 0x41, 0x41, 0x77, 0x3e, 0x08, 0x08, 0x00, 0x00, 0x02, 0x03, 0x01, 0x03, 0x02, 0x03, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    position: .word 0x0B00
    
.text
    
    # FUnction xddd
    # $a0 -> character in ascii , 0xFF prints waiting dash
    print_char:
	addi	    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
	
	
	beq	    $a0, $zero, endLine
	beq	    $a0, 0xFF, waiting_dash
	# cargar bitmap
	la $t0, characters
	addi $t1, $a0, -32
	mul $t1, $t1, 8
	add $a0, $t1, $t0

	# load size
	li $a2, 0x0808
	
	lw $a1, position
	print_ready:
	jal print_bitmap
	
	arrange_position:
	lw	$t1, position
	andi	$t0, $t1, 0xFF00
	srl	$t0, $t0, 8
	addi	$t0, $t0, 8
	beq	$t0, 115, new_line
	sll	$t0, $t0, 8
	andi	$t1, $t1, 0xFF
	or	$t2, $t1, $t0
	sw	$t2, position
	j endLine
	
	new_line:
	    li	    $t0, 0x0B
	    sll	    $t0, $t0, 8
	    andi    $t1, $t1, 0xFF
	    addi    $t1, $t1, 1
	    or	    $t2, $t1, $t0
	    sw	    $t2, position
	    
	waiting_dash:
	    la $a0, waiting_dash_bitmap
	    lw $a1, position
	    li $a2, 0x0808
	    jal print_bitmap
	    j arrange_position

	endLine:
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi	    $sp, $sp, 20
	jr	    $ra

    reset_position:
	addi	    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
    
	li $t1, 0x0B00
	sw $t1, position
    
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra
	
    print_int:
	addi	    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
    
	li	$a0, 110
	jal	print_char
    
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi	    $sp, $sp, 20
	jr	    $ra
	
	
	# $a0 adress ; $a1 -> position 0xaabb (aa column in hex) (bb page )
    print_str:
	addi	    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
    
	add	$s0, $a0, $zero
	sw	$a1, position
	print_str_loop:
	    lb	    $a0, ($s0)
	    beq	    $a0, $zero, end_str_loop
	    jal	    print_char
	    addi    $s0, $s0, 1
	    j	    print_str_loop
	    
	end_str_loop:
    
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi	    $sp, $sp, 20
	jr	    $ra
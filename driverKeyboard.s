.globl keyboard_check
.data
.text
    
# Set pins as input/output
keyboard_read:
    addi    $sp, $sp, -20
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
    
    
    
    li	    $t0, 0xF0
    sw	    $t0, TRISE
    start_mapping:
    li	    $t0, 0xF
    sw	    $t0, PORTE
    
    lw	    $t1, PORTE
    bgt	    $t1, 0xF, pressed_btn
    li	    $v0, 0
    j	    end_read
    pressed_btn:
	li	$t0, 0x1
	sw	$t0, PORTE
	lw	$t0, PORTE
	bgt	$t0, 1, pressed_row1
	li	$t0, 0x2
	sw	$t0, PORTE
	lw	$t0, PORTE
	bgt	$t0, 2, pressed_row2
	li	$t0, 0x4
	sw	$t0, PORTE
	lw	$t0, PORTE
	bgt	$t0, 4, pressed_row3
	li	$t0, 0x8
	sw	$t0, PORTE
	lw	$t0, PORTE
	bgt	$t0, 8, pressed_row4
	li	$v0, 0
	j	end_read
	
    pressed_row1:
	lw	$t0, PORTE
	beq	$t0, 0x11, case1_row1
	beq	$t0, 0x21, case2_row1
	beq	$t0, 0x41, case3_row1
	beq	$t0, 0x81, case4_row1
	j	start_mapping
	case1_row1:
	    # ascii
	    li	    $v0, 49
	    j	    end_read
	case2_row1:
	    li	    $v0, 65
	    j	    end_read
	case3_row1:
	    li	    $v0, 68
	    j	    end_read
	case4_row1:
	    # esc - 0xF0
	    li	    $v0, 0xF0
	    j	    end_read
	
	
    pressed_row2:
	lw	$t0, PORTE
	beq	$t0, 0x12, case1_row2
	beq	$t0, 0x22, case2_row2
	beq	$t0, 0x42, case3_row2
	beq	$t0, 0x82, case4_row2
	j	start_mapping
	case1_row2:
	    # ascii
	    li	    $v0, 49
	    j	    end_read
	case2_row2:
	    li	    $v0, 65
	    j	    end_read
	case3_row2:
	    li	    $v0, 68
	    j	    end_read
	case4_row2:
	    # esc - 0xF0
	    li	    $v0, 0xF0
	    j	    end_read
    pressed_row3:
	beq	    $t0, 0x14, case1_row3
	beq	    $t0, 0x24, case2_row3
	beq	    $t0, 0x44, case3_row3
	beq	    $t0, 0x84, case4_row3
	j	start_mapping
	case1_row3:
	    # ascii
	    li $v0, 49
	    j end_read
	case2_row3:
	    li $v0, 65
	    j end_read
	case3_row3:
	    li $v0, 68
	    j end_read
	case4_row3:
	    # esc - 0xF0
	    li $v0, 0xF0
	    j end_read
    pressed_row4:
	beq $t0, 0x18, case1_row4
	beq $t0, 0x28, case2_row4
	beq $t0, 0x48, case3_row4
	beq $t0, 0x88, case4_row4
	j start_mapping
	case1_row4:
	    # ascii
	    li $v0, 49
	    j end_read
	case2_row4:
	    li $v0, 65
	    j end_read
	case3_row4:
	    li $v0, 68
	    j end_read
	case4_row4:
	    # esc - 0xF0
	    li $v0, 0xF0
	    j end_read
    end_read:
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi	    $sp, $sp, 20
	jr	    $ra
		

   keyboard_check:
    addi    $sp, $sp, -20
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
	jal keyboard_read
	add $s1, $v0, $zero
	li $a0, 1000
	jal delay
	jal keyboard_read
	bne $s1, $v0, discard
	wait_for_release:
	    jal keyboard_read
	    bne $v0, $zero, wait_for_release
	j end_check
	discard:
	    add	    $v0, $zero, $zero
	end_check:
	    add	    $v0, $s1, $zero
	    lw	    $s3, 16($sp)
	    lw	    $s2, 12($sp)
	    lw	    $s1, 8($sp)
	    lw	    $s0, 4($sp)
	    lw	    $ra, ($sp)
	    addi    $sp, $sp, 20
	    jr		$ra
	    


.globl keyboard_check
.globl keyboard_type
.data
    one:		.byte ',', '.', '!', '1'
    two:		.byte  'A','B','C','2'
    three:		.byte  'D','E','F','3'
    four:		.byte  'G','H','I','4'
    five:		.byte  'J','K','L','5'
    six:		.byte  'M','N','O','6'
    seven:		.byte  'P','Q','R','S','7'
    eight:		.byte  'T','U','V','8'
    nine:		.byte  'W','X','Y','Z','9'
    zero:		.byte  ' ','0'
    input_counter: .byte 0x0
    last_input: .byte 0x0
.text
# This file contains the main driver for the usage of the T0308 membrane keyboard
# It has an integrated debounce of 1000 cpu clock signals
# Inputs are sent once the button is released
    # pin/port config
    # RE0 thru RE7
    
# Keyboard_read iterates thru the keyboard matrix and returns a read value in $v0
# Return values are ascii coded, with the exception of A, B, C and D keys
# that return the following values:
#   A -> 0xFF
#   B -> 0xFE
#   C -> 0xFB
#   D -> 0xF7  

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
	    li	    $v0, 50
	    j	    end_read
	case3_row1:
	    li	    $v0, 51
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
	    li	    $v0, 52
	    j	    end_read
	case2_row2:
	    li	    $v0, 53
	    j	    end_read
	case3_row2:
	    li	    $v0, 54
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
	    li $v0, 55
	    j end_read
	case2_row3:
	    li $v0, 56
	    j end_read
	case3_row3:
	    li $v0, 57
	    j end_read
	case4_row3:
	    li $v0, 0xFB
	    j end_read
    pressed_row4:
	beq $t0, 0x18, case1_row4
	beq $t0, 0x28, case2_row4
	beq $t0, 0x48, case3_row4
	beq $t0, 0x88, case4_row4
	j start_mapping
	case1_row4:
	    # ascii
	    li $v0, 42
	    j end_read
	case2_row4:
	    li $v0, 48
	    j end_read
	case3_row4:
	    li $v0, 35
	    j end_read
	case4_row4:
	    # esc - 0xF0
	    li $v0, 0xF7
	    j end_read
    end_read:
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi	    $sp, $sp, 20
	jr	    $ra
		

# Keyboard_check is a debounce function that double checks the keyboard input
# and waits for its release. Return is given in $v0, following the logic of
# keyboard_read
keyboard_check:
    addi    $sp, $sp, -20
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
    
    jal	    keyboard_read
    add	    $s1, $v0, $zero
    li	    $a0, 1000
    jal	    delay
    jal	    keyboard_read
    bne	    $s1, $v0, discard
    wait_for_release:
	jal	keyboard_read
	bne	$v0, $zero, wait_for_release
	j	end_check
    discard:
	add	$v0, $zero, $zero
    end_check:
	add	$v0, $s1, $zero
	lw	$s3, 16($sp)
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, ($sp)
	addi    $sp, $sp, 20
	jr	$ra
	
	
	
keyboard_type:
    addi    $sp, $sp, -20
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
	
	jal keyboard_check
	
	keyboard_type_loop:
	    sb $v0, last_input
    
	    beq $v0, $zero, finish
	    beq $v0, 0xFE, keyboard_type_loop
	    beq $v0, 0xFB, keyboard_type_loop
	    
	    
	    beq $v0, 0xF7, finish
	    beq $v0, 0xF0, finish
 
	    
	    jal keyboard_check
	    lb $t1, last_input
	    bne $v0, $t1, confirmed_input
	    
	    
	    lb $t0, input_counter
	    addi $t0, $t0, 1
	    beq $t0, 4, reset_counter
	    
	    
	    
	    li $s0, 0
	    waiting_loop:
	    jal keyboard_check
	    bne $v0, $zero, keyboard_type_loop
	    addi $s0, $s0, 1
	    beq $s0, 1000, confirmed_input
	    reset_counter:
		sb $zero, input_counter
		j keyboard_type_loop
	    
	confirmed_input:
	    lb $t0, input_counter
	    # t1 last input
	    # manage output and store in $v0
	    lb $t1, last_input
	    
	    beq $t1, 48, case0
	    beq $t1, 49, case1
	    beq $t1, 50, case2
	    beq $t1, 51, case3
	    beq $t1, 52, case4
	    beq $t1, 53, case5
	    beq $t1, 54, case6
	    beq $t1, 55, case7
	    beq $t1, 56, case8
	    beq $t1, 57, case9
	    case0:
		la $s1, zero
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case1:
		la $s1, one
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case2:
		la $s1, two
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case3:
		la $s1, three
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case4:
		la $s1, four
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case5:
		la $s1, five
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case6:
		la $s1, six
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case7:
		la $s1, seven
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case8:
		la $s1, eight
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    case9:
		la $s1, nine
		lb $t0, input_counter
		add $s1, $t0, $s1
		lb $v0, ($s1)
		j finish
	    finish:
	    sb $zero, input_counter
	lw	$s3, 16($sp)
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, ($sp)
	addi    $sp, $sp, 20
	jr	$ra
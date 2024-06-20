.globl execRot
    
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
    stack: .space 40
    stack_top: .byte 0x0
    entry: .asciiz "> "
    output: .asciiz "~ "
.text
    
    execRot:
	jal clear_display
	la $a0, entry
	li $a1, 0x0B00
	jal print_str
	jal print_stack_rot
	
	waiting_loop:
	    jal keyboard_check
	    beq $v0, $zero, waiting_loop
	
	    beq $v0, 0xFF, exit_rot
	    beq $v0, 35, rot_backspace
	    beq $v0, 0xF7, end_type
	    lb $t0, stack_top
	    beq $t0, 38, end_type
	    li $s3, 0
	    sb $zero, input_counter
	    add $s0, $zero, $v0
	    beq $v0, 48, case0
	    beq $v0, 49, case1
	    beq $v0, 50, case2
	    beq $v0, 51, case3
	    beq $v0, 52, case4
	    beq $v0, 53, case5
	    beq $v0, 54, case6
	    beq $v0, 55, case7
	    beq $v0, 56, case8
	    beq $v0, 57, case9
	    
	    
	    case0:
		la $s1, zero
		li $s2, 1
		j print_input
	    case1:
		la $s1, one
		li $s2, 3
		j print_input
	    case2:
		la $s1, two
		li $s2, 3
		j print_input
	    case3:
		la $s1, three
		li $s2, 3
		j print_input
	    case4:
		la $s1, four
		li $s2, 3
		j print_input
	    case5:
		la $s1, five
		li $s2, 3
		j print_input
	    case6:
		la $s1, six
		li $s2, 3
		j print_input
	    case7:
		la $s1, seven
		li $s2, 4
		j print_input
	    case8:
		la $s1, eight
		li $s2, 3
		j print_input
	    case9:
		la $s1, nine
		li $s2, 4
		j print_input
	    
		
	    halt:
		addi $s3, $s3, 1
		beq $s3, 8000, waiting_loop
		jal keyboard_check
		beq $v0, $zero, halt
		beq $v0, 35, rot_backspace
		beq $v0, 0xFF, exit_rot
		beq $v0, 0xF7, end_type
		bne $v0, $s0, waiting_loop
	    
	    lb $t0, input_counter
	    beq $t0, $s2, reset 
	    addi $t0, $t0, 1
	    sb $t0, input_counter
	    jal stackPop
	    j print_input
	    reset:
		sb $zero, input_counter
		jal stackPop
		

	    print_input:
		lb $t0, input_counter
		add $t0, $s1, $t0
		lb $a0, ($t0)
		jal stackPush
		jal print_stack_rot
		li $s3, 0
		j halt

	j execRot

	end_type:
	la $a0, output
	li $a1, 0x0B05
	jal print_str
	la $s0, stack
	    encryption_loop:
		lb $a0, ($s0)
		beq $a0, $zero, reading_loop
		bgt $a0, 122, print
		ble $a0, 64, print
		
		ble $a0, 90, upper
		ble $a0, 96, print
		ble $a0, 122, lower
		print:
		jal print_char
		addi $s0, $s0, 1
		j encryption_loop
		
	    lower:
		addi $a0, $a0, -97
		addi $a0, $a0, 13
		rem $t1, $a0, 26
		add $a0, $t1, $zero
		addi $a0, $a0, 97
		j print
	    upper:
		addi $a0, $a0, -65
		addi $a0, $a0, 13
		rem $t1, $a0, 26
		add $a0, $t1, $zero
		addi $a0, $a0, 65
		j print

	    j reading_loop
	reading_loop:

	    jal keyboard_check
	    beq $v0, 0xF7, exit_rot
	    beq $v0, 0xFF, exit_rot
	    j reading_loop
	
	    
	    
    exit_rot:
	la $t0, stack
	li $t1, 0
	clear_input_buffer:
	    add $t0, $t1, $t0
	    sb $zero, ($t0)
	    addi $t1, $t1, 1
	    bne $t1, 39, clear_input_buffer
	sb $zero, stack_top
	j goBack
	
    rot_backspace:
	jal stackPop
	j execRot
	
	
	# Stack functions
	
	# $a0 value
    stackPush:
	addi    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
	
	lb $t0, stack_top
	# max size
	
	bge $t0, 40, stack_overflow
	
	la $t2, stack
	
	add $t2, $t2, $t0
	sb $a0, ($t2)
	
	lb $t0, stack_top
	addi $t0, $t0, 1
	sb $t0, stack_top
	j end_push
	
	stack_overflow:
	# alert overflow
	    
	
	
	end_push:
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra
	
    # pop function, $v0 popped value
    stackPop:
	addi    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
    
	lb $t0, stack_top
	blez $t0, stack_underflow
	
	
	
	la $t1, stack
	add $t1, $t1, $t0
	lb $v0, ($t1)
	sb $zero, ($t1)
	
	addi $t0, $t0, -1
	sb $t0, stack_top
	
	stack_underflow:
	    # alert user
	
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra
	
	
    print_stack_rot:
	addi    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
    
	lb $s0, stack_top
	beq $s0, $zero, exit
	
	la $s1, stack
	li $s2, 0
	
	la $a0, entry
	li $a1, 0x0B00
	jal print_str
	print_loop:
	    add $t1, $s1, $s2
	    lb $a0, ($t1)
	    jal print_char
	    addi $s2, $s2, 1
	    bne $s2, $s0, print_loop
	
	
	    
	exit:
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra
	
    
.globl execRot
    
.data
    
    
    stack: .space 40
    stack_top: .byte 0x0
    entry: .asciiz "> "
    output: .asciiz "~ "
.text
    
    execRot:
	la $a0, entry
	li $a1, 0x0B00
	jal print_str
    
	jal keyboard_type
	beq $v0, $zero, execRot
	
	beq $v0, 0xF7, end_type
	lb $t0, stack_top
	beq $t0, 38, end_type
	
	add $a0, $v0, $zero
	jal stackPush
	jal print_stack_rot
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
	    

	    li $a0, 2000
	    jal delay
	    jal keyboard_check
	    beq $v0, 0x7F, execRot
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
.globl execCalc
.data
    stack: .space 40
    stack_top: .word 0
    input_buffer: .word 0
 
    input_internal: .byte 0x0 , 0x0, 0x0, 0x0
    current_iteration: .byte 0x0
    input_flag: .byte 0x0
    
    selected_operation: .byte 0x0
    
    
    buffer1: .word 0
    buffer2: .word 0
 
    str_stack: .byte 83, 116, 97, 99, 107, 58
.text
    execCalc:
	jal clear_display
	la $a0, str_stack
	li $a1, 7
	jal print_str
	jal print_stack
	read_input:
	    jal keyboard_check
	    
	    beq $v0, $zero, read_input
	    beq $v0, 0xF0, exit_calc
	    beq $v0, 35, operation_select
	    beq $v0, 0xF7, end_read
	    li $t1, 0x1
	    sb $t1, input_flag
	    
	    digit_management:
		lb $t0, current_iteration
		la $t1, input_internal
		add $t1, $t1, $t0
		addi $v0, $v0, -48
		sb $v0, ($t1)
		addi $t0, $t0, 1
		beq $t0, 5, end_and_convert
		sb $t0, current_iteration
		j read_input
		
		
		
	    
	    operation_select:
		li $t1, 0x1
		sb $t1, input_flag
		lb $t0, selected_operation
		addi $t0, $t0, 1
		beq $t0, 5, start_over
		j read_input
		
		start_over:
		    lw $zero, operation_select
		    j read_input
		
	    end_read:
	    lb $t1, input_flag
	    beq $t1, $zero, read_input
	    end_and_convert:
		lb $zero, input_flag
		sw $zero, current_iteration
		
		lb $t0, selected_operation
		bne $t0, $zero, end_operation
		
		
		li $t0, 1
		li $t1, 3
		convert_loop:
		    la $t2, input_internal
		    add $t2, $t1, $t2
		    lb $t3, ($t2)
		    mul $t3, $t3, $t0
		    lw $t2, input_buffer
		    add $t2, $t3, $t2
		    sw $t2, input_buffer
		    
		    addi $t1, $t1, -1
		    mul $t0, 10
		    mflo $t0
		    bne $t1, -1, convert_loop
		    
	        lw $a0, input_buffer
		jal stackPush
		lw $zero, input_buffer
		j execCalc
		    
	    end_operation:
		# + (1), - (2), * (3), p (4)
		lb $zero, input_flag
		lb $a0, operation_select
		sb $zero, operation_select
		jal operate
	    j execCalc

	exit_calc:
	    j goBack
    # push function
    # $a0 value
    stackPush:
	addi    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
	
	lw $t0, stack_top
	# max size
	
	bge $t0, 10, stack_overflow
	
	la $t2, stack
	sll $t0, $t0, 2
	
	add $t2, $t2, $t0
	sw $a0, ($t2)
	
	lw $t0, stack_top
	addi $t0, $t0, 1
	sw $t0, stack_top
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
    
	lw $t0, stack_top
	blez $t0, stack_underflow
	
	addi $t0, $t0, -1
	sw $t0, stack_top
	
	la $t1, stack
	sll $t0, $t0, 2
	add $t1, $t1, $t0
	
	lw $v0, ($t1)
	
	stack_underflow:
	    # alert user
	
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra
	
    # print stack function
    print_stack:
	addi    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
	
	
	lw $t0, stack_top
	li $t0, 0
	
	print_loop:
	    bge $t1, $t0, printStack_done
	    
	    la $t2, stack
	    sll $t3, $t1, 2
	    add $a0, $t2, $zero
	    jal print_int
	    li $a0, 20
	    jal print_char
	    j print_loop
	    
	    
	    
	printStack_done:
	    lw	    $s3, 16($sp)
	    lw	    $s2, 12($sp)
	    lw	    $s1, 8($sp)
	    lw	    $s0, 4($sp)
	    lw	    $ra, ($sp)
	    addi    $sp, $sp, 20
	    jr	    $ra

    # Operate function takes two values stored in buffer and conducts an operation
    # given by the paremeter $a0. Return value stored in $v0
    # add -> $a0 = 1
    # sub -> $a0 = 2
    # mult -> $a0 = 3
    # power -> $a0 = 4
    operate:
	addi	    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
    
    
	jal stackPop
	add $t0, $v0, $zero
	jal stackPop
	add $t1, $v0, $zero
	beq $a0, 1, add_op
	beq $a0, 2, sub_op
	beq $a0, 3, mult_op
	beq $a0, 4, power_op
	
	add_op:
	    add $v0, $t0, $t1
	    j operate_end
	sub_op:
	    sub $v0, $t0, $t1
	    j operate_end
	mult_op:
	    mul $v0, $t0, $t1
	    j operate_end
	power_op:
	    li $v0, 1
	    power_loop:
		# t1 = exponent
		# t0 = base
		beq $t1, $zero, operate_end
		mul $v0, $v0, $t0
		addi $t1, $t1, -1
		j power_loop
	
	operate_end:
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi	    $sp, $sp, 20
	jr	    $ra

    # Backspace function deletes the last input
    backspace:
	addi	    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
    
	jal clear_display
	jal stackPop
	jal print_stack
	
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi	    $sp, $sp, 20
	jr	    $ra
	

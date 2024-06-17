.globl execCalc
.data
    stack: .space 40
    stack_top: .word 0
    input_buffer: .word 0
 
    input_internal: .byte 0x0, 0x0, 0x0, 0x0
    current_iteration: .byte 0x0
    input_flag: .byte 0x0
    
    
    selected_operation: .byte 0x0
    
    str_current_type: .byte 0x5F, 0x5F, 0x5F, 0x5F, 0x0
    str_stack: .asciiz "Stack: "
.text
    execCalc:
	jal clear_display
	la $a0, str_stack
	la $a1, 0x0B00
	jal print_str
	jal print_stack
	read_input:
	    sw $zero, input_buffer
	    jal print_typing
	    jal keyboard_check
	    
	    beq $v0, $zero, read_input
	    beq $v0, 0xF0, exit_calc
	    beq $v0, 42, operation_select
	    beq $v0, 0xF7, end_read
	    beq $v0, 0xFB, delete_last
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
		sb $t0, selected_operation
		j read_input
		
		start_over:
		    sb $zero, selected_operation
		    j read_input
		
	    end_read:
	    lb $t1, input_flag
	    beq $t1, $zero, read_input
	    end_and_convert:
		lb $zero, input_flag
		
		lb $t0, selected_operation
		bne $t0, $zero, end_operation
		
		
		li $t0, 1
		lb $t1, current_iteration
		la $t2, input_internal
		convert_loop:
		    lb $t3, ($t2)
		    mul $t3, $t3, $t0
		    lw $t4, input_buffer
		    add $t4, $t3, $t4
		    sw $t4, input_buffer
		    
		    addi $t1, $t1, -1
		    addi $t2, $t2, 1
		    mul $t0, 10
		    mflo $t0
		    bne $t1, $zero, convert_loop
		
		    
		la $t0, input_internal
		li $t1, 0
		reset_input_internal:
		    add $t0, $t0, $t1
		    sb $zero, ($t0)
		    addi $t1, $t1, 1
		    bne $t1, 4, reset_input_internal
		    
	        lw $a0, input_buffer
		jal stackPush
		sb $zero, current_iteration
		lw $zero, input_buffer
		la $t0, str_current_type
		li $t1, 4
		reset_type_loop:
		    li $t2, 0x5F
		    sb $t2, ($t0)
		    addi $t0, $t0, 1
		    addi $t1, $t1, -1
		    bne $t1, $zero, reset_type_loop
		
		
		j execCalc
		    
	    end_operation:
		# + (1), - (2), * (3), p (4)
		lb $zero, input_flag
		lb $a0, selected_operation
		sb $zero, selected_operation
		jal operate
		add $a0, $v0, $zero
		jal stackPush
	    j execCalc
	    
	delete_last:
	    jal backspace
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
	
	
	lw $s0, stack_top
	li $s1, 0
	li $a0, 0x0B01
	jal update_print_position
	
	print_loop:
	    bge $s1, $s0, printStack_done
	    
	    la $t2, stack
	    sll $t3, $s1, 2
	    add $t2, $t2, $t3
	    lw $a0, ($t2)
	    jal print_int
	    li $a0, 44
	    jal print_char
	    addi $s1, $s1, 1
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
	add $s0, $v0, $zero
	jal stackPop
	add $s1, $v0, $zero
	beq $a0, 1, add_op
	beq $a0, 2, sub_op
	beq $a0, 3, mult_op
	beq $a0, 4, power_op
	
	add_op:
	    add $v0, $s0, $s1
	    j operate_end
	sub_op:
	    sub $v0, $s0, $s1
	    j operate_end
	mult_op:
	    mul $v0, $s0, $s1
	    j operate_end
	power_op:
	    li $v0, 1
	    power_loop:
		# t1 = exponent
		# t0 = base
		beq $s1, $zero, operate_end
		mul $v0, $v0, $s0
		addi $s1, $s1, -1
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
	
	
    print_typing:
	addi	    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
	
	la $t0, input_internal
	la $t1, str_current_type
	lb $t2, current_iteration
	lb $t3, selected_operation
	bne $t3, $zero, print_operation
	copy_loop:
	    beq	    $t2, $zero, ready_to_print
	    lb	    $t3, ($t0)
	    addi    $t3, $t3, 48
	    sb	    $t3, ($t1)
	    addi    $t0, $t0, 1
	    addi    $t1, $t1, 1
	    addi    $t2, $t2, -1
	    j	    copy_loop
	
	print_operation:
	    beq $t3, 1, display_sum
	    beq $t3, 2, display_sub
	    beq $t3, 3, display_mult
	    li $t4, 94
	    sb $t4, ($t1)
	    addi $t1, $t1, 1
	    sb $zero, ($t1)
	    j ready_to_print
	    display_sum:
		li $t4, 43
		sb $t4, ($t1)
		addi $t1, $t1, 1
		sb $zero, ($t1)
		j ready_to_print
	    display_sub:
		li $t4, 45
		sb $t4, ($t1)
		addi $t1, $t1, 1
		sb $zero, ($t1)
		j ready_to_print
	    display_mult:
		li $t4, 42
		sb $t4, ($t1)
		addi $t1, $t1, 1
		sb $zero, ($t1)
		j ready_to_print
	    
	    
	    
	ready_to_print:
	la $a0, str_current_type
	li $a1, 0x5F06
	jal print_str
	    
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi	    $sp, $sp, 20
	jr	    $ra

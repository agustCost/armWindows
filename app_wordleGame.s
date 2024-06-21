.globl execWordle
.data
    current_try: .byte 0x0
    stack: .space 6
    stack_top: .byte 0x0
    word_dictionary: .byte 0x41, 0x50, 0x50, 0x4c, 0x45, 0x00, 0x42, 0x41, 0x4b, 0x45, 0x52, 0x00, 0x43, 0x41, 0x4e, 0x44, 0x59, 0x00, 0x44, 0x41, 0x49, 0x53, 0x59, 0x00, 0x45, 0x41, 0x47, 0x4c, 0x45, 0x00, 0x46, 0x4c, 0x41, 0x4d, 0x45, 0x00, 0x47, 0x52, 0x41, 0x50, 0x45, 0x00, 0x48, 0x4f, 0x4e, 0x45, 0x59, 0x00, 0x49, 0x56, 0x4f, 0x52, 0x59, 0x00, 0x4a, 0x4f, 0x4b, 0x45, 0x52, 0x00, 0x4b, 0x4e, 0x49, 0x46, 0x45, 0x00, 0x4c, 0x45, 0x4d, 0x4f, 0x4e, 0x00, 0x4d, 0x41, 0x47, 0x49, 0x43, 0x00, 0x4e, 0x4f, 0x42, 0x4c, 0x45, 0x00, 0x4f, 0x43, 0x45, 0x41, 0x4e, 0x00, 0x50, 0x49, 0x41, 0x4e, 0x4f, 0x00, 0x51, 0x55, 0x45, 0x45, 0x4e, 0x00, 0x52, 0x4f, 0x42, 0x4f, 0x54, 0x00, 0x53, 0x55, 0x47, 0x41, 0x52, 0x00, 0x54, 0x49, 0x47, 0x45, 0x52, 0x00

    game_over_msg: .asciiz "Game over"
    user_win_msg: .asciiz "You win"
    
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
    
    hit_count: .byte 0x0
    response: .space 6
    seed: .byte 0x0
    print_position: .word 0x0B00
    input_counter: .byte 0x0
.text
    
    execWordle:
	jal clear_display
	# Generate random seed
	mfc0 $t0, $9
	andi $t0, $t0, 0xFF
	bge $t0, 20, reduce
	sb $t0, seed
	j start_game
	    reduce:
		addi $t0, $t0, -3
		bge $t0, 21, reduce
		sb $t0, seed
	start_game:
	    lb $t0, current_try
	    beq $t0, 4, send_end
	    # Keyboard input loop
	    waiting_loop:
		jal keyboard_check
		beq $v0, $zero, waiting_loop
		
		beq $v0, 0xFF, exit_wordle
		beq $v0, 35, wordle_backspace
		beq $v0, 0xF7, end_type
		lb $t0, stack_top
		beq $t0, 6, end_type
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
		    beq $v0, 35, wordle_backspace
		    beq $v0, 0xFF, exit_wordle
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
		    lw $a0, print_position
		    jal print_stack_wordle
		    li $s3, 0
		    j halt
		    
		end_type:
		    # game logic
		    lb $t0, seed
		    mul $t0, $t0, 6
		    la $t1, word_dictionary
		    add $s0, $t0, $t1
		    la $a0, print_position
		    jal print_stack_wordle
		    li $a0, 10000
		    jal delay
		    
		    # s0 has the adress of the chosen word
		    # print input => compare input with word => win or add try
		    la $t0, stack
		    li $t3, 0
		    add $t1, $s0, $zero
		    
		    
		    # char matches but in other position check
		    la $t0, stack
		    li $t3, 0
		    add $t1, $s0, $zero
		    half_hit_check:	
			lb $t2, ($t0)
			li $t4, 0
			check_loop:
			    lb $t5, ($t1)
			    beq $t2, $t5, commit_half_hit
			    addi $t1, $t1, 1
			    addi $t4, $t4, 1
			    bne $t4, 5, check_loop
			continue_search:
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			bne $t3, 5, half_hit_check
		    commit_half_hit:
			la $t5, response
			add $t5, $t5, $t3
			li $t8, '?'
			sb $t8, ($t5)
			addi $t1, $t1, 1
			addi $t4, $t4, 1
			bne $t4, 5, check_loop
			j continue_search
			
		    # ? do appear in full hits, but should be updated to =
		    # char matches position check
	            full_hit_check:
			lb $t2, ($t0)
			lb $t3, ($t1)
			beq $t2, $t3, commit_full_hit
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			addi $t3, $t3, 1
			bne $t3, 5, full_hit_check
		    commit_full_hit:
			la $t4, response
			add $t5, $t4, $t3
			li $t6, '='
			sb $t6, ($t5)
			lb $t7, hit_count
			addi $t7, $t7, 1
			sb $t7, hit_count
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			addi $t3, $t3, 1
			bne $t3, 5, full_hit_check
			
		    # Fill zeros with '_'
		    fill_response:
			la $t0, response
			li $t1, 0
			fill_loop:
			    lb $t2, ($t0)
			    beq $t0, $zero, add_char
			    addi $t0, $t0, 1
			    addi $t1, $t1, 1
			    bne $t1, 5, fill_loop
			j print_response
			add_char:
			    li $t3, '_'
			    sb $t3, ($t0)
			    addi $t0, $t0, 1
			    addi $t1, $t1, 1
			    bne $t1, 5, fill_loop
			print_response:
			    la $a0, response
			    lw $a1, print_position
			    jal print_str
			   
		    # check if the word is guessed
		    lb $t0, hit_count
		    sb $zero, hit_count
		    beq $t0, 5, user_wins
		    # clear response
		    la $t0, response
		    li $t1, 0
		    clear_loop:
			sb $zero, ($t0)
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			bne $t1, 5, clear_loop
		    # update current try
		    lb $t0, current_try
		    addi $t0, $t0, 1
		    sb $t0, current_try
		    # repeat
		    j start_game
		    send_end:
			jal clear_display
			sb $zero, current_try
			la $a0, game_over_msg
			li $a1, 0x0B00
			jal print_str
			li $a0, 1000000
			jal delay
			j execWordle
			user_wins:
			    jal clear_display
			    sb $zero, current_try
			    la $a0, user_win_msg
			    li $a1, 0x0B00
			    jal print_str
			    li $a0, 1000000
			    jal delay
			    j execWordle
		   
    exit_wordle:
	li $a0, 10000
	jal delay
	la $t0, stack
	lb $t1, stack_top
	li $t2, 0
	clear_loop_exit:
	    sb $zero, ($t0)
	    addi $t0, $t0, 1
	    bne $t2, $t1, clear_loop_exit
	sb $zero, stack_top
    wordle_backspace:
	jal stackPop
	jal clear_display
	li $a0, 0x0B00
	jal print_stack_wordle
	j start_game
	
# Data structure functions
	# Push function, $a0 value to push
    stackPush:
	addi    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
	
	lb $t0, stack_top
	# max size
	
	bge $t0, 6, stack_overflow
	
	la $t2, stack
	
	add $t2, $t2, $t0
	sb $a0, ($t2)
	
	lb $t0, stack_top
	addi $t0, $t0, 1
	sb $t0, stack_top
	j end_push
	
	stack_overflow:
	# Overflow is managed by ignoring the user request
	    
	
	
	end_push:
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra
	
    # Pop function, $v0 popped value
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
	    # Underflow is managed by ignoring the user request
	
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra
	
	
	# Prints the current stack, in the position given by parameter $a0
    print_stack_wordle:
	addi    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)
    
	jal update_print_position
	lb $s0, stack_top
	beq $s0, $zero, exit
	
	la $s1, stack
	li $s2, 0
	
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
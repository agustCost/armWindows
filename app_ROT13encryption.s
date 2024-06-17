.globl execRot
    
.data
    entry: .asciiz "> "
    output: .asciiz "~ "
    user_input: .space 38
.text
    
    execRot:
	jal clear_display
	la $a0, entry
	li $a1, 0x0B00
	jal print_str
	typing_loop:
	    jal keyboard_check
	    
	    beq $v0, $zero, typing_loop
	    beq $v0, 0x7F, end_typing
	    beq $v0, 0xF0, exit_rot
	    
	    
	    backspace:
		la $a0, 32
		jal print_char
		sb $zero, ($s0)
	    
	end_typing:
	la $a0, output
	li $a1, 0x0B05
	jal print_str
	la $s0, user_input
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
	    
	    beq $v0, 0x7F, execRot
	    j reading_loop
	
	    
	    
    exit_rot:
	la $t0, user_input
	li $t1, 0
	clear_input_buffer:
	    add $t0, $t1, $t0
	    sb $zero, ($t0)
	    addi $t1, $t1, 1
	    bne $t1, 38, clear_input_buffer
	j goBack
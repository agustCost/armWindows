.globl keyboard_check
.data
     
.text
    
# Set pins as input/output
keyboard_check:
    addi    $sp, $sp, -20
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
    
    
    
    li $t0, 0xF0
    sw $t0, TRISE
    start_mapping:
    li $t0, 0xF
    sw $t0, PORTE
    
    lw $t1, PORTE
    bgt $t1, 0xF, pressed_btn
    
    pressed_btn:
	li $t0, 0x1
	sw $t0, PORTE
	lw $t0, PORTE
	bgt $t0, 1, pressed_row1
	li $t0, 0x2
	sw $t0, PORTE
	lw $t0, PORTE
	bgt $t0, 2, pressed_row2
	li $t0, 0x4
	sw $t0, PORTE
	lw $t0, PORTE
	bgt $t0, 4, pressed_row3
	li $t0, 0x8
	sw $t0, PORTE
	lw $t0, PORTE
	bgt $t0, 8, pressed_row4
	j start_mapping
	
    pressed_row1:
	li $v0, 1
	
	
    pressed_row2:
    
    pressed_row3:
    
    pressed_row4:
	
    end_check:
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra
	



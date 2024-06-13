.globl delay
 
.data

.text
    
    # Takes $a0 as parameter and counts down to it
    delay:
	addi	    $sp, $sp, -20
	sw	    $ra, ($sp)
	sw	    $s0, 4($sp)
	sw	    $s1, 8($sp)
	sw	    $s2, 12($sp)
	sw	    $s3, 16($sp)

	add $t0, $a0, $zero
	delay_loop:
	    addi $t0, $t0, -1
	    bne $t0, $zero, delay_loop
	
	lw	    $s3, 16($sp)
	lw	    $s2, 12($sp)
	lw	    $s1, 8($sp)
	lw	    $s0, 4($sp)
	lw	    $ra, ($sp)
	addi    $sp, $sp, 20
	jr	    $ra


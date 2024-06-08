.globl play_melody
.data

melody: .word 554, 622, 622, 698, 831, 740, 698, 622, 554, 622, -1, 415, 415
rhythm: .word 6, 10, 6, 6, 1, 1, 1, 1, 6, 10, 4, 2, 10
buffer: .word 0

.text
# using RE0
 play_melody:
    # 13 note/rh length
    li $s0, 0
    la $t0, melody
    la $t1, rhythm
    melody_loop:
	lw $a0, ($t0)
	lw $a1, ($t1)
	jal generateTone
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	addi $s0, $s0, 1
	# length
	blt $s0, 13, melody_loop
    jr $ra
    
 generateTone:
    addi $sp, $sp, -8
    sw $ra, ($sp)
    sw $s0, 4($sp)
 # $a0 freq, #a1 rhythm
    beq $a0, -1, rest
    sw $zero, TRISE
    calculate_delay:
	add $t0, $a0, $zero
	
	# 8Mhz from PIC
	li $t1, 8000000
	li $t2, 1
	div $t2, $t1
	mflo $t3
	# $t3 period of internal clk
	div $t2, $a0
	mflo $t2
	mul $t2, $t2,2
	div $t2, $t3
	mflo $t4
	sw $t4, buffer
	# $t4 = number of clk ticks for half period of desired freq
    # counter
    toneLoop:
	# high
	li $t3, 0x1
	sw $t3, PORTE
	
	lw $a0, buffer
	jal toneDelay
	
	# low
	sw $zero, PORTE
	
	lw $a0, buffer
	jal toneDelay
	bne $s1, $zero, toneLoop
	j endTone
	
    toneDelay:
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	add $t3, $a0, $zero
	delay_loop:
	    beq $t3, $zero, end_delay
	    addi $t3, $t3, -1
	    j delay_loop
	end_delay:
	    lw $ra, ($sp)
	    lw $s0, 4($sp)
	    lw $s1, 8($sp)
	    addi $sp, $sp, 12
	    jr $ra
    endTone:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
    rest:
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 4
	jr $ra
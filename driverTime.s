# This file could be used to configure the RTC module, but due to a lack of pin
# conections for an external oscillator, it needed to be descarded.
    
    
.globl set_time
.globl print_time
.globl init_timeModule
.data
    
.text
    
init_timeModule:
    addi    $sp, $sp, -20
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
    
	li $t1, 0x8000
	sw $t1, RTCCONCLR
	
	# Enable secondary oscillator 32kHz
	li $t1, 0x2
	sw $t1, OSCCONSET
	
	li $t1, 0x200
	sw $t1, RTCCONSET
	
	# Use system keys to access enable write mode
	li $t1, 0xAA996655
	li $t2, 0x556699AA
	sw $t1, SYSKEY
	sw $t2, SYSKEY
	# write enable mode
	li $t1, 0x8
	sw $t1, RTCCONSET
	# <3>
	wait_loop:
	    lw $t1, RTCCON
	    andi $t1, $t1, 0x40

	    bne $t1, $zero, wait_loop
	
	li $t1, 0x07135600
	sw $t1, RTCTIME
	# disable write enable mode

	li $t1, 0x8000
	sw $t1, RTCCONSET
	li $t1, 0x8
	sw $t1, RTCCONCLR

	
    lw	    $s3, 16($sp)
    lw	    $s2, 12($sp)
    lw	    $s1, 8($sp)
    lw	    $s0, 4($sp)
    lw	    $ra, ($sp)
    addi	    $sp, $sp, 20
    jr	    $ra
	
	
print_time:
    addi    $sp, $sp, -20
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
    
    lw $t1, RTCTIME
    srl $t1, $t1, 8
    li $t2, 20
    li $s1, 0
    arrange_loop:
	andi $t3, $t1, 0xF
	sll $t0, $t3, $t2
	or $s1, $t0, $s1
	srl $t1, $t1, 4
	addi $t2, $t2, -4
	bne $t2, $zero, arrange_loop
    li $s0, 0
    print_loop:
	
	andi $t1, $s1, 0xF
	addi $a0, $t1, 48
	jal print_char
	addi $s0, $s0, 1
	bne $s0, 2, continue
	li $a0, 58
	jal print_char
	continue:
	bne $s0, 4, finish
	li $a0, 58
	jal print_char
	finish:
	srl $s1, $s1, 4
	bne $s0, 6, print_loop
	
	
    lw	    $s3, 16($sp)
    lw	    $s2, 12($sp)
    lw	    $s1, 8($sp)
    lw	    $s0, 4($sp)
    lw	    $ra, ($sp)
    addi	    $sp, $sp, 20
    jr	    $ra
	
    



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
	
	
	# Use system keys to be able to enable write mode
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
	
	li $t1, 0x07135500
	sw $t1, RTCTIME
	# disable write enable mode
	li $t1, 0x8
	sw $t1, RTCCONCLR
	
	
	li $t1, 0x8000
	sw $t1, RTCCONSET
	
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
    
    lw $s1, RTCTIME
    srl $s1, $s1, 8
    li $s0, 0
    print_loop:
	andi $t1, $s1, 0xF
	addi $a0, $t1, 48
	jal print_char
	addi $s0, $s0, 1
	srl $s1, $s1, 4
	bne $s0, 4, print_loop
	
    lw	    $s3, 16($sp)
    lw	    $s2, 12($sp)
    lw	    $s1, 8($sp)
    lw	    $s0, 4($sp)
    lw	    $ra, ($sp)
    addi	    $sp, $sp, 20
    jr	    $ra
	
    



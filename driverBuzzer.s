.globl play_melody
.data

intro_melody: .word 554, 622, 622, 698, 831, 740, 698, 622, 554, 622, -1, 415, 415
intro_rhythm: .word 6, 10, 6, 6, 1, 1, 1, 1, 6, 10, 4, 2, 10

.text
# using RE0

# $a0 = delay in us
delayMicroseconds:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $t1, 0($sp)
    
    li $t1, 0
delayMicrosecondsLoop:
    addi $t1, $t1, 1
    bne $t1, $a0, delayMicrosecondsLoop

    lw $ra, 4($sp)
    lw $t1, 0($sp)
    addi $sp, $sp, 8
    jr $ra

# generate tone
# $a0 duration, $a1 freq
generateTone:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)
    
    li $t0, 0x0
    sw $t0, TRISE
    li $t0, 1000000
    div $t0, $a1
    mflo $t1 # period
    srl $t1, $t1, 1 # half period
    
    mul $t2, $a0, 1000 # duration in us
    
toneLoop:
    beq $t2, $zero, endTone
    
    # High period
    li $t3, 0x1
    sw $t3, PORTE
    move $a0, $t1
    jal delayMicroseconds
    
    # Low period
    li $t3, 0
    sw $t3, PORTE
    move $a0, $t1
    jal delayMicroseconds
    
    subu $t2, $t2, $t1
    subu $t2, $t2, $t1
    
    j toneLoop
endTone:
    lw $ra, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addi $sp, $sp, 12
    jr $ra

play_melody:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $t0, 4($sp)
    sw $t1, 0($sp)
    
    la $t0, intro_melody
    la $t1, intro_rhythm
    li $t2, 13
noteLoop:
    lw $a1, ($t0)
    lw $a0, ($t1)
    
    mul $a0, $a0, 100
    
    jal generateTone
    
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, -1
    bne $t2, $zero, noteLoop

    lw $ra, 8($sp)
    lw $t0, 4($sp)
    lw $t1, 0($sp)
    addi $sp, $sp, 12
    jr $ra
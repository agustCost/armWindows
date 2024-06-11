# This file contains the main driver for the usage of the SSD1306 OLED
# It considers the datasheet power-on sequence as well as the initialization 
# setup.
# send_1306 consists of a writeCommand and writeData, which are implemented 
# using a 3-wire SPI transmission system.
.globl	    init_pin1306
.globl	    init_spi
.globl	    init_ssd1306
.globl	    send_1306
.globl	    delay
.globl	    print_bitmap
.globl	    clear_display
.data
    
.text
# pin/port config
    # D0 -> SCK1
    # D1 -> SDO1
    # RES -> RD0
    # DC -> RD1
    # CS -> RD2
init_pin1306:
    addi	$sp, $sp, -4
    sw		$ra, ($sp)
    # All ports set to output(0)
    # DC# && CS# && RES#
    li		$t1, 0x0
    sw		$t1, TRISD
    
    # Set transmission(D0 && D1) ports to output
    li		$t1, 0x0
    sw		$t1, TRISF
    
    lw		$ra, ($sp)
    addi	$sp, $sp, 4
    jr		$ra
    
init_spi:
    addi	$sp, $sp, -4
    sw		$ra, ($sp)

    jal		delay
    
    # Disable interrupts
    li		$t0, 0x03800000
    sw		$t0, IEC1   
    
    # Reset SPIxCON
    sw		$zero, SPI1CON    
    # Set SRG
    li		$t0, 0x0
    sw		$t0, SPI1BRG    
    # Clear SPIROV bit
    li		$t0, 0x40
    sw		$t0, SPI1STATCLR
    # SPIxCON setup
    # 8 bit transfer, Master mode, CKE = 1
    li		$t0, 0x120
    sw		$t0, SPI1CON

    # Enable ON bit in SPIxCON (<15>)
    li		$t0, 0x8120
    sw		$t0, SPI1CON


    lw		$ra, ($sp)
    addi	$sp, $sp, 4
    jr		$ra

init_ssd1306:
    addi	$sp, $sp, -4
    sw		$ra, ($sp)

    jal		delay
    # Power ON sequence based on datasheet
    
    # RES# low
    li		$t0, 0x0
    sw		$t0, PORTD
    # Hold for at least 3us
    jal		delay        
    # RES# high
    li		$t0, 0x1
    sw		$t0, PORTD

    jal		delay
    # SSD1306 initialization
	# OFF
	li	$a1, 0x1
	li	$a0, 0xAE
	jal	send_1306
	# Set contrast control
	li	$a1, 0x1
	li	$a0, 0x81
	jal	send_1306
	li	$a1, 0x1
	li	$a0, 0x7F
	jal	send_1306
	
	# Set normal display
	li	$a1, 0x1
	li	$a0, 0xA6
	jal	send_1306
	
	# Set oscillator frequency
	li	$a1, 0x1
	li	$a0, 0xD5
	jal	send_1306
	li	$a1, 0x1
	li	$a0, 0x80
	jal	send_1306
	
	# Enable charge pump regulator
	li	$a1, 0x1
	li	$a0, 0x8D
	jal	send_1306
	li	$a1, 0x1
	li	$a0, 0x14
	jal	send_1306
	
	# Horizontal adressing mode
	li	$a0, 0x20
	li	$a1, 0x1
	jal	send_1306
	
	li	$a0, 0x00
	li	$a1, 0x1
	jal	send_1306
	
	# Column adress
	li $a0, 0x21
	li $a1, 0x1
	jal send_1306
	
	li $a0, 0x00
	li $a1, 0x1
	jal send_1306
	
	li $a0, 0x7F
	li $a1, 0x1
	jal send_1306
	# Page adress
	li $a0, 0x22
	li $a1, 0x1
	jal send_1306
	
	li $a0, 0x00
	li $a1, 0x1
	jal send_1306
	
	li $a0, 0x7
	li $a1, 0x1
	jal send_1306
	
	# Display ON
	li $a0, 0xAF
	li $a1, 0x1
	jal send_1306
	
	# see datasheet
	li $a0, 0xA4
	li $a1, 0x1
	jal send_1306
	
	jal clear_display
	
	
	
    lw	    $ra, ($sp)
    addi    $sp, $sp, 4
    jr	    $ra
clear_display:
    addi    $sp, $sp, -24
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
    sw	    $s4, 20($sp)
    
    li $s0, 0
	clear_display_loop:
	    li $a0, 0x00
	    li $a1, 0x3
	    jal send_1306
	    addi $s0, $s0, 1
	    bne $s0, 1024, clear_display_loop
    lw	    $ra, ($sp)
    lw	    $s0, 4($sp)
    lw	    $s1, 8($sp)
    lw	    $s2, 12($sp)
    lw	    $s3, 16($sp)
    lw	    $s4, 20($sp)
    addi    $sp, $sp, 24
    jr	    $ra
# send_1306($a0 byte, $a1 pinState)
    # $a1 can be 0x1 for commands or 0x3 for data
send_1306:
    addi    $sp, $sp, -24
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
    sw	    $s4, 20($sp)
    
    # DC# low for commands
    # DC# high for data
    sw	    $a1, PORTD
    # RES # still high
    # copy $a0 to buffer
    sw	    $a0, SPI1BUF

    # Check SPITBUSY (<11>) in SPIxSTAT
    check:
	lw	$t0, SPI1STAT
	li	$t1, 0x800
	and	$t1, $t0, $t1
	beq	$t1, 1, check
    lw	    $ra, ($sp)
    lw	    $s0, 4($sp)
    lw	    $s1, 8($sp)
    lw	    $s2, 12($sp)
    lw	    $s3, 16($sp)
    lw	    $s4, 20($sp)
    addi    $sp, $sp, 24
    jr	    $ra
delay:
    addi    $sp, $sp, -4
    sw	    $ra, ($sp)

    li	    $t0, 5000

    delay_loop:
    addi    $t0, $t0, -1
    bne	    $t0, $zero, delay_loop

    lw	    $ra, ($sp)
    addi    $sp, $sp, 4
    jr      $ra
    
    
# print_bitmap($a0 bitmap (by), $a1 page/column (hw), $a2 dimension (hw))
    # hw: 0xaabb aa = pageI or pageF, bb = columnI or columnF
    # dimensions are sent in column / pages
print_bitmap:
    addi    $sp, $sp, -20
    sw	    $ra, ($sp)
    sw	    $s0, 4($sp)
    sw	    $s1, 8($sp)
    sw	    $s2, 12($sp)
    sw	    $s3, 16($sp)
    
    
	
    # $s0 = bitmap
    add	$s0, $a0, $zero
    add $s1, $a1, $zero
    add $s2, $a2, $zero
    
    andi $t0, $s1, 0xFF00
    srl $t0, $t0, 8
    andi $t1, $s2, 0xFF00
    srl $t1, $t1, 8
    addi $t1, $t1, 1
    sub $t0, $t1, $t0
    andi $t1, $s1, 0xFF
    andi $t2, $s2, 0xFF
    addi $t2, $t2, 1
    sub $t1, $t2, $t1
    mul $s3, $t1, $t0

    # Cursor setting
    
    # Column adress
    li $a0, 0x21
    li $a1, 0x1
    jal send_1306
	
    andi $a0, $s1, 0xFF00
    li $a1, 0x1
    jal send_1306
    
    andi $a0, $s2, 0xFF00
    li $a0, 0x7F
    li $a1, 0x1
    jal send_1306
    
    # Page adress
    li $a0, 0x22
    li $a1, 0x1
    jal send_1306
	
    andi $a0, $s1, 0xFF
    li $a0, 0
    li $a1, 0x1
    jal send_1306
    
    andi $a0, $s2, 0xFF
    li $a0, 0x07
    li $a1, 0x1
    jal send_1306
    
    print_loop:
	lb	$a0, ($s0)
	li	$a1, 0x3
	jal	send_1306
	addi	$s1, $s1, 1
	addi	$s0, $s0, 1
	bne	$s1, $s3, print_loop

    lw	    $s3, 16($sp)
    lw	    $s2, 12($sp)
    lw	    $s1, 8($sp)
    lw	    $s0, 4($sp)
    lw	    $ra, ($sp)
    addi    $sp, $sp, 20
    jr	    $ra
	    
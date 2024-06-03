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
    li		$t0, 0
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
    # SSD1306 initialization based on datasheet sequence
	# Multiplex ratio
	li	$a1, 0x1
	li	$a0, 0xA8
	jal	send_1306
	li	$a1, 0x1
	li	$a0, 0x3F
	jal	send_1306
	
	# Set display offset
	li	$a1, 0x1
	li	$a0, 0xD3
	jal	send_1306
	li	$a1, 0x1
	li	$a0, 0x00
	jal	send_1306
	
	# Set display start line
	li	$a1, 0x1
	li	$a0, 0x40
	jal	send_1306
	
	# Set segment re-map
	li	$a1, 0x1
	li	$a0, 0xA0
	jal	send_1306

	
	# Set COM output scan direction
	li	$a1, 0x1
	li	$a0, 0xC0
	jal	send_1306
	
	# Set COM pins HW config
	li	$a1, 0x1
	li	$a0, 0xDA
	jal	send_1306
	li	$a1, 0x1
	li	$a0, 0x02
	jal	send_1306
	
	# Set contrast control
	li	$a1, 0x1
	li	$a0, 0x81
	jal	send_1306
	li	$a1, 0x1
	li	$a0, 0x7F
	jal	send_1306
	
	# Disable entire display ON
	li	$a1, 0x1
	li	$a0, 0xA4
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
	
	# Display ON
	li	$a1, 0x1
	li	$a0, 0xAF
	jal	send_1306
	
	
	li	$a1, 0x1
	li	$a0, 0xA5
	jal	send_1306
    
    lw	    $ra, ($sp)
    addi    $sp, $sp, 4
    jr	    $ra
# send_1306($a0 byte, $a1 pinState)
    # $a1 can be 0x1 for commands or 0x3 for data
send_1306:
    addi    $sp, $sp, -4
    sw	    $ra, ($sp)
    
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
    addi    $sp, $sp, 4
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
.end main
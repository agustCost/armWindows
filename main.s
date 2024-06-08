.data
.text
.globl main
.ent main
    main:
	jal init_pin1306
	jal init_spi
	jal init_ssd1306
	jal print_bitmap
	
	loop:
	    j loop
.end main



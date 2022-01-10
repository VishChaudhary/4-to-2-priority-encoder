;
; priority_encoder_4to2.asm
;
; Created: 9/22/2021 5:01:56 PM
; Author : vish75000
; Target: AVR128DB48


; Replace with your application code
start:    
; Configure I/O ports
    ldi r16, 0xFF       ;load r16 will all 1s
    out VPORTD_DIR, r16 ;VPORTD - all pins configured as outputs
    out VPORTD_OUT, r16 ;VPORTD - all outputs 0s
    out VPORTC_DIR, r16 ;VPORTC - all pins configured as inputs

again:
    in r16, VPORTC_IN   ;read switch values
    mov r19, r16        ;save copy of input
    andi r16, 0x08      ;mask all but /E1
	cpi r16, 0x08		;checks if /E1 is high
    brne not_enabled    ;device is not enabled, skip conditionals

a0:
    ; Checking for X-I0    X-I1    X-I2    L-I3
    mov r16, r19		;copy r19 back into r16
    andi r16, 0xF0		;mask everything but first 4 bits
    cpi r16, 0x10		;compare input to 00010000
    brne a1				;branch to next conditional if not equal
    ldi r17, 0x10		;if equal, set r17 to 00010000
	rjmp output			;jump to ouput
a1:
    ; Checking for X-I0    X-I1    L-I2    H-I3
    mov r16, r19		;copy r19 back into r16
    andi r16, 0xF0		;mask everything but first 4 bits
    cpi r16, 0x20		;compare input to 00100000
    brne a2				;branch to next conditional if not equal
    ldi r17, 0x50		;if equal, set r17 to 01010000
	rjmp output			;jump to output
a2:
    ; Checking for X-I0    L-I1    H-I2    H-I3
    mov r16, r19		;copy r19 back into r16
    andi r16, 0xF0		;mask everything but first 4 bits
    cpi r16, 0x40		;compare input to 01000000
    brne a3				;branch to next conditional if not equal
    ldi r17, 0x90		;if equal, set r17 to 10010000
	rjmp output			;jump to output
a3:
    ; Checking for L-I0    H-I1    H-I2    H-I3
    mov r16, r19		;copy r19 back into r16
    andi r16, 0xF0		;mask everything but first 4 bits
    cpi r16, 0x80		;compare input to 10000000
						;last conditional, does not need to jump, must execute
    ldi r17, 0xD0		;if equal, set r17 to 11010000
	rjmp output			;jump to output
not_enabled:
	ldi r17, 0xF8		;outputs 1111 if E1 is disabled

output:
    out VPORTD_OUT, r17 ;output encoder logic to LEDs
    rjmp again          ;continually repeat everything

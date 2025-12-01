ORG 0x0000
    B START
ORG 0x0000
    B START

; Minimal example: print "arpan" to the LCD
LCD_BASE:    DEFW 0xFF40
TEMP1:       DEFW 0

START:
    ; Print the name to the LCD (uses R2 as the LCD pointer register)
; Print string: "arpan"
__PTR_LCD_BASE_1:    DEFW LCD_BASE
    LD R2, __PTR_LCD_BASE_1
    MOV R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #7
    ST R1, [R2]
    MOV R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #9
    ADD R3, R2, #1
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #7
    ADD R3, R2, #2
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #7
    ADD R3, R2, #3
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #5
    ADD R3, R2, #4
    ST R1, [R3]

    ; --- SAVE/RESTORE test ---
    ; Put a known value in R1, save it to TEMP1, clobber R1, then restore
    MOV R1, #7
__PTR_TEMP1_2:    DEFW TEMP1
    LD R3, __PTR_TEMP1_2
    ST R1, [R3]
    ; put 'A' (65) in R1 using the macro
    MOV R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #5
; Print string: "A"
__PTR_LCD_BASE_3:    DEFW LCD_BASE
    LD R2, __PTR_LCD_BASE_3
    MOV R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #5
    ST R1, [R2]
__PTR_TEMP1_4:    DEFW TEMP1
    LD R3, __PTR_TEMP1_4
    LD R1, [R3]

    ; Stop here
DONE:
    B DONE
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
    LD R2, LCD_BASE
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
__PTR_TEMP1_1:    DEFW TEMP1
    LD R3, __PTR_TEMP1_1
    ST R1, [R3]
    MOV R1, #65        ; put 'A' (value) in R1 to simulate clobber
; Print string: "A"
    LD R2, LCD_BASE
    MOV R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #15
    ADD R1, R1, #5
    ST R1, [R2]
__PTR_TEMP1_2:    DEFW TEMP1
    LD R3, __PTR_TEMP1_2
    LD R1, [R3]

    ; Stop here
DONE:
    B DONE
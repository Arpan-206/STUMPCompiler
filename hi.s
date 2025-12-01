ORG 0x0000
    ; Temporary storage for macro register save/restore
TEMP1:    DEFW 0
TEMP2:    DEFW 0
TEMP3:    DEFW 0
TEMP4:    DEFW 0
TEMP5:    DEFW 0
TEMP6:    DEFW 0
    B START

; Memory addresses
LCD_BASE:     DEFW 0xFF40
RTC_SECONDS:  DEFW 0xFF98
RTC_MINUTES:  DEFW 0xFF99
RTC_HOURS:    DEFW 0xFF9A
RTC_DAY:      DEFW 0xFF9B
RTC_DATE:     DEFW 0xFF9C
RTC_MONTH:    DEFW 0xFF9D
RTC_YEAR:     DEFW 0xFF9E
RTC_CONTROL:  DEFW 0xFF9F

START:
    ; Clear the LCD display
; Clear LCD
    ST R1, TEMP1
    ST R2, TEMP2
    ST R3, TEMP3
    LD R2, LCD_BASE
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32 (space)
    MOV R3, #15
CLEAR_LOOP1_1:
    ST R1, [R2]
    ADD R2, R2, #1
    SUB R3, R3, #1
    BNE CLEAR_LOOP1_1
    MOV R3, #5
CLEAR_LOOP2_1:
    ST R1, [R2]
    ADD R2, R2, #1
    SUB R3, R3, #1
    BNE CLEAR_LOOP2_1
    LD R1, TEMP1
    LD R2, TEMP2
    LD R3, TEMP3

    ; Display "Clock v1.0" on first line
; Print string: "   CLOCK v1.0   "
    ST R1, TEMP1
    ST R3, TEMP3
    LD R2, LCD_BASE
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, TEMP1
    LD R1, [R3]
    ST R1, [R2]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #1
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #2
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #3  ; 67
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #3
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #12  ; 76
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #4
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #15  ; 79
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #5
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #3  ; 67
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #6
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #11  ; 75
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #7
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #8
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15  ; 30
    ADD R1, R1, #15  ; 45
    ADD R1, R1, #15  ; 60
    ADD R1, R1, #15  ; 75
    ADD R1, R1, #15  ; 90
    ADD R1, R1, #15  ; 105
    ADD R1, R1, #13  ; 118
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #9
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, #1
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #10
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15  ; 30
    ADD R1, R1, #15  ; 45
    ADD R1, R1, #1  ; 46
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #11
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #12
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #13
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #14
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #15
    ST R1, [R3]
    LD R1, TEMP1
    LD R3, TEMP3

    ; Small startup delay
; Delay
    ST R5, TEMP5
    ST R6, TEMP6
    MOV R5, #15
DELAY_OUTER_2:
    MOV R6, #15
DELAY_INNER_2:
    SUB R6, R6, #1
    BNE DELAY_INNER_2
    SUB R5, R5, #1
    BNE DELAY_OUTER_2
    LD R5, TEMP5
    LD R6, TEMP6

MAIN_LOOP:
    ; Read current time from RTC
    ; Stores: hours->R10, minutes->R11, seconds->R12
; Read from RTC
    LD R2, RTC_CONTROL
    MOV R1, #1          ; Set Read Enable
    ST R1, [R2]
RTC_WAIT:
    LD R1, [R2]
    MOV R3, #2
    AND R3, R1, R3      ; Check Busy flag (bit 1)
    BNE RTC_WAIT
    ; Read complete, clear Read Enable
    MOV R1, #0
    ST R1, [R2]
    ; Load time values
    LD R2, RTC_HOURS
    LD R3, [R2]        ; R3 = hours (BCD)
    LD R2, RTC_MINUTES
    LD R4, [R2]        ; R4 = minutes (BCD)
    LD R2, RTC_SECONDS
    LD R5, [R2]        ; R5 = seconds (BCD)

    ; Display "Time: " label on second line
    LD R2, LCD_BASE
    MOV R3, #15
    ADD R2, R2, R3
    ADD R2, R2, #5      ; R2 now points to LCD line 2 (offset 20)
; Print string: "Time: "
    ST R1, TEMP1
    ST R3, TEMP3
    LD R2, LCD_BASE
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #10
    ADD R1, R1, R1  ; 20
    ADD R1, R1, R1  ; 40
    ADD R1, R1, R1  ; 80
    ADD R1, R1, #4  ; 84
    LD R3, TEMP1
    LD R1, [R3]
    ST R1, [R2]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #9  ; 105
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #1
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #13  ; 109
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #2
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #5  ; 101
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #3
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #4
    ST R1, [R3]
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #5
    ST R1, [R3]
    LD R1, TEMP1
    LD R3, TEMP3

    ; Now display the actual time using the BCD values
    ; Get LCD position after "Time: " (offset 26)
    LD R2, LCD_BASE
    MOV R3, #15
    ADD R2, R2, R3
    ADD R2, R2, #11     ; Position after "Time: "

    ; Display hours (R10 contains BCD hours)
; ERROR: Forbidden register used in @DISPLAY_BCD_BYTE: R10, R2

    ; Display first colon
    ST R1, TEMP1
    ST R3, TEMP3
; Print ':'
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #2
    ST R1, [R3]
    LD R1, TEMP1
    LD R3, TEMP3

    ; Display minutes (R11 contains BCD minutes)
; ERROR: Forbidden register used in @DISPLAY_BCD_BYTE: R11, R2

    ; Display second colon
    ST R1, TEMP1
    ST R3, TEMP3
; Print ':'
    LD R3, TEMP1
    ST R1, [R3]
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    LD R3, TEMP1
    LD R1, [R3]
    ADD R3, R2, #5
    ST R1, [R3]
    LD R1, TEMP1
    LD R3, TEMP3

    ; Display seconds (R12 contains BCD seconds)
; ERROR: Forbidden register used in @DISPLAY_BCD_BYTE: R12, R2

    ; Short delay before next update
; Delay
    ST R5, TEMP5
    ST R6, TEMP6
    MOV R5, #15
DELAY_OUTER_3:
    MOV R6, #15
DELAY_INNER_3:
    SUB R6, R6, #1
    BNE DELAY_INNER_3
    SUB R5, R5, #1
    BNE DELAY_OUTER_3
    LD R5, TEMP5
    LD R6, TEMP6

    ; Loop forever
    B MAIN_LOOP

DONE:
    B DONE
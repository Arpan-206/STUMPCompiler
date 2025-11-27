ORG 0x0000
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
    LD R2, LCD_BASE
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32 (space)
    MOV R3, #15
CLEAR_LOOP1:
    ST R1, [R2]
    ADD R2, R2, #1
    SUB R3, R3, #1
    BNE CLEAR_LOOP1
    MOV R3, #5
CLEAR_LOOP2:
    ST R1, [R2]
    ADD R2, R2, #1
    SUB R3, R3, #1
    BNE CLEAR_LOOP2

    ; Display "Clock v1.0" on first line
; Print string: "   CLOCK v1.0   "
    LD R2, LCD_BASE
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ST R1, [R2]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R3, R2, #1
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R3, R2, #2
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #3  ; 67
    ADD R3, R2, #3
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #12  ; 76
    ADD R3, R2, #4
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #15  ; 79
    ADD R3, R2, #5
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #3  ; 67
    ADD R3, R2, #6
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #11  ; 75
    ADD R3, R2, #7
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R3, R2, #8
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15  ; 30
    ADD R1, R1, #15  ; 45
    ADD R1, R1, #15  ; 60
    ADD R1, R1, #15  ; 75
    ADD R1, R1, #15  ; 90
    ADD R1, R1, #15  ; 105
    ADD R1, R1, #13  ; 118
    ADD R3, R2, #9
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, #1
    ADD R3, R2, #10
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15  ; 30
    ADD R1, R1, #15  ; 45
    ADD R1, R1, #1  ; 46
    ADD R3, R2, #11
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R3, R2, #12
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R3, R2, #13
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R3, R2, #14
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R3, R2, #15
    ST R1, [R3]

    ; Small startup delay
; Delay
    MOV R5, #15
DELAY_OUTER:
    MOV R6, #15
DELAY_INNER:
    SUB R6, R6, #1
    BNE DELAY_INNER
    SUB R5, R5, #1
    BNE DELAY_OUTER

MAIN_LOOP:
    ; Read current time from RTC
    ; Stores: hours->R10, minutes->R11, seconds->R12
; Read from RTC
    LD R8, RTC_CONTROL
    MOV R1, #1          ; Set Read Enable
    ST R1, [R8]
RTC_WAIT:
    LD R1, [R8]
    MOV R2, #2
    AND R2, R1, R2      ; Check Busy flag (bit 1)
    BNE RTC_WAIT
    ; Read complete, clear Read Enable
    MOV R1, #0
    ST R1, [R8]
    ; Load time values
    LD R8, RTC_HOURS
    LD R10, [R8]        ; R10 = hours (BCD)
    LD R8, RTC_MINUTES
    LD R11, [R8]        ; R11 = minutes (BCD)
    LD R8, RTC_SECONDS
    LD R12, [R8]        ; R12 = seconds (BCD)

    ; Display "Time: " label on second line
    LD R2, LCD_BASE
    MOV R3, #15
    ADD R2, R2, R3
    ADD R2, R2, #5      ; R2 now points to LCD line 2 (offset 20)
; Print string: "Time: "
    LD R2, LCD_BASE
    MOV R1, #10
    ADD R1, R1, R1  ; 20
    ADD R1, R1, R1  ; 40
    ADD R1, R1, R1  ; 80
    ADD R1, R1, #4  ; 84
    ST R1, [R2]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #9  ; 105
    ADD R3, R2, #1
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #13  ; 109
    ADD R3, R2, #2
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #5  ; 101
    ADD R3, R2, #3
    ST R1, [R3]
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    ADD R3, R2, #4
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R3, R2, #5
    ST R1, [R3]

    ; Now display the actual time using the BCD values
    ; Get LCD position after "Time: " (offset 26)
    LD R2, LCD_BASE
    MOV R3, #15
    ADD R2, R2, R3
    ADD R2, R2, #11     ; Position after "Time: "

    ; Display hours (R10 contains BCD hours)
; Display BCD byte from R10 at offset 0
    MOV R4, R10
    MOV R5, #0          ; Tens counter
TENS_LOOP_0:
    SUBS R0, R4, #15    ; Compare R4 with 15
    BLE TENS_DONE_0  ; If R4 <= 15, done
    SUB R4, R4, #15
    SUB R4, R4, #1      ; -16 total
    ADD R5, R5, #1
    B TENS_LOOP_0
TENS_DONE_0:
    ; Convert tens to ASCII
    MOV R1, #12
    ADD R1, R1, R1      ; 24
    ADD R1, R1, R1      ; 48 ('0')
    ADD R1, R1, R5      ; Add tens digit
    ADD R3, R2, #0
    ST R1, [R3]
    MOV R5, #15
    AND R5, R10, R5   ; Units digit
    ; Convert units to ASCII
    MOV R1, #12
    ADD R1, R1, R1      ; 24
    ADD R1, R1, R1      ; 48 ('0')
    ADD R1, R1, R5      ; Add units digit
    ADD R3, R2, #1
    ST R1, [R3]

    ; Display first colon
; Print ':'
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    ADD R3, R2, #2
    ST R1, [R3]

    ; Display minutes (R11 contains BCD minutes)
; Display BCD byte from R11 at offset 3
    MOV R4, R11
    MOV R5, #0          ; Tens counter
TENS_LOOP_1:
    SUBS R0, R4, #15    ; Compare R4 with 15
    BLE TENS_DONE_1  ; If R4 <= 15, done
    SUB R4, R4, #15
    SUB R4, R4, #1      ; -16 total
    ADD R5, R5, #1
    B TENS_LOOP_1
TENS_DONE_1:
    ; Convert tens to ASCII
    MOV R1, #12
    ADD R1, R1, R1      ; 24
    ADD R1, R1, R1      ; 48 ('0')
    ADD R1, R1, R5      ; Add tens digit
    ADD R3, R2, #3
    ST R1, [R3]
    MOV R5, #15
    AND R5, R11, R5   ; Units digit
    ; Convert units to ASCII
    MOV R1, #12
    ADD R1, R1, R1      ; 24
    ADD R1, R1, R1      ; 48 ('0')
    ADD R1, R1, R5      ; Add units digit
    ADD R3, R2, #4
    ST R1, [R3]

    ; Display second colon
; Print ':'
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    ADD R3, R2, #5
    ST R1, [R3]

    ; Display seconds (R12 contains BCD seconds)
; Display BCD byte from R12 at offset 6
    MOV R4, R12
    MOV R5, #0          ; Tens counter
TENS_LOOP_2:
    SUBS R0, R4, #15    ; Compare R4 with 15
    BLE TENS_DONE_2  ; If R4 <= 15, done
    SUB R4, R4, #15
    SUB R4, R4, #1      ; -16 total
    ADD R5, R5, #1
    B TENS_LOOP_2
TENS_DONE_2:
    ; Convert tens to ASCII
    MOV R1, #12
    ADD R1, R1, R1      ; 24
    ADD R1, R1, R1      ; 48 ('0')
    ADD R1, R1, R5      ; Add tens digit
    ADD R3, R2, #6
    ST R1, [R3]
    MOV R5, #15
    AND R5, R12, R5   ; Units digit
    ; Convert units to ASCII
    MOV R1, #12
    ADD R1, R1, R1      ; 24
    ADD R1, R1, R1      ; 48 ('0')
    ADD R1, R1, R5      ; Add units digit
    ADD R3, R2, #7
    ST R1, [R3]

    ; Short delay before next update
; Delay
    MOV R5, #15
DELAY_OUTER:
    MOV R6, #15
DELAY_INNER:
    SUB R6, R6, #1
    BNE DELAY_INNER
    SUB R5, R5, #1
    BNE DELAY_OUTER

    ; Loop forever
    B MAIN_LOOP

DONE:
    B DONE
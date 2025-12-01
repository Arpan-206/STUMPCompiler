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
__TMP_R1_2:    DEFW 0
    LD R4, __TMP_R1_2
    ST R1, [R4]
__TMP_R2_2:    DEFW 0
    LD R4, __TMP_R2_2
    ST R2, [R4]
__TMP_R3_2:    DEFW 0
    LD R4, __TMP_R3_2
    ST R3, [R4]
__PTR_LCD_BASE_3:    DEFW LCD_BASE
    LD R2, __PTR_LCD_BASE_3
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
    LD R4, __TMP_R1_2
    LD R1, [R4]
    LD R4, __TMP_R2_2
    LD R2, [R4]
    LD R4, __TMP_R3_2
    LD R3, [R4]

    ; Display "Clock v1.0" on first line
; Print string: "   CLOCK v1.0   "
__TMP_R1_4:    DEFW 0
    LD R4, __TMP_R1_4
    ST R1, [R4]
__TMP_R3_4:    DEFW 0
    LD R4, __TMP_R3_4
    ST R3, [R4]
__PTR_LCD_BASE_5:    DEFW LCD_BASE
    LD R2, __PTR_LCD_BASE_5
__TMP_R1_6:    DEFW 0
    LD R3, __TMP_R1_6
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, __TMP_R1_6
    LD R1, [R3]
    ST R1, [R2]
__TMP_R1_7:    DEFW 0
    LD R3, __TMP_R1_7
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, __TMP_R1_7
    LD R1, [R3]
    ADD R3, R2, #1
    ST R1, [R3]
__TMP_R1_8:    DEFW 0
    LD R3, __TMP_R1_8
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, __TMP_R1_8
    LD R1, [R3]
    ADD R3, R2, #2
    ST R1, [R3]
__TMP_R1_9:    DEFW 0
    LD R3, __TMP_R1_9
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #3  ; 67
    LD R3, __TMP_R1_9
    LD R1, [R3]
    ADD R3, R2, #3
    ST R1, [R3]
__TMP_R1_10:    DEFW 0
    LD R3, __TMP_R1_10
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #12  ; 76
    LD R3, __TMP_R1_10
    LD R1, [R3]
    ADD R3, R2, #4
    ST R1, [R3]
__TMP_R1_11:    DEFW 0
    LD R3, __TMP_R1_11
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #15  ; 79
    LD R3, __TMP_R1_11
    LD R1, [R3]
    ADD R3, R2, #5
    ST R1, [R3]
__TMP_R1_12:    DEFW 0
    LD R3, __TMP_R1_12
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #3  ; 67
    LD R3, __TMP_R1_12
    LD R1, [R3]
    ADD R3, R2, #6
    ST R1, [R3]
__TMP_R1_13:    DEFW 0
    LD R3, __TMP_R1_13
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    ADD R1, R1, R1  ; 64
    ADD R1, R1, #11  ; 75
    LD R3, __TMP_R1_13
    LD R1, [R3]
    ADD R3, R2, #7
    ST R1, [R3]
__TMP_R1_14:    DEFW 0
    LD R3, __TMP_R1_14
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, __TMP_R1_14
    LD R1, [R3]
    ADD R3, R2, #8
    ST R1, [R3]
__TMP_R1_15:    DEFW 0
    LD R3, __TMP_R1_15
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15  ; 30
    ADD R1, R1, #15  ; 45
    ADD R1, R1, #15  ; 60
    ADD R1, R1, #15  ; 75
    ADD R1, R1, #15  ; 90
    ADD R1, R1, #15  ; 105
    ADD R1, R1, #13  ; 118
    LD R3, __TMP_R1_15
    LD R1, [R3]
    ADD R3, R2, #9
    ST R1, [R3]
__TMP_R1_16:    DEFW 0
    LD R3, __TMP_R1_16
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, #1
    LD R3, __TMP_R1_16
    LD R1, [R3]
    ADD R3, R2, #10
    ST R1, [R3]
__TMP_R1_17:    DEFW 0
    LD R3, __TMP_R1_17
    ST R1, [R3]
    MOV R1, #15
    ADD R1, R1, #15  ; 30
    ADD R1, R1, #15  ; 45
    ADD R1, R1, #1  ; 46
    LD R3, __TMP_R1_17
    LD R1, [R3]
    ADD R3, R2, #11
    ST R1, [R3]
__TMP_R1_18:    DEFW 0
    LD R3, __TMP_R1_18
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    LD R3, __TMP_R1_18
    LD R1, [R3]
    ADD R3, R2, #12
    ST R1, [R3]
__TMP_R1_19:    DEFW 0
    LD R3, __TMP_R1_19
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, __TMP_R1_19
    LD R1, [R3]
    ADD R3, R2, #13
    ST R1, [R3]
__TMP_R1_20:    DEFW 0
    LD R3, __TMP_R1_20
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, __TMP_R1_20
    LD R1, [R3]
    ADD R3, R2, #14
    ST R1, [R3]
__TMP_R1_21:    DEFW 0
    LD R3, __TMP_R1_21
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, __TMP_R1_21
    LD R1, [R3]
    ADD R3, R2, #15
    ST R1, [R3]
    LD R4, __TMP_R1_4
    LD R1, [R4]
    LD R4, __TMP_R3_4
    LD R3, [R4]

    ; Small startup delay
; Delay
__TMP_R5_23:    DEFW 0
    LD R3, __TMP_R5_23
    ST R5, [R3]
__TMP_R6_23:    DEFW 0
    LD R3, __TMP_R6_23
    ST R6, [R3]
    MOV R5, #15
DELAY_OUTER_22:
    MOV R6, #15
DELAY_INNER_22:
    SUB R6, R6, #1
    BNE DELAY_INNER_22
    SUB R5, R5, #1
    BNE DELAY_OUTER_22
    LD R3, __TMP_R5_23
    LD R5, [R3]
    LD R3, __TMP_R6_23
    LD R6, [R3]

MAIN_LOOP:
    ; Read current time from RTC
    ; Stores: hours->R10, minutes->R11, seconds->R12
; Read from RTC
__PTR_RTC_CONTROL_24:    DEFW RTC_CONTROL
    LD R2, __PTR_RTC_CONTROL_24
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
__PTR_RTC_HOURS_25:    DEFW RTC_HOURS
    LD R2, __PTR_RTC_HOURS_25
    LD R3, [R2]        ; R3 = hours (BCD)
__PTR_RTC_MINUTES_26:    DEFW RTC_MINUTES
    LD R2, __PTR_RTC_MINUTES_26
    LD R4, [R2]        ; R4 = minutes (BCD)
__PTR_RTC_SECONDS_27:    DEFW RTC_SECONDS
    LD R2, __PTR_RTC_SECONDS_27
    LD R5, [R2]        ; R5 = seconds (BCD)

    ; Display "Time: " label on second line
    LD R2, LCD_BASE
    MOV R3, #15
    ADD R2, R2, R3
    ADD R2, R2, #5      ; R2 now points to LCD line 2 (offset 20)
; Print string: "Time: "
__TMP_R1_28:    DEFW 0
    LD R4, __TMP_R1_28
    ST R1, [R4]
__TMP_R3_28:    DEFW 0
    LD R4, __TMP_R3_28
    ST R3, [R4]
__PTR_LCD_BASE_29:    DEFW LCD_BASE
    LD R2, __PTR_LCD_BASE_29
__TMP_R1_30:    DEFW 0
    LD R3, __TMP_R1_30
    ST R1, [R3]
    MOV R1, #10
    ADD R1, R1, R1  ; 20
    ADD R1, R1, R1  ; 40
    ADD R1, R1, R1  ; 80
    ADD R1, R1, #4  ; 84
    LD R3, __TMP_R1_30
    LD R1, [R3]
    ST R1, [R2]
__TMP_R1_31:    DEFW 0
    LD R3, __TMP_R1_31
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #9  ; 105
    LD R3, __TMP_R1_31
    LD R1, [R3]
    ADD R3, R2, #1
    ST R1, [R3]
__TMP_R1_32:    DEFW 0
    LD R3, __TMP_R1_32
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #13  ; 109
    LD R3, __TMP_R1_32
    LD R1, [R3]
    ADD R3, R2, #2
    ST R1, [R3]
__TMP_R1_33:    DEFW 0
    LD R3, __TMP_R1_33
    ST R1, [R3]
    MOV R1, #12
    ADD R1, R1, R1  ; 24
    ADD R1, R1, R1  ; 48
    ADD R1, R1, R1  ; 96
    ADD R1, R1, #5  ; 101
    LD R3, __TMP_R1_33
    LD R1, [R3]
    ADD R3, R2, #3
    ST R1, [R3]
__TMP_R1_34:    DEFW 0
    LD R3, __TMP_R1_34
    ST R1, [R3]
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    LD R3, __TMP_R1_34
    LD R1, [R3]
    ADD R3, R2, #4
    ST R1, [R3]
__TMP_R1_35:    DEFW 0
    LD R3, __TMP_R1_35
    ST R1, [R3]
    MOV R1, #8
    ADD R1, R1, R1  ; 16
    ADD R1, R1, R1  ; 32
    LD R3, __TMP_R1_35
    LD R1, [R3]
    ADD R3, R2, #5
    ST R1, [R3]
    LD R4, __TMP_R1_28
    LD R1, [R4]
    LD R4, __TMP_R3_28
    LD R3, [R4]

    ; Now display the actual time using the BCD values
    ; Get LCD position after "Time: " (offset 26)
    LD R2, LCD_BASE
    MOV R3, #15
    ADD R2, R2, R3
    ADD R2, R2, #11     ; Position after "Time: "

    ; Display hours (R10 contains BCD hours)
; ERROR: Forbidden register used in @DISPLAY_BCD_BYTE: R10, R2

    ; Display first colon
__TMP_R1_36:    DEFW 0
    LD R4, __TMP_R1_36
    ST R1, [R4]
__TMP_R3_36:    DEFW 0
    LD R4, __TMP_R3_36
    ST R3, [R4]
; Print ':'
__TMP_R1_37:    DEFW 0
    LD R3, __TMP_R1_37
    ST R1, [R3]
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    LD R3, __TMP_R1_37
    LD R1, [R3]
    ADD R3, R2, #2
    ST R1, [R3]
    LD R4, __TMP_R1_36
    LD R1, [R4]
    LD R4, __TMP_R3_36
    LD R3, [R4]

    ; Display minutes (R11 contains BCD minutes)
; ERROR: Forbidden register used in @DISPLAY_BCD_BYTE: R11, R2

    ; Display second colon
__TMP_R1_38:    DEFW 0
    LD R4, __TMP_R1_38
    ST R1, [R4]
__TMP_R3_38:    DEFW 0
    LD R4, __TMP_R3_38
    ST R3, [R4]
; Print ':'
__TMP_R1_39:    DEFW 0
    LD R3, __TMP_R1_39
    ST R1, [R3]
    MOV R1, #14
    ADD R1, R1, R1  ; 28
    ADD R1, R1, R1  ; 56
    ADD R1, R1, #2  ; 58
    LD R3, __TMP_R1_39
    LD R1, [R3]
    ADD R3, R2, #5
    ST R1, [R3]
    LD R4, __TMP_R1_38
    LD R1, [R4]
    LD R4, __TMP_R3_38
    LD R3, [R4]

    ; Display seconds (R12 contains BCD seconds)
; ERROR: Forbidden register used in @DISPLAY_BCD_BYTE: R12, R2

    ; Short delay before next update
; Delay
__TMP_R5_41:    DEFW 0
    LD R3, __TMP_R5_41
    ST R5, [R3]
__TMP_R6_41:    DEFW 0
    LD R3, __TMP_R6_41
    ST R6, [R3]
    MOV R5, #15
DELAY_OUTER_40:
    MOV R6, #15
DELAY_INNER_40:
    SUB R6, R6, #1
    BNE DELAY_INNER_40
    SUB R5, R5, #1
    BNE DELAY_OUTER_40
    LD R3, __TMP_R5_41
    LD R5, [R3]
    LD R3, __TMP_R6_41
    LD R6, [R3]

    ; Loop forever
    B MAIN_LOOP

DONE:
    B DONE
# STUMP Macro Compiler — Available Macros

This document lists all macros currently implemented in `stump.py`, their usage, arguments, side-effects and small examples.

**Notes / global constraints**
- Registers: `R0` is fixed to `0x0000` (read-only), `R7` is the program counter (PC) and must not be used. Only `R1`–`R6` are safe for temporary use inside macros. `R8`–`R15` are invalid for general use.
- Temporary memory: macros save/restore registers to `TEMP1`..`TEMP6`. Your assembly should define these memory locations.
- When a macro detects a forbidden register (e.g. `R0`, `R7`, or `R8`–`R15`) it emits a comment starting with `; ERROR:` in the expanded output.

---

## @PRINT_STRING
- **Syntax:** `@PRINT_STRING "<string>" <lcd_reg>`
- **Description:** Writes the given ASCII string into the LCD memory starting at the address loaded into `<lcd_reg>`.
- **Arguments:**
  - **string**: quoted string literal (double quotes) to print.
  - **lcd_reg**: register name (e.g. `R2`) which the macro will load with `LCD_BASE` and then use to write characters.
- **Side-effects / clobbers:** Saves/restores `R1` and `R3` via `TEMP1`/`TEMP3`; uses `build_value` (which itself saves/restores the register it uses).
- **Example:**
  - `@PRINT_STRING "HELLO" R2`

---

## @PRINT_CHAR
- **Syntax:** `@PRINT_CHAR '<char>' <lcd_reg> <offset>`
- **Description:** Writes a single character to the LCD at base address in `<lcd_reg>` plus `<offset>`.
- **Arguments:**
  - **char**: a single character enclosed in single quotes (e.g. `'A'`) or a register/value.
  - **lcd_reg**: register name to hold LCD base pointer.
  - **offset**: integer offset from the LCD base where the character should be stored.
- **Side-effects / clobbers:** Saves/restores `R1` and `R3` via `TEMP1`/`TEMP3`.
- **Example:**
  - `@PRINT_CHAR 'A' R2 0`  — place `A` at the first LCD character position.

---

## @NUM_TO_ASCII
- **Syntax:** `@NUM_TO_ASCII <number> <dest_reg>`
- **Description:** Convert a small integer to its ASCII code (by adding to base `'0'`) and place result in `<dest_reg>`.
- **Arguments:**
  - **number**: immediate (e.g. `#5`) or register containing numeric value.
  - **dest_reg**: destination register to receive ASCII code.
- **Side-effects / clobbers:** Uses `R6` internally to build base `'0'` constant; does not explicitly save/restore `dest_reg`.
- **Example:**
  - `@NUM_TO_ASCII #7 R3`

---

## @CLEAR_LCD
- **Syntax:** `@CLEAR_LCD`
- **Description:** Clears the LCD by writing space (ASCII 32) to the entire LCD memory area.
- **Arguments:** None.
- **Side-effects / clobbers:** Saves/restores `R1`, `R2`, `R3` to `TEMP1`..`TEMP3` while iterating.
- **Example:**
  - `@CLEAR_LCD`

---

## @DELAY
- **Syntax:** `@DELAY`
- **Description:** Inserts a nested-loop software delay.
- **Arguments:** None.
- **Side-effects / clobbers:** Saves/restores `R5` and `R6` to `TEMP5`/`TEMP6`.
- **Example:**
  - `@DELAY`

---

## @RTC_READ
- **Syntax:** `@RTC_READ`
- **Description:** Reads the real-time-clock (RTC) device through control register operations and loads the BCD time values into registers.
- **Behavior (as implemented):** Loads RTC control, sets a read enable, waits for completion, clears enable, then loads from `RTC_HOURS`, `RTC_MINUTES`, `RTC_SECONDS` memory addresses and places the values in registers:
  - `R3` = hours (BCD)
  - `R4` = minutes (BCD)
  - `R5` = seconds (BCD)
- **Arguments:** None.
- **Side-effects / clobbers:** Uses `R1`..`R5` inside the sequence; it's not written to save/restore all of them in this macro.
- **Example:**
  - `@RTC_READ`

---

## @BCD_TO_DIGITS
- **Syntax:** `@BCD_TO_DIGITS <bcd_reg> <tens_reg> <units_reg>`
- **Description:** Convert a BCD byte in `<bcd_reg>` to two decimal digit values placed in `<tens_reg>` and `<units_reg>`.
- **Arguments:**
  - **bcd_reg**: register containing BCD byte.
  - **tens_reg**: register to receive tens digit.
  - **units_reg**: register to receive units digit.
- **Validation:** Macro rejects forbidden registers (`R0`, `R7`, `R8`–`R15`) and will emit `; ERROR:` if used.
- **Side-effects / clobbers:** Uses internal label counters for loops and modifies the BCD register during conversion; caller should ensure the BCD source can be clobbered or use a copy.
- **Example:**
  - `@BCD_TO_DIGITS R4 R2 R3`  — convert BCD in `R4` to tens in `R2` and units in `R3`.

---

## @DISPLAY_BCD_BYTE
- **Syntax:** `@DISPLAY_BCD_BYTE <bcd_reg> <lcd_reg> <offset>`
- **Description:** Convert a BCD byte in `<bcd_reg>` and write two ASCII digits into the LCD at `<lcd_reg>` with given offset.
- **Arguments:**
  - **bcd_reg**: register with BCD byte
  - **lcd_reg**: register holding LCD base pointer
  - **offset**: numeric offset (0..15) where tens digit is written; units placed at `offset+1`
- **Validation:** Rejects forbidden registers (emits `; ERROR:`).
- **Side-effects / clobbers:** Uses `R1`, `R3`, `R4`, `R5` internally and the macro increments a label counter for local loop labels.
- **Example:**
  - `@DISPLAY_BCD_BYTE R4 R2 3` — display BCD in `R4` starting at LCD position `R2+3`.

---

## @DISPLAY_TIME
- **Syntax:** `@DISPLAY_TIME`
- **Description:** High-level macro intended to display `HH:MM:SS` on the LCD. It delegates to `@DISPLAY_BCD_BYTE` for each BCD field and writes `:` separators.
- **Arguments:** None.
- **Implementation note:** Current implementation calls `macro_display_bcd_byte` with registers `R10`, `R11`, `R12` (for hours/mins/secs respectively). These registers are outside the allowed `R1`–`R6` range and are therefore invalid for real STUMP use — the call will produce either incorrect code or error comments depending on register validation. This macro needs updating to use valid registers or to accept destination registers as parameters.
- **Side-effects / clobbers:** See `@DISPLAY_BCD_BYTE` and the note above.
- **Example:**
  - `@DISPLAY_TIME` (but be aware of the invalid-registers issue in the current implementation)

---

## Implementation helpers (not macros)
- `build_value(value, reg)` — helper that builds an immediate numeric value into `reg` using only valid registers and saving/restoring the used register to `TEMPx`. Macros call this to construct ASCII codes and other immediates.
- `_increment_label()` — helper for making unique local labels (increments `label_counter`).

---

## Quick usage notes / recommendations
- Ensure your assembly defines `TEMP1`..`TEMP6` memory words (used to save registers) and hardware labels used by macros (e.g. `LCD_BASE`, `RTC_CONTROL`, `RTC_HOURS`, `RTC_MINUTES`, `RTC_SECONDS`).
- Prefer passing registers from the caller to control where values land (so caller can preserve critical registers). Many macros attempt to save used temporaries but some higher-level macros still clobber registers.
- `@DISPLAY_TIME` should be fixed before use (it currently references `R10`/`R11`/`R12` which are invalid on STUMP).

---

If you want, I will:
- Fix `@DISPLAY_TIME` to use only `R1`–`R6` (or accept destination registers as parameters).
- Add an example `hi.sasm` snippet that exercises each macro and an expanded `hi.s` result.
- Generate a small test harness that runs the macro expansion on the examples.

Which of these should I do next?
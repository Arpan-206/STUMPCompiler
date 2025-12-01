#!/usr/bin/env python3
import re
import sys

class StumpMacroCompiler:
    def __init__(self):
        self.output = []
        self.label_counter = 0
        
    def process_file(self, filename):
        """Process a .sasm file (STUMP assembly with macros)"""
        with open(filename, 'r') as f:
            lines = f.readlines()
        
        # Expand macros
        expanded = self.expand_macros(lines)
        # Ensure TEMP1..TEMP6 are defined somewhere in the output. Many macros
        # rely on these memory locations to save/restore registers. If the
        # user's input didn't define them, insert definitions after the ORG
        # directive (or at top) so the assembler won't complain.
        joined = '\n'.join(expanded)
        # Check which TEMP labels are actually defined (look for label definitions
        # like "TEMP1:"). Users may reference TEMP1 in code; we must only add
        # DEFW definitions when a TEMP label is not already defined. This avoids
        # inserting duplicates and ensures missing temps are created.
        missing = []
        for i in range(1, 7):
            if not re.search(rf'^\s*TEMP{i}:', joined, re.M):
                missing.append(i)

        if missing:
            temp_defs = ["    ; Temporary storage for macro register save/restore"]
            for i in missing:
                temp_defs.append(f"TEMP{i}:    DEFW 0")

            # Find ORG line to insert after, else prepend
            insert_at = 0
            for idx, l in enumerate(expanded):
                if l.strip().upper().startswith('ORG'):
                    insert_at = idx + 1
                    break
            for i, d in enumerate(temp_defs):
                expanded.insert(insert_at + i, d)

        return '\n'.join(expanded)
    
    def expand_macros(self, lines):
        """Expand all macro calls"""
        expanded = []
        
        for line in lines:
            stripped = line.strip()
            
            # Skip comments and empty lines
            if not stripped or stripped.startswith(';'):
                expanded.append(line.rstrip())
                continue
            
            # Check for macro calls
            if stripped.startswith('@'):
                expanded.extend(self.handle_macro(stripped))
            else:
                expanded.append(line.rstrip())
        
        return expanded
    
    def handle_macro(self, line):
        """Handle macro expansion"""
        # Parse macro and arguments
        match = re.match(r'@(\w+)\s*(.*)', line)
        if not match:
            return [f"; Error parsing macro: {line}"]
        
        macro_name = match.group(1)
        args_str = match.group(2).strip()
        
        # Parse arguments - handle quoted strings
        args = []
        if args_str:
            if '"' in args_str:
                # Extract quoted string and other args
                quote_start = args_str.index('"')
                quote_end = args_str.index('"', quote_start + 1)
                string_arg = args_str[quote_start + 1:quote_end]
                args.append(string_arg)
                # Get remaining args
                remaining = args_str[quote_end + 1:].strip()
                if remaining:
                    args.extend(remaining.split())
            else:
                args = args_str.split()
        
        # Dispatch to appropriate macro handler
        if macro_name == 'PRINT_STRING':
            return self.macro_print_string(args)
        elif macro_name == 'PRINT_CHAR':
            return self.macro_print_char(args)
        elif macro_name == 'NUM_TO_ASCII':
            return self.macro_num_to_ascii(args)
        elif macro_name == 'CLEAR_LCD':
            return self.macro_clear_lcd(args)
        elif macro_name == 'DELAY':
            return self.macro_delay(args)
        elif macro_name == 'RTC_READ':
            return self.macro_rtc_read(args)
        elif macro_name == 'BCD_TO_DIGITS':
            return self.macro_bcd_to_digits(args)
        elif macro_name == 'DISPLAY_TIME':
            return self.macro_display_time(args)
        elif macro_name == 'DISPLAY_BCD_BYTE':
            return self.macro_display_bcd_byte(args)
        else:
            return [f"; Unknown macro: {macro_name}"]
    
    def build_value(self, value, reg):
        """Build any 8-bit value in a register"""
        result = []
        
        # Never use R0, R7, or R8–R15 for value building
        invalid_regs = ["R0", "R7"] + [f"R{i}" for i in range(8, 16)]
        if reg in invalid_regs:
            result.append(f"; ERROR: Attempt to use forbidden register {reg}")
            return result

        # Save register to memory before use using a local temp pair so loads/stores
        # reference a nearby label (avoids assembler offset-range errors).
        if reg in ["R1", "R2", "R3", "R4", "R5", "R6"]:
            prologue, epilogue = self.save_restore_pair([reg])
            result.extend(prologue)

        if value <= 15:
            result.append(f"    MOV {reg}, #{value}")
        elif value <= 30:
            result.append(f"    MOV {reg}, #15")
            result.append(f"    ADD {reg}, {reg}, #{value - 15}")
        else:
            # Build value step by step
            if value == 32:  # Space
                result.append(f"    MOV {reg}, #8")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 16")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 32")
            elif value == 48:  # '0'
                result.append(f"    MOV {reg}, #12")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 24")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 48")
            elif value >= 49 and value <= 57:  # '1'-'9'
                result.append(f"    MOV {reg}, #12")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 24")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 48")
                result.append(f"    ADD {reg}, {reg}, #{value - 48}")
            elif value == 58:  # ':'
                result.append(f"    MOV {reg}, #14")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 28")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 56")
                result.append(f"    ADD {reg}, {reg}, #2  ; 58")
            elif value >= 65 and value <= 80:  # 'A'-'P'
                result.append(f"    MOV {reg}, #8")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 16")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 32")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 64")
                remainder = value - 64
                if remainder <= 15:
                    result.append(f"    ADD {reg}, {reg}, #{remainder}  ; {value}")
                else:
                    result.append(f"    ADD {reg}, {reg}, #15  ; 79")
                    result.append(f"    ADD {reg}, {reg}, #{remainder - 15}  ; {value}")
            elif value >= 81 and value <= 95:  # 'Q'-'_'
                result.append(f"    MOV {reg}, #10")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 20")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 40")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 80")
                remainder = value - 80
                if remainder <= 15:
                    result.append(f"    ADD {reg}, {reg}, #{remainder}  ; {value}")
                else:
                    result.append(f"    ADD {reg}, {reg}, #15  ; 95")
                    result.append(f"    ADD {reg}, {reg}, #{remainder - 15}  ; {value}")
            elif value >= 97 and value <= 112:  # 'a'-'p'
                result.append(f"    MOV {reg}, #12")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 24")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 48")
                result.append(f"    ADD {reg}, {reg}, {reg}  ; 96")
                remainder = value - 96
                if remainder <= 15:
                    result.append(f"    ADD {reg}, {reg}, #{remainder}  ; {value}")
                else:
                    result.append(f"    ADD {reg}, {reg}, #15  ; 111")
                    result.append(f"    ADD {reg}, {reg}, #{remainder - 15}  ; {value}")
            else:
                # Generic approach
                current = 0
                result.append(f"    MOV {reg}, #15")
                current = 15
                while current < value:
                    if value - current <= 15:
                        result.append(f"    ADD {reg}, {reg}, #{value - current}  ; {value}")
                        break
                    else:
                        result.append(f"    ADD {reg}, {reg}, #15  ; {current + 15}")
                        current += 15
        # Restore register from memory after use using the matching epilogue
        if reg in ["R1", "R2", "R3", "R4", "R5", "R6"]:
            result.extend(epilogue)
        return result

    # --- Register save/restore helpers ---
    def reg_is_forbidden(self, reg):
        invalid_regs = ["R0", "R7"] + [f"R{i}" for i in range(8, 16)]
        return reg in invalid_regs

    def reg_to_temp(self, reg):
        mapping = {"R1": "TEMP1", "R2": "TEMP2", "R3": "TEMP3", "R4": "TEMP4", "R5": "TEMP5", "R6": "TEMP6"}
        return mapping.get(reg)

    def _pick_scratch(self, avoid_regs):
        """Pick a scratch register not in avoid_regs and not forbidden."""
        candidates = [f"R{i}" for i in range(3, 7)] + ["R1", "R2"]
        for c in candidates:
            if c not in avoid_regs and not self.reg_is_forbidden(c):
                return c
        # Fallback (shouldn't happen in normal macro usage)
        return "R3"

    def save_regs(self, regs):
        """Return list of assembly lines that save each register in `regs` to its TEMPn.

        Uses an indirect store via a picked scratch register (LD scratch, TEMPn; ST reg, [scratch])
        to avoid assembler absolute-offset range issues.
        """
        lines = []
        avoid = set(regs)
        for reg in regs:
            temp = self.reg_to_temp(reg)
            if not temp:
                # Nothing to do for registers without TEMP mapping
                continue
            scratch = self._pick_scratch(avoid)
            # Each save uses its own scratch selection to ensure we don't clobber
            # a register that we're saving.
            lines.append(f"    LD {scratch}, {temp}")
            lines.append(f"    ST {reg}, [{scratch}]")
        return lines

    def save_restore_pair(self, regs):
        """Return (prologue_lines, epilogue_lines) that save and later restore regs.

        For each reg in regs this emits a local DEFW label immediately before the
        prologue so that subsequent `LD scratch, <label>` is PC-near and avoids
        assembler "offset out of range" errors. The epilogue contains matching
        LD/LD sequences to restore the registers.
        """
        lid = self._get_label_id()
        prologue = []
        epilogue = []
        avoid = set(regs)
        for reg in regs:
            temp_label = f"__TMP_{reg}_{lid}"
            # Define the temp word immediately so LD/ST are nearby
            prologue.append(f"{temp_label}:    DEFW 0")
            scratch = self._pick_scratch(avoid)
            prologue.append(f"    LD {scratch}, {temp_label}")
            prologue.append(f"    ST {reg}, [{scratch}]")
            # Epilogue restores in the same way
            scratch2 = self._pick_scratch(avoid)
            epilogue.append(f"    LD {scratch2}, {temp_label}")
            epilogue.append(f"    LD {reg}, [{scratch2}]")
        return prologue, epilogue

    def restore_regs(self, regs):
        """Return list of assembly lines that restore each register in `regs` from its TEMPn.

        Uses the same indirect addressing pattern as `save_regs`.
        """
        lines = []
        avoid = set(regs)
        for reg in regs:
            temp = self.reg_to_temp(reg)
            if not temp:
                continue
            scratch = self._pick_scratch(avoid)
            lines.append(f"    LD {scratch}, {temp}")
            lines.append(f"    LD {reg}, [{scratch}]")
        return lines

    # --- Offset helpers ---
    def offset_in_range(self, offset):
        """Return True if offset is within assembler immediate range (-16..15)."""
        return -16 <= offset <= 15

    def indexed_address_lines(self, base_reg, offset, addr_reg='R3'):
        """Return assembly lines that compute address (base_reg + offset) into addr_reg.

        If offset == 0, returns an empty list (caller can use [base_reg] directly).
        If offset positive, emits `ADD addr_reg, base_reg, #offset`.
        If offset negative, emits `SUB addr_reg, base_reg, #{-offset}`.
        Returns None if offset out of range.
        """
        if offset == 0:
            return []
        if not self.offset_in_range(offset):
            return None
        if offset > 0:
            return [f"    ADD {addr_reg}, {base_reg}, #{offset}"]
        else:
            return [f"    SUB {addr_reg}, {base_reg}, #{-offset}"]
    
    def macro_print_string(self, args):
        """Print string at LCD position"""
        if len(args) < 2:
            return ["; Error: @PRINT_STRING needs string and lcd_reg"]
        
        string = args[0]
        lcd_reg = args[1]
        
        result = [f"; Print string: \"{string}\""]
        # Save caller-volatile registers we will use (local temps)
        prologue, epilogue = self.save_restore_pair(["R1", "R3"])
        result.extend(prologue)
        result.append(f"    LD {lcd_reg}, LCD_BASE")

        for i, char in enumerate(string):
            ascii_val = ord(char)
            result.extend(self.build_value(ascii_val, 'R1'))
            if i == 0:
                result.append(f"    ST R1, [{lcd_reg}]")
            else:
                if i <= 15:
                    result.append(f"    ADD R3, {lcd_reg}, #{i}")
                    result.append(f"    ST R1, [R3]")
                else:
                    result.append(f"    ADD {lcd_reg}, {lcd_reg}, #1")
                    result.append(f"    ST R1, [{lcd_reg}]")
        result.extend(epilogue)
        return result
    
    def macro_print_char(self, args):
        """Print a single character"""
        if len(args) < 3:
            return ["; Error: @PRINT_CHAR needs char, lcd_reg, offset"]
        
        char = args[0]
        lcd_reg = args[1]
        offset = int(args[2])
        
        result = []
        # Save registers we'll use (local temps)
        prologue, epilogue = self.save_restore_pair(["R1", "R3"])
        result.extend(prologue)

        if char.startswith("'") and char.endswith("'"):
            ascii_val = ord(char[1])
            result.append(f"; Print '{char[1]}'")
            result.extend(self.build_value(ascii_val, 'R1'))
        else:
            result.append(f"    MOV R1, {char}")

        # Handle offset within assembler signed immediate range (-16..15)
        addr_lines = self.indexed_address_lines(lcd_reg, offset, addr_reg='R3')
        if addr_lines is None:
            result.append(f"; Offset {offset} out of range (-16..15)")
        else:
            if offset == 0:
                result.append(f"    ST R1, [{lcd_reg}]")
            else:
                result.extend(addr_lines)
                result.append(f"    ST R1, [R3]")

        result.extend(epilogue)
        return result
    
    def macro_num_to_ascii(self, args):
        """Convert number to ASCII digit"""
        if len(args) != 2:
            return ["; Error: @NUM_TO_ASCII needs number and dest_reg"]
        
        num = args[0]
        dest = args[1]
        
        result = [f"; Convert {num} to ASCII"]
        result.append(f"    MOV R6, #12")
        result.append(f"    ADD R6, R6, R6  ; 24")
        result.append(f"    ADD R6, R6, R6  ; 48")
        
        if num.startswith('#'):
            val = int(num[1:])
            if val <= 15:
                result.append(f"    ADD {dest}, R6, {num}")
            else:
                result.append(f"; Error: number too large")
        else:
            result.append(f"    ADD {dest}, R6, {num}")
        
        return result
    
    def macro_clear_lcd(self, args):
        """Clear LCD display"""
        lid = self._get_label_id()
        result = [
            "; Clear LCD",
        ]
        # Save registers we will clobber (local temps)
        prologue, epilogue = self.save_restore_pair(["R1", "R2", "R3"])
        result.extend(prologue)
        result.extend([
            "    LD R2, LCD_BASE",
            "    MOV R1, #8",
            "    ADD R1, R1, R1  ; 16",
            "    ADD R1, R1, R1  ; 32 (space)",
            "    MOV R3, #15",
            f"CLEAR_LOOP1_{lid}:",
            "    ST R1, [R2]",
            "    ADD R2, R2, #1",
            "    SUB R3, R3, #1",
            f"    BNE CLEAR_LOOP1_{lid}",
            "    MOV R3, #5",
            f"CLEAR_LOOP2_{lid}:",
            "    ST R1, [R2]",
            "    ADD R2, R2, #1",
            "    SUB R3, R3, #1",
            f"    BNE CLEAR_LOOP2_{lid}",
        ])
        # Restore saved registers
        result.extend(epilogue)
        return result
    
    def macro_delay(self, args):
        """Insert delay loop"""
        lid = self._get_label_id()
        result = [
            "; Delay",
        ]
        prologue, epilogue = self.save_restore_pair(["R5", "R6"])
        result.extend(prologue)
        result.extend([
            "    MOV R5, #15",
            f"DELAY_OUTER_{lid}:",
            "    MOV R6, #15",
            f"DELAY_INNER_{lid}:",
            "    SUB R6, R6, #1",
            f"    BNE DELAY_INNER_{lid}",
            "    SUB R5, R5, #1",
            f"    BNE DELAY_OUTER_{lid}",
        ])
        result.extend(epilogue)
        return result
    
    def macro_rtc_read(self, args):
        """Read from RTC - stores hours in R3, minutes in R4, seconds in R5"""
        return [
            "; Read from RTC",
            "    LD R2, RTC_CONTROL",
            "    MOV R1, #1          ; Set Read Enable",
            "    ST R1, [R2]",
            "RTC_WAIT:",
            "    LD R1, [R2]",
            "    MOV R3, #2",
            "    AND R3, R1, R3      ; Check Busy flag (bit 1)",
            "    BNE RTC_WAIT",
            "    ; Read complete, clear Read Enable",
            "    MOV R1, #0",
            "    ST R1, [R2]",
            "    ; Load time values",
            "    LD R2, RTC_HOURS",
            "    LD R3, [R2]        ; R3 = hours (BCD)",
            "    LD R2, RTC_MINUTES",
            "    LD R4, [R2]        ; R4 = minutes (BCD)",
            "    LD R2, RTC_SECONDS",
            "    LD R5, [R2]        ; R5 = seconds (BCD)"
        ]
    
    def macro_bcd_to_digits(self, args):
        """Convert BCD byte to two decimal digits
        Args: bcd_reg, tens_reg, units_reg"""
        if len(args) != 3:
            return ["; Error: @BCD_TO_DIGITS needs bcd_reg, tens_reg, units_reg"]
        
        bcd_reg = args[0]
        tens_reg = args[1]
        units_reg = args[2]
        # Prevent forbidden registers
        invalid_regs = ["R0", "R7"] + [f"R{i}" for i in range(8, 16)]
        if bcd_reg in invalid_regs or tens_reg in invalid_regs or units_reg in invalid_regs:
            return [f"; ERROR: Forbidden register used in @BCD_TO_DIGITS: {bcd_reg}, {tens_reg}, {units_reg}"]
        
        lid = self._get_label_id()
        return [
            f"; Convert BCD in {bcd_reg} to digits",
            f"    MOV {tens_reg}, {bcd_reg}",
            f"    MOV {units_reg}, #15",
            f"    AND {units_reg}, {bcd_reg}, {units_reg}  ; Units = bcd & 0x0F",
            "    ; Divide by 16 to get tens digit",
            f"    MOV {tens_reg}, #0",
            f"BCD_DIV_{lid}:",
            f"    SUBS R0, {bcd_reg}, #15  ; Compare with 15",
            f"    BLE BCD_DONE_{lid}  ; If <= 15, done",
            f"    SUB {bcd_reg}, {bcd_reg}, #15",
            f"    SUB {bcd_reg}, {bcd_reg}, #1    ; -16 total",
            f"    ADD {tens_reg}, {tens_reg}, #1",
            f"    B BCD_DIV_{lid}",
            f"BCD_DONE_{lid}:"
        ]
    
    def macro_display_bcd_byte(self, args):
        """Display a BCD byte as two digits at LCD position
        Args: bcd_reg, lcd_reg, offset"""
        if len(args) != 3:
            return ["; Error: @DISPLAY_BCD_BYTE needs bcd_reg, lcd_reg, offset"]
        
        bcd_reg = args[0]
        lcd_reg = args[1]
        offset = int(args[2])
        # Prevent forbidden registers
        invalid_regs = ["R0", "R7"] + [f"R{i}" for i in range(8, 16)]
        if bcd_reg in invalid_regs or lcd_reg in invalid_regs:
            return [f"; ERROR: Forbidden register used in @DISPLAY_BCD_BYTE: {bcd_reg}, {lcd_reg}"]
        
        lid = self._get_label_id()
        result = [f"; Display BCD byte from {bcd_reg} at offset {offset}"]
        
        # Extract tens digit (upper nibble)
        result += [
            f"    MOV R4, {bcd_reg}",
            "    MOV R5, #0          ; Tens counter",
            f"TENS_LOOP_{lid}:",
            "    SUBS R0, R4, #15    ; Compare R4 with 15",
            f"    BLE TENS_DONE_{lid}  ; If R4 <= 15, done",
            "    SUB R4, R4, #15",
            "    SUB R4, R4, #1      ; -16 total",
            "    ADD R5, R5, #1",
            f"    B TENS_LOOP_{lid}",
            f"TENS_DONE_{lid}:",
            "    ; Convert tens to ASCII",
            "    MOV R1, #12",
            "    ADD R1, R1, R1      ; 24",
            "    ADD R1, R1, R1      ; 48 ('0')",
            "    ADD R1, R1, R5      ; Add tens digit",
        ]
        
        # Store tens digit
        if offset <= 15:
            result.append(f"    ADD R3, {lcd_reg}, #{offset}")
            result.append(f"    ST R1, [R3]")
        else:
            result.append(f"; Offset too large")
        
        # Extract units digit (lower nibble)
        result += [
            f"    MOV R5, #15",
            f"    AND R5, {bcd_reg}, R5   ; Units digit",
            "    ; Convert units to ASCII",
            "    MOV R1, #12",
            "    ADD R1, R1, R1      ; 24",
            "    ADD R1, R1, R1      ; 48 ('0')",
            "    ADD R1, R1, R5      ; Add units digit",
        ]
        
        # Store units digit — validate offset+1 in range
        units_off = offset + 1
        addr_lines = self.indexed_address_lines(lcd_reg, units_off, addr_reg='R3')
        if addr_lines is None:
            result.append(f"; Offset {units_off} out of range (-16..15)")
        else:
            if units_off == 0:
                result.append(f"    ST R1, [{lcd_reg}]")
            else:
                result.extend(addr_lines)
                result.append(f"    ST R1, [R3]")
        return result
    
    def macro_display_time(self, args):
        """Display HH:MM:SS format on LCD"""
        return [
            "; Display time in HH:MM:SS format",
            "    LD R2, LCD_BASE",
            "    ; Display hours",
        ] + self.macro_display_bcd_byte(['R10', 'R2', '0']) + [
            "    ; Display colon",
            "    MOV R1, #14",
            "    ADD R1, R1, R1      ; 28",
            "    ADD R1, R1, R1      ; 56",
            "    ADD R1, R1, #2      ; 58 (':')",
            "    ADD R3, R2, #2",
            "    ST R1, [R3]",
            "    ; Display minutes",
        ] + self.macro_display_bcd_byte(['R11', 'R2', '3']) + [
            "    ; Display colon",
            "    MOV R1, #14",
            "    ADD R1, R1, R1      ; 28",
            "    ADD R1, R1, R1      ; 56",
            "    ADD R1, R1, #2      ; 58 (':')",
            "    ADD R3, R2, #5",
            "    ST R1, [R3]",
            "    ; Display seconds",
        ] + self.macro_display_bcd_byte(['R12', 'R2', '6'])
    
    def _increment_label(self):
        """Increment label counter and return empty list"""
        self.label_counter += 1
        return []

    def _get_label_id(self):
        """Return a new unique label id (integer) for use as a suffix.

        Use this to create non-colliding labels inside macros, e.g.
        lid = self._get_label_id(); f"LOOP_{lid}:" and branches to
        "LOOP_{lid}". This keeps labels unique across macro expansions.
        """
        self.label_counter += 1
        return str(self.label_counter)

def main():
    if len(sys.argv) != 2:
        print("Usage: python stump_macro.py input.sasm")
        return
    
    compiler = StumpMacroCompiler()
    output = compiler.process_file(sys.argv[1])
    
    # Write output
    output_file = sys.argv[1].replace('.sasm', '.s')
    with open(output_file, 'w') as f:
        f.write(output)
    
    print(f"Generated {output_file}")

if __name__ == "__main__":
    main()
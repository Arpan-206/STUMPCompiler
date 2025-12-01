#!/usr/bin/env python3
"""
Minimal STUMP macro expander

- Expands a small set of macros in `.sasm` files into plain STUMP assembly.
- Intended as a compact, readable baseline you can edit directly.
- Usage: python3 stump_minimal.py input.sasm
"""

import re
import sys

class StumpMacroCompiler:
    def __init__(self):
        self.output = []

    def process_file(self, filename):
        """Process a .sasm file (STUMP assembly with macros)"""
        with open(filename, 'r') as f:
            lines = f.readlines()

        expanded = self.expand_macros(lines)
        return '\n'.join(expanded)

    def expand_macros(self, lines):
        expanded = []
        for raw in lines:
            line = raw.rstrip()
            stripped = line.strip()
            if not stripped or stripped.startswith(';'):
                expanded.append(line)
                continue
            if stripped.startswith('@'):
                expanded.extend(self.handle_macro(stripped))
            else:
                expanded.append(line)
        return expanded

    def handle_macro(self, line):
        match = re.match(r'@(\w+)\s*(.*)', line)
        if not match:
            return [f"; Error parsing macro: {line}"]
        name = match.group(1)
        args_str = match.group(2)
        args = []
        if args_str:
            if '"' in args_str:
                parts = args_str.split('"')
                if len(parts) >= 3:
                    args.append(parts[1])
                    rem = parts[2].strip()
                    if rem:
                        args.extend(rem.split())
            else:
                args = args_str.split()

        if name == 'NUM_TO_ASCII':
            return self.macro_num_to_ascii(args)
        if name == 'PRINT_STRING':
            return self.macro_print_string(args)
        if name == 'PRINT_CHAR':
            return self.macro_print_char(args)
        if name == 'CLEAR_LCD':
            return self.macro_clear_lcd(args)
        if name == 'DELAY':
            return self.macro_delay(args)
        return [f"; Unknown macro: {name}"]

    def macro_num_to_ascii(self, args):
        if len(args) != 2:
            return ["; Error: @NUM_TO_ASCII needs src and dest_reg"]
        src = args[0]
        dest = args[1]
        return [
            f"; Convert {src} to ASCII in {dest}",
            f"    MOV R6, #12",
            f"    ADD R6, R6, R6      ; 24",
            f"    ADD R6, R6, R6      ; 48 (ASCII '0')",
            f"    ADD {dest}, R6, {src}  ; Add 48"
        ]

    def macro_print_string(self, args):
        if len(args) < 2:
            return ["; Error: @PRINT_STRING needs string and lcd_reg"]
        string = args[0]
        lcd_reg = args[1]
        out = [f"; Print string: \"{string}\""]
        out.append(f"    LD {lcd_reg}, LCD_BASE")
        for i,ch in enumerate(string):
            out.extend(self.build_value(ord(ch),'R1'))
            if i == 0:
                out.append(f"    ST R1, [{lcd_reg}]")
            else:
                if i <= 15:
                    out.append(f"    ADD R3, {lcd_reg}, #{i}")
                    out.append(f"    ST R1, [R3]")
                else:
                    out.append(f"    ; Offset {i} too large")
        return out

    def macro_print_char(self, args):
        if len(args) < 3:
            return ["; Error: @PRINT_CHAR needs char, lcd_reg, offset"]
        char = args[0]
        lcd_reg = args[1]
        offset = int(args[2])
        out = []
        if char.startswith("'") and char.endswith("'"):
            ascii_val = ord(char[1])
            out.append(f"; Print '{char[1]}'")
            out.extend(self.build_value(ascii_val,'R1'))
        else:
            out.append(f"    MOV R1, {char}")
        if offset == 0:
            out.append(f"    ST R1, [{lcd_reg}]")
        elif -16 <= offset <= 15:
            if offset > 0:
                out.append(f"    ADD R3, {lcd_reg}, #{offset}")
            else:
                out.append(f"    SUB R3, {lcd_reg}, #{-offset}")
            out.append("    ST R1, [R3]")
        else:
            out.append(f"    ; Offset {offset} out of range")
        return out

    def build_value(self, value, reg):
        if value <= 15:
            return [f"    MOV {reg}, #{value}"]
        if value <= 30:
            return [f"    MOV {reg}, #15", f"    ADD {reg}, {reg}, #{value-15}"]
        if value == 32:
            return [f"    MOV {reg}, #8", f"    ADD {reg}, {reg}, {reg}", f"    ADD {reg}, {reg}, {reg}"]
        if 48 <= value <= 57:
            out = [f"    MOV {reg}, #12", f"    ADD {reg}, {reg}, {reg}", f"    ADD {reg}, {reg}, {reg}"]
            if value > 48:
                out.append(f"    ADD {reg}, {reg}, #{value-48}")
            return out
        if value == 58:
            return [f"    MOV {reg}, #14", f"    ADD {reg}, {reg}, {reg}", f"    ADD {reg}, {reg}, {reg}", f"    ADD {reg}, {reg}, #2"]
        # generic
        out = []
        if value >= 15:
            out.append(f"    MOV {reg}, #15")
            cur = 15
        else:
            out.append(f"    MOV {reg}, #{value}")
            return out
        while cur < value:
            if value-cur <= 15:
                out.append(f"    ADD {reg}, {reg}, #{value-cur}")
                break
            out.append(f"    ADD {reg}, {reg}, #15")
            cur += 15
        return out

    def macro_clear_lcd(self, args):
        return [
            "; Clear LCD",
            "    LD R2, LCD_BASE",
            "    MOV R1, #8",
            "    ADD R1, R1, R1",
            "    ADD R1, R1, R1",
            "    MOV R3, #15",
            "CLEAR_LOOP1:",
            "    ST R1, [R2]",
            "    ADD R2, R2, #1",
            "    SUB R3, R3, #1",
            "    BNE CLEAR_LOOP1",
            "    MOV R3, #5",
            "CLEAR_LOOP2:",
            "    ST R1, [R2]",
            "    ADD R2, R2, #1",
            "    SUB R3, R3, #1",
            "    BNE CLEAR_LOOP2"
        ]

    def macro_delay(self, args):
        count = 15
        if args and args[0].isdigit():
            count = min(15, int(args[0]))
        return [
            "; Delay",
            f"    MOV R5, #{count}",
            "DELAY_OUTER:",
            "    MOV R6, #15",
            "DELAY_INNER:",
            "    SUB R6, R6, #1",
            "    BNE DELAY_INNER",
            "    SUB R5, R5, #1",
            "    BNE DELAY_OUTER"
        ]

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 stump_minimal.py input.sasm")
        return
    c = StumpMacroCompiler()
    out = c.process_file(sys.argv[1])
    out_file = sys.argv[1].replace('.sasm', '.s')
    with open(out_file, 'w') as f:
        f.write(out)
    print(f"Generated {out_file}")

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
Macro-assisted STUMP compiler helpers.

The macros implemented here are tailored to the COMP22111 experimental board
peripherals that are documented in:
- COMP22111 Stump Instruction Set (ver. 2025)
- COMP22111 Experimental Board Peripherals (ver. 2023, updated 27.11)

The PDF notes define the LCD display memory map (&FF40-&FF8F), the buzzer busy
flag, the free-running counter and the constraints on immediate operands (<=15).
"""
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Sequence


REGISTER_RE = re.compile(r"^R([0-7])$")


@dataclass(frozen=True)
class Token:
    value: str
    is_string: bool = False


class StumpMacroCompiler:
    """
    Expands a handful of convenience macros into vanilla STUMP assembly.

    Macros will clobber registers R1-R6. Callers should preserve any live values
    they care about before invoking @PRINT_STRING, @PRINT_CHAR, @NUM_TO_ASCII or
    @CLEAR_LCD. R0 (constant zero) and R7 (PC) stay untouched.
    """

    LCD_BASE = 0xFF40          # Page 2 of the peripherals PDF
    LCD_LINE_LENGTH = 20
    LCD_TOTAL_CHARS = 80
    FREE_RUNNING_COUNTER = 0xFFA4

    def __init__(self) -> None:
        self.label_counter = 0

    # --------------------------------------------------------------------- API
    def process_file(self, filename: str | Path) -> str:
        with open(filename, "r", encoding="utf-8") as fh:
            lines = fh.readlines()
        expanded = self.expand_macros(lines)
        return "\n".join(expanded)

    def expand_macros(self, lines: Iterable[str]) -> List[str]:
        expanded: List[str] = []
        for raw_line in lines:
            line = raw_line.rstrip("\n")
            stripped = line.strip()

            if not stripped or stripped.startswith(";"):
                expanded.append(line)
                continue

            if stripped.startswith("@"):
                expanded.extend(self.handle_macro(stripped))
            else:
                expanded.append(line)
        return expanded

    # ----------------------------------------------------------------- parsing
    def handle_macro(self, line: str) -> List[str]:
        match = re.match(r"@(\w+)\s*(.*)", line)
        if not match:
            return [f"; Error parsing macro invocation: {line}"]

        macro_name = match.group(1).upper()
        args = self._tokenise_args(match.group(2).strip())

        if macro_name == "PRINT_STRING":
            return self.macro_print_string(args)
        if macro_name == "PRINT_CHAR":
            return self.macro_print_char(args)
        if macro_name == "NUM_TO_ASCII":
            return self.macro_num_to_ascii(args)
        if macro_name == "CLEAR_LCD":
            return self.macro_clear_lcd(args)
        if macro_name == "DELAY":
            return self.macro_delay(args)
        return [f"; Unknown macro: {macro_name}"]

    def _tokenise_args(self, args_str: str) -> List[Token]:
        if not args_str:
            return []

        tokens: List[Token] = []
        in_quotes = False
        current: List[str] = []

        for char in args_str:
            if char == '"' and not in_quotes:
                in_quotes = True
                current = []
                continue
            if char == '"' and in_quotes:
                tokens.append(Token("".join(current), True))
                current = []
                in_quotes = False
                continue
            if in_quotes:
                current.append(char)
                continue
            if char.isspace():
                if current:
                    tokens.append(Token("".join(current), False))
                    current = []
                continue
            current.append(char)

        if current:
            tokens.append(Token("".join(current), in_quotes and bool(current)))
        return tokens

    # ----------------------------------------------------------------- helpers
    def _parse_number(self, token: Token, *, allow_negative: bool = False) -> int:
        text = token.value
        if text.startswith("#"):
            text = text[1:]
        if text.startswith("&"):
            value = int(text[1:], 16)
        elif text.lower().startswith("0x"):
            value = int(text, 16)
        elif text.startswith("%"):
            value = int(text[1:], 2)
        else:
            value = int(text, 10)
        if not allow_negative and value < 0:
            raise ValueError("Negative values are not supported here")
        return value

    def _expect_register(self, token: Token) -> str:
        match = REGISTER_RE.match(token.value.upper())
        if not match:
            raise ValueError(f"Expected register (R1-R6), got '{token.value}'")
        reg_index = int(match.group(1))
        if reg_index in (0, 7):
            raise ValueError("Register must be in the general-purpose range R1-R6")
        return f"R{reg_index}"

    def _lcd_address(self, line: int, column: int) -> int:
        if not 0 <= line < 4:
            raise ValueError("LCD line must be in range 0-3")
        if not 0 <= column < self.LCD_LINE_LENGTH:
            raise ValueError("LCD column must be in range 0-19")
        offset = line * self.LCD_LINE_LENGTH + column
        return self.LCD_BASE + offset

    def _new_label(self, prefix: str) -> str:
        self.label_counter += 1
        return f"__{prefix.upper()}_{self.label_counter}"

    def build_value(self, value: int, reg: str) -> List[str]:
        if not 0 <= value <= 0xFFFF:
            raise ValueError(f"Immediate out of range: {value}")
        if value == 0:
            return [f"    MOV {reg}, #0"]
        bits = bin(value)[2:]
        instructions = [f"    MOV {reg}, #{bits[0]}"]
        for bit in bits[1:]:
            instructions.append(f"    ADD {reg}, {reg}, {reg}")
            if bit == "1":
                instructions.append(f"    ADD {reg}, {reg}, #1")
        return instructions

    # --------------------------------------------------------------- macro impl
    def macro_print_string(self, args: Sequence[Token]) -> List[str]:
        if not args or not args[0].is_string:
            return ['; PRINT_STRING needs @"text" [line] [col]']

        text = args[0].value
        line = self._parse_number(args[1]) if len(args) > 1 else 0
        column = self._parse_number(args[2]) if len(args) > 2 else 0
        start_address = self._lcd_address(line, column)

        instructions = [
            f"; PRINT_STRING \"{text}\" -> LCD line {line}, column {column}"
        ]
        instructions += self.build_value(start_address, "R4")

        char_pointer = 0
        for ch in text:
            current_address = start_address + char_pointer
            if current_address >= self.LCD_BASE + self.LCD_TOTAL_CHARS:
                instructions.append(
                    "; Warning: string truncated because LCD memory (FF40-FF8F) was exceeded"
                )
                break
            if char_pointer:
                instructions.append("    ADD R4, R4, #1")
            instructions += self.build_value(ord(ch), "R5")
            instructions.append("    ST R5, [R4]")
            char_pointer += 1
        return instructions

    def macro_print_char(self, args: Sequence[Token]) -> List[str]:
        if not args:
            return ['; PRINT_CHAR needs a character plus LCD coordinates']

        if args[0].is_string and args[0].value:
            char_value = ord(args[0].value[0])
        else:
            char_value = self._parse_number(args[0])

        if len(args) == 2 and not args[1].is_string:
            line = 0
            column = 0
            absolute_address = self._parse_number(args[1])
        else:
            line = self._parse_number(args[1]) if len(args) > 1 else 0
            column = self._parse_number(args[2]) if len(args) > 2 else 0
            absolute_address = self._lcd_address(line, column)

        instructions = [
            f"; PRINT_CHAR value {char_value} -> LCD line {line}, column {column}"
        ]
        instructions += self.build_value(absolute_address, "R4")
        instructions += self.build_value(char_value, "R5")
        instructions.append("    ST R5, [R4]")
        return instructions

    def macro_num_to_ascii(self, args: Sequence[Token]) -> List[str]:
        """
        Convert a binary value (0-99) in a register into two ASCII digits and
        store them consecutively on the LCD.

        Usage: @NUM_TO_ASCII Rn line column
        """
        if len(args) < 3:
            return ['; NUM_TO_ASCII needs source register plus LCD line/column']

        src_reg = self._expect_register(args[0])
        line = self._parse_number(args[1])
        column = self._parse_number(args[2])
        start_address = self._lcd_address(line, column)

        loop_label = self._new_label("NUM_TO_ASCII_LOOP")
        done_label = self._new_label("NUM_TO_ASCII_DONE")

        instructions = [
            f"; NUM_TO_ASCII {src_reg} -> LCD line {line}, column {column}"
        ]
        instructions += self.build_value(start_address, "R4")
        instructions.append(f"    MOV R5, {src_reg}    ; working copy")
        instructions.append("    MOV R6, #0           ; tens counter")
        instructions.append("    MOV R3, #10")
        instructions.append(f"{loop_label}:")
        instructions.append("    CMP R5, R3")
        instructions.append(f"    blt {done_label}")
        instructions.append("    SUB R5, R5, #10")
        instructions.append("    ADD R6, R6, #1")
        instructions.append(f"    bal {loop_label}")
        instructions.append(f"{done_label}:")
        instructions += self.build_value(ord("0"), "R2")
        instructions.append("    ADD R6, R6, R2")
        instructions.append("    ST R6, [R4]")
        instructions.append("    ADD R4, R4, #1")
        instructions.append("    ADD R5, R5, R2")
        instructions.append("    ST R5, [R4]")
        return instructions

    def macro_clear_lcd(self, _: Sequence[Token]) -> List[str]:
        loop_label = self._new_label("CLEAR_LCD")
        instructions = [
            "; CLEAR_LCD (FF40-FF8F as per peripherals PDF)",
        ]
        instructions += self.build_value(self.LCD_BASE, "R4")
        instructions += self.build_value(self.LCD_TOTAL_CHARS, "R6")
        instructions.append("    MOV R5, #0")
        instructions.append(f"{loop_label}:")
        instructions.append("    ST R5, [R4]")
        instructions.append("    ADD R4, R4, #1")
        instructions.append("    SUBS R6, R6, #1")
        instructions.append(f"    bne {loop_label}")
        return instructions

    def macro_delay(self, args: Sequence[Token]) -> List[str]:
        if not args:
            return ['; DELAY needs a positive integer iteration count']

        cycles = self._parse_number(args[0])
        loop_label = self._new_label("DELAY_LOOP")

        instructions = [f"; DELAY loop for {cycles} iterations"]
        instructions += self.build_value(cycles, "R5")
        instructions.append(f"{loop_label}:")
        instructions.append("    SUBS R5, R5, #1")
        instructions.append(f"    bne {loop_label}")
        return instructions


def main(argv: Sequence[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Expand STUMP board helper macros.")
    parser.add_argument("source", type=Path, help="Input .sasm file")
    parser.add_argument(
        "-o", "--output", type=Path, help="Optional output file (defaults to stdout)"
    )
    args = parser.parse_args(argv)

    compiler = StumpMacroCompiler()
    expanded = compiler.process_file(args.source)

    if args.output:
        args.output.write_text(expanded + "\n", encoding="utf-8")
    else:
        print(expanded)


if __name__ == "__main__":
    main()


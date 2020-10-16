// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.core;
using haxe.EnumTools;

// ISO 7.11.2.5 How to read double quoted strings
enum DoubleQuotes {
    chars;  // each char as an atom
    codes;  // numerical codes
    atom;   // as a single atom
}

// ISO 7.11 Flags
class Flags {

    public var doubleQuotes = DoubleQuotes.codes;

    public function new() {}

    public static final flagNames = [
        "bounded",
        "max_integer",
        "min_integer",
        "integer_rounding_function",
        "char_conversion",
        "debug",
        "max_arity",
        "unknown",
        "double_quotes"
    ];
    

}
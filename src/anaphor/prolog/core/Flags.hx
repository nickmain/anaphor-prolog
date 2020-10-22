// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.core;

// ISO 7.11.2.1 Character Conversion
enum CharConversion {
    on;  // ISO default
    off;
}

// ISO 7.11.2.2 Implementation defined debug mode
enum Debug {
    on;
    off;  // ISO default
}

// ISO 7.11.2.4 Effect of attempting to call an unknown predicate
enum Unknown {
    error;  // ISO default
    fail;
    warning;
}

// ISO 7.11.2.5 How to read double quoted strings
enum DoubleQuotes {
    chars;  // each char as an atom
    codes;  // numerical codes
    atom;   // as a single atom
    string; // non-ISO, native string (default)
}

// ISO 7.11 Flags
class Flags {

    public var charConversion = CharConversion.on;
    public var debug = Debug.off;
    public var unknown = Unknown.error;
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
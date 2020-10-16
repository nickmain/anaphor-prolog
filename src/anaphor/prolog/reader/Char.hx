// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

class Char {

    // ISO 6.4.1 Comment chars
    public static inline final comment1 = "/";
    public static inline final comment2 = "*";
    public static inline final commentEnd = "*/";

    // ISO 6.4.2 Names
    public static inline function isGraphicToken(char: String): Bool {
        return isGraphic(char) || char == backslash;
    }

    // ISO 6.4.8 Other tokens
    public static inline final end = ".";

    // ISO 6.5 Processor character set
    public static function isChar(char: String): Bool {
        return isGraphic(char) 
            || isAlphanumeric(char)
            || isSolo(char)
            || isLayout(char)
            || isMeta(char);
    }

    // ISO 6.5.1 Graphic characters
    public static inline function isGraphic(char: String): Bool {
        return char == "#" || char == "$" || char == "&" || char == "*"
            || char == "+" || char == "-" || char == "." || char == "/"
            || char == ":" || char == "<" || char == "=" || char == ">"
            || char == "?" || char == "@" || char == "^" || char == "~";
    }

    // ISO 6.5.2 Alphanumeric characters
    public static inline function isAlphanumeric(char: String): Bool {
        return isAlpha(char) || isDecimalDigit(char);
    }

    public static inline function isAlpha(char: String): Bool {
        return char == underscore || isLetter(char);
    }

    public static inline function isLetter(char: String): Bool {
        return isCapitalLetter(char) || isSmallLetter(char);
    }

    public static inline function isCapitalLetter(char: String): Bool {
        return char == "A" || char == "B" || char == "C" || char == "D" || char == "E"
            || char == "F" || char == "G" || char == "H" || char == "I" || char == "J"
            || char == "K" || char == "L" || char == "M" || char == "N" || char == "O"
            || char == "P" || char == "Q" || char == "R" || char == "S" || char == "T"
            || char == "U" || char == "V" || char == "W" || char == "X" || char == "Y"
            || char == "Z";
    }

    public static inline function isSmallLetter(char: String): Bool {
        return char == "a" || char == "b" || char == "c" || char == "d" || char == "e"
            || char == "f" || char == "g" || char == "h" || char == "i" || char == "j"
            || char == "k" || char == "l" || char == "m" || char == "n" || char == "o"
            || char == "p" || char == "q" || char == "r" || char == "s" || char == "t"
            || char == "u" || char == "v" || char == "w" || char == "x" || char == "y"
            || char == "z";
    }

    public static inline function isDecimalDigit(char: String): Bool {
        return char == "0" || char == "1" || char == "2" || char == "3" || char == "4"
            || char == "5" || char == "6" || char == "7" || char == "8" || char == "9";
    }

    public static inline function isBinaryDigit(char: String): Bool {
        return char == "0" || char == "1";
    }

    public static inline function isOctalDigit(char: String): Bool {
        return char == "0" || char == "1" || char == "2" || char == "3" || char == "4"
            || char == "5" || char == "6" || char == "7";
    }

    public static inline function isHexadecimalDigit(char: String): Bool {
        return char == "0" || char == "1" || char == "2" || char == "3" || char == "4"
            || char == "5" || char == "6" || char == "7" || char == "8" || char == "9"
            || char == "a" || char == "b" || char == "c" || char == "d" || char == "e"
            || char == "f" 
            || char == "A" || char == "B" || char == "C" || char == "D" || char == "E"
            || char == "F";
    }

    public static inline final underscore = "_";

    // ISO 6.5.3 Solo characters
    public static inline function isSolo(char: String): Bool {
        return char == cut 
            || char == open      || char == close 
            || char == comma     || char == semicolon 
            || char == openList  || char == closeList
            || char == openCurly || char == closeCurly 
            || char == headTailSeparator
            || char == endLineComment;
    }

    public static inline final cut               = "!";
    public static inline final open              = "(";
    public static inline final close             = ")";
    public static inline final comma             = ",";
    public static inline final semicolon         = ";";
    public static inline final openList          = "[";
    public static inline final closeList         = "]";
    public static inline final openCurly         = "{";
    public static inline final closeCurly        = "}";
    public static inline final headTailSeparator = "|";
    public static inline final endLineComment    = "%";

    // ISO 6.5.4 Layout characters
    public static inline function isLayout(char: String): Bool {
        return char == space 
            || char == horizontalTab
            || char == newline 
            || char == carriageReturn // not ISO
            || char == verticalTab // not ISO
            || char == formfeed; // not ISO
    } 

    public static inline final space          = " ";
    public static inline final horizontalTab  = "\t";
    public static inline final newline        = "\n";
    public static inline final carriageReturn = "\r";
    public static inline final verticalTab    = "\x0B";
    public static inline final formfeed       = "\x0C";

    // ISO 6.5.5 Meta characters
    public static inline function isMeta(char: String): Bool {
        return char == backslash 
            || char == singleQuote 
            || char == doubleQuote 
            || char == backQuote;
    }  

    public static inline final backslash   = "\\";
    public static inline final singleQuote = "'";
    public static inline final doubleQuote = "\"";
    public static inline final backQuote   = "`";
}
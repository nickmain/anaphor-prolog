// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

class Chars {


    // ISO 6.5.1 Graphic characters
    public static func isGraphic(char: String): Bool {
        return char == "#" || char == "$" || char == "&" || char == "*"
            || char == "+" || char == "-" || char == "." || char == "/"
            || char == ":" || char == "<" || char == "=" || char == ">"
            || char == "?" || char == "@" || char == "^" || char == "~";
    }

    // ISO 6.5.2 Alphanumeric characters
    
}
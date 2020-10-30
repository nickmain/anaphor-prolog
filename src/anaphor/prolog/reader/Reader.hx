// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

import anaphor.prolog.reader.Lexer.CharPosition;

typedef ReaderTerm = {
    pos: CharPosition;
    type: TermType;
}

enum TermType {
    atom(name: String);
    number(value: NumberTerm);
    string(value: String);
    list(head: Array<ReaderTerm>, tail: Null<ReaderTerm>);
    struct(name: StructName, args: Array<ReaderTerm>);
    variable(name: String);
}

enum StructName {
    atom(name: String);
    operator;
}

enum NumberTerm {
    integer(value: Int);
    float(value: Float);
}

class Reader {
    public var sourceName(default,null): String; // filename or whatever 

    public function new(name: String) {
        this.name = name;
    }

    
}
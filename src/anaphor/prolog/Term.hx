// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog;

enum Term<T> {
    Foo(term: T);
    Bar;
    Bat(term1: T, term2: T);
}

class LocatedEnum {
    public var line: Int;
    public var pos: Int;

    public var term: Term<LocatedEnum>;

    public function new(line: Int, pos: Int, term: Term<LocatedEnum>) {
        this.term = term;
        this.line = line;
        this.pos  = pos;
    }

    public function toString(): String {
        return '($line:$pos): $term';
    }
}


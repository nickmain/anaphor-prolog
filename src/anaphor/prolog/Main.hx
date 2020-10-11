package anaphor.prolog;

import anaphor.prolog.Term;

class Main {
    public static function main() {
        final le = new LocatedEnum(1, 2, Foo(new LocatedEnum(4, 5, Bar)));
        trace(le);
    }
}
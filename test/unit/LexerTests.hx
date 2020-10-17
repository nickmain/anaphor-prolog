// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package unit;
import utest.Assert;
import anaphor.prolog.core.Flags;
import anaphor.prolog.reader.Lexer;
import anaphor.prolog.reader.Lexer.Token;
import haxe.io.StringInput;
using haxe.EnumTools.EnumValueTools;

// Expected token to compare against
private enum ExpectedToken {
    token(token: Token);
    posToken(token: Token, line1: Int, col1: Int, line2: Int, col2: Int);
}

class LexerTests extends utest.Test {

    // tokenize the source string and compare against expected tokens
    function check(src: String, expected: Array<ExpectedToken>, ?flags: Flags) {
        if(flags == null) flags = new Flags();
        final lexer = new Lexer(new StringInput(src), flags);

        for(expect in expected) {
            switch(lexer.read()) {
                case finished: { Assert.fail("finished before all expected tokens"); return; }
                case problem(p): { Assert.fail(Std.string(p)); return; }
                case token(tok, span): {
                    switch(expect) {
                        case token(t): {
                            tokenEq(t, tok);
                        }
                        case posToken(t, line1, col1, line2, col2): {
                            tokenEq(t, tok);
                            Assert.equals(line1, span.start.line);
                            Assert.equals(col1, span.start.col);
                            Assert.equals(line2, span.end.line);
                            Assert.equals(col2, span.end.col);
                        }
                    }	
                }
            }
        }

        switch(lexer.read()) {
            case finished: { Assert.pass(); }
            case problem(p): { Assert.fail(Std.string(p)); }
            case token(_, pos): { Assert.fail("Extra token(s) at " + Std.string(pos)); }
        }
    }

    function tokenEq(expected: Token, actual: Token) {
        if(! expected.equals(actual)) {
            Assert.fail("Expected token " + Std.string(expected) + " but got " + Std.string(actual));
        }
    }
    
    function testCut() {
        check(" ! !what!ever", [
            posToken(name("!"), 1, 2, 1, 2),
            posToken(name("!"), 1, 4, 1, 4),
            token(name("what")),
            posToken(name("!"), 1, 9, 1, 9),
            token(name("ever"))
        ]);
    }
    
    function testNames() {
        Assert.fail("unimplemented");	
    }
    
    function testTermEnd() {
        //     123456789.123456789.123  12345678
        check(" foo. bar.bat .%comment\n.=hello.", [
            token(name("foo")),
            posToken(endTerm, 1, 5, 1, 5),
            token(name("bar")),
            posToken(name("."), 1, 10, 1, 10),
            token(name("bat")),
            posToken(endTerm, 1, 15, 1, 15),
            posToken(name(".="), 2, 1, 2, 2),
            token(name("hello")),
            posToken(endTerm, 2, 8, 2, 8)
        ]);
    }
    
    function testLineEndComments() {
        Assert.fail("unimplemented");	
    }

    function testBlockComments() {
        Assert.fail("unimplemented");	
    }

    function testStrings() {
        Assert.fail("unimplemented");	
    }

    function testIntegers() {
        Assert.fail("unimplemented");	
    }

    function testFloats() {
        Assert.fail("unimplemented");	
    }

    function testVariables() {
        check(" foo Foo _foo _= _.", [
            token(name("foo")),
            token(variable("Foo")),
            token(variable("_foo")),
            token(variable("_")),
            token(name("=")),
            token(variable("_")),
            token(endTerm)
        ]);
    }

    function testWhitespace() {
        Assert.fail("unimplemented");	
    }

    function testEof() {
        Assert.fail("unimplemented");	
    }

    function testParens() {
        Assert.fail("unimplemented");	
    }

    function testCurlies() {
        Assert.fail("unimplemented");	
    }

    function testLists() {
        Assert.fail("unimplemented");	
    }

    function testExceptions() {
        Assert.fail("unimplemented");	
    }
}
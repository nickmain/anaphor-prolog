// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package unit;
import utest.Assert;
import anaphor.prolog.reader.Lexer;
import anaphor.prolog.reader.Lexer.Token;
import haxe.io.StringInput;
using haxe.EnumTools.EnumValueTools;

// Expected token to compare against
private enum ExpectedToken {
    token(token: Token);
    posToken(token: Token, line: Int, col: Int);
}

class LexerTests extends utest.Test {

    // tokenize the source string and compare against expected tokens
    function check(src: String, expected: Array<ExpectedToken>) {
        final lexer = new Lexer(new StringInput(src));

        for(expect in expected) {
            switch(lexer.read()) {
                case finished: { Assert.fail("finished before all expected tokens"); return; }
                case problem(p): { Assert.fail(Std.string(p)); return; }
                case token(tok, pos): {
                    switch(expect) {
                        case token(t): {
                            tokenEq(t, tok);
                        }
                        case posToken(t, line, col): {
                            tokenEq(t, tok);
                            Assert.equals(line, pos.line);
                            Assert.equals(col, pos.col);
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
        //     123456789.1234
        check(" ! !what!ever", [
            token(layout),
            posToken(name("!"), 1, 2),
            token(layout),
            posToken(name("!"), 1, 4),
            token(name("what")),
            posToken(name("!"), 1, 9),
            token(name("ever")),
            token(layout)
        ]);
    }
    
    function testNames() {
        Assert.fail("unimplemented");	
    }
    
    function testTermEnd() {
        //     123456789.123456789.123  12345678
        check(" foo. bar.bat .%comment\n.=hello.", [
            token(layout),
            token(name("foo")),
            posToken(endTerm, 1, 5),
            token(layout),
            token(name("bar")),
            posToken(name("."), 1, 10),
            token(name("bat")),
            token(layout),
            posToken(endTerm, 1, 15),
            token(layout),
            posToken(name(".="), 2, 1),
            token(name("hello")),
            posToken(endTerm, 2, 8),
            token(layout)
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
            token(layout),
            token(name("foo")),
            token(layout),
            token(variable("Foo")),
            token(layout),
            token(variable("_foo")),
            token(layout),
            token(variable("_")),
            token(name("=")),
            token(layout),
            token(variable("_")),
            token(endTerm),
            token(layout)
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
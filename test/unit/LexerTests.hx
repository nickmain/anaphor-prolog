// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package unit;
import utest.Assert;
import anaphor.prolog.core.Flags;
import anaphor.prolog.reader.Lexer;
import anaphor.prolog.reader.Lexer.LexerResult;
import anaphor.prolog.reader.Lexer.Token;
import haxe.io.StringInput;
using haxe.EnumTools.EnumValueTools;

// Expected token to compare against
private enum ExpectedToken {
    token(token: Token);
    posToken(token: Token, line: Int, start: Int, end: Int);
}

class LexerTests extends utest.Test {

    // tokenize the source string and compare against expected tokens
    function check(src: String, expected: Array<ExpectedToken>, ?flags: Flags) {
        if(flags == null) flags = new Flags();
        final lexer = new Lexer(new StringInput(src), flags);

        for(ex in expected) {
            switch(lexer.read()) {
                case finished: { Assert.fail("finished before all expected tokens"); return; }
                case problem(p): { Assert.fail(Std.string(p)); return; }
                case token(tok, pos): {
                    switch(ex) {
                        case token(t): {
                            tokenEq(t, tok);
                        }
                        case posToken(t, line, start, end): {
                            tokenEq(t, tok);
                            Assert.equals(line, pos.line);
                            Assert.equals(start, pos.start);
                            Assert.equals(end, pos.end);
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
            posToken(name("!"), 1, 2, 2),
            posToken(name("!"), 1, 4, 4),
            token(name("what")),
            posToken(name("!"), 1, 9, 9),
            token(name("ever"))
        ]);
    }
    
    function testNames() {
        Assert.fail("unimplemented");	
    }
    
    function testPeriod() {
        Assert.fail("unimplemented");	
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
        Assert.fail("unimplemented");	
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
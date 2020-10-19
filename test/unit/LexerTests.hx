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
    function checkTokens(src: String, expected: Array<Token>) {
        check(src, expected.map((t) -> token(t)));
    }

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

    function read(src: String): LexerResult {
        final lexer = new Lexer(new StringInput(src));
        return lexer.read();
    }

    function tokenEq(expected: Token, actual: Token) {
        if(! expected.equals(actual)) {
            Assert.fail("Expected token " + Std.string(expected) + " but got " + Std.string(actual));
        }
    }
    
    function testEmpty() {
        check("", [token(layout)]);
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

    function testIntegers() {
        check(" 123 ", [token(layout), posToken(integer(123), 1, 2), token(layout)]);
        check(" 003 ", [token(layout), posToken(integer(3), 1, 2), token(layout)]);
        check("45"   , [token(integer(45)), token(layout)]);
        check("10x"  , [posToken(integer(10), 1, 1), token(name("x")), token(layout)]);
    }

    function testHexadecimal() {
        check("0x123 ", [posToken(integer(0x123), 1, 1), token(layout)]);
        check("0xaA9 ", [posToken(integer(0xaa9), 1, 1), token(layout)]);
        check("0x0"   , [posToken(integer(0), 1, 1), token(layout)]);
        check("0xcafezoo", [posToken(integer(0xcafe), 1, 1), token(name("zoo")), token(layout)]);
        
        switch(read("0x")) {
            case problem(badHexValue({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(1, col);
            }
            default: Assert.fail("Expected badHexValue");
        }
    }

    function testOctal() {
        check("0o123 ", [posToken(integer(83), 1, 1), token(layout)]);
        check("0o003 ", [posToken(integer(3), 1, 1), token(layout)]);
        check("0o0"   , [posToken(integer(0), 1, 1), token(layout)]);
        check("0o1234zoo", [posToken(integer(668), 1, 1), token(name("zoo")), token(layout)]);
        
        switch(read("0o8")) {
            case problem(badOctalValue({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(1, col);
            }
            default: Assert.fail("Expected badOctalValue");
        }
    }

    function testBinary() {
        check("0b011 ", [posToken(integer(3), 1, 1), token(layout)]);
        check("0b11000111111111011101100 ", [posToken(integer(6553324), 1, 1), token(layout)]);
        check("0b0"    , [posToken(integer(0), 1, 1), token(layout)]);
        check("0b10123", [posToken(integer(5), 1, 1), token(integer(23)), token(layout)]);
        
        switch(read("0b2")) {
            case problem(badBinaryValue({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(1, col);
            }
            default: Assert.fail("Expected badBinaryValue");
        }
    }

    function testCharacterCodeLiteral() {
        Assert.fail("unimplemented");	
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


    function testFloats() {
        Assert.fail("unimplemented");	
    }

    function testVariables() {
        checkTokens(" foo Foo _foo _= _.", [
            layout, name("foo"), layout, variable("Foo"), layout, variable("_foo"),
            layout, variable("_"), name("="), layout, variable("_"), endTerm, layout
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
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

    // tokenize the source string and compare against single expected token
    function check1(src: String, expected: Token) {
        final lexer = new Lexer(new StringInput(src));

        switch(lexer.read()) {
            case finished: { Assert.fail("finished before expected token"); return; }
            case problem(p): { Assert.fail(Std.string(p)); return; }
            case token(tok, _): tokenEq(expected, tok);
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
        else Assert.isTrue(true);
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

    function testFloatingPoint() {
        check1("0.0 ", float(0));
        check1("0.1 ", float(0.1));
        check1("0010.0001 ", float(10.0001));
        check1("10.0e2 ", float(1000));
        check1("10.0e+2 ", float(1000));
        check1("9.0e-2 ", float(0.09));
        check1("9.0e-02 ", float(0.09));
        
        check("1.e2", [token(integer(1)), token(name(".")), token(name("e2")), token(layout)]);
        check("1. ", [token(integer(1)), token(endTerm), token(layout)]);
        check("1e2",  [token(integer(1)), token(name("e2")), token(layout)]);

        switch(read("1.0ee")) {
            case problem(badFloatValue({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(1, col);
            }
            default: Assert.fail("Expected badFloatValue");
        }
    }

    function testHexadecimal() {
        check1("0x123 ", integer(0x123));
        check1("0xaA9 ", integer(0xaa9));
        check1("0x0"   , integer(0));
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
        check1("0o123 ", integer(83));
        check1("0o003 ", integer(3));
        check1("0o0"   , integer(0));
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
        check1("0b011 ", integer(3));
        check1("0b0"   , integer(0));
        check1("0b11000111111111011101100 ", integer(6553324));
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
        check1("0'A ", integer(65));
        check1("0''' ", integer("'".code));
        check1("0'\\' ", integer("'".code));
        check1("0'\\\\ ", integer("\\".code));
        check1("0'\\n ", integer("\n".code));
        check1("0'\\40\\ ", integer(32));
        check1("0'\\x0020\\ ", integer(32)); 

        // space can be a char literal ?
        check("0'  x", [posToken(integer(32), 1, 1), posToken(layout, 1, 4), token(name("x")), token(layout)]);
        
        switch(read("0'\\x0020 ")) {
            case problem(badHexEscapeSequence({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(3, col);
            }
            default: Assert.fail("Expected badHexEscapeSequence");
        }

        switch(read("0'\\20 ")) {
            case problem(badOctalEscapeSequence({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(3, col);
            }
            default: Assert.fail("Expected badOctalEscapeSequence");
        }

        switch(read("0'' ")) {
            case problem(badCharacterCodeLiteral({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(1, col);
            }
            default: Assert.fail("Expected badCharacterCodeLiteral");
        }

        switch(read("0'\\8\\ ")) { // not octal
            case problem(badCharacterCodeLiteral({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(1, col);
            }
            default: Assert.fail("Expected badCharacterCodeLiteral");
        }
    }
    
    function testNames() {
        Assert.fail("unimplemented");	
    }
    
    function testQuotedName() {
        check1("'' ", name(""));
        check1("'''' ", name("'"));
        check1("'\\'' ", name("'"));
        check1("'\"foo bar\"' ", name("\"foo bar\""));

        check1("'hello\\n world \\x41\\' ", name("hello\n world A"));

        // check that next token has correct pos
        check("'foo'a", [posToken(name("foo"), 1, 1), posToken(name("a"), 1, 6), token(layout)]);

        // continuation escape
        check("'foo\\
bar' a", 
              [posToken(name("foobar"), 1, 1), token(layout), posToken(name("a"), 2, 6), token(layout)]);

        // no continuation escape
        switch(read("''' 
               bar' ")) {
            case problem(unterminatedQuotedAtom({line: line, col: col})): {
                Assert.equals(1, line);
                Assert.equals(1, col);
            }
            default: Assert.fail("Expected unterminatedQuotedAtom");
        }
    }

    function testMetaEscapes() {
        Assert.fail("unimplemented");	
    }

    function testControlEscapes() {
        Assert.fail("unimplemented");	
    }

    function testOctalEscapes() {
        Assert.fail("unimplemented");	
    }

    function testHexEscapes() {
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
// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package unit;
import utest.Assert;
import anaphor.prolog.reader.Lexer;
import anaphor.prolog.reader.Lexer.Lexeme;
import haxe.io.StringInput;

class LexerTests extends utest.Test {

	function lexemes(s: String): Array<Lexeme> {
		final lexer = new Lexer(new StringInput(s));
		final lexs: Array<Lexeme> = [];

		lexs.push(lexer.read());
		return lexs;
	}

	function testCut() {
		Assert.equals(name("!"), lexemes(" ! whatever")[0].token);
	}

	function testLineEndComments() {
		Assert.fail("unimplemented");	
	}

	function testBlockComments() {
		Assert.fail("unimplemented");	
	}

	function testStrings() {
		Assert.equals(openList, lexemes("foo")[0].token);
		//Assert.fail("unimplemented");	
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

	function testNames() {
		Assert.fail("unimplemented");	
	}

	function testWhitespace() {
		Assert.fail("unimplemented");	
	}

	function testPeriod() {
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
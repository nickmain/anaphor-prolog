// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

import haxe.io.Input;

typedef Lexeme = { token: Token, line: Int, start: Int, end: Int }

enum Token {
    string(value: String);
    integer(value: Int);
    float(value: Float);   
	variable(name: String);
    name(value: String);
	openParen;
	closeParen;
	openCurly;
	closeCurly;
	openList;
    closeList;
    headTailSeparator;
    comma;
    endTerm;
    
	finished;
    problem(problem: LexerProblem);
}

enum LexerProblem {
    exception(ex: haxe.Exception);
    unknown(msg: String);
}

private enum LexerState {
    gatheringString;
    gatheringWhitespace;
    gatheringOperator;
    gatheringAtom;
    gatheringVar;
    idle;
    finished;
    problem(problem: LexerProblem);
}

class Lexer {

    var lineNum = 0;
    var index = 0;
    var line = "";
    var input: Input;
    var state = LexerState.idle;
    
    public function new(input: Input) {
        this.input = input;
    }

    public function read(): Lexeme {
        if(state == finished) return lexeme(eof, 0);

        return lexeme(endTerm, 1);

        // TODO: implement me
      //  return lexeme(unknown(msg: "implement me"), 1};
    }

    // Make a lexeme to return
    function lexeme(token: Token, size: Int): Lexeme {
        final lex: Lexeme = { token: token, line: lineNum, col: index+1 };
        index += size;
        return lex;
    }

    function readNextLine() {
        try {
            index = 0;
            lineNum++;
            line = input.readLine();
            return;
        } 
        catch(_: haxe.io.Eof) {
            state = finished;
        }
        catch(e) {
            state = exception(e);
        }

        line = "";
    }
} 

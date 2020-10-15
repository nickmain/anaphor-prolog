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
    unterminatedBlockComment;
    unknown(msg: String);
}

private enum LexerState {
    ready;     // ready to proceed
    finished;  // no more tokens in input
    problem(problem: LexerProblem); // stop - problem was encountered
}

private enum TokenType {
    letterDigitToken;
    graphicToken;
    quotedToken;
}

class Lexer {

    var lineNum = 0;
    var index = 0;
    var line = "";
    var input: Input;
    var state = LexerState.ready;
    
    public function new(input: Input) {
        this.input = input;
    }

    // Read the next token.
    // Return "finished" if there are no more tokens in the input.
    // Return "problem(..)" if any problem is or was previously encountered.
    public function read(): Lexeme {
        if(! state.match(ready)) return stateLexeme();

        consumeWhitespace();
        if(! state.match(ready)) return stateLexeme();

        return gatherToken();
    }

    // Gather the next token and leave index pointing at the next char
    // after it
    function gatherToken(): Lexeme {
        final char = line.charAt(index);

        if(char == Char.semicolon) return lexeme(name(Char.semicolon));
        if(char == Char.cut) return lexeme(name(Char.cut));

        return lexeme(name("poop"), index, index);
    }

    // Make a lexeme from current state
    function lexeme(token: Token, start: Int = - 1, end: Int = -1): Lexeme { 
        if(start < 0) start = index;
        if(end < 0) end = index;       
        final lex: Lexeme = { token: token, line: lineNum, start: start, end: end };
        index = end + 1;
        return lex;
    }

    // Make a lexeme for finished or problem state
    function stateLexeme(): Lexeme {
        switch(state) {
            case problem(p): return { token: problem(p), line: lineNum, start: index, end: index };
            default: return { token: finished, line: lineNum, start: index, end: index };
        }
    }
    
    // Consume whitespace and comments.
    // On return index points at char after whitespace
    function consumeWhitespace() {
        while(state.match(ready)) {
            // consume whitespace until non-ws or end of line
            var char = line.charAt(index);
            while(Char.isLayout(char)) {
                index++;
                char = line.charAt(index);
            }

            if(char.length > 0) {
                // start of block comment
                if(char == Char.comment1 && line.charAt(index+1) == Char.comment2) {
                    index += 2; // first char after "/*"
                    consumeBlockComment();
                    continue;
                }
                else if(char != Char.endLineComment) {
                    state = ready;
                    return;    
                }
                // else is endline comment - skip to next line
            }

            readNextLine();
        }
    }

    // Consume block comment.
    // On return index points at char after closing "*/"
    function consumeBlockComment() {
        while(state.match(ready)) {
            final end = line.indexOf(Char.commentEnd, index);
            if(end >= 0) {
                index += Char.commentEnd.length;
                state = ready;
                return;
            }

            readNextLine();
            if(state.match(finished)) {
                state = problem(unterminatedBlockComment);
            }
        }
    }

    function readNextLine() {
        index = 0;
        try {
            line = input.readLine();
            lineNum++;
            state = ready;
        } 
        catch(_: haxe.io.Eof) {
            state = finished;
        }
        catch(e) {
            state = problem(exception(e));
        }
    }
} 

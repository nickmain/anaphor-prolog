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
        switch(state) {
            case finished: return lexeme(finished);
            case problem(p): return lexeme(problem(p), index);
            default:
        }

        consumeWhitespace();
        switch(state) {
            case finished: return lexeme(finished);
            case problem(p): return lexeme(problem(p), index);
            default:
        }

        return gatherToken();
    }

    // Gather the next token and leave index pointing at the next char
    // after it
    function gatherToken(): Lexeme {
        final char = line.charAt(index);

        if(char == Char.semicolon) return lexeme(name(Char.semicolon), index, index);
        if(char == Char.cut) return lexeme(name(Char.cut), index, index);

        return lexeme(name("poop"), index, index);
    }

    // Make a lexeme from current state
    function lexeme(token: Token, start: Int = - 1, end: Int = -1): Lexeme {        
        final lex: Lexeme = { token: token, line: lineNum, start: start, end: end };
        if(end >= 0) index = end + 1;
        return lex;
    }

    // Consume whitespace and comments.
    // On return index points at char after whitespace
    function consumeWhitespace() {
        while(state == ready) {
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
        while(state == ready) {
            final end =line.indexOf(Char.commentEnd, index);
            if(end >= 0) {
                index += Char.commentEnd.length;
                state = ready;
                return;
            }

            readNextLine();
            if(state == finished) {
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

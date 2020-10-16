// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

import haxe.io.Input;
import anaphor.prolog.core.Flags;

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
}

typedef TokenPosition = { line: Int, start: Int, end: Int };

enum LexerResult {
    token(token: Token, pos: TokenPosition);
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

class Lexer {

    final input: Input;
    final flags: Flags;
    var lineNum = 0;
    var index = 0;
    var line = "";
    var state = LexerState.ready;
    
    public function new(input: Input, flags: Flags) {
        this.input = input;
        this.flags = flags;
    }

    // Read the next token.
    // Return "finished" if there are no more tokens in the input.
    // Return "problem(..)" if any problem is or was previously encountered.
    public function read(): LexerResult {
        if(! state.match(ready)) return stateResult();

        consumeWhitespace();
        if(! state.match(ready)) return stateResult();

        return readToken();
    }

    // Read the next token and leave index pointing at the next char
    // after it
    function readToken(): LexerResult {
        final char = line.charAt(index);

        if(char == Char.open      ) return token(openParen);
        if(char == Char.close     ) return token(closeParen);
        if(char == Char.openCurly ) return token(openCurly);
        if(char == Char.closeCurly) return token(closeCurly);
        if(char == Char.openList  ) return token(openList);
        if(char == Char.closeList ) return token(closeList);
        if(char == Char.comma     ) return token(comma);
        if(char == Char.headTailSeparator) return token(headTailSeparator);

        if(char == Char.end) {
            final next = line.charAt(index + 1);
            if(next == "" || next == Char.endLineComment || Char.isLayout(next)) {
                // period followed by whitespace or comment is term-end
                return token(endTerm);
            }
            else {
                return graphicToken();
            }
        }

        // ISO 6.4.2 Names
        if(char == Char.semicolon) return token(name(Char.semicolon));
        if(char == Char.cut) return token(name(Char.cut));
        if(Char.isSmallLetter(char)) return letterDigitToken();
        if(Char.isGraphicToken(char)) return graphicToken();
        //TODO: quoted token

        // ISO 6.4.3 Variables
        if(char == Char.underscore || Char.isCapitalLetter(char)) return variableToken();

        // ISO 6.4.4 Integer numbers

        // ISO 6.4.5 Floating point numbers

        // ISO 6.4.6 Doubled quoted lists, aka Strings

        // ISO 6.4.7 Back quoted strings

        return finished;
    }

    function variableToken(): LexerResult {
        final start = index++;

        while(Char.isAlphanumeric(line.charAt(index))) index++;
        // index is now at non-alpha char or EOL

        return token(variable(line.substring(start, index)), start+1, index);
    }

    function letterDigitToken(): LexerResult {
        final start = index++;

        while(Char.isAlphanumeric(line.charAt(index))) index++;
        // index is now at non-alpha char or EOL

        return token(name(line.substring(start, index)), start+1, index);
    }

    function graphicToken(): LexerResult {
        final start = index++;

        while(Char.isGraphicToken(line.charAt(index))) index++;
        // index is now at non-graphic char or EOL

        return token(name(line.substring(start, index)), start+1, index);        
    }

    // Make a token result from current state
    function token(token: Token, start: Int = - 1, end: Int = -1): LexerResult { 
        if(start < 0) start = index+1;
        if(end < 0) end = index+1;
        final result = LexerResult.token(token, {line: lineNum, start: start, end: end});
        index = end;  // index is zero-based, end is 1-based
        return result;
    }

    // Make a result for finished or problem state
    function stateResult(): LexerResult {
        switch(state) {
            case problem(p): return problem(p);
            default: return finished;
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

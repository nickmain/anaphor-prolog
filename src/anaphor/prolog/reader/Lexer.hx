// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

enum TokenType {
    string(value: String);
    integer(value: Int);
    float(value: Float);   
	variable(name: String);
    atom(value: String);
    operator(value: String);
	whitespace(value: String);
	period;
	eof;
	openParen;
	closeParen;
	openBrace;
	closeBrace;
	openBracket;
    closeBracket;
    exception(ex: haxe.Exception);
    unknown(msg: String);
}

typedef Token = { type: TokenType, line: Int, col: Int }

enum LexerState {
    gatheringString;
    gatheringWhitespace;
    gatheringOperator;
    gatheringAtom;
    gatheringVar;
    idle;
}

class Lexer {
    public static inline var OP_CHARS  : String = "#$&*+-./:<=>?@^~\\";
    public static inline var WHITESPACE: String = " \n\r\t\x0C";

    var lineNum = 0;
    var index = 0;
    var line = "";
    var input: haxe.io.Input;
    var state = LexerState.idle;
    
    public function new(input: Input) {
        this.input = input;
    }

    public function read(): Token {
        if(token != null) return theToken();

        readWhitespace();
        if(token != null) return theToken();

        // should now be at a valid char
        final char = line.charAt(index);

        if(char == "(") return tokenType(openParen, 1);
        if(char == ")") return tokenType(closeParen, 1);
        if(char == "[") return tokenType(openBracket, 1);
        if(char == "]") return tokenType(closeBracket, 1);
        if(char == "{") return tokenType(openBrace, 1);
        if(char == "}") return tokenType(closeBrace, 1);
        if(char == ".") return tokenType(period, 1);

        // TODO: implement me
        return { type: unknown(msg: "implement me"), line: line, col: index+1 };
    }

    inline function isWhitespace(char: String): Bool {
        return char == " " 
            || char == "\n"
            || char == "\r"
            || char == "\t"
            || char == "\x0C";
    }

    // Make a token to return
    function tokenType(type: TokenType, size: Int): Token {
        final t = { type: type, line: line, col: index+1 };
        index += size;
        return t;
    }

    // Predetermined token to return
    function theToken(): Token {
        if(token != null) {
            switch(token.type) {
                case eof: return token;
                case exception(_): return token;
                default:
            }

            final t = token;
            token = null;
            return t;
        }

        return { type: unknown(msg: "oops"), line: line, col: index+1 };
    }

    // Consume whitespace, including new lines until eof or a char is reached
    function readWhitespace() {
        while(token == null) {
            final char = line.charAt(index);



        }

        while(index >= length) {
            readNextLine();            
        }

    }

    function readNextLine() {
        try {
            index = 0;
            lineNum++;
            line = input.readLine();
        } 
        catch(_: haxe.io.Eof) {
            token = { type: eof, line: line, col: index+1 };
        }
        catch(e) {
            token = { type: exception(ex: e), line: line, col: index+1 };
        }

        line = "";
    }
} 

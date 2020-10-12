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
}

typedef Token = { type: TokenType, line: Int, col: Int }

class Lexer {
    public static inline var OP_CHARS  : String = "#$&*+-./:<=>?@^~\\";
    public static inline var WHITESPACE: String = " \n\r\t\x0C";

    var lineNum = 0;
    var index = 0;
    var line: String;
    var input: haxe.io.Input;

    public function new(input: Input) {
        this.input = input;
    }

    

    public function read(): Token {
        // TODO: implement me
        return eof;
    }
} 

class Token {    
    public var value(default,null): TokenValue;
    public var type (default,null): TokenType;
    
    public function new( type: TokenType, chars: Array<Char>, ?start: Char, ?end: Char ) {
        this.type = type;        
        if( type == eof ) return; 
        
        if( start == null ) start = chars[0];
        if( end   == null ) end   = chars[chars.length-1];
        
        startLine = start.line;
        startCol  = start.col;
        endLine   = end.line;
        endCol    = end.col;

        var s = chars.join("");
        
        if     ( type == token_int   ) value = Std.parseInt( s );
        else if( type == token_float ) value = Std.parseFloat( s );
        else value = s;
    }
    
    public function toString() {
        return type + " [" + startLine + ":" + startCol + "-" + 
               endLine + ":" + endCol + "] = '" + value + "'";  
    }
}


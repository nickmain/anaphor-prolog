// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

enum TokenValue {
    string(value: String);
    integer(value: Int);
    float(value: Float);    
}

class Token {

    public var startLine(default,null): Int;
    public var startCol (default,null): Int;
    public var endLine  (default,null): Int;
    public var endCol   (default,null): Int;     
    
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

enum TokenType {
	variable;
	atom;
	int;
	float;
	whitespace;
	string;
	termEnd;
	eof;
	openParen;
	closeParen;
	openBrace;
	closeBrace;
	openBracket;
	closeBracket;
}
// Copyright © 2020, David N Main. All rights reserved.
// Licensed under the MIT License, see LICENSE file for details.

package anaphor.prolog.reader;

import anaphor.prolog.reader.CharConversionTable.CharConverter;
import haxe.io.Input;
import anaphor.prolog.core.Flags;
import anaphor.prolog.core.Flags.DoubleQuotes;

enum Token {
    string(value: String, style: DoubleQuotes);
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
    layout;
    endTerm;
}

typedef CharPosition = { line: Int, col: Int }

enum LexerResult {
    token(token: Token, pos: CharPosition);
    finished;
    problem(problem: LexerProblem);
}

enum LexerProblem {
    exception(ex: haxe.Exception);
    unterminatedBlockComment(start: CharPosition);
    badIntegerValue(start: CharPosition);
    badHexValue(start: CharPosition);
    badBinaryValue(start: CharPosition);
    badOctalValue(start: CharPosition);
    badFloatValue(start: CharPosition);
    unknown(msg: String);
}

private enum LexerState {
    ready;     // ready to proceed
    finished;  // no more tokens in input
    problem(problem: LexerProblem); // stop - problem was encountered
}

class Lexer {
    public var doubleQuoteFlag = DoubleQuotes.codes;
    public var charConversion = false;
    public var charConvertor: Null<CharConverter>;

    final input: Input;
    var lineNum = 0;
    var index = 0;
    var line = "";
    var state = LexerState.ready;
    var start: CharPosition = {line: 1, col: 1};
    
    public function new(input: Input) {
        this.input = input;

        // initialize
        readNextLine();
        if(state.match(finished)) {
            state = ready; // in order to read the layout token
        }
    }

    // Read the next token.
    // Return a final layout token at EOF if there is no trailing whitespace.
    // Return "finished" if there are no more tokens in the input.
    // Return "problem(..)" if any problem is or was previously encountered.
    public function read(): LexerResult {
        if(! state.match(ready)) return stateResult();

        this.start = here();

        consumeWhitespace();
        if(state.match(finished) || ! stillHere(start)) {
            return token(layout);
        }
        if(! state.match(ready)) return stateResult();

        final char = line.charAt(index);

        if(char == Char.open      ) return charToken(openParen);
        if(char == Char.close     ) return charToken(closeParen);
        if(char == Char.openCurly ) return charToken(openCurly);
        if(char == Char.closeCurly) return charToken(closeCurly);
        if(char == Char.openList  ) return charToken(openList);
        if(char == Char.closeList ) return charToken(closeList);
        if(char == Char.comma     ) return charToken(comma);
        if(char == Char.headTailSeparator) return charToken(headTailSeparator);

        if(char == Char.end) {
            final next = line.charAt(index + 1);
            if(next == "" || next == Char.endLineComment || Char.isLayout(next)) {
                // period followed by whitespace or comment is term-end
                return charToken(endTerm);
            }
            else {
                return graphicToken();
            }
        }

        // ISO 6.4.2 Names
        if(char == Char.semicolon) return charToken(name(Char.semicolon));
        if(char == Char.cut) return charToken(name(Char.cut));
        if(char == Char.singleQuote) return quotedAtom();
        if(Char.isSmallLetter(char)) return letterDigitToken();
        if(Char.isGraphicToken(char)) return graphicToken();

        // ISO 6.4.3 Variables
        if(char == Char.underscore || Char.isCapitalLetter(char)) return variableToken();

        // ISO 6.4.4/5 Integer and floating point numbers
        if(Char.isDecimalDigit(char)) return readNumber(char);

        // ISO 6.4.6 Doubled quoted lists, aka Strings

        // ISO 6.4.7 Back quoted strings

        return finished;
    }

    function readNumber(char: String): LexerResult {
        if(char == "0") {
            final next = line.charAt(index + 1);
            if(next == Char.binaryConstantIndicator) return readBinaryConstant();
            if(next == Char.octalConstantIndicator) return readOctalConstant();
            if(next == Char.hexadecimalConstantIndicator) return readHexConstant();
            if(next == Char.singleQuote) return readCharCodeConstant();
        }

        while(Char.isDecimalDigit(line.charAt(++index))) {}

        // float nums are extensions of integers
        final floatNum = readFloatingPoint();
        if(floatNum != null) return floatNum;

        final value = Std.parseInt(capture());
        if(value != null) {
            return token(integer(value));
        }

        return oops(badIntegerValue(start));
    }

    function readHexConstant(): LexerResult {
        index++; //skip to the "x"
        while(Char.isHexadecimalDigit(line.charAt(++index))) {}

        final value = Std.parseInt(capture()); // this handles hex
        if(value != null) {
            return token(integer(value));
        }

        return oops(badHexValue(start));
    }

    function readFloatingPoint(): Null<LexerResult> {
        // According to ISO floats must have a fractional part before any exponent
        final point = line.charAt(index);
        final digit = line.charAt(index+1);
        if(point != Char.decimalPoint || ! Char.isDecimalDigit(digit)) return null;

        index++; // skip the point
        while(Char.isDecimalDigit(line.charAt(++index))) {}

        final exponent = line.charAt(index);
        if(Char.isExponent(exponent)) {
            index++; // skip the E

            // skip any sign
            final sign = line.charAt(index);
            if(sign == Char.positiveSign || sign == Char.negativeSign) index++;

            final expDigit = line.charAt(index);
            if( ! Char.isDecimalDigit(expDigit)) return oops(badFloatValue(start));

            while(Char.isDecimalDigit(line.charAt(++index))) {}
        }

        final value = Std.parseFloat(capture()); // this handles hex
        if(value != null) {
            return token(float(value));
        }

        return oops(badFloatValue(start));
    }

    function readBinaryConstant(): LexerResult {
        index++; //skip to the "b"
        while(Char.isBinaryDigit(line.charAt(++index))) {}

        var digitString = capture();
        if(digitString.length < 3) return oops(badBinaryValue(start));
        var digits = digitString.substring(2).split("");  //drop the prefix and split into digits
        digits.reverse();

        // make value by processing each digit
        var value = 0;
        var power = 1;
        for(digit in digits) {
            if(digit == "1") {
                value += power;
            }

            power *= 2;
        }

        return token(integer(value));
    }

    function readOctalConstant(): LexerResult {
        index++; //skip to the "o"
        while(Char.isOctalDigit(line.charAt(++index))) {}

        var digitString = capture();
        if(digitString.length < 3) return oops(badOctalValue(start));
        var digits = digitString.substring(2).split("");  //drop the prefix and split into digits
        digits.reverse();

        // make value by processing each digit
        var value = 0;
        var power = 1;
        for(digit in digits) {
            if(digit != "0") {
                final digitValue = Std.parseInt(digit);
                if(digitValue != null) {
                    value += digitValue * power;
                }
                else {
                    return oops(badOctalValue(start));
                }                
            }

            power *= 8;
        }

        return token(integer(value));
    }

    function readCharCodeConstant(): LexerResult {
        // TODO:
        return finished;
    }

    function quotedAtom(): LexerResult {
        this.start.col++; // skip the opening single quote

        final buf = new StringBuf();  // since this can span lines

        while(Char.isAlphanumeric(line.charAt(index))) index++;
        // index is now at non-alpha char or EOL

        return token(name(capture()));
    }

    function variableToken(): LexerResult {
        while(Char.isAlphanumeric(line.charAt(++index))) {}
        return token(variable(capture()));
    }

    function letterDigitToken(): LexerResult {
        while(Char.isAlphanumeric(line.charAt(++index))) {}
        return token(name(capture()));
    }

    function graphicToken(): LexerResult {
        while(Char.isGraphicToken(line.charAt(++index))) {}
        return token(name(capture()));
    }

    // Make a token result from current state
    inline function token(token: Token): LexerResult { 
        return LexerResult.token(token, start);
    }

    // capture the text from the start pos up to the index (exclusive)
    inline function capture(): String {
        return line.substring(start.col-1, index);
    }

    // Make a token result for a single char token and advance the index
    inline function charToken(token: Token): LexerResult { 
        final result = LexerResult.token(token, start);
        index++;
        return result;
    }

    // Make a result for finished or problem state
    function stateResult(): LexerResult {
        switch(state) {
            case problem(p): return problem(p);
            default: return finished;
        }
    }
    
    // Set state and return problem
    inline function oops(p: LexerProblem): LexerResult {
        state = problem(p);
        return problem(p);
    }

    // Consume whitespace and comments.
    // On return index points at char after whitespace.
    // Return false if nothing was consumed.
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
        final commentStart = here();
        index += 2; // first char after "/*"

        while(state.match(ready)) {
            final end = line.indexOf(Char.commentEnd, index);
            if(end >= 0) {
                index += Char.commentEnd.length;
                return;
            }

            readNextLine();
            if(state.match(finished)) {
                state = problem(unterminatedBlockComment(commentStart));
            }
        }
    }

    function readNextLine() {
        try {
            line = input.readLine();
            lineNum++;
            index = 0;
            state = ready;
        } 
        catch(_: haxe.io.Eof) {
            state = finished;
        }
        catch(e) {
            state = problem(exception(e));
        }
    }

    // Capture the curent line and index as a position
    inline function here(offset: Int = 0): CharPosition {
        return {line: this.lineNum, col: this.index + 1 + offset};
    }

    // Return true if current position is still the same as the given one
    inline function stillHere(pos: CharPosition): Bool {
        return this.lineNum == pos.line && this.index == pos.col - 1;
    }
} 

import "./token" for Token, Tok

var EOFChar = "\0"

class Lexer {
	input { _input }
	
	pos { _pos }
	readPos { _readPos }

	char { _char }
	char=(char) {
		_char = char
	}

	construct new(input) {
		_pos = -1
		_readPos = 0
		_input = input
		readChar()
	}
	
	iterate(obj) {
		return this
	}

	iteratorValue(obj) {
		return nextToken()
	}
	
	nextToken() {
		var tok = null

		skipSpace()

		if (_char == "=") {
			if (peekChar() == "=") {
				var ch = _char
				readChar()
				var lit = ch + _char
				tok = Token.new(Tok["EQ_EQ"], lit)
			} else {
				tok = Token.new(Tok["EQ"], _char)
			}
		} else if (_char == "+") {
			tok = Token.new(Tok["PLUS"], _char)
		} else if (_char == "-") {
			tok = Token.new(Tok["MINUS"], _char)
		} else if (_char == "!") {
			if (peekChar() == "=") {
				var ch = _char
				readChar()
				var lit = ch + _char
				tok = Token.new(Tok["BANG_EQ"], lit)
			} else {
				tok = Token.new(Tok["BANG"], _char)
			}
		} else if (_char == "/") {
			tok = Token.new(Tok["SOL"], _char)
		} else if (_char == "*") {
			tok = Token.new(Tok["STAR"], _char)
		} else if (_char == "<") {
			tok = Token.new(Tok["LT"], _char)
		} else if (_char == ">") {
			tok = Token.new(Tok["GT"], _char)
		} else if (_char == ":") {
			tok = Token.new(Tok["COLON"], _char)
		} else if (_char == ",") {
			tok = Token.new(Tok["COMMA"], _char)
		} else if (_char == "(") {
			tok = Token.new(Tok["LPAREN"], _char)
		} else if (_char == ")") {
			tok = Token.new(Tok["RPAREN"], _char)
		} else if (_char == "{") {
			tok = Token.new(Tok["LBRACE"], _char)
		} else if (_char == "}") {
			tok = Token.new(Tok["RBRACE"], _char)
		} else if (_char == "[") {
			tok = Token.new(Tok["LBRACK"], _char)
		} else if (_char == "]") {
			tok = Token.new(Tok["RBRACK"], _char)
		} else if (_char == "\n") {
			tok = Token.new(Tok["NEWLINE"], _char)
		} else if (_char == "\"") {
			var lit = readString()
			tok = Token.new(Tok["STRING_LIT"], lit)
		} else if (_char == EOFChar) {
			tok = Token.new(Tok["EOF"], "")
		} else {
			if (isAlpha(_char)) {
				var lit = readIdentifier()
				var kind = lookupIdent(lit)
				tok = Token.new(kind, lit)
				return tok
			} else if (isDigit(_char)) {
				var lit = readNumber()
				tok = Token.new(Tok["NUMBER_LIT"], lit)
				return tok
			} else {
				tok = Token.new(Tok["EOF"], "illegal")
			}
		}
		readChar()
		return tok
	}
	
	skipSpace() {
		while (_char == " " || _char == "\t" || _char == "\r") {
			readChar()
		}
	}
	
	readChar() {
		if (_readPos != null && _readPos >= _input.count) {
			_char = EOFChar
		} else {
			_char = _input[_readPos]
		}
		_pos = _readPos
		_readPos = _readPos + 1
	}
	
	peekChar() {
		if (_readPos >= _input.count) {
			return EOFChar
		} else {
			return _input[_readPos]
		}
	}
	
	readIdentifier() {
		var pos = _pos
		while (isAlnum(_char)) {
			readChar()
		}
		var res = _input[pos..._pos]
		return res
	}
	
	readNumber() {
		var pos = _pos
		while (isDigit(_char)) {
			readChar()
		}
		var res = _input[pos..._pos]
		return res
	}
	
	readString() {
		var pos = _pos + 1
		while (true) {
			readChar()
			if (_char == "\"" || _char == "\0") {
				break
			}
		}
		var res = _input[pos..._pos]
		return res
	}

	isAlnum(char) {
		return isAlpha(char) || isDigit(char)
	}
	
	isAlpha(char) {
		if (char is String == false) {
			Fiber.abort("isAlpha expected String")
		}
		var ch = char.codePoints[0]
		return ("a".codePoints[0] <= ch &&
			ch <= "z".codePoints[0] ||
			"A".codePoints[0] <= ch &&
			ch <= "Z".codePoints[0] ||
			ch == "_".codePoints[0])
	}
	
	isDigit(char) {
		if (char is String == false) {
			Fiber.abort("isDigit expected String")
		}
		var ch = char.codePoints[0]
		return ("0".codePoints[0] <= ch &&
			ch <= "9".codePoints[0])
	}

	lookupIdent(ident) {
		var keywords = {
			"break":    	Tok["BREAK"],
			"continue":    	Tok["CONTINUE"],
			"var":    	Tok["VAR"],
			"true":   	Tok["TRUE"],
			"false":  	Tok["FALSE"],
			"if":     	Tok["IF"],
			"else":   	Tok["ELSE"],
			"return": 	Tok["RETURN"],
		}
		
		if (keywords.containsKey(ident)) {
			return keywords[ident]
		}
		
		return Tok["IDENT"]
	}
}

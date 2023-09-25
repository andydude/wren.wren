class PrattEntry {
	// kind is a number like TokenKind["PLUS"]
	kind { _kind }

	// prec is a number like 2
	prec { _prec }

	// assoc is a boolean like
	// false, implying Left-associative
	// true, implying Right-associative
	assoc { _assoc }

	// parser is a function
	parser { _parser }

	construct new(kind, prec, assoc, parser) {
		_kind = kind
		_prec = prec
		_assoc = assoc
		_parser = parser
	}
}

class PrattParser {
	lexer { _lexer }
	previousToken { _previousToken }
	nextToken { _nextToken }
	defaultPrec { _defaultPrec }
	prefixTable { _prefixTable }
	infixTable { _infixTable }
	
	construct new(lexer, defaultPrec, prefixTable, infixTable) {
		_lexer = lexer
		_previousToken = null
		_nextToken = null
		_defaultPrec = defaultPrec
		_prefixTable = prefixTable
		_infixTable = infixTable
	}

	// monkey nextToken()
	// lox advance()
	advance() {

		// monkey .curToken
		// lox .previous
		_previousToken = _nextToken

		// monkey .peekToken
		// lox .current
		_nextToken = _lexer.nextToken()
	}
	
	// monkey expectPeek
	// lox match
	match(kind) {
		if (!check(kind)) {
			return false
		}
		advance()
		return true
	}

	// monkey peekTokenIs
	// lox check
	check(kind) {
		return _nextToken.kind == kind
	}

	isEndish(token) {
		if (token.kind.name == "EOF") {
			return true
		}
		if (token.kind.name == "COMMA") {
			return true
		}
		if (token.kind.name == "RPAREN") {
			return true
		}
		if (token.kind.name == "RBRACK") {
			return true
		}
		if (token.kind.name == "RBRACE") {
			return true
		}
		if (token.kind.name == "NEWLINE") {
			return true
		}
		
		return false
	}
	
	// monkey peekPrecedence
	// lox 
	getPrecedence(opToken) {
		var prec = _infixTable[opToken.kind.value]
		if (prec == null) {
			return _defaultPrec
		}
		return prec
	}
	
	parsePrecedence(minPrec) {
		if (isEndish(_nextToken)) {
			return null
		}
		
		var left = parsePrefixSelector(_nextToken)
		var prec = 0
		if (left == null) {
			return null
		}

		while (true) {
			if (isEndish(_nextToken)) {
				break
			}
			
			prec = getPrecedence(_nextToken)
			if (prec.value > minPrec.value) {
				System.print("Got bad precedence")
				break
			}
			
			advance()

			var right = parseInfixSelector(_previousToken, left)
			if (right == null) {
				System.print("Got null right")
				break
			}
			left = right
		}
		return left
	}
}

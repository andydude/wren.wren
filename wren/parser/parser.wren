import "./ast" for
	ArrayLiteral,
	BinaryExpression,
	BlockStatement,
	BooleanLiteral,
	CallExpression,
	ClassDeclaration,
	ConditionExpression,
	ConditionStatement,
	DotExpression,
	EmptyLiteral,
	ExpressionStatement,
	FunctionDeclaration,
	HashMapLiteral,
	HashMemberNode,
	Identifier,
	IndexExpression,
	NumberLiteral,
	Program,
	ReturnStatement,
	StatementDeclaration,
	StringLiteral,
	VariableDeclaration,
	WhileStatement,
	UnaryExpression

import "./token" for Token, Tok, Prec
import "./pratt" for PrattEntry, PrattParser


class Parser is PrattParser {
	construct new(lexer) {
		var prefixTable = List.filled(Tok["LAST"].value, null)
		var infixTable = List.filled(Tok["LAST"].value, null)

		// prefix operators

		prefixTable[Tok["IDENT"].value] = PrattEntry.new(
			Tok["IDENT"], Prec["PRE"], false,
			Fn.new {|o| this.parseIdentifier()})
		prefixTable[Tok["NUMBER_LIT"].value] = PrattEntry.new(
			Tok["NUMBER_LIT"], Prec["PRE"], false,
			Fn.new {|o| this.parseNumberLiteral()})
		prefixTable[Tok["STRING_LIT"].value] = PrattEntry.new(
			Tok["STRING_LIT"], Prec["PRE"], false,
			Fn.new {|o| this.parseStringLiteral()})
		prefixTable[Tok["BANG"].value] = PrattEntry.new(
			Tok["BANG"], Prec["PRE"], false,
			Fn.new {|o| this.parsePrefixExpression(o)})
		prefixTable[Tok["TILDE"].value] = PrattEntry.new(
			Tok["TILDE"], Prec["PRE"], false,
			Fn.new {|o| this.parsePrefixExpression(o)})
		prefixTable[Tok["MINUS"].value] = PrattEntry.new(
			Tok["MINUS"], Prec["PRE"], false,
			Fn.new {|o| this.parsePrefixExpression(o)})
		prefixTable[Tok["FALSE"].value] = PrattEntry.new(
			Tok["FALSE"], Prec["PRE"], false,
			Fn.new {|o| this.parseBooleanLiteral()})
		prefixTable[Tok["TRUE"].value] = PrattEntry.new(
			Tok["TRUE"], Prec["PRE"], false,
			Fn.new {|o| this.parseBooleanLiteral()})
		prefixTable[Tok["NULL"].value] = PrattEntry.new(
			Tok["NULL"], Prec["PRE"], false,
			Fn.new {|o| this.parseBooleanLiteral()})
		prefixTable[Tok["LBRACE"].value] = PrattEntry.new(
			Tok["LBRACE"], Prec["PRE"], false,
			Fn.new {|o| this.parseHashMapLiteral()})
		prefixTable[Tok["LBRACK"].value] = PrattEntry.new(
			Tok["LBRACK"], Prec["PRE"], false,
			Fn.new {|o| this.parseArrayLiteral()})
		prefixTable[Tok["LPAREN"].value] = PrattEntry.new(
			Tok["LPAREN"], Prec["PRE"], false,
			Fn.new {|o| this.parseGroupExpression()})

		// infix operators

		infixTable[Tok["DOT"].value] = PrattEntry.new(
			Tok["DOT"], Prec["POST"], false,
			Fn.new {|o, t| this.parseDotExpression(t)})
		infixTable[Tok["LPAREN"].value] = PrattEntry.new(
			Tok["LPAREN"], Prec["POST"], false,
			Fn.new {|o, t| this.parseCallExpression(t)})
		infixTable[Tok["LBRACE"].value] = PrattEntry.new(
			Tok["LBRACE"], Prec["POST"], false,
			Fn.new {|o, t| this.parseFunctionExpression(t)})
		infixTable[Tok["LBRACK"].value] = PrattEntry.new(
			Tok["LBRACK"], Prec["POST"], false,
			Fn.new {|o, t| this.parseIndexExpression(t)})
		infixTable[Tok["STAR"].value] = PrattEntry.new(
			Tok["STAR"], Prec["FACTOR"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["SOL"].value] = PrattEntry.new(
			Tok["SOL"], Prec["FACTOR"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["PCT"].value] = PrattEntry.new(
			Tok["PCT"], Prec["FACTOR"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["PLUS"].value] = PrattEntry.new(
			Tok["PLUS"], Prec["TERM"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["MINUS"].value] = PrattEntry.new(
			Tok["MINUS"], Prec["TERM"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["EQ_EQ"].value] = PrattEntry.new(
			Tok["EQ_EQ"], Prec["EQUAL"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["BANG_EQ"].value] = PrattEntry.new(
			Tok["BANG_EQ"], Prec["EQUAL"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["GT"].value] = PrattEntry.new(
			Tok["GT"], Prec["REL"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["LT"].value] = PrattEntry.new(
			Tok["LT"], Prec["REL"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["QUEST"].value] = PrattEntry.new(
			Tok["QUEST"], Prec["COND"], false,
			Fn.new {|o, t| this.parseConditionExpression(o, t)})
		infixTable[Tok["COLON"].value] = PrattEntry.new(
			Tok["COLON"], Prec["COND"], false,
			Fn.new {|o, t| this.parseHashMemberNode(o, t)})

		super(lexer, Prec["LAST"], prefixTable, infixTable)
		advance()
	}

	parseProgram() {
		var decls = []
		while (!match(Tok["EOF"])) {
			var decl = parseDeclaration()
			if (decl != null) {
				decls.add(decl)
			}
			advance()
		}
		var program = Program.new(
			BlockStatement.new(decls))
		return program
	}

	parseIdentifier() {
		var name = this.nextToken.text
		advance()
		return Identifier.new(name)
	}

	parseDeclaration() {
		if (check(Tok["CLASS"])) {
			return parseClassDeclaration()
		} else if (check(Tok["FOREIGN"])) {
			return parseClassDeclaration()
		} else if (check(Tok["IMPORT"])) {
			return parseImportDeclaration()
		} else if (check(Tok["VAR"])) {
			return parseVariableDeclaration()
		} else {
			return StatementDeclaration.new(parseStatement())
		}
	}
	
	parseClassDeclaration() {
	}
	parseImportDeclaration() {
	}

	parseStatement() {
		if (check(Tok["RETURN"])) {
			return parseReturnStatement()
		} else if (check(Tok["IF"])) {
			return parseConditionStatement()
		} else if (check(Tok["WHILE"])) {
			return parseWhileStatement()
		} else {
			return parseExpressionStatement()
		}
	}

	parseVariableDeclaration() {
		if (!match(Tok["VAR"])) {
			Fiber.abort("expected 'let'")
			return null
		}
		var name = parseIdentifier()
		if (!match(Tok["EQ"])) {
			Fiber.abort("expected '='")
			return null
		}
		var value = parseExpression()
		if (!match(Tok["NEWLINE"])) {
			Fiber.abort("expected ';'")
		}
		return VariableDeclaration.new(name, value)
	}

	parseReturnStatement() {
		if (!match(Tok["RETURN"])) {
			return null
		}
		var value = parseExpression()
		if (!match(Tok["NEWLINE"])) {
			Fiber.abort("expected ';'")
		}
		return ReturnStatement.new(value)
	}

	parseExpressionStatement() {
		var expr = parseExpression()
		System.print("= " + this.nextToken.kind.name)
		if (!isEndish(this.nextToken)) {
			if (!match(Tok["NEWLINE"])) {
				Fiber.abort("expected ';'")
			}
		}
		return ExpressionStatement.new(expr)
	}

	parseExpression() {
		return parsePrecedence(Prec["LAST"])
	}

	parseNumberLiteral() {
		var valuestr = super.nextToken.text
		var value = Num.fromString(valuestr)
		advance()
		return NumberLiteral.new(value)
	}

	parseStringLiteral() {
		var value = super.nextToken.text
		advance()
		return StringLiteral.new(value)
	}

	parseBooleanLiteral() {
		var valuestr = super.nextToken.text
		advance()
		if (valuestr == "true") {
			return BooleanLiteral.new(true)
		} else if (valuestr == "false") {
			return BooleanLiteral.new(false)
		} else if (valuestr == "null") {
			return EmptyLiteral.new()
		} else {
			return null
		}
	}

	parseGroupExpression() {
		if (!match(Tok["LPAREN"])) {
			return null
		}
		var expr = parseExpression()
		if (!match(Tok["RPAREN"])) {
			return null
		}
		return expr
	}

	parseWhileStatement() {
		if (!match(Tok["WHILE"])) {
			return null
		}
		if (!match(Tok["LPAREN"])) {
			return null
		}
		var cond = parseExpression()
		if (!match(Tok["RPAREN"])) {
			return null
		}
		if (!check(Tok["LBRACE"])) {
			return null
		}
		var iterBlock = parseBlockStatement()
		return WhileStatement.new(cond, iterBlock)
	}
	parseConditionStatement() {
		if (!match(Tok["IF"])) {
			return null
		}
		if (!match(Tok["LPAREN"])) {
			return null
		}
		var cond = parseExpression()
		if (!match(Tok["RPAREN"])) {
			return null
		}
		if (!check(Tok["LBRACE"])) {
			return null
		}
		var thenBlock = parseBlockStatement()
		if (match(Tok["ELSE"])) {
			var elseBlock = parseBlockStatement()
			return ConditionStatement.new(cond, thenBlock, elseBlock)
		} else {
			return ConditionStatement.new(cond, thenBlock, null)
		}
	}


	// Precondition:
	// last == LBRACE
	// cur == Statement
	parseBlockStatement() {
		return parseFunctionExpression()
	}
	
	parseFunctionExpression() {
		System.print("funcExp0")
		return parseFunctionExpression(null)
	}
	
	parseFunctionExpression(target) {
		System.print("funcExp1" + target.toString)
		System.print(super.nextToken.kind.name)
		if (super.previousToken.kind != Tok["LBRACE"]) {
			if (!match(Tok["LBRACE"])) {
				return null
			}
		}
		var parms = []
		if (target != null) {
			System.print("Parsing parameters")
			if (!match(Tok["OR"])) {
				return null
			}
			parms = parseFunctionParameters()
			System.print(parms.toString)
			if (!match(Tok["OR"])) {
				return null
			}
		} else {
			System.print("target is NULL!")
		}
		//var body = parseBlockStatement()
		var body = null
		if (check(Tok["NEWLINE"])) {
			var decls = []
			while (!check(Tok["RBRACE"])) {
				var decl = parseDeclaration()
				if (decl != null) {
					decls.add(decl)
				}
			}
			body = BlockStatement.new(decls)
		} else {
			var expr = parseExpression()
			body = ExpressionStatement.new(expr)
		}
		if (!match(Tok["RBRACE"])) {
			return null
		}

		return FunctionDeclaration.new(
			null, parms, body)
	}

	parseFunctionParameters() {
		var idents = []
		if (!check(Tok["IDENT"])) {
			return []
		}
		var ident = parseIdentifier()
		idents.add(ident)
		while (match(Tok["COMMA"])) {
			ident = parseIdentifier()
			idents.add(ident)
		}
		return idents
	}

	parseFunctionArguments() {
		var exprs = []
		if (check(Tok["RPAREN"])) {
			return []
		}
		if (check(Tok["RBRACK"])) {
			return []
		}
		if (check(Tok["RBRACE"])) {
			return []
		}
		var expr = parseExpression()
		exprs.add(expr)
		while (match(Tok["COMMA"])) {
			expr = parseExpression()
			exprs.add(expr)
		}
		return exprs
	}

	parseArrayLiteral() {
		if (!match(Tok["LBRACK"])) {
			Fiber.abort("expected '['")
		}
		var exprs = parseFunctionArguments()
		// System.print("found exprs.count " + exprs.count.toString)
		// System.print("found expr[0] " + exprs[0].toString)
		if (!match(Tok["RBRACK"])) {
			Fiber.abort("expected ']'")
		}
		return ArrayLiteral.new(exprs)
	}

	parseHashMapLiteral() {
		if (!match(Tok["LBRACE"])) {
			return null
		}
		var expr = parseFunctionArguments()
		if (!match(Tok["RBRACE"])) {
			return null
		}
		return HashMapLiteral.new(expr)
	}

	parsePrefixSelector(opToken) {
		System.print("prefixSel " + opToken.kind.name)
		var opDef = super.prefixTable[
			opToken.kind.value]
		if (opDef == null) {
			Fiber.abort("expected prefix table entry for " + opToken.kind.name)
			return null
		}

		return opDef.parser.call(opToken)
	}
	parsePrefixExpression(opToken) {
		System.print("prefixExp " + opToken.kind.name)
		advance()
		var right = parsePrecedence(Prec["PRE"])
		return UnaryExpression.new(opToken, right)
	}

	parseInfixSelector(opToken, left) {
		System.print("infixSel " + opToken.kind.name)
		var opDef = super.infixTable[
			opToken.kind.value]
		if (opDef == null) {
			Fiber.abort("expected infix table entry for " + opToken.kind.name)
			return null
		}

		return opDef.parser.call(opToken, left)
	}

	parseInfixExpression(opToken, left) {
		// System.print("infixExp " + opToken.kind.name)
		//advance()
		var opDef = super.infixTable[opToken.kind.value]
		var right = parsePrecedence(opDef.prec)
		return BinaryExpression.new(opToken, left, right)
	}

	parseConditionExpression(opToken, left) {
		var opDef = super.infixTable[opToken.kind.value]
		var right = parsePrecedence(opDef.prec)
		if (right is HashMemberNode == false) {
			Fiber.abort("expected colon")
		}

		var mid = right.left
		var right2 = right.right
		return ConditionExpression.new(left, mid, right2)
	}
	parseHashMemberNode(opToken, left) {
		var opDef = super.infixTable[opToken.kind.value]
		var right = parsePrecedence(opDef.prec)
		return HashMemberNode.new(opToken, left, right)
	}

	parseDotExpression(target) {
		match(Tok["DOT"])
		var name = parseIdentifier()
		return DotExpression.new(target, name)
	}

	parseCallExpression(target) {
		match(Tok["LPAREN"])
		var args = parseFunctionArguments()
		match(Tok["RPAREN"])
		return CallExpression.new(target, args)
	}

	parseCallBlockExpression(target) {
		var block = parseFunctionExpression()
		return CallExpression.new(target, args)
	}

	parseIndexExpression(target) {
		match(Tok["LBRACK"])
		var args = parseExpression()
		match(Tok["RBRACK"])
		return IndexExpression.new(target, args)
	}

}

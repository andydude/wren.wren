import "./token" for Token, Tok, Prec
import "./pratt" for PrattEntry, PrattParser
import "../ast/ast" for
	ArrayLiteral,
	BinaryExpression,
	BlockStatement,
	BooleanLiteral,
	CallExpression,
	ClassDeclaration,
	ConditionExpression,
	ConditionStatement,
	EmptyLiteral,
	ExpressionStatement,
	FunctionDeclaration,
	HashMapLiteral,
	HashMemberNode,
	Identifier,
	IndexExpression,
	NumberLiteral,
	VariableStatement,
	Program,
	ReturnStatement,
	StringLiteral,
	UnaryExpression
	// Newlines can appear after Commas


class Parser is PrattParser {
	construct new(lexer) {
		var prefixTable = List.filled(Tok["LAST"].value, null)
		var infixTable = List.filled(Tok["LAST"].value, null)

		// prefix operators

		prefixTable[Tok["BANG"].value] = PrattEntry.new(
			Tok["BANG"], Prec["PRE"], false,
			Fn.new {|o| this.parsePrefixExpression(o)})
		prefixTable[Tok["MINUS"].value] = PrattEntry.new(
			Tok["MINUS"], Prec["PRE"], false,
			Fn.new {|o| this.parsePrefixExpression(o)})
		//prefixTable[Tok["IF"].value] = PrattEntry.new(
		//	Tok["IF"], Prec["PRE"], false,
		//	Fn.new {|o| this.parseConditionExpression()})
		prefixTable[Tok["IDENT"].value] = PrattEntry.new(
			Tok["IDENT"], Prec["PRE"], false,
			Fn.new {|o| this.parseIdentifier()})
		//prefixTable[Tok["FUNCTION"].value] = PrattEntry.new(
		//	Tok["FUNCTION"], Prec["PRE"], false,
		//	Fn.new {|o| this.parseFunctionExpression()})
		prefixTable[Tok["NUMBER_LIT"].value] = PrattEntry.new(
			Tok["NUMBER_LIT"], Prec["PRE"], false,
			Fn.new {|o| this.parseNumberLiteral()})
		prefixTable[Tok["STRING_LIT"].value] = PrattEntry.new(
			Tok["STRING_LIT"], Prec["PRE"], false,
			Fn.new {|o| this.parseStringLiteral()})
		prefixTable[Tok["FALSE"].value] = PrattEntry.new(
			Tok["FALSE"], Prec["PRE"], false,
			Fn.new {|o| this.parseBooleanLiteral()})
		prefixTable[Tok["TRUE"].value] = PrattEntry.new(
			Tok["TRUE"], Prec["PRE"], false,
			Fn.new {|o| this.parseBooleanLiteral()})
		// prefixTable[Tok["NULL"].value] = PrattEntry.new(
		// 	Tok["NULL"], Prec["PRE"], false,
		// 	Fn.new {|o| this.parseBooleanLiteral()})
		prefixTable[Tok["LBRACE"].value] = PrattEntry.new(
			Tok["LBRACE"], Prec["PRE"], false,
			Fn.new {|o| this.parseHashLiteral()})
		prefixTable[Tok["LBRACK"].value] = PrattEntry.new(
			Tok["LBRACK"], Prec["PRE"], false,
			Fn.new {|o| this.parseArrayLiteral()})
		prefixTable[Tok["LPAREN"].value] = PrattEntry.new(
			Tok["LPAREN"], Prec["PRE"], false,
			Fn.new {|o| this.parseGroupExpression()})

		// infix operators

		infixTable[Tok["LPAREN"].value] = PrattEntry.new(
			Tok["LPAREN"], Prec["POST"], false,
			Fn.new {|o, t| this.parseCallExpression(t)})
		infixTable[Tok["LBRACK"].value] = PrattEntry.new(
			Tok["LBRACK"], Prec["POST"], false,
			Fn.new {|o, t| this.parseIndexExpression(t)})
		infixTable[Tok["STAR"].value] = PrattEntry.new(
			Tok["STAR"], Prec["FACTOR"], false,
			Fn.new {|o, t| this.parseInfixExpression(o, t)})
		infixTable[Tok["SOL"].value] = PrattEntry.new(
			Tok["SOL"], Prec["FACTOR"], false,
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
		infixTable[Tok["COLON"].value] = PrattEntry.new(
			Tok["COLON"], Prec["KEY"], false,
			Fn.new {|o, t| this.parseKeyLiteral(o, t)})

		super(lexer, Prec["LAST"], prefixTable, infixTable)
		advance()
	}

	parseProgram() {
		var stmts = []
		while (!match(Tok["EOF"])) {
			var stmt = parseStatement()
			if (stmt != null) {
				stmts.add(stmt)
			}
			advance()
		}
		var program = Program.new(
			BlockStatement.new(stmts))
		return program
	}

	parseIdentifier() {
		var name = this.nextToken.text
		advance()
		return Identifier.new(name)
	}

	parseStatement() {
		if (check(Tok["VAR"])) {
			return parseVariableStatement()
		} else if (check(Tok["RETURN"])) {
			return parseReturnStatement()
		// } else if (check(Tok["LBRACE"])) {
		// 	return parseBlockStatement()
		} else {
			return parseExpressionStatement()
		}
	}

	parseVariableStatement() {
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
		return VariableStatement.new(name, value)
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
		if (!match(Tok["NEWLINE"])) {
			Fiber.abort("expected ';'")
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

	parseIfExpression() {
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
			return ConditionExpression.new(cond, thenBlock, elseBlock)
		} else {
			return ConditionExpression.new(cond, thenBlock, null)
		}
	}

	// Precondition:
	// last == LBRACE
	// cur == Statement
	parseBlockStatement() {
		if (!match(Tok["LBRACE"])) {
			return null
		}
		var stmts = []
		while (!check(Tok["RBRACE"])) {
			var stmt = parseStatement()
			if (stmt != null) {
				stmts.add(stmt)
			}
		}
		if (!match(Tok["RBRACE"])) {
			return null
		}
		return BlockStatement.new(stmts)
	}

	//parseFunctionDeclaration() {
	//	System.print(super.nextToken.kind.name)
	//
	//	if (!match(Tok["FUNCTION"])) {
	//		return null
	//	}
	//	var name = null
	//	System.print(super.nextToken.kind.name)
	//	if (check(Tok["IDENT"])) {
	//		name = parseIdentifier()
	//	}
	//	System.print(super.nextToken.kind.name)
	//	if (!match(Tok["LPAREN"])) {
	//		return null
	//	}
	//	System.print(super.nextToken.kind.name)
	//	var parms = parseFunctionParameters()
	//	System.print(super.nextToken.kind.name)
	//	if (!match(Tok["RPAREN"])) {
	//		return null
	//	}
	//	if (!check(Tok["LBRACE"])) {
	//		return null
	//	}
	//	var body = parseBlockStatement()
	//	return FunctionDeclaration.new(
	//		name, parms, body)
	//
	//}

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
		// System.print("prefixSel " + opToken.kind.name)
		var opDef = super.prefixTable[
			opToken.kind.value]
		if (opDef == null) {
			Fiber.abort("expected prefix table entry for " + opToken.kind.name)
			return null
		}

		return opDef.parser.call(opToken)
	}
	parsePrefixExpression(opToken) {
		// System.print("prefixExp " + opToken.kind.name)
		//advance()
		var right = parsePrecedence(Prec["PRE"])
		return UnaryExpression.new(opToken, right)
	}

	parseInfixSelector(opToken, left) {
		// System.print("infixSel " + opToken.kind.name)
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

	parseKeyLiteral(opToken, left) {
		var right = parseExpression()
		return HashMemberNode.new(left, right)
	}

	parseCallExpression(target) {
		match(Tok["LPAREN"])
		var args = parseFunctionArguments()
		match(Tok["RPAREN"])
		return CallExpression.new(target, args)
	}

	parseIndexExpression(target) {
		match(Tok["LBRACK"])
		var args = parseExpression()
		match(Tok["RBRACK"])
		return IndexExpression.new(target, args)
	}

}

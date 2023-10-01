import "../parser/ast" for
	ArrayLiteral,
	BinaryExpression,
	Declaration,
	BlockStatement,
	BooleanLiteral,
	CallExpression,
	ClassDeclaration,
	ConditionExpression,
	ConditionStatement,
	DotExpression,
	EmptyLiteral,
	Expression,
	ExpressionStatement,
	FunctionDeclaration,
	HashMapLiteral,
	HashMemberNode,
	Identifier,
	IndexExpression,
	Literal,
	LiteralExpression,
	Node,
	NumberLiteral,
	Program,
	ReturnStatement,
	Statement,
	StatementDeclaration,
	StringLiteral,
	UnaryExpression,
	VariableDeclaration,
	WhileStatement

import "./runtime" for
	ArrayRuntime,
	AstFunc,
	BooleanRuntime,
	EmptyRuntime,
	HashMapRuntime,
	NumberRuntime,
	ReturnValue,
	StringRuntime

import "./environment" for Environment

class Interpreter {
	construct new() {
	}

	eval(node, env) {
		if (node is Literal) {
			return evalLiteral(node, env)
		} else if (node is Expression) {
			return evalExpression(node, env)
		} else if (node is Statement) {
			return evalStatement(node, env)
		} else if (node is Declaration) {
			return evalDeclaration(node, env)
		} else if (node is Program) {
			return evalProgram(node, env)
		} else if (node is Node) {
			return evalNode(node, env)
		} else {
			Fiber.abort("expected AST node")
		}
	}

	evalProgram(node, env) {
		return evalBlockStatement(node.body, env)
	}

	evalDeclaration(node, env) {
		if (node is ClassDeclaration) {
			return evalClassDeclaration(node, env)
		} else if (node is VariableDeclaration) {
			return evalVariableDeclaration(node, env)
		} else if (node is StatementDeclaration) {
			return evalStatementDeclaration(node, env)
		} else {
			Fiber.abort("evalDeclaration " + node.type.toString)
		}
	}

	evalStatementDeclaration(node, env) {
		return evalStatement(node.statement, env)
	}

	evalStatement(node, env) {
		if (node is BlockStatement) {
			return evalBlockStatement(node, env)
		} else if (node is ConditionStatement) {
			return evalConditionStatement(node, env)
		} else if (node is ReturnStatement) {
			return evalReturnStatement(node, env)
		} else if (node is VariableDeclaration) {
			return evalVariableDeclaration(node, env)
		} else if (node is WhileStatement) {
			return evalWhileStatement(node, env)
		} else if (node is ExpressionStatement) {
			return evalExpressionStatement(node, env)
		} else {
			Fiber.abort("evalStatement " + node.type.toString)
		}
	}

	evalWhileStatement(node,  env) {
		// TODO
		return evalStatement(node.body, env)
	}

	evalBlockStatement(node,  env) {
		var result = null

		for (decl in node.statements) {
			result = this.evalDeclaration(decl, env)
		}

		return result
	}

	evalVariableDeclaration(node, env) {
		var val = eval(node.value, env)
		if (isError(val)) {
			return val
		}
		env[node.name.name] = val
	}

	evalReturnStatement(node, env) {
		var val = eval(node.returnValue, env)
		if (isError(val)) {
			return val
		}
		return ReturnValue.new(val)
	}

	evalExpressionStatement(node, env) {
		return evalExpression(node.expression, env)
	}

	evalExpression(node, env) {
		if (node is ConditionExpression) {
			return evalConditionExpression(node, env)
		//} else if (node is FunctionDeclaration) {
		//	return evalFunctionDeclaration(node, env)
		} else if (node is BinaryExpression) {
			return evalBinaryExpression(node, env)
		} else if (node is UnaryExpression) {
			return evalUnaryExpression(node, env)
		} else if (node is DotExpression) {
			return evalDotExpression(node, env)
		} else if (node is CallExpression) {
			return evalCallExpression(node, env)
		} else if (node is IndexExpression) {
			return evalIndexExpression(node, env)
		} else if (node is LiteralExpression) {
			return evalLiteralExpression(node, env)
		} else if (node is Literal) {
			return evalLiteral(node, env)
		} else if (node is Identifier) {
			return evalIdentifier(node, env)
		} else if (node is FunctionDeclaration) {
			return node
		} else {
			Fiber.abort("evalExpression " + node.type.toString)
		}
	}

	evalBinaryExpression(node, env) {
		var fn = null
		if (node.operator.text == "+") {
			fn = Fn.new {|a, b| a + b}
		} else if (node.operator.text == "-") {
			fn = Fn.new {|a, b| a - b}
		} else if (node.operator.text == "*") {
			fn = Fn.new {|a, b| a * b}
		} else if (node.operator.text == "/") {
			fn = Fn.new {|a, b| a / b}
		} else if (node.operator.text == "\%") {
			fn = Fn.new {|a, b| (a % b)}
		}
		if (fn == null) {
			Fiber.abort("unrecognized binary operator " + node.operator.text)
		}
		var left = evalExpression(node.left, env)
		var right = evalExpression(node.right, env)
		return fn.call(left, right)
	}

	evalUnaryExpression(node, env) {
		var fn = null
		if (node.operator.text == "!") {
			fn = Fn.new {|a| (!a)}
		}
		if (node.operator.text == "~") {
			fn = Fn.new {|a| (~a)}
		}
		if (node.operator.text == "-") {
			fn = Fn.new {|a| (-a)}
		}
		if (fn == null) {
			Fiber.abort("unrecognized unary operator " + node.operator.text)
		}
		var inner = evalExpression(node.inner, env)
		return fn.call(inner)
	}

	evalConditionStatement(node, env) {
		var cond = evalExpression(node.condition, env)
		if (isTruthy(cond)) {
			return evalStatement(node.thenStatement, env)
		} else if (node.elseStatement != null) {
			return evalStatement(node.elseStatement, env)
		} else {
			return EmptyRuntime.new()
		}
	}

	evalConditionExpression(node, env) {
		var cond = evalExpression(node.condition, env)
		if (isTruthy(cond)) {
			return evalExpression(node.thenExpression, env)
		} else if (node.elseExpression != null) {
			return evalExpression(node.elseExpression, env)
		} else {
			return EmptyRuntime.new()
		}
	}

	evalFunctionDeclaration(node, env) {
	}

	evalDotExpression(node, env) {
		//var target = evalExpression(node.target, env)
		//System.print(node.name.type.toString)
		return evalExpression(Identifier.new(node.target.name + "." + node.name.name), env)
	}


	evalCallExpression(node, env) {
		var target = evalExpression(node.target, env)
		var args = evalExpressionList(node.args, env)
		return applyFunction(target, args)
	}

	evalCallBlockExpression(node, env) {
		var target = evalExpression(node.target, env)
		var args = evalExpressionList(node.args, env)
		return applyFunction(target, args)
	}

	evalIndexExpression(node, env) {
		return evalExpression(node.target, env)[evalExpression(node.index, env)]
	}

	evalIdentifier(node, env) {
		var builtins = {
			"System.print":
			Fn.new {|a| System.print(a)},
		}
		if (env.containsKey(node.name)) {
			var val = env[node.name]
			return val
		}

		if (builtins.containsKey(node.name)) {
			return builtins[node.name]
		}

		return newError("identifier not found")
	}

	evalLiteralExpression(node, env) {
		return evalLiteral(node.literal, env)
	}

	evalLiteral(node, env) {
		if (node is BooleanLiteral) {
			return evalBooleanLiteral(node, env)
		} else if (node is NumberLiteral) {
			return evalNumberLiteral(node, env)
		} else if (node is StringLiteral) {
			return evalStringLiteral(node, env)
		} else if (node is EmptyLiteral) {
			return evalEmptyLiteral(node, env)
		} else if (node is ArrayLiteral) {
			return evalArrayLiteral(node, env)
		} else if (node is HashMapLiteral) {
			return evalHashMapLiteral(node, env)
		} else {
			Fiber.abort("evalLiteral " + node.type.toString)
		}
	}

	evalBooleanLiteral(node, env) {
		return BooleanRuntime.new(node.value)
	}

	evalEmptyLiteral(node, env) {
		return EmptyRuntime.new()
	}

	evalNumberLiteral(node, env) {
		return NumberRuntime.new(node.value)
	}

	evalStringLiteral(node, env) {
		return StringRuntime.new(node.value)
	}

	evalArrayLiteral(node, env) {
		return ArrayRuntime.new(node.value)
	}

	evalHashMapLiteral(node, env) {
		var map = Map.new()
		for (maplet in node.members) {
			map[maplet.left.value] = maplet.right
		}
		return HashMapRuntime.new(map)
	}

	isTruthy(obj) {
		if (obj is BooleanRuntime) {
			return obj.value
		} else if (obj is EmptyRuntime) {
			return false
		} else {
			return true
		}
		// if (obj is Bool) {
		// 	return obj
		// } else if (obj == null) {
		// 	return false
		// } else {
		// 	return true
		// }
	}

	newError(message) {
		Fiber.abort(message)
	}

	isError(obj) {
		return false
	}

	evalExpressionList(exprs, env) {
		var result = []
		for (e in exprs) {
			result.add(eval(e, env))
		}
		return result
	}


	
	applyFunction(target, args) {
		if (target is AstFunc) {
			return applyAstFunction(target, args)
		} else if (target is Fn) {
			return applyWrenFunction(target, args)
		} else {
			System.print("unknown function")
		}
		//if (fn is Function) {
		//} else if (fn is Fn) {
			return fn.call(args)
		//}
	}
	applyAstFunction(target, args) {
		var env = fn.env.newChild({})

		for (pi in 0...(fn.parameters.count)) {
			var p = fn.parameters[pi]
			env[p.name] = args[pi]
		}

		var result = eval(fn.body, env)
		return result
	}
	applyWrenFunction(target, args) {
		if (target.arity != args.count) {
			System.print("too many args!")
		}
		if (target.arity == 0) {
			return target.call()
		} else if (target.arity == 1) {
			return target.call(args[0])
		} else if (target.arity == 2) {
			return target.call(args[0], args[1])
		} else {
			System.print("unsupported arity")
		}
	}

}

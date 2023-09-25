import "./environment" for Environment
import "../object/object" for
	ArrayRuntime,
	HashMapRuntime,
	BooleanRuntime,
	EmptyRuntime,
	Function,
	NumberRuntime,
	ReturnValue,
	StringRuntime

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
	Expression,
	ExpressionStatement,
	FunctionDeclaration,
	HashMapLiteral,
	HashMemberNode,
	Identifier,
	IndexExpression,
	NumberLiteral,
	Literal,
	LiteralExpression,
	Node,
	Program,
	ReturnStatement,
	VariableStatement,
	Statement,
	StringLiteral,
	UnaryExpression
// Newlines are allowed after Commas
	

class Interpreter {
	construct new() {
	}
	
	eval(node, env) {
		if (node is Program) {
			return evalProgram(node, env)
		} else if (node is Literal) {
			return evalLiteral(node, env)
		} else if (node is Expression) {
			return evalExpression(node, env)
		} else if (node is Statement) {
			return evalStatement(node, env)
		} else if (node is Node) {
			return evalNode(node, env)
		} else {
			Fiber.abort("expected AST node")
		}
	}

	evalProgram(node, env) {
		return evalBlockStatement(node.body, env)
	}

	evalStatement(node, env) {
		if (node is BlockStatement) {
			return evalBlockStatement(node, env)
		} else if (node is VariableStatement) {
			return evalVariableStatement(node, env)
		} else if (node is ReturnStatement) {
			return evalReturnStatement(node, env)
		} else if (node is ExpressionStatement) {
			return evalExpressionStatement(node, env)
		} else {
			Fiber.abort("WTF")
		}
	}

	evalBlockStatement(node,  env) {
		var result = null

		for (s in node.statements) {
			result = this.evalStatement(s, env)
		}
		
		return result
	}

	evalVariableStatement(node, env) {
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
		} else {
			Fiber.abort("WTF" + node.type.toString)
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
		}
		if (fn == null) {
			Fiber.abort("unrecognized binary operator " + node.operator.text)
		}
		var left = evalExpression(node.left, env)
		var right = evalExpression(node.right, env)
		return fn.call(left, right)
	}

	evalUnaryExpression(node, env) {
		fn = null
		if (node.operator.text == "-") {
			fn = Fn.new {|a| (-a)}
		}
		if (fn == null) {
			Fiber.abort("unrecognized unary operator " + node.operator.text)
		}
		return fn.call(node.inner)
	}

	evalIfExpression(node, env) {
		var cond = evalExpression(node.condition, env)
		if (isTruthy(cond)) {
			return eval(node.thenExpression, env)
		} else if (node.elseExpression != null) {
			return eval(node.elseExpression, env)
		} else {
			return EmptyRuntime.new()
		}
	}

	evalFunctionDeclaration(node, env) {
	}

	evalCallExpression(node, env) {
		
	}

	evalIndexExpression(node, env) {
		return evalExpression(node.target, env)[evalExpression(node.index, env)]
	}

	evalIdentifier(node, env) {
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
			Fiber.abort("WTF")
		}
	}

	evalBooleanLiteral(node, env) {
		return BooleanRuntime.new(node.bit)
	}

	evalEmptyLiteral(node, env) {
		return EmptyRuntime.new()
	}

	evalNumberLiteral(node, env) {
		return NumberRuntime.new(node.num)
	}

	evalStringLiteral(node, env) {
		return StringRuntime.new(node.str)
	}

	evalArrayLiteral(node, env) {
		return ArrayRuntime.new(node.elems)
	}

	evalHashMapLiteral(node, env) {
		var map = Map.new()
		for (maplet in node.members) {
			System.print(maplet.key.type)
			map[maplet.key.str] = maplet.value
		}
		return HashMapRuntime.new(map)
	}

	isTruthy(obj) {
		if (obj is Bool) {
			return obj
		} else if (obj == null) {
			return false
		} else {
			return true
		}
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

	extendedFunctionEnv(fn, args) {
		var env = fn.env.newChild({})

		for (pi in 0...(fn.parameters.count)) {
			var p = fn.parameters[pi]
			env[p.name] = args[pi]
		}

		return env
	}
	applyFunction(fn, args) {
		//if (fn is Function) {
		//	var env = extendFunctionEnv(fn, args)
		//	var result = eval(fn.body, env)
		//	return result
		//} else if (fn is Fn) {
			return fn.call(args)
		//}
	}
}

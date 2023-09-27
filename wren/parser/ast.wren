
class Node {
	toString {
		return "UnknownNode"
	}
}

class Declaration is Node {
	toString {
		return "UnknownDeclaration"
	}
}

class Statement is Node {
	toString {
		return "UnknownStatement"
	}
}

class Expression is Node {
	toString {
		return "UnknownExpression"
	}
}

class Literal is Node {
	value { _value }
	value=(value) {
		_value = value
	}
	construct new(value) {
		_value = value
	}
	toString {
		return _value.toString
	}
}

class Program is Node {
	body { _body }
	construct new(body) {
		if (body is BlockStatement == false) {
			Fiber.abort("expected BlockStatement")
		}
		_body = body
	}
	toString {
		var res = _body.toString
		if (res[0] == "{") {
			res = res[1...res.count]
		}
		if (res[res.count - 2..res.count - 1] == "\n}") {
			res = res[0..(res.count - 3)]
		}
		if (res[res.count - 1] == "}") {
			res = res[0..(res.count - 2)]
		}
		return res
	}
}

class StatementDeclaration is Declaration {
	statement { _statement }
	construct new(statement) {
		_statement = statement
	}
	toString {
		return statement.toString
	}
}

class ClassDeclaration is Declaration {
	name { _name }
	name=(name) {
		_name = name
	}

	superClassName { _superClassName }
	superClassName=(name) {
		_superClassName = name
	}

	memberList { _memberList }
	memberList=(memberList) {
		_memberList = memberList
	}


}

class FunctionDeclaration is Declaration {
	name { _name }
	parameterList { _parameterList }
	bodyStatement { _bodyStatement }
	construct new(name, params, body) {
		if (name != null && name is Identifier == false) {
			Fiber.abort("expected Identifier")
		}
		if (params is List == false) {
			Fiber.abort("expected List")
		}
		if (body is BlockStatement == false) {
			Fiber.abort("expected BlockStatement")
		}
		_name = name
		_parameterList = params
		_bodyStatement = body
	}
	toString {
		var res = ""
		if (_name != "_") {
			res = res + " " + _name.toString
		}
		res = res + "("
		var inner = _parameterList.toString
		if (_parameterList.count > 0) {
			for (i in 1..(inner.count - 2)) {
				res = res + inner[i]
			}
		}
		res = res + ") "
		res = res + _bodyStatement.toString
		return res
	}
}

class VariableDeclaration is Declaration {
	name { _name }
	value { _value }
	construct new(name, value) {
		_name = name
		_value = value
	}
	toString {
		return "var " + _name.toString + " = " + _value.toString + "\n"
	}
}

class ForStatement is Statement {
}

class ReturnStatement is Statement {}
class ContinueStatement is Statement {}
class BreakStatement is Statement {}
class WhileStatement is Statement {
	condition { _condition }
	body { _body }
	construct new(condition, body) {
		_condition = condition
		_body = body
	}
	toString {
		return "while (" + _condition.toString + ") " + _body.toString
	}
}

class BlockStatement is Statement {
	statements { _statements }
	construct new(stmts) {
		_statements = stmts
	}
	toString {
		var repr = "{"
		if (_statements.count == 0) {
			repr = repr + "}"
			return repr
		}

		for (st in _statements) {
			repr = repr + st.toString
		}

		repr = repr + "}"
		return repr
	}
}
class AssignStatement is Statement {
	name { _name }
	value { _value }
	construct new(name, value) {
		_name = name
		_value = value
	}
	toString {
		return "var " + _name.toString + " = " + _value.toString + "\n"
	}
}

class ConditionStatement is Statement {
	condition { _condition }
	thenStatement { _thenStatement }
	elseStatement { _elseStatement }

	construct new(condition, thenExp, elseExp) {
		_condition = condition
		_thenStatement = thenExp
		_elseStatement = elseExp
	}

	toString {
		var res = "if ("
		res = res + _condition.toString
		res = res + ") "
		res = res + _thenStatement.toString
		if (_elseStatement != null) {
			res = res + " else "
			res = res + _elseStatement.toString
		}
		return res
	}
}

class ExpressionStatement is Statement {
	expression { _expression }
	construct new(expression) {
		if (expression == null) {
			Fiber.abort("null expression statement")
		}
		_expression = expression
	}
	toString {
		return _expression.toString
	}
}

class ConditionExpression is Expression {
	condition { _condition }
	thenExpression { _thenExpression }
	elseExpression { _elseExpression }

	construct new(condition, thenExp, elseExp) {
		_condition = condition
		_thenExpression = thenExp
		_elseExpression = elseExp
	}

	toString {
		var res = _condition.toString
		res = res + " ? "
		res = res + _thenExpression.toString
		res = res + " : "
		if (_elseExpression != null) {
			res = res + _elseExpression.toString
		} else {
			res = res + "null"
		}
		return res
	}
}

class BinaryExpression is Expression {
	operator { _op }
	left { _left }
	right { _right }
	construct new(op, left, right) {
		_op = op
		_left = left
		_right = right
	}
	toString {
		return _left.toString + " " + _op.text + " " + _right.toString
	}
}

class UnaryExpression is Expression {
	operator { _op }
	inner { _inner }
	construct new(op, inner) {
		_op = op
		_inner = inner
	}
	toString {
		return _op.text + " " + _inner.toString
	}
}

class DotExpression is Expression {
	target { _target }
	name { _name }
	construct new(target, name) {
		_target = target
		_name = name
	}
	toString {
		return _target.toString + "." + _name.toString
	}
}

class CallExpression is Expression {
	target { _target }
	args { _args }
	construct new(target, args) {
		_target = target
		_args = args
	}
	toString {
		var inner = _args.toString
		var res = ""
		for (i in 1..(inner.count - 2)) {
			res = res + inner[i]
		}
		return _target.toString + "(" + res + ")"
	}
}

class IndexExpression is Expression {
	target { _target }
	index { _index }
	construct new(target, index) {
		_target = target
		_index = index
	}
	toString {
		return _target.toString + "[" + _index.toString + "]"
	}
}

class LiteralExpression is Expression {
	literal { _literal }
	construct new(literal) {
		_literal = literal
	}
	toString {
		return _literal.toString
	}
}

class Identifier is Expression {
	name { _name }
	construct new(name) {
		_name = name
	}
	toString {
		return _name
	}
}

class BooleanLiteral is Literal {
	construct new(value) {
		super(value)
	}
}
class EmptyLiteral is Literal {
	construct new() {
		super(null)
	}
}
class NumberLiteral is Literal {
	construct new(value) {
		super(value)
	}
}
class StringLiteral is Literal {
	construct new(value) {
		super(value)
	}
}
class ArrayLiteral is Literal {
	value { _value }
	construct new(value) {
		_value = value
	}
	toString {
		var elemstr = ""
		if (_value.count > 0) {
			elemstr = elemstr + _value[0].toString
			if (_value.count > 1) {
				for (i in 1..._value.count) {
					elemstr = elemstr + ", " + _value[i].toString
				}
			}
		}
		return "[" + elemstr + "]"
	}
}
class HashMapLiteral is Literal {}
class HashMemberNode is BinaryExpression {
	construct new(op, left, right) {
		super(op, left, right)
	}
}

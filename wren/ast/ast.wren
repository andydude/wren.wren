
class Node {
	toString {
		return "UnknownNode"
	}
}

class Declaration is Node {}

class Statement is Node {}

class Expression is Node {}

class Literal is Node {
	construct new(value) {
		_value = value
	}
	value { _value }
	value=(value) {
		_value = value
	}
}

class Program is Node {
	declarations { _declarations }
	construct new(declarations) {
		if (declarations is List == false) {
			Fiber.abort("expected Declaration[]")
		}
		if (declarations[0] is Declaration == false) {
			Fiber.abort("expected Declaration[]")
		}
		_declarations = declarations
	}
	toString() {
		return "<Program>"
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

class VariableStatement is Statement {
	name { _name }
	value { _value }
	construct new(name, value) {
		_name = name
		_value = value
	}
	toString {
		return "var " + name.toString + " = " + value.toString + ";"
	}

}

class ForStatement is Statement {
}

class ReturnStatement is Statement {}
class ContinueStatement is Statement {}
class BreakStatement is Statement {}
class WhileStatement is Statement {}

class BlockStatement is Statement {}
class AssignStatement is Statement {}

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
		res
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
		return _expression.toString + ";"
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
		var res = "if ("
		res = res + _condition.toString
		res
		res = res + ") "
		res = res + _thenExpression.toString
		if (_elseExpression != null) {
			res = res + " else "
			res = res + _elseExpression.toString
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
}

class Identifier is Expression {}

class BooleanLiteral is Literal {}
class EmptyLiteral is Literal {}
class NumberLiteral is Literal {}
class StringLiteral is Literal {}
class ArrayLiteral is Literal {}
class HashMapLiteral is Literal {}
class HashMemberNode is Node {}

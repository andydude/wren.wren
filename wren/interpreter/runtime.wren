class MonkeyObject { }

class ReturnValue is MonkeyObject {
	value { _value }
	construct new(value) {
		_value = value
	}
}

class AstFunc is MonkeyObject {
	name { _name }
	parameters { _parameters }
	body { _body }
	env { _env }

	construct new(name, parameters, body, env) {
		_name = name
		_parameters = parameters
		_body = body
		_env = env
	}
}

class ArrayRuntime is MonkeyObject {
	elems { _elems }
	construct new(elems) {
		_elems = elems
	}
	[index] {
		return _elems[index.num]
	}
	toString {
		return _elems.toString
	}
}

class HashMapRuntime is MonkeyObject {
	map { _map }
	construct new(map) {
		_map = map
	}
	[index] {
		return _map[index.str]
	}
	toString {
		return _map.toString
	}
}

class BooleanRuntime is MonkeyObject {
	value { _value }
	construct new(value) {
		_value = value
	}
	! {
		return !_value
	}
	~ {
		Fiber.abort("Runtime error: Bool does not implement '~'.")
	}
	- {
		Fiber.abort("Runtime error: Bool does not implement '-'.")
	}
	toString {
		if (_value) {
			return "true"
		} else {
			return "false"
		}
	}
}

class EmptyRuntime is MonkeyObject {
	construct new() {
	}
	! {
		return true
	}
	~ {
		Fiber.abort("Runtime error: Null does not implement '~'.")
	}
	- {
		Fiber.abort("Runtime error: Null does not implement '-'.")
	}
	toString {
		return "null"
	}
}

class NumberRuntime is MonkeyObject {
	num { _num }
	construct new(num) {
		_num = num
	}
	toString {
		return _num.toString
	}
	! {
		return _num == null
	}
	~ {
		return ~(_num)
	}
	- {
		return -(_num)
	}
	+(other) {
		return NumberRuntime.new(this.num + other.num)
	}
	-(other) {
		return NumberRuntime.new(this.num - other.num)
	}
	*(other) {
		return NumberRuntime.new(this.num * other.num)
	}
	/(other) {
		return NumberRuntime.new(this.num / other.num)
	}
	%(other) {
		return NumberRuntime.new(this.num % other.num)
	}
}

class StringRuntime is MonkeyObject {
	str { _str }
	construct new(str) {
		_str = str
	}
	toString {
		return "\"" + _str + "\""
	}
	! {
		return _str == null
	}
	- {
		return -(_num)
	}
	+(other) {
		return StringRuntime.new(this.str + other.str)
	}
	[index] {
		return _str[index]
	}
}

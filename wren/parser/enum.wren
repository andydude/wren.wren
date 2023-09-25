class EnumMember {
  name { _name }
  value { _value }
  construct new (value2, name2) {

    if (value2 == null || (value2 is Num == false)) {
      Fiber.abort("'Num' expected for 1st parameter.")
    }

    if (name2 == null || (name2 is String == false)) {
      Fiber.abort("'String' expected for 3rd parameter.")
    }

    _name = name2
    _value = value2
  }

  toString () {
    return "<%(_parent).%(_name): %(_value)>"
  }
  == (other) {
		if (other == null) {
			return false
		}
    return _value == other.value
  }
}

class Enum {
  name { _name }
	enums { _enums }
  construct new (name, values) {
    _name = name
    _enums = {}

    if (values is List) {
      values = Enum.transformList(values)
    } else if (values is Map == false) {
      Fiber.abort("'List' or 'Map' expected for 'values' parameter when constructing 'Enum'.")
    }

    if (values is Map) {
      Enum.validateMap(values)
      _enums = Enum.createMembers(name, values)
    } else {
      Fiber.abort("'List' or 'Map' expected for 'values' parameter when constructing 'Enum'.")
    }
  }
  has (index) {
	  if (index is Num || index is String) {
			var e = _enums[index]
		  return e != null
	  }
	  Fiber.abort("Expected 'String' or 'Num' for 'index' parameter.")
  }
  toString () {
    return "<enum '%(_name)'>"
  }
  [index] {
    var e = _enums[index]
    if (e == null || (e is EnumMember == false)) {
      Fiber.abort("Invalid enum member: %(index)")
    }
    return e
  }
  [index] = (value) {
    Fiber.abort("Cannot set enumerated value.")
  }
	static createMembers(name, values) {
    var enums = {}
    var value
    for (key in values.keys) {
      value = values[key]
      var enum = EnumMember.new(value, key)
      enums[key] = enum
      enums[value] = enum
    }
    return enums
	}
	static transformList(list) {
    var mapped = {}
    var iter
    var value
    while (iter = list.iterate(iter)) {
      value = list.iteratorValue(iter)
      if (mapped[value] != null) Fiber.abort("Duplicate key found in 'List': %(value)")
      mapped[value] = iter
    }
    return mapped
	}
	static validateMap(values) {
    if (values is Map == false) {
      Fiber.abort("'Map' expected for 'values' parameter.")
    }
    var found = {}
    var f
    var value
    for (key in values.keys) {
      value = values[key]
      if (value is Num == false) {
        Fiber.abort("Enumeration member 'keys' and 'values' must be of type 'Num'.")
      }
      f = found[value]
      found[value] = f == null ? 1 : f + 1
    }
    for (key in found.keys) {
      value = found[key]
      if (value > 1) {
        Fiber.abort("Attempted to reuse key: %(key).")
      }
    }
  }
}

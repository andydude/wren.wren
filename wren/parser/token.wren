import "./enum" for Enum

var Prec = Enum.new("Prec", [
	"POST",
	"PRE",
	"FACTOR",
	"TERM",
	"RANGE",
	"SHIFT",
	"BITAND",
	"BITXOR",
	"BITOR",
	"REL",
	"IS",
	"EQUAL",
	"LOGAND",
	"LOGOR",
	"COND",
	"ASSIGN",

	// pseudo-precedence
	"LAST",
])

var Tok = Enum.new("Tok", [
	"EOF",

	// operators
	"BANG",
	"BANG_EQ",
	"COLON",
	"COMMA",
	"DOT2",
	"DOT3",
	"EQ",
	"EQ_EQ",
	"GT",
	"GT2",
	"GT_EQ",
	"LT",
	"LT2",
	"LT_EQ",
	"MINUS",
	"PLUS",
	"QUEST",
	"SOL",
	"STAR",
	"TILDE",
	"NEWLINE",
	"LPAREN",
	"RPAREN",
	"LBRACE",
	"RBRACE",
	"LBRACK",
	"RBRACK",
	
	// keywords
	"AS",
	"BREAK",
	"CLASS",
	"CONSTRUCT",
	"CONTINUE",
	"ELSE",
	"FALSE",
	"FOR",
	"FOREIGN",
	"IF",
	"IMPORT",
	"IN",
	"IS",
	"NULL",
	"RETURN",
	"STATIC",
	"SUPER",
	"THIS",
	"TRUE",
	"VAR",
	"WHILE",

	// other
	"STATIC_FIELD_IDENT",
	"FIELD_IDENT",
	"IDENT",
	"NUMBER_LIT",
	"STRING_LIT",

	// pseudo-token
	"LAST",
])

class Token {
	kind { _kind }
	text { _text }

	construct new(kind, text) {
		_kind = kind
		_text = text
	}
}

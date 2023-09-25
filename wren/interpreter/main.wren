import "../parser/lexer" for Lexer
import "../parser/parser" for Parser
import "./interpreter" for Interpreter
import "./environment" for Environment
import "io" for Stdin, Stdout

var PROMPT = ">> "
var DEBUG_LEXER = false
var DEBUG_PARSER = true
var env = Environment.new()

while (true) {
	System.write(PROMPT)
	Stdout.flush()
	var line = Stdin.readLine()
	if (DEBUG_LEXER) {
		var lexer = Lexer.new(line)
		for (t in lexer) {
			if (t.kind.value == 0) break
			System.print("L- " + t.text + " " + t.kind.name + "(" + t.kind.value.toString + ")")
		}
	}
	var lexer = Lexer.new(line)
	var parser = Parser.new(lexer)
	var program = parser.parseProgram()
	if (DEBUG_PARSER) {
		System.print("P: " + program.toString)
	}
	var interp = Interpreter.new()
	var evaluated = interp.evalProgram(program, env)
	System.print("=> " + evaluated.toString)
}

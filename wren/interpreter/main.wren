import "../parser/lexer" for Lexer
import "../parser/parser" for Parser
import "./interpreter" for Interpreter
import "./environment" for Environment
import "io" for Stdin, Stdout

var PROMPT = ">> "
var DEBUG_LEXER = true
var DEBUG_PARSER = true
var env = Environment.new()

while (true) {
	System.write(PROMPT)
	Stdout.flush()
	var line = Stdin.readLine()
	line = line + "\n"
	System.print("-- " + line)
	if (true) {
		var lexer = Lexer.new(line)
		System.print("debug lexer")
		while (true) {
			var t = lexer.nextToken()
			System.print("L- " + t.text + " " + t.kind.name + "(" + t.kind.value.toString + ")")
			if (t.kind.value == 0) break
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

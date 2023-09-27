import "./interpreter/environment" for Environment
import "./interpreter/interpreter" for Interpreter
import "./parser/lexer" for Lexer
import "./parser/parser" for Parser
import "io" for Stdin, Stdout

var PROMPT = ">> "
var DEBUG_LEXER = false
var DEBUG_PARSER = false
var env = Environment.new()

while (true) {
	System.write(PROMPT)
	Stdout.flush()
	var line = Stdin.readLine()
	line = line + "\n"
	if (DEBUG_LEXER) {
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

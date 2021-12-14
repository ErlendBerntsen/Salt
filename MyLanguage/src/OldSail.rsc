module OldSail
import IO;
import ParseTree;
import List;

layout MyLayout = [\ \n]*;

lexical ID = [a-zA-Z_] !<< [a-zA-Z_]+ !>> [a-zA-Z_] \ Keywords;
lexical TYPEID = [a-zA-Z_] !<< [a-zA-Z_]+ !>> [a-zA-Z_] \ NonTypenameKeyWords;
lexical INTEGER = [0] | [1-9] [0-9]*;

keyword Keywords = "int" | "bool" | "void" | "true" | "false" | "print" | "if" | "then" | "else";
keyword NonTypenameKeyWords =  "true" | "false" | "print" | "if" | "then" | "else";


start syntax Program = VariableDeclaration* variableDeclarations FunctionDeclaration* functionDeclarations;


syntax VariableDeclaration 
	= TypeName ID name "=" Expression";"
	| TypeName ID name";"
	;
	
syntax FunctionDeclaration
	=  TypeName returnType ID name "(" {Parameter ","}* parameters ")" "{" Statement* body "}";

syntax Parameters =  Parameter parameter ("," Parameters)?;

syntax Parameter = TypeName type ID name;

syntax Statement 
	= VariableDeclaration				// Both variable declaration and initilization
	| ID "=" Expression";"				// Variable Assignment
	| FunctionCall";"
	| "return" Expression?";"			// Function return Statement
	| "print" "(" Expression ")"";"
	| IfStatement
	;						
	
syntax IfStatement = "if" "(" Expression condition ")" "then" "{" Statement+ thenBranch "}" "else" "{" Statement+ elseBranch"}";

syntax Expression 
	= SimpleExpression
	| SimpleExpression RelationalOperator SimpleExpression 
	| FunctionCall	 
	| IfExpression
	| "(" Expression ")"
	| ArrayExpression   
	;

syntax ArrayExpression = "[" {Expression "," }* elements "]";

syntax IfExpression = left Expression "?" Expression ":" Expression;

syntax FunctionCall = ID name "(" {Argument ","}* arguments ")";

syntax Arguments = Argument ("," Arguments)?;

syntax Argument = Expression;

syntax SimpleExpression
	= Term
	| UnaryOperator Term
	| SimpleExpression LowerPrecedenceOperator Term
	;

syntax Term 
	= Factor
	| Term HigherPrecedenceOperator Factor
	;

syntax Factor
	= ID
	| INTEGER
	| Boolean
	;
	
syntax TypeName = TYPEID name | TYPEID name "[]" array;

syntax Boolean = "true" | "false";

syntax RelationalOperator = "\<" | "\>" | "\<=" | "\>=" |"==" | "!=";
syntax LowerPrecedenceOperator = "+" | "-" | "||";
syntax HigherPrecedenceOperator =  "*" | "/" | "&&";
syntax UnaryOperator = "-" | "!";

Expression parens(Expression expr) {
    return bottom-up visit(expr) {
        case (Expression)`((<Expression e>))` => e    // drop extra parens
        case e:(Expression)`(<Expression _>)` => e    // don't touch if we already have
        case Expression e => (Expression)`(<Expression e>)` // add around all other expressions
    }
}
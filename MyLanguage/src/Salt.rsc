module Salt


layout MyLayout = [\ \n]*;

lexical ID = [a-zA-Z_] !<< [a-zA-Z_]+ !>> [a-zA-Z_] \ Keywords;
lexical Integer = [0] | [1-9] [0-9]*;

keyword Keywords = "int" | "bool" | "true" | "false" | "globals" | "functions" |"begin" | "end";


start syntax Program = VariableDeclaration* variableDeclarations FunctionDeclaration* functionDeclarations;



syntax VariableDeclaration 
	= TypeName ID "=" Expression
	| TypeName ID 
	;
	
syntax FunctionDeclaration
	=  TypeName returnType ID name "(" Parameters? ")" "{" Statement* body "}";

syntax Parameters =  Parameter ("," Parameters)?;

syntax Parameter = TypeName type ID name;

syntax Statement 
	= VariableDeclaration	// Both variable declaration and initilization
	| ID "=" Expression 	// Variable Assignment
	| ID"(" Arguments? ")" 	// Function Call
	| "return" Expression	// Function return Statement
	;						// TODO if statements, while loop
	
syntax Arguments = Argument ("," Arguments)?;

syntax Argument = Expression;

syntax Expression 
	= SimpleExpression
	| SimpleExpression RelationalOperator SimpleExpression
	;

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
	| Integer
	| Boolean
	;
	
syntax TypeName = "int" | "bool";

syntax Boolean = "true" | "false";

syntax RelationalOperator = "\<" | "\>" | "\<=" | "\>=" |"==" | "!=";
syntax LowerPrecedenceOperator = "+" | "-" | "||";
syntax HigherPrecedenceOperator =  "*" | "/" | "&&";
syntax UnaryOperator = "-" | "!";

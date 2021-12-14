module Sail

//*******
//GRAMMAR
//*******

//TERMINALS
lexical ID = [a-zA-Z_] !<< [a-zA-Z_]+ !>> [a-zA-Z_] \ Keywords;
lexical TYPEID = [a-zA-Z_] !<< [a-zA-Z_]+ !>> [a-zA-Z_] \ NonTypenameKeyWords;
lexical INTEGER = [0] | [1-9] [0-9]*;
lexical BOOLEAN = "true" | "false";

syntax UnaryOperator = "-" | "!";
syntax RelationalOperator = "\<" | "\>" | "\<=" | "\>=" | "==" | "!=";
syntax HigherPrecedenceOperator =  "*" | "/" | "&&";
syntax LowerPrecedenceOperator = "+" | "-" | "||";

//KEYWORDS
keyword Keywords = "int" | "bool" | "void" | "true" | "false" | "print" | "if" | "then" | "else" | "while" | "return" | "size";
keyword NonTypenameKeyWords =  "true" | "false" | "print" | "if" | "then" | "else" | "while" | "return" | "size" ;

//WHITESPACE / LAYOUT
layout MyLayout = [\ \n\t\r]*;

//START SYMBOL
start syntax Program = VariableDeclaration* variableDeclarations FunctionDeclaration* functionDeclarations;

//NON-TERMINALS AND PRODUCTION RULES
syntax VariableDeclaration 
	= TypeName ID name "=" Expression";"
	| TypeName ID name";"
	;
	
syntax FunctionDeclaration
	=  TypeName returnType ID name "(" {Parameter ","}* parameters ")" "{" Statement* body "}"; //TODO change to +?

syntax Parameters =  Parameter parameter ("," Parameters)?;

syntax Parameter = TypeName type ID name;

syntax Statement 
	= VariableDeclaration	// Both variable declaration and initilization
	| ID "=" Expression";"	// Variable Assignment
	| FunctionCall";"
	| ReturnStatement	
	| "print" "(" Expression ")"";"
	| IfStatement
	| WhileLoop
	| ArrayExpression "=" Expression ";" 	//Update array element
	| ID "/" Expression ";"					//Delete Array element
	;						
syntax ReturnStatement = "return" Expression? ";";
syntax IfStatement = "if" "(" Expression condition ")" "then" "{" Statement+ thenBranch "}" "else" "{" Statement+ elseBranch"}";
syntax WhileLoop = "while" "(" Expression condition ")" "{" Statement* statements "}";

syntax Expression 
	= ID
	| INTEGER
	| BOOLEAN
	> UnaryOperator Expression
	> left Expression RelationalOperator Expression
	> left Expression HigherPrecedenceOperator Expression
	> left Expression LowerPrecedenceOperator Expression 
	| FunctionCall	 
	| IfExpression
	| "(" Expression ")"
	| ArrayList 
	| ArrayExpression
	| ArraySize   
	;

syntax ArrayExpression = ID var "[" Expression index "]";
syntax ArrayList = "[" {Expression "," }* elements "]";
syntax ArraySize = "size" "(" Expression array ")"; 

syntax IfExpression = left Expression "?" Expression ":" Expression;

syntax FunctionCall = ID name "(" {Argument ","}* arguments ")";

syntax Arguments = Argument ("," Arguments)?;

syntax Argument = Expression;

//This could be a terminal marked with lexical, the difference is that syntax allows whitespace between the type name and [] e.g. int []	
syntax TypeName = TYPEID name | TYPEID name "[]" array;
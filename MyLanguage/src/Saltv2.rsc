module Saltv2

import String;
import ParseTree;

layout MyLayout = [\ \n]*;

lexical ID = [a-zA-Z_] !<< [a-zA-Z_]+ !>> [a-zA-Z_] \ Keywords;
lexical Integer = [0] | [1-9] [0-9]*;

keyword Keywords = "int" | "bool" | "true" | "false";


start syntax Program = Declarations;


syntax Declarations = VariableDeclarations;

syntax VariableDeclarations 
	= VariableDeclarations DataType ID 
	| VariableDeclarations DataType ID "=" Expr
	|
	;


syntax Expr =  "-" Expression";" > Expression";";
syntax Expression 
	= SimpleExpression
	> left Expression "*" Expression
	> left (Expression "+" Expression | Expression "-" Expression)
	;


syntax SimpleExpression
	= ID
	| Integer
	| Boolean
	;
	
syntax DataType = "int" | "bool";

syntax Boolean = "true" | "false";


data Integer = integer(int n);

public Integer eval(str txt){
	return integer(evalExpr(parse(#Expr, txt)));
}

public int evalExpr((Expr)`<Expression e>;`){
	return evalExpression(e);
}

public int evalExpr((Expr)`-<Expression e>;`){
	return -evalExpression(e);
}

public int evalExpression((Expression)`<SimpleExpression se>`){
	return evalSimpleExpression(se);
}


public int evalExpression((Expression)`<Expression e1>+<Expression e2>`){
	return evalExpression(e1) + evalExpression(e2);
}

public int evalExpression((Expression)`<Expression e1>*<Expression e2>`){
	return evalExpression(e1) * evalExpression(e2);
}


public int evalSimpleExpression((SimpleExpression) `<Integer n>`){
	return toInt("<n>");
}


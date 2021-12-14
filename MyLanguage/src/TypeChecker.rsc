module TypeChecker

import String;
import ParseTree;
import Map;
import List;
import IO;
import Sail;

data Type 
	= Integer(int n) 
	| Integer() 
	| Boolean(bool b) 
	| Boolean()
	| Array(Type t)
	| Array(list[Type] l)
	| Void()
	| Function(Type returnType, list[Type] parameterTypes) 
	| Error(loc location, Exception exception);

data Exception 
	= IllegalArgumentException(str s) 
	| VariableAlreadyInScopeException(str s)
	| UndefinedVariableException(str s)
	| TypeMismatchException(str s)
	| ArgumentNumberException(str s)
	| NoMainFunctionException(str s)
	| UnknownTypeException(str s)
	| MissingReturnStatementException(str s)
	| UnreachableCodeException(str s)
	;

alias TypeEnvironment = map[str, Type];
alias Errors = list[Type];

private TypeEnvironment environment = ();
private Errors errors = [];
private FunctionDeclaration currentFunction;

// ****************
// INPUT TYPE CHECK
// ****************

public bool typeCheck(str text){
	tree = parse(#start[Program], text).top;
	typeCheckProgram(tree);
	if(errors == []){
		return true;
	}
	for(Type error <- errors){
		println(error);
	}
	return false;
}

public bool tcf(str file){
	loc fileLoc = |project://MyLanguage/src/| + (file + ".txt");
	tree = parse(#start[Program], fileLoc).top;
	typeCheckProgram(tree);
	if(errors == []){
		return true;
	}
	for(Type error <- errors){
		println(error);
	}
	return false;
}


// ******************
// PROGRAM TYPE CHECK
// ****************** 

public void typeCheckProgram(Program program){
	environment = ();
	errors = [];
	
	for(VariableDeclaration variableDeclaration <- program.variableDeclarations){
		typeCheckVariableDeclaration(variableDeclaration);
	}
	
	for(FunctionDeclaration functionDeclaration <- program.functionDeclarations){
		typeCheckFunctionDeclaration(functionDeclaration);
	}
	
	if("main" notin environment){
		errors += [Error(program@\loc, NoMainFunctionException("A program needs a main function"))];
	}
	
	else if(environment["main"] != Function(Void(), [])){
		errors += [Error(program@\loc, IllegalArgumentException("The main function should have a return type of void and no parameters"))];
	}
	
	for(FunctionDeclaration functionDeclaration <- program.functionDeclarations){
		typeCheckFunctionBody(functionDeclaration);
	}
	
	if(errors != []){
		return;
	}
}


// *******************************
// VARIABLE DECLARATION TYPE CHECK
// *******************************

public void typeCheckVariableDeclaration(vd:(VariableDeclaration) `<TypeName t><ID id>;`){
	str idKey = "<id>";
	if(idKey in environment){
		errors += [Error(vd@\loc, VariableAlreadyInScopeException("Variable <id>  is already defined"))];
	}
	else{
		Type variableType = getTypeFromTypeName(t);
		if(variableType is Error){
			//TODO prevent void variable?
			errors += [variableType];
			return;
		}
		if(variableType is Void){
			errors += [Error(vd@\loc, IllegalArgumentException("Variable <id> cant have a type of Void"))];
			return; 
		}
		environment[idKey] = variableType;
	}
}


public void typeCheckVariableDeclaration(vd:(VariableDeclaration) `<TypeName t><ID id>=<Expression e>;`){
	str idKey = "<id>";
	if(idKey in environment){
		errors += [Error(vd@\loc, VariableAlreadyInScopeException("Variable <id> is already defined"))];
	}
	else{
		Type variableType = getTypeFromTypeName(t);
		if(variableType is Error){
			errors += [variableType];
			return;
		}
		Type expressionType = typeCheckExpression(e);
		if(expressionType is Error){
			errors += [expressionType];
			return;
		}
		if(expressionType == Array(Void()) && variableType is Array){
			expressionType = variableType;
		}
		else if(variableType != expressionType){
			errors += [Error(vd@\loc, TypeMismatchException("Cannot assign variable <id> of type <variableType> to type <expressionType>"))];
			return;
		}
		environment[idKey] =  variableType;
	}
}


// *******************************
// FUNCTION DECLARATION TYPE CHECK
// *******************************

public void typeCheckFunctionDeclaration(FunctionDeclaration function){
	Type returnType = getTypeFromTypeName(function.returnType);
	if(returnType is Error){
		errors += [returnType];
		return;
	}
	str functionName = "<function.name>";
	if(functionName in environment){
		errors += [Error(function@\loc , VariableAlreadyInScopeException("Identifier <functionName> is already defined"))];
	}
	
	environment[functionName] = Void();
	list[str] parameterNames = [];
	list[Type] parameterTypes = [];
	
	for(Parameter parameter <- function.parameters){
		<parameterType, parameterName> = typeCheckParameter(parameter, parameterNames);
		if(parameterType is Error){
			errors += [parameterType];
			return;
		}
		parameterTypes += [parameterType];
		parameterNames += [parameterName];
	}
	
	environment[functionName] = Function(returnType, parameterTypes);
}

public void typeCheckFunctionBody(FunctionDeclaration function){
	currentFunction = function;
	list[str] parameterNames = [];
	list[Type] parameterTypes = [];
	
	for(Parameter parameter <- function.parameters){
		//Already type checked the function declaration, it is not possible this will return an Error here
		<parameterType, parameterName> = typeCheckParameter(parameter, parameterNames);
		parameterTypes += [parameterType];
		parameterNames += [parameterName];
		environment[parameterName] = parameterType;
	}
	
	bool hasReturnStatement = false;
	for(Statement statement <- function.body){
		if(hasReturnStatement){
			errors += [Error(function@\loc, UnreachableCodeException("The statement: <statement> will never be executed"))];
			return;			
		}
		
		else if((Statement)`<ReturnStatement _>` := statement){
			typeCheckReturnStatement(statement, function);
			hasReturnStatement = true;
		}
		else if((Statement)`<IfStatement ifs>` := statement){
			typeCheckStatement(statement);
			bool ifStatementHasReturnStatement = doesIfStatementHaveReturnStatement(ifs, function);
			hasReturnStatement = hasReturnStatement || ifStatementHasReturnStatement;
		}
		else{
			typeCheckStatement(statement);
		}
		if(errors != []){
			return;
		}
	}
	
	Type functionType = getVariableType(function@\loc , "<function.name>");
	Type returnType = functionType.returnType;
	if(!hasReturnStatement && returnType != Void()){
		errors += [Error(function@\loc, 
						MissingReturnStatementException("Function <function.name> has return type of <returnType> but returns nothing"))];
	}

	for(str parameterName <- parameterNames){
		environment = delete(environment, parameterName);
	}
}

public void typeCheckReturnStatement(Statement returnStatement, FunctionDeclaration function){
	Type functionType = getVariableType(function@\loc , "<function.name>");
	Type returnType = functionType.returnType;
	if((Statement)`return;` := returnStatement){
			if(returnType != Void()){
				errors += [Error(function@\loc, 
					MissingReturnStatementException("Function <function.name> has return type of <returnType> but tried to return nothing"))];
			}
	}
	if((Statement)`return<Expression e>;` := returnStatement){
		Type expressionType = typeCheckExpression(e);
		if(expressionType is Error){
			errors += [expressionType];
			return;
		}
		
		if(expressionType != returnType){
					errors += [Error(function@\loc, 
						TypeMismatchException("Function <function.name> has return type of <returnType> but returned <expressionType>"))];
		}
	}
}

// ********************
// PARAMETER TYPE CHECK
// ********************


public tuple[Type, str] typeCheckParameter(parameter:(Parameter) `<TypeName t><ID id>`, list[str] parameterNames){
	str idKey = "<id>";
	Type typeName = getTypeFromTypeName(t);
	if(typeName is Error){
		return <typeName, idKey>;
	}
	if(idKey in environment || idKey in parameterNames){
		return <Error(parameter@\loc, VariableAlreadyInScopeException("Variable <id> is already defined")), idKey>;
	}
	return <typeName, idKey>;
}


// ********************
// STATEMENT TYPE CHECK
// ********************

public void typeCheckStatement((Statement) `<VariableDeclaration vd>`){
	return typeCheckVariableDeclaration(vd);
}

public void typeCheckStatement(statement:(Statement) `<ID id>=<Expression e>;`){

	Type variableType = getVariableType(statement@\loc, "<id>");
	if(variableType is Error){
		errors += [variableType];
		return;
	}
	
	Type expressionType = typeCheckExpression(e);
	if(variableType != expressionType){
		errors += [Error(statement@\loc, TypeMismatchException("Cannot assign variable <id> of type <variableType> to type <expressionType>"))];
		return;
	}
}

public void typeCheckStatement(statement:(Statement) `<ReturnStatement _>`){
	typeCheckReturnStatement(statement, currentFunction);
}

public void typeCheckStatement(statement:(Statement) `<ID id>/<Expression e>;`){
	Type variableType = getVariableType(statement@\loc, "<id>");
	if(variableType is Error){
		errors += [variableType];
		return;
	}
	
	if(!variableType is Array){
		errors += [Error(statement@\loc, IllegalArgumentException("Variable <id> is not an array"))];
		return;
	}
	
	Type expressionType = typeCheckExpression(e);
	if(!expressionType is Integer){
		errors += [Error(statement@\loc, IllegalArgumentException("The index must be of type Integer when deleting from an array"))];
		return;
	}
}

public void typeCheckStatement((Statement) `print(<Expression e>);`){
	Type expressionType = typeCheckExpression(e);
	if(expressionType is Error){
		errors += [expressionType];
	}	
}

public void typeCheckStatement(ifstmt:(Statement) `<IfStatement ifstatement>`){
	Type conditionType = typeCheckExpression(ifstatement.condition);
	if(conditionType is Error){
		errors += [conditionType];
		return;
	}
	
	if(!conditionType is Boolean){
		errors += Error(ifstmt@\loc, IllegalArgumentException("Illegal type in if condition. Type must be Boolean"));
	}
	
	set[str] variables = domain(environment);
	bool bodyHasReturnStatement = false;
	for(Statement statement <- ifstatement.thenBranch){
		if(bodyHasReturnStatement){
			errors += [Error(statement@\loc, UnreachableCodeException("The statement: <statement> will never be executed"))];
			return;
		}
		if((Statement) `<ReturnStatement _>` := statement){
			bodyHasReturnStatement = true;
		}
		typeCheckStatement(statement);
		
	}
	
	TypeEnvironment modifiedEnvironment = domainX(environment, variables); 
	for(str newVariable <- domain(modifiedEnvironment)){
		environment = delete(environment, newVariable);
	}
	
	for(Statement statement <- ifstatement.elseBranch){
		if(bodyHasReturnStatement){
			errors += [Error(statement@\loc, UnreachableCodeException("The statement: <statement> will never be executed"))];
			return;
		}
		if((Statement) `<ReturnStatement _>` := statement){
			bodyHasReturnStatement = true;
		}
		typeCheckStatement(statement);
	}
	
	modifiedEnvironment = domainX(environment, variables); 
	for(str newVariable <- domain(modifiedEnvironment)){
		environment = delete(environment, newVariable);
	}
}

public void typeCheckStatement(stmt:(Statement)`<WhileLoop wl>`){
	Type conditionType = typeCheckExpression(wl.condition);
	if(conditionType is Error){
		errors += [conditionType];
		return;
	}
	if(!conditionType is Boolean){
		errors += [Error(stmt@\loc, IllegalArgumentException("Condition in while loop must be of type Boolean"))];
		return;
	}
	
	set[str] variables = domain(environment);
	bool bodyHasReturnStatement = false;
	for(Statement statement <- wl.statements){
		if(bodyHasReturnStatement){
			errors += [Error(statement@\loc, UnreachableCodeException("The statement: <statement> will never be executed"))];
			return;
		}
		if((Statement) `<ReturnStatement _>` := statement){
			bodyHasReturnStatement = true;
		}
		typeCheckStatement(statement);
	}
	
	TypeEnvironment modifiedEnvironment = domainX(environment, variables); 
	for(str newVariable <- domain(modifiedEnvironment)){
		environment = delete(environment, newVariable);
	}
	
}

public void typeCheckStatement(stmt:(Statement)`<ArrayExpression ae>=<Expression e>;`){
	Type arrayType = typeCheckArrayExpression(ae);
	Type expressionType = typeCheckExpression(e);
	if(arrayType is Error){
		errors += [arrayType];
		return;
	}
	if(expressionType is Error){
		errors += [expressionType];
		return;
	}
	if(arrayType != expressionType){
			errors += [Error(stmt@\loc, TypeMismatchException("Cant update element to type <expressionType> in an array of type <arrayType>"))];
	}
}


public void typeCheckStatement(functionCall:(Statement)`<FunctionCall funcCall>;`){
	Type functionCallType = typeCheckFunctionCall("<funcCall.name>", [a | a <- funcCall.arguments], functionCall@\loc);
	if(functionCallType is Error){
		errors += [functionCallType];
	}
}

public Type typeCheckFunctionCall(str functionName, list[Argument] arguments, loc location){
	Type functionType = getVariableType(location , functionName);
	if(functionType is Error){
		return functionType;
	}
	
	if(!functionType is Function){
		return Error(location, IllegalArgumentException("Cant call <functionName> because it is not a function"));
	}
	list[Type] parameterTypes = functionType.parameterTypes;
	int parameters = size(parameterTypes);
	int numberOfArguments = size(arguments);
	if(parameters != numberOfArguments){
		return Error(location, 
			ArgumentNumberException("Wrong number of arguments in function call. Expected <parameters> but got <numberOfArguments>"));
			
	}
	
	for(int i <- index(arguments)){
		Type argumentType = typeCheckArgument(arguments[i]);
		if(argumentType is Error){
			return argumentType;
		}

		Type parameterType = parameterTypes[i];
		if(argumentType != parameterType){
			return Error(location, TypeMismatchException("Parameter <i + 1> in function <functionName> should be of type <parameterType> but received argument of type <argumentType>"));
		}
	}
	return functionType.returnType;
}

public Type typeCheckArgument((Argument) `<Expression e>`){
	return typeCheckExpression(e);
}


// *********************
// EXPRESSION TYPE CHECK
// *********************

public Type typeCheckExpression(expression:(Expression) `<Expression e1><RelationalOperator relop><Expression e2>`){
	Type expression1Type = typeCheckExpression(e1);
	if(expression1Type is Error){
		return expression1Type;
	}
	
	Type expression2Type = typeCheckExpression(e2);
	if(expression2Type is Error){
		return expression2Type;
	}
	
	if("<relop>" in ["==", "!="] && expression1Type != expression2Type){
		return Error(expression@\loc, TypeMismatchException("Cannot check for equality between <expression1Type> and <expression2Type>"));
	}
	
	if("<relop>" in ["\<", "\>", "\<=", "\>="]){
		if(!(expression2Type is Integer) 
			|| (!expression1Type is Integer 
			&& !((Expression)`<Expression _><RelationalOperator relop2><Expression _>` := e1 
			&& "<relop2>" in ["\<", "\>", "\<=", "\>="]))){
			return Error(expression@\loc, IllegalArgumentException("Illegal type applied to <relop> operator. Type must be of Integer"));
		}
	}
	
	return Boolean();
}

public Type typeCheckExpression((Expression)`(<Expression e>)`){
	return typeCheckExpression(e);
}

public Type typeCheckExpression((Expression)`<IfExpression ie>`){
	return typeCheckIfExpression(ie);
}

public Type typeCheckIfExpression(ifexpr:(IfExpression) `<Expression condition>?<Expression thenExpr>:<Expression elseExpr>`){
	Type conditionType = typeCheckExpression(condition);
	if(conditionType is Error){
		return conditionType;
	}
	
	if(!conditionType is Boolean){
		return Error(ifexpr@\loc, IllegalArgumentException("Illegal type in if condition. Type must be Boolean"));
	}
	
	Type thenExpressionType = typeCheckExpression(thenExpr);
	if(thenExpressionType is Error){
		return thenExpressionType;
	}
	
	Type elseExpressionType = typeCheckExpression(elseExpr);
	if(elseExpressionType is Error){
		return elseExpressionType;
	}
	
	if(thenExpressionType != elseExpressionType){
		return Error(ifexpr@\loc, TypeMismatchException("Both branches in an if statement must be of the same type"));
	}
	
	return thenExpressionType;
}


public Type typeCheckExpression(functionCall:(Expression)`<FunctionCall funcCall>`){
	return typeCheckFunctionCall("<funcCall.name>", [a | a <- funcCall.arguments], functionCall@\loc);
}

public Type typeCheckExpression(expression:(Expression) `<UnaryOperator uop><Expression e>`){
	
	Type expressionType = typeCheckExpression(e);
	
	if(expressionType is Error){
		return expressionType;
	}
	
	if("!" == "<uop>"){
		if(!(expressionType is Boolean)){
			return Error(expression@\loc, IllegalArgumentException("Illegal type applied to <uop> operator. Type must be of Boolean"));
		}
		return Boolean();
	}else if("-" == "<uop>"){
		if(!(expressionType is Integer)){
			return Error(expression@\loc, IllegalArgumentException("Illegal type applied to <uop> operator. Type must be of Integer"));
		}
		return Integer();
	}
	return expressionType;
}

public Type typeCheckExpression(expression:(Expression) `<Expression e1><LowerPrecedenceOperator lpop><Expression e2>`){
	Type expression1Type = typeCheckExpression(e1);
	if(expression1Type is Error){
		return expression1Type;
	}
	
	Type expression2Type = typeCheckExpression(e2);
	if(expression2Type is Error){
		return expression2Type;
	}
	
	if("||" == "<lpop>"){
		if(!(expression1Type is Boolean) || !(expression2Type is Boolean)){
			return Error(expression@\loc, IllegalArgumentException("Illegal type applied to <lpop> operator. Type must be of Boolean"));
		}
		return Boolean();
	}else if("-" == "<lpop>"){ 
		if(!(expression1Type is Integer) || !(expression2Type is Integer)){
			return Error(expression@\loc, IllegalArgumentException("Illegal type applied to <lpop> operator. Type must be of Integer"));
		}
		return Integer();
	}else if ("+" == "<lpop>"){
		if(expression1Type is Array && expression2Type is Array){
			if(expression1Type.t != expression2Type.t){
					return Error(expression@\loc, TypeMismatchException("Cant concatenate array of type <expression1Type.t> to array of type <expression2Type.t>"));
			}else {
				return expression1Type;
			}
		}
		if(!(expression1Type is Integer) || !(expression2Type is Integer)){
			return Error(expression@\loc, IllegalArgumentException("Illegal type applied to <lpop> operator. Type must be of Integer or arrays of the same type"));
		}
	}
	
	return expression1Type;
}

public Type typeCheckExpression(expression:(Expression) `<Expression e1><HigherPrecedenceOperator hpop><Expression e2>`){
	println(e1);
	Type expression1Type = typeCheckExpression(e1);
	if(expression1Type is Error){
		return expression1Type;
	}
	
	Type expression2Type = typeCheckExpression(e2);
	if(expression2Type is Error){
		return expression2Type;
	}
	
	if("<hpop>" == "*" || "<hpop>" == "/"){
		if(!(expression1Type is Integer) || !(expression2Type is Integer)){
			return Error(expression@\loc, IllegalArgumentException("Illegal type applied to <hpop> operator. Type must be of Integer"));
		}
		return Integer();
	}
	
	else if("<hpop>" == "&&"){
		if(!(expression1Type is Boolean) || !(expression2Type is Boolean)){
			return Error(expression@\loc, IllegalArgumentException("Illegal type applied to <hpop> operator. Type must be of Boolean"));
		}
		return Boolean();
	}
	return expression1Type;
}

public Type typeCheckExpression((Expression) `<INTEGER n>`){
	return Integer();
}

public Type typeCheckExpression((Expression) `<BOOLEAN b>`){
	return Boolean();
}

public Type typeCheckExpression(expression:(Expression) `<ID id>`){
	str idStr = "<id>";
	if(idStr notin environment){
		return Error(expression@\loc, UndefinedVariableException("Variable <idStr> has not been defined"));
	}
	return environment[idStr];
}

public Type typeCheckExpression(arrayExpr:(Expression)`<ArrayList array>`){
	list[Type] elements = [];
	for(Expression element <-  array.elements){
		elements += [typeCheckExpression(element)];
	}
	
	if(isEmpty(elements)){
		return Array(Void());
	}
	
	Type arrayType = head(elements);
	
	for(Type elementType <- elements){
		if(elementType != arrayType){
			return Error(arrayExpr@\loc, TypeMismatchException("Not every element in the array is of the same type"));
		}
	}
	return Array(arrayType);
}

public Type typeCheckExpression((Expression) `<ArrayExpression ae>`){
	return typeCheckArrayExpression(ae);
}

public Type typeCheckArrayExpression(arrexpr:(ArrayExpression) `<ID id>[<Expression e>]`){
	Type variableType = getVariableType(arrexpr@\loc, "<id>");
	if(variableType is Error){
		return variableType;
	}
	if(!variableType is Array){
		return Error(arrexpr@\loc, TypeMismatchException("Cannot retrieve an element from a variable that is not an array"));
	}
	
	Type expressionType = typeCheckExpression(e);
	
	if(expressionType is Error){
		return expressionType;
	}
	
	if(!expressionType is Integer){
		return Error(arrexpr@\loc, IllegalArgumentException("An index must be of type integer"));
	}
	
	return variableType.t;
}

public Type typeCheckExpression(expr:(Expression)`<ArraySize as>`){
	if((Expression) `<ID id>` := as.array){
		Type array = getVariableType(expr@\loc, "<id>");
		if(array is Error){
			return array;
		}
		if (!array is Array){
			return Error(expr@\loc, IllegalArgumentException("An argument to the size method can only an Array literal, or a variable that is of an Array type"));
		}
	}
	if(!(Expression) `<ArrayList _>` := as.array){
		return Error(expr@\loc, IllegalArgumentException("An argument to the size method can only an Array literal, or a variable that is of an Array type"));
	}
	return Integer();
}

// **************
// HELPER METHODS
// **************

public Type getTypeFromTypeName(TypeName typeName){
	if((TypeName)`<TYPEID name>[]` := typeName){
		Type arrayType = getTypeFromTypeId(typeName@\loc, "<name>");
		if(arrayType is Error){
			return arrayType;
		}
		return Array(arrayType);
	}
	return getTypeFromTypeId(typeName@\loc, "<typeName.name>");
}

public Type getTypeFromTypeId(loc location, str id){
	switch(id){
		case "int":
			return Integer();
		case "bool":
			return Boolean();
		case "void":
			return Void();
		default:
			return Error(location, UnknownTypeException("There is no type called <id>")); 
	}
}

public Type getVariableType(loc location, str id){
	if(id notin environment){
		return Error(location, UndefinedVariableException("Variable <id> has not been defined"));
	}
	return environment[id];
}

public bool doesIfStatementHaveReturnStatement(IfStatement ifStatement, FunctionDeclaration function){
	bool thenBranchHasReturn = false;
	bool elseBranchHasReturn = false;
	
	for(Statement statement <- ifStatement.thenBranch){
		if((Statement)`return;` := statement || (Statement)`return<Expression _>;` := statement){
			typeCheckReturnStatement(statement, function);
			thenBranchHasReturn = true;
		}
		if((Statement)`<IfStatement ifs>` := statement && !thenBranchHasReturn){
			thenBranchHasReturn = doesIfStatementHaveReturnStatement(ifs, function);
		}
	}
	
	for(Statement statement <- ifStatement.elseBranch){
		if((Statement)`return;` := statement || (Statement)`return<Expression _>;` := statement){
			typeCheckReturnStatement(statement, function);
			elseBranchHasReturn = true;
		}
		if((Statement)`<IfStatement ifs>` := statement && !elseBranchHasReturn){
			elseBranchHasReturn = doesIfStatementHaveReturnStatement(ifs, function);
		}
	}
	
	return (thenBranchHasReturn && elseBranchHasReturn);
}
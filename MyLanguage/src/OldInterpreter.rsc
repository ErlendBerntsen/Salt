module OldInterpreter

import String;
import ParseTree;
import Map;
import List;
import IO;
import TypeChecker;
import OldSail;

alias ValueEnvironment = map[str, Type];
alias FunctionParameters = map[str, list[str]];
alias FunctionBodies = map[str, list[Statement]];

private FunctionParameters functionParameters = ();
private FunctionBodies functionBodies = ();
private ValueEnvironment environment = ();
private list[str] instructions = [];
private set[str] globals = {};


public ValueEnvironment run(str text){
	tree = parse(#start[Program], text).top;
	interpretProgram(tree);
	return environment;
}

public void interpretProgram(Program program){
	environment = ();
	globals = {};
	instructions = [];
	
	for(VariableDeclaration variableDeclaration <- program.variableDeclarations){
		globals += "<variableDeclaration.name>";
		interpretVariableDeclaration(variableDeclaration);
	}
	
	for(FunctionDeclaration functionDeclaration <- program.functionDeclarations){
		globals += "<functionDeclaration.name>";
		interpretFunctionDeclaration(functionDeclaration);
	}
	
	interpretFunctionCall("main", []);
	for(str instruction <- instructions){
		println("<instruction>");
	}
}

// *********************************
// VARIABLE DECLARATION INTERPRETING
// *********************************

public void interpretVariableDeclaration((VariableDeclaration) `<TypeName _><ID id>=<Expression e> ;`){	
	Type expressionValue = evalExpression(e);
	environment["<id>"] = expressionValue;
	instructions += ["Variable initilization: setting <id> to <expressionValue>"];
}

public void interpretVariableDeclaration((VariableDeclaration) `<TypeName _><ID id> ;`){	
	environment["<id>"] = Void();
	instructions += ["Variable declaration: setting <id> to <Void()>"];
}

// *********************************
// FUNCTION DECLARATION INTERPRETING
// *********************************

public void interpretFunctionDeclaration(FunctionDeclaration function){	
	list[str] parameterNames = [];
	list[Statement] functionBody = [];
	list[Type] parameterTypes = [];
	
	for((Parameter) `<TypeName t><ID id>` <- function.parameters){
		parameterNames += ["<id>"];
		parameterTypes += getTypeFromTypeName(t);
	}
	
	for(Statement statement <- function.body){
		functionBody += [statement];
	}
	
	functionParameters["<function.name>"] = parameterNames;
	functionBodies["<function.name>"] = functionBody;
	Type functionType = Function(getTypeFromTypeName(function.returnType), parameterTypes);
	//environment["<function.name>"] = functionType;
	instructions += ["Function declaration: setting <function.name> to <functionType>"];
}


// **************************
// FUNCTION CALL INTERPRETING
// **************************

public Type interpretFunctionCall(str functionName, list[Type] argumentValues){
	ValueEnvironment nonGlobals = domainX(environment, globals);
	environment = domainR(environment, globals);
	list[str] parameterNames = functionParameters[functionName];
	
	//println("Calling function: <functionName>");
	
	for(int i <- index(argumentValues)){
	
		Type argumentValue = argumentValues[i];
		//println("argument value: <argumentValue>");
		//println("environment before: <environment>");
		environment[parameterNames[i]] = argumentValue;
		//println("environment after: <environment>");
		
	}
	
	instructions += ["Function call: calling function <functionName> with arguments <argumentValues>"];		
	
	for(Statement statement <- functionBodies[functionName]){
		if(isReturnStatement(statement)){
			Type returnValue = interpretReturnStatement(statement);
			environment = nonGlobals + domainR(environment, globals);
			return returnValue;
		}
		
		if((Statement) `<IfStatement _>` := statement){
			<hasReturnStatement, returnValue> = interpretIfStatement(statement);
			if(hasReturnStatement){
				environment = nonGlobals + domainR(environment, globals);
				return returnValue;
			}
		}else{
			interpretStatement(statement);
		}
	}
	
	environment = nonGlobals + domainR(environment, globals);
	return Void();
}

public Type interpretReturnStatement(Statement returnStatement){
	if((Statement)`return<Expression e>;` := returnStatement){
		Type returnValue = evalExpression(e);
		return returnValue;
	}
	return Void();
}

public Type evalArgument((Argument) `<Expression e>`){
	return evalExpression(e);
}

// **********************
// STATEMENT INTERPRETING
// **********************

public void interpretStatement((Statement) `<VariableDeclaration vd>`){
	return interpretVariableDeclaration(vd);	
}

public void interpretStatement((Statement) `<ID id>=<Expression e>;`){
	Type expressionValue = evalExpression(e);
	environment["<id>"] = expressionValue;
	instructions += ["Variable assignment: setting <id> to <expressionValue>"];
}

public void interpretStatement((Statement) `<FunctionCall funcCall>;`){
	str functionName = "<funcCall.name>";
	list[Type] argumentValues = [];
	for(Argument argument <- funcCall.arguments){
		argumentValues += [evalArgument(argument)];
	}
	interpretFunctionCall(functionName, argumentValues);
}

public void interpretStatement((Statement) `print(<Expression e>);`){
	Type expressionValue = evalExpression(e);
	if(expressionValue is Integer){
		println("<expressionValue.n>");
	}else if(expressionValue is Boolean){
		println("<expressionValue.b>");
	}
	instructions += ["Print statement: printing <expressionValue>"];
}

public tuple[bool, Type] interpretIfStatement((Statement) `<IfStatement ifstatement>`){
	set[str] variablesInScope = domain(environment);
	Type conditionValue = evalExpression(ifstatement.condition);
	
	if(conditionValue.b){
		for(Statement statement <- ifstatement.thenBranch){
			if(isReturnStatement(statement)){
				return <true, interpretReturnStatement(statement)>;
			}
			if((Statement) `<IfStatement _>` := statement){
				<hasReturnStatement, returnValue> = interpretIfStatement(statement);
				if(hasReturnStatement){
					return <hasReturnStatement, returnValue>;
				}
			} else{
				interpretStatement(statement);
			}
		}
	}
	else{
		for(Statement statement <- ifstatement.elseBranch){
			if(isReturnStatement(statement)){
				return <true, interpretReturnStatement(statement)>;
			}
			if((Statement) `<IfStatement _>` := statement){
				<hasReturnStatement, returnValue> = interpretIfStatement(statement);
				if(hasReturnStatement){
					return <hasReturnStatement, returnValue>;
				}
			} else{
				interpretStatement(statement);
			}
		}
	}
	//println("Variables before deleting: <environment>");
	environment = domainR(environment, variablesInScope);
	//println("Variables after deleting: <environment>");
	return <false, Void()>;
	
}


// *********************
// EXPRESSION EVALUATION
// *********************

public Type evalExpression((Expression)`<SimpleExpression se>`){
	return evalSimpleExpression(se);
}

public Type evalExpression((Expression) `<SimpleExpression se1><RelationalOperator relop><SimpleExpression se2>`){
	Type value1 = evalSimpleExpression(se1);
	Type value2 = evalSimpleExpression(se2);
	switch("<relop>"){
		case "\<": 
			return Boolean(value1.n < value2.n);
		case "\<=": 
			return Boolean(value1.n <= value2.n);
		case "\>": 
			return Boolean(value1.n > value2.n);
		case "\>=": 
			return Boolean(value1.n >= value2.n);
		case "==": 
			if(value1 is Integer){
				return Boolean(value1.n == value2.n);
			}else{
				return Boolean(value1.b == value2.b);
			}
		case "!=": 
			if(value1 is Integer){
				return Boolean(value1.n != value2.n);
			}else{
				return Boolean(value1.b != value2.b);
			}
		default: 
			return Void();
	}
}

public Type evalExpression((Expression) `<FunctionCall funcCall>`){
	str functionName = "<funcCall.name>";
	list[Type] argumentValues = [];
	for(Argument argument <- funcCall.arguments){
		argumentValues += [evalArgument(argument)];
	}
	return interpretFunctionCall(functionName, argumentValues);
}


public Type evalExpression((Expression)`<IfExpression ie>`){
	return evalIfExpression(ie);
}

public Type evalExpression((Expression) `(<Expression e>)`){
	return evalExpression(e);
}

public Type evalIfExpression((IfExpression)`<Expression condition>?<Expression thenBranch>:<Expression elseBranch>`){
	Type conditionValue = evalExpression(condition);
	if(conditionValue.b){
		return evalExpression(thenBranch);
	}
	return evalExpression(elseBranch);
}

public Type evalExpression(arrayExpr:(Expression)`<ArrayExpression array>`){
	list[Type] elements = [];
	for(Expression element <- array.elements){
		elements += [evalExpression(element)] ;
	}
	return Array(elements);
}

// ****************************
// SIMPLE EXPRESSION EVALUATION
// ****************************

public Type evalSimpleExpression((SimpleExpression)`<Term t>`){
	return evalTerm(t);
}

public Type evalSimpleExpression((SimpleExpression)`<UnaryOperator uop><Term t>`){
	if("<uop>" == "!"){
		return Boolean(!evalTerm(t).b);
	}
	return Integer(-evalTerm(t).n);
}

public Type evalSimpleExpression((SimpleExpression)`<SimpleExpression se><LowerPrecedenceOperator lpop><Term t>`){
	Type value1 = evalSimpleExpression(se);
	Type value2 = evalTerm(t);
	switch("<lpop>"){
		case "+": 
			return Integer(value1.n + value2.n);
		case "-": 
			return Integer(value1.n - value2.n);
		case "||":
			return Boolean(value1.b || value2.b);
		default: 
			return Void();
	}
	
}

// ***************
// TERM EVALUATION
// ***************

public Type evalTerm((Term) `<Factor f>`){
	return evalFactor(f);
}

public Type evalTerm((Term) `<Term t><HigherPrecedenceOperator hpop><Factor f>`){
	Type value1 = evalTerm(t);
	Type value2 = evalFactor(f);
	switch("<hpop>"){
		case "*": 
			return Integer(value1.n * value2.n);
		case "/": 
			return Integer(value1.n / value2.n);
		case "&&":
			return Boolean(value1.b && value2.b);
		default: 
			return Void();
	}
	
}


// *****************
// FACTOR EVALUATION
// *****************

public Type evalFactor((Factor)`<INTEGER n>`){
	return Integer(toInt("<n>"));
}

public Type evalFactor((Factor)`<Boolean b>`){
	bool val = true;
	if("<b>" == "false"){
		val = false;
	}
	return Boolean(val);
}

public Type evalFactor((Factor)`<ID id>`){
	return environment["<id>"];
}

public bool isReturnStatement(Statement statement){
	return (Statement)`return<Expression _>;` := statement || (Statement) `return;` := statement;
}

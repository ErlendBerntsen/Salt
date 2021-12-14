module Interpreter

import String;
import ParseTree;
import Map;
import List;
import IO;
import TypeChecker;
import Sail;

alias ValueEnvironment = map[str, Type];
alias FunctionParameters = map[str, list[str]];
alias FunctionBodies = map[str, list[Statement]];

private FunctionParameters functionParameters = ();
private FunctionBodies functionBodies = ();
private ValueEnvironment environment = ();
private list[str] instructions = [];
private set[str] globals = {};


public ValueEnvironment rf(str file, bool printInstructions=false){
	if(!tcf(file)){
		println("Could not run program since it contains errors");
		return ();
	}
	loc fileLoc = |project://MyLanguage/src/| + (file + ".txt");
	tree = parse(#start[Program], fileLoc).top;
	interpretProgram(tree, printInstructions);
	return environment;
}

public ValueEnvironment run(str text, bool printInstructions=false){
	if(!typeCheck(text)){
		println("Could not run program since it contains errors");
		return ();
	}
	tree = parse(#start[Program], text).top;
	interpretProgram(tree, printInstructions);
	return environment;
}

public void interpretProgram(Program program, bool printInstructions){
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
	
	if(printInstructions){
		for(str instruction <- instructions){
		println("<instruction>");
		}
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
	instructions += ["Function declaration: setting <function.name> to <functionType>"];
}


// **************************
// FUNCTION CALL INTERPRETING
// **************************

public Type interpretFunctionCall(str functionName, list[Type] argumentValues){
	//Get current environment without global variables and functions
	ValueEnvironment nonGlobals = domainX(environment, globals);
	//Change the environment to only include the global variables and functions
	environment = domainR(environment, globals);
	list[str] parameterNames = functionParameters[functionName];
		
	//Add the parameters to the environment, assigning them to the values of the argument expresions
	for(int i <- index(argumentValues)){
		Type argumentValue = argumentValues[i];
		environment[parameterNames[i]] = argumentValue;		
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
			
		}else if((Statement)`<WhileLoop _>` := statement){
			<hasReturnStatement, returnValue> = interpretWhileLoop(statement);
			if(hasReturnStatement){
				environment = nonGlobals + domainR(environment, globals);
				return returnValue;
			}
		}else{
			interpretStatement(statement);
		}
	}
	//Change the environment back to the environment before the function call that excluded the global variables and functions
	//Take the non-global environment and add it together with the environment of the global variables
	//This makes sure any side-effects on global variables in a function call is saved to the environment after exiting the function
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

public void interpretStatement((Statement) `<ID id>/<Expression e>;`){
	int index = evalExpression(e).n;
	environment["<id>"] = Array(delete(environment["<id>"].l, index));
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
	}else if(expressionValue is Array){
		println("<expressionValue.l>");
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
			} else if((Statement) `<WhileLoop _>` := statement){
				<hasReturnStatement, returnValue> = interpretWhileLoop(statement);
				if(hasReturnStatement){
					return <hasReturnStatement, returnValue>;
				}
			}else{
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
			}else if((Statement) `<WhileLoop _>` := statement){
				<hasReturnStatement, returnValue> = interpretWhileLoop(statement);
				if(hasReturnStatement){
					return <hasReturnStatement, returnValue>;
				}
			}else{
				interpretStatement(statement);
			}
		}
	}
	environment = domainR(environment, variablesInScope);
	return <false, Void()>;
}

public tuple[bool, Type] interpretWhileLoop((Statement) `<WhileLoop wl>`){
	//Remember the variables in scope before entering body
	set[str] variablesInScope = domain(environment);
	Type conditionValue = evalExpression(wl.condition);
	while(conditionValue.b){
		for(Statement statement <- wl.statements){
			if(isReturnStatement(statement)){
				return <true, interpretReturnStatement(statement)>;
			}
			if((Statement) `<IfStatement _>` := statement){
				<hasReturnStatement, returnValue> = interpretIfStatement(statement);
				if(hasReturnStatement){
					return <hasReturnStatement, returnValue>;
				}
			} else if((Statement) `<WhileLoop _>` := statement){
				<hasReturnStatement, returnValue> = interpretWhileLoop(statement);
				if(hasReturnStatement){
					return <hasReturnStatement, returnValue>;
				}
			}else{
				interpretStatement(statement);
			}
		}
		conditionValue = evalExpression(wl.condition);
	}
	//Remove all new variables initialized in body, keep the ones that was in scope before entering the body
	environment = domainR(environment, variablesInScope);
	return <false, Void()>;
}

public void interpretStatement((Statement) `<ArrayExpression ae>=<Expression e>;`){
	Type array = environment["<ae.var>"];
	Type index = evalExpression(ae.index);
	Type expressionValue = evalExpression(e);
	if(expressionValue is Integer){
		array.l[index.n] = Integer(expressionValue.n);
		environment["<ae.var>"] = Array(array.l);
		instructions += ["Updating index <index.n> of array <ae.var> to <expressionValue.n>"];	 
	}
	else if(expressionValue is Boolean){
		array.l[index.n] = Boolean(expressionValue.b);
		environment["<ae.var>"] = Array(array.l);
		instructions += ["Updating index <index.n> of array <ae.var> to <expressionValue.b>"];	 
	}
}


// *********************
// EXPRESSION EVALUATION
// *********************

public Type evalExpression((Expression) `<Expression e1><RelationalOperator relop><Expression e2>`){
	Type value1 = evalExpression(e1);
	if((Expression)`<Expression _><RelationalOperator _><Expression e12>` := e1){
		if(value1.b == false){
			return value1;
		}
		value1 = evalExpression(e12);
	}
	Type value2 = evalExpression(e2);
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
			} else if(value1 is Array){
				return Boolean(value1.l == value2.l);
			}
			else{
				return Boolean(value1.b == value2.b);
			}
		case "!=": 
			if(value1 is Integer){
				return Boolean(value1.n != value2.n);
			}else if(value1 is Array){
				return Boolean(value1.l != value2.l);
			}
			else{
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

public Type evalExpression(arrayExpr:(Expression)`<ArrayList array>`){
	list[Type] elements = [];
	for(Expression element <- array.elements){
		elements += [evalExpression(element)] ;
	}
	return Array(elements);
}

public Type evalExpression((Expression)`<ArrayExpression array>`){
	Type arr = environment["<array.var>"];
	return arr.l[evalExpression(array.index).n];
}

public Type evalExpression((Expression)`<ArraySize as>`){
	Type array = evalExpression(as.array);
	return Integer(size(array.l));
}

public Type evalExpression((Expression)`<UnaryOperator uop><Expression e>`){
	if("<uop>" == "!"){
		return Boolean(!evalExpression(e).b);
	}
	return Integer(-evalExpression(e).n);
}

public Type evalExpression((Expression)`<Expression e1><LowerPrecedenceOperator lpop><Expression e2>`){
	Type value1 = evalExpression(e1);
	Type value2 = evalExpression(e2);
	if("<lpop>" == "+" && value1 is Array && value2 is Array){
		return Array(value1.l + value2.l);
	}
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

public Type evalExpression((Expression) `<Expression e1><HigherPrecedenceOperator hpop><Expression e2>`){
	Type value1 = evalExpression(e1);
	Type value2 = evalExpression(e2);
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

public Type evalExpression((Expression)`<INTEGER n>`){
	return Integer(toInt("<n>"));
}

public Type evalExpression((Expression)`<BOOLEAN b>`){
	bool val = true;
	if("<b>" == "false"){
		val = false;
	}
	return Boolean(val);
}

public Type evalExpression((Expression)`<ID id>`){
	return environment["<id>"];
}

public bool isReturnStatement(Statement statement){
	return (Statement)`<ReturnStatement _>` := statement;
}

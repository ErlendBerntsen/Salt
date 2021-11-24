module SaltTypeChecker

import String;
import ParseTree;
import Map;
import List;
import IO;
import Salt;


data Type = Integer(int n) | Integer() | Boolean() | Boolean(bool b) | Undefined() | Error(loc location, Exception exception);

data Exception 
	= IllegalArgumentException(str s) 
	| VariableAlreadyInScopeException(str s)
	| TypeMismatchException(str s);

alias Environment = map[str, int];
alias Store = list[int]; //TODO make generic
alias Errors = list[Type];
alias Context = tuple[Environment, Store, Errors];

public bool typeCheck(str text){
	tree = parse(#start[Program], text).top;
	<environment, store, errors> =  typeCheckProgram(tree);
	if([] == errors){
		return true;
	}
	for(Type error <- errors){
		println(error);
	}
	return false;
}

public Context typeCheckProgram(Program program){
	Environment environment = ();
	Store store = [];
	Errors errors = [];
	
	for(VariableDeclaration variableDeclaration <- program.variableDeclarations){
		<environment, store, errors> = typeCheckVariableDeclaration(variableDeclaration, environment, store, errors);
	}
	
	for(FunctionDeclaration functionDeclaration <- program.functionDeclarations){
		<environment, store, errors> = typeCheckFunctionDeclaration(functionDeclaration, environment, store, errors);
	}
	if(errors != []){
		return <environment, store, errors>;
	}
	println("Environment:");
	for(str key <- environment){
		printlnExp("Key: ", key);
		printlnExp("Index: ", environment[key]);
		printlnExp("Value: ", store[environment[key]]);
	}
	return <environment, store, errors>;
}




//public tuple[Environment, Store] typeCheckStatement((Statement) `<ID id>=<Expression e>`, Environment environment, Store store){
	//TODO
//	
//}

//TODO type check function call
//TODO type check return statement




public Context typeCheckVariableDeclaration(vd:(VariableDeclaration) `<TypeName t><ID id>`, Environment environment, Store store, Errors errors){
	str idKey = "<id>";
	if(idKey in environment){
		errors += [Error(vd@\loc, VariableAlreadyInScopeException("Variable <id>  is already defined"))];
	}
	else{
		environment[idKey] = size(store);
		//TODO store = store + [0];
	}
	return <environment, store, errors>;
}


public Context typeCheckVariableDeclaration(vd:(VariableDeclaration) `<TypeName t><ID id>=<Expression e>`, Environment environment, Store store, Errors errors){
	str idKey = "<id>";
	if(idKey in environment){
		errors += [Error(vd@\loc, VariableAlreadyInScopeException("Variable <id> is already defined"))];
	}
	else{
		Type variableType = getTypeFromTypeName(t);
		//printlnExp("Variable type: ", variableType);
		Type expressionType = typeCheckExpression(e, environment, store);
		if(expressionType is Error){
			errors += [expressionType];
			return <environment, store, errors>;
		}
		//printlnExp("Expression type: ", expressionType);
		else if(variableType != expressionType){
			errors += [Error(vd@\loc, TypeMismatchException("Cannot assign variable <id> of type <variableType> to type <expressionType>"))];
			return <environment, store, errors>;
		}
		environment[idKey] = size(store);
		//TODO
		store = store + [0];
		//store = store + [evalExpression(e, environment, store)];
	}
	return <environment, store, errors>;
}

public Context typeCheckFunctionDeclaration(FunctionDeclaration function, Environment environment, Store store, Errors errors){
	Type returnType = getTypeFromTypeName(function.returnType);
	str functionName = "<function.name>";
	if(functionName in environment){
		errors += [Error(function@\loc ,VariableAlreadyInScopeException("Identifier <functionName> is already defined"))];
	}
	//Parameters parameters = function.parameters;
	//for(Parameter parameter <- parameters){
		//Type type = getTypeFromName(parameter.tsype);
		//lookup parameter name
	//}
	
	for(Statement statement <- function.body){
		<environment, store, errors> = typeCheckStatement(statement, environment, store, errors);
	}
	
	return <environment, store, errors>;
}


public Context typeCheckStatement((Statement) `<VariableDeclaration vd>`, Environment environment, Store store, Errors errors){
	return typeCheckVariableDeclaration(vd, environment, store, errors);
}


public Type typeCheckExpression((Expression) `<SimpleExpression se>`, Environment environment, Store store){
	return typeCheckSimpleExpression(se, environment, store);
}

public Type typeCheckSimpleExpression((SimpleExpression) `<Term t>`, Environment environment, Store store){
	return typeCheckTerm(t, environment, store);
}

public Type typeCheckTerm((Term) `<Factor f>`, Environment environment, Store store){
	return getFactorType(f, environment, store);
}

public Type typeCheckTerm(term:(Term) `<Term t>*<Factor f>`, Environment environment, Store store){
	Type termType = typeCheckTerm(t, environment, store);
	if(termType is Error){
		return termType;
	}
	Type factorType = getFactorType(f, environment, store);
	if(termType != Integer() || factorType != Integer()){
		return Error(term@\loc, IllegalArgumentException("Illegal type applied to * operator. Type must be of Integer"));
	}
	return termType;
}

public Type getFactorType((Factor) `<Integer n>`, Environment environment, Store store){
	return Integer();
}

public Type getFactorType((Factor) `<Boolean b>`, Environment environment, Store store){
	return Boolean();
}

public Type getTypeFromTypeName(typeName: (TypeName) `<TypeName t>`){
	switch("<t>"){
		case "int":
			return Integer();
		case "bool":
			return Boolean();
		default:
			return Integer(); //TODO
	}
}

public int findIndex(Environment environment, str id){
	return environment[id];
}
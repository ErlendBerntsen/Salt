module Evaluator

import String;
import Salt;

alias ValueEnvironment = map[str, value];

//public Type eval(str txt){
//	Environment environment = ();
//	Store store = [];
//	return Integer(evalExpression(parse(#Expression, txt), environment, store));
//}

public value evalExpression((Expression)`<SimpleExpression se>`, Environment environment, Store store){
	return evalSimpleExpression(se, environment, store);
}

public value evalSimpleExpression((SimpleExpression)`<UnaryOperator uop><Term t>`,Environment environment, Store store){
	return -evalTerm(t, environment, store);
}

public value evalSimpleExpression((SimpleExpression)`<Term t>`, Environment environment, Store store){
	return evalTerm(t, environment, store);
}

public value evalSimpleExpression((SimpleExpression)`<SimpleExpression se>+<Term t>`, Environment environment, Store store){
	return evalSimpleExpression(se, environment, store) + evalTerm(t, environment, store);
}

public value evalSimpleExpression((SimpleExpression)`<SimpleExpression se>-<Term t>`, Environment environment, Store store){
	return evalSimpleExpression(se, environment, store) - evalTerm(t, environment, store);
}

public value evalTerm((Term) `<Term t>*<Factor f>`, Environment environment, Store store){
	return evalTerm(t, environment, store) * evalFactor(f, environment, store);
}

public value evalTerm((Term) `<Term t>/<Factor f>`, Environment environment, Store store){
	return evalTerm(t, environment, store) / evalFactor(f, environment, store);
}

public value evalTerm((Term) `<Factor f>`, Environment environment, Store store){
	return evalFactor(f, environment, store);
}

public value evalFactor((Factor)`<Integer n>`, Environment environment, Store store){
	return toInt("<n>");
}

public value evalFactor((Factor)`<ID id>`, Environment environment, Store store){
	str idKey = "<id>";
	if(idKey notin environment){
		printlnExp("Error, undefined variable: ", idKey);
	}
	value indexMaybe = environment[idKey];
	if(indexMaybe == "null"){
		printlnExp("Error, unassigned variable: ", idKey);
	}
	return environment[idKey];
}
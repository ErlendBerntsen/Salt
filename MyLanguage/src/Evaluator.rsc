module Evaluator


public Type eval(str txt){
	Environment environment = ();
	Store store = [];
	return Integer(evalExpression(parse(#Expression, txt), environment, store));
}

public int evalExpression((Expression)`<SimpleExpression se>`, Environment environment, Store store){
	return evalSimpleExpression(se, environment, store);
}

public int evalSimpleExpression((SimpleExpression)`<UnaryOperator uop><Term t>`,Environment environment, Store store){
	return -evalTerm(t, environment, store);
}

public int evalSimpleExpression((SimpleExpression)`<Term t>`, Environment environment, Store store){
	return evalTerm(t, environment, store);
}

public int evalSimpleExpression((SimpleExpression)`<SimpleExpression se>+<Term t>`, Environment environment, Store store){
	return evalSimpleExpression(se, environment, store) + evalTerm(t, environment, store);
}

public int evalSimpleExpression((SimpleExpression)`<SimpleExpression se>-<Term t>`, Environment environment, Store store){
	return evalSimpleExpression(se, environment, store) - evalTerm(t, environment, store);
}

public int evalTerm((Term) `<Term t>*<Factor f>`, Environment environment, Store store){
	return evalTerm(t, environment, store) * evalFactor(f, environment, store);
}

public int evalTerm((Term) `<Term t>/<Factor f>`, Environment environment, Store store){
	return evalTerm(t, environment, store) / evalFactor(f, environment, store);
}

public int evalTerm((Term) `<Factor f>`, Environment environment, Store store){
	return evalFactor(f, environment, store);
}

public int evalFactor((Factor)`<Integer n>`, Environment environment, Store store){
	return toInt("<n>");
}

public int evalFactor((Factor)`<ID id>`, Environment environment, Store store){
	str idKey = "<id>";
	if(idKey notin environment){
		printlnExp("Error, undefined variable: ", idKey);
	}
	value indexMaybe = environment[idKey];
	if(indexMaybe == "null"){
		printlnExp("Error, unassigned variable: ", idKey);
	}
	int index = environment[idKey];
	return store[index];
}
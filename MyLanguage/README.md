# Introduction

# Terminals
There are 4 types of terminals:
- Variable name
- Type name
- Number
- Boolean value

## Variable name
Variable name are a sequence of english letters (a-z lowercase or uppercase) and underscores.\
They can be of any length. Note that numbers can't be used and certain keywords are reserved.

### Correct examples
- `var` 
- `VAR`
- `myVariable`
- `my_Long_Variable_Name`

### Incorrect examples
- `var1`
- `my-variable`

## Type name
Type names are use to declare the data type of a variable.\
There are three different data types: integers, booleans and arrays.\
The different type names are:
- `int`
- `bool`
- `int[]`
- `bool[]`
- `void` only allowed for function return types

## Number
Numbers are used to represent integer values.\
Leading zeros are not allowewd.\
There is no restriction on the size of the integer.

## Boolean value
Either `true` or `false`

# Keywords
- `int`
- `bool`
- `void`
- `true`
- `false`
- `print`
- `if`
- `then`
- `else`
- `while`

# Program
A program consists of two parts: global variable declarations or initializations, and functions.\
The execution of the program will start from the main function. It is an **error** if a program doesn't include a main function.\
The main function should be of type void and should not take any arguments, i.e., `void main() {...}`

# Variable declaration & initialization
A variable declaration specifies the data type and name of the variable, e.g., `int variable;`\
A variable initialization specifies the data type and name on the left side of a equals sign,\
 and the initial value of the variable on the right side, e.g. `int variable = 0;`\
A variable can't have the same name as another variable or function that is already in the scope.\
A variable name can't be any of the reserver keywords.\
Variable declarations and initializations always end with a semicolon.

# Function
A function is a sequence of statements, and may take some input and may return a value.\
A function has the form *return type, name, ( parameters), { statements }*\
The return type is type name and can be any data type, including void.\
The function name has the same rules as a variable name, i.e. the name can't already be in scope. (it does not matter if a name as a variable name or function name)\
Any variable declared or initialized inside a function only exist in the scope of that function.


## Parameters
A function may include parameters, but does not need to.\
A parameter consists of a type name, specifying the data type, and a variable name.\
Multiple parameters are seperated using a comma.

## Return statement
A function must have a return statement, except if the return type is `void`, then it may be omitted.\
A return statement must be guaranteed to be executed at runtime.\
That means that a return statement must be in the regular scope of a function, or in both branches of an if-statement.\
A return statement in a while-loop is not guaranteed to be executed.\
A return statement consists of the word `return` followed by an expression and a semicolon.\
The expression part must be omitted in a return statement in a `void` function.\
It is an **error** if the data type of the expression is different from the data type of the specified return type.\
It is an **error** if there exist statements after a return statement that can never be executed.

# Statement
A statement can be seen as a simple line of instruction in a function.\
A statement usually ends with a semicolon.\
There are a handful of different statements:
- Variable declaration or initialization
- Variable assignment
- Function call
- Function return statement
- Print an expression value
- If-statement'
- While-loop'
- Update element in array
- Delete element in array

' = Does not end with a semicolon.

## Variable declaration or initialization
See above for information.

## Variable assignment
Variable assignment updates the value of a variable.\
It includes a variable name, an equal sign, and an expression. i.e. `variable = expression` where "variable" is arbtrary variable in scope and "expression" is an arbitrary expression.\
It is an **error** if the data type of the expression does not match the data type that is declared with the variable.\
It is an **error** if the variable name is not in the scope.

## Function call
A function can be called by specifying the name of a function followed by a pair of paranthesis, and ending with a semicolon.\
Arguments can be placed inside the paranthesis, which corresponds to a parameter in the function declaration.\
Multiple arguments are separated with a comma.\
An argument is just an expression.\
Recursive function calls is allowed.\
It is an **error** if the amount of arguments and the data type of the arguments doesn't match the function declaration

## Function return statement
See above for information.

## Print an expression value
The `print` keyword can be used for printing an expression value to the console.\
The correct syntax for a print statement is exactly the same as a regular function call, i.e., `print(expression);`, where "expression" is an arbitrary expression.

## If-statement
An if-statement consists of three parts:
- A condition
- The "then" branch
- The "else" branch

The condition is just an expression and has the syntax `if(condition)`, where "condition" is an arbitrary expression.\
It is an **error** if the data type of the condition expression is not a boolean.\
If the condition expression is evaluated to `true` the `then` branch will be excuted, and the `else` branch will be skipped.\
If the condition expression is evaluated to `false` the `else` branch will be executed, and the `then` branch will be skipped.\
The branches are just zero or more statements and has the syntax `then{statements}` and `else{statements}`, where "statements" is an arbitrary sequence of statements.\
Any variable declared or initialized inside a branch only exist in the scope of that branch.\
Nesting of if-statements is allowed.\
Note that the "else" branch is **not** optional and must be included in every if-statement.

## While-loop
A while-loop consists of two parts:
- A condition
- A body

Similar to an if-statement, a condition is just an expression and has the syntax `while(condition)`, where "condition" is an arbitrary expression.\
It is an **error** if the data type of the condition expression is not a boolean.\
The body will be excuted indefinitely until the condition expression is evaluated to `false`\
The body is a sequence of statements, and has the syntax `{statements}`, where "statements" is an arbitrary sequence of statements.\
Any variable declared or initialized inside a body of a while-loop only exist in the scope of that body.\
Nesting of while-loops is allowed.

## Update element in array
An element in an array can be updated by specifying the name of the array, the index of the element, and the expression to update that array index to.\
The correct syntax is `arrayname[index] = expression;`, where "arrayname" is a name of an array variable in scope, and "index" and "expression" is any arbitrary expressions.\
It is an **error** if the "arrayname" is not a variable in the scope, or if the data type of the variable is not an array type.\
It is an **error** if the "index" expression is not an integer type.\
It is an **error** if the "expression" is not the same data type as the rest of the elements in the array.\
Note that this statement may result in a run-time error that is not caught by the typechecker if the index is a negative value or higher then the size of the array.

## Delete element in array
An element in an array can be deleted by specifying the name of the array and the index of the element to be removed.\
The correct syntax is `arrayname / index;`, where "arrayname" is a name of an array variable in scope, and "index" is an arbitrary expression.\
It is an **error** if the "arrayname" is not a variable in the scope, or if the data type of the variable is not an array type.\
It is an **error** if the "index" expression is not an integer type.\
Note that this statement may result in a run-time error that is not caught by the typechecker if the index is a negative value or higher then the size of the array.

# Expression
An expression is something that can be evaluated to a specific value of a data type.\
An expression can't exist on its own and should always be a part of a statement.\
There are a handful of different expressions:
- Variable
- Integer value
- Boolean value
- Operation
- Function call
- Inline if-expression
- Expression in paranthesis
- Array literal
- Array element retrieval

## Variable
A variable expression is just the name of an initialized variable.\
The value of a variable is the value of the expression it was intialized to, or the value of the last expression it was assigned to.\
It is an **error** if the variable has not been declared.\
It is an **error** if the variable has been declared but not assigned to value.

## Integer value
A positive integer number as specified in the Number section above.

## Boolean
Either `true` or `false`

## Operation
There are different types of operations and can be split into two categories:
- Unary operation
- Binary operation

Operations have different precedence. Any unary operation has higher precedence than all binary operations.

### Unary operation
There are two types of unary operators, `-` and `!`, which can be put in front of an expression, e.g. `-1`\
`-` is used to represent negative integer values.\
It is an **error** if `-` is placed in front an expression that isn't an integer.\
`!` is used to invert the value of a boolean expression.\
It is an **error** if `!` is placed in front an expression that isn't a boolean.

### Binary operation
Any binary operation is left-associative, i.e., `1 + 2 + 3` is interpreted as `(1 + 2) + 3`\
There any many different binary operations, which can be split into three categories (listed in the order of precedence, highest precedence first):
- Relational operation
- Higher precedence operation
- Lower precedence operation

All the operations inside a specific category has the the precedence, meaning that the left-associative property disambiguates the order of operations.

#### Relational operation
Relational operations include both equality operations and comparison operations.\
The value of relation operation is a boolean value, i.e., either `true` or `false`\
Equality operators are `==` and `!=` which take two operands that are expressions on each side of the operator, e.g. `a == b`\
`==` is used to check if the values of the two operands are equal, while `!=` is used to check if they are inequal.\
It is an **error** if the data types of the two operands are different\
Comparison operators are `<`, `>`, `<=`, and `>=` which take two operands that are expression on each side of the operator, e.g. `1 < 2`\
`<` is used to see if the left operand is less than the right operand.\
`>` is used to see if the left operand is greater than the right operand.\
`<=` is used to see if the left operand is lower than or equal to the right operand.\
`>=` is used to see if the left operand is greater than or equal to the right operand.\
It is an **error** if any of the operands in a comparison operation is not an integer.\
Chaining comparison operations is allowed, e.g. `x <= 10 > y ` which is shorthand for `x <= 10 && 10 > y`

#### Higher precedence operation
A higher precedence operation includes an arithmetic or logical operator that has higher precedence than other arithmetic or logical operators.\
The operators are `*`, `/`, and `&&` which take two operands that are expressions on each side of the operator, e.g. `2 * 2`\
`*` represents multiplication, while `/` represents integer division (fractional values will get rounded down to the nearest integer).\
It is an **error** if any of the operands in a multiplication or division operation is not an integer.\
Note that a division operation may result in a run-time error if the right operand experession is evaluated to 0.\
`&&` is used to represent logical "and".\
It is an **error** if any of the operands in a logical "and" operation is not a boolean.

#### Lower precedence operation
A lower precedence operation includes an arithmetic or logical operator that has lower precedence than other arithmetic or logical operators.\
The operators are `+`, `-`, and `||` which take two operands that are expressions on each side of the operator, e.g. `1 + 2`\
`+` represents both addition and array concatenation, while `-` only represents subtraction.\
It is an **error** if any of the operands of a subtraction or addition operation is not an integer.\
It is an **error** if any of the operands is not an array in a concatenation operation.\
It is an **error** if the operands in an array concatenation is not of the same array type.\
`||` is used to represent logical "or".\
It is an **error** if any of the operands in a logical "or" operation is not a boolean.

### Examples

| Expression  | Interpretation | Value       |
| :---------- | :----------    | :---------- |
| `1 - 2 - 3` | `(1 - 2) - 3`| `-4`     |
| `1 < 2 < 3` | `1 < 2 && 2 < 3`| `true` |
| `-1 - 2` | `(-1) - 2` | `-3` |
| `10 / 3` | `10 / 3` | `3` |
| `[1,2] + [2,3]` | `[1,2] + [2,3]` | `[1,2,2,3]` |
| `!true == 1 + -3 * 4 / 2 > 5 && 1 != 2` | `(!true) == ((1 + (((-3) *4)/2) > 5) && (1 != 2))` | `true` | 


## Function call
An expression function call works exactly the same as a statement function call.\
See above for more information.\
The reason a function call is both an expression and a statement is to be able to store the return value to a variable,\
and also be able to do function calls while ignoring the return value.

## Inline if-expression
An inline if-expressions is similar to an if-statement, but the branches only consist of a single expression instead of a sequence of statements.\
The syntax is `condition ? expression1 : expression2`, where "condition", "expression1" and "expression2" are any arbitrary expressions.\
It is an **error** if the data type of the condition expression is not a boolean.\
If the condition expression is evaluated to `true` then the if-expression will be evaluated to the value of "expression1".\
If the condition expression is evaluated to `false` then the if-expression will be evaluated to the value of "expression2".\
It is an **error** if the data type of "expression1" is not the same as the data type of "expression2".\
Note that nesting if-expressions should use paranthesis to disambiguate the expression.

## Expression in paranthesis
Any expression can be wrapped in paranthesis, i.e., `(expression)` where "expression" is an arbitrary expression.

## Array literal
An array literal consists of zero or more elements wrapped in brackets, i.e., `[elements]` where "elements" is an arbitrary amount of expressions.\
Multiple elements are separated with a comma, and there is no limit on the amount of elements in an array.\
It is an **error** if all the elements in an array  does not have the same data type.\
Note that an empty array literal is allowed, and is denoted by `[]`

## Array element retrieval
An element of an array can be retrieved by specifying the name of the array and the index of the element, which returns the expression at that index.\
The syntax is `arrayname[index]` where "arrayname" is a name of an array variable in scope, and "index" is an arbitrary expression.\
It is an **error** if the "arrayname" is not a variable in the scope, or if the data type of the variable is not an array type.\
It is an **error** if the "index" expression is not an integer type.\
Note that this expression may result in a run-time error that is not caught by the typechecker if the index is a negative value or higher then the size of the array. 
 
# What does my project do?
It can do a semantic analysis of a parse tree.\
It can also do an evaluation of a parse tree.\
I'm **not** doing: 
- Any parsing myself, that is done through Rascal, i.e. recognizing an input text (string or file) according to the grammar and checking that if conforms to the syntax while also building a parse tree.
- Any memory management, e.g. how should values and names be stored? how much memory does an integer take?
- Compiling a parse tree into machine instructions
- Any optimization before evaluation
- Type inference
- Run-time error handling

In short: im not checking if a particular text is structured correctly (correct syntax), im checking that it makes sense in a sementical way.

My semantic analysis consists of:
- Abstraction of expressions to data types. 
- Typechecking, i.e., detecting type erros. For example, checking that a function returns the correct type.
- Name binding, i.e., binding variables and function names to a particular data type.
- Overload resolution on operators. Some operators can be used for different purposes, e.g. `+` can be used for addition and concatenation.
- Showing errors. The location of the error along with an appropriate exception and error message is given when something goes wrong.
- Checking specific constraints, e.g. making sure a program contains a main method, not having unreachable code etc.

My interpreting consists of:
- Evaluating expressions to values
- Interpreting statements
- Assigning, updating and removing variables
- "Running" the program, starting the execution from the main method

# How do I do it?
To get a parse tree from a text input i use Rascal's parse function from their ParseTree module.\
A parse tree is a concrete syntax tree, which is an ordered, rooted tree that represents the syntactic structure of a string according to some grammar.\
In Rascal parse trees, the interior nodes are labeled by rules of the grammar (i.e. nonterminals or `syntax`), and leaf nodes are labeled by terminals (i.e. characters or `lexical`) of the grammar.\
More generally a parse tree in Rascal is a Tree data type. A Tree is:
- subtype of Node (Node is a pair: a string that represents the node name, and a list type values as the children of the node).
- All `syntax` or non-terminals are sub-types of Tree
- Most internal nodes are applications (appl) of a Production to a list of children Tree nodes. 
Production is the abstract representation of a SyntaxDefinition rule,
 which consists of a definition of an specific alternative for a Symbol by a list of Symbols.
 For example the tree of "1 + 2" will have a Production with Symbol definition of sort("Expression") and a list of 5 symbols (1,+,2 are symbols, and there are two layouts or whitespaces)
- The leaves of a parse tree are always characters (char), which have an integer index in the UTF8 table.
- Some internal nodes encode ambiguity (amb) by pointing to a set of alternative Tree nodes.
  
A node in the tree can easily be pattern matched with concrete syntax.\
This is done by using a *typed quoted pattern* where the *type* is the Symbol definition of a node, e.g., Expression.\
The *quoted pattern* ignores layout (whitespaces) and often consists of *typed variable patterns* and tokens.\ 
A *typed variable pattern* is on the form <Type Var> where *Type* is a Symbol definition, e.g., Expression, and *Var* is an arbitrary variable name that we will be bound to the value of the type.\
Tokens are usually terminals or `lexical`\
An example of a pattern match would be "1 + 2" resulting in the (simplified) tree node: (Production: Expression, Children[Production: Expression, Production: +, Production: Expression])\
This can be pattern matched with (Expression) \`<Expression e1>+<Expression e2>\`\
Here the type in the quoted pattern is Expression, <Expression e1> and <Expression e2> are typed variable patterns, and + is a token.

To traverse the parse tree i pattern match recursively until i end up with a terminal.\
When i succesfully pattern match a concrete pattern i check for type errors.\
The order of a typechecking the parse tree is generally this:
- Program (start symbol)
- Variable declarations and initilization
- Function declarations
- Function bodies
- Statements
- Expressions
- Terminals (variables, integers, booleans)

## Typechecker
An algebraic data type called Type is used as an abstract representation for expressions.\
The definition of Type is `data Type = Integer()| Boolean()| Array(Type t)| Void()| Function(Type returnType, list[Type] parameterTypes) | Error(loc location, Exception exception)`\
Typechecking an expression returns a Type, e.g., an expression that is just a `lexical` INTEGER terminal is evaluated to a type of Integer.\
The Error type is a metatype that is returned when an expression has type error.\
For example, the expression `1 * a` will return the type Error if the variable `a` is not an Integer type.\
The Error type contains the location of the error in the input text and and an exception with a message explaining why it is an error.\
The above example gives an IllegalArgumentException specifying that a Boolean type can not be an argument to the `*` operator.

An environment is used to keep track of declared variables and functions and their associated types.\
They use the same namespace so that means functions and variables in the same scope can't have the same names.\
The environment is a map with string as keys (names of variables and functions) and Type as values.\
The environment is used to check if a name is already taken or if a variable or function is declared and initialized before use.\
The type name of the variable determines its Type, e.g. `int` corresponds to Integer and `bool` corresponds to Boolean.
There is only one environment, which gets updated and modified as the typechecker works through the program.\
Global variables and functions are always in the environment.\
All function declarations (name, return type, parameters) get typechecked before any body of a function gets typechecked.\
Parameters of functions and local variables in bodies of functions, if-statements and while-loops get added to the environment only when the typechecker enters the scope of those bodies.\
The variables will be removed again from the environment when exiting from the bodies.\
This makes it possible to use the same name for variables that are in different scopes, e.g., in two different functions.

## Interpreter
The interpreter works almost exactly the same as the typechecker.\
It does recursive pattern matching on nodes in a parse tree.\
The first thing it does is run the typechecker on the parse tree, which will either return true (no errors) or false (type erros exist).\
It will only start interpreting the parse tree if there is no type errors, and then it can do a lot of assumptions based on the fact that it passed the typechecker.\
For example it can assume that `a` and `b` in `a * b` are of type Integer, because if they weren't then the typechecker would fail.\
The algebraic data type is extended to allow values in the construcor, e.g., `Integer(int n)` which uses the underlying datatype `int` from Rascal.\
Expression are still abstracted to a Type, only that its value is also stored.\
For example, instead of `1 + 2` being abstracted to the type Integer (as the the typechecker does), it now is abstracted to Integer(3).\


The environment is also similar, only that the values is now types with values.\
Two additional maps are used: one to store the parameter names for a function, and another for storing all statements in a function body.\

The program is executed as follows:
- Create empty environment
- Add global variables to the environment
- Add functions to the environment, and also mapping each function to a list of parameter names and statements (without intepreting them!) 
- Call the main function
- Interpret each statement in the main function one by one

Function calls are a little complicated. They can produce side-effects (e.g. update global variables) so I can't just have a stack of environments that i can push and pop when entering in and out of scopes.\
Instead i only have a single environment that gets updates and modified with execution of the program.\
Function calls are pass-by-value, which means argument variables will not be updated if the corresponding parameter gets updated (i.e. the value of the argument variable is copied to the parameter).\
The steps when interpreting a function call are as follows:
- Copy and store the current local environment before the function call (i.e. this environment copy doesn't include the global variables and functions)
- Change the environment to just include the global variables and functions
- Add the parameters to the environment, assigning them to the values of the argument expresions
- Interpret each statement in the function body
- Each statement is checked to see if it is a return statement. A return statement will stop any further interpreting of statements, and will exit the function
- When exiting a function, the interpret function returns the value of the expression in the return statement (if there was one) or it will return `Void()`
- Exiting a function will also update the environment to remove local variables and parameters. This is done by
	- updating the environment by removing all new local variables and parameters that was added to the environment in the function call
	- taking the copy of the local environment created at the beginning of the function call and adding the key-value pairs back to the envionment
- Entering an if-statement or while-loop creates a new scope. Exiting this scope will remove any local variables added to the environment inside them. 



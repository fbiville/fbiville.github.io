---
layout: post
title: "Java fundamentals: booleans, expressions, bitwise operations++"
---
Although there are bitwise operators \| and &, this should not be mixed
with the logical ones (same goes with + for concatenation and + for
arithmetic addition). Indeed, contrary to other programming languages,
boolean values are comprised within 1 and only type. 0 is an integer,
not a boolean.

Even though you can use the analogy (1 boolean = 1 bit) to deduce the
result `if(condition = false | myInt++ == 0)`, we cannot know for sure
that a boolean is stored in 1 bit. That's up to the JVM implementation.
So again, the analogy boolean/bit can be useful to compute some complex
expressions, but keep in mind that's not totally correct. In some books,
they call \|\| and && \"short-circuit operators\". As you can point it
out:

-   `boolean a = false && expression1;`

-   `boolean b = true || expression2;`

a will always be false and expression1 will never be evaluated. b will
always be true and expression won't be evaluated neither. The result of
the assignments are the same with both \| and & (possible side effects
kept apart), but both operands are evaluated in this case.

Assignments vs. expressions
===========================

If I take again the same piece of code: if(condition = false \| myInt++
== 0), a lot of things happen in there. But before detailing what
happens, let's write some definitions down.

Expressions
-----------

Basically, an expression is made of 1 or 2 operands and one operator.
Operands can be simple, i.e. literals (in case of booleans, the only
literals are true and false) or expressions themselves. You can see a
kind of recursion there already.

Assignments
-----------

Assignments are a specialized subset of expressions where:

-   the operator must be =

-   the left operand MUST be type-compatible with the right one (i.e.
    compatible with what results from the expression, e.g. you cannot
    assign a String instance to an int, neither a variable to a
    literal).

The right operand however can be an expression. Recursion again. So
assignments like that:

`int i = 0, j = 0, k = 0, l = 0; //init`

`k = (l = (i = j++));`

are totally legal (but obviously not recommended as it is awfully
unreadable). The compiler checks the leftmost expression and sees:

1.  variable of type int called k, containing the value 0 is assigned to
    the result of expression\` (l = (i = j++))`

2.  variable of type int called l, containing the value 0 is assigned to
    the result of expression `(i = j++)`

3.  variable of type int called i, containing the value 0 is assigned to
    the result of expression `j++`

4.  as it is a post-increment operation, the compiler will first
    evaluate j which contains 0

5.  i receives the previous expression result which is 0

6.  l receives the evaluation of the expression result, that is the
    value contained in i, which is 0

7.  k receives the evaluation of the expression result, that is the
    value contained in l, which is 0

8.  now, the compiler executes j = j+1, which basically increments the
    value contained in the variable j

At the end, i,k,l contain 0, j contains 1.

Quick note about pre/post-in/decrementation operations
------------------------------------------------------

As you know, and \-- are language constructs (sometimes syntactic
sugar). It means, that is just a more convenient (convenient meaning
here more compact) way to write an expression. Obviously, you cannot do
3 or 1\--, this would be 3 = 3+1 which is syntactically incorrect as the
left operand of an assigment MUST be variable, not a literal.

Here is another example maybe a bit less obvious but still not legal:

`int i = 0;`

`((i++)+ +);`

This makes no sense as assignments have variables as left operands.`
i\` is legal. But then, the expression\` i\` is evaluated to 1, and 1 is
a literal value not a variable. Therefore, it is exactly like trying to
compute `1++`.

It's about Java, you know?
--------------------------

Everything I told is Java-specific. Some languages do not make the
distinctions between literal values and objects. In Ruby or in Scala,
everything is an object.

1 is an instance of Integer (or whatever it's called). Therefore, the
expression evaluation is a tad different. However, I do not know enough
about these two languages enough to talk about it (Scala is on
TODO-List, but a thorough study of pure Javascript comes first).

Bitwise operations and their object counterpart
===============================================

*When should it be used?*

Such operations could be used to carry several information within the
same data segment. Let's say we wanna transport several information
about a Person. An int is 32 bits, so we could use 1 bit for the gender,
7/8 bits for the age etc etc...​

However, this is clearly not type-safe, the various pieces of
information contained are clearly not of the same nature but they all
are assimilated to an integer value here! Fortunately, the Java Standard
Edition API includes an object-oriented approach through the facilities
provided by classes such as
[EnumSet](http://download.oracle.com/javase/1,5.0/docs/api/java/util/EnumSet.html),
[EnumMap](http://download.oracle.com/javase/1,5.0/docs/api/java/util/EnumMap.html)
etc...​ Type safety gua-ran-teed ;-)
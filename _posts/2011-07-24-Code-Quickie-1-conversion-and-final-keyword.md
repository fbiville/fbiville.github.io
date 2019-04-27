---
layout: post
title: "Code Quickie #1: Conversion And Final Keyword"
---
-   a class or method declared final cannot be overridden (this is not a
    problem, as you favor [composition over
    inheritance](http://en.wikipedia.org/wiki/Composition_over_inheritance),
    right?) ;

-   a variable declared final can be assigned only once ;

-   method-local classes can access only the final variables declared
    before the class in the very method

-   ...​ check [the Java Language Specification, 3rd
    edition](http://java.sun.com/docs/books/jls/third_edition/html/j3TOC.html),
    for the reference information.

Let us see some basic CODE:

    short result;
    int value = 10;
    result = 3*value-7;

Suppose this forms the body of a method, will this compile ?

The answer is...​.. **NO**!
The compiler is nice enough to tell you that such operations, a.k.a.
narrowing primitive conversions, may result in a loss of precision. As a
matter of fact, you cannot fit the 32 bits of `int` into the 16 of
`short`.

You still have the option to force the conversion:

    short result;
    int value = 10;
    result = (short) (3*value-7);
    /**
     * without the parentheses around, only the literal 3 would be converted to short
     * however, value is of type integer and 3 would be immediately promoted back to integer, nullifying the explicit conversion
     */

... in which case only the *n* lowest bits (*n* being the target type size i.e. 16 for `short`) of the expression result are kept.

So yes, you can force the conversion as a workaround. Here is a slight
variation of our first non-compiling piece of code:

    short result;
    final int value = 10;
    result = 3*value-7;

Will this compile ?

This time, the answer is **YES**!

I guess you are wondering about what is so different between this and
the original version ?
The fact that a final variable cannot be assigned more than once has an
interesting consequence: the variable is a constant, its contents are
known at compile time.
Therefore, the compiler knows exactly that you are trying to assign to *result* the result of 3\*10-7. It can replace *value* by the literal.

This process is called [compiler
inlining](http://en.wikipedia.org/wiki/Inline_expansion).

As a final exercise (no answer provided this time), will the following
block compile?

    short result;
    final int value = 10925;
    result = 3*value-7;

Have fun!
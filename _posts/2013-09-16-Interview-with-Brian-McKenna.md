---
layout: post
title: "Interview with Brian McKenna"
---
There you are: the interview is about Brian's views on FP, OOP, Computer Science...​

![image](https://pbs.twimg.com/profile_images/1313081307/WithMonkey2.jpg)

Enjoy the reading!

**First things first, who are you, Brian? What are you doing? Moreover,
is the parrot yours? :-)**

I'm Brian McKenna, possibly better known as
[@puffnfresh](https://twitter.com/puffnfresh). I was previously working
at a company called [Precog](http://precog.com/), where we wrote purely
functional Scala to make a service for analytics over big data. We were
recently acquired by [RichRelevance](http://www.richrelevance.com/), so
now I'm writing Java for product recommendations.

The parrot is my pet Indian Ringneck!

**Functional programming has attracted more and more attention over the
last few years. What is functional programming?**

Hell yeah! Functional programming has always been about programming with
functions. People have gotten confused about the \"programming with
functions\" part since languages have started calling things functions
which actually aren't functions. Others have also tried to hijack the
term to encompass more than it was originally intended.

A function (according to mathematics) is something that takes an value
and produces a value. That's it. If it does anything else other than
produce a value, then it's not a function (i.e. it has side- effects).

**You have been growing quite a deep interest in this paradigm. Where
does this originate from? When did it start?**

I started programming with JavaScript, PHP and Python. When I entered a
\"University for the Real World\" I had to do C, C++, C\# and Java but
that was of course just more of the same old. I really wanted to learn
something completely different so I decided to do it myself. 

Hacker News kept going on about how crazy Haskell was, so I decided to
seriously learn it. Everything about Haskell just made more sense to me.
Purity made me write better programs and so did having a great type
system.

I later got really interested in concurrency because of Haskell and
functional programming, which helped me out with classes in University!

**You also seem to enjoy some time exploring new programming languages.
Which one(s) would you recommend amongst your latest discoveries and
why?**

I'm really excited about
[Ermine](http://ermine-language.github.io/ermine/), a Haskell-like
language with row-polymorphism for the JVM. It was created by Edward
Kmett, Runar Bjarnason, Josh Cough and other smart people at Capital IQ
for generating reports by non-programmers.

I'm also excited about [BODOL](https://github.com/bodil/BODOL), a
functional, typed and curried Lisp. Created by [Bodil
Stokke](https://twitter.com/bodil) because it'd be awesome. 

**I read several tweets of yours similar to this one: \"*'You can
write bad code in any language\' is not a valid defense for Java and
node.js - they don't give you much of a chance to do otherwise.*\" **

**What bad parts do you attribute to Java as a language, to Java as
\"represented\" by popular frameworks, Java as its Virtual Machine and
finally Java as its community? And also, what are the GOOD parts of Java
in your opinion?**

Java as a language and its users:

-   Code reuse is awful - e.g. Java has no way to abstract over type
    constructors

-   When people hit limits in subtyping, they do awful things like
    casting

-   People often don't know how to write [sum
    types](https://www.fpcomplete.com/school/pick-of-the-week/sum-types)
    (imagine arithmetic with just multiplication and no addition)

-   Reflection being possible and sadly, somewhat common

I've worked in a few companies which write almost solely Java and I see
the above all the time.

JVM: pretty good. 

Problems: 

-   no tail calls, 

-   primitives vs references,

-   65535 byte method limit

Good parts of Java:

-   Has types

-   Better at functional programming than JavaScript

**Do you see any future for functional programming languages on the JVM?
Will we be alive to see Haskell fully ported there for instance?**

Ermine is doing great things for functional programming on the JVM. It
actually makes some small improvements on Haskell but it doesn't have
some of the more basic things, like type-classes.

Frege is a fairly direct port of Haskell. It fixes a few mistakes, for
example it has a better generalised standard library (e.g. it doesn't
make the Monad/Applicative mistake and also has Bind/Apply
type-classes).

One downside of Frege is that the compiler requires Java 7.  Another
downside is that it compiles by generating a huge Java source file and
forking to javac. I can get over those minor annoyances.

**What is your take on Javascript? Is it only worth as a transpiler
target (e.g.: Roy does this)? Can it be called a functional programming
language?**

I don't like the label \"functional language\" - almost all languages
allow functional programming (i.e. using functions as actual
mathematical functions) so when is a language allowed to have that
label?

Functional programming in JavaScript is incredibly hard. I definitely
think that compiling to JavaScript is the best thing to do. 

**Not a new question, but still somewhat confusing: do Computer Science
and Software Engineering differ?**

I haven't really thought about this before.

Software engineering is an interesting one. Writing software doesn't
seem like engineering at all. How is the current state of designing
software disciplined or quantifiable? I've heard some people say
\"software needs maintenance, therefore it's like engineering\" but I
don't buy it.

Like Dijkstra, I reject the idea of \"software maintenance\" - software
doesn't decay or deteriorate from use. What would we be trying to
preserve? When people say \"maintenance\" they sometimes mean \"make
software actually do what it was intended to do\" and sometimes \"make
software do more things\" - not exactly maintenance, right?

I don't think writing software is or should strive to be engineering. I
guess I'd like it to be purely an application of computer science. Maybe
I'm a dreamer, but I'm not the only one!

**For the last question, let's go back in time and imagine you are given
the opportunity to discuss with E. W. Dijkstra. What would you talk
about?**

Dijkstra seemingly did not agree with getting computers to help with
proofs. I found that very strange. While I can't make my computer figure
out what I want to prove, it definitely helps me out once I tell it
(i.e. by writing down a type) - Dijkstra said he wasn't comfortable with
type theory so maybe that was the only problem. I'd like to find out.
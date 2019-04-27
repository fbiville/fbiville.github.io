---
layout: post
title: "Compilers Hate Him! Discover This One Weird Trick with Neo4j Stored Procedures"
---
As you probably already know, Neo4j 3.0 finally comes with [stored
procedures](https://neo4j.com/docs/java-reference/current/#_calling_procedure)
(let's call them sprocs from now on).

The cool thing about this is you can directly interact with sprocs in
Cypher, as [Michael Hunger](https://twitter.com/mesirii) explains in
this [blog
post](https://neo4j.com/blog/intro-user-defined-procedures-apoc/).

Writing stored procedures
=========================

During the preparation of my Neo4j introduction talk in the latest
[Criteo
summit](https://www.facebook.com/GoCriteo/photos/pcb.1045385882181102/1045385698847787/?type=3)
(we're [hiring](http://www.criteo.com/careers/#careers-browser)!), I
started playing around with sprocs.

The process is quite simple:

1.  You write some code, annotate it

2.  test it with the test harness

3.  package the JAR and deploy it to your Neo4j instance (`plugins/`)!

Actually, step 3 may repeat itself quite a few times, Neo4j sprocs must
comply to a few rules before your Neo4j server accepts to deploy it.

Sproc rules
===========

The rules are detailed in `@org.neo4j.procedure.Procedure`
[javadoc](https://github.com/neo4j/neo4j/blob/3.0/community/kernel/src/main/java/org/neo4j/procedure/Procedure.java#L31),
but we can summarize them as follows:

-   a sproc is a method annotated with `@org.neo4j.procedure.Procedure`

-   it must return a
    [`java.util.stream.Stream<T>`](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html)
    where T is a user-defined record type

-   the record type must define public fields

-   these can only be of restricted types

-   if the sproc accepts parameters, they all must be annotated with
    [`@org.neo4j.procedure.Name`](https://github.com/neo4j/neo4j/blob/3.0/community/kernel/src/main/java/org/neo4j/procedure/Name.java)

-   parameters can only be of specific types

-   the procedure name must be unique (name = package name+method name)

-   injectable types (`GraphDatabaseService` et al) must target public
    non-static, non-final,
    [`@Context`-annotated](https://github.com/neo4j/neo4j/blob/3.0/community/kernel/src/main/java/org/neo4j/procedure/Context.java)
    fields

Fortunately, folks at [Neo Technology](https://neo4j.com/company/) have
done a wonderful job at error reporting. Neo4j fails fast if any of the
rules is violated and gives a detailed error message.

Here is an example with Neo4j 3.0.3 and the following **failing**
attempt to deploy the following sproc:

``` {.java}
@Procedure
public Stream<MyRecord> doSomething(Map<String, Integer> value) {
    // [...]
}
```

The following error will be prompted (see `logs/neo4j.log`):

    Caused by: org.neo4j.kernel.api.exceptions.ProcedureException: Argument at position 0 in method `doSomething` is missing an `@Name` annotation.
    Please add the annotation, recompile the class and try again.

Nice error message! Just add the missing `@Name` on the only parameter,
re-compile, package and deploy the JAR again, restart Neo4j and you're
done!

Can we do better?
=================

The previous example is quite trivial, but this back-and-forth could be
potentially repeated many times, especially when one is not much
familiar with sprocs.

Fortunately for us, most of the errors can be caught at compile time.

@Eureka(\"annotation processing FTW!")
========================================

Annotations have been around in Java since end of 2004 (v1.5) and have
come together with `apt` (now built in `javac`), the annotation
processing tool.

What the latter does in brief (in long, read the
[spec](https://www.jcp.org/en/jsr/detail?id=269)) is to allow
user-defined code to introspect a Java program at compile-time (original
paper [here](http://www.bracha.org/mirrors.pdf)) and possibly:

-   issue compilation notices/warnings/errors

-   generate static, source and/or bytecode files

(By the way, this means exceptions can be raised at compile-time too!)

Based on this, I decided to write a little annotation processor on my
way back from Criteo summit (did I mention we are
[hiring](http://www.criteo.com/careers/#careers-browser)?).

[neo4j-sproc-compiler](https://github.com/fbiville/neo4j-sproc-compiler)
is born. And it's
[used](https://github.com/neo4j-contrib/neo4j-apoc-procedures/blob/18fe85a3712aa84696cc4dedaf0db659a63e3e7b/pom.xml#L72)!

If Michael is happy, I am happy:

![michael sproc compiler
feedback](https://raw.githubusercontent.com/fbiville/fbiville.github.io/master/images/michael-sproc-compiler-feedback.png)

(I swear it's not photoshopped, see \#apoc channel, 1st of July 2016 in
Neo4j-Users [Slack](https://neo4j-users.slack.com)).

neo4j-sproc-compiler in action
==============================

While the following screencast features Maven, the annotation processor
is actually agnostic of any build tool. You can use any build tool you
want or directly `javac` if that floats your boat!

[![asciicast](https://asciinema.org/a/79379.svg)](https://asciinema.org/a/79379)

Conclusion
==========

Be cautious, most but **not** all checks can be performed at compile
time. You'll still need to write some tests and monitor your deploys!

Hopefully, this little utility that I wrote will shorten your
development feedback loop and get your stored procedures harder, better,
stronger and faster.
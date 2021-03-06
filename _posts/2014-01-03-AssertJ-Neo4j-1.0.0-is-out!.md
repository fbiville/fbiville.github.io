---
layout: post
title: "AssertJ-Neo4j 1.0.0 is out!"
---

Assertwhat?
===========

AssertJ-Neo4j is an AssertJ module. AssertJ aims at making tests more
concise and readable, by providing a set of rich and broad assertions.
They are, at the time of writing, broken down into three modules: 

 - [AssertJ-core](https://github.com/joel-costigliola/assertj-core):
 assertions focused on JDK structures \*
[AssertJ-Guava](https://github.com/joel-costigliola/assertj-guava):
assertions for some structures bundled with
[Guava](https://code.google.com/p/guava-libraries/) 
 - [AssertJ-Joda-Time](https://github.com/joel-costigliola/assertj-joda-time):
assertions for the Java [date and time
API](http://www.joda.org/joda-time/) written by Stephen Colebourne

And affiliated with: 

 - [AssertJ-generator-plugin](https://github.com/joel-costigliola/assertj-assertions-generator):
generate your own custom assertions! (check [the Maven plugin](https://github.com/joel-costigliola/assertj-assertions-generator-maven-plugin)
out!)
 - [AssertJ-examples](https://github.com/joel-costigliola/assertj-examples):
a project aggregating all modules and plugins, showing concrete examples
of use

This may seem familiar to some of you, for a reason. AssertJ is actually
a fork of Fest-Assert, initiated almost a year ago by [Joël
Costigliola](https://twitter.com/JoCosti), long-time committer to
Fest-Assert. While it shares many similarities, AssertJ brings some
novelties as well. Be sure to check the repositories and various
examples on the Interwebz.


AssertJ-Neo4J!
==============

Neo4j embeds an [\"impermanent graph
database\"](http://docs.neo4j.org/chunked/stable/tutorials-java-unit-testing.html) which
definitely helps writing short and efficient integration tests. However,
there is still some boilerplate up to the people to write. That's
exactly
when [AssertJ-Neo4j](https://github.com/joel-costigliola/assertj-neo4j) comes
to the rescue. As you can see
from [AssertJ-examples](https://github.com/joel-costigliola/assertj-examples),
Assert-Neo4j will help you write concise and elegant assertions on
[Node](http://api.neo4j.org/current/org/neo4j/graphdb/Node.html),
[Relationship](http://api.neo4j.org/current/org/neo4j/graphdb/Relationship.html) (and
their common part:
[PropertyContainer](http://api.neo4j.org/current/org/neo4j/graphdb/PropertyContainer.html))
and [Path](http://api.neo4j.org/current/org/neo4j/graphdb/Path.html).
Feel free to check the examples
[here](https://github.com/joel-costigliola/assertj-examples/tree/master/src/test/java/org/assertj/examples/neo4j).


Grab it while it's hot!
=======================

![AssertJ_1.0.0](/assets/img/AssertJ.png)


While I already have some plans to provide better assertions on
collections of Node/Relationship, I am very eager to gather your
feedback on this. Feel free to send suggestions on
[Github](https://github.com/joel-costigliola/assertj-neo4j/issues) or
ping me on [Twitter](https://twitter.com/fbiville)!


HAPPY NEW YEAR! :-)
===================
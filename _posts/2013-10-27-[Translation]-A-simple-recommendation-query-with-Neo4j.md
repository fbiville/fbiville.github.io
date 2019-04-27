---
layout: post
---
Recommending colleagues
=======================

Previous article follow-up
--------------------------

The previous exercise, temporarily left to the curiosity of the reader,
consists in finding professional contact recommendations, as specified
by the following question:

*"find the contacts of my contacts, who know (are in contact with) with
someone I already have worked with (with whom I am NOT already in
contact)"*

A reminder of the graph :

-   users are labeled `CONTACT`

-   companies are labeled `COMPANY`

-   user nodes have a name property (including both first and last name
    for simplicity sake)

-   to be in contact with someone is modeled as such 

`(:CONTACT)-[:IN_CONTACT_WITH]-(:CONTACT)`

-   to work for a company is modeled as follows: 

`(:CONTACT)-[:WORKED_IN]->(:COMPANY)`

Now, let's start solving this problem by decomposing it into smaller
sub-tasks..

Finding former colleagues
-------------------------

A first simple query could be like:
```
MATCH (me:CONTACT)-[:WORKED_IN]->(:COMPANY)<-[:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name}
RETURN me, colleagues
```

Not bad, but I don't want to see suggested colleagues I'm already in
contact with.

To avoid this, let's verify we are not already connected:

```
MATCH (me:CONTACT)-[:WORKED_IN]->(:COMPANY)<-[:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
RETURN me, colleagues
```

Let's go even further: we want to include people that worked in a
company only when you worked there as well. In other words, will be
included colleagues who stopped working (or are still there) after you
started and who started before you left (if you left).

However, you'll notice the specs ain't complete. After a long and
tedious meeting, it has been decided that `WORKED_IN` will comprise 2 new
timestamp properties: beginning and end (end is optional, it means the
person is still working there). Isn't it convenient to have full-fledged
relationships? They can have attributes, too!

Going back to our query, two `WORKED_IN` relationships must be captured,
as they respectively represent your stay and your colleagues stay dates.
Let's also split the `MATCH` clause, given it's gonna slightly grow as you
can see:

```
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
RETURN me, colleagues
```

Let's now restrict the subgraph with the aforementioned overlap constraints:

```
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
AND myStay.beginning < theirStay.end
AND theirStay.beginning < myStay.end
RETURN me, colleagues
```

And let's make sure that people still working in their company are
properly handled (end property won't be set in that case).

```
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
AND (NOT HAS(theirStay.end) OR myStay.beginning < theirStay.end)
AND (NOT HAS(myStay.end) OR theirStay.beginning < myStay.end)
RETURN me, colleagues
```

Filtering further
-----------------

As you notice, the query has grown quite a bit, but we're still not
done. 2 strategies lay ahead:

1.  we can insert more and more patterns in `MATCH` and more filtering in `WHERE`

2.  we chain the previous query with another one

You got it, let's go with the 2nd option. What's more, this will be the
perfect excuse to introduce you to `WITH` clause, which acts as a UNIX
pipe.

Not much has to be done to allow query chaining. In our simple case,
let's just replace `RETURN` by WITH and write the last filtering step:

```
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
AND (NOT HAS(theirStay.end) OR myStay.beginning < theirStay.end)
AND (NOT HAS(myStay.end) OR theirStay.beginning < myStay.end)
WITH me, colleagues
WHERE (me-[:IN_CONTACT_WITH]-(:CONTACT)-[:IN_CONTACT_WITH]-colleagues)
RETURN me, colleagues
```

Quite cool, or?

Cherry on the cake: instead of returning n times 1-1 associations, it's
been decided that a single 1-n relationship should be returned, and the
aggregated set of colleagues should be sorted by name.

Tiny subtlety here: colleague order is absolutely not guaranteed by
default. We're gonna use the quite fitting `ORDER BY`, just after the
existing `WITH` clause, in order to make sure colleagues are properly
ordered (the subsequent filtering won't alter this invariant anyway).

    MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
    company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
    WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
    AND (NOT HAS(theirStay.end) OR myStay.beginning < theirStay.end)
    AND (NOT HAS(myStay.end) OR theirStay.beginning < myStay.end)
    WITH me, colleagues
    ORDER BY colleagues.name
    WHERE (me-[:IN_CONTACT_WITH]-(:CONTACT)-[:IN_CONTACT_WITH]-colleagues)
    RETURN me, colleagues

After sorting, let's aggregate!

    MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
    company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
    WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
    AND (NOT HAS(theirStay.end) OR myStay.beginning < theirStay.end)
    AND (NOT HAS(myStay.end) OR theirStay.beginning < myStay.end)
    WITH me, colleagues
    ORDER BY colleagues.name
    WHERE (me-[:IN_CONTACT_WITH]-(:CONTACT)-[:IN_CONTACT_WITH]-colleagues)
    RETURN me, COLLECT(colleagues)

And that's it!

Reasoning and writing the query like this comes with several benefits:

-   the query, split as such, is much more readable

-   it is also arguably more maintainable: 1 subquery = 1 responsibility

-   last but not least, the resulting nodes are self-sufficient: no
    extra context is needed to interprete the result (both the original
    contact and its suggestions are returned)

Le grand final
--------------

1.5 years ago or so, Cypher was so tiny. It is like seeing a newborn
growing: more and more capable and still amazing. It just started as
time-off idea and is now almost Turing-complete :-) I cannot help but be
enthusiastic about Cypher: easy on the eyes, low barrier for newcomers
and still incredibly powerful!

Be ready for it, Cypher is soon gonna be the \#1 way to query data on
Neo4j. This is quite logical : we all expect a database to include a
query language.

What's still missing, maybe, is a communication protocol with remote
Neo4j instances with less overhead than the standard REST API, as
suggested [Sébastien Deleuze](https://twitter.com/sdeleuze) while we
were discussing at [Soft-Shake](http://soft-shake.ch/).

Post-Scriptum : a test dataset
------------------------------

Open <http://console.neo4j.org> and try out the final query and its
intermediary steps (do not forget to replace {name} by 'Florent').

---
layout: post
title: "Rant: The Teletubbies \"Documentation\" Pitfall"
---
Disclaimer
==========

I am not Uncle Bob's nephew, but if you already have read Clean Code,
chances are you will not learn much from this post.

Typical example
===============

Let me talk about a coding practice that I find profoundly disturbing.
Get this code for instance:

``` {.java}
public SomeResult computeResult(SomeParameter parameter) {
    // call nice service to fetch foo
    Foo foo = niceService.fetchFoo(parameter);
    return new SomeResult(foo);
}
```

Basically, we have got some trivial calls to a service and use it for
instanciating the result we are interested in.

Do we need the comment, though? Obviously, we don't!

We are just adding noise!

That's why I call it a Teletubbies documentation.

Teletu-what?
============

Teletubbies, as you probably already know, is a TV show for very young
children, created by the BBC.

If you know the show, you know also that whenever a Teletubbies
character does something, the following happens:

1.  the character announces what it intends to do

2.  the voice-over paraphrases what the character just said

3.  the character does it

4.  optionally back to step 1

This makes sense for very young children, part of education is based on
repetition.

Back to our example
===================

So whenever I encounter a snippet of code like above, I immediately hear
this annoying voice-over that just repeats something we already know.

It is annoying because, well, we are not very young children.

What's the big deal, you might object?

Well, comments like these can **easily** get out of sync. In the
worst-case scenario, they become misleading.

It leads to situations where you have to confront the current code and
the outdated comment and you cannot really be sure which one describes
what the behavior **should** be.

Comments don't run, they are just an informal bunch of text and cannot
be changed automatically (at least, not in a 100% reliable way). Their
risk of becoming obsolete is therefore higher.

To rephrase it, comments like this are part of the problem, not the
solution.

Inline comments are just a liability.

The worst part is that they often appear as a whole bunch:

``` {.java}
public SomeResult computeResult(SomeParameter parameter) {
    // call nice service to fetch foo
    Foo foo = niceService.fetchFoo(parameter);

    // [...] 200 lines with comments+code like that
    // hilarity ensues... not
    return new SomeResult(foo, ...);
}
```

Indeed, the bad side effect of this kind of brain-dead comments is that
it **prevents** the original authors to ask themselves: is the code
readable enough this way? Am I thinking this through? How can I make the
code more self-explanatory?

If you get used to this kind of comments, you will most likely focus
your reading on them and live in the illusion that the method is
readable and well-documented.

I have got some bad news for you: 200 lines of code for a method are NOT
readable at all, no matter how much obsolete poetry you stick in there.

As a general rule of thumb, is it worth writing something down if that
only took you 10 seconds to come up with?

A not-so-noisy example
======================

Let's move on to a more interesting example.

It's not that the first example does not happen frequently, but there
are some situations like the following that involves a bit more than
pure noise.

``` {.java}
public SomeResult computeResult(SomeParameter parameter) {
    /*
     * call nice service to fetch foo because
     * some contextual reasons
     *
     * fetchFoo may throw in theory but will not
     * because the parameter is always valid in
     * this particular usecase [...], so no try-catch,
     * YOLO
     */
    Foo foo = niceService.fetchFoo(parameter);
    return new SomeResult(foo);
}
```

\"Ah! This comment is useful! It explains the implementation
rationale!", you may say.

While there is some value in these pieces of information, they just do
not belong there.

Let me elaborate.

Small detour: back to basics
============================

As you already know, in many programming languages, method signatures
look like:

``` {.java}
public SomeResult computeResult(SomeParameter parameter)
```

Ideally, the signature should be explicit enough (especially with
well-defined types, parametricity FTW) to know what the method does. How
the method does it should be relevant only if you have to change
something there.

Everything that follows between curly braces is about **implementation**
details.

Back to the example again
=========================

However, I would argue that the two information encoded as a inline
comment above are NOT implementation details, yet they live in the
implementation section.

What are these comment sections about?

1.  the first part describe the intent behind the implementation (or at
    least part of it)

2.  the second and last part describe (part of) the observable behavior
    of the method

Intent documentation
====================

Intents are very contextual and temporal.

Decisions, no matter how small, are taken every day and guide the way we
implement things.

These decisions are influenced by temporal factors mostly: the
assumptions made at the time may not hold at all anymore in 6 months, 1
year...​

Temporal documentation.

**TEMPORAL** documentation.

It rings a bell, somehow.

S-C-M! Source Control Management tools like Git, Mercurial and friends.

They play an important part in documentation. Not only do they
intrinsically describe what has changed and when, they should describe
**why** the changes were made.

That's what **commit messages** are for!

And if you start thinking this way, there will be an additional benefit:
you will keep your commits as small and focused as possible. If the
commit is too big, there is no way you can explain all the important
changes you made ;-)

And if you start to care enough about your changelog, you will get nice
readable releases notes for free!

Observable behavior documentation
=================================

If what you describe is part of the observable behavior of the scope you
are modifying, then it is clearly about the contract you implicitly sign
between the code you are implementing and its callers.

The documentation is about the API. API is just a clever name for a set
of accessible signatures. It is not an implementation detail at all, it
should be near the method signature itself:

``` {.java}
/**
 * *describes the nominal observable behaviour here [...]*
 *
 * fetchFoo may throw in theory but will not
 * because the parameter is always valid in this
 * particular usecase [...], so no try-catch, YOLO
 */
public SomeResult computeResult(SomeParameter parameter) {
    Foo foo = niceService.fetchFoo(parameter);
    return new SomeResult(foo);
}
```

Going further
=============

You could even rewrite the method like this:

``` {.java}
/**
 * *describes the nominal observable behaviour here [...]*
 */
public SomeResult computeResult(SomeParameter parameter) {
    try {
        Foo foo = niceService.fetchFoo(parameter);
        return new SomeResult(foo);
    }
    catch (MyNiceServiceException e) {
        throw new AssertionError("Should not happen", e);
    }
}
```

Now the assumptions are even more explicit. That opens even an
interesting discussion about the virtues of [failing
fast](https://www.youtube.com/watch?v=57P86oZXjXs) :-)

One could argue we could do even better. Ideally, method signatures
should be sufficient to tell what the method is doing:
[parametricity](http://data.tmorris.net/talks/yow-west-2016/1d388b6263e7cbeedfbea224997648daa1d7862d/parametricity.pdf)
FTW! Hoogle.com is probably one of the best illustrations for this.

That requires discipline (especially with languages such as Java, C\# et
al), but is not impossible to achieve: try to minimize and contain side
effects, forego nulls...​ and then types could convery a lot more useful
information!

Yet another interesting discussion!

The end
=======

As you can see, caring about documentation is a gateway drug to better
software, clearer releases and happier collaborators.

I personally write comments less than 1% of the time I write code. This
happens where there is a tiny local expression that may seem obscure and
there is not simple way around it.

For the 99+%, there are almost always better places to write the
information you want to convey:

-   the code itself, it should answer **WHAT** it does, without
    ambiguity, else just refactor it (extract meaningful methods,
    rename, split expressions...​ the IDE is your friend). This is the
    material that decays the least, rely on this as much as you can!

-   the \*-doc (e.g. Javadoc, Csharpdoc): the information is about the
    observable behavior of the section you are altering

-   the intent: that should justify the commit you are about to push

Inline comments are (99+%) dead! Long live inline comments!
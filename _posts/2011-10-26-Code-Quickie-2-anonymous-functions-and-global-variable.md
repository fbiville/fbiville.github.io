---
layout: post
title: "Code Quickie #2: Anonymous Functions and Global Variables"
---
To avoid global variable name collision, there is a possibility to
enclose your Javascript snippet in an anonymous function, whose
invocation follows the declaration. For instance: 

```
(function () {
    var msg = 'test';
    alert(msg);
})()
```

This comes in two parts: the first one is an
expression `(function () { var msg = 'test'; alert(msg);})` that is
evaluated as a function. Therefore, you can directly invoke this
evaluated function by passing a parameter list (in the example: an empty
list), which gives you the above snippet.

A variant with a parameter, this time:

```
(function (msg) {
    alert(msg);
})('test');
```

Cool consequences
=================

The cool thing about this practice is that there are no more global
variables ('cause the declared variables are limited to the enclosing
function scope) and any possible collision is thus avoided. This is
especially useful when you have to handle multiple tracking tags within
the same page. Further reading:

-   detailed answers:
    <http://stackoverflow.com/questions/1140089/how-does-an-anonymous-function-in-javascript-work>

-   must-read for Javascript newbies like me:
    <http://www.eloquentjavascript.net>
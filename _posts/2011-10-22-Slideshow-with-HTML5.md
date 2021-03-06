---
layout: post
title: "Slideshow with HTML5"
---
When you hear slideshow, you probably think of Javascript, maybe via
[your favorite
framework](http://en.wikipedia.org/wiki/List_of_JavaScript_libraries) or
[not](http://eloquentjavascript.net/).

Well, those days are over. [HTML5](http://www.html5rocks.com/) is more
and more present, and yes, you should begin learning it. Today, we are
gonna focus on a very specific feature called *keyframes*.

Keyframes?!
===========

Keyframes let you define animation appearances in pure CSS. Those are
broken down into:

-   **steps** - expressed in percentage (e.g. 0%, 33%, 66%, 100%). Note
    that *from* and *to* can be respectively used in lieu of 0% and
    100%.

-   **effects** - each step defines a set of [CSS
    rules](http://www.css3.info/preview/).

``` {.css}
@keyframes AnimationName {
    0%,15%,100% {left: 0px;}
    35%,50% {left: -640px;}   
    70%,85% {left: -1280px;}
}
```

In the above example, nothing fancy: this animation does no more than
moving the attached block to the left and come back to its initial
position (provided this element is positioned relatively to one of its
parents).
By the way, be wary of keyframes browser support. Indeed, you might need
to prefix your keyframes rules by your target [browser vendor
prefix](http://reference.sitepoint.com/css/vendorspecific#vendorspecific__tbl_vendor-specific-extensions_vendor-extension-prefixes).


Animation settings
==================

Now that you have defined the animation appearance, it must be applied
to an element and the animation behavior must be set.

Here is an interesting subset of the [available animation
sub-properties](http://www.w3.org/TR/css3-animations/):

-   animation-name: as you guess, this corresponds to the name in the
    @keyframes declaration (here: AnimationName) ;

-   animation-duration: the number of seconds to complete one cycle
    (basically, from 0 to 100%) ;

-   animation-iteration-count: how many time the keyframe will be played
    ;

-   animation-timing-function: you can pick up amongst [a bunch of
    predefined
    functions](http://www.w3.org/TR/css3-animations/#animation-timing-function_tag)
    to describe the timing acceleration curve.

``` {.css}
#myElementId {    
    animation-name: AnimationName;   
    animation-duration: 20s;   
    animation-iteration-count: infinite;   
    animation-timing-function: ease-in-out;
}
```

In this example, the animation will loop forever, each cycle taking 20
seconds to complete following an ease-in-out curve.

A live example
==============

Cross-browser compatibility
---------------------------

Because HTML5 features are not uniformly supported by browsers, I
decided to download [HTML5 Boilerplate](http://html5boilerplate.com/) so
to benefit from consistent rendering amongst browsers and devices. I did
not explore all the functionalities it brings, but I can already say
this is a lightweight and loosely structuring solution that I am most
certainly gonna use for other experiments.

Keyframes also suffer from that inconsistent support, I wrote a small
and ad-hoc Javascript snippet pretty much inspired from one [Mozilla
Developer Network
article](https://developer.mozilla.org/en/CSS/CSS_animations/Detecting_CSS_animation_support).

``` {.javascript}
var hasKeyFrameSupport = false;
var vendorPrefixes = 'Webkit Moz O ms Khtml'.split(' ');
var slideContainer = document.getElementById('myElementId');
if (!slideContainer.style.animationName) {

    for (var i = 0; !hasKeyFrameSupport && i < vendorPrefixes.length; i++) {
        var animation = vendorPrefixes[i]+'AnimationName';
        hasKeyFrameSupport = (slideContainer.style[animation] !== undefined);
    }

    if (!hasKeyFrameSupport) {
        var upgrade = document.createElement('p');
        upgrade.setAttribute('id', 'upgrade');       
        upgrade.appendChild(document.createTextNode('For better CSS, upgrade your browser!'));
        slideContainer.appendChild(upgrade);   
    }
}
```

Once again, this is not rocket science. The following script first
checks the standard animationName property existence. Then, the script
iterates over several vendor-prefixed animation name property just to
check if one is supported.

If none of the previous tests succeed, a warning good-tasting message
notifies the user that his computer might be stuck in a spatiotemporal
distortion causing some deprecated pieces of software to live longer
than they should.

lorem ipsum 2.0
---------------

Not much to say except that you should check [Samuel L. Ipsum](http://slipsum.com/) out.

esporx labs?!
-------------

esporx is a cool project I am working on, on my free time. There is
gonna be for sure a full post about it. In short: the new ESPN for
esports events, hosted by Google App Engine, powered by Spring MVC and
JPA and awesomely rendered by truly awesome webdesigners (and this
obviously does not include myself) and HTML5 :)

tl;dr?
------

Check the full example
[here](https://github.com/fbiville/html5fun/tree/master/slideshow)!
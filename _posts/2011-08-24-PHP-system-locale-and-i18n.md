---
layout: post
title: "PHP, System Locale and I18n"
---
A large number of PHP functions base their behavior on the system
locale:
[number_format](http://php.net/manual/en/function.number-format.php),
[money_format](http://php.net/manual/en/function.money-format.php) ...​

If we take a closer look to the
[setlocale](http://php.net/manual/en/function.setlocale.php)
documentation, here is what is says about its first parameter
`$category`:

> *\`category\`* is a named constant specifying the category of the
> functions affected by the locale setting:
>
> -   **`LC_ALL`** for all of the below
>
> -   **`LC_COLLATE`** for string comparison, see
>     [strcoll()](http://www.php.net/manual/en/function.strcoll.php)
>
> -   **`LC_CTYPE`** for character classification and conversion, for
>     example
>     [strtoupper()](http://www.php.net/manual/en/function.strtoupper.php)
>
> -   **`LC_MONETARY`** for
>     [localeconv()](http://www.php.net/manual/en/function.localeconv.php)
>
> -   **`LC_NUMERIC`** for decimal separator (See also
>     [localeconv()](http://www.php.net/manual/en/function.localeconv.php))
>
> -   **`LC_TIME`** for date and time formatting with
>     [strftime()](http://www.php.net/manual/en/function.strftime.php)
>
> -   **`LC_MESSAGES`** for system responses (available if PHP was
>     compiled with *libintl*)
>

And just below this explanation, the only given examples in the doc make
use of `LC_ALL`.

PHP puzzle
==========

But let's take a concrete example:

``` {.php}
<?php

$table = 'Administrator_Roles';
setlocale(LC_ALL, 'tr_TR.UTF-8', 'tr');

$class = preg_replace('/[^A-Z0-9]/i','_',$table);
print $class.PHP_EOL;
?>
```

What is the output going to be ?

-   Tip \#1: <http://php.net/manual/en/book.pcre.php>

-   Tip \#2: <http://en.wikipedia.org/wiki/Dotted_and_dotless_I>

Find the culprit: PCRE!
=======================

...​or maybe developers like me, who did not spend enough time hunting
down the information in the PHP manual ;)

Rather than copying the whole contents referenced by the two above
links, let us summarize how `setlocale` could end up producing such
output.

PHP builds in PCRE module (Perl-Compatible Regular Expressions), whose
standard escape sequences *might* be locale-specific.

Unfortunately, the official PHP documentation is not so helpful (see
<http://us2.php.net/manual/en/regexp.reference.escape.php>):

> A \"word\" character is any letter or digit or the underscore
> character, that is, any character which can be part of a Perl
> \"*word*\". The definition of letters and digits is controlled by
> PCRE's character tables, and may vary if locale-specific matching is
> taking place. For example, in the \"fr\" (French) locale, some
> character codes greater than 128 are used for accented letters, and
> these are matched by *\w*.

Conclusion
==========

`LC_ALL`, really?
-----------------

Avoid `LC_ALL` whenever possible. Select the most restrictive
\"category\" you need.

`LC_TIME`, `LC_MONETARY` and `LC_NUMERIC` seem to be good candidates for
e-commerce websites for instance. By the way, you can apply several
categories by calling `setlocale` multiple times in a row (bitwise OR
should NOT work).

Unicode matching
----------------

If you really cannot change `LC_ALL` to a more specific category, be
extremely cautious with regular expressions, string comparisons etc.

Your application could grow enough to have to support new languages, and
this could break as in the example of this post.

Note that if your application handles Unicode representation (crazy idea
in 2011, I know), then you can use Unicode in your expressions:
<http://php.net/manual/en/regexp.reference.unicode.php>. However, the
documentation says:

> Matching characters by Unicode property is not fast, because PCRE has
> to search a structure that contains data for over fifteen thousand
> characters. That is why the traditional escape sequences such as *\d*
> and *\w* do not use Unicode properties in PCRE.

It might be worth ignoring this piece of advice until it is proven to be
a problem for your application. As they say, [premature optimization is
the root of all evil](http://c2.com/cgi/wiki?PrematureOptimization).

And that's all, folks!
---
layout: post
title: "Devoxx: Nouveaux Langages"
---
Les conférences suivies
=======================

Voici les conférences que ce premier billet va tenter de résumer.

-   *The Groovy Ecosystem*, Andres Almiray

-   *Crash Course into Scala*, Mario Fusco et Kevin Wright

-   *The Kotlin Programming Language*, Andrey Breslav

-   *The Ceylon Programming Language*, Emmanuel Bernard et Stéphane
    Épardeau

-   *Is Fantom light years ahead of Scala?*, Stephen Colebourne

Il ne s'agit en aucun cas d'un compte rendu exhaustif, mais plutôt des
points qui m'ont marqués (et dont je me souviens encore :P).

Scala
=====

J'ai commencé la semaine avec une introduction à Scala. Ce langage est
dans ma TODO list et malgré mon arrivée une heure en retard, j'ai pu
apprécier la conférence animée par Mario Fusco (père de LambdaJ) et de
Kévin Wright.


L'usine à DSLs
--------------

Mario Fusco a notamment mis en avant la facilité de créer ses propres
[DSLs](http://en.wikipedia.org/wiki/Domain-specific_language) en Scala
très rapidement. Comment ? En s'appuyant sur les conversions implicites.
Comme son nom l'indique, cette propriété de Scala permet d'indiquer au
compilateur de passer d'un type à un autre sans aucune mention
explicite. L'exemple le plus connu est `"toto" * 3` qui produit
`"totototototo"`.

Puisque la méthode \* n'est visiblement pas définie dans la classe
`java.lang.String` et qu'il n'existe aucun moyen de l'ajouter (la classe
est finale), il  suffit de définir cette méthode dans une autre classe,
disons `StringRepeater` et d'indiquer une conversion implicite entre
`String` et `StringRepeater` en écrivant comme suit:

``` {.scala}
implicit def myFirstImplicitConversion(str: String) = new StringRepeater(str)
```

Quand le compilateur rencontrera une expression du type `"toto" * 3`, il
cherchera donc toutes les conversions implicites disponibles dans le
scope courant qui permettent de convertir une `String` vers une instance
de classe où la méthode \* est définie.

Cette fonctionnalité est donc très puissante, comme vous l'aurez vu.
Exploitant au maximum cette possibilité, Mario Fusco a d'ailleurs créé
le moteur de règles [Hammurabi](http://code.google.com/p/hammurabi/)
\"pour le fun\". Il a d'ailleurs tenu une conférence à part entière à ce
sujet. Un inconvénient potentiel réside dans le fait que ces conversions
sont implicites, justement, et qu'il peut devenir compliqué de
déterminer quelle conversion est sélectionnée (pour peu qu'il y en ait
un certain nombre dans le même scope).

Scala dans vos équipes
----------------------

Kevin Wright a ensuite pris le relais.

Selon lui, un développeur Java doit \"parler\" XML et coder en Spring,
du fait des nombreuses insuffisances du langage Java.

Scala, au contraire, est suffisamment riche et expressif (*literary
programming*) qu'il permet de se focaliser sur des problématiques métier
en restant très peu verbeux (vous trouverez un exemple de code appuyant
ses propos [ici](https://gist.github.com/1262988)).

Étant intervenu dernièrement dans 3 entreprises afin de former et mettre
en place Scala dans les équipes de développement, Kevin nous partage ses
expériences et prodigue quelques conseils intéressants.
Il explique tout d'abord qu'il n'a rencontré que très peu (voire pas du
tout) de résistance à l'apprentissage de Scala. Partout où il est
intervenu, il a procédé ainsi :

-   écrire les tests en Scala

-   laisser l'enthousiasme se répandre :)

-   bouger progressivement toute la base de code vers Scala

L'erreur à ne pas commettre est de vouloir changer les composants en
production les plus critiques tout de suite. La réécriture des tests
reste donc souvent un choix raisonnable.

Groovy
======

Je ne connaissais Groovy que de nom et notamment au travers de son
leader superstar Guillaume Laforge. La présentation menée par le *sehr
sympatisch* Andres Almiray, papa de
[Griffon](http://griffon.codehaus.org/), a été très agréable, montrant
de nombreux outils/frameworks développés en Groovy. Que ce soit pour la
programmation par contrat avec
[GContracts](https://github.com/andresteingress/gcontracts/wiki/), le
développement web avec le le framework phare
[Grails](http://grails.org/) ou le BDD avec
[easyb](http://www.easyb.org/), vous trouverez forcément chaussure à
votre pied.

Cependant, le produit qui a retenu le plus mon attention est Griffon. Ce
projet qui s'inspire à la fois de Grails et de Swing en est bientôt à la
version 1. Il permet de construire des applications riches. Deux idées
m'ont particulièrement séduit :

-   puisqu'il s'inspire de Grails, Griffon semble très accessible aux
    développeurs Web (dont je fais partie). J'avais plutôt observé le
    phénomène inverse jusqu'ici (exemple : Wicket).

-   Griffon permet de générer des artefacts différents à partir des
    mêmes sources (applet Java, Swing...​).

Bref, si je dois développeur une appli riche un jour, je regarderai
Griffon avec le plus grand intérêt.

Kotlin et Ceylon
----------------

Kotlin est un langage en cours de développement par la société
Jetbrains, les p'tit gars derrière IntelliJ IDEA et beaucoup d'autres
IDE. Tous ces produits sont codés en Java. Les développeurs de Jetbrains
en sont à la conclusion que leur code pouvait être grandement simplifié
: l'idée de Kotlin est donc né. L'équipe a fixé entr'autres les
objectifs suivants :

-   Kotlin doit être compatible avec Java

-   le code Kotlin doit compiler au moins aussi vite que le code actuel

-   le langage doit rester concis et simple (comprendre aussi par là :
    plus concis que Java, plus simple que Scala)

Les objectifs sont somme toute très similaires côté Red Hat, avec le
projet Ceylon, dont [le site officiel](http://www.ceylon-lang.org/) a
été lancé le 18 novembre dernier, jour même de la conférence de
présentation par Emmanuel Bernard et Stéphane Epardaud.

### Types Nullable

Parmi les points communs, on recensera les types *Nullable*. En effet,
que ce soit en Ceylon :

``` {.ceylon}
String myString = null
```

ou en Kotlin :

``` {.kotlin}
var myString: String = null
```

ces deux exemples de code ne compileront pas. La valeur `null` n'existe
que pour un seul type (`Nothing` en Ceylon). Pour y remédier, il
\"suffit\" de modifier le type déclaré à `String?` (équivalent à
`String|Nothing` en Ceylon - ici un type union : `String` OU
`Nothing`).

Encore plus fort, les deux compilateurs sont assez intelligents pour
affiner le type d'une variable selon les tests qui ont été effectués en
préalable. Un premier exemple avec Ceylon :

``` {.ceylon}
void doSomething(String? arg) {  
    //print (arg.length); // doesn't compile, the expression could throw an NPE  
    if (exists arg) {
        print (arg.length); // compiles given arg cannot be null after this test  
    }
}
```

À la ligne 4 de l'exemple ci-dessus, `arg` n'est plus de type
`String|Nothing` mais bien de type `String` seulement. Plus concisément
(en Kotlin cette fois-ci):

``` {.kotlin}
print(myString?.length())
```

Ici, si `myString` est `null`, alors l'expression sera directement
évaluée comme étant `null`, sinon l'expression `myString.length` sera
évaluée. Notez que cette syntaxe se retrouve aussi en Fantom.

Pour résumer : une défaite pour les NPE, une victoire pour les amoureux
de Question Mark.


### Classes et héritage

Une classe en Kotlin ou en Ceylon définit à la fois un type mais aussi
un constructeur. En Ceylon :

``` {.ceylon}
shared class Counter(Natural initialValue=0) {
    value count = initialValue;
}
```

Comme vous vous en doutez, `shared` en Ceylon s'apparente à `public` en
Java. Pour être précis, Ceylon n'a que deux niveaux de visibilités. La
classe `Counter` définit un constructeur qui prend un argument de type
`Natural` dont la valeur par défaut est 0, lequel initialise la
propriété `count`. En Ceylon, il n'est possible de définir qu'un seul
constructeur et bannit l'overloading de manière générale, le système de
valeur par défaut permet de compenser une écrasante majorité de ses cas
d'usage (dixit les messieurs de Ceylon, de Kotlin et même de Fantom,
hein...​).

Notez aussi que les deux langages supportent les propriétés (dites donc
adieu aux innombrables getters et setters qui jonchent vos classes
Java).

Plus intéressant, l'héritage en Ceylon comme en Kotlin est un petit peu
plus avancé qu'en Java puisqu'il permet l'héritage multiple de
[mixins](http://en.wikipedia.org/wiki/Mixin). Pour faire simple, il est
possible de définir des implémentations par défaut dans les
interfaces/traits (*defender methods*, *virtual extension method*,
...​).

J'y reviendrais plus en détails, cher lecteur, dans un prochain billet,
puisque notre maître à tous, j'ai nommé Brian Goetz, a précisément
abordé ce thème pendant la conférence **\"Language / co-evolution in
Java SE 8\"** auquel j'ai eu le plaisir d'assister.

Un exemple d'héritage multiple en Kotlin :

``` {.kotlin}
open class Base {
    virtual fun v() {}    
    fun nv() {}
}

open class Base2()

class Derived() : Base2, Base {
    override fun v() {}
}
```

On apprécie l'absence totale d'ambiguïté du code précédent. En effet, en
Kotlin, toute classe non `open` est finale (immutabilité renforcée),
tout membre overridable doit être déclaré `virtual` (s'il est déjà
`abstract`, la mention de `virtual` devient redondante donc
facultative).

Mais qui dit héritage multiple dit \"*how the f\*ck are you gonna handle
the [Diamond Problem](http://en.wikipedia.org/wiki/Diamond_problem)?*\"
(exemple repris de la [doc
officielle](http://confluence.jetbrains.net/display/Kotlin/Classes+and+Inheritance)
de Kotlin) :


``` {.kotlin}
open class A(virtual var v : int)
open class B(v : Int) : A(v)
open class C(v : Int) : A(v)
class D(v : Int) : B(v), C(v)

fun main(args : Array<String>) {    
    val d = D(10)
    d.v = 5
    print(d.v)
}
```

Ici, le compilateur se plaindra du fait qu'il ne peut déterminer de quel
*getter* hérite le *getter* implicite de la propriété `v` dans D. Afin
de résoudre le problème, il est nécessaire de redéfinir la propriété `v`
explicitement dans D de la façon suivante :

``` {.kotlin}
class D(v : Int) : B(v), C(v) {
    override var v : Int    
    get() = super<B>.v    
    set(value) { super<B>.v = value }
}
```

Par corollaire, le *setter* de D pourrait hériter du *setter* de B et le
*getter* de celui de C (ça va donner lieu à des *Kotlin puzzlers* bien
sympa, je le sens).


### Alors, Kotlin ou Ceylon ?

Sachez que je suis loin d'avoir couvert les possibilités offertes par
ces deux langages : jetez un oeil aux documentations officielles par
vous-mêmes.

Ce qui m'a plu chez Kotlin est le support multi-IDE (Eclipse, IntelliJ)
et la réutilisation maximale des mots clefs Java.


Côté Ceylon, j'ai particulièrement apprécié le côté ouvert du projet,
chacun peut contribuer (les tâches les plus faciles sont gardées
ouvertes un peu plus longtemps afin de laisser leur chance aux nouveaux
venus), toutes les sources (site web compris) sont hébergées sur
Github.



Fantom
======

Je n'ai assisté qu'à une partie de la conférence animée par Stephan
Colebourne, créateur de [Joda-Time](http://joda-time.sourceforge.net/).

*\"Is Fantom light years ahead of Scala?"* se voulait très provocateur.

Comme vous l'aurez deviné, Stephen n'aime pas Scala, qu'il trouve
beaucoup trop complexe. Vous trouverez d'ailleurs [une récente
publication](http://blog.joda.org/2011/11/scala-feels-like-ejb-2-and-other.html)
de sa part où il énumère un certain nombre d'arguments et de ressentis
qui le pousse à préférer d'autres langages que celui-ci.

Mais revenons-en à [Fantom](http://fantom.org/).
À la fois orienté objet et fonctionnel, Fantom embarque la notion de
*pod*, a.k.a. modules (prévu en Java pour la release du JDK8, par le
projet Jigsaw, lequel a fait l'objet d'une conférence à part entière par
Mark Reinhold).

Un *pod* est :

-   le niveau hiérarchique le plus élevé (un pod contient des *types* -
    classe ou mixin, un type contient des *slots* - méthode ou champ) ;

-   l'unité de compilation en Fantom : une classe ne peut se compiler,
    seul le pod auquel elle appartient peut l'être ;

-   le nom d'un *pod* est globalement unique, comporte le VCS utilisé et
    le numéro de version

Ainsi, pas besoin de librairie tierce \"à la Maven\", le langage
comporte déjà tout ce qu'il faut. Contrairement à Kotlin et Ceylon,
Fantom est déjà relativement mature et dispose d'une API assez
conséquente.

Le reproche que je pourrais apporter au langage est l'apport un peu trop
conséquent, à mon goût, de nouveaux termes techniques (pourquoi utiliser
le terme pod plutôt que module par exemple ?).


Conclusions intermédiaires
==========================

J'ai vraiment apprécié cette *track* \"Nouveaux langages\", laquelle m'a
permis d'apprendre de nombreux concepts (mixins, nullable ...​) et de
comprendre un peu mieux les motivations et aussi les difficultés
rencontrées par les créateurs de nouveaux langages.

Fantom, Ceylon et Kotlin ont de nombreuses similarités mais Scala reste
malgré tout le langage que j'apprendrai avant tout :)
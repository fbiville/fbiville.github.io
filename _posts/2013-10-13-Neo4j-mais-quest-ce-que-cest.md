---
layout: post
title: "Neo4j : mais qu'est-ce que c'est ?"
---
Les graphes sont partout et il y a une bonne raison à cela : il s'agit
de l'une des structures de données les plus génériques qui existent dans
notre panoplie de développeur. Tellement générique qu'elle se retrouve
dans de nombreux domaines métier.

En témoigne un concours clos récemment : le [GraphGist
challenge](http://www.neo4j.org/learn/graphgist_challenge).

La notion de [gist](https://gist.github.com/) a été popularisée par
[Github](https://www.github.com/). Le terme signifie littéralement
\"idée générale\" et consiste, dans le cas de Github, à partager un bout
de code à d'autres personnes.

La notion de [GraphGist](http://gist.neo4j.org/) s'en inspire largement
et laisse l'utilisateur saisir quelques requêtes typiques d'un graphe,
agrémentées de commentaires. Basée sur <http://console.neo4j.org>, la
console interactive de Neo4J, vous pourrez alors exécuter les requêtes
saisies voire les modifier si l'envie vous en prend.

Sans en aller jusque là, je vous invite tout de même à consulter les
[contributions](https://github.com/neo4j-contrib/graphgist/wiki) du
concours et vous constaterez à quel point elles sont diverses : n'est-ce
pas là la meilleure preuve qu'une base de données graphe peut vous
dépanner dans de nombreuses situations ?

Nom : Neo4J, fonction : base de données graphe
==============================================

Revenons aux fondamentaux : Neo4J est une base de données
[ACID-compliant](http://fr.wikipedia.org/wiki/Propri%C3%A9t%C3%A9s_ACID)
orientée graphe. Elle persiste, comme son nom peut le suggérer, des
noeuds et des relations.

![image](https://lh4.googleusercontent.com/n_tOS-0poKPC8Bma1P3N9kbzQczOQw_wnbX0tt4m32gPZX9nF7_OOgRjTba51sA8QbY04Na2KQdNlHiA-v20dXmGUexI4uvVjnAPs7niE3JfIeeGYFU0lwSLzw)

Base de données, vous connaissez : PostgreSQL, Oracle sont des exemples
bien connus de base de données relationnelles. D'ailleurs, pourquoi ne
retrouve-t'on pas le terme \"relationnel\" pour les bases de données
graphe ?

![image](https://lh3.googleusercontent.com/gNPP3UXguHPCv-sTTn2TTHNWLZtRrMMsuJwPd0mozfQO5wPcNl_aAiQiPp2s2zV8dz6RzeipuLfnF5ABqxp082W9T29AfbJduj7jfM8GhvEOWC4cGxo4NSCELA)

Dans le cas de nos bons vieux SGDBR, le terme relationnel prend ses
racines dans la théorie de l'algèbre dite (elle aussi, comme c'est
étrange) relationnelle, laquelle fut fondée fondée par Edgar Frank Codd
(voir photo précédente) en 1970 (oui, oui, la même année que
[ça](http://www.youtube.com/watch?v=huZFThnetjo)). (Tiens, d'ailleurs,
vous savez pourquoi le mouvement NOSQL s'endort : parce que Codd est in
!). L'algèbre relationnelle formalise une série d'opérations applicables
à des ensembles, lesquels sont fixés par un schéma qui leur est propre.

Et donc à y regarder de plus près, Neo4J n'est donc pas une base de
données relationnelle *stricto sensu* : aucun schéma n'est requis ! Si
vous souhaitez semi-structurer vos données, cette tâche vous revient.

Concernant ce dernier point, notez tout de même qu'entre la V1 et la V2,
Neo4J est passé du rang *\"schemaless\"* à *\"schema-optional\"*. Cette
version 2, en cours de finalisation, promeut une nouvelle notion : les
[labels](http://docs.neo4j.org/chunked/milestone/graphdb-neo4j-labels.html).
Vous pouvez maintenant regrouper vos noeuds par famille. Un noeud
représentant par exemple un chien pourra se voir apposé les labels
\"canidé\", \"mammifère\" et \"animal\".

Un label n'est rien d'autre qu'une étiquette. Deux noeuds libellés de la
même façon pourront contenir des propriétés potentiellement différentes.
Neo4J reste avant une base de données sans schema. Les labels sont juste
une manière très légère de donner plus de sens à vos données. N'hésitez
à regarder ce court [*screencast*](http://www.neo4j.org/develop/labels)
d'introduction.

Neo4J persiste des *property graphs*
------------------------------------

Le graphe est une structure de données tellement riche, tellement variée
qu'il serait faux de croire que toutes les typologies de graphe du monde
sont supportées.

À l'instar du
[modèle](https://github.com/tinkerpop/blueprints/wiki/Property-Graph-Model)
poussé par la spécification Blueprints de Tinkerpop, Neo4J supporte
uniquement le *property graph*. Comme dans tout graphe, nous disposons
de noeuds (*nodes*, *vertices*) et éventuellement de relations
(*relationships*, *edges*,*arcs*) orientées ou non. Chacun de ces deux
types d'élements peuvent être constitués de 0 à n paires de
clefs-valeurs (comme l'illustre l'image ci-dessous).

![image](https://lh4.googleusercontent.com/oDnT0mVQO6YJ6XJ6SW0fEGnTdL8LWyw2a3-mFR1pjbHGxI6BrfLOha3iLhGjAyE30leiugTZI_PyaOUCJoaMneyAKJpin0hxbWVx86Z8uehz71H_7BOqrGNfRw)

Vous l'aurez compris, ce graphe décrit les relations entre différents
personnages de Matrix (film tellement culte qu'il a largement inspiré le
nom Neo4J). Les chiffres représentent les IDs techniques des noeuds.

Les noeuds (ronds) contiennent un nombre varié de propriétés (bloc gris)
et se joignent par des relations (lignes pointillées) avec un type (ici
KNOWS et CODED_BY). Rien n'indique que nous ayons à faire à des
personnages ici, puisque qu'aucun noeud n'a exactement la même structure
(certains ont une propriété last name, d'autres une propriété language).
De même, bien que la grande majorité des relations ici soit libellée
KNOWS, certaines n'ont pas de propriétés, d'autres une propriété
disclosure...​

C'est par une lecture plus globale que l'on comprend ce que le graphe
représente. L'aspect schéma-optionnel peut paraître déroutant, mais une
fois dompté, il vous permet d'intégrer un nombre d'informations utiles
là où cela fait sens (rappelez-vous cette colonne supplémentaire que
vous avez ajoutée à votre table et dont la valeur est NULL pour 90% des
enregistrements).

Un *property graph*, bien que très flexible, impose quelques contraintes
: ses noeuds et relations doivent être identifiés de façon globalement
unique (ce sont les IDs techniques dont je vous parlais). En outre, ses
relations doivent nécessairement comprendre un noeud de départ (*tail*)
et d'arrivée (*head*), potentiellement non distincts. En d'autres
termes, un noeud peut avoir une relation avec lui-même (et je prie tout
esprit malsain de s'abstenir de commentaires douteux).

Quoi qu'il en soit, le modèle de Neo4J est simple, ses concepts se
comptent sur les doigts d'une main (noeuds, relations, propriétés,
labels). Il existe d'autres types de graphes non supportés par Neo et
qui ont aussi leur utilité.

Un modèle de persistence orienté graphe différent : *le triplestore*
--------------------------------------------------------------------

La spécification
[RDF](http://fr.wikipedia.org/wiki/Resource_Description_Framework) du
W3C décrit un autre modèle de graphe, destiné à représenter les
ressources sur le Web et leurs métadonnées. Un document persisté dans un
store RDF est un ensemble de triplets (sujet, prédicat, objet).
L'intérêt d'une telle formalisation est de pouvoir formuler des requêtes
intelligentes permettant d'obtenir les données qui nous sont le plus
pertinentes (via le langage de requêtage standardisé SPARQL par
exemple).

Ayant honteusement pompé la documentation
d'[AllegroGraph](http://www.franz.com/agraph/allegrograph/) (une base de
données graphe conforme à RDF), je vous invite à regarder l'exemple
trivial suivant :

![image](https://lh5.googleusercontent.com/XnkjhxAd62wOEyq5mf_zhdZcCxYNL6tysMVDHgxJa2PZHzQPvcqFhy5KDmjWGTakDd9883UnVyYvyyRrvPBAFLRFsEtnpwEb0Zlh3ZM63uGqdH7XcCkr7o7H1g)

Un exemple de triplets issus de ce graphe pourrait être :

| sujet  | prédicat   | objet  |
|--------|------------|--------|
| Jans   | Type       | Human  |
| Robbie | Type       | Dog    |
| Robbie | PetOf      | Jans   |
| PetOf  | InverseOf  | HasPet |
| Dog    | SubClassOf | Mammal |

Une fois persisté, vous pourrez donc formuler des requêtes type \"sujet
= Jans\" ou encore \"type = PetOf, objet = Jans\" afin de récupérer le
ou les triplets correspondants.

Si le sujet vous intéresse, n'hésitez pas consulter les ressources
suivantes :

-   Qu'est-ce que RDF ? <http://www.w3.org/TR/rdf-primer/>

-   Documentation
    d'[AllegroGraph](http://www.franz.com/agraph/support/documentation/current/agraph-introduction.html)

-   Tutoriaux pour et par [Apache
    Jena](http://jena.apache.org/tutorials/index.html)

-   et bien d'autres !

Comme je vous le disais, Neo4J ne supporte pas cette notion de triplet
(une relation n'affecte que deux noeuds maximum). Il existe cependant
différentes façons de contourner cette limitation :

1.  introduire un noeud factice, lui-même lié aux trois noeuds qui vous
    intéresse

2.  regarder du côté de
    [Neo4j-RDF](https://github.com/neo4j-contrib/neo4j-rdf), un module
    communautaire

Mais cela devient déjà fastidieux, alors imaginez une seconde essayer de
persister un [hypergraphe](http://fr.wikipedia.org/wiki/Hypergraphe)
avec Neo4J et vous comprendrez votre douleur. S'il y a bien une idée qui
doit ressortir de NOSQL (plutôt que \"remplaçons MySQL par MongoDB\")
est \"chaque base a son usage\", donc n'allez pas coller Neo4J n'importe
où non plus ;-)

Son modèle est certes très simple et souffre de quelques limitations
théoriques, mais cette base de données sait très bien s'adapter à un
large panel de situations.

Qui utilise Neo4J ?
===================

Et pour bien comprendre la variété des cas d'utilisation candidats à une
utilisation de Neo, il suffit de lister les domaines métier des
[utilisateurs officiels](http://www.neotechnology.com/customers/) (on y
retrouve de l'aéronautique et des coopératives agricoles en passant par
les télécoms et la [biologie](http://bio4j.com/)). Je ne saurai
prétendre à l'exhaustivité, prenons toutefois l'exemple français de
Viadeo.

Disclaimer : je n'ai pas travaillé avec cette entreprise, cela ne
reflète aucunement le travail qui a été mis en oeuvre dans cette
société.

Viadeo : Neo4J comme moteur de recommandations
==============================================

![image](https://lh5.googleusercontent.com/tMhBpya1njHQk1vqB8lwNQ_7gmoeZ7dzrerRkT2wPaCs1KmI2wyCnzj85KKTQow8H7o5oIpgnE9w8qR3ZG5QBEsXy-2pZKwgXotCqArBd6QorJrO44-zGZ5MYA)

[Viadeo](http://fr.viadeo.com/) est un réseau social professionnel,
permettant de mettre en relation deux personnes partageant (le plus
souvent) au moins une expérience professionnelle commune. Leur moteur
initial de recommandations rencontrait de plus en plus de difficultés :
plus ça allait, plus le batch de calcul de recommandations requiérait du
temps...​ jusqu'au point de non-retour ou y dédier un week-end complet
ne suffisait plus. Mais Neo4J vint à la rescousse !

Imaginez donc que vous soyez recrutés pour réaliser cette nouvelle
version du moteur de recommandations. Votre mission, si vous l'acceptez,
est de réaliser un prototype permettant de stocker un ensemble de
contacts, d'entreprises. Chaque contact peut avoir travaillé pour une ou
plusieurs entreprises et peut être en contact direct avec d'autres
personnes.

Avant d'ébaucher le modèle, vous vous rendez compte qu'il vous est
nécessaire de vous former rapidement au langage de requêtage privilégié
de Neo4J : Cypher.

Cypher crash course
===================

Cypher a pour rôle de requêter des données sur Neo4J (en plus d'être un
traître dans le premier volet de Matrix). Déclaratif, Cypher vous laisse
décrire la forme du résultat qui vous intéresse et les contraintes que
vous souhaitez y ajouter : c'est lui qui se chargera d'optimiser le plan
d'exécution pour récupérer vos résultats.

Anatomie d'une requête en lecture
---------------------------------

Pour lire de la donnée, vous suivrez donc 4 étapes :

1.  clause `START` : définition du ou des points de départ dans votre
    graphe. Ce peut être des noeuds ou des relations. Mieux vous ciblez
    vos points de départ, moins vous aurez de données à traverser et
    plus performante votre requête sera (et de plus en plus comme Yoda
    je m'exprime). Note : depuis la v2, cette clause peut la plupart du
    temps être omise.

2.  clause `MATCH` : c'est ici que tout se joue ! Vous décrivez la petite
    portion du graphe qui vous intéresse (par exemple :"les noeuds de
    label ZOMBIE qui sont en relation FRIEND_WITH avec les noeuds de
    label PLANT eux-mêmes en relation FARMED_BY avec des noeuds de
    label HUMAN\"). Notez qu'il est
    [**très**](http://www.javacodegeeks.com/2013/01/optimizing-neo4j-cypher-queries.html)
    de ne spécifier ici que ce qui vous sera utile pour le résultat. Si
    par exemple, vous ne souhaitez retourner que des noeuds de label
    HUMAN et ZOMBIE, alors déportez le reste dans la clause de filtrage
    WHERE, (ce qui donne \"les noeuds de label ZOMBIE indirectement liés
    aux noeuds de label HUMAN pour lesquels (WHERE) il existe une
    relation FRIEND_WITH des noeuds de label PLANT avec une relation
    FARMED_BY\").

3.  clause `WHERE` : à l'instar d'une requête SQL, vous rédigez ici vos
    prédicats permettant de réduire (filtrer) le nombre
    d'enregistrements à ce qui vous intéresse. Basé sur l'exemple
    précédent, nous pourrions nous intéresser uniquement aux noeuds
    HUMAN dont le nom est \"Florent Biville\" par exemple.

4.  clause `RETURN` : c'est évidemment ici que vous spécifiez l'expression
    qui décrit le résultat qui vous intéresse. Cette expression peut
    être simple (un ensemble de variables déclarées dans les clauses
    précédentes) ou plus complexes (utilisation d'opérateurs
    d'[aggrégation](http://docs.neo4j.org/chunked/milestone/query-aggregation.html)).

Je ne traite ici que la partie lecture (en omettant d'ailleurs certaines
clauses comme `LIMIT`, `ORDER BY` et, une clause introduite plus récemment,
`WITH`, qui agit comme un *pipe* Unix entre différentes requêtes).

Description de patterns (`MATCH`) : l'ASCII Art au service du graphe
------------------------------------------------------------------

Rappelez-vous du *property graph* précédent :

![image](https://lh3.googleusercontent.com/2XrmgbjrUXhdLVpEPqEO34PYD9a318K2FDpx8Bo7tuzbA3fG1L3VI1RTeujEfxJGbIcs9q2BuP15wUdMKu29ihI5KvGVXRzkwDg1Mp3hXh-L_0tO9UxizmhLqQ)

Les graphes sont souvent dépeints avec des \"ronds\" pour les noeuds et
des \"flèches\" pour les relations. Tout en prenant soin de ne pas trop
s'éloigner de la triste réalité de nos claviers, Cypher tente toute de
même de se rapprocher de cette symbolique (hein,
[BODOL](https://github.com/bodil/BODOL)!).

La façon la plus simple/rapide de décrire un rond (et donc un noeud) ?
`()`

La façon la plus simple/rapide de décrire une flècle (et donc une
relation) ? `-->`

Épiçons un peu.

Une relation orientée / non-orientée entre deux noeuds ? `()-->()` / `()--()`

Trois noeuds joints par deux relations orientées ? `()-->()-->()`

Un noeud de label HUMAN ? `(:HUMAN)`

Un noeud avec les labels GEEK et NERD ? `(:GEEK:NERD)`

Une relation non-orientée de type IDYLLIC ?
`(:HUMAN)-[:IDYLLIC]-(:HUMAN)`

Nous y sommes presque. Reste un point épineux : comment fais-je
référence à ces jolis patterns dans les clauses suivantes de ma requête
?

Par des noms de variable pardi !

Prenons un exemple de requête complète :

``` {.cypher}
 MATCH (flo:HUMAN:MALE)-[luv:LOVES]-(didi:HUMAN:FEMALE
 WHERE flo.firstName = 'Florent' AND didi.firstName = '...' // ;-)
 RETURN flo, didi, luv.since
```

Comme vous le voyez, vous pouvez utiliser à peu près n'importe quel nom
de variable, que vous pourrez reprendre ensuite dans d'autres clauses
afin de définir et affiner le résultat. (Ah oui, et la requête répond à
\"Qui aime et est aimé par Florent et depuis quand ?").

Il existe bien d'autres aspects que je n'ai pas décrits ici :

-   opérateurs (NOT, IN, ...​)

-   aggrégation

-   requêtes d'écriture

-   indexation

-   les alternatives à Cypher : le [framework de
    traversée](http://docs.neo4j.org/chunked/milestone/tutorial-traversal-java-api.html),
    le langage
    [Gremlin](https://github.com/neo4j-contrib/gremlin-plugin) devéloppé
    par Tinkerpop

        <shamelessPlug> Les http://www.lateral-thoughts.com/formations[formations] ou http://www.brownbaglunch.fr/baggers.html#Florent_Biville[BBL] sont l'occasion d'en parler </shamelessPlug> .

Retour à Viadeo : implementation time!
======================================

Revenons à votre moteur de recommandations. Le genre de questions auquel
vous devez répondre ressemble à \"trouver tous les contacts de mes
contacts\" ou encore \"trouve-moi tous les contacts de mes contacts, qui
connaissent quelqu'un avec qui j'ai déjà travaillé\". C'est un point qui
s'applique bien au delà de Neo4J d'ailleurs : **avant de pondre un
modèle de données, réfléchissez aux questions auxquelles il doit
répondre !**

Au vu de celles énoncées ci-dessus, un graphe avec les éléments
suivantes pourrait tout à fait faire l'affaire :

-   les utilisateurs auront un label `CONTACT`

-   les entreprises auront un label `COMPANY`

-   les noeuds ont (pour simplifier) une propriété name qui contient nom
    et prénom

-   le fait d'être en contact est matérialisé par
    `(:CONTACT)-[:IN_CONTACT_WITH]-(:CONTACT)`

-   le fait de travailler pour une entreprise s'écrit :
    `(:CONTACT)-[:WORKED_IN]->(:COMPANY)`

Vous décidez donc de commencer par la requête visiblement la plus
simple, à savoir \"trouve-moi tous les contacts de mes contacts\".

Comme votre formateur précédent ne l'a pas mentionné, vous avez eu
l'heureuse initiative de consulter la superbe documentation de Neo4J
concernant les [requêtes
paramétrées](http://docs.neo4j.org/chunked/stable/cypher-parameters.html).

Vous arrivez donc à la requête suivante :

``` {.cypher}
 MATCH (suggestions:CONTACT)-[:IN_CONTACT_WITH]-(:CONTACT)-[:IN_CONTACT_WITH]-(me:CONTACT)
 WHERE me.name = {name} // {name} est un paramètre nommé, passé à l'exécution
 RETURN me, suggestions
```

Plutôt expressif, non ? Vous traversez deux relations `IN_CONTACT_WITH`
pour trouver des suggestions de contact.

Oui mais...​ il subsiste un petit souci que certains d'entre vous auront
peut-être entrevu. Être un contact avec quelqu'un sur Viadeo est
bidirectionnel (je suis en contact avec toi donc tu es en contact avec
moi).

Mettez-vous donc dans la peau du *traversal framework* : vous rencontrez
alors un noeud de label `CONTACT` (appelons-le Alfred), suivez une
première relation `IN_CONTACT_WITH` qui vous amène à un autre noeud de
label `CONTACT` (appelons-le Alphonse). Le souci est que rien ne vous
interdit de suivre la même relation dans l'autre sens et revenir à
Alfred ! Par conséquent, Alfred se retrouve donc comme contact de
contact de lui-même et sera annoncé comme recommandation, ce qui lui
fait une belle jambe à Alfred !

Mais ne paniquez pas ! Vous avez plusieurs possibilités (comme
l'utilisation de
[`DISTINCT`](http://docs.neo4j.org/chunked/milestone/query-aggregation.html#aggregation-distinct))
ou encore :

``` {.cypher}
 MATCH (suggestions:CONTACT)-[:IN_CONTACT_WITH]-(:CONTACT)-[:IN_CONTACT_WITH]-(me:CONTACT)
 WHERE me.name = {name} AND me <> suggestions +
 RETURN me, suggestions
```

Notez enfin que vous pouvez reformuler le *pattern* de `MATCH` de façon à
ce qu'elle ne référence vraiment que ce qui est utilisé dans la clause
`RETURN`. Je vais vous présenter une façon de faire et vous laisser
l'autre comme exercice ;-)

Avant de vous montrer cette reformulation, voici la syntaxe complète
d'une relation comme l'indique la
[documentation](http://docs.neo4j.org/chunked/milestone/query-match.html#match-variable-length-relationships)
de Cypher:

     `[variableName:RELATION_TYPE*minHops..maxHops]`

La partie de gauche est déjà connue. La partie précédée d'une
astérisque, quant à elle, paraît plus exotique. Elle permet de spécifier
des degrés de séparations (ne pas le spécifier revient à écrire
\*1..infinité). Par défaut, vous cherchez une relation d'un degré au
moins égal à 1 (ami de) ou plus (ami d'ami d'ami d'ami d'ami...​).

Or, ce que vous voulons, ce sont des contacts de contacts. La requête
peut donc être réécrite comme suit (avec une légère feinte : minHops est
égal à maxHops) :

``` {.cypher}
 MATCH (suggestions:CONTACT)-[:IN_CONTACT_WITH***2..2**]-(me:CONTACT) +
 WHERE me.name = {name} AND me <> suggestions +
 RETURN me, suggestions
```

Dans le cadre de requêtes plus complexes, vous pourriez simplifier la
clause `MATCH` et imposer le chemin intermédiaire requis dans la clause
`WHERE`. En effet, si vous n'avez pas besoin du chemin intermédiaire dans
la clause `RETURN` c'est qu'il n'est nécessaire qu'au *filtrage* c'est
donc pourquoi la clause `WHERE` est toute indiquée dans cette situation.

Évidemment, cette requête n'est qu'une façon de se mettre le pied à
l'étrier. Une fois mis en production, vous vous rendez compte que :

1.  certains contacts déjà ajoutés apparaissent dans les recommandations

2.  le taux d'acceptation est mitigé, visiblement, il va falloir affiner
    les critères de sélection !

Vers une requête mieux ciblée
=============================

Et si vous essayiez d'implémenter la requête de recommandations suivante
\"trouve-moi tous les contacts de mes contacts, qui connaissent (sont en
contact avec) quelqu'un avec qui j'ai déjà travaillé\".

Petit rappel du graphe :

-   les utilisateurs auront un label `CONTACT`

-   les entreprises auront un label `COMPANY`

-   les noeuds ont (pour simplifier) une propriété name qui contient nom
    et prénom

-   le fait d'être en contact est matérialisé par
    `(:CONTACT)-[:IN_CONTACT_WITH]-(:CONTACT)`

-   le fait de travailler pour une entreprise s'écrit :
    `(:CONTACT)-[:WORKED_IN]->(:COMPANY)`

Le début de la requête est exactement le même que précédemment : je
récupère les contacts de contacts.

À VOUS, MAINTENANT !

Promis, je donne *une* solution dans le prochain article !

Le mot de la fin
================

Nous sommes encore loin d'avoir implémenté [un moteur de
recommandations](http://www.reco4j.org/) digne de ce nom. Néanmoins,
vous avez pu d'ores et déjà constater que les pré-requis pour jouer avec
Neo4J sont loin d'être insurmontables :

-   il suffit d'ouvrir <http://console.neo4j.org> dans votre navigateur
    favori

-   et écrire quelques requêtes
    [Cypher](http://docs.neo4j.org/chunked/2.0.0-M05/cypher-query-lang.html)
    pour vous faire la main

    i.  pour commencer à avoir des retours très rapides. Même pas besoin
        d'installer Neo4J. Une feuille de papier, un crayon et un
        navigateur suffisent !

Non content d'être simple à prototyper, Neo4J est aussi conceptuellement
simple et j'espère que cette mise en bouche vous en aura convaincu.

Pour le prochain article, j'aborderai Neo4J avec un angle plus technique
afin d'évoquer notamment :

-   la représentation des données sur disque

-   la gestion des transactions

-   et sa montée en charge

    i.  avant d'expliquer, dans l'article suivant, comment démarrer un
        projet Java avec Neo.

En attendant, je vais simplement paraphraser [Peter
Neubauer](https://twitter.com/peterneubauer) et conclure par :

> If you can write, you can code. If you can sketch, you can use a graph
> database.

Approfondir
===========

Rencontres : [Graph DB Paris](http://www.meetup.com/graphdb-france/)

Entraide : [Google Groups Neo4J
FR](https://groups.google.com/forum/#!forum/neo4jfr)

Conseil / formation : [Lateral
Thoughts](http://www.lateral-thoughts.com/), [Brown Bag
Lunch](http://www.brownbaglunch.fr/baggers.html#Florent_Biville)

Un grand merci à Mathilde, Hugo, Pierre-Yves pour leur relecture !
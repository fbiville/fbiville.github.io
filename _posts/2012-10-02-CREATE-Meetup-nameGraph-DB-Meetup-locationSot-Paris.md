---
layout: post
title: "CREATE (:Meetup {name:'Graph DB Meetup', location:'So@t Paris'})"
---
GraphDB Meetup : hello world
============================

Jeudi dernier s'est donc tenu le premier meetup français autour de
[Neo4J](http://neo4j.org/). Merci à [So@t](http://blog.soat.fr/) pour
l'accueil !

Au programme :

-   *présentation de la société Neo Technologies* par [Cédric
    Fauvet](https://twitter.com/Neo4jFr), responsable des développements
    de Neo4J en France

-   présentation de Neo4J par [Stefan
    Armbruster](https://twitter.com/darthvader42), freelance depuis
    passé dans les rangs de Neo Allemagne

-   retour d'expérience sur
    [SpringData/Neo4J](http://www.springsource.org/spring-data/neo4j)
    par [Olivier Girardot](https://twitter.com/ogirardot) et [votre
    serviteur](https://twitter.com/fbiville)

tl;dr?
======

C'était bien :)

Suivez le [meetup](http://www.meetup.com/graphdb-france/) pour vous
tenir au courant des prochains événements : on vous attend de pied ferme
!

Une bonne première
==================

Tout d'abord, un chiffre : plus d'une vingtaine de personnes a assisté à
ce meetup, sur les 30 inscrits. Pour un premier meetup, c'est un score
tout à fait honorable. L'ambiance fut décontractée et les échanges, que
ce soit pendant les présentations ou autour d'un verre de vin / bière et
d'une part de pizza, n'ont pas manqué.

Le public était autant composé de curieux que d'utilisateurs de Neo4J.
Certains ont même fait le déplacement de Belgique ! Bref, ce fut une
excellente occasion de rencontrer la communauté naissante et de discuter
de ce qui viendrait ensuite.

Les talks
=========

Présentation de Neo Technologies
--------------------------------

Cédric Fauvet, co-organisateur avec [Lateral
Thoughts](http://www.lateral-thoughts.com/) et initiateur du meetup, a
donc inauguré ce dernier par une présentation générale de Neo
Technologies, société supportant Neo4J. Basée originellement en Suède
(\"à trois, dans un garage\"), elle s'étend maintenant aux États-Unis,
en Allemagne, en France et ailleurs. Cédric est lui-même en charge des
développements dans l'Hexagone et a ainsi pu présenter certains cas
d'utilisation, tels que celui de Viadeo et son moteur de recommandations
temps réel.

Il a également annoncé le partenariat entre la société Lateral Thoughts
et Neo Technologies autour de Neo4J.

Neo4J
-----

Stefan Armbruster a ensuite pris le relais, afin de présenter la base de
données Neo4J. En quelques mots, Neo4J est une base de données orientée
graphe (tout est vertex et edge) transactionnelle et ACID. À la fois
disponible en licence open-source (\"Community\") pour les projets
open-source et en version payante, l'écosystème de Neo4J s'enrichit de
façon assez spectaculaire : développement du langage de requêtage
Cypher, requêtes géospatiales, intégration avec SpringData, bindings
avec Grails, Python ...​ ne sont qu'autant d'éléments qui tendent à
prouver que Neo4J sera encore bien présent dans les années à venir.

Retour sur SpringData/Neo4J
---------------------------

Après une pause pizza/bières/vin appréciable, Olivier Girardot et moi
avons conclu la soirée par une présentation certifiée sans slides autour
du code de notre *toy project*
[DevInLove](https://github.com/LateralThoughts/DevInLove). L'idée est
simple : permettre aux geeks de se regrouper par intérêts. Bien que
fonctionnellement limitée, l'application tente de tirer parti des
nombreuses features incluses dans SpringData/Neo4J. En l'espace d'une
vingtaine de minutes, nous avons pu montrer le mapping par annotations,
les repositories et leur magic finders ainsi que les dernières
évolutions liées à la version 1.8 (bientôt disponible en version stable)
autour du langage Cypher.

Olivier a aussi montré l'utilisation de [Gephi](https://gephi.org/) via
un plugin Neo4J : un outil scientifique de visualisation et de
manipulation de graphe. Sachez qu'il existe également
[NeoClipse](https://github.com/neo4j/neoclipse), développé spécialement
pour Neo4J.

What's next?
============

Comme annoncé précédemment, toutes les informations se trouvent ici :
<http://www.meetup.com/graphdb-france/>. Nous souhaitons que ce genre
d'événements continue, ne soyez donc pas surpris de voir une autre
session débarquer prochainement.
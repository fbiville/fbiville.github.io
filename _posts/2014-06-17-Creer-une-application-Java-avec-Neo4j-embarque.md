---
layout: post
title: "Créer une application java avec Neo4j embarqué"
---
Un long discours ?
==================

Après vous avoir assommé avec [mon article
précédent](/?post/2014/06/09/Neo4j-sous-le-capot) sur le stockage
interne de Neo4j et sa scalabilité, je vais aujourd'hui me contenter
d'assez peu. En effet, plutôt que de consacrer un effort important à
expliquer des bonnes pratiques autour de la mise en oeuvre de Neo4j dans
des projets Java, pourquoi ne pas créer l'[archetype
Maven](https://github.com/fbiville/maven-embedded-neo4j-archetype) qui
fait le boulot ?

Archetype...​ Maven ?
=====================

Alors oui, je sais, certains d'entre vous ne peuvent pas voir Maven en
couleurs. 

Je sais qu'il existe quelques archetypes bien particuliers autour de
Neo4j pour d'autres outils de build tels que
[celui](https://github.com/sarmbruster/unmanaged-extension-archetype) de
[Stefan Armbruster](https://twitter.com/darthvader42) pour
[Gradle](http://www.gradle.org/). Néanmoins, je n'ai pas croisé
d'archetypes équivalents à celui que je vais vous présenter.

Si vous pensez en avoir trouvé un, n'hésitez pas à [me
contacter](https://www.twitter.com/fbiville) que je le liste ici.

Physiologie
-----------

Penchons-nous maintenant
sur l'[archetype](https://github.com/fbiville/maven-embedded-neo4j-archetype) créé
pour l'occasion.

Il génère des projets embarquant :

-   neo4j

-   neo4j-kernel (classifier test-jar) pour les tests d'intégration

-   junit

-   assertj-core

[assertj-neo4j](http://joel-costigliola.github.io/assertj/assertj-neo4j.html)
n'est pas encore assez mature, je vais tâcher de le faire évoluer avant
de le proposer via l'archetype.

Contenu
-------

Si vous suivez [les
instructions](https://github.com/fbiville/maven-embedded-neo4j-archetype/blob/master/README.md),
vous vous retrouverez avec un projet tout simple : \* qui insère des
données avec
[Cypher](http://docs.neo4j.org/chunked/stable/cypher-query-lang.html) :
 - qui lit des données via le [framework de traversée
Java](http://docs.neo4j.org/chunked/stable/tutorial-traversal-java-api.html)
 - qui utilise EmbeddedDatabaseRule pour les tests
[JUnit](http://junit.org/) (cette [règle
JUnit](https://github.com/junit-team/junit/wiki/Rules) encapsule
l'utilisation de Neo4j pour les tests d'intégration via son
[implémentation
spécifique](http://docs.neo4j.org/chunked/stable/tutorials-java-unit-testing.html))

Conclusion
==========

Un autre archetype Maven devrait suivre pour l'interfaçage REST de
Neo4j.  L'archetype décrit ici sera bientôt releasé sur Maven Central.
En attendant, vous pouvez déjà l'utiliser et démarrer avec Neo4j sur des
bases saines !
---
layout: post
---
Recommandations de collègues
============================

Rappel de l'épisode précédent
-----------------------------

L'exercice posé en fin d'article précédent, dans le cadre d'un moteur de
recommandations pour un réseau social professionnel, était le suivant : 

*"trouve-moi tous les contacts de mes contacts, qui connaissent (sont en
contact avec) quelqu'un avec qui j'ai déjà travaillé (avec qui je ne
suis pas déjà en contact)"*

Petit rappel du graphe :

-   les utilisateurs auront un label `CONTACT`

-   les entreprises auront un label `COMPANY`

-   les noeuds ont (pour simplifier) une propriété name qui contient nom et prénom

-   le fait d'être en contact est matérialisé par 
```
(:CONTACT)-[:IN_CONTACT_WITH]-(:CONTACT)
```

-   le fait de travailler pour une entreprise s'écrit : 
```
(:CONTACT)-[:WORKED_IN]->(:COMPANY)
```

Envisageons le problème avec humilité, et tâchons de le résoudre bloc
par bloc.

Anciens collègues
-----------------

Trouvons donc mes anciens collègues :

``` {.cypher}
MATCH (me:CONTACT)-[:WORKED_IN]->(:COMPANY)<-[:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name}
RETURN me, colleagues
```

Pas mal, mais je voudrais éviter d'inclure ceux avec qui je suis déjà en
contact.

Pour se faire, il suffit de vérifier l'absence de la relation entre les
collègues et moi :

``` {.cypher}
MATCH (me:CONTACT)-[:WORKED_IN]->(:COMPANY)<-[:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
RETURN me, colleagues
```

Allons encore plus loin : vous ne souhaitez maintenant en résultat que
les collègues qui ont travaillé dans l'entreprise en même temps que
vous. En d'autres termes, les personnes qui ont terminé (voire pas
terminé) leur contrat après vos débuts et qui ont commencé avant que
vous partiez (pour peu que vous soyez parti).

Ici, les spécifications ne sont pas complètes, vous retournez donc vers
les autorités compétentes et en concluez que cette notion de date est
portée par la relation `WORKED_IN`, avec deux attributs de type timestamp
: beginning et end (end est optionnel si le collègue y travaille
toujours). Pratique d'avoir des propriétés sur les relations, non ?

Maintenant, les deux relations `WORKED_IN` nous intéressent puisqu'elles
représentent respectivement vos dates de présence et les dates de
présence de vos collègues dans les entreprises communes. Profitons-en,
d'ailleurs, pour séparer le `MATCH` en deux sous-patterns, afin
d'améliorer la lisibilité de la requête.

``` {.cypher}
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
RETURN me, colleagues
```

Exprimons maintenant les contraintes de chevauchement :

``` {.cypher}
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
AND myStay.beginning < theirStay.end
AND theirStay.beginning < myStay.end
RETURN me, colleagues
```

... sans oublier le fait que les personnes peuvent encore être présentes
dans l'entreprise (auquel cas la propriété end ne sera tout simplement
pas renseignée).

``` {.cypher}
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
AND (NOT HAS(theirStay.end) OR myStay.beginning < theirStay.end)
AND (NOT HAS(myStay.end) OR theirStay.beginning < myStay.end)
RETURN me, colleagues
```

Filtrage des collègues par contact
----------------------------------

Maintenant que avons sous la main une requête de taille déjà
relativement importante, deux stratégies se présentent pour continuer :

1.  nous continuons à l'enrichir au risque de la rendre complètement
    spécifique et potentiellement illisible

2.  nous la chaînons avec une autre-requête

Vous l'aurez compris, nous allons privilégier la seconde piste. De plus,
cela va nous permettre d'introduire la clause `WITH`, qui agit à l'instar
d'un "pipe" qui sert de glue entre différentes commandes sous Unix.

Deux éléments nous intéressent dans la requête précédente, ceux qui sont
spécifiés dans la clause `RETURN`. Afin de pouvoir les réutiliser dans la
requête suivante, nous allons simplement remplacer `RETURN` par `WITH` et
filtrer par collègues :

``` {.cypher}
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
AND (NOT HAS(theirStay.end) OR myStay.beginning < theirStay.end)
AND (NOT HAS(myStay.end) OR theirStay.beginning < myStay.end)
WITH me, colleagues
WHERE (me-[:IN_CONTACT_WITH]-(:CONTACT)-[:IN_CONTACT_WITH]-colleagues)
RETURN me, colleagues
```

Sympa, non ?

Allez, une dernière pour la route : pour que de retourner n associations
1-1 comme c'est le cas actuellement, les autorités compétentes m'ont
demandé de directement retourner une association 1-n avec les collègues
triés par nom. Autrement dit : retourner la collection agrégée de
collègues.

Petite subtilité : rien ne vous garantit l'ordre des collègues qui vous
a été retourné. Nous pouvons utiliser la clause `ORDER BY` juste après
`WITH`, afin de s'assurer que les collègues sont triés (l'opération de
filtrage qui suit n'y changera rien).

``` {.cypher}
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
AND (NOT HAS(theirStay.end) OR myStay.beginning < theirStay.end)
AND (NOT HAS(myStay.end) OR theirStay.beginning < myStay.end)
WITH me, colleagues
ORDER BY colleagues.name
WHERE (me-[:IN_CONTACT_WITH]-(:CONTACT)-[:IN_CONTACT_WITH]-colleagues)
RETURN me, colleagues
```

Reste maintenant à agréger :

``` {.cypher}
MATCH (me:CONTACT)-[myStay:WORKED_IN]->(company:COMPANY),
company<-[theirStay:WORKED_IN]-(colleagues:CONTACT)
WHERE me.name = {name} AND NOT (me-[:IN_CONTACT_WITH]-colleagues)
AND (NOT HAS(theirStay.end) OR myStay.beginning < theirStay.end)
AND (NOT HAS(myStay.end) OR theirStay.beginning < myStay.end)
WITH me, colleagues
ORDER BY colleagues.name
WHERE (me-[:IN_CONTACT_WITH]-(:CONTACT)-[:IN_CONTACT_WITH]-colleagues)
```

Et le tour est joué !

Les avantages d'avoir découpé la requête comme suit sont multiples :

-   la requête, découpée en blocs distincts, est nettement plus lisible

-   elle est également plus maintenable puisque chaque bloc se voit
    confier une partie bien identifiée du problème à résoudre

-   et surtout, puisque l'on retourne toujours le contact concerné et
    ses suggestions de contact, je peux me permettre d'opérer à la "fire
    and forget" puisque le résultat de la requête contient tout le
    contexte nécessaire à son interprétation

Le mot de la fin
----------------

Et dire que Cypher a démarré comme une idée de time-off. Il y a 1.5 ans
(version Neo4J 1.4 ou 1.5), seules des requêtes assez limitées et en
lecture étaient possibles. Ce langage ne cesse de m'enthousiasmer : il
reste vraiment accessible aux néophytes et son éventail d'opérations
possibles va bientôt faire de lui un langage Turing-Complete :-)

Qu'on se le dise, Cypher va devenir la voie privilégiée pour requêter de
la donnée sur Neo4j. Cela est somme toute logique, on attend d'une base
de données qu'elle offre un langage de requêtage.

Reste peut-être un dernier chaînon pour compléter le tableau presque
parfait : un protocole d'échange avec moins d'overhead que l'API REST
standard pour communiquer avec une instance Neo4j distante, comme le
déplorait [Sébastien Deleuze](https://twitter.com/sdeleuze) lors d'un
échange à Soft-Shake.

Le prochain article aura pour thème : Neo4J sous le capot.

Post-Scriptum : un jeu de données pour vérifier la requête
----------------------------------------------------------

Essayez donc la requête finale sur <http://console.neo4j.org> et les
requêtes intermédiaires en remplaçant `{name}` par 'Florent' sur le jeu
de données fourni ci-dessous.
---
layout: post
title: "Ne remets pas à deux mains ce que tu peux faire à quatre"
---
Comme tout le monde, j'avais déjà entendu parler de TDD. La première
fois que j'y ai été confronté fut lors de mon entretien d'embauche pour
la société que j'ai rejoint ensuite : [Lateral
Thoughts](http://www.lateral-thoughts.com/), société de service
innovante toute jeune fondée par
[Jean-Baptiste Lemée](https://twitter.com/jblemee),
[Hugo Lassiège](https://twitter.com/hugolassiege) et [Olivier
Girardot](https://twitter.com/#%21/ogirardot) (promis : je ne bullshite
pas). Hé oui, en entretien d'embauche, j'ai codé ! Mais aussi entendu :
\"mais pourquoi n'écris-tu pas un premier test ?". Et là, d'un coup,
d'un seul, le déclic a eu lieu : j'ai entrevu la puissance d'une telle
approche et ses premières difficultés d'adoption; à savoir : se défaire
de la notion de propriété (ceci n'est pas **mon** code) et se forcer à
n'écrire que le strict minimum (Keep It Simple, Stupid!).

Vint ensuite [le challenge
CodeStory](/2012/02/18/Anonymous-Driven-Development.html). Évidemment,
ni [Pierre-Yves Ricau](https://twitter.com/piwai) (aka Piwaï) ni
moi n'y sommes allés complètement à l'improviste. 

Connaissant un petit
peu le niveau des organisateurs
[David Gageot](https://twitter.com/dgageot) et [Jean-Laurent de
Morlhon](https://twitter.com/#%21/morlhon), nous nous entraînés à
(essayer d') aller plus vite : apprentissage des raccourcis d'Eclipse,
démarrage rapide sur des technos particulières. Cela a représenté une
somme de travail assez conséquente, mais le fait d'être à deux a
beaucoup aidé.

Enfin, pendant l'[Android Dev Camp de
Paris](http://www.paug.fr/evenement-android/paris-android-dev-camp-2012-projets-open-data/)
(que Piwaï a remporté avec son équipe, au passage), je décidais de me
créer mon propre challenge, tout content des choses apprises pendant
CodeStory : un randori d'un week-end sur un projet personnel (plus
d'infos bientôt) qui ne faisait que trop traîner. une vingtaine de
sessions de 25 minutes chacune, en pur TDD et à deux. Très clairement,
je n'aurais pas suivi ce rythme tout seul. J'espère publier bientôt le
retour d'expérience de [Jérémy
Hagneré](http://www.linkedin.com/pub/j%C3%A9r%C3%A9my-hagnere/41/540/499)
avec qui j'ai travaillé tout le week-end. Cela est d'autant plus
intéressant que Jérémy partait d'un niveau scolaire en Java.


Quelques outils
===============

Ayant toujours travaillé avec Eclipse, cet IDE est resté le choix par
défaut. Il a toutefois été complété de quelques fonctionnalités bien
sympathiques fournies par les plug-ins suivants :

-   [MoreUnit](http://moreunit.sourceforge.net/), un outil simple qui
    permet de passer facilement d'une classe à sa classe de tests et
    offre plein d'autres petits raccourcis qui vous changent la vie

-   [InfiniTest](http://infinitest.github.com/), maintenu par [notre
    chatonphile national](https://github.com/dgageot/kittenmash/), qui
    traque les moindres changements de code susceptibles d'influer les
    résultats de vos tests et les rejoue pour vous le cas échéant (c'est
    le plugin qui traque, pas le chatonphile, hein)

-   [EclEmma](http://www.eclemma.org/) ou
    [eCobertura](http://ecobertura.johoop.de/) sont deux plugins très
    similaires qui vous rapportent le pourcentage de code par vos tests
    (funny fact: EclEmma considère les lignes d'où sont lancées des
    exceptions non couvertes, même si un test associé couvre cette
    éventualité)

-   [PairHero](http://www.happyprog.com/pairhero/) est sans doute un des
    outils les plus ludiques : calqué sur
    [Pomodoro](http://en.wikipedia.org/wiki/Pomodoro_Technique) et TDD,
    il vous permettra de coder & stresser à deux en vous amusant.

Mais ça ne s'arrête pas là ! Sans maîtrise, la puissance n'est rien,
comme dirait l'autre. Par le biais de ces sessions d'entraînement, mon
partenaire et moi veillons à être le plus efficace possible avec l'IDE,
c'est-à-dire apprendre à bien maîtriser ses raccourcis (qui varient
évidemment d'une plate-forme à l'autre, sinon, ce serait trop simple).

Bien que Ctrl+1\* (MAC: Cmd+1) soit vraiment le couteau suisse du
*serial refactorer*, les plus intéressants à retenir selon moi sont les
raccourcis liés aux extractions (extraction de variable locale, de
méthodes...​). Lorsque vous faites face à un code monolithique, vous
verrez que ce genre de raccourci vous permettra de modifier votre code
de façon beaucoup plus *safe* (mais vu que vous aurez écrit tous les
tests pour couvrir l'existant, vous verrez vite si ça pète, non ?).

On me souffle même dans l'oreillette que la première chose qu'aurait
fait David Gageot avant de passer à IntelliJ IDEA aurait été d'apprendre
ses raccourcis.

\*bien comprendre que sur un clavier PC français il faut appuyer sur
Shift pour obtenir un 1, sinon, j'aurais écrit Ctrl+& bien sûr ;)

Méthodos
========

TDD
---

Tout le monde connait cette approche ou croit la connaître. Et pour
cause, l'approche proposée tient en quelques étapes et il est très
facile de minimiser l'importance de certaines d'entre elles:

1.  écrivez un test qui ne passe pas (il faut qu'il compile tout de
    même)

2.  exécutez-le et constatez son échec

3.  écrivez le code minimal et \"production-ready\" qui fait passer le
    test (baby step)

4.  constatez sa réussite sinon repassez au 3

5.  nettoyez si nécessaire le code tout en vous assurant que les tests
    passent toujours  

6.  revenez à l'étape 1 jusqu'à ce que tous les cas de tests soient
    couverts

Conclusion: TDD, c'est juste écrire les tests en premier ?

Que nenni, camarade ! Pour citer [Ugo
Bourdon](https://twitter.com/#%21/ugobourdon), un Test-Driven Developer
bien plus aguerri que moi: \"Je ne teste jamais, je fais du TDD." Vous
voyez la nuance ? Le but n'est pas d'atteindre 100% de couverture de
tests ou d'exploser les stats de téléchargement d'Infinitest. Non, le
but premier, commun à tous, est de produire du code qui peut partir en
production le plus rapidement possible.

Et bien sûr, cela dépend de la Définition de Fini que vous vous fixez.
Mais il ne semble pas incongru de définir au minimum les contraintes
suivantes:

-   le code fonctionne

-   le code est lisible

-   n'importe quelle fonctionnalité est remplaçable/ajoutable en un
    minimum de changements

-   toute régression est détectée le plus vite possible

Comme vous pouvez le voir, le mot \"test\" n'apparaît nulle part dans
ces contraintes. Le test n'est qu'un moyen de se prémunir contre les
bugs, un rempart contre les effets de bord et donc : un facilitateur de
changements. Il devient presque indispensable à partir du moment où vous
n'êtes plus le seul à travailler sur un projet (et qui vous dit que
quelqu'un d'autre ne vous remplacera pas par la suite, de toutes façons
?).

Si vous codez comme un
[gougnafier](http://fr.wiktionary.org/wiki/gougnafier), votre code
restera de qualité déplorable et buggé. Déterminer les bons tests, faire
en sorte que le code soit lisible est toujours de votre responsabilité.
TDD vous aide juste à déterminer plus rapidement que votre code se
détériore et vous aide donc à le corriger plus vite.

À deux, c'est mieux !
---------------------

J'espère que tout le monde passera outre la proximité de ce titre avec
ma comparaison précédente :)

### Intérêts

Les avantages naturels du pair-programming sont les suivants :

-   le code est écrit par deux personnes, le sentiment de propriété est
    donc moins fort et les remises en cause plus aisées

-   chacun s'expose à l'autre et tend à lui montrer ce qu'il peut faire
    de mieux (émulation)

-   les failles de raisonnement et fautes d'inattention doivent faire
    face à une paire d'yeux supplémentaire et se trouvent donc fortement
    réduites

-   chaque personne est responsable de l'équipe, et l'envie d'abandonner
    pénalise deux personnes au lieu d'une, ce qui explique pourquoi
    travailler à deux est bien plus motivant

En résumé, travailler à deux, c'est un ping-pong permanent, une
[dissonance
cognitive](http://fr.wikipedia.org/wiki/Dissonance_cognitive) réduite
bien plus vite et un partage des connaissances et une envie d'essayer
accrues.


### Les pièges

Mais sachez qu'il existe de nombreuses possibilités de configuration
pour programmer en paire **inefficacement**, comme l'explique
l'excellent post [\"Mechanics of Good
Pairing\"](http://www.nomachetejuggling.com/2011/08/25/mechanics-of-good-pairing/)
dont je ne peux que vous recommander la lecture.

Afin de pas tomber dans l'écueil du \"pépère-programming\", je me suis
toujours installé de la façon suivante :

![image](http://www.nomachetejuggling.com/files/level4.png)

Dans cette configuration, il n'existe qu'une seule machine (+ 1 machine
commune pour les recherches) avec affichage en miroir sur deux écrans,
un clavier et une souris chacun. Chacun est donc installé comme s'il
était seul et peut donc intervenir à tout moment (plus d'effets \"bras
croisés\" donc). Les deux personnes restent maîtres en même temps d'un
seul et même code.

Si vous êtes joueur, je vous conseille de pimenter l'exercice avec
PairHero. Le workflow décrit précédemment devient :


1.  le codeur A écrit un test qui ne passe pas

2.  PairHero donne la main au codeur B qui écrit le code qui fait passer
    le test (+10 points!)

3.  le codeur refactore le code si besoin (+2 par refactor!)

4.  le codeur B écrit un nouveau test qui ne passe pas

5.  PairHero donne la main au codeur A qui écrit le code suffisant pour
    que le test passe (+10 points!)

6.  le codeur refactore le code si besoin

7.  retour à l'étape 1 et ainsi de suite pendant 25 minutes

Sympathique, n'est-ce pas ?

To be continued
===============

J'ai eu l'occasion de discuter sur ce sujet avec mon responsable en
mission qui était vraiment très réfractaire à ce genre de pratiques. Il
avait en fait l'image d'un pair-programming qui n'en est pas un (voir
les niveaux \< 2 de [l'article cité plus
haut](http://www.nomachetejuggling.com/2011/08/25/mechanics-of-good-pairing/)).

Néanmoins, avec mon enthousiasme non dissimulé et en faisant
l'association TDD \<-> pair-programming, j'ai réussi à le convaincre
d'essayer dans notre équipe de projet dès la semaine prochaine. Dans le
même temps, j'animerais un petit atelier sur un Kata classique afin de
mettre mes coéquipiers à l'épreuve, et je l'espère, convaincre les
réfractaires (s'il y en a).

Ce sera donc ma première expérience de pair-programming avec des
personnes que je connais peu.

Donc non, le pair-programming/TDD en entreprise n'est pas mort !

Stay tuned et banzai !
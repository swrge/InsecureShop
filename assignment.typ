#let accent = rgb("#1f3a5f")
#let clair = rgb("#eef3fb")

#set document(title: "TP J3 — Audit statique d’InsecureShop")
#set page(
  paper: "a4",
  margin: (x: 2cm, top: 2.4cm, bottom: 2cm),
  header: context {
    if counter(page).get().first() > 1 { text(size: 9pt, fill: luma(110))[
      Master 2 • Sécurité des plateformes mobiles • TP J3
    #h(1fr) Audit statique d’InsecureShop
  ]}},
  numbering: "1 / 1",
)
#set text(lang: "fr", size: 10.5pt)
#set par(justify: true, leading: 0.65em)

#show heading.where(level: 1): it => block(
  width: 100%,
  above: 1.8em,
  below: 0.9em,
  sticky: true,
  stroke: (bottom: 0.8pt + accent),
  inset: (bottom: 4pt),
  text(fill: accent, size: 14pt, weight: "bold", it.body),
)
#show heading.where(level: 2): it => block(
  above: 1.4em,
  below: 0.7em,
  sticky: true,
  text(fill: accent, size: 12pt, weight: "bold", it.body),
)
#show raw.where(block: true): it => block(
  width: 100%,
  fill: luma(245),
  inset: 8pt,
  radius: 3pt,
  it,
)

// ---------- Composants réutilisables ----------

// Encadré d'information
#let note(titre, corps) = block(
  width: 100%,
  fill: clair,
  stroke: (left: 3pt + accent),
  inset: 9pt,
  radius: (right: 3pt),
  breakable: false,
)[
  #text(weight: "bold", fill: accent)[#titre] \
  #corps
]

// Question + zone de réponse (à compléter via `rep:`)
#let question(rep: none, h: 2cm, corps) = block(breakable: false, width: 100%, above: 1em)[
  #block(width: 100%, fill: clair, inset: 8pt, radius: (top: 3pt))[
    *Question.* #corps
  ]
  #block(
    width: 100%,
    height: if rep == none { h } else { auto },
    inset: 8pt,
    stroke: (paint: luma(170), dash: "dashed"),
    radius: (bottom: 3pt),
  )[
    #if rep == none [
      #text(fill: luma(150), size: 9pt, style: "italic")[Votre réponse…]
    ] else [#rep]
  ]
]

// Tableau à compléter
//  entetes   : liste des titres de colonnes
//  lignes    : nombre de lignes vides
//  hauteur   : hauteur minimale d'une ligne
//  largeurs  : largeurs des colonnes (optionnel)
//  pre       : contenu pré-rempli de la 1re colonne (optionnel)
//  remplir   : contenu par défaut d'une colonne, ex. ("1": [☐ Oui   ☐ Non])
//  insecable : true = le tableau n'est jamais coupé entre deux pages
#let grille(entetes, lignes: 4, hauteur: 1.5cm, largeurs: none, pre: (), remplir: (:), insecable: true) = {
  let n = entetes.len()
  let cols = if largeurs == none { (1fr,) * n } else { largeurs }
  let cellules = ()
  for i in range(lignes) {
    for j in range(n) {
      if j == 0 and i < pre.len() { cellules.push(pre.at(i)) }
      else if str(j) in remplir { cellules.push(remplir.at(str(j))) }
      else { cellules.push([]) }
    }
  }
  block(breakable: not insecable, width: 100%)[
    #set par(justify: false)
    #table(
      columns: cols,
      rows: (auto,) + (hauteur,) * lignes,
      stroke: 0.5pt + luma(150),
      inset: 6pt,
      align: left + top,
      fill: (_, y) => if y == 0 { accent } else if calc.odd(y) { luma(250) } else { white },
      table.header(..entetes.map(h => text(fill: white, weight: "bold", size: 9pt, h))),
      ..cellules,
    )
  ]
}

// Fiche de constat (Mission 14)
#let fiche(n) = {
  let champs = (
    ("Titre", 1cm),
    ("Composant affecté", 1cm),
    ("Description", 2.6cm),
    ("Preuve précise (classe / méthode / Manifest)", 2.6cm),
    ("Scénario de risque", 2.3cm),
    ("Impact", 1.7cm),
    ("Vraisemblance", 1.2cm),
    ("Criticité argumentée", 1.8cm),
    ("Recommandation", 2.2cm),
    ("Limite de l’analyse", 1.8cm),
  )
  [== Constat n°#n]
  table(
    columns: (4.2cm, 1fr),
    rows: champs.map(c => c.at(1)),
    stroke: 0.5pt + luma(150),
    inset: 6pt,
    align: left + top,
    ..champs.map(c => (table.cell(fill: luma(236))[*#c.at(0)*], [])).flatten(),
  )
}

// ---------- Page de titre ----------

#align(center)[
  #v(0.3em)
  #text(size: 22pt, weight: "bold", fill: accent)[TP J3 — Audit statique d’InsecureShop]
  #v(0.2em)
  #text(size: 12pt, style: "italic")[Étude d’une nouvelle application Android volontairement vulnérable]
]

#v(0.8em)

#table(
  columns: (3.5cm, 1fr, 3.5cm, 1fr),
  stroke: 0.5pt + luma(150),
  inset: 7pt,
  fill: (x, _) => if calc.even(x) { luma(236) } else { white },
  [*Nom(s)*], [], [*Groupe*], [],
  [*Date*], [], [*Version de l’APK*], [],
)

#v(0.6em)

#note("Mission")[
  Vous intervenez comme auditeurs pour examiner InsecureShop, une application Android de démonstration.
  Votre objectif est de comprendre sa surface d’attaque, de croiser les observations de plusieurs outils et
  de formuler des constats étayés. Vous ne disposez initialement que de l’APK : *n’ouvrez pas le code source
  du dépôt avant la fin de vos investigations.*
]

#v(0.5em)

#note("Périmètre")[
  Uniquement l’APK InsecureShop et votre environnement local de laboratoire. Pas de tests sur des services
  tiers, pas d’exfiltration de données, pas d’exploitation de failles hors de ce périmètre. Le J3 porte sur
  l’analyse statique ; les essais d’exécution approfondis sont réservés au J4.
]

// ---------- Mission 1 ----------
#pagebreak()

= Mission 1 — Préparer l’environnement et récupérer l’APK

Ouvrez le dépôt officiel du projet : https://github.com/hax0rgb/InsecureShop. Accédez à la rubrique Releases :
https://github.com/hax0rgb/InsecureShop/releases. Téléchargez le fichier APK proposé. Si aucun APK n’est
disponible dans la version sélectionnée, utilisez la release pédagogique historique : InsecureShop v1.0 (archive).

Placez le fichier dans un dossier de travail dédié. Vérifiez son nom, sa taille et calculez son empreinte
SHA-256. Sur Windows :

```
certutil -hashfile InsecureShop.apk SHA256
```

Sur Linux/macOS :

```
sha256sum InsecureShop.apk
```

#grille(
  ("Fichier APK", "Version / source", "Empreinte SHA-256"),
  lignes: 2,
  hauteur: 1.6cm,
  largeurs: (1fr, 1fr, 1.6fr),
)

#question[Pourquoi conserver l’empreinte SHA-256 ?]
#question[Quel est l’intérêt de noter la version exacte de l’APK ?]

// ---------- Mission 2 ----------
#pagebreak()

= Mission 2 — Installer et vérifier les outils

MobSF : dépôt officiel et documentation. JADX : releases officielles. apktool : guide d’installation.
Pour MobSF, utilisez de préférence l’instance de laboratoire fournie par le formateur. Si Docker est disponible
et autorisé, référez-vous à la commande de démarrage à jour du dépôt officiel, plutôt que d’utiliser une
commande copiée d’une source inconnue.

Vérifiez les outils locaux :

```
jadx --version
apktool --version
java -version
```

#grille(
  ("Outil", "Version relevée", "Apport principal"),
  lignes: 4,
  hauteur: 1cm,
  pre: ([MobSF], [JADX], [apktool], [Java]),
)

#question[Qu’apporte chaque outil ?]
#question(h: 1.8cm)[Lequel effectue des contrôles automatisés ?]
#question(h: 1.8cm)[Lequel permet de naviguer dans le code décompilé ?]

#pagebreak()

// ---------- Mission 3 ----------

= Mission 3 — Premier examen de l’APK

Avant de lancer MobSF, identifiez les grandes catégories de fichiers présentes dans l’APK. Une APK est un
conteneur de type ZIP, mais son Manifest est généralement encodé au format binaire Android.

Avec un gestionnaire d’archives, observez *sans modifier* : `classes.dex`, `res/`, `assets/` (si présent),
`lib/` (si présent) et les fichiers liés aux signatures.

#grille(
  ("Élément", "Présent ?", "Utilité supposée"),
  lignes: 7,
  hauteur: 1.1cm,
  largeurs: (1.2fr, 0.9fr, 2fr),
  remplir: ("1": [☐ Oui   ☐ Non]),
  pre: (
    [`AndroidManifest.xml`],
    [`classes.dex`],
    [`res/`],
    [`assets/`],
    [`lib/`],
    [`META-INF/` (signatures)],
    [`resources.arsc`],
  ),
)

#question[Quels fichiers semblent contenir le code ?]
#question[Quels éléments peuvent contenir des chaînes ou configurations sensibles ?]
#question[Pourquoi ne peut-on pas lire directement le Manifest comme un simple XML texte ?]

#pagebreak()
// ---------- Mission 4 ----------
= Mission 4 — Analyse automatisée avec MobSF

Ouvrez l’interface MobSF de votre laboratoire. Importez `InsecureShop.apk` et lancez l’analyse statique.
Notez les métadonnées détectées, les permissions, les composants, les paramètres de sécurité et les
catégories d’alertes. *Ne considérez pas le score comme une preuve suffisante.*

#grille(
  ("Alerte / observation MobSF", "Emplacement indiqué", "À vérifier dans JADX/apktool ?"),
  lignes: 6,
  hauteur: 1.5cm,
)

#question[Quelle version Android minimale et cible est annoncée ?]
#question[Quels composants exportés sont signalés ?]
#question[Quelles alertes nécessitent une confirmation dans le code ?]

#pagebreak()
// ---------- Mission 5 ----------
= Mission 5 — Décoder l’APK avec apktool

Dans le dossier contenant l’APK :

```
apktool d InsecureShop.apk -o InsecureShop_decoded
```

Ouvrez `InsecureShop_decoded/AndroidManifest.xml`. Relevez les permissions, les Activities, Services,
Receivers, Providers, attributs `android:exported`, intent-filters, schemes d’URI et éventuelles options de
debug / backup / cleartext.

#note("Attention")[
  La présence d’un attribut ne suffit pas à conclure à une vulnérabilité ; la version Android et les
  contrôles dans le code comptent aussi.
]

#v(0.6em)

#grille(
  ("Composant / attribut", "Valeur exacte", "Risque potentiel", "Vérification nécessaire"),
  lignes: 8,
  hauteur: 1.5cm,
)

#question[Quels composants peuvent recevoir des intents externes ?]
#question[Quel composant semble lié à une WebView ?]
#question[Quels schémas de deep links sont déclarés ?]

#pagebreak()

// ---------- Mission 6 ----------
= Mission 6 — Explorer le code avec JADX

Ouvrez l’APK dans jadx-gui (ou utilisez la commande suivante). *Ne modifiez pas le code* : l’objectif est de le
lire et de le comprendre.

```
jadx-gui InsecureShop.apk
```

Repérez le package principal, les classes liées à la connexion, aux préférences, aux WebViews, aux Intents et
aux Content Providers. Pour chaque piste, conservez le nom de la classe, de la méthode et une courte citation
de code.

#grille(
  ("Classe / méthode", "Fonction observée", "Contrôle présent ?", "Hypothèse de risque"),
  lignes: 6,
  hauteur: 1.6cm,
)

#question[Comment le code récupère-t-il les données reçues par un Intent ?]
#question[Où la validation est-elle réalisée ?]
#question[Un composant vérifie-t-il l’identité ou les droits de l’appelant ?]

#pagebreak()
// ---------- Mission 7 ----------
= Mission 7 — Rechercher des identifiants et secrets codés en dur

Utilisez la recherche globale JADX avec les termes `password`, `username`, `token`, `api_key`, `secret`,
`credential`. Explorez aussi les ressources décodées et les constantes.

Pour chaque résultat, déterminez s’il s’agit d’un véritable secret, d’une valeur de démonstration, d’un simple
nom de variable ou d’une information non sensible. *Ne publiez ni ne testez des identifiants sur des services
externes.*

#grille(
  ("Chaîne / référence (masquée)", "Emplacement", "Usage probable", "Risque et justification"),
  lignes: 6,
  hauteur: 1.5cm,
)

#question[Pourquoi une clé API visible dans une APK n’est-elle pas automatiquement une vulnérabilité critique ?]

#pagebreak()
// ---------- Mission 8 ----------
= Mission 8 — Deep links : cartographier l’entrée et le traitement
À partir du Manifest, identifiez les intent-filters associés à `VIEW`, `BROWSABLE` et aux schémas d’URI. Dans
JADX, retrouvez les méthodes qui lisent l’URI ou ses paramètres (`getData`, `getQueryParameter`, etc.).

Dessinez un chemin logique : *lien externe → Activity → extraction du paramètre → validation → action.*
Cherchez si l’URL reçue est validée sur la base d’un schéma et d’un hôte exacts ou avec une simple
comparaison de chaîne.

#let etape(titre, aide) = block(
  width: 100%,
  height: 3cm,
  inset: 5pt,
  stroke: (paint: accent, dash: "dashed"),
  radius: 3pt,
)[
  #set par(justify: false)
  #text(size: 8.5pt, weight: "bold", fill: accent)[#titre] \
  #text(size: 7.5pt, fill: luma(140), style: "italic")[#aide]
]

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  column-gutter: 3pt,
  align: horizon + center,
  etape("Lien externe", "schéma, hôte, paramètres…"),
  text(size: 14pt, fill: accent)[→],
  etape("Activity", "nom de la classe"),
  text(size: 14pt, fill: accent)[→],
  etape("Extraction", "getData, getQueryParameter…"),
  text(size: 14pt, fill: accent)[→],
  etape("Validation", "schéma + hôte exacts ?"),
  text(size: 14pt, fill: accent)[→],
  etape("Action", "loadUrl, startActivity…"),
)

#v(0.6em)

#grille(
  ("Deep link / paramètre", "Activity concernée", "Validation identifiée", "Conséquence possible"),
  lignes: 4,
  hauteur: 1.6cm,
)

#question[Quelle différence entre vérifier qu’une chaîne « contient » un domaine et vérifier réellement l’hôte d’une URL ?]
#question[Pourquoi faut-il valider une entrée même lorsqu’elle provient d’un Intent Android ?]

#pagebreak()
// ---------- Mission 9 ----------
= Mission 9 — WebView : identifier les paramètres sensibles

Dans JADX, recherchez `WebView`, `loadUrl`, `setJavaScriptEnabled`, `addJavascriptInterface`,
`setAllowFileAccess`, `setAllowUniversalAccessFromFileURLs` et `onReceivedSslError`.

Pour chaque résultat présent, relevez le contexte. Distinguez un paramètre dangereux isolé d’une combinaison
exploitable avec une URL non fiable. *Ne chargez aucune URL externe et ne tentez aucune lecture de fichiers
privés durant le J3.*

#grille(
  ("API / réglage", "Classe", "Valeur ou traitement", "Risque conditionnel"),
  lignes: 7,
  hauteur: 1.5cm,
  largeurs: (1.5fr, 1fr, 1.3fr, 1.6fr),
  pre: (
    [`WebView` / `loadUrl`],
    [`setJavaScriptEnabled`],
    [`addJavascriptInterface`],
    [`setAllowFileAccess`],
    [`setAllowUniversalAccessFromFileURLs`],
    [`onReceivedSslError`],
    [Autre : ],
  ),
)

#question[Pourquoi JavaScript activé n’est-il pas toujours une vulnérabilité ?]
#question[Pourquoi ignorer une erreur de certificat TLS peut-il devenir grave ?]

#pagebreak()

// ---------- Mission 10 ----------
= Mission 10 — Intents, broadcasts et Content Providers

Repérez les usages de `startActivity`, `sendBroadcast`, `registerReceiver`, `getParcelableExtra` et les classes
héritant de `ContentProvider`.

Recherchez les échanges de données sensibles via des intents implicites, les composants exportés sans
protection et les fournisseurs de données accessibles à d’autres applications. Pour un Provider, examinez la
déclaration dans le Manifest et les vérifications de permissions dans le code.

#grille(
  ("Point d’entrée", "Données manipulées", "Protection trouvée", "Risque envisagé"),
  lignes: 6,
  hauteur: 1.5cm,
)

#question[Pourquoi un Intent implicite contenant un secret est-il risqué ?]
#question[Quelle protection pourrait limiter l’accès à un Content Provider ?]

// ---------- Mission 11 ----------
#pagebreak(weak: true)
= Mission 11 — Stockage local, cryptographie et journalisation
Dans JADX, recherchez `SharedPreferences`, `getSharedPreferences`, `putString`, `SQLite`, `Log.d`, `Log.e`,
`KeyStore`, `Cipher` et `MessageDigest`.

Identifiez les données qui sont stockées, journalisées ou transformées. Notez les protections présentes et les
absences de protection, sans supposer qu’un chiffrement est absent uniquement parce qu’aucune occurrence de
« Cipher » n’apparaît.

#grille(
  ("Donnée / opération", "Classe et méthode", "Protection identifiée", "Risque éventuel"),
  lignes: 6,
  hauteur: 1.5cm,
)

#question[Pourquoi un mot de passe stocké en clair est-il problématique ?]
#question[Quel est l’intérêt d’Android Keystore ?]
#question[Comment distinguer chiffrement et hachage ?]

// ---------- Mission 12 ----------

#pagebreak(weak: true)
= Mission 12 — Bibliothèques et dépendances

Inspectez les packages tiers visibles dans JADX et les fichiers `lib/` ou métadonnées de l’APK. Identifiez les
composants externes possibles. *Ne concluez pas à une CVE sur la seule présence d’un nom de bibliothèque :* une
version exacte et un contexte d’utilisation sont nécessaires.

#grille(
  ("Bibliothèque / SDK", "Indice de version", "Fonction", "Vérification à poursuivre"),
  lignes: 5,
  hauteur: 1.4cm,
)

#question[Quelles informations manquent pour affirmer qu’une dépendance est vulnérable ?]
#question[Quelles précautions prendre avant de reprendre un résultat de scanner dans un rapport ?]

#pagebreak()
// ---------- Mission 13 ----------
= Mission 13 — Recouper les outils et classer les observations

Sélectionnez *au moins huit observations distinctes* issues de vos recherches. Pour chacune, indiquez ce que
MobSF détecte, ce que le Manifest décodé confirme et ce que JADX permet de comprendre. Une absence de
résultat doit être notée comme telle.

#grille(
  ("Observation", "MobSF", "apktool", "JADX", "Confiance"),
  lignes: 9,
  hauteur: 1.7cm,
  largeurs: (1.3fr, 1fr, 1fr, 1fr, 0.8fr),
  insecable: false,
)

== Classement des observations

Classez les observations selon l’une des catégories suivantes et justifiez vos décisions :

- *Confirmée par le code*
- *Hypothèse à tester*
- *Information sans risque démontré*
- *Faux positif probable*

#grille(
  ("Observation (n°)", "Classement", "Justification"),
  lignes: 8,
  hauteur: 1.5cm,
  largeurs: (0.9fr, 1.7fr, 2.3fr),
  remplir: ("1": text(size: 8.5pt)[☐ Confirmée   ☐ Hypothèse \ ☐ Sans risque   ☐ Faux positif]),
  insecable: false,
)

#pagebreak()

// ---------- Mission 14 ----------
= Mission 14 — Rédiger des constats professionnels

Construisez *au moins cinq fiches de constats* sur la base de vos preuves. Un constat doit comporter : titre,
composant affecté, description, preuve précise (classe/méthode/Manifest), scénario de risque, impact,
vraisemblance, criticité argumentée, recommandation et limite de l’analyse.

#note("Rappel")[
  Si vous ne trouvez pas cinq vulnérabilités démontrables, distinguez les constats avérés des hypothèses non
  vérifiées. *Ne créez pas de fausses vulnérabilités pour atteindre un nombre.* Précisez dans chaque fiche s’il
  s’agit d’un constat « avéré » ou d’une « hypothèse non vérifiée ».
]

#fiche(1)
#pagebreak(weak: true)
#fiche(2)
#pagebreak(weak: true)
#fiche(3)
#pagebreak(weak: true)
#fiche(4)
#pagebreak(weak: true)
#fiche(5)

// ---------- Mission 15 ----------

#pagebreak(weak: true)
= Mission 15 — Arbitrage et plan de remédiation

Imaginez que l’équipe de développement ne puisse corriger que *trois problèmes* avant la mise en production.
Sélectionnez vos trois priorités et justifiez-les selon l’impact, l’exposition, la facilité de correction et le
niveau de confiance dans la preuve.

#grille(
  ("Priorité", "Problème", "Pourquoi maintenant ?", "Correction proposée"),
  lignes: 3,
  hauteur: 2.6cm,
  largeurs: (0.7fr, 1.3fr, 1.7fr, 1.7fr),
  pre: ([1], [2], [3]),
)

#question(h: 3.2cm)[
  *Discussion :* un composant exporté sans impact démontré doit-il passer avant une exposition de secrets ?
  La réponse dépend du contexte et des preuves.
]

// ---------- Mission 16 ----------

#pagebreak(weak: true)
= Mission 16 — Préparer les vérifications du J4

Choisissez trois hypothèses que l’analyse statique ne suffit pas à confirmer. Pour chacune, proposez un test
dynamique local et autorisé à réaliser au J4 : objectif, prérequis, résultat attendu, preuve et précautions.

#grille(
  ("Hypothèse J3", "Test prévu J4", "Résultat attendu", "Précaution"),
  lignes: 3,
  hauteur: 3cm,
  pre: ([1], [2], [3]),
)

#v(0.4em)

Exemples de pistes : contrôle d’accès sur une Activity exportée ; traitement d’un deep link avec URL de test
locale ; apparition de données de démonstration dans les logs. *N’effectuez pas encore ces tests.*

#pagebreak()
// ---------- Mission 17 ----------
= Mission 17 — Relecture croisée et bilan

Échangez vos constats avec un autre groupe. Pour chaque constat reçu, demandez-vous : la preuve est-elle
reproductible ? La vulnérabilité est-elle réellement démontrée ? L’impact est-il proportionné ? La
recommandation corrige-t-elle la cause ?

#grille(
  (
    "Constat reçu (groupe / n°)",
    "Preuve reproductible ?",
    "Vulnérabilité démontrée ?",
    "Impact proportionné ?",
    "Recommandation corrige la cause ?",
  ),
  lignes: 5,
  hauteur: 1.5cm,
)

#v(0.6em)

#block(sticky: true)[Terminez en répondant *individuellement* :]

#question[Qu’est-ce que MobSF a trouvé que vous n’aviez pas vu ?]
#question[Qu’est-ce que JADX vous a permis de corriger dans l’interprétation d’une alerte ?]
#question[Quelle limite principale de l’analyse statique retenez-vous ?]

#pagebreak()
// ---------- Ressources ----------
= Ressources de référence

- InsecureShop : https://github.com/hax0rgb/InsecureShop
- MobSF : https://mobsf.github.io/docs
- JADX : https://github.com/skylot/jadx
- apktool : https://apktool.org
- OWASP MASTG : https://mas.owasp.org/MASTG

#v(0.5em)

# 📋 CHANGELOG.md — Journal de Traçabilité du Projet (Antigravity & Jules AI)

Ce fichier garde une **trace exacte et chronologique de chaque ajout ou modification** effectuée sur le jeu (que ce soit en local avec **Antigravity** ou sur GitHub avec **Jules AI**).
En cas de bug plus tard, ce journal permet d'identifier immédiatement **quel fichier** et **quel commit Git** est responsable, et comment le tester ou l'annuler.

---

## 🛠️ Comment revenir en arrière en cas de problème ?

- **Voir toutes les dernières modifications** : `git log --oneline -n 10`
- **Voir ce qui a changé dans un commit précis** : `git show <ID_COMMIT>`
- **Annuler un commit précis sans perdre le reste** : `git revert <ID_COMMIT>`
- **Restaurer un seul fichier à son état précédent** : `git checkout <ID_COMMIT>~1 -- chemin/du/fichier`

---

## 📅 Historique des Ajouts & Modifications

### `[AGY-014]` — 2026-10-12 — Arrivée des Noxiens par le bas ("de l'autre côté") & Suppression des rochers sous l'échelle de corde
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes (`Pictures` / `Tilesets`) & Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers modifiés** :
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png`, `Graphics/Pictures/Autel_Anivia_Vide.png`, `Graphics/Tilesets/SubTileset_2_Sanctuaire_DemiDieux.png` (Suppression des 4 blocs de pics/rochers situés derrière l'Œuf pour dégager à 100% la zone d'atterrissage de l'échelle de corde)
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` (Arrivée de Valerius et de ses 2 soldats par le bas de l'écran en montant vers l'Œuf `dir = 8`, positionnement à gauche et à droite de l'Œuf au-dessus de la boîte de dialogue, et déploiement de l'échelle sur la neige 100% dégagée à `x = spr.x + 92`)
- **Comment tester en jeu** :
  - Lancer le jeu (**New Game**) : les 3 Noxiens arrivent par le bas du plateau enneigé (au lieu de surgir de la falaise du haut), et l'échelle de corde se déroule sur la neige dégagée sans aucun rocher en dessous.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

### `[AGY-013]` — 2026-10-12 — Ralentissement global de toutes les animations de la cinématique (personnages, montée à l'échelle, grand treuil, dirigeable et fondus)
- **Auteur** : `Antigravity`
- **Catégorie** : Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers modifiés** :
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` :
    - **Cadence des pas & marche des personnages** : Marche d'arrivée ralentie de `45` à **`140` frames** (`0.75 px/frame`), cadence des jambes passée de `6` à **`14` frames/pas**, sauts ralentis de `12` à **`28` frames`.
    - **Échelle de corde & montée à bord** : Déroulage en **`70` frames**, marche jusqu'à l'échelle en **`95` frames**, montée barreau par barreau ralentie à **`185` frames** (`0.88 px/frame`), rétractation en **`60` frames** avec pauses naturelles entre chaque étape.
    - **Grand Treuil qui saisit l'Œuf d'Anivia** : Descente ralentie à **`130` frames**, ajout d'une séquence de verrouillage des pinces sur l'Œuf (**`55` frames** de pause dramatique au sol), et remontée lourde de l'Œuf ralentie à **`220` frames**.
    - **Dirigeable & fondus** : Arrivée et fuite ralenties à **`260` frames** avec courbe en S douce (`t²(3-2t)`), secousses d'explosion allongées à **`95` frames`, et fondus au noir passés de `25` à **`65` frames**.
- **Comment tester en jeu** :
  - Lancer le jeu (**New Game**) : toutes les animations (marche des Noxiens, montée à l'échelle, descente/verrouillage/remontée du treuil et vol du Dirigeable) se déroulent à un rythme posé et naturel.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

### `[AGY-012]` — 2026-10-12 — Suppression des mini-œufs parasites, rochers et tas de neige + Plaques de glace vive & Glace pure issue de l'Œuf d'Anivia
- **Auteur** : `Antigravity` (après validation de l'utilisateur)
- **Catégorie** : Graphismes (`Pictures` / `Tilesets`)
- **Fichiers modifiés** :
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png` (`512×384 px` — Suppression totale des petits cristaux-œufs `32×32`, des rochers ronds et des tas de neige ; ajout de plaques de glace vive fissurée et du socle de glace pure turquoise issu directement de la base de l'Œuf d'Anivia)
  - `Graphics/Pictures/Autel_Anivia_Vide.png` & `Graphics/Tilesets/SubTileset_2_Sanctuaire_DemiDieux.png` (Mise à jour du nid avec uniquement la glace pure d'Anivia et les grands pics de glace)
- **Comment tester en jeu** :
  - Lancer le jeu (**New Game**) : le sommet ne comporte plus aucun petit œuf ni rocher parasite, et lorsque l'Œuf d'Anivia est soulevé, seule sa glace pure turquoise reste incrustée dans la plaque gelée.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

### `[AGY-011]` — 2026-10-12 — Tremblement d'écran réel à l'enlèvement de l'Œuf & Repositionnement de l'Œuf au-dessus de la boîte de dialogue (`Y = 166..286`)
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes (`Pictures`) & Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers modifiés** :
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` (Ajout du tremblement réel du Viewport de la cinématique `@viewport.ox` / `@viewport.oy` avec `trigger_shake!` et `continuous_rumble` dès que l'Œuf est arraché de son nid et à chaque coup de tonnerre/explosion, et repositionnement de l'Œuf à `Y = 166..286` au sol et `Y = 128..282` sous le Dirigeable pour qu'il reste toujours 100% au-dessus de la boîte de texte `Y = 288..384`)
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png`, `Dirigeable_Noxus_1_Vol.png`, `Dirigeable_Noxus_2_Capture.png`, `Dirigeable_Noxus_3_Explosion.png` (Ajustement vertical du nid enneigé et de la hauteur d'attache du treuil pour ne jamais être recouvert par la boîte de dialogue)
- **Comment tester en jeu** :
  - Lancer le jeu (**New Game**) : le texte en bas ne cache plus jamais l'Œuf (ni au sol ni en l'air), et tout l'écran tremble violemment dès que le treuil arrache l'Œuf.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

### `[AGY-010]` — 2026-10-12 — Agrandissement de l'Œuf (+50%) & du Dirigeable (+35%), Échelle de corde d'embarquement, Grand Treuil (Œuf 100% visible) & Tonnerres/Éclairs
- **Auteur** : `Antigravity` (après validation de l'utilisateur)
- **Catégorie** : Graphismes (`Pictures` / `Characters`) & Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers modifiés** :
  - `Graphics/Pictures/Oeuf_Anivia_Seul.png` (`144×120 px` — Œuf d'Anivia agrandi de +50%)
  - `Graphics/Characters/!Oeuf_Anivia.png` (`576×480 px` — Planche d'événement 4×4 agrandie à `144×120 px` par frame)
  - `Graphics/Pictures/Dirigeable_Grappin_Oeuf.png` (`156×154 px` — Grand Treuil mécanique à doubles chaînes dorées, large palonnier rouge/or et grandes pinces d'acier entourant l'Œuf complet de `144×120 px`)
  - `Graphics/Pictures/Dirigeable_Noxus_1_Vol.png`, `Dirigeable_Noxus_2_Capture.png`, `Dirigeable_Noxus_3_Explosion.png` (`346×308 px` — Dirigeable agrandi de +35%, ballon 100% visible sans coupure en haut, et Grand Œuf complet suspendu sous la coque)
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png` (`512×384 px` — Nid enneigé ajusté pour laisser tout l'espace vertical au Grand Treuil)
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` (Ajout de `pbDirigeableNoxus_EmbarquementEchelle` où une échelle de corde se déroule depuis le pont et les 3 Noxiens grimpent les barreaux de dos jusqu'à la cabine sans téléportation, treuillage de l'Œuf complet devant la coque, et ajout des coups de tonnerre/éclairs ramifiés `strike_thunder!` dans `NoxusSnowStorm`)
- **Comment tester en jeu** :
  - Lancer le jeu et choisir **New Game**.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

### `[AGY-009]` — 2026-10-12 — Montagnes pointues complètes (sans coupure) + Neige en continu & Vraie Tempête Blizzard à l'enlèvement de l'Œuf
- **Auteur** : `Antigravity` (après validation de l'utilisateur)
- **Catégorie** : Graphismes (`Pictures` / `Tilesets`) & Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers modifiés** :
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png` (`512×384 px` — Chaîne de vraies montagnes pointues enneigées sur 2 plans sans coupure ni bloc blanc vide, et neige continue sans démarcation carrée au sol)
  - `Graphics/Pictures/Autel_Anivia_Vide.png` & `Graphics/Tilesets/SubTileset_2_Sanctuaire_DemiDieux.png` (Neige uniforme sans raccord visible autour du nid)
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` (Ajout de la classe `NoxusSnowStorm` : neige douce en continu dès le début de la cinématique, puis déclenchement immédiat d'une **vraie tempête de neige / blizzard** avec 160 flocons rapides en diagonale, 28 rafales de vent glacé, voile de givre et bruit de vent hurlant dès l'instant où l'Œuf d'Anivia est soulevé de son nid)
- **Comment tester en jeu** :
  - Lancer le jeu et choisir **New Game** : il neige sur le sommet aux montagnes pointues, et dès que la pince soulève l'Œuf d'Anivia, la tempête de neige s'intensifie violemment en blizzard.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

### `[AGY-008]` — 2026-10-12 — Toit de la Montagne Enneigée avec Pics de Glace & Extension du Sous-Tileset 2 (`256×2400`)
- **Auteur** : `Antigravity` (après validation de l'utilisateur)
- **Catégorie** : Graphismes (`Tilesets` & `Pictures`)
- **Fichiers modifiés** :
  - `Graphics/Tilesets/SubTileset_2_Sanctuaire_DemiDieux.png` (`256×2400 px` — Remplacement du cercle sci-fi en `Y=0..128` par le sommet enneigé entouré de pics de glace avec/sans l'Œuf d'Anivia, conservation de `Y=128..640` et extension complète en `Y=640..2400` avec grottes de glace, falaises enneigées, cathédrale de glace, portes géantes, sapins et ciel étoilé, 100% détouré sans croix rouges `X`)
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png` (`512×384 px` — Décor plein écran du toit de la montagne enneigée avec pics de glace, falaises et ciel étoilé de Freljord)
  - `Graphics/Pictures/Autel_Anivia_Vide.png` (`128×128 px` — Nid enneigé entouré de pics de glace laissé au sommet après l'enlèvement de l'Œuf)
- **Comment tester en jeu** :
  - Lancer le jeu et choisir **New Game** pour voir directement la cinématique sur le toit de la montagne enneigée, ou utiliser `SubTileset_2_Sanctuaire_DemiDieux.png` dans l'éditeur de cartes RPG Maker XP.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour restaurer la version précédente des 3 fichiers PNG.

---

### `[AGY-007]` — 2026-10-12 — Décor plein écran du Sanctuaire de Glace (`Fond_Sanctuaire_Glace.png`) & Transition vers le réveil dans la chambre
- **Auteur** : `Antigravity` (après validation de l'utilisateur)
- **Catégorie** : Graphismes (`Pictures`) & Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers ajoutés / modifiés** :
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png` (`512×384 px` — Décor complet de la Caverne de Glace / Sanctuaire d'Anivia avec ciel étoilé en haut, statues des Demi-Dieux, colonnes de glace, gouffre d'aurore boréale et tapis Avarosan)
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` (Affichage automatique du décor `Fond_Sanctuaire_Glace` en arrière-plan de la cinématique d'ouverture pour masquer la chambre du joueur, suivi d'un fondu au noir narratif qui dévoile la chambre du joueur avec un `[!]` de réveil pour enchaîner sur le début classique Pokémon)
- **Comment tester en jeu** :
  - Lancer le jeu et choisir **New Game** : la cinématique s'ouvre directement dans le Sanctuaire de Glace, puis s'ouvre en fondu sur la chambre du joueur.
- **Comment désactiver en cas de bug** :
  - Retirer `pbCinematiqueDirigeableNoxus` de l'événement d'intro ou supprimer `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb`.

---

### `[AGY-006]` — 2026-10-11 — Animation complète sur carte : Déplacement des PNJ Noxiens & Décollage concret de l'Œuf d'Anivia
- **Auteur** : `Antigravity` (après validation de l'utilisateur)
- **Catégorie** : Sprites (`Characters` / `Pictures`) & Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers ajoutés / modifiés** :
  - `Graphics/Characters/!Oeuf_Anivia.png` (`384×320 px` — Planche d'événement 4×4 de l'Œuf d'Anivia In-Game sur fond transparent, à poser par-dessus l'Autel Vide)
  - `Graphics/Pictures/Dirigeable_Grappin_Oeuf.png` (`96×120 px` — Œuf d'Anivia saisi par le grappin/treuil noxien pour l'animation de montée verticale)
  - `Graphics/Pictures/Oeuf_Anivia_Seul.png` (`96×80 px` — Sprite de l'Œuf d'Anivia seul sur son socle de cristaux de givre)
  - `Graphics/Pictures/Autel_Anivia_Vide.png` (`128×128 px` — Socle de l'Autel pillé qui reste visible au sol une fois l'Œuf soulevé)
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` (Ajout de la classe `NoxusCutsceneActor`, arrivée et marche animée du Commandant Valerius et de ses 2 soldats jusqu'à l'Œuf, dialogues, descente du câble jusqu'au socle, activation automatique de l'Interrupteur Local `A` de l'Œuf pour vider le socle au sol, et montée progressive pixel par pixel de l'Œuf vers le Dirigeable)
- **Comment tester en jeu** :
  - Appeler `pbCinematiqueDirigeableNoxus` dans une commande `Script...` d'un événement (fonctionne automatiquement même sur une carte de test sans événement préalable, ou détecte automatiquement l'événement utilisant `!Oeuf_Anivia.png` sur la carte du Sanctuaire).
- **Comment désactiver en cas de bug** :
  - Retirer l'appel `pbCinematiqueDirigeableNoxus` de l'événement ou supprimer `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb`.

---

### `[AGY-005]` — 2026-10-11 — Correctif PBS `GrowthRate = Medium` pour Camalyx et Ziggs
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif PBS (`PBS/pokemon.txt`)
- **Fichiers modifiés** :
  - `PBS/pokemon.txt` (Lignes `23124` et `23147` : remplacement de `GrowthRate = MediumFast` par `GrowthRate = Medium`, qui est l'identifiant exact attendu par `GameData::GrowthRate` dans Pokémon Essentials v21.1 + restauration des accents français dans les descriptions Pokédex de `[CAMALYX]` et `[ZIGGS]`)
- **Symptôme corrigé** : `RuntimeError: Undefined value MediumFast in GameData::GrowthRate (File PBS/pokemon.txt, section CAMALYX)` au lancement du jeu en mode Debug.

---

### `[AGY-004]` — 2026-10-11 — Sous-Tilesets Acte 1 (Freljord) & Cinématique du Dirigeable de Noxus (V5) (Commit `05f7ca8`)
- **Auteur** : `Antigravity` (après validation visuelle de l'utilisateur)
- **Catégorie** : Graphismes (`Tilesets` / `Pictures`) & Script Cinématique (`Overworld`)
- **Fichiers ajoutés** :
  - `Graphics/Tilesets/SubTileset_1_Dirigeable_Noxus.png` (`256×640 px` — Dirigeable V5, Pont de commandement noxien avec blason officiel, Capsule Hextech avec Œuf d'Anivia In-Game, Consoles & Caisses Noxus, Sols enneigés)
  - `Graphics/Tilesets/SubTileset_2_Sanctuaire_DemiDieux.png` (`256×640 px` — Autel 4×4 intact avec le vrai Œuf d'Anivia In-Game sur son socle de givre, Autel 4×4 pillé avec harpons noxiens, Vitrail mural d'Anivia, Colonnes de Glace Pure, Tapis Avarosan, Gouffre d'Aurore Boréale & Pont de Cristal, 4 Grandes Statues de Demi-Dieux, Fresque des Veilleurs, Stèles & Poro)
  - `Graphics/Tilesets/SubTileset_3_Caverne_Epreuve_Crash.png` (`256×640 px` — Pont de l'Abîme Hurlant, Grande Porte de l'Épreuve, Glace glissante, Pics de Glace Pure, Épave du Réacteur Chimtech/Hextech crashé)
  - `Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png` (`256×640 px` — Chalets nordiques de Bourg-Givre, Laboratoire du Prof. Mélèze, Centre Pokémon, Braseros, Totems, Sapins enneigés, Bateau à quai de Port-Brumeux)
  - `Graphics/Pictures/Cinematic_Dirigeable_Noxus_3Frames.png` (Planche complète des 3 étapes de vol V5)
  - `Graphics/Pictures/Dirigeable_Noxus_1_Vol.png` (`256×240 px` — Étape 1 : Approche nocturne avec projecteurs)
  - `Graphics/Pictures/Dirigeable_Noxus_2_Capture.png` (`256×240 px` — Étape 2 : Treuil soulevant l'Œuf d'Anivia In-Game)
  - `Graphics/Pictures/Dirigeable_Noxus_3_Explosion.png` (`256×240 px` — Étape 3 : Éclair du Sanctuaire & explosion de l'hélice arrière)
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` (Fonctions Ruby `pbCinematiqueDirigeableNoxus`, `pbDirigeableNoxus_Arrivee`, `pbDirigeableNoxus_CaptureOeuf`, `pbDirigeableNoxus_ExplosionEtFuite`)
- **Comment tester en jeu** :
  - Dans un événement RPG Maker XP, ajouter la commande `Script...` avec le texte : `pbCinematiqueDirigeableNoxus`
- **Risque de conflit / Debug** :
  - Aucun fichier existant de Pokémon Essentials n'a été écrasé (uniquement des nouveaux fichiers ajoutés). Si la cinématique a un souci, supprimer ou désactiver `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb`.

---

### `[AGY-003]` — 2026-10-11 — Documentation Scénario & Lore de l'Acte 1 (`STORY.md`)
- **Auteur** : `Antigravity`
- **Catégorie** : Documentation / Lore
- **Fichiers ajoutés** :
  - `STORY.md` (Synopsis complet de l'Acte 1 à Freljord : Bourg-Givre, Sanctuaire d'Anivia, Caverne de l'Épreuve, Raid nocturne du Dirigeable du Commandant Valerius, Fuite par bateau à Port-Brumeux)
- **Risque de conflit / Debug** : Aucun impact sur le code ou l'exécution du jeu (fichier Markdown documentaire).

---

### `[AGY-002]` — 2026-10-10 — Ajout des 10 Pokémon Custom (Runeterra) & Guide `AGENTS.md` (Commit `e9c8616`)
- **Auteur** : `Antigravity`
- **Commit Git** : `e9c8616`
- **Catégorie** : Données PBS (`PBS/pokemon.txt`, `PBS/pokemon_metrics.txt`) & Sprites (`Graphics/Pokemon/`)
- **Fichiers modifiés / ajoutés** :
  - `PBS/pokemon.txt` (Ajout à la fin du fichier de : `[CAMALYX]`, `[ZIGGS]`, `[KINDRAME]`, `[AURELIASTRE]`, `[VORAGATH]`, `[SYLVERN]`, `[ROCPHITE]`, `[XENOSAI]`, `[OMBREVEX]`, `[FIDDLEFFROI]` + correction de l'encodage UTF-8 des accents français)
  - `PBS/pokemon_metrics.txt` (Positionnement des sprites pour les 10 Pokémon custom)
  - `Graphics/Pokemon/Front/`, `Back/`, `Front shiny/`, `Back shiny/`, `Icons/`, `Icons shiny/`, `Footprints/` pour les 10 espèces
  - `AGENTS.md` & `.gitignore` (Configuration pour ignorer `Data/*.dat` et suivre `Graphics/`, `Audio/` et `Data/*.rxdata`)
- **Risque de conflit / Debug** :
  - Si erreur de compilation PBS au lancement en mode Debug, vérifier les dernières lignes de `PBS/pokemon.txt` et `PBS/pokemon_metrics.txt`.

---

### `[JULES-001]` — 2026-10-10 — Configuration Git initiale du suivi `Audio/` et `Graphics/` (Commit `98c7e71`)
- **Auteur** : `Jules AI` (Branche fusionnée dans `main`)
- **Commit Git** : `98c7e71`
- **Catégorie** : Configuration Git
- **Fichiers modifiés** : `.gitignore`
- **Description** : Autorisation du suivi des dossiers `Audio/` et `Graphics/` sur le dépôt GitHub.

---

### `[INIT-001]` — 2026-10-10 — Import initial de Pokémon Essentials v21.1 (Commit `e9127e0`)
- **Auteur** : `Utilisateur / Initial`
- **Commit Git** : `e9127e0`
- **Catégorie** : Base du moteur
- **Description** : Version de base de Pokémon Essentials v21.1 (`Data/Scripts/`, `PBS/` de base).

---

## 🧪 En attente de validation avant installation dans le jeu (Stockés uniquement dans le dossier de prévisualisation)

Les éléments suivants sont prêts mais **ne sont PAS encore copiés dans les fichiers du jeu** (conformément à ta consigne) :
- **Sprites des Starters de l'Acte 1** :
  - Famille **Geloupiot** → **Lycanglas** → **Fenrimas** (`Front`, `Back`, `Front shiny`, `Back shiny`)
  - Famille **Tyrakoup** → **Thoraklak** (`Front`, `Back`, `Front shiny`, `Back shiny`)

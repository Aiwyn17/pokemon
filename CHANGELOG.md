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

### `[AGY-032]` — 2026-10-16 — Déploiement Intégral des 3 Lignées de Starters de Bourg-Givré (9 Pokémon & 63 Sprites In-Game)
- **Auteur** : `Antigravity`
- **Catégorie** : Pokémon Starters / Sprites Combat 5G (`Graphics/Pokemon/`) & Données PBS (`PBS/pokemon.txt`, `PBS/pokemon_metrics.txt`)
- **Pokémon intégrés & finalisés (3 Lignées complètes de 3 Stades)** :
  1. **Lignée Loup de Glace Pure** :
     - **Geloupiot** (`[GELOUPIOT]`, Niv. 5 — Glace)
     - **Lycanglas** (`[LYCANGLAS]`, Niv. 16 — Glace / Ténèbres)
     - **Fenrimas** (`[FENRIMAS]`, Niv. 36 — Glace / Ténèbres)
  2. **Lignée Ours de la Tempête (*Volibear*)** :
     - **Tyrakoup** (`[TYRAKOUP]`, Niv. 5 — Combat)
     - **Thoraklak** (`[THORAKLAK]`, Niv. 16 — Combat / Électrik)
     - **Volibjorn** (`[VOLIBJORN]`, Niv. 36 — Combat / Électrik)
  3. **Lignée Esprit Runique des Veilleurs** :
     - **Veilliris** (`[VEILLIRIS]`, Niv. 5 — Psy)
     - **Runolithe** (`[RUNOLITHE]`, Niv. 16 — Psy / Sol)
     - **Ragnarune** (`[RAGNARUNE]`, Niv. 36 — Psy / Sol)
- **Ressources ajoutées pour chaque Pokémon** :
  - `Graphics/Pokemon/Front/` & `Front shiny/` (160×160 PNG Gen 5 pixel art).
  - `Graphics/Pokemon/Back/` & `Back shiny/` (160×160 PNG dos de combat 180°).
  - `Graphics/Pokemon/Icons/` & `Icons shiny/` (128×64 PNG icônes 2-frames animées).
  - `Graphics/Pokemon/Footprints/` (16×16 PNG empreintes uniques de pas).
  - `PBS/pokemon.txt` : Fiches complètes (BST équilibrés, Talents réguliers et cachés, Movesets complets jusqu'au niv. 70+, chaînes d'évolution aux niveaux 16 et 36, courbes paraboliques).
  - `PBS/pokemon_metrics.txt` : Métriques d'ombres et positionnement en combat.
- **Aperçu visuel de validation** :
  - `apercu_officiel_9_starters_complets.png` (Dossier d'artefacts).
- **Comment tester en jeu** :
  - Lancer en Debug (`F9`) -> Menu Pokémon -> Donner Pokémon (`GELOUPIOT`, `TYRAKOUP`, `VEILLIRIS`, etc.).
  - Faire monter de niveau pour tester les évolutions aux niveaux 16 et 36.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-031]` — 2026-10-16 — Correction du Paramètre `Shape = HeadArms` pour les 3 Starters (Veilliris, Runolithe, Ragnarune)
- **Auteur** : `Antigravity`
- **Catégorie** : Données PBS (`PBS/pokemon.txt`)
- **Fichier modifié** :
  - `PBS/pokemon.txt` : Remplacement de la valeur non reconnue `Shape = HeadWithArms` par la constante valide du moteur Pokémon Essentials v21.1 `Shape = HeadArms` (`GameData::BodyShape` id `:HeadArms`) pour `[VEILLIRIS]`, `[RUNOLITHE]` et `[RAGNARUNE]`.
- **Résultat** : Résolution définitive de l'erreur de compilation PBS et validation de la fiche Pokédex.
- **Comment tester en jeu** :
  - Lancer le jeu en mode Debug (`F9`) pour vérifier la compilation sans erreur de `PBS/pokemon.txt`.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-030]` — 2026-10-16 — Intégration de la Nomenclature League of Legends pour les Statistiques (AD, AP, Armure, Res. Magique, MS)
- **Auteur** : `Antigravity` (portage des travaux de `Jules AI`)
- **Catégorie** : Scripts Moteur UI & Textes Système (`Data/Scripts/`, `Text_english_core/`)
- **Fichiers modifiés** :
  - `Data/Scripts/010_Data/001_Hardcoded data/008_Stat.rb` : Définition des noms et abréviations des statistiques de combat dans le registre de données (`ATTACK` -> `AD`, `DEFENSE` -> `Armure`, `SPECIAL_ATTACK` -> `AP`, `SPECIAL_DEFENSE` -> `Res. Magique` / `RM`, `SPEED` -> `MS`).
  - `Data/Scripts/016_UI/006_UI_Summary.rb` : Écran du Résumé Pokémon (Summary) mis à jour pour afficher fidèlement `AD`, `Armure`, `AP`, `Res. Magique`, `MS`.
  - `Text_english_core/SCRIPT_TEXTS.txt` : Remplacement complet des chaînes de combat, messages d'altération de stats, objets boosters de statistiques et baies anti-EVs avec la nomenclature LoL.
- **Comment tester en jeu** :
  - Ouvrir le menu Pokémon -> `Résumé` d'un Pokémon -> Page des statistiques : observer les intitulés `AD`, `Armure`, `AP`, `Res. Magique`, `MS`.
  - Tester une capacité modifiant les statistiques en combat (ex: *Danse-Lames*, *Groz'Yeux*) pour voir les messages adaptés.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` ou restaurer les 3 fichiers concernés avec `git checkout HEAD~1 -- Data/Scripts/010_Data/001_Hardcoded\ data/008_Stat.rb Data/Scripts/016_UI/006_UI_Summary.rb Text_english_core/SCRIPT_TEXTS.txt`.

---

### `[AGY-029]` — 2026-10-16 — Unification de la Branche Principale sur `main` & Sécurisation Intégrale des 14 Pokémon Personnalisés
- **Auteur** : `Antigravity`
- **Catégorie** : Architecture Git & Préservation Intégrale des Données du Projet
- **Actions réalisées** :
  - **Unification de la branche principale** : La branche locale et distante `main` a été alignée exactement sur l'état complet et fonctionnel (`code-only`). La branche temporaire `code-only` a été supprimée proprement. `main` est désormais l'unique branche de référence du projet.
  - **Audit & Sécurisation des Pokémon Runeterra & Starters (14 au total)** :
    - Tous les 14 Pokémon disposent de l'intégralité de leurs 7 variantes de sprites validées et testées dans `Graphics/Pokemon/` (`Front/`, `Front shiny/`, `Back/`, `Back shiny/`, `Icons/`, `Icons shiny/`, `Footprints/`).
    - Liste des 14 Pokémon vérifiés à 100 % : `CAMALYX`, `ZIGGS`, `KINDRAME`, `AURELIASTRE`, `VORAGATH`, `SYLVERN`, `ROCPHITE`, `XENOSAI`, `OMBREVEX`, `FIDDLEFFROI`, `VOLIBJORN`, `VEILLIRIS`, `RUNOLITHE`, `RAGNARUNE`.
    - Les fiches statistiques complètes, movesets et courbes d'expérience sont scrupuleusement encodées en UTF-8 propre dans `PBS/pokemon.txt` et `PBS/pokemon_metrics.txt`.
- **Comment tester en jeu** :
  - Lancer le jeu en mode Debug (`F9`).
  - Vérifier la présence et les sprites de dos à 180° de chaque Pokémon en combat.
- **Comment désactiver en cas de bug** :
  - `git checkout HEAD~1`

---

### `[AGY-028]` — 2026-10-16 — Création du Nouveau Tileset Authentique des Routes de Freljord (`SubTileset_5_Routes_Freljord.png`)
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes / Tilesets Overworld (`Graphics/Tilesets/`)
- **Fichier créé** :
  - `Graphics/Tilesets/SubTileset_5_Routes_Freljord.png` (`256×2752 px`, PNG ARGB 32-bit avec fond transparent, 8 colonnes × 86 rangées de tuiles unifiées `32×32 px`).
- **Conception & Harmonie Graphique** :
  - **100 % basé sur la charte graphique officielle des sous-tilesets existants (`SubTileset_1` à `SubTileset_4`)** pour une continuité visuelle parfaite avec Bourg-Givré et le Sanctuaire des Demi-Dieux (zéro discordance de style, zéro problème d'alignement).
- **Contenu Exhaustif pour les Routes de Haute Montagne de Freljord (Acte 1)** :
  1. **Sols & Chemins** : Neige fraîche poudreuse, sentiers de neige tassée et damée avec virages et carrefours complets, dalles et pavés de pierre froide, marches de sentier.
  2. **Glace & Hautes Herbes Sauvages** : Lac gelé complet (berges, transition eau/glace, patinoire de glace lisse), dalles de glace bleutée, et kit complet de **hautes herbes enneigées** de rencontre sauvage Pokémon.
  3. **Reliefs, Montagnes & Falaises** : Parois rocheuses enneigées, angles de falaises, corniches / *ledges* sautables Pokémon, grand pic rocheux monumental, parois de glace pure et échelles de corde.
  4. **Grottes & Cavernes Naturelles** : Entrée de caverne rocheuse sous falaise, entrée monumentale de sanctuaire de glace, stalagmites, pics de glace et trous dans la glace.
  5. **Forêt Boréale Boréale** : Sapins boréaux individuels (2×3), cimes d'arbres enneigées, forêt dense répétable, conifères givrés et buissons de baies enneigés.
  6. **Passages & Franchissements** : Ponts suspendus en bois (horizontaux et verticaux) et grand escalier monumental en pierre à double balustrade.
  7. **Bivouac & Campements Nomades (League of Legends)** : Tente / yourte nordique en fourrure et bois avec lueur intérieure chaude (3×3), grand feu de camp de trappeur avec marmite fumante sur trépied, grand feu de camp de pierres, petit feu de camp compact, billot de bois avec hache plantée, puits gelé, souches-sièges, bancs en gros troncs d'arbres enneigés, grand tas de bûches, traîneau en bois, séchoir à poissons, barrières en rondins, bonhomme de neige nordique, cabane-refuge en bois chaud, igloo et caisses de provisions.
  8. **Lore & Demi-Dieux de Freljord** : Grandes statues d'**Anivia**, de **Volibear** et du **Loup de Glace**, Poro sauvage, grand autel d'Anivia à socle de glace pure, piliers runiques, pierres sacrées et bannières tribales.
  9. **Signalétique & Mobilier de Route** : Panneaux indicateurs en bois/pierre de Freljord, lampadaires nordiques, bancs de pierre et barrières de sentier.
- **Aperçus de validation (Dossier d'artefacts)** :
  - `SubTileset_5_Routes_Freljord.png` (Tileset 256×2752 px).
  - `SubTileset_5_Routes_Freljord_grid.png` (Superposition de grille 32×32 px).
- **Comment tester en jeu** :
  - Ouvrir le projet dans **RPG Maker XP** -> Base de données (`F9`) -> Onglet `Tilesets`.
  - Assigner `SubTileset_5_Routes_Freljord` au tileset de votre route de Freljord.
  - Peindre la route de montagne sur les calques 1, 2 et 3.
- **Comment désactiver en cas de bug** :
  - Supprimer `Graphics/Tilesets/SubTileset_5_Routes_Freljord.png`.

---

### `[AGY-027]` — 2026-10-15 — Perfectionnement Dorsal & Cimes de Ragnarune, Intégration Flawless de Runolithe & Synthèse des 3 Starters
- **Auteur** : `Antigravity`
- **Catégorie** : Pokémon Starters / Sprites Combat 5G (`Graphics/Pokemon/`) & Synthèse Globale
- **Fichiers modifiés / remplacés** :
  - **Ragnarune (`[RAGNARUNE]`, Stade 3 Final — Types Psy / Sol)** :
    - `Graphics/Pokemon/Front/RAGNARUNE.png` & `Front shiny/RAGNARUNE.png` : Rallonge et finition naturelle des 5 éléments supérieurs coupés nets par le cadre de carte (cimes pointues en biseau de pierre pour les stèles gauche/droite et cornes recourbées pour la couronne de tête).
    - `Graphics/Pokemon/Back/RAGNARUNE.png` & `Back shiny/RAGNARUNE.png` : **Version Dorsale 100% fidèle à la face** (silhouette, épaules en blocs de basalte, mains de golem flottantes vues de dos avec jointures de roche et éclairs violets, stèles en lévitation, vortex tellurique et casque de basalte lisse et massif avec fissure runique lumineuse axiale sans aucun artéfact rectangulaire ni découpe).
    - `Graphics/Pokemon/Icons/RAGNARUNE.png` & `Icons shiny/RAGNARUNE.png` (icônes d'équipe 128×64 actualisées).
  - **Runolithe (`[RUNOLITHE]`, Stade 2 Intermédiaire — Types Psy / Sol)** :
    - `Graphics/Pokemon/Front/RUNOLITHE.png` & `Back/RUNOLITHE.png` : Idole mégalithique éveillée avec anneau rotatif d'arcanes, stèles de protection flottantes, cornes naissantes et poussière de terre (nettoyage 100% pixel-perfect : zéro texte "RUNOLITHE/SOL", zéro bordure de carte).
    - `Graphics/Pokemon/Front shiny/RUNOLITHE.png` & `Back shiny/RUNOLITHE.png` (variante magma / grès incandescent).
    - `Graphics/Pokemon/Icons/RUNOLITHE.png` & `Icons shiny/RUNOLITHE.png` (`128×64 px`).
    - `Graphics/Pokemon/Footprints/RUNOLITHE.png` (`16×16 px`).
- **Aperçus de validation générés (Dossier d'artefacts)** :
  - `apercu_final_3_starters_veilliris.png` (Vue détaillée des 3 stades de la lignée Veilliris : 12 sprites 160×160 sur damier transparent).
  - `apercu_synthese_globale_3_starters.png` (Synthèse comparative des 3 lignées de starters de Bourg-Givré).
- **Comment tester en jeu** :
  - Lancer en Debug -> `Donner Pokémon` -> tester `RUNOLITHE` et `RAGNARUNE` en combat dresseur / sauvage pour admirer les sprites de dos à 180°.
- **Comment désactiver en cas de bug** :
  - Revenir au commit précédent avec `git checkout HEAD~1 -- Graphics/Pokemon/`.

---

### `[AGY-026]` — 2026-10-15 — Intégration Complète des Starters de Bourg-Givré (Volibjorn, Veilliris, Ragnarune) & Correction Dorsale
- **Auteur** : `Antigravity`
- **Catégorie** : Pokémon Starters / Sprites Combat 5G (`Graphics/Pokemon/`) & Données PBS (`PBS/pokemon.txt`, `PBS/pokemon_metrics.txt`)
- **Fichiers ajoutés / créés** :
  - **Volibjorn (`[VOLIBJORN]`, Stade 3 Final — Combat / Électrik)** :
    - `Graphics/Pokemon/Front/VOLIBJORN.png` (`160×160 px`)
    - `Graphics/Pokemon/Back/VOLIBJORN.png` (`160×160 px`)
    - `Graphics/Pokemon/Front shiny/VOLIBJORN.png` (`160×160 px`)
    - `Graphics/Pokemon/Back shiny/VOLIBJORN.png` (`160×160 px`)
    - `Graphics/Pokemon/Icons/VOLIBJORN.png` (`128×64 px` — Icône animée 2 frames)
    - `Graphics/Pokemon/Icons shiny/VOLIBJORN.png` (`128×64 px`)
    - `Graphics/Pokemon/Footprints/VOLIBJORN.png` (`16×16 px`)
  - **Veilliris (`[VEILLIRIS]`, Stade 1 — Psy)** :
    - `Graphics/Pokemon/Front/VEILLIRIS.png` (`160×160 px` — Extrait de l'image 1 Ligne 1, esprit éthéré entourant la stèle)
    - `Graphics/Pokemon/Back/VEILLIRIS.png` (`160×160 px`)
    - `Graphics/Pokemon/Front shiny/VEILLIRIS.png` (`160×160 px`)
    - `Graphics/Pokemon/Back shiny/VEILLIRIS.png` (`160×160 px`)
    - `Graphics/Pokemon/Icons/VEILLIRIS.png` & `Icons shiny/VEILLIRIS.png` (`128×64 px`)
    - `Graphics/Pokemon/Footprints/VEILLIRIS.png` (`16×16 px`)
  - **Ragnarune (`[RAGNARUNE]`, Stade 3 Final — Psy / Sol)** :
    - `Graphics/Pokemon/Front/RAGNARUNE.png` (`160×160 px` — Titan tellurique aux 5 yeux, vortex abyssal et stèles)
    - `Graphics/Pokemon/Back/RAGNARUNE.png` (`160×160 px` — **Version Dos Corrigée sans bugs** : ajout des mains articulées en perspective dorsale, stèles runiques flottantes avec arcs d'éclairs violets et vortex circulaire préservé)
    - `Graphics/Pokemon/Front shiny/RAGNARUNE.png` (`160×160 px` — Teinte magma / lave solaire)
    - `Graphics/Pokemon/Back shiny/RAGNARUNE.png` (`160×160 px` — **Version Dos Shiny Corrigée**)
    - `Graphics/Pokemon/Icons/RAGNARUNE.png` & `Icons shiny/RAGNARUNE.png` (`128×64 px`)
    - `Graphics/Pokemon/Footprints/RAGNARUNE.png` (`16×16 px`)
- **Fichiers modifiés** :
  - `PBS/pokemon.txt` : Ajout des fiches statistiques complètes pour `[VOLIBJORN]`, `[VEILLIRIS]`, `[RUNOLITHE]` et `[RAGNARUNE]` (BST équilibrés, Talents, Courbes d'expérience, Movesets thématiques Freljord).
  - `PBS/pokemon_metrics.txt` : Ajout des métriques de positionnement et ombres de combat pour les 4 Pokémon.
- **Aperçus de validation générés** :
  - `apercu_final_volibjorn.png` (4 vues Volibjorn 160×160 sur damier transparent)
  - `apercu_final_veilliris.png` (4 vues Veilliris 160×160 sur damier transparent)
  - `apercu_final_ragnarune_parfait.png` (4 vues Ragnarune 160×160 avec dos corrigé sans coupure ni moiré)
- **Comment tester en jeu** :
  - Lancer le jeu en mode Debug via RPG Maker XP (F9 en jeu ou Menu Développeur -> `Donner Pokémon` -> choisir `VOLIBJORN`, `VEILLIRIS` ou `RAGNARUNE`).
- **Comment désactiver en cas de bug** :
  - Supprimer les sprites correspondants dans `Graphics/Pokemon/` et retirer les sections `[VOLIBJORN]`, `[VEILLIRIS]`, `[RUNOLITHE]`, `[RAGNARUNE]` à la fin de `PBS/pokemon.txt` et `PBS/pokemon_metrics.txt`.

---

### `[AGY-025]` — 2026-10-14 — Formatage & Correction d'Orientation des 5 Planches de Personnages Overworld (`Graphics/Characters/`)
- **Auteur** : `Antigravity`
- **Catégorie** : Sprites d'Événements / Personnages (`Graphics/Characters/`)
- **Fichiers ajoutés / créés** :
  - `Graphics/Characters/valerius_walk.png` (`128×192 px` — Format standard Essentials) + `valerius_walk_hd.png` (`192×256 px`) : **Commandant Valerius** (Officier noxien avec lunettes de pilote, cape rouge à double hache)
  - `Graphics/Characters/soldat_noxus_walk.png` (`128×192 px`) + `soldat_noxus_walk_hd.png` (`192×256 px`) : **Soldat / Assassin de Noxus** (Queue de cheval rouge, masque ninja, cape noxienne)
  - `Graphics/Characters/prof_meleze_walk.png` (`128×192 px`) + `prof_meleze_walk_hd.png` (`192×256 px`) : **Professeur Mélèze** (Vieux sage à barbe blanche, toque et runes nordiques)
  - `Graphics/Characters/soren_walk.png` (`128×192 px`) + `soren_walk_hd.png` (`192×256 px`) : **Soren (Le Rival)** (Cheveux argentés, bandeau noir, écharpe ambrée et sacoche)
  - `Graphics/Characters/hero_walk.png` (`128×192 px`) + `hero_walk_hd.png` (`192×256 px`) : **Le Héros / Joueur** (Cheveux bleu nuit, bandeau et écharpe rouge, manteau boréal et sac à dos)
- **Corrections apportées sur les dessins bruts** :
  1. **Remise en ordre stricte des 4 directions RPG Maker XP / Pokémon Essentials** :
     - **Ligne 0 (y = 0..47)** : **BAS (Face)** — 4 frames : Repos (Frame 0), Pas 1 (Frame 1), Repos (Frame 2), Pas 2 (Frame 3).
     - **Ligne 1 (y = 48..95)** : **GAUCHE (Profil)** — 4 frames : Repos, Pas 1, Repos, Pas 2 (tous tournés vers la gauche, suppression des frames tournées à droite sur Hero et Professeur Mélèze).
     - **Ligne 2 (y = 96..143)** : **DROITE (Profil)** — 4 frames : Repos, Pas 1, Repos, Pas 2 (tous tournés vers la droite, 100% cohérents sans aucune inversion de regard).
     - **Ligne 3 (y = 144..191)** : **HAUT (Dos)** — 4 frames : Repos, Pas 1, Repos, Pas 2.
  2. **Détourage Alpha & Préservation des cheveux blancs / barbes** :
     - Détourage intelligent par inondation (Flood-Fill) depuis les bords extérieurs : les cheveux blancs de Soren, la barbe blanche du Professeur, les yeux et la fourrure blanche sont 100 % préservés sans devenir transparents.
     - Élimination des débordements de pixels de semelles entre les rangées.
  3. **Double format disponible** :
     - **Standard Essentials `128×192 px`** (cases de `32×48 px`, s'intègre parfaitement avec tous les PNJ et dresseurs existants).
     - **HD `192×256 px`** (cases de `48×64 px`, pour un rendu 1:1 sans réduction).
- **Comment tester en jeu / dans RPG Maker XP** :
  - Dans RPG Maker XP, créer ou éditer un Événement -> double-cliquer sur la case graphique -> sélectionner `valerius_walk.png`, `soldat_noxus_walk.png`, `prof_meleze_walk.png`, `soren_walk.png` ou `hero_walk.png`.
- **Comment désactiver en cas de bug** :
  - Supprimer les 10 fichiers `*_walk*.png` de `Graphics/Characters/`.

---

### `[AGY-024]` — 2026-10-13 — Audit Complet & Suppression de Tous les Murs Invisibles du Village (`Data/Map022.rxdata`, `Data/Tilesets.rxdata`)
- **Auteur** : `Antigravity`
- **Catégorie** : Collisions & Priorités RPG Maker XP (`Data/Map022.rxdata`, `Data/Tilesets.rxdata`)
- **Cause des blocages invisibles identifiée et corrigée (en conservant 100 % des dernières modifications de l'utilisateur sur `Map022`)** :
  1. **Angle interne de la route pavée `tid = 680 (0, 1184)` qui avait `Passage = 15`** :
     - Bloquait les 3 carrefours pavés aux coordonnées **`Map(19, 16)`**, **`Map(26, 16)`** et **`Map(24, 24)`**. Remis en **`Passage = 0, Priority = 0`** dans `Data/Tilesets.rxdata`.
  2. **Cases 100 % transparentes (`opaquePx < 20`) de `SubTileset_4_Villages_Freljord_Port.png` qui avaient hérité de `Passage = 15`** :
     - Lors de la sélection rectangulaire d'éléments multi-cases dans RPG Maker XP (lampadaires, rochers, ancien pic de glace), les cases vides adjacentes avaient été posées sur le Layer 2 (`z = 2`) et bloquaient le passage à **`Map(24, 18)`** (route sous la lanterne du lampadaire central), **`Map(30, 24..25)`** (route sous la lanterne du lampadaire près du Poro), **`Map(26, 12..15)`** (avenue du Sanctuaire Nord), **`Map(23, 12)`** (parvis du Sanctuaire), et **`Map(21, 11)` / `Map(34, 11)` / `Map(44, 24)`** (près des rochers).
     - **Correctif permanent** : Suppression de ces `11` tuiles transparentes sur `Data/Map022.rxdata` ET remise à zéro (`P = 0, Pr = 0, T = 0`) des `70` cases transparentes dans `Data/Tilesets.rxdata` (`Tileset 25`) pour qu'aucune sélection rectangulaire dans RPG Maker XP ne puisse jamais recréer de mur invisible.
  3. **Tuiles de neige bloquantes `tid = 1351 (224, 3840)` (`Passage = 15`) restées sur le Layer 0 (`z = 0`) dans les zones ouvertes** :
     - Dans Pokémon Essentials (`004_Game_Map.rb#playerPassable?`), lorsqu'une case a `Passage = 0` sur le Layer 2 avec `Priority > 0` (ou est vide sur les Layers 2 et 1), le moteur vérifie le Layer 0 (`z = 0`). Les cases de neige `tid = 1351` restées en haut (`Y = 6..8` autour du Sanctuaire) et en bas (`Y = 35..36` sous le Laboratoire et le Lac où des sapins avaient été gommes) bloquaient le joueur sur de la neige ouverte.
     - **Correctif** : Remplacement par la neige marchable normale `tid = 544 (0, 640)` (`Passage = 0`) dans tout l'intérieur du village et derrière la première ligne de cimes d'arbres du bas (`Y = 36`), tout en conservant `tid = 1351` uniquement sous les sapins des 4 murs de forêt extérieurs (`X <= 9`, `X >= 46`, `Y <= 8` hors Sanctuaire, `Y >= 37`).
  4. **Touffes de neige/fleurs au sol `tid = 1037 (160, 2592)` & Niche enneigée `(43..44, 10..11)` + Nettoyage des `161` gommes d'autotiles vides (`tid = 1..383`)** :
     - Les petites touffes au sol `(160, 2592)` sont désormais marchables (`P = 0`) comme les fleurs `(128, 2592)`, le haut du toit de la petite niche au Nord-Est `(0..32, 2976)` passe en `P = 0, Pr = 1` (effet 3D derrière le toit), et les `161` cases d'autotiles vides (`tid = 1..383`) ont été nettoyées en vraies cases vides (`tid = 0`).
- **Comment tester en jeu** :
  - Fermer et rouvrir **RPG Maker XP** (si ouvert) puis lancer le jeu : toutes les routes, carrefours, portes, abords des lampadaires, avenue du Sanctuaire et neige sous le Labo/Lac sont 100 % fluides sans aucun blocage invisible.
- **Comment désactiver en cas de bug** :
  - `git checkout HEAD~1 -- Data/Map022.rxdata Data/Tilesets.rxdata`

---

### `[AGY-023]` — 2026-10-13 — Décalage du Village, Ajout de la Forêt Boréale Sans Fin sur les 4 Côtés (`56×44` cases, Zéro Vide Noir) & Décorations Enneigées (`Data/Map022.rxdata`, `Data/Tilesets.rxdata`)
- **Auteur** : `Antigravity`
- **Catégorie** : Cartes RPG Maker XP (`Data/Map022.rxdata`, `Data/Tilesets.rxdata`)
- **Fichiers modifiés** :
  - `Data/Map022.rxdata` (`"village 1"`, agrandie en **`56×44` cases**) :
    - **Conservation à 100 % des modifications de l'utilisateur** (Sanctuaire en pierre au Nord + panneau d'emblème + grand pic de glace + rochers, Place Centrale ouverte avec le Poro, Maison du Rival à arche, Laboratoire bleu-glacier, clôtures en pierre autour de la moitié eau du lac, buissons givrés).
    - **Décalage complet du village de `(+8, +6)` cases** pour créer une **Forêt Boréale Sans Fin** sur les **4 côtés** :
      - **5 colonnes de sapins (`10` cases de large)** à **Gauche (`X = 0..9`)** et à **Droite (`X = 46..55`)**,
      - **3 rangées de sapins (`9` cases de profondeur)** en **Haut (`Y = 0..8`)** et en **Bas (`Y = 35..43`)**, avec prolongement des routes pavées Nord (`X = 19..20`) et Sud (`X = 27..28`) jusqu'aux bords de la carte.
      - **Remplissage intégral du Layer 0 sous toute la forêt avec la neige collisionnable `(224, 3840)` (`Passage = 15`)** : supprime totalement le fond noir entre les sapins et empêche de voir du vide noir quand le joueur marche près des arbres à gauche, à droite, en haut ou en bas.
    - **Ajout de décorations enneigées Gen 4** : bancs enneigés sur la Place Centrale et face à la partie gelée du lac, panneaux en bois (carrefour central et entrée du lac), lampadaires symétriques le long des avenues, perron pavé devant la porte de la Maison du Rival, sapins `2×3` supplémentaires, rochers enneigés et touffes de fleurs givrées.
  - `Data/Tilesets.rxdata` (`Tileset 25`) :
    - Ajout des priorités 3D (`Pr = 1`) sur le haut du toit du Sanctuaire Nord (`160..224, 192`) et de la Maison du Rival (`0..128, 448`), ouverture de la porte (`32, 512` `P = 0`), et collision solide (`P = 15`) sur le Poro (`128, 160`).
- **Comment tester en jeu / dans RPG Maker XP** :
  - Fermer et rouvrir **RPG Maker XP** (pour recharger `Map022.rxdata`) ou lancer le jeu et marcher tout à gauche, à droite, en haut et en bas du village.
- **Comment désactiver en cas de bug** :
  - `git checkout HEAD~1 -- Data/Map022.rxdata Data/Tilesets.rxdata`

---

### `[AGY-022]` — 2026-10-12 — Création de la Map du Premier Village « Bourg-Givré » (`Data/Map022.rxdata`, `40×32`) & Configuration complète des Collisions / Priorités 3D / Terrain Tags (`Data/Tilesets.rxdata` — `Tileset 25`)
- **Auteur** : `Antigravity`
- **Catégorie** : Cartes RPG Maker XP (`Data/Map022.rxdata`, `Data/Tilesets.rxdata`) & Graphismes (`Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png`)
- **Fichiers modifiés** :
  - `Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png` (`256×4480 px`) :
    - **Sapin individuel `2×3` (`192, 0, 64, 96`)** : Ré-extrait en entier depuis `(16, 1760, 64, 96)` de `Outside.png` (100 % plein, non coupé à gauche).
    - **Laboratoire du Professeur à Colonnes (`0, 3328, 160, 128`)** : Bâtiment officiel à colonnes symétriques (`0, 5984` de `Outside.png`) coiffé d'un toit de neige blanche, bien distinct des maisons.
    - **Maisons `5×4` et `4×4` 100 % complètes (`0, 4128`, `0, 3200`, `0, 4256`, `128, 3456`)** : Sans aucun objet dessiné par-dessus les murs/fenêtres et avec portes alignées.
    - **Kit de Lac Moitié Eau / Moitié Glace Lisse (`0, 3840, 224, 96`)** : Moitié eau glacée liquide (`128, 3840`), colonne de transition nette (`96, 3840`) et moitié glace lisse naturelle (`0, 3840`), plus tuile de neige collisionnable (`224, 3840`) pour bloquer proprement les bordures de carte sous les sapins.
    - **Statues des Demi-Dieux de Freljord (`0, 3936, 224, 96`)** : Statue de l'Aigle de Glace d'Anivia (`96×96`), Statue de Volibear (`64×96`) et Statue du Loup de Glace (`64×96`) détourées sur fond transparent.
    - **Grand Escalier Monumental en Pierre `4×4` (`128, 4256, 128, 128`)** : Complet avec ses deux balustrades latérales.
  - `Data/Tilesets.rxdata` (`Tileset 25` — `"Bourg-Givre / Villages Freljord"`) :
    - Extension des tables `@passages`, `@priorities` et `@terrain_tags` de `544` à **`1504` tuiles** (`384` autotiles + `1120` tuiles).
    - Configuration complète des **collisions (`@passages`)**, des **priorités 3D (`@priorities`)** (cimes des sapins `Pr=1`, haut des toits de maisons/labo `Pr=1`, haut des boîtes aux lettres `Pr=1`, lanternes de lampadaires `Pr=2`, haut des statues `Pr=2`) et des **Terrain Tags Pokémon Essentials (`@terrain_tags`)** (`Water = 7` sur la moitié eau du lac pour Surf/Pêche, `Ice = 13` sur la moitié glace du lac pour glisser sur la glace, `17` sur les escaliers).
  - `Data/Map022.rxdata` (`"village 1"`, redimensionnée en **`40×32` cases**, `tileset_id = 25`) :
    - **4 Maisons espacées avec chacune sa boîte aux lettres** : Notre Maison (`X=4..8, Y=6..9`), Maison du Rival (`X=28..32, Y=6..9`), Maison d'Habitant 1 (`X=5..8, Y=14..17`), Maison d'Habitant 2 (`X=28..31, Y=12..15`).
    - **Laboratoire du Professeur (`X=5..9, Y=22..25`)** : Architecture à colonnes au Sud-Ouest avec grande cour pavée, panneau officiel et parterres de fleurs givrées.
    - **Sanctuaire des Demi-Dieux de Freljord (`X=14..25, Y=2..9`) & Place de la Fontaine Gelée (`X=16..23, Y=10..17`)** : Statues d'Anivia, Volibear et du Loup de Glace au sommet du Grand Escalier `4×4`, surplombant la Fontaine de Glace circulaire et ses bancs.
    - **Lac Moitié Eau / Moitié Glace Lisse (`X=25..34, Y=19..26`)** au Sud-Est et **7 lampadaires** disposés le long des trottoirs.
- **Comment tester en jeu / dans RPG Maker XP** :
  - Ouvrir **RPG Maker XP** -> double-cliquer sur la carte **`022 : village 1`** en bas à gauche (ou téléporter le joueur sur la `Map 022` en mode Debug).
- **Comment désactiver en cas de bug** :
  - `git checkout HEAD~1 -- Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png Data/Tilesets.rxdata Data/Map022.rxdata`

---

### `[AGY-021]` — 2026-10-12 — Remplacement de l'effet « Glace » sur les Toits par un Épais Manteau de Vraie Neige Blanche (`SubTileset_4_Villages_Freljord_Port.png`)
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes (`Graphics/Tilesets/`)
- **Fichier modifié** :
  - `Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png` (`256×4480 px`) :
    - **Tous les bâtiments des Colonnes 1 (`Y = 192..576`), 5 (`Y = 2768..3008`), 6 (`Y = 3200..3840`) et 7 (`Y = 4128..4480`)** : Suppression totale du quadrillage de tuiles bleutées/glacées et des pentes bleues au profit d'un **épais coussin de neige blanche poudreuse** (`RGB(252, 254, 255)` / `RGB(244, 248, 254)`), avec courbes organiques de congères (`RGB(220, 230, 242)`) et rebord de neige gonflé débordant sur les gouttières (`RGB(196, 212, 228)`), tout en préservant les cheminées en pierre (coiffées d'un tas de neige), les pignons avant et les enseignes (`MART`, `GYM`).
    - **Igloos de la Colonne 7 (`Y = 4000..4096`)** : Sommet des dômes adouci en neige blanche fraîche et joints en gris-neige doux au lieu du bleu glace.
- **Comment tester en jeu / dans RPG Maker XP** :
  - Ouvrir **RPG Maker XP** -> *Base de données (F9)* -> onglet *Tilesets* -> vérifier les toits des bâtiments de `SubTileset_4_Villages_Freljord_Port.png` (Colonnes 1, 5, 6 et 7).
- **Comment désactiver en cas de bug** :
  - `git checkout HEAD~1 -- Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png`

---

### `[AGY-020]` — 2026-10-12 — Ajout des Toits Enneigés, Lac Gelé, Feu de Camp, Igloos, Chalets en Bois & Cabanes en Rondins (`SubTileset_4_Villages_Freljord_Port.png`, `256×4480 px`)
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes (`Graphics/Tilesets/`)
- **Fichier modifié** :
  - `Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png` (Agrandissement de `256×3840 px` à **`256×4480 px`**, soit 7 colonnes de `640 px` / 140 lignes de tuiles `32×32`) :
    - **Colonne 4 (`Y = 2240..2560, X = 160..256`)** : Restauration complète en largeur `96 px` (`3×3` cases) du lac et des berges enneigées.
    - **Colonne 6 (`Y = 3200..3840`) — Maisons & Bâtiments avec neige épaisse sur les toits + stalactites** : Manteau de neige blanche sculptée sur le dessus des toits des 9 bâtiments (en préservant le relief de chaque ligne de tuiles) + stalactites de glace le long des gouttières.
    - **Colonne 7 (`Y = 3840..4480`) — Esprit Neige (Lac Gelé, Feu de Camp, Igloos, Chalets & Cabanes en Bois)** :
      - **`Y = 3840..3936` (Kit complet de Lac Gelé)** : Lac gelé `3×3` avec berges de neige + 4 coins internes + 4 tuiles de glace (`Glace brillante à reflets`, `Glace fissurée`, `Patinoire lisse`, `Trou d'eau glacée / Trou de pêche`) + grand pic de glace et rochers enneigés sur la glace.
      - **`Y = 3936..4000` (Coin Feu de Camp & Bivouac)** : Grand Feu de camp entouré de pierres enneigées (`64×64`), Feu de camp de trappeur avec marmite suspendue sur trépied (`64×64`), Petit Feu de camp (`32×32`), billot de bois avec hache plantée, bancs en gros troncs d'arbres enneigés (horizontal `64×32` et vertical `32×64`) et grand tas de bûches sous la neige (`64×32`).
      - **`Y = 4000..4128` (Igloos & Décorations d'Hiver)** : Grand Igloo familial en briques de neige/glace avec tunnel voûté et lueur chaude (`128×96`), Igloo traditionnel (`96×96`), Bonhomme de neige (`32×64`), souche-tabouret enneigée, traîneau en bois, séchoir à poissons, barrière en rondins sous la neige, tonneaux enneigés et puits gelé.
      - **`Y = 4128..4480` (Chalets en Bois Chaud, Cabanes en Rondins & Tente Nordique)** : Grand Chalet Alpin en bois chaud avec fenêtres dorées et gros toit de neige (`160×128`), Chalet en bois à 2 étages (`96×128`), Grande Cabane de Bûcheron / Trappeur en rondins avec bois de cerf et tas de bûches (`160×128`), Petite Cabane en bois enneigée (`96×96`), Refuge/Taverne de montagne en bois chaud (`160×96`) et Tente/Yourte nordique en fourrure et bois sous la neige (`96×96`).
- **Comment tester en jeu / dans RPG Maker XP** :
  - Ouvrir **RPG Maker XP** -> *Base de données (F9)* -> onglet *Tilesets* -> sélectionner le tileset utilisant `SubTileset_4_Villages_Freljord_Port.png` pour utiliser les nouvelles lignes (`Y = 3840..4480`) et les toits enneigés (`Y = 3200..3840`).
- **Comment désactiver en cas de bug** :
  - `git checkout HEAD~1 -- Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png` pour revenir à la version `256×3840 px`.

---

### `[AGY-019]` — 2026-10-12 — Extension majeure (6×) du Sous-Tileset 4 du Premier Village (`SubTileset_4_Villages_Freljord_Port.png`, `256×3840 px`)
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes (`Graphics/Tilesets/`)
- **Fichier modifié** :
  - `Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png` (Agrandissement de `256×640 px` à **`256×3840 px`**, soit 120 lignes de tuiles `32×32`) :
    - **`Y = 0..640` (Base 100 % rétro-compatible)** : Conservation stricte des coordonnées existantes pour ne casser aucune carte déjà commencée + détourage 100 % transparent du sapin individuel à `(192, 0)`.
    - **`Y = 640..1280` (Sols, Sentiers, Routes & Pavés)** : Neige poudreuse, congères, sentiers de neige tassée avec virages complets, routes de pierre froide, escaliers en bois/pierre, pavés de place publique, terre gelée et hautes herbes enneigées.
    - **`Y = 1280..1920` (Forêt Boréale, Arbres & Clôtures)** : Sapins individuels détourés (`2×3` cases sur fond transparent), bloc de forêt dense répétable, grands arbres ronds enneigés, petits conifères givrés, et kit complet de barrières/clôtures en bois et pierre.
    - **`Y = 1920..2560` (Falaises, Ponts, Quais & Eau glacée)** : Falaises enneigées complètes, entrée de grotte, rebords sautables, grand pic rocheux (`64×128`), ponts suspendus en bois (horizontaux et verticaux), grand escalier monumental en pierre, pontons en bois, berges d'eau glacée et pilotis du port.
    - **`Y = 2560..3200` (Mobilier urbain, Stands, Phare & Props)** : Panneaux en bois/pierre, boîtes aux lettres, pots de fleurs givrées, caisses, parterres de fleurs des neiges, 2 stands de marché couverts, lampadaires (orientés gauche/droite), phare rond du port, obélisque/statue, bancs publics, niches à Pokémon et camions de ravitaillement (100 % débarrassés des cases de croix rouges/bleues d'instructions).
    - **`Y = 3200..3840` (9 Bâtiments complets de Bourg-Givré)** : Maison de Soren, Maison à deux étages, Chalet en rondins, Sanctuaire de pierre, Boutique Pokémon (`MART`), Maison villageoise bleu glacier, Auberge/Taverne lavande, Petit cottage à toit bleu, Arène / Hall des Épreuves (`GYM`) + bannières tribales, braseros et Poros.
- **Comment tester en jeu / dans RPG Maker XP** :
  - Ouvrir **RPG Maker XP** -> *Base de données (F9)* -> onglet *Tilesets* -> sélectionner le tileset utilisant `SubTileset_4_Villages_Freljord_Port.png` pour configurer les praticabilités/priorités des nouvelles lignes (`Y = 640..3840`) et mapper **Bourg-Givré**.
- **Comment désactiver en cas de bug** :
  - `git checkout HEAD~1 -- Graphics/Tilesets/SubTileset_4_Villages_Freljord_Port.png` pour revenir à la version `256×640 px`.

---

### `[AGY-018]` --- 2026-10-12 --- Musiques BGM de la Cinematique Dirigeable de Noxus
- **Auteur** : `Antigravity`
- **Fichiers ajoutes** : `Audio/BGM/Freljord_Calme.mp3`, `Audio/BGM/Freljord_Tempete.mp3`
- **Fichier modifie** : `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb`
- **Detail** : `pbBGMPlay("Freljord_Calme")` au debut -> transition `pbBGMFade(2.5)` + `pbBGMPlay("Freljord_Tempete")` a l'arrivee du Dirigeable -> `pbBGMFade(4.0)` pendant le fondu final au noir.
- **Sources audio** : Route 216 Day (Pokemon D/P) + Battle Regirock/Regice/Registeel (Pokemon Pt) --- archive.org
- **Tester** : Lancer la cinematique -> neige calme au debut, tempete intense a l'arrivee du Dirigeable, fondu avec le noir.
- **Desactiver** : Commenter les 4 lignes `# [AGY-018]` dans le script + supprimer les 2 MP3 de `Audio/BGM/`.
### `[AGY-017]` — 2026-10-12 — Marche initiale du Sud vers le Nord en direction de l'Œuf & Trajet propre en file indienne jusqu'à l'échelle
- **Auteur** : `Antigravity`
- **Catégorie** : Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers modifiés** :
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` :
    - **Début de la cinématique (`pbCinematiqueDirigeableNoxus`)** : Valerius (`x = 256`) et ses 2 soldats (`x = 200` et `x = 312`) arrivent désormais en marchant du **Sud vers le Nord (`dir = 8`) directement en direction de l'Œuf d'Anivia**, et s'arrêtent devant l'Œuf face au Nord (`y = 288..296`).
    - **Trajet jusqu'à l'échelle de corde (`pbDirigeableNoxus_EmbarquementEchelle`)** : Suppression du contournement par le haut (qui faisait passer la soldate de droite à travers un pic de glace et glisser en diagonale). Les 3 Noxiens marchent désormais proprement en file indienne selon un trajet orthogonal **Ouest (`dir = 4`) sur la neige dégagée au Sud de l'Œuf jusqu'à `x = ladder_x`**, puis **Nord (`dir = 8`) tout droit dans le couloir dégagé jusqu'au pied de l'échelle**.
- **Comment tester en jeu** :
  - Lancer le jeu (**New Game**) : au début de la cinématique, on voit les 3 personnages marcher du Sud vers le Nord en direction de l'Œuf ; puis, quand l'échelle se déroule, ils rejoignent l'échelle en marchant vers la gauche puis vers le haut sans traverser aucun pic de glace ni glisser en diagonale.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

### `[AGY-016]` — 2026-10-12 — Agrandissement de l'Œuf d'Anivia (+36 % en blocs 3×3), suppression des cristaux latéraux & nettoyage du socle de glace
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes (`Pictures` / `Characters`) & Script Cinématique (`009_Overworld_Cinematics_LoL.rb`)
- **Fichiers modifiés** :
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png` (Suppression des 2 petits amas de cristaux turquoise sur les côtés, nettoyage des pixels blancs isolés/croix sombre au centre de la glace, et agrandissement du socle de Glace Pure sous l'Œuf `168×138`)
  - `Graphics/Pictures/Statue_Aigle_Glace_Anivia.png` (Nettoyage complet du socle de glace `3×3` sans point blanc ni découpe en vague)
  - `Graphics/Pictures/Oeuf_Anivia_Seul.png` & `Graphics/Characters/!Oeuf_Anivia.png` (Agrandissement de l'Œuf d'Anivia à `168×138` par frame, soit `672×552` pour la planche 4×4, avec un dôme d'Œuf +36 % plus grand sur la grille `3×3`)
  - `Graphics/Pictures/Dirigeable_Grappin_Oeuf.png`, `Graphics/Pictures/Dirigeable_Noxus_2_Capture.png`, `Graphics/Pictures/Dirigeable_Noxus_3_Explosion.png`, `Graphics/Pictures/Cinematic_Dirigeable_Noxus_3Frames.png` (Intégration de l'Œuf agrandi et nettoyé dans les pinces du treuil du Dirigeable)
  - `Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb` (Alignement au pixel près de `!Oeuf_Anivia` agrandi `168×138` sur `y = 150..288`)
- **Comment tester en jeu** :
  - Lancer le jeu (**New Game**) : l'Œuf d'Anivia est nettement plus grand et imposant devant la Statue en Glace d'Anivia (et dans les pinces du treuil lors de la capture), les petits cristaux sur les côtés ont disparu et le socle de glace est parfaitement propre.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

### `[AGY-015]` — 2026-10-12 — Ajout de la Statue en Glace Pure d'Anivia au centre derrière l'Œuf (grille 3×3 identique à l'Œuf) & Glace au sol lisse
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes (`Pictures`)
- **Fichiers créés / modifiés** :
  - `Graphics/Pictures/Fond_Sanctuaire_Glace.png` (Ajout de la grande Statue en Glace Pure d'Anivia `162×150` en plein centre derrière l'Œuf d'Anivia, de bouquets de cristaux de Glace Pure sur les flancs nord, et lissage complet des plaques de glace au sol sans traits ni rayures)
  - `Graphics/Pictures/Statue_Aigle_Glace_Anivia.png` (Sprite isolé `162×150` de la Statue en Glace Pure d'Anivia sculptée sur la même grille de blocs `3×3` et le même damier cristallin bleu/turquoise que `Oeuf_Anivia_Seul_Big.png`)
- **Comment tester en jeu** :
  - Lancer le jeu (**New Game**) : au sommet enneigé du Sanctuaire d'Anivia, la grande Statue en Glace Pure d'Anivia trône désormais en plein centre derrière l'Œuf (en laissant le couloir de l'échelle de corde `x = 169` totalement dégagé), et la glace au sol est parfaitement lisse.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` pour revenir à l'état précédent.

---

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

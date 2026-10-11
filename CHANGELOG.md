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

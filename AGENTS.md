# AGENTS.md — Guide de coordination (Jules AI & Antigravity)

Ce dépôt contient un projet **Pokémon Essentials v21.1** (RPG Maker XP / Ruby RGSS). Ce fichier sert de référence commune pour **Jules AI** (sur GitHub) et **Antigravity** (en local) afin de travailler ensemble sans conflits.

---

## 1. Architecture du projet

- **`Data/Scripts/`** : Scripts Ruby du moteur Pokémon Essentials v21.1, organisés par dossiers numérotés (`001_Technical`, `010_Data`, `011_Battle`, etc.).
  - Pour ajouter de nouvelles mécaniques, privilégier un nouveau script ou un dossier dédié dans `Plugins/` ou à la fin de la section appropriée de `Data/Scripts/` afin d'éviter les conflits de fusion.
- **`PBS/`** : Fichiers texte de données du jeu (`pokemon.txt`, `pokemon_metrics.txt`, `moves.txt`, `abilities.txt`, `items.txt`, `encounters.txt`, `trainers.txt`, `map_metadata.txt`, etc.).
  - **Encodage obligatoire** : UTF-8 (sans caractères doublement encodés).
  - **Séparateur obligatoire** : chaque section commence par `#-------------------------------` suivi de `[ID_INTERNE]`.
  - **Règle anti-conflit** : toujours ajouter les nouvelles entrées **tout à la fin** du fichier `PBS/*.txt` concerné.
- **`Graphics/Pokemon/`** :
  - `Front/` et `Front shiny/` : Sprites de face 160×160 PNG (grille pixel-art 2×2 style Gen 5, fond transparent).
  - `Back/` et `Back shiny/` : Sprites de dos 160×160 PNG (vraie vue de dos à 180°, même palette que la face, fond transparent).
  - `Icons/` et `Icons shiny/` : Icônes d'équipe animées 128×64 PNG (2 frames de 64×64 côte à côte).
  - `Footprints/` : Empreintes 16×16 PNG.
- **`Data/*.dat` (ignorés par Git)** :
  - Les fichiers compilés (`species.dat`, `moves.dat`, `trainers.dat`, etc.) sont générés automatiquement au lancement du jeu en mode Debug. **Ne jamais les commiter** pour éviter les conflits binaires.
- **`Data/*.rxdata` (suivis par Git)** :
  - Cartes RPG Maker XP (`MapXXX.rxdata`, `MapInfos.rxdata`, `Tilesets.rxdata`, `CommonEvents.rxdata`, `System.rxdata`).

---

## 2. Pokémon personnalisés installés (Génération 9 / Custom)

Les Pokémon suivants sont déjà intégrés dans `PBS/pokemon.txt`, `PBS/pokemon_metrics.txt` et `Graphics/Pokemon/` :

| ID Interne (`[ID]`) | Nom FR | Types | Inspiration / Concept |
| :--- | :--- | :--- | :--- |
| `[CAMALYX]` | **Camalyx** | `ICE,ELECTRIC` | Lynx espiègle avec yeux-objectifs photo et oreilles-micros |
| `[ZIGGS]` | **Ziggs** | `FIRE,STEEL` | Petit rongeur artificier hyperactif aux bombes minérales |
| `[KINDRAME]` | **Kindrâme** | `GHOST,FAIRY` | Duo d'esprits masqués (Agneau spectral & Loup d'ombre — *Kindred*) |
| `[AURELIASTRE]` | **Aureliastre** | `DRAGON,PSYCHIC` | Dragon stellaire serpentin entouré d'astres (*Aurelion Sol*) |
| `[VORAGATH]` | **Voragath** | `DARK,BUG` | Béhémoth abyssal à carapace chitineuse rouge (*Cho'Gath*) |
| `[SYLVERN]` | **Sylvern** | `GRASS,FAIRY` | Esprit-arbre sylvestre à bois fleuris (*Ivern*) |
| `[ROCPHITE]` | **Rocphite** | `ROCK,GROUND` | Colosse monolithique de basalte et granit (*Malphite*) |
| `[XENOSAI]` | **Xenosai** | `GROUND,DARK` | Prédatrice souterraine cuirassée du Néant (*Rek'Sai*) |
| `[OMBREVEX]` | **Ombrevex** | `DARK,GHOST` | Créature féline-lapin mélancolique à ombre vivante (*Vex*) |
| `[FIDDLEFFROI]` | **Fiddleffroi** | `GHOST,DARK` | Épouvantail-corbeau spectral à lanterne ardente (*Fiddlesticks*) |

---

## 3. Règles de workflow Git (Jules AI & Local)

1. **Branche principale (`main`)** :
   - Les ajouts locaux de sprites et de Pokémon validés avec **Antigravity** sont poussés directement sur `main`.
2. **Branches de fonctionnalités (Jules AI)** :
   - **Jules AI** crée une branche dédiée par tâche à partir de `main` et ouvre une Pull Request claire et ciblée.
   - Une branche = une fonctionnalité ou un correctif précis (ex. `feat/custom-moves`, `feat/new-trainers`, `fix/battle-ai`).
   - Ne jamais écraser ou supprimer les entrées personnalisées existantes à la fin des fichiers `PBS/*.txt`.

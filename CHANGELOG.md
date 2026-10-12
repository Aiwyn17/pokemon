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

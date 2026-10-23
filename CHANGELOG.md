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


### `[AGY-099]` — 2026-10-23 — Intégration d'Advanced AI System v2.0 (v2.7.2) pour Pokémon Essentials v21.1 & Compatibilité DBK
- **Auteur** : `Antigravity`
- **Catégorie** : IA de Combat Stratégique, Méta-Mécaniques & Plugins (`Plugins/[AAI] Advanced AI System/`)
- **Demande Utilisateur** : 
  - *« oui fais le necessaire »* (suite à l'analyse du plugin *[Plugin] Advanced AI System v2.0 — Master-Tier Intelligence for Pokémon Essentials* dans l'archive fournie `media_1792788928077_2b1285c6.zip`).
- **Contenu Intégré & Optimisations** :
  1. **Déploiement complet d'Advanced AI System v2.7.2** :
     - 7 modules stratégiques déployés dans `Plugins/[AAI] Advanced AI System/` :
       - `1_Core/` (`0_Settings.rb`, `Combat_Utilities.rb`, `Core.rb`, `Debug_Menu.rb`, `Illusion_Perception.rb`, `OptionsMenu.rb`, `Utilities.rb`)
       - `2_Move_Intelligence/` (`0_Move_Scorer.rb`, `Disruption_Moves.rb`, `Move_Categories.rb`, `Move_Memory.rb`, `Special_Moves.rb`)
       - `3_Combat_Mechanics/` (`Advanced_Abilities.rb`, `Field_Effects.rb`, `Recoil_Tracking.rb`, `Weather_Terrain_Wars.rb`)
       - `4_Battle_Strategy/` (`Advanced_Items.rb`, `Item_Intelligence.rb`, `Prediction_System.rb`, `Role_Detection.rb`, `Setup_Recognition.rb`, `Strategic_Awareness.rb`, `Switch_Intelligence.rb`, `Tactical_Enhancements.rb`, `Team_Preview_Intelligence.rb`, `Threat_Assessment.rb`)
       - `5_Format_Specific/` (`Doubles_Coordination.rb`, `Doubles_Strategy.rb`, `Pivot_Moves.rb`, `Priority_Tiers.rb`, `Speed_Tiers.rb`)
       - `6_Meta_Mechanics/` (`Battle_Personalities.rb`, `Dynamax_Intelligence.rb`, `Endgame_Scenarios.rb`, `Mega_Intelligence.rb`, `Terastallization_Intelligence.rb`, `Win_Conditions.rb`, `ZMove_Intelligence.rb`)
       - `7_Integration/` (`Console_Fix.rb`, `Custom_Content.rb`, `DBK_Compatibility.rb`, `Debug_Replacement.rb`, `Hotfixes.rb`, `Mechanics_Hooks.rb`, `Per_Trainer_Flags.rb`, `Switch_Determinism.rb`, `Switch_Turn_Guard.rb`)
       - `meta.txt` (v2.7.2 par NoNoNever).
  2. **Paramétrage & Équilibrage Fin dans `0_Settings.rb`** :
     - `SHOW_MOVE_EXPLANATIONS = false` : désactivation de l'affichage textuel interne de débogage ("Thunder Wave (Paralyze fast threat)") pour que les dialogues de combat restent fluides et immersifs pour le joueur.
     - `ENABLE_WILD_POKEMON_AI = false` : maintien d'une IA naturelle pour les créatures sauvages de Freljord (permet de capturer normalement les Pokémon sans subir d'anti-stratégie / switches hyper-compétitifs de bêtes sauvages de bas niveau).
     - `MIN_SKILL_FOR_AUTO_ACTIVATION = 70` : Les dresseurs débutants de route restent accessibles, tandis que les Dresseurs d'Élite, Chefs d'Arène, Gardiens d'Épreuve et Commandants Noxiens (Kael, Valerius) activent l'intelligence Master-Tier.
  3. **Synergie avec Deluxe Battle Kit & Mécaniques LoL** :
     - Module `DBK_Compatibility.rb` natif synchronisé avec le `[DBK_000] Deluxe Battle Kit` installé.
     - Prise en charge des drapeaux par dresseur dans `PBS/trainers.txt` (`Skill = 100`, etc.).
     - Préservation complète des calculs d'Armure / Résistance Magique et Sorts d'Invocateur LoL.
- **Fichiers créés / modifiés** :
  - `Plugins/[AAI] Advanced AI System/` (ensemble des scripts v2.7.2)
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Lancer un combat contre un dresseur avec `Skill = 70` ou plus (ex: Chef Noxien ou Gardien d'Épreuve) : l'IA analyse les types, switch intelligemment, anticipe les menaces et utilise les synergies.
- **Comment désactiver en cas de bug** :
  - Mettre `ENABLED = false` dans `Plugins/[AAI] Advanced AI System/1_Core/0_Settings.rb` ou `git revert HEAD`


### `[AGY-098]` — 2026-10-23 — Intégration d'Item Crafting UI Plus v3.0.0 & Système de Forge d'Objets LoL
- **Auteur** : `Antigravity`
- **Catégorie** : Artisanat d'Objets, Forge & Plugins (`Plugins/Item Crafting UI Plus/`, `PBS/recipes.txt`, `Graphics/UI/Crafting/`)
- **Demande Utilisateur** : 
  - *« installe le plugin pour le moment »* (suite à la validation du besoin de combiner des composants LoL, ex: 2 épées = 1 B.F. Glaive).
  - Archive fournie : `media_1792788028181_5fbc5b7a.zip` (*Item Crafting UI Plus v3.0.0* par ThatWelshOne_ et Vendily pour Pokémon Essentials v21.1).
- **Contenu Intégré & Optimisations** :
  1. **Déploiement Complet de la Version v21 (Essentials v21.1)** :
     - Plugin déployé dans `Plugins/Item Crafting UI Plus/` (`meta.txt`, `001_UI_ItemCrafting.rb`, `002_Recipe.rb`, `003_CompilerChanges.rb`, `004_PokemonGlobal_UserFunctions.rb`).
     - Assets graphiques déployés dans `Graphics/UI/Crafting/` (`base.png`, `bg.png`) et `Graphics/Items/Category/` (`berry.png`).
     - Base de données créée dans `PBS/recipes.txt` avec formatage strict Essentials.
  2. **Système de Recettes et Arbre de Craft LoL Pré-Configuré** :
     - Recette du **B.F. Glaive** (`[BFSword]`) : 2x `LONGSWORD` -> 1x `BFSWORD` (`+20 AD`).
     - Recette de la **Lame d'Infini** (`[InfinityEdge]`) : 1x `BFSWORD` + 1x `PICKAXE` -> 1x `INFINITYEDGE` (`+30 AD`, `+25% Crit`).
     - Recette de la **Cotte de Mailles** (`[ChainVest]`) : 2x `CLOTHARMOR` -> 1x `CHAINVEST` (`+15 Armure`).
     - Recette de la **Cotte Épineuse** (`[Thornmail]`) : 1x `CHAINVEST` + 1x `RUBYCRYSTAL` -> 1x `THORNMAIL` (`+35 Armure`, `+300 PV`).
     - Recettes classiques incluses : Jus de Baie (`BerryJuice`) et fragmentation de Rappel Max (`BreakMaxRevive`).
  3. **Correctifs & Fonctions Raccourcies (`003`, `004`)** :
     - Correction du bug `data_hash[:id]` dans `validate_compiled_recipe` pour éviter les `NameError`.
     - Sécurisation contre le splat nil dans le compilateur si des fichiers de recettes manquent.
     - Prise en charge des symboles et chaînes dans `pbUnlockRecipe`, `pbLockRecipe` et `pbKnowsRecipe?`.
     - Ajout de la fonction pratique `pbOpenForge(flag)` pour ouvrir directement l'interface de craft devant une enclume ou auprès d'un PNJ forgeron.
- **Fichiers créés / modifiés** :
  - `Plugins/Item Crafting UI Plus/meta.txt`
  - `Plugins/Item Crafting UI Plus/001_UI_ItemCrafting.rb`
  - `Plugins/Item Crafting UI Plus/002_Recipe.rb`
  - `Plugins/Item Crafting UI Plus/003_CompilerChanges.rb`
  - `Plugins/Item Crafting UI Plus/004_PokemonGlobal_UserFunctions.rb`
  - `Graphics/UI/Crafting/base.png`
  - `Graphics/UI/Crafting/bg.png`
  - `Graphics/Items/Category/berry.png`
  - `PBS/recipes.txt`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Dans un événement RPG Maker ou en console Debug :
    - Apprendre la recette : `pbUnlockRecipe(:BFSword)`
    - Ouvrir la forge : `pbOpenForge` ou `pbItemCrafter(pbGetRecipes)`
  - Acheter 2 Épées Longues et forger le B.F. Glaive dans l'interface animée.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-097]` — 2026-10-23 — Déploiement des Quêtes Scénarisées de Freljord (Acte 1) & Quêtes Secondaires LoL
- **Auteur** : `Antigravity`
- **Catégorie** : Quêtes Scénarisées & Intégration Événements (`Plugins/MQS/005_Quest_MenuHandlers.rb`)
- **Demande Utilisateur** : 
  - *« tu sais mettre les quetes avec ce plugin pour mon jeu »*
- **Contenu Intégré & Optimisations** :
  1. **5 Quêtes Principales de l'Histoire (Scénario Acte 1 : Freljord & Menace Noxienne)** :
     - `:Quest_Prologue` (*L'Éveil du Freljord*) : Choix du premier Pokémon, assaut du Dirigeable noxien sur le Sanctuaire d'Anivia, descente du sommet.
     - `:Quest_Route1` (*La Traversée du Blizzard*) : Traversée des herbes hautes enneigées, affrontement des éclaireurs noxiens, arrivée aux portes de Havre-Givre.
     - `:Quest_Refuge` (*Le Dernier Rempart*) : Réchauffement de l'équipe au coin du feu, ravitaillement au Poste de Traite, entretien avec l'Éclaireur de la Griffe.
     - `:Quest_Epreuve` (*L'Épreuve des Quatre Démi-Dieux*) : Éveil des 4 Statues runiques (Volibear, Loup, Ornn, Anivia), matérialisation du Pont de Glace et affrontement du Gardien Ancestral.
     - `:Quest_CrashNoxus` (*Le Siège de l'Épave*) : Infiltration de la carcasse fumante du Dirigeable noxien, duel tactique contre le Commandant Kael et sauvetage de l'Œuf d'Anivia.
  2. **4 Quêtes Secondaires Immersives (LoL & Freljord)** :
     - `:Quest_PoroPerdu` (*Un Poro dans la Tourmente*) : Recherche d'un Poro égaré sous les grands sapins de la Route 1 avec récompense Poro-Snax.
     - `:Quest_ChasseursGivre` (*Le Bestiaire du Pergélisol*) : Recensement et capture des espèces endémiques de Freljord (Blizzapin, Givracorn, Cryocrust).
     - `:Quest_BraisesOrnn` (*Les Vestiges de la Forge*) : Collecte de basalte ardent pour raviver l'antique enclume d'Ornn et forger la Cotte Épineuse.
     - `:Quest_ZiggsExplosif` (*L'Artificier Déjanté*) : Enquête sur les explosions mystérieuses de la crête, duel contre Ziggs et déblaiement du passage.
  3. **Connexions & Déclencheurs Automatiques dans l'Overworld** :
     - Déclenchement automatique dès la sélection du Starter (`DiegoWTsStarterSelection` ou `pbFreljordStarterSelection`).
     - Progression automatique au passage des cartes (`on_enter_map` : Route 1, Havre-Givre, Caverne de l'Épreuve).
     - Avancement automatique lors du Soin au refuge (`pbHealAtHavreGivreRefuge`), des achats en boutique (`pbShopHavreGivre`) et de chaque statue activée (`pbActivateStatue`).
- **Fichiers créés / modifiés** :
  - `Plugins/MQS/005_Quest_MenuHandlers.rb`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Ouvrir le Menu Pause (Échap / X) -> « Quêtes ».
  - Ou exécuter en console / événement : `activateQuest(:Quest_Prologue, colorQuest("blue"), true)`.
  - Observer la notification visuelle et sonore `New task added!` et l'actualisation sur la Carte Régionale.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-096]` — 2026-10-23 — Intégration de Modern Quest System + UI v1.1.0 (Eevee Expo #709)
- **Auteur** : `Antigravity`
- **Catégorie** : Journal de Quêtes, Interface & Plugins (`Plugins/MQS/`, `Graphics/UI/QuestUI/`)
- **Demande Utilisateur** : 
  - *« https://eeveeexpo.com/resources/709/ fais ca aussi »*
  - Archive fournie : `media_1792787076344_371077ac.zip` (*Modern Quest System + UI v1.1.0* par ThatWelshOne_, mej71, derFischae, Marin pour Pokémon Essentials v21.1).
- **Contenu Intégré & Optimisations** :
  1. **Installation Complète** :
     - Plugin déployé dans `Plugins/MQS/` (`meta.txt`, `001_Quest_Config.rb`, `002_Quest_Main.rb`, `003_Quest_UI.rb`, `004_Quest_Data.rb`).
     - Tous les 7 assets graphiques d'interface déployés dans `Graphics/UI/QuestUI/` (fonds d'écran parchemin/ardoise, onglets d'état, badges NEW, icônes de navigation).
  2. **Intégration Menu Pause & Sécurisation Moteur (`005_Quest_MenuHandlers.rb`)** :
     - Ajout automatique de l'entrée « Quêtes » dans le Menu Pause (`MenuHandlers.add(:pause_menu, :quests)`), accessible directement en jeu via Échap ou touche X.
     - Sécurisation nil-safety de la carte d'origine (`originalMap = quest.location || "???"`) pour prévenir les crashes lors de l'affichage des détails si une quête est activée hors map.
     - Gestion paresseuse des sauvegardes : `$PokemonGlobal.quests` s'initialise automatiquement sans corrompre ni exiger de réinitialiser les fichiers de sauvegarde existants.
  3. **Synergie Immédiate avec Arcky's Region Map v3.3.0** :
     - Déverrouille instantanément le mode **Quest Map** (`ModeNames[:quest] = "Quest Map"`) sur la carte régionale pour visualiser géographiquement les quêtes actives et leurs objectifs.
  4. **Quête Principale de l'Acte 1 Pré-Configurée (`QuestFreljord1`)** :
     - Intégration de la quête narrative : *L'Éveil du Freljord* (Sanctuaire des Glaces -> Havre-Givre -> Caverne sacrée de l'Épreuve) avec gestion d'étapes dynamiques.
- **Fichiers créés / modifiés** :
  - `Plugins/MQS/meta.txt`
  - `Plugins/MQS/001_Quest_Config.rb`
  - `Plugins/MQS/002_Quest_Main.rb`
  - `Plugins/MQS/003_Quest_UI.rb`
  - `Plugins/MQS/004_Quest_Data.rb`
  - `Plugins/MQS/005_Quest_MenuHandlers.rb`
  - `Graphics/UI/QuestUI/*` (7 fichiers PNG)
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Ouvrir le Menu Pause (Échap / X) et sélectionner l'option « Quêtes ».
  - Ou appeler en script/événement : `activateQuest(:QuestFreljord1, colorQuest("blue"), true)`.
  - Ouvrir la Carte Régionale (Poké-Matos ou Sac) et appuyer sur Action/Shift pour basculer en mode Quest Map.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-095]` — 2026-10-23 — Intégration de DiegoWT's Starter Selection v1.5.0
- **Auteur** : `Antigravity`
- **Catégorie** : Sélection de Starter, Interface & Plugins (`Plugins/DiegoWT's Starter Selection/`, `Graphics/UI/DiegoWT's Starter Selection/`, `Graphics/Windowskins/`)
- **Demande Utilisateur** : 
  - *« ca mtn »* avec l'archive `media_1792786173942_2bc9f2aa.zip` (*DiegoWT's Starter Selection v1.5.0* pour Essentials v21.1).
- **Contenu Intégré & Optimisations** :
  1. **Installation Complète** :
     - Plugin déployé dans `Plugins/DiegoWT's Starter Selection/` (`meta.txt`, `Script.rb`, `Settings.rb`).
     - Tous les 17 assets graphiques d'interface déployés dans `Graphics/UI/DiegoWT's Starter Selection/` (Poké Balls animées, socles, surbrillances, curseurs, fenêtres BW/HGSS, dégradés de double type).
     - Skin sans bordure installé dans `Graphics/Windowskins/nil skin.png`.
  2. **Compatibilité & Correctifs Appliqués** :
     - Correction du bug natif des vérifications Shiny pour le starter 2 et starter 3 (`STARTER2SHINY` et `STARTER3SHINY`).
     - Sécurisation de la méthode `pbTypeColor` avec `return typeColor` direct et fallback dynamique pour les types personnalisés.
     - Ajout de la fonction raccourcie d'événement `pbFreljordStarterSelection` appelant directement les 3 starters personnalisés de l'Acte 1 (`:GELOUPIOT`, `:TYRAKOUP`, `:VEILLIRIS`).
  3. **Fonctionnalités Clés** :
     - Sélection interactive et animée des starters avec zoom, ombres portées et secousse de Poké Balls.
     - Support des doubles types avec double dégradé lumineux personnalisé.
     - Cris authentiques lors du choix (`STARTERCRY = true`).
     - Attribution automatique du Pokémon choisi au joueur avec IVs, forme, objet et brillance configurables dans `Settings.rb`.
- **Fichiers créés / modifiés** :
  - `Plugins/DiegoWT's Starter Selection/meta.txt`
  - `Plugins/DiegoWT's Starter Selection/Script.rb`
  - `Plugins/DiegoWT's Starter Selection/Settings.rb`
  - `Graphics/UI/DiegoWT's Starter Selection/*` (17 fichiers PNG)
  - `Graphics/Windowskins/nil skin.png`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Dans un événement RPG Maker XP (ou en console Debug) : appeler `pbFreljordStarterSelection` ou `DiegoWTsStarterSelection.new(:GELOUPIOT, :TYRAKOUP, :VEILLIRIS)`.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-094]` — 2026-10-23 — Intégration d'Arcky's Poké Market v1.7.0 (Guide Officiel)
- **Auteur** : `Antigravity`
- **Catégorie** : Boutiques, Économie & Plugins (`Plugins/Arcky's Poke Market/`, `Graphics/UI/Mart/`)
- **Demande Utilisateur** :
  - *« https://docs.arcky-tech.be/poke-market pareil »*
  - Archive fournie : `media_1792785205993_6d1dd883.zip` (*Arcky's Poké Market v1.7.0*).
- **Conformité Stricte aux Directives Officielles (Arcky-Tech Docs)** :
  1. **Dépendance Prérequise Validée** :
     - Utilise *Arcky's Utilities v1.1.0* (déjà installé lors de l'étape précédente, `Requires = Arcky's Utilities, 1.1.0` parfaitement honoré).
  2. **Structure des Répertoires Respectée** :
     - Plugin complet extrait dans `Plugins/Arcky's Poke Market/`.
     - Intégration des graphismes d'étagères pour Pokémon Essentials v21.1 dans [`Graphics/UI/Mart/`](file:///c:/Users/Mon%20POc/3D%20Objects/Pokemon%20Essentials%20v21.1%202023-07-30/Graphics/UI/Mart/) (`bg_shelf.png`, `cursor_shelf.png`).
  3. **Fonctionnalités Clés Activées** :
     - **Transitions Fluides d'Argent** : Animation fluide du compteur d'or / monnaie lors des achats et ventes.
     - **Achats en Rayon (Shelf Shopping)** : Possibilité de faire ses courses directement sur les étagères des boutiques via `pbShelfMart`.
     - **Vendeurs & Marchands Spécialisés** : Dialogues vivants, personnalités de marchands, gestion des dettes/factures, remises et surtaxes.
     - **Multi-Devises** : Support natif de l'Argent standard ($), des Jetons de Casino, des Points de Combat (BP) ou d'objets spécifiques comme monnaie d'échange.
     - **Vente de Pokémon en Boutique** : Vendeurs clandestins ou marchands de créatures avec personnalisation complète des stats et prix.
- **Fichiers créés / modifiés** :
  - `Plugins/Arcky's Poke Market/` (suite complète v1.7.0)
  - `Graphics/UI/Mart/bg_shelf.png`
  - `Graphics/UI/Mart/cursor_shelf.png`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Interagir avec un comptoir de Boutique Pokémon standard ou un événement appelant `pbPokemonMart(:normalStore)` ou `pbShelfMart`.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-093]` — 2026-10-23 — Intégration d'Arcky's Region Map v3.3.0 & Arcky's Utilities v1.1.0 (Guide Officiel)
- **Auteur** : `Antigravity`
- **Catégorie** : Carte Régionale, Interface & Plugins (`Plugins/Arcky's Region Map/`, `Plugins/Arcky's Utilities/`, `Graphics/`, Racine)
- **Demande Utilisateur** :
  - *« https://docs.arcky-tech.be/region-map tu sais me rajouter ca selon les regles du site web ou il y a tout expliquer »*
  - Archives fournies : `media_1792784452117_f09a9f3e.zip` (*Arcky's Utilities v1.1.0*) et `media_1792784456989_790e4181.zip` (*Arcky's Region Map v3.3.0*).
- **Conformité Stricte aux Directives Officielles (Arcky-Tech Docs)** :
  1. **Dépendance Prérequise Installée** :
     - Installation d'*Arcky's Utilities v1.1.0* dans `Plugins/Arcky's Utilities/` (`Requires = Arcky's Utilities, 1.0.9` satisfait).
  2. **Structure des Répertoires Respectée** :
     - Plugin principal extrait dans `Plugins/Arcky's Region Map/`.
     - Intégration complète des ressources graphiques dans `Graphics/UI/Town Map/` (7 thèmes d'interface au choix, boîtes d'aperçu de lieux, météo, quêtes, baies, surbrillances de routes, icônes de vol et de dresseurs).
     - Déploiement des surcouches Pokédex dans `Graphics/UI/Pokedex/` et des icônes cardinales dans `Graphics/Icons/`.
     - Mise en place de `townmapgen v21.1.html` à la racine du projet pour la génération assistée des coordonnées PBS.
  3. **Configuration & Support des Lieux de Freljord** :
     - Ajout de l'entrée de lieu `HavreGivre` dans [`001_RegionMap_LocationInfo.rb`](file:///c:/Users/Mon%20POc/3D%20Objects/Pokemon%20Essentials%20v21.1%202023-07-30/Plugins/Arcky's%20Region%20Map/000_Settings_and_Setup/001_RegionMap_LocationInfo.rb) pour le village fortifié de l'Acte 1.
     - Prise en charge du zoom carte (`Ctrl` / touches de saut), du changement de région, de la recherche rapide et de la compatibilité souris (`Input::MOUSELEFT`, `Input::MOUSERIGHT`).
- **Fichiers créés / modifiés** :
  - `Plugins/Arcky's Utilities/` (suite complète v1.1.0)
  - `Plugins/Arcky's Region Map/` (suite complète v3.3.0)
  - `Graphics/UI/Town Map/` (thèmes, icônes et surbrillances)
  - `Graphics/UI/Pokedex/`
  - `Graphics/Icons/`
  - `townmapgen v21.1.html`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Ouvrir la Carte Régionale (depuis le Poké-Matos / Sac / Événement PNJ).
  - Observer la nouvelle interface HD dynamique avec zoom, navigation fluide, aperçu météo et descriptions de lieux.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-092]` — 2026-10-23 — Intégration du Deluxe Battle Kit (DBK v1.3.1) & Sorts d'Invocateur LoL (Option 4 : Combats Dresseurs/Boss & IA Tactique)
- **Auteur** : `Antigravity`
- **Catégorie** : Combat, Moteur & Plugins (`Plugins/[DBK_000] Deluxe Battle Kit/`, `Plugins/[LoL_000] Summoner Spells/`, `Audio/`, `Graphics/`)
- **Demande Utilisateur** :
  - *« jaimerai bien utilise le deluxe kit battle qui est tres populaire tu sais lapadter pour mon jeu et lutiliser »*
  - Validation de l'**Option 4** : Sorts d'Invocateur réservés aux combats de dresseurs et boss (désactivés contre les petits Pokémon sauvages), avec sorts équipés pour les Boss/Dresseurs adverses et une **IA ennemie intelligente et tactique**.
- **Réalisations & Adaptations Moteur** :
  1. **Intégration du Deluxe Battle Kit v1.3.1 (`[DBK_000] Deluxe Battle Kit`)** :
     - Déploiement complet de la suite DBK par Lucidious89 : HUD et barres de combat retravaillées, animations d'action, musique dynamique de PV faibles (`Battle low HP.ogg`), effets sonores (`DX Action.ogg`), boutons d'action du Fight Menu.
     - Ajustement de compatibilité dans `meta.txt` (`Requires = v21.1 Hotfixes,1.0.7`).
  2. **Préservation Critique de la Formule de Dégâts League of Legends** :
     - DBK réécrivait par défaut le calcul des dégâts avec la formule classique Pokémon (`... / defense`).
     - Patch immédiat de `[002] Damage Calc Refactor.rb` pour le joueur et pour l'IA :
       - Application stricte de la formule d'Armure LoL : `damage = (raw_damage * (100.0 / (100.0 + defense))).floor`.
       - Maintien des pénétrations d'armure / RM (`Bâton du Vide`, `Salutations de Dominik`, etc.).
       - Prise en compte des bonus de dégâts critiques LoL (Lame d'Infini, Danseur Fantôme, Canon Ultrarapide, Zèle).
  3. **Système de Sorts d'Invocateur LoL (`Plugins/[LoL_000] Summoner Spells/`)** :
     - **Condition d'activation stricte (Option 4)** : Uniquement en duel de Dresseurs ou Boss (`@battle.trainerBattle?`). Inactif contre les Pokémon sauvages des herbes.
     - **Les 5 Sorts Iconiques LoL** :
       - ⚡ **Saut Éclair (Flash)** : Esquive garantie du prochain coup fatal direct adverse ce tour.
       - 🔥 **Embrasement (Ignite)** : Enflamme la cible pendant 4 tours, infligeant 1/8 PV bruts à chaque fin de tour et applique Hémorragie (-50% aux soins reçus).
       - 💚 **Soin (Heal)** : Restaure 35 % des PV max, dissipe la confusion et augmente la Vitesse d'un niveau pendant 1 tour.
       - 🛡️ **Barrière (Barrier)** : Génère un bouclier absorbant les dégâts jusqu'à 40 % des PV max pendant 2 tours.
       - 🌀 **Fatigue (Exhaust)** : Réduit de 35 % les dégâts infligés et de 30 % la Vitesse de la cible pendant 2 tours.
     - **Intelligence Artificielle Tactique Ennemie (`004_Summoner_Spells_AI.rb`)** :
       - **Ignite Kill-Secure** : L'IA claque Embrasement si le Pokémon du joueur passe sous les 35 % de PV pour achever le kill et bloquer les soins.
       - **Flash Reflex** : L'IA claque Saut Éclair si son propre Pokémon est en situation critique (PV <= 25 %) pour esquiver le coup de grâce.
       - **Heal & Barrier Clutch** : L'IA protège son Pokémon avec Barrière ou le soigne avec Soin en cas de danger de mort.
       - **Exhaust Threat-Neutralization** : L'IA neutralise le Pokémon du joueur avec Fatigue s'il accumule des buffs offensifs (+2 Attaque/SpAtk).
     - **Interface Utilisateur Épurée** :
       - En combat de dresseur, la commande « Fuite » (inutile en duel) ouvre directement le menu des Sorts d'Invocateur avec affichage des états `[PRÊT]` / `[UTILISÉ]` et confirmation. Accessible également via la touche Action / Shift.
- **Fichiers créés / modifiés** :
  - `Plugins/[DBK_000] Deluxe Battle Kit/` (suite complète adaptée)
  - `Plugins/[LoL_000] Summoner Spells/meta.txt`
  - `Plugins/[LoL_000] Summoner Spells/001_Summoner_Spells_Core.rb`
  - `Plugins/[LoL_000] Summoner Spells/002_Summoner_Spells_BattleHooks.rb`
  - `Plugins/[LoL_000] Summoner Spells/003_Summoner_Spells_UI.rb`
  - `Plugins/[LoL_000] Summoner Spells/004_Summoner_Spells_AI.rb`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Lancer un combat contre un dresseur (ex: Kael ou PNJ de test).
  - Sélectionner la 4e option du menu (ou appuyer sur Shift/Action) pour ouvrir le menu des Sorts d'Invocateur.
  - Observer l'IA ennemie utiliser ses propres sorts tactiquement selon l'état des PV.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`


---

### `[AGY-091]` — 2026-10-23 — Résolution Définitive : Correction du Type `item_id` (Symbole) & Actualisation au Chargement de Sauvegarde
- **Auteur** : `Antigravity`
- **Catégorie** : Moteur de Données & Sauvegardes (`Data/Scripts/014_Pokemon/`, `Data/Scripts/002_Save data/`)
- **Problème Identifié par l'Utilisateur** :
  - *« ça marche toujours pas »* (capture montrant Fenrimas avec 14 Armure et 13 AP malgré le Sablier de Zhonya).
  - **Origine Racine du Bug** : Dans la classe `Pokemon`, la méthode `self.item` renvoie une instance d'objet `GameData::Item` (et non un `Symbol`). Par conséquent, l'expression `case self.item` échouait toujours (`GameData::Item == :ZHONYASHOURGLASS` vaut `false` en Ruby).
  - De plus, les données de l'équipe contenues dans un fichier de sauvegarde déjà existant conservaient les anciennes stats calculées sans déclencher `calc_stats` au chargement de la partie.
- **Correctifs Appliqués** :
  1. **Utilisation stricte de `item_id` (`001_Pokemon.rb`)** :
     - Utilisation de `held_item_id = self.item_id || ...` pour comparer avec les symboles (`:ZHONYASHOURGLASS`, `:WARMOGSARMOR`, etc.). Le `case` s'exécute désormais à 100%.
  2. **Actualisation Automatique au Chargement de Sauvegarde (`004_Game_SaveValues.rb`)** :
     - Dès qu'une partie est chargée, `$player.party.each { |pkmn| pkmn.calc_stats }` est exécuté automatiquement pour que chaque Pokémon existant voie ses stats recalculées immédiatement.
- **Fichiers modifiés** :
  - `Data/Scripts/014_Pokemon/001_Pokemon.rb`
  - `Data/Scripts/002_Save data/004_Game_SaveValues.rb`
  - `CHANGELOG.md`
- **Résultat Immédiat sur Fenrimas (Niv. 5)** :
  - **Armure** : passe de 14 à **64** (`14 + 50`) !
  - **AP** : passe de 13 à **63** (`13 + 50`) !
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-090]` — 2026-10-23 — Correction Critique : Affichage et Actualisation des Statistiques d'Objets LoL (AD, Armure, AP, Res. Magique, MS)
- **Auteur** : `Antigravity`
- **Catégorie** : Moteur de Statistiques Pokémon & Écran de Résumé (`Data/Scripts/014_Pokemon/`, `Data/Scripts/016_UI/`, `Data/Scripts/011_Battle/`)
- **Problème Identifié par l'Utilisateur** :
  - *« par exemple là j'ai ajouté Zhonya mais les stats de mon pokémon n'ont pas changé »*.
  - Dans le code d'origine de Jules AI, les bonus de statistiques (ex: Zhonya +50 AP, +50 Armure) étaient codés uniquement à l'intérieur du calcul de dégâts en combat (`003_Move_UsageCalculations.rb`). L'objet `Pokemon` (`001_Pokemon.rb`) ne modifiait que les PV (`@totalhp`), laissant `@attack`, `@defense`, `@spatk`, `@spdef` et `@speed` à leurs valeurs de base dans l'écran de résumé (SKILLS) !
- **Solutions & Correctifs Appliqués** :
  1. **Attribution Réelle des Stats dans `Pokemon#calc_stats` (`001_Pokemon.rb`)** :
     - Intégration complète des 49 objets LoL dans `calc_stats`.
     - Lorsque Zhonya est équipé, `stats[:DEFENSE] + 50` et `stats[:SPECIAL_ATTACK] + 50` sont directement injectés dans `@defense` et `@spatk`.
     - Tous les objets LoL (AD, AP, Armure, Res. Magique, MS) augmentent immédiatement les attributs du Pokémon.
     - Dès que l'objet est retiré ou changé, `calc_stats` rétablit instantanément les statistiques naturelles du Pokémon sans résidu.
  2. **Actualisation Automatique dans l'Écran de Résumé (`006_UI_Summary.rb`)** :
     - `calc_stats` est automatiquement déclenché à l'ouverture de l'écran de résumé (`pbStartScene`) et lors de l'affichage de l'onglet Statistiques (`drawPageThree`).
     - Geloupiot (Niv. 5) passant de 9 Armure / 11 AP à **59 Armure / 61 AP** avec le Sablier de Zhonya !
  3. **Suppression du Double-Calcul en Combat (`003_Move_UsageCalculations.rb` & `009_Battle_ItemEffects.rb`)** :
     - Comme `Battle::Battler` hérite nativement des statistiques de `Pokemon`, les additions plates redondantes dans `pbGetAttackStats` et `pbGetDefenseStats` ont été épurées afin de ne pas doubler les bonus en combat.
     - Les effets dynamiques (pénétration d'Armure de Dominik/Sunderer/Eclipse et pénétration magique du Bâton du vide) sont préservés lors de l'attaque d'une cible.
- **Fichiers modifiés** :
  - `Data/Scripts/014_Pokemon/001_Pokemon.rb`
  - `Data/Scripts/016_UI/006_UI_Summary.rb`
  - `Data/Scripts/011_Battle/003_Move/003_Move_UsageCalculations.rb`
  - `Data/Scripts/011_Battle/007_Other battle code/009_Battle_ItemEffects.rb`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Relancer le jeu (ou appuyer sur F12 pour recharger les scripts).
  - Ouvrir le menu Pokémon -> Résumé -> Page Compétences/Stats.
  - Observer les statistiques bondir avec le Sablier de Zhonya (+50 AP, +50 Armure), Rabadon, ou tout autre objet LoL !
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-089]` — 2026-10-23 — Intégration Sécurisée des 49 Objets League of Legends & des Nouvelles Mécaniques de Combat (Travaux de Jules AI)
- **Auteur** : `Antigravity` (portage et sécurisation des travaux de `Jules AI` sur GitHub)
- **Catégorie** : Objets PBS, Moteur de Combat Ruby & Système de Statistiques LoL (`PBS/items.txt`, `Data/Scripts/`)
- **Contexte & Sécurisation Critique** :
  - La branche GitHub de Jules AI contenait d'importantes suppressions accidentelles d'assets audio, graphiques et cartes RPG Maker dues à une modification de `.gitignore`.
  - Intégration sélective et chirurgicale de l'ensemble des 49 objets et mécaniques de combat créés et corrigés par Jules AI, sans aucune perte de données locales (cartes 076..081, graphismes et sons préservés à 100%).
- **Contenu Intégré & Nouvelles Mécaniques** :
  1. **49 Objets League of Legends (`PBS/items.txt`)** :
     - **33 Objets Mythiques / Légendaires** : Coiffe de Rabadon (`RABADON`), Lame d'infini (`INFINITYEDGE`), Cotte épineuse (`THORNMAIL`), Force de la Trinité (`TRINITYFORCE`), Ange Gardien (`GUARDIANANGEL`), Soif-de-sang (`BLOODTHIRSTER`), Cœurgel / Warmog (`WARMOGSARMOR`), Sablier de Zhonya (`ZHONYASHOURGLASS`), Tempête de Luden (`LUDENSTEMPEST`), Épée vespérale de Draktharr (`DUSKBLADE`), Bâton du vide (`VOIDSTAFF`), Salutations de Dominik (`LORDDOMINIKSREGARDS`), Couperet noir (`BLACKCLEAVER`), Danseur fantôme (`PHANTOMDANCER`), Gage de Sterak (`STERAKSGAGE`), Canon ultrarapide (`RAPIDFIRECANNON`), Poignard de Statikk (`STATIKKSHIV`), Tueur de krakens (`KRAKENSLAYER`), Éviscérateur (`GOREDRINKER`), Estropieur (`STRIDEBREAKER`), Pourfendeur divin (`DIVINESUNDERER`), Éclipse (`ECLIPSE`), Griffe du rôdeur (`PROWLERSCLAW`), Angoisse de Liandry (`LIANDRYSANGUISH`), Gel éternel (`EVERFROST`), Moissonneur nocturne (`NIGHTHARVESTER`), Ceinture-roquette Hextech (`HEXTECHROCKETBELT`), Créateur de failles (`RIFTMAKER`), Égide solaire (`SUNFIREAEGIS`), Gantelet givrant (`FROSTFIREGAUNTLET`), Chimico-scaphandre turbo (`TURBOCHEMTANK`), Médaillon de l'Iron Solari (`LOCKETOFTHEIRONSOLARI`), Régénérateur de pierre de lune (`MOONSTONEKRENOWER`).
     - **16 Composants & Objets de Base** : Épée longue (`LONGSWORD`), Pioche (`PICKAXE`), B.F. Glaive (`BFSWORD`), Tome d'amplification (`AMPLIFYINGTOME`), Baguette explosive (`BLASTINGWAND`), Baguette trop grosse (`NEEDLESSLYLARGEROD`), Armure d'étoffe (`CLOTHARMOR`), Cotte de mailles (`CHAINVEST`), Manteau de corbeau (`NULLMAGICMANTLE`), Manteau de Négatron (`NEGATRONCLOAK`), Cristal de rubis (`RUBYCRYSTAL`), Ceinture du géant (`GIANTSBELT`), Sceptre vampirique (`VAMPIRICSCEPTER`), Maillet gelé / Phage (`PHAGE`), Brillance (`SHEEN`), Zèle (`ZEAL`).
  2. **Formule de Dégâts League of Legends (`003_Move_UsageCalculations.rb`)** :
     - Calcul des dégâts bruts normalisés puis réduction d'Armure / RM selon la formule canonique LoL : `damage = (raw_damage * (100.0 / (100.0 + defense))).floor`.
     - Pénétration d'Armure (Salutations de Dominik 35%, Pourfendeur divin 20%, Éclipse 15%) et Pénétration Magique (Bâton du vide 40%).
     - Multiplicateurs de dégâts critiques bonus (+25% pour Lame d'infini, Danseur fantôme, Canon ultrarapide ; +10% pour Zèle).
  3. **Résurrection de l'Ange Gardien (`003_Battler_ChangeSelf.rb`)** :
     - Hook direct dans `pbFaint` : si le Pokémon tient l'Ange Gardien lors d'un K.O., il est immédiatement ressuscité avec 50% de ses PV max, animation de soin et consommation de l'objet.
  4. **Effets Passifs d'Objets en Combat (`009_Battle_ItemEffects.rb`)** :
     - **Vol de vie (Omnivamp / Lifesteal)** après chaque attaque infligeant des dégâts : Soif-de-sang (+18% physique), Éviscérateur (+20% physique), Sceptre vampirique (+5% physique), Créateur de failles (+15% spécial).
     - **Renvoi de dégâts (Thornmail)** : 1/8ème des PV max de l'attaquant renvoyé sur coup physique reçu.
     - **Régénération Warmog** : +5% des PV max à la fin de chaque tour si le porteur peut être soigné.
     - **Bonus de Vitesse (MS)** : Force de la Trinité, Danseur fantôme, Canon ultrarapide, Statikk (+30%), Luden, Krakens, Estropieur, Chimico-scaphandre (+20%), Zèle (+10%).
  5. **Attribution Dynamique des PV Max (`001_Pokemon.rb`)** :
     - Les objets accordant des PV plats (Warmog +150, Sterak +100, etc.) mettent à jour dynamiquement `totalhp` et les PV actuels lors de l'équipement via `item=` et `calc_stats`, sans bug lors de la montée de niveau.
- **Fichiers modifiés** :
  - `PBS/items.txt`
  - `Data/Scripts/011_Battle/002_Battler/003_Battler_ChangeSelf.rb`
  - `Data/Scripts/011_Battle/003_Move/003_Move_UsageCalculations.rb`
  - `Data/Scripts/011_Battle/007_Other battle code/009_Battle_ItemEffects.rb`
  - `Data/Scripts/014_Pokemon/001_Pokemon.rb`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Ouvrir le menu Debug (`F9`) -> `Objets` -> S'octroyer un objet LoL (ex. `RABADON`, `INFINITYEDGE`, `GUARDIANANGEL`, `BLOODTHIRSTER`, `WARMOGSARMOR`).
  - Équiper un Pokémon : vérifier dans le résumé que les PV augmentent (avec Warmog) et lancer un combat.
  - En combat : vérifier que l'Ange Gardien ressuscite à 50% PV, que la Soif-de-sang soigne 18% des dégâts physiques infligés, et que la Cotte épineuse inflige des dégâts à l'attaquant.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD` ou restaurer les 5 fichiers : `git checkout HEAD~1 -- PBS/items.txt Data/Scripts/011_Battle/ Data/Scripts/014_Pokemon/`

---

### `[AGY-088]` — 2026-10-23 — Salle 4 : Restructuration Complète & Mise en Scène du Cratère du Crash Noxien (Map 081)
- **Auteur** : `Antigravity`
- **Catégorie** : Création de Carte, Mise en Scène Narrative & Combats de Boss (`Data/Map081.rxdata`, `Data/Tilesets.rxdata`)
- **Demande Utilisateur** :
  - *« ok maintenant c'est la salle du crash on est daccord tu peux faire un beau truc scenarisé avec ce qu'on avait convenu »*.
- **Réalisations & Correctifs Appliqués** :
  1. **Correction Intégrale de la Praticabilité (0 Blocage)** :
     - Remplacement de l'ancien sol impassable par le véritable sol en pierre praticable de caverne (`Tile 388`, collision `0x0000`).
     - Configuration stricte des débris métalliques et du réacteur Hextech en impassable (`Tile 512..543`, collision `0x0F` dans `Tileset 28`). Le joueur peut se déplacer librement à travers toute la salle dès son arrivée en `(10, 23)` sans jamais être bloqué.
  2. **Scénarisation & Cinématique d'Entrée** :
     - En avançant en `(10, 20)`, un tremblement de terre retentit (`Voltorb Flip explosion` + secousse d'écran), suivi du cri d'alerte des soldats noxiens (`Exclaim`).
     - Les soldats Kael et Draven apostrophent le joueur, stupéfaits qu'un habitant de Freljord ait survécu aux épreuves.
  3. **Confrontation des 2 Soldats d'Élite de Noxus** :
     - **Soldat Kael** `(9, 13)` : Affronte le joueur avec *Rocphite* (Niv. 13) et *Voragath* (Niv. 14).
     - **Soldat Draven** `(12, 13)` : Affronte le joueur avec *Xenosai* (Niv. 14) et *Ziggs* (Niv. 15).
     - Révélation narrative : ils admettent leur défaite mais révèlent que le Commandant Valerius a déjà évacué l'Œuf d'Anivia vers Port-Brumeux pour appareiller vers Zaun !
  4. **Fouille de l'Épave du Réacteur Hextech** :
     - En inspectant le réacteur en `(10, 10)`, le joueur découvre une sacoche militaire noxienne contenant la **CT13 Laser Glace** (`pbItemBall(:TM13)`) ainsi que l'ordre de mission officiel confirmant la destination de Valerius.
  5. **Sorties de Carte** :
     - Au Sud en `(10..11, 23)` : retour vers l'Abîme Hurlant (`Map 080`).
     - Au Nord en `(10..11, 1)` : sortie de la caverne vers la Route 3 / le col extérieur menant à Port-Brumeux (`Map 031`).
- **Aperçus Visuels** :
  - [salle4_crash_final_visual.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/salle4_crash_final_visual.png) (Rendu complet de la caverne avec réacteur, débris et acteurs).
  - [map081_passability_grid.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/map081_passability_grid.png) (Grille de praticabilité 100% verte).

---

### `[AGY-087]` — 2026-10-23 — Salle 3 : Reset Automatique du Dresseur Sigurd à Chaque Chute
- **Auteur** : `Antigravity`
- **Catégorie** : Logique de Combat & Événements (`Data/Map080.rxdata`)
- **Demande Utilisateur** :
  - *« le dresseur reset aussi? »* -> Option validée : réinitialiser le dresseur à chaque chute (il faut le rebattre à chaque fois pour rouvrir le TP).
- **Réalisations & Correctifs Appliqués** :
  - Lors de l'utilisation du téléporteur runique pour remonter au départ du pont, la commande `pbSetSelfSwitch(6, "A", false)` réinitialise instantanément le Gardien Sigurd (Event ID 6).
  - En conséquence :
    - Le pont de glace est remis à neuf (Switch 50 OFF).
    - Le téléporteur redevient éteint et scellé (Switch 51 OFF).
    - Si le joueur chute à nouveau, le **Gardien Sigurd est à nouveau prêt au combat** et bloque la sortie tant qu'il n'est pas battu !
- **Aperçu Visuel** :
  - [preview_salle3_pont_avec_intersections.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_avec_intersections.png).

---

### `[AGY-086]` — 2026-10-23 — Salle 3 : Conditionnement du Téléporteur de Remontée (Victoire Contre Sigurd Obligatoire)
- **Auteur** : `Antigravity`
- **Catégorie** : Logique de Combat & Déverrouillage d'Événement (`Data/Map080.rxdata`)
- **Demande Utilisateur** :
  - *« ok bien le tp derriere le dresseur meme invisble est actif arrange ca »*.
- **Réalisations & Correctifs Appliqués** :
  1. **Téléporteur Scellé et Inactif tant que Sigurd n'est pas battu** :
     - **Page 1 (Switch 51 OFF)** : Le téléporteur est totalement désactivé (invisible et inopérant au toucher). Si le joueur clique dessus, un message indique : *« Le cercle runique est éteint et scellé. Vous devez vaincre le Gardien de la fosse pour l'activer ! »*.
  2. **Victoire Vérifiée & Activation Runique** :
     - Le combat contre Sigurd est désormais conditionné par `TrainerBattle.start(:TRIAL_GUARDIAN, "Gardien Sigurd")` dans un bloc `Conditional Branch` officiel.
     - **Seule la victoire du joueur** déclenche le dialogue de félicitations de Sigurd et active `Switch 51 ON`.
  3. **Page 2 du Téléporteur (Switch 51 ON)** :
     - Dès la victoire, le téléporteur runique s'illumine avec son sprite magique (`!Teleporteur_Runique.png`).
     - Au contact du joueur, il joue le son de téléportation, réinitialise `Switch 50` (le pont redevient intact) et `Switch 51` (le TP redevient scellé pour la prochaine chute éventuelle), puis le téléporte au départ du pont.
- **Aperçu Visuel** :
  - [preview_salle3_pont_avec_intersections.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_avec_intersections.png).

---

### `[AGY-085]` — 2026-10-23 — Salle 3 : Pont de Glace avec Intersections d'Arrêt après Chaque Choix
- **Auteur** : `Antigravity`
- **Catégorie** : Game Design, Rythme de Jeu & Événements (`Data/Map080.rxdata`)
- **Demande Utilisateur** :
  - *« ok j'ai pas pensé a ce probleme mais je peux avancer quand ligne droite en faire il faudrait apres chaque choix une interscetion ou on sarrete pour choisir le prochain choix etc »*.
- **Réalisations & Améliorations Appliquées** :
  1. **Rythme Alterné Glace / Intersection** :
     - Pour éviter que le joueur ne soit forcé d'avancer tout droit sans pouvoir s'arrêter ni changer de colonne, chaque étape de choix est désormais suivie d'un palier d'intersection stable.
     - **Structure** :
       - Palier de choix (Y impair/pair) : 2 dalles de glace côte à côte (`X=29` et `X=30`), dont une seule est solide !
       - Palier de repos / intersection : 2 dalles de sol ferme (`STONE_FLOOR = 1386`) où le joueur s'arrête, se repositionne à gauche ou à droite, et réfléchit à son prochain pas.
  2. **Maintien de la Mécanique Globale à 2 Erreurs** :
     - 1ère erreur : le pont craque, l'écran tremble (`Screen Shake 225`), et **tout le pont de glace bascule en texture fissurée**.
     - 2ème erreur : effondrement total et chute immédiate dans la fosse de combat face au Gardien Sigurd.
- **Aperçu Visuel** :
  - [preview_salle3_pont_avec_intersections.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_avec_intersections.png).

---

### `[AGY-084]` — 2026-10-23 — Salle 3 : Correctif Immédiat Crash `NoMethodError: undefined method 'red' for 5:Integer`
- **Auteur** : `Antigravity`
- **Catégorie** : Bugfix Événement RPG Maker (`Data/Map080.rxdata`)
- **Problème Identifié** :
  - Lors de la première erreur sur le pont de glace, le jeu crashait avec : `001_Game_Screen.rb:75:in 'update': undefined method 'red' for 5:Integer`.
  - Cause : la commande RPG Maker pour la secousse d'écran était appelée avec l'opcode `223` (qui est *Change Screen Color Tone*) au lieu de l'opcode `225` (*Screen Shake*). L'interpréteur prenait l'entier 5 pour un objet `Tone` et essayait d'appeler `.red` dessus.
- **Correctif Appliqué** :
  - Remplacement immédiat par l'opcode natif `225` (`start_shake(5, 5, 20)`).
  - Map 080 régénérée et vérifiée.
- **Aperçu Visuel** :
  - [preview_salle3_pont_2_de_large_ice.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_2_de_large_ice.png).

---

### `[AGY-083]` — 2026-10-23 — Salle 3 : Pont de Glace Strictement 2 de Large & Fissure Globale
- **Auteur** : `Antigravity`
- **Catégorie** : Map Design & Logique Globale d'Événements (`Data/Map080.rxdata`, `Data/Tilesets.rxdata`)
- **Demande Utilisateur** :
  - *« JE VEUX UN CHEMIN DE 2 DE LARGE EN ICE CHAQUE FOIS IL Y A UNE DES 2 CASSES QUI EST BONNE ET AINSI DE SUITE SI ON RATE UNE CASSE TOUT LE PONT DEPUIS ICE UN PEU CASSE ET ENSUITE SIL Y A UNE DEUXEIME ERREUR TOUT LE BON SE CASSE ET ON TOMBE CONTRE LA SALLE CONTRE LE DRESSEUR »*.
- **Réalisations & Correctifs Appliqués** :
  1. **Pont de Glace Continu de 2 Cases de Largeur (Sans aucun mur central)** :
     - Le pont s'étend de `Y=50` à `Y=12` sur exactement 2 cases côte à côte : Colonne Gauche `X=29` et Colonne Droite `X=30`.
     - Aucune roche ni poutre entre les deux dalles.
  2. **Passabilité Réelle et Certifiée (Tuile 424 & 425)** :
     - Les tuiles de glace pure (`Tile 424`) et de glace fissurée (`Tile 425`) ont été configurées dans `Data/Tilesets.rxdata` en `passage = 0x0000` (100% praticables) et `tag = 0` (marche au pas, sans glissade incontrôlée).
  3. **Système de Fissure Globale à 2 Erreurs (Switch 50)** :
     - À chaque rangée `Y`, une case est **solide** et l'autre est **piégée**.
     - **1ère Erreur** : Dès que le joueur marche sur une mauvaise dalle :
       - Bruit de fissure (`Mining collapse`) et secousse d'écran.
       - Message d'alerte.
       - **TOUT LE PONT** bascule instantanément en texture de glace fissurée sous ses yeux (via `Switch 50 ON`) !
     - **2ème Erreur** : Si le joueur commet une seconde erreur sur le pont fissuré :
       - Bruit d'effondrement massif (`Rock Smash` + `Player fall`).
       - Message d'effondrement complet : *« FRACAS TOTAL ! Le pont de glace s'effondre entièrement ! Vous chutez dans l'arène ! »*.
       - Chute immédiate dans l'arène souterraine `(48, 56)`.
     - **Réinitialisation en Sortie de Fosse** : Après avoir vaincu le dresseur Sigurd, le téléporteur runique désactive `Switch 50` et remonte le joueur au départ avec un pont remis à neuf !
- **Aperçu Visuel** :
  - [preview_salle3_pont_2_de_large_ice.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_2_de_large_ice.png).

---

### `[AGY-082]` — 2026-10-23 — Salle 3 : Pont de Glace Authentique (Tuiles Réelles Salle 2 & Système Fissure 2 Étapes)
- **Auteur** : `Antigravity`
- **Catégorie** : Fix Passabilité & Logique Événementielle (`Data/Map080.rxdata`)
- **Demande Utilisateur** :
  - *« met comme les autres salle ici je peux pas bougez et pour le pont fait juste un pont de glace (l'eau il fait froid la) et faut trouver le bon chemin »*.
- **Réalisations & Correctifs Appliqués** :
  1. **Résolution Radicale du Blocage** :
     - Remplacement de toutes les tuiles par les tuiles authentiques et 100% praticables de la Salle 2 (`STONE_FLOOR = 1386` pour la roche et `ICE_SLIDE = 1328` pour les dalles de glace).
     - Nettoyage complet des collisions sur la plateforme Sud de départ (`Y=51..66`) et sur les deux voies du pont (`X=29` et `X=31`, `Y=12..50`).
  2. **Pont de Glace Suspendu au-dessus de l'Abîme Glacial** :
     - Deux voies parallèles en glace pure (`ICE_SLIDE`), séparées par une arête rocheuse centrale (`ROCK_WALL = 1349`).
     - 20 étapes successives où le joueur doit tester son chemin.
  3. **Système de Double Détection (Glace Fissurée puis Rupture)** :
     - **1ère Erreur** : Bruit de craquement (`Mining collapse`), alerte textuelle avertissant que la glace se fissure sous les pas, activation de l'état fissuré (Self Switch A = ON).
     - **2ème Erreur** : Bruit de fracas et de chute (`Rock Smash` + `Player fall`), message de rupture, chute libre dans l'arène souterraine `(48, 56)`.
     - **Gardien Sigurd & Téléporteur** : Combat de fosse ; une fois vaincu, le cercle runique en `(48, 50)` renvoie le joueur en haut du pont en `(30, 52)`.
- **Aperçu Visuel** :
  - [preview_salle3_pont_de_glace_authentique.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_de_glace_authentique.png).

---

### `[AGY-081]` — 2026-10-23 — Déblocage Entrée du Pont & Mécanique de Glace Fissurée à 2 Erreurs (Salle 3)
- **Auteur** : `Antigravity`
- **Catégorie** : Game Design, Graphismes & Logique d'Événements (`Data/Map080.rxdata`, `Graphics/Tilesets/SubTileset_3_Caverne_Epreuve_Crash.png`)
- **Demande Utilisateur** :
  - *« je peux pas passer et met de la glace qui se fissure si'il y aune erreur et la deuxeime fois si on se trompe une deuxeime fois ca se casse et on tombe »*.
- **Réalisations & Correctifs Appliqués** :
  1. **Déblocage Immédiat de l'Accès au Pont** :
     - Les 3 tuiles de transition entre la plateforme Sud et le début du pont en `(Y=51..53)` utilisaient l'ancienne tuile 1386 bloquée. Elles ont été converties sur la tuile de pierre praticable `Tile 435`. Le joueur peut maintenant avancer librement et monter directement sur les dalles de glace !
  2. **Mécanique de Glace Fissurée à Deux Erreurs (Double Détente)** :
     - **1ère Erreur** : Si le joueur pose le pied sur la mauvaise dalle de glace :
       - Son de craquement sous les pas (`Mining collapse` aigu).
       - Message d'alerte : *« CRAAAC ! La glace se fissure dangereusement sous vos pas ! Un pas de plus et elle cédera ! »*.
       - La dalle de glace change instantanément d'aspect visuel pour devenir une dalle fissurée zébrée de crevasses (`Tile 425`). Le joueur a le temps de rebrousser chemin ou de sauter sur l'autre dalle !
     - **2ème Erreur** : Si le joueur insiste ou se trompe à nouveau sur une dalle déjà fissurée :
       - Son d'explosion de glace (`Rock Smash`) et de chute (`Player fall`).
       - Message : *« FRACAS ! La glace fissurée cède totalement ! Vous chutez dans la fosse ! »*.
       - Le joueur est précipité dans la fosse des Gardiens en `(48, 56)` pour affronter Sigurd avant de pouvoir remonter.
- **Aperçu Visuel** :
  - [preview_salle3_pont_de_verre_squid_game.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_de_verre_squid_game.png).

---

### `[AGY-080]` — 2026-10-23 — Remplacement Salle 3 : Le Grand Pont de Verre Suspendu (Type Squid Game)
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte Complète de Carte & Puzzle Natif Événementiel (`Data/Map080.rxdata`, `Graphics/Tilesets/SubTileset_3_Caverne_Epreuve_Crash.png`)
- **Demande Utilisateur** :
  - Abandon du système de vent trop complexe/buggé.
  - Passer sur un long chemin simple et lisible où le joueur doit trouver la bonne dalle à chaque pas (comme l'épreuve du pont de verre de Squid Game).
  - S'il se trompe de dalle, elle se brise et il tombe dans une fosse avec un dresseur. S'il bat le dresseur, il remonte à l'entrée de l'épreuve.
- **Réalisations & Mécanique Implémentée (100% Natif RPG Maker)** :
  1. **Le Pont de Verre Suspendu (20 Paires de Dalles)** :
     - Deux rangées de dalles de verre translucide (`Tile 568` et `Tile 569`, rendues identiques au pixel près) séparées par une poutre centrale infranchissable (`X=29` Gauche vs `X=31` Droite) sur 40 cases de longueur au-dessus de l'abîme.
     - À chaque étape, une seule dalle est en verre trempé solide, l'autre est fragile.
  2. **Chute & Arène de Combat Souterraine** :
     - Si le joueur pose le pied sur la mauvaise dalle : bruit de verre qui vole en éclats (`Rock Smash` à pitch aigu) + cri de chute (`Player fall`) + message immersif *« CRAC ! La dalle de verre cède sous votre poids ! »*.
     - Le joueur chute dans l'Arène des Gardiens en bas à droite en `(48, 56)`.
     - **Gardien Sigurd** (`TRIAL_GUARDIAN`) lui barre la route : *« Tu as fait un faux pas et chuté dans ma fosse ! Bats-moi si tu veux remonter au départ de l'Épreuve ! »*.
  3. **Portail de Remontée vers l'Entrée** :
     - Une fois Sigurd battu, le téléporteur runique en `(48, 50)` s'ouvre et ramène le joueur en sécurité au début du pont en `(30, 54)`.
     - Le joueur retient son erreur et progresse pas à pas jusqu'à la sortie Nord vers le Cratère de Noxus.
  4. **Zéro Script Complexe, Zéro Freeze** :
     - Le script expérimental `012_Overworld_Abyss_Wind.rb` a été totalement supprimé. Le puzzle tourne à 100% sur des événements natifs ultra-stables.
- **Aperçu Visuel** :
  - [preview_salle3_pont_de_verre_squid_game.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_de_verre_squid_game.png).

---

### `[AGY-079]` — 2026-10-23 — Résolution du Blocage Infini : Architecture Non-Bloquante & Compte à Rebours Secondes (Salle 3)
- **Auteur** : `Antigravity`
- **Catégorie** : Débogage Moteur, Performance & Fluidité (`Data/Scripts/012_Overworld/012_Overworld_Abyss_Wind.rb`)
- **Demande Utilisateur** :
  - *« CEST FULL BUGGUE JE SUIS BLOQUE A LINFINI »* : le jeu freeze ou le joueur reste coincé sans pouvoir bouger dès que le vent souffle.
- **Cause Identifiée & Correctif Appliqué** :
  1. **Cause du freeze** :
     - L'appel synchrone `pbMoveRoute($game_player, ..., true)` forçait une chaîne de 15 pas dans l'Abîme sur des tuiles bloquées ou avec `waitComplete = true` à l'intérieur de `on_frame_update`. Le moteur RMXP se retrouvait prisonnier d'une boucle infinie d'attente d'itinéraire.
  2. **Transition Immédiate et Sécurisée (`pbFadeOutIn`)** :
     - Remplacement de la route forçante par une transition standard native Pokémon Essentials : `pbFadeOutIn` avec fondu noir instantané, son de tornade (`Whirlwind` / `Ice`), et repositionnement propre en `(30, 64)`.
     - Ajout d'un verrou `@blown = true` pour qu'une bourrasque ne se redéclenche jamais en boucle pendant la même seconde.
  3. **Compte à Rebours des Secondes dans le HUD** :
     - Le bandeau vert affiche désormais le décompte exact en secondes : `[VENT CALME - AVANCEZ ! (10s)]`, permettant au joueur de jauger immédiatement le temps qu'il lui reste pour courir jusqu'au pilier suivant.

---

### `[AGY-078]` — 2026-10-23 — Refonte Complète : Bourrasques Latérales (Est->Ouest), Toboggan de Glace & Indicateur Visuel HUD (Salle 3)
- **Auteur** : `Antigravity`
- **Catégorie** : Mécanique de Jeu en Temps Réel, Interface Utilisateur (HUD), Scripts Ruby & Refonte Carte (`Data/Scripts/012_Overworld/012_Overworld_Abyss_Wind.rb`, `Data/Map080.rxdata`, `Graphics/Tilesets/SubTileset_3_Caverne_Epreuve_Crash.png`)
- **Demande Utilisateur** :
  - Le vent venant du haut était bizarre vu qu'on commence en bas : le faire venir de côté (Est vers Ouest).
  - Si on est poussé de côté : être éjecté sur une zone de glace latérale qui nous fait glisser ensuite vers le bas, puis vers la droite en direction de notre spawn.
  - Possibilité d'affronter des dresseurs sur la glace si on glisse à certains niveaux.
  - Rendre beaucoup plus clair quand on peut passer et quand il y a du vent (système optimal de lisibilité).
- **Réalisations & Mécaniques Implémentées** :
  1. **Indicateur Visuel Dynamique en Direct (HUD)** :
     - Affichage d'un bandeau en haut de l'écran avec code couleur et consignes explicites en direct :
       - 🟢 `[VENT CALME - AVANCEZ !]` (9 à 12 secondes) : traversée 100% sécurisée.
       - 🟡 `[LE VENT SE LÈVE...]` : grondement lointain de vent venant de l'Est.
       - 🟠 `[ALERTE ! ABRI IMMÉDIAT !]` : sifflement aigu, le joueur doit se plaquer derrière un pilier !
       - 🔴 `[BOURRASQUE EN COURS !]` : rafale latérale violente balayant le pont.
  2. **Vent Latéral (Est ➔ Ouest)** :
     - Les rafales soufflent perpendiculairement depuis la droite (Est) vers la gauche (Ouest).
     - Des grands piliers protecteurs sont disposés tout le long du flanc droit (X=32) : le joueur s'y abrite pour bloquer le vent !
  3. **Toboggan de Glace Latéral avec Retour au Spawn** :
     - Tout le flanc gauche du pont est bordé d'un grand couloir de glace vive (`Tile 434`).
     - Si le joueur est surpris à découvert, la rafale le pousse à gauche sur la glace, il glisse à toute vitesse vers le bas, puis vers la droite pour réatterrir au spawn du début en `(30, 64)`.
  4. **Embuscades sur la Glace** :
     - En glissant, le joueur peut heurter de plein fouet deux dresseurs postés sur la glissade :
       - **Sentinelle Vagn** en `(26, 22)` (niveau haut).
       - **Gardien Sigurd** en `(25, 42)` (niveau bas).
- **Aperçu Visuel** :
  - [preview_salle3_pont_abime_bourrasques.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_abime_bourrasques.png).

---

### `[AGY-077]` — 2026-10-23 — Rééquilibrage Salle 3 : Grondement Annonciateur, Embuscades sur Rochers & Effet de Chute
- **Auteur** : `Antigravity`
- **Catégorie** : Game Design, Sons Précurseurs & Événements (`Data/Scripts/012_Overworld/012_Overworld_Abyss_Wind.rb`, `Data/Map080.rxdata`, `Graphics/Tilesets/SubTileset_3_Caverne_Epreuve_Crash.png`)
- **Demande Utilisateur** :
  - La traversée était trop rapide/impossible : donner le temps d'avancer et le bruit du vent qui se lève pour savoir clairement quand ça va arriver.
  - Placer les combats sur des rochers où le vent nous pousse en cas d'erreur.
  - Ajouter un effet de vide sur la map et un effet de chute réaliste quand on tombe.
- **Réalisations & Améliorations Appliquées** :
  1. **Timing Équilibré & Traversée Possible** :
     - Période de calme augmentée à **8 à 12 secondes entières** : le joueur a largement le temps de courir d'un abri au suivant (distants de seulement 8 pas).
  2. **Bruit du Vent qui se Lève (Double Alerte Sonore)** :
     - **Étape 1 (à -2.5 secondes)** : Grondement lointain sourd (`Anim/Wind1` à basse fréquence) + léger tremblement de caméra.
     - **Étape 2 (à -1.1 seconde)** : Sifflement aigu imminent (`Anim/Wind5`) + flash d'alerte bleuté.
     - Le joueur a 2.5 secondes complètes pour se réfugier dès qu'il entend le vent monter.
  3. **Deux Îlots Rocheux d'Embuscade (`Gardien Sigurd` & `Sentinelle Vagn`)** :
     - Si le vent surprend le joueur au milieu (`Y=28..35`), il est soufflé sur l'îlot rocheux Ouest en face du **Gardien Sigurd** (`26, 32`) !
     - Si surpris en haut (`Y=15..23`), il est soufflé sur le promontoire rocheux Est en face de la **Sentinelle Vagn** (`34, 19`) !
  4. **Effet de Vide Abyssal & Chute** :
     - Le sol autour du pont est désormais un **vide abyssal insondable** (`Tile 1136` peint en noir ténébreux pur) avec bordure rocheuse abrupte (`Tile 1128`).
     - En cas de chute dans le néant : bruitage de chute libre dans le vide (`Player fall`), tremblement d'impact, obscurcissement total au noir et message d'alerte immersif avant réapparition au départ.
- **Aperçu Visuel** :
  - [preview_salle3_pont_abime_bourrasques.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_abime_bourrasques.png).

---

### `[AGY-076]` — 2026-10-23 — Système Dynamique de Bourrasques avec Sons, Pirouette & Embuscades (Salle 3)
- **Auteur** : `Antigravity`
- **Catégorie** : Mécanique de Jeu en Temps Réel, Scripts Ruby, Audio & PBS (`Data/Scripts/012_Overworld/012_Overworld_Abyss_Wind.rb`, `Data/Map080.rxdata`, `PBS/trainers.txt`)
- **Demande Utilisateur** :
  - Dans certains jeux, il y a du vent : le joueur tourne sur lui-même et est repoussé quand le vent souffle.
  - Système de bourrasques périodiques avec des endroits pour se protéger (alcôves/refuges).
  - Utiliser le bruit du jeu pour savoir quand le vent va arriver et partir (avertissement sonore distinct).
  - Vitesses variables de bourrasques (rapide, normale, lente) avec recul proportionnel.
  - S'il se fait pousser à certains endroits, il tombe directement contre un dresseur inévitable.
- **Réalisations & Mécaniques Implémentées** :
  1. **Script Global en Temps Réel (`AbyssWindManager`)** :
     - Hooké sur `EventHandlers.add(:on_frame_update, :abyss_wind_cycle)` sur la Map 80.
     - **Phase 1 : Calme** (4 à 7 secondes) où le joueur avance librement.
     - **Phase 2 : Alerte Précurseur** (1 à 2 secondes) avec sifflement strident de vent aigu (`Anim/Wind1`) et flash cyan discret à l'écran.
     - **Phase 3 : Bourrasque Violente** : rugissement de tempête (`Anim/Wind7` ou `Anim/Whirlwind`). Si le joueur est sur le pont sans être caché dans une des 6 alcôves :
       - Il effectue une rotation à 360° sur lui-même (`TURN_RIGHT`, `TURN_UP`, `TURN_LEFT`, `TURN_DOWN`).
       - Il est projeté violemment vers le Sud (recul de 3 à 6 cases selon la vitesse du vent).
  2. **Embuscade Forcée contre Dresseur** :
     - Si la rafale pousse le joueur sur le segment central en face de `(30, 32)`, le dresseur **Gardien Sigurd** (`TRIAL_GUARDIAN`) l'intercepte immédiatement en duel Pokémon sans esquive possible !
     - Nouveau dresseur enregistré dans `PBS/trainers.txt` avec Rocphite N.14 et Thoraklak N.15.
     - Sentinelle Vagn (`TRIAL_GUARDIAN`) montée à la sortie Nord avec Lycanglas N.15 et Runolithe N.15.
  3. **Protection des Niches Latérales** :
     - Les 6 alcôves à piliers rocheux (`(28, 52)`, `(32, 44)`, `(28, 36)`, `(32, 28)`, `(28, 20)`, `(32, 12)`) protègent à 100% contre le vent tant que le joueur s'y abrite.
  4. **Chute & Respawn** :
     - Si le vent repousse le joueur jusqu'à l'orée du pont (`Y >= 61`), bruitage de chute abyssale (`Player fall`), fondu noir et respawn au départ du pont en `(30, 64)`.
- **Aperçu Visuel** :
  - [preview_salle3_pont_abime_bourrasques.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_abime_bourrasques.png).

---

### `[AGY-075]` — 2026-10-23 — Refonte Salle 3 : Le Grand Pont de l'Abîme Hurlant avec Bourrasques & Refuges
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte de Carte, Mécanique de Vent & Événements (`Data/Map080.rxdata`, `Data/Map079.rxdata`)
- **Demande Utilisateur** :
  - Transformer la Salle 3 en un grand pont au-dessus du vide où le vent souffle et peut nous repousser/précipiter dans le vide.
  - Plus aucune rune ou mécanisme complexe requis pour avancer : juste l'épreuve de progression face aux rafales de vent et une sortie directe vers le Nord (Cratère de Noxus).
- **Réalisations & Mécaniques Appliquées** :
  1. **Le Grand Pont Suspendu (60×70, 50 cases de longueur au-dessus du néant)** :
     - Tout autour du pont, c'est le vide noir infranchissable (`Tile 494`).
     - Entrée Sud à `(30, 65)` depuis la Salle 2.
     - Sortie Nord libre et directe à `(30, 4)` vers le Cratère du Dirigeable de Noxus (`Map081`).
  2. **15 Zones de Bourrasques Violentes** :
     - Éparpillées en quinconce le long du pont.
     - Si le joueur marche sur une rafale sans observer son chemin : un bruitage de tempête retentit (`FOUUUUSH !`), le souffle glacial le balaye et le projette en bas au départ du pont en `(30, 64)`.
  3. **6 Niches de Refuges Latéraux avec Piliers** :
     - Permettent au joueur de se mettre à l'abri sur les côtés pour contourner les courants d'air violents.
  4. **Sentinelle de l'Abîme à Mi-Parcours `(30, 32)`** :
     - Un dresseur d'élite posté au centre du pont défie le joueur pour tester sa résistance.
- **Aperçu Visuel** :
  - [preview_salle3_pont_abime_bourrasques.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle3_pont_abime_bourrasques.png).

---

### `[AGY-074]` — 2026-10-23 — Dresseurs Inesquivables en Cas d'Erreur & Solution Unique Démontrée (Salle 2)
- **Auteur** : `Antigravity`
- **Catégorie** : Mécanique de Combat Forcé & Pièges de Glace (`Data/Map079.rxdata`)
- **Demande Utilisateur** :
  - Placer les dresseurs directement sur les trajectoires d'erreur pour qu'on glisse de plein fouet sur eux sans pouvoir les esquiver en cas de mauvaise manoeuvre.
  - Revérifier formellement avec l'algorithme qu'il n'existe toujours qu'une seule méthode de sortie.
- **Réalisations & Vérifications** :
  1. **Impact Frontal Direct Inesquivable (`trigger = 1 Player Touch`)** :
     - **Chasseur Erling `(10, 51)`** : Placé directement sur la dalle d'atterrissage du couloir Sud-Ouest. Si le joueur fait l'erreur d'aller trop loin à l'Ouest au début, sa glisse percute immédiatement le dresseur et déclenche le combat.
     - **Guerrier Halvar `(36, 11)`** : Placé directement sur la ligne de fuite Nord. Si le joueur fonce vers le Nord sans bifurquer vers l'arche, il s'écrase sur Halvar.
  2. **Vérification Algorithmique Complète** :
     - **TOTAL DES SOLUTIONS EXISTANTES : STRICTEMENT 1 SEULE**.
     - Séquence validée : `HAUT ➔ GAUCHE ➔ HAUT ➔ GAUCHE ➔ HAUT ➔ GAUCHE ➔ BAS ➔ DROITE ➔ HAUT ➔ DROITE ➔ HAUT`.
  3. **Aperçu Visuel Dédié** :
     - [preview_salle2_dresseurs_inesquivables.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle2_dresseurs_inesquivables.png).

---

### `[AGY-073]` — 2026-10-23 — Grand Tour Périphérique Déroutant (Salle 2) : Exploration Intégrale de la Carte & Solution Unique
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte Architecture de Glace (`Data/Map079.rxdata`)
- **Demande Utilisateur** :
  - Empêcher la solution d'être trop centrée au milieu de la carte.
  - Obliger le joueur à explorer les confins lointains de l'immense salle (60×60) pour créer une vraie sensation d'immensité et de désorientation.
- **Réalisations & Preuve Algorithmique** :
  1. **Trajectoire Périphérique Épique (13 étapes de glisse)** :
     - Le chemin sillonne désormais les profondeurs du Sud, remonte à travers une immense traversée Nord-Sud de 40 cases, explore le flanc Ouest lointain avant de revenir vers le centre-nord pour s'aligner sous l'arche.
  2. **Unicité Absolue Démontrée par Solveur BFS** :
     - **Exactement 1 seule solution au monde** : `HAUT ➔ GAUCHE ➔ HAUT ➔ DROITE ➔ BAS ➔ GAUCHE ➔ HAUT ➔ GAUCHE ➔ BAS ➔ DROITE ➔ HAUT ➔ DROITE ➔ HAUT`.
  3. **2 Dresseurs Excentrés dans les Coins Reculés** :
     - Chasseur Erling dans le coin Sud-Ouest lointain `(12, 46)`.
     - Guerrier Halvar dans le coin Nord-Est lointain `(48, 14)`.
  4. **Aperçu Visuel Dédié** :
     - [preview_salle2_grand_tour_des_4_coins.png](file:///C:/Users/Mon%20POc/.gemini/antigravity/brain/829cfc1b-7134-4156-b9ea-bafe0bbd893b/preview_salle2_grand_tour_des_4_coins.png).

---

### `[AGY-072]` — 2026-10-23 — Verrouillage Mathématique : Preuve Formelle de l'Unicité Stricte de la Solution (Salle 2)
- **Auteur** : `Antigravity`
- **Catégorie** : Validation Algorithmique & Sécurisation de Carte (`Data/Map079.rxdata`)
- **Vérification Effectuée** :
  - Exécution d'un solveur exhaustif (algorithme de recherche en largeur BFS explorant 100% des états possibles sur la carte de 60×60).
  - Détection et neutralisation d'une boucle parasite (un ricochet optionnel vers le bas qui permettait une variante en 16 étapes).
  - Ajout d'un bloc de roche de verrouillage en `(30, 14)` : une fois arrivé en `(30, 13)`, la seule et unique direction autorisée sans obstacle est **HAUT** vers l'arche Nord.
- **Résultat Formel** :
  - **TOTAL DES CHEMINS GAGNANTS EXISTANTS : EXACTEMENT 1 SEUL**.
  - Toutes les autres trajectoires mènent soit à une impasse, soit aux 2 dresseurs embusqués, soit à un aller-retour en boucle fermée.

---

### `[AGY-071]` — 2026-10-23 — Grand Labyrinthe de Verglas Épique (60x60) : 14 Ricochets & 2 Dresseurs Pièges
- **Auteur** : `Antigravity`
- **Catégorie** : Extension de Carte, Puzzles de Glace & Dresseurs (`Data/Map079.rxdata`)
- **Demande Utilisateur** :
  - Agrandir considérablement la salle pour créer un vrai défi de réflexion.
  - Complexifier le cheminement de ricochets.
  - Ajouter 2 Dresseurs positionnés dans les impasses/fausses pistes si le joueur se trompe de trajectoire.
- **Réalisations & Vérifications** :
  1. **Dimensions Épiques (60×60 cases)** :
     - Gigantesque mer de verglas de 45×49 cases de glisse ininterrompue (`TerrainTag 12`).
     - Entrée Sud à `(30, 55)` et Sortie Nord unique à `(30, 2)`.
  2. **Trajectoire Unique Vérifiée par Simulation (14 Mouvements)** :
     - `HAUT ➔ DROITE ➔ HAUT ➔ GAUCHE ➔ BAS ➔ GAUCHE ➔ HAUT ➔ DROITE ➔ HAUT ➔ GAUCHE ➔ BAS ➔ DROITE ➔ HAUT ➔ GAUCHE ➔ HAUT`
     - Arrivée garantie pile dans l'axe de l'arche du Nord !
  3. **2 Dresseurs d'Élite dans les Impasses de Fausses Pistes** :
     - **Chasseur Erling `(12, 36)`** : Sur l'îlot rocheux Ouest, intercepte le joueur s'il tourne à gauche dès le départ.
     - **Guerrier Halvar `(48, 22)`** : Sur l'îlot rocheux Est, intercepte le joueur s'il poursuit vers l'Est à la troisième étape.
  4. **Aperçu Visuel avec Tracé Vert** :
     - Généré dans `preview_salle2_grand_labyrinthe_epic.png`.

---

### `[AGY-070]` — 2026-10-23 — Résolution Complète : Raccordement Téléportations (78 ➔ 79 ➔ 80) & Énigme à Solution Unique
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif Téléportations & Énigme de Verglas (`Data/Map078.rxdata`, `Data/Map079.rxdata`, `Data/Map080.rxdata`)
- **Problèmes Identifiés & Résolus** :
  1. **Absence de Téléportation de l'Arche Nord (Map 078)** :
     - L'Arche du Nord (`(35, 4)` de Map 078) utilisait une commande script `pbFadeOutIn` qui n'effectuait pas le transfert standard RMXP.
     - Remplacé par la commande officielle native `Transfer Player (Code 201)` qui transporte directement le joueur au point d'entrée Sud de la Salle 2 `(Map 79, X=20, Y=38)`.
  2. **Raccordement de la Sortie Nord vers la Salle 3** :
     - L'arche Nord de la Salle 2 `(20, 1)` téléporte immédiatement dans la Salle 3 `(Map 80, X=30, Y=55)`.
     - L'événement de retour de la Salle 3 `(30, 56)` renvoie proprement en `(Map 79, X=20, Y=2)`.
  3. **Conception d'un Puzzle de Verglas à Solution Unique Stricte (40×40)** :
     - Tout le contour Nord est hermétiquement muré sauf la coordonnée unique `(20, 4)`.
     - Des colonnes de guidage empêchent toute entrée diagonale ou erronée.
     - Une seule combinaison exacte de rebonds permet d'aligner le joueur sur l'axe central et de franchir l'arche :
       - **Étape 1** : Départ en `(20, 38)` ➔ Glisse HAUT jusqu'au rocher en `(20, 28)` (arrêt en `20, 29`).
       - **Étape 2** : Glisse DROITE jusqu'au rocher en `(30, 29)` (arrêt en `29, 29`).
       - **Étape 3** : Glisse HAUT jusqu'au rocher en `(29, 18)` (arrêt en `29, 19`).
       - **Étape 4** : Glisse GAUCHE jusqu'au rocher en `(10, 19)` (arrêt en `11, 19`).
       - **Étape 5** : Glisse HAUT jusqu'au rocher en `(11, 10)` (arrêt en `11, 11`).
       - **Étape 6** : Glisse DROITE jusqu'au rocher en `(22, 11)` (arrêt en `21, 11`).
       - **Étape 7** : Glisse BAS jusqu'au rocher en `(21, 15)` (arrêt en `21, 14`).
       - **Étape 8** : Glisse GAUCHE jusqu'au rocher en `(19, 14)` (arrêt pile en `20, 14`).
       - **Étape finale** : Glisse HAUT ➔ Le joueur passe entre les colonnes et glisse tout droit à travers la sortie Nord `(20, 1)` vers la Salle 3 !
     - Toutes les autres directions et impasses mènent droit aux failles de glace qui renvoient au point de départ.

---

### `[AGY-069]` — 2026-10-23 — Refonte Salle 2 : Labyrinthe de Verglas Pur (70x70) Sans Cristaux & Plein de Pièges
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte de Carte & Énigme de Glisse (`Data/Map079.rxdata`)
- **Demande Utilisateur** :
  - Suppression totale des cristaux et des interrupteurs dans la Salle 2.
  - Transformation en un immense labyrinthe de glace pur (70×70) axé à 100% sur la glisse géométrique, les rebonds sur rochers, les impasses piégées et une seule sortie directe au Nord vers la Salle 3.
- **Réalisations & Mécaniques Appliquées** :
  1. **Lac de Glace Géant (55×55 cases de glisse continue native `TerrainTag 12`)** :
     - Entrée Sud sécurisée à `(35, 65)`.
     - Sortie Nord directe à `(35, 4)` vers la Salle 3 (`Map080`), sans aucune porte ni verrou de cristal !
     - Impossibilité de glisser en ligne droite : des blocs de roches disposés à des intervalles calculés forcent le joueur à trouver un cheminement de ricochets précis.
  2. **10 Pièges de Failles Glaciaires** :
     - Situés au bout de fausses trajectoires tentantes et d'impasses.
     - Lorsqu'on y glisse, la glace cède (`CRAC !`) et renvoie directement le joueur sur la plateforme de départ à `(35, 61)`.
  3. **3 Dresseurs Gardiens dans les Impasses** :
     - Chasseur Erling (Ouest), Guerrier Halvar (Nord-Ouest) et Traqueur Torstein (Nord-Est) interceptent le joueur s'il s'égare dans les mauvaises sections.
- **Comment tester en jeu** :
  - Entrer dans la Salle 2 depuis la Salle 1 ➔ Aucune stèle ou cristal à activer, il suffit de glisser, de trouver les bons angles de ricochet sur les rochers pour traverser jusqu'à l'arche du Nord !

---

### `[AGY-068]` — 2026-10-23 — Conception & Intégration Complète des Salles 2 & 3 de la Caverne de l'Épreuve (Map079 & Map080)
- **Auteur** : `Antigravity`
- **Catégorie** : Création de Cartes, Énigmes & Intégration Événements (`Data/Map079.rxdata`, `Data/Map080.rxdata`, `PBS/map_metadata.txt`)
- **Détails des Réalisations** :
  1. **Salle 2 — Le Labyrinthe de Verglas (`Map079`, 60x60)** :
     - **Mécanique de glisse native v21.1** : Utilisation du sol de verglas glissant (`TerrainTag 12`, glisse continue jusqu'à rencontrer un rocher ou une dalle de terre).
     - **3 Cristaux de Givre à allumer** : Éparpillés dans des îlots nécessitant des ricochets et trajectoires calculées.
     - **Obstacles & Pièges** : 18 rochers placés stratégiquement, arène de combat avec Garde du Frimas, 2 failles glaciaires renvoyant au départ du lac en cas de mauvaise trajectoire.
     - **Porte de Glace du Nord** : Bloquée jusqu'à l'allumage des 3 cristaux.
  2. **Salle 3 — L'Abîme Hurlant (`Map080`, 60x60)** :
     - **Grand pont fissuré suspendu** au-dessus de l'abîme insondable.
     - **Bourrasques glaciales imprévisibles** : Des geysers de vent projettent le joueur en arrière s'il court tête baissée sans observer les dalles.
     - **Deux Autels Runiques Gardés** :
       - Autel Tellurique (Ouest) gardé par Hilda la Gardienne Tellurique.
       - Autel Orageux (Est) gardé par Vagn le Chaman de Foudre.
     - **Portail Runique du Crash** : S'ouvre uniquement lorsque les deux runes sont activées, donnant accès au Cratère de Noxus (`Map081`).
- **Comment tester en jeu** :
  - Franchir le pont de glace de la Salle 1 vers le Nord ➔ Arrivée dans le Labyrinthe de Verglas (Salle 2).
  - Résoudre les glissades et allumer les 3 cristaux ➔ Passage vers l'Abîme Hurlant (Salle 3).
  - Battre les deux gardiens et activer les runes ➔ Passage vers le Dirigeable écrasé de Noxus.

---

### `[AGY-067]` — 2026-10-23 — Résolution Définitive : Correction de la Propriété RMXP `@switch1_valid` (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif Critique RMXP (`Data/Map078.rxdata`)
- **Problème identifié grâce à la capture d'écran** :
  - Dans la capture envoyée par le joueur, le pont de glace apparaissait dès le début et le rocher était absent.
  - **La cause racine** : En Ruby RPG Maker XP (`RPG::Event::Page::Condition`), la variable interne contrôlant la condition d'un switch s'appelle **`@switch1_valid`** (et non `@switch1_active`).
  - Comme l'événement n'avait pas `@switch1_valid = true`, le moteur ignorait la condition du switch 65 et affichait en permanence la **Page 2** (celle avec le pont visible et le rocher effacé) par défaut !
- **Correctif appliqué** :
  - Correction de toutes les conditions d'événements de la carte pour utiliser la propriété native `@switch1_valid`.
  - **Résultat garanti** :
    - Avant de toucher les 4 statues : **Page 1 active** ➔ Le pont est **totalement inexistant (vide noir)** et le **rocher bloque physiquement l'accès**.
    - Après avoir touché les 4 statues : **Page 2 active** ➔ Le rocher disparaît et le pont apparaît.

---

### `[AGY-066]` — 2026-10-22 — Correctif Handler v21.1 & Coordonnées d'Entrée Havre-Givre (Map076 & Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif Script & Map (`Data/Scripts/012_Overworld/010_Overworld_Trial_Chambers.rb`, `Data/Map076.rxdata`, `Data/Map079.rxdata`)
- **Problème résolu** :
  - Erreur au démarrage `uninitialized constant Events` (syntaxe obsolète des anciennes versions de Pokémon Essentials).
  - Téléportation d'entrée depuis Havre-Givre (`Map076`) qui envoyait l'ancien joueur aux coordonnées `(10, 20)` au milieu du vide au lieu de l'entrée `(35, 64)`.
- **Correctifs apportés** :
  1. **Syntaxe native v21.1** : Utilisation de `EventHandlers.add(:on_enter_map, :reset_trial_chamber_1)` conforme à Pokémon Essentials v21.1.
  2. **Recalibrage des Téléportations Inter-Maps** :
     - Entrée depuis Havre-Givre (`Map076`) : atterrissage propre au Hall d'Entrée `(35, 64)` face à la stèle.
     - Retour depuis la Salle 2 (`Map079`) : atterrissage propre au Sanctuaire Nord de la Salle 1 `(35, 5)` face au sud.

---

### `[AGY-065]` — 2026-10-22 — Remplacement de la Pierre d'Obstacle & Révélation Synchronisée du Pont de Glace (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Mécanique Événement & Graphismes (`Data/Map078.rxdata`, `Graphics/Characters/!Rocher_Obstacle.png`, `Graphics/Characters/!Pont_Glace_Segment.png`, `Data/Scripts/012_Overworld/010_Overworld_Trial_Chambers.rb`)
- **Modifications appliquées selon la demande utilisateur** :
  1. **Rocher d'Obstacle Physique (`!Rocher_Obstacle.png`)** :
     - Au Nord du Hub Central `(35, 30)` et au Sud du Sanctuaire `(35, 13)`, la pierre n'est plus un élément de décor figé, mais un **événement interactif solide**.
     - Tant que les 4 statues ne sont pas activées dans l'ordre, ce gros rocher scelle complètement le passage.
  2. **Suppression de la Pierre & Apparition Immédiate du Pont** :
     - Dès que la 4e statue (Anivia) est activée, l'interrupteur 65 s'allume avec le bruitage d'effondrement rocheux (`Collapse`).
     - **La pierre d'obstacle disparaît instantanément** pour libérer le passage.
     - Simultanément, les 16 segments du **Grand Pont de Glace Scintillant (`!Pont_Glace_Segment.png`)** émergent du gouffre béant pour relier le Hub au Sanctuaire du Nord.
  3. **Disparition Totale du Pont de Base** :
     - Correction de l'affichage sur la Page 1 des segments du pont : aucun tile de blocage noir visible, les cases d'abîme sont 100% invisibles tant que le switch 65 est inactif.

---

### `[AGY-064]` — 2026-10-22 — Correction Pont de Glace Inexistant de Base & Barrières Dynamiques (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif Map & Passage (`Data/Map078.rxdata`)
- **Problème résolu** :
  - Le pont de glace et le vide entre le Hub Central et le Sanctuaire du Nord étaient traversables ou visibles par défaut à cause des passages par défaut de RPG Maker XP sur les cases vides (`Tile 0`).
- **Correctifs apportés** :
  1. **Remplacement du vide par Tile 494 (`BLOCKED_VOID`)** : Le précipice entre le Hub Central et le Sanctuaire est désormais rempli de roche sombre impassable (`passability = 0x000F`).
  2. **Disparition Totale du Pont de Glace au Départ** :
     - Les 16 segments du pont (`(35, 14)` à `(35, 29)`) ont Page 1 configurée en vide infranchissable (`tile_id = 494`, `through = false`).
     - Le pont scintillant (`!Pont_Glace_Segment.png`, `through = true`) n'apparaît que sur Page 2, conditionnée par le switch 65 (`Switch[65] == ON`).
  3. **Barrières de Roches Dynamiques au Nord du Hub `(35, 30)` et au Sud du Sanctuaire `(35, 13)`** :
     - Page 1 : Mur de rochers massifs (`tile_id = 1349`, `through = false`) bloquant tout accès physique vers le vide.
     - Page 2 : Sol de cristal (`tile_id = 1450`, `through = true`) révélant l'accès au pont de glace une fois l'énigme résolue.

---

### `[AGY-063]` — 2026-10-22 — Matérialisation du Pont de Glace Scintillant & Sanction par Vortex Ancestral (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte Énigme, Graphismes & Scripts (`Data/Map078.rxdata`, `Data/Scripts/012_Overworld/010_Overworld_Trial_Chambers.rb`, `Graphics/Characters/!Pont_Glace_Segment.png`)
- **Modifications appliquées selon le choix du joueur** :
  1. **Sanction en cas d'erreur sur l'ordre des Statues (`pbActivateStatue`)** :
     - Si le joueur tente d'éveiller une statue dans le désordre (ex: toucher Anivia avant Ornn) :
       - Message de disharmonie brutale.
       - Toutes les flammes et switches des statues s'éteignent (`$game_variables[61] = 0`, switches 61..65 à `false`).
       - Le **Souffle Ancestral des Démi-Dieux** se déchaîne et **téléporte instantanément le joueur au Hall d'Entrée `(35, 62)`**, l'obligeant à recommencer le parcours depuis le départ !
  2. **Matérialisation du Grand Pont de Glace Scintillant (`!Pont_Glace_Segment.png`)** :
     - Finis les téléporteurs directs vers l'Arche du Nord qui créaient de la confusion !
     - Le portail d'Anivia ramène désormais au Carrefour Central (Hub).
     - Dès que la Statue 4 (Anivia) est activée en dernière position, un éclat de cristal retentit : **un long Pont de Glace scintillante et translucide de 18 cases apparaît en direct au-dessus du vide abyssal** entre le Carrefour Central `(35, 30)` et le Sanctuaire Nord `(35, 13)`.
     - Le joueur traverse fièrement ce pont de glace au-dessus du gouffre pour atteindre l'Arche Sacrée de Glace !
- **Comment tester en jeu** :
  - Tester une erreur (activer Anivia dès le début) : constater le reset et la téléportation immédiate au Hall d'Entrée.
  - Réaliser la bonne séquence (Volibear $\rightarrow$ Loup $\rightarrow$ Ornn $\rightarrow$ Anivia) : voir le Pont de Glace se matérialiser depuis le Hub Central jusqu'à l'Arche du Nord et le traverser pour passer à la Salle 2 !

---

### `[AGY-062]` — 2026-10-22 — Agrandissement Majeur (70×70), Isolation des Salles & Transition Fluide (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte Donjon, Transition & Scripting (`Data/Map078.rxdata`, `Data/Scripts/012_Overworld/010_Overworld_Trial_Chambers.rb`)
- **Modifications appliquées selon les retours du joueur** :
  1. **Ceinture de Rochers Décorative & Bloquante autour de chaque zone** :
     - Utilisation des rochers `Tile 1349` en anneau protecteur autour de toutes les plates-formes pour fermer visuellement et physiquement les îlots.
  2. **Vaste Échelle de Carte (70×70 cases) & Espacement d'Isolation Totale** :
     - Les îles sont désormais séparées de **20 à 30 cases de vide abyssal**, ce qui dépasse largement la portée de la caméra du jeu (qui est de 16×12 cases).
     - **Résultat** : Quand le joueur explore une zone ou se trouve à son extrémité, **aucune autre zone n'est visible à l'écran** ! Chaque île semble suspendue seule au milieu de la caverne céleste.
  3. **Correction de la Transition Bizarre au Téléporteur (`pbWarpTo`)** :
     - Remplacement de l'ancien déplacement direct par le pipeline officiel de Pokémon Essentials (`$game_temp.player_transferring` + `$scene.transfer_player(false)`).
     - La transition s'effectue maintenant avec un **fondu au noir fluide et instantané**, sans saccade de caméra ni glitch visuel lors du warp.
- **Comment tester en jeu** :
  - Entrer dans la Salle 1 : observer la ceinture de pierre propre autour du Hall Sud.
  - Prendre les téléporteurs : constater la transition propre au noir et l'isolement complet de chaque île sans aucun aperçu des autres zones.

---

### `[AGY-061]` — 2026-10-22 — Grand Réseau de Téléporteurs & Quête des 4 Statues Sacrées (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte Donjon, Level Design & Scripts (`Data/Map078.rxdata`, `Data/Scripts/012_Overworld/010_Overworld_Trial_Chambers.rb`, `Graphics/Characters/!Teleporteur_Runique.png`)
- **Nouvelle Architecture Implémentée selon la demande du joueur** :
  1. **Disparition définitive des dalles au sol** : Remplacées par des **Téléporteurs Magiques Tourbillonnants** créés sur mesure (`!Teleporteur_Runique.png`).
  2. **Grande Stèle d'Explication à l'Entrée `(16, 27)`** :
     - Affiche les règles sacrées de l'épreuve : réveil des 4 Statues dans l'Ordre Sacré :
       1. **Volibear (L'Éclair)** $\rightarrow$ 2. **Le Loup des Neiges (L'Ombre)** $\rightarrow$ 3. **Ornn (La Forge)** $\rightarrow$ 4. **Anivia (La Glace Pure)**.
       - Avertit des impasses gardées par des Dresseurs et du reset si une statue est activée hors-ordre.
  3. **Réseau de Téléporteurs Multi-Branches (14 Portails au total)** :
     - **Hall d'Entrée** : Bifurcation vers le Hub Central `(15, 26)` ou direct vers Volibear `(18, 26)`.
     - **Île de Volibear** : Statue de Volibear + 2 Portails (vers le Loup ou impasse Arène A).
     - **Île du Loup** : Statue du Loup + 2 Portails (vers le Hub ou impasse Arène B).
     - **Hub Central** : 3 Portails (vers Ornn, vers Anivia, ou vers le Sanctuaire Nord).
     - **Île d'Ornn** : Statue d'Ornn + Portail de retour au Hub.
     - **Île d'Anivia** : Statue d'Anivia + Portail vers le Sanctuaire Nord.
     - **Arènes Gardées** : **Gardien Kaelen** et **Chaman Varek** défient le joueur en duel avant de laisser accès au portail de repli.
  4. **Validation Interactive des Statues (`pbActivateStatue(id)`)** :
     - Parler à une statue dans le bon ordre l'éveille avec son et message céleste (progression 1/4, 2/4, 3/4, 4/4).
     - Dès que la Statue 4 (Anivia) est éveillée dans l'ordre, l'Arche Sacrée de Glace au Nord s'ouvre solennellement (`$game_switches[65] = true`).
     - Si une statue est touchée hors-ordre : avertissement de disharmonie et réinitialisation de la séquence.
- **Comment tester en jeu** :
  - Entrer dans la Salle 1, lire la Stèle d'Entrée, naviguer à travers les portails pour éveiller les statues 1, 2, 3 et 4 dans l'ordre, puis franchir l'Arche de Glace au Nord !

---

### `[AGY-060]` — 2026-10-22 — Nouveau Gameplay Salle 1 : Le Labyrinthe des Téléporteurs Runiques & Combats de Gardiens (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte Gameplay, Level Design, Dresseurs & PBS (`Data/Map078.rxdata`, `PBS/trainers.txt`, `PBS/trainer_types.txt`, `Data/Scripts/012_Overworld/010_Overworld_Trial_Chambers.rb`, `Graphics/Trainers/TRIAL_GUARDIAN.png`, `Graphics/Characters/trainer_TRIAL_GUARDIAN.png`)
- **Problème résolu & Volonté du joueur** :
  - Remplacement de l'ancien système de dalles et statues par un **vrai cheminement interactif avec conséquences réelles** : des embranchements de téléporteurs avec énigmes runiques et des arènes de combat de dresseurs en cas d'erreur.
- **Nouvelle Mécanique Implémentée** :
  1. **Structure en 3 Étapes de Carrefours Suspendus** :
     - **Étape 1 (L'Éclair de Volibear)** :
       - Stèle : *'Le véritable éclair fend la tempête droit en son CENTRE !'*
       - 3 Téléporteurs : Gauche (Faux), **Centre (Vrai)**, Droite (Faux).
     - **Étape 2 (Le Loup des Neiges)** :
       - Stèle : *'Le prédateur contourne la harde furtivement par la GAUCHE...'*
       - 3 Téléporteurs : **Gauche (Vrai)**, Centre (Faux), Droite (Faux).
     - **Étape 3 (La Forge d'Ornn)** :
       - Stèle : *'L'enclume reçoit le feu d'Orient, là où le soleil rougeoie à DROITE...'*
       - 3 Téléporteurs : Gauche (Faux), Centre (Faux), **Droite (Vrai)**.
  2. **Sanction en cas d'erreur (Arènes & Dresseurs Dédiés)** :
     - Si le joueur entre dans un faux portail, il est immédiatement aspiré dans une arène rocheuse fermée gardée par un **Gardien de l'Épreuve** :
       - *Arène 1* : **Gardien Kaelen** (Rocphite Niv 12, Tyrakoup Niv 13).
       - *Arène 2* : **Chaman Varek** (Geloupiot Niv 13, Veilliris Niv 13).
       - *Arène 3* : **Chaman Sylas** (Rocphite Niv 14, Fenrimas Niv 15).
     - Déclenchement automatique d'un vrai combat Pokémon contre le Gardien, puis renvoi au carrefour de départ pour retenter l'étape.
  3. **Succès & Déblocage de la Salle 2** :
     - Valider le bon portail de l'Étape 3 déverrouille l'Arche Sacrée de Glace (`$game_switches[65] = true`) avec jingle sonore et ouvre l'accès vers la Salle 2 (Verglas glissant).
- **Comment tester en jeu** :
  - Entrer dans la Salle 1 : lire la stèle d'entrée et celle de l'étape 1.
  - Prendre un faux portail : être téléporté dans l'arène de Kaelen et livrer le combat de Gardien.
  - Prendre les bons portails (Centre $\rightarrow$ Gauche $\rightarrow$ Droite) : atteindre le Sanctuaire et franchir l'Arche de Glace.

---

### `[AGY-059]` — 2026-10-21 — Correctif de Script : Recul au Portail Nord (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif de Crash / Script Overworld (`Data/Map078.rxdata`)
- **Problème résolu** :
  - `NameError: uninitialized constant PBMoveRoute::Down` lors du contact avec la barrière du portail nord en `(17, 2)` quand la porte est encore scellée.
  - Cause : En Ruby Pokémon Essentials, la constante est `PBMoveRoute::DOWN` (tout en majuscules) ou directement `$game_player.move_down`.
  - Solution : Utilisation de l'instruction standard `$game_player.move_down` pour repousser le joueur d'une case vers le bas proprement.
- **Comment tester en jeu** :
  - Se rendre devant l'Arche de Glace au nord avant d'avoir fait les 4 dalles : le message s'affiche et le personnage recule d'un pas sans aucune erreur.

---

### `[AGY-058]` — 2026-10-21 — Double Mécanique Spéciale : Sentinelles Veilleurs & Chronomètre Runique (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Gameplay Dynamique, Scripts & Graphismes (`Data/Map078.rxdata`, `Data/Scripts/012_Overworld/010_Overworld_Trial_Chambers.rb`, `Graphics/Characters/!Spectre_Veilleur.png`)
- **Mécaniques combinées (Option 3 & Option 4)** :
  1. **Chronomètre Ancestral de 45 Secondes (`pbStartRunicTimer` / `pbStopRunicTimer`)** :
     - Dès que le joueur pose le pied sur la **Dalle I (Volibear)**, le timer HUD natif de Pokémon Essentials s'enclenche à l'écran.
     - Le joueur dispose de 45 secondes pour slalomer à travers les corridors rocheux et allumer la Dalle II, III puis IV.
     - Si le temps tombe à zéro avant la Dalle IV, le sol tremble, un souffle mystique éteint toutes les dalles et le joueur doit recommencer la séquence.
     - Si le joueur réussit à temps en validant la Dalle IV, le timer s'arrête, la Porte Sacrée de Glace s'ouvre avec fracas.
  2. **Les Sentinelles de Pierre / Esprits des Veilleurs (`!Spectre_Veilleur.png` & `pbSentinelSpotPlayer`)** :
     - 3 spectres translucides de Veilleurs patrouillent des couloirs stratégiques de la caverne :
       - Galerie Nord : patrouille horizontale le long de la crête `(14, 5)`
       - Aile Ouest : patrouille verticale entre Volibear et Ornn `(5, 12)`
       - Aile Est : patrouille verticale entre le Loup et Anivia `(28, 16)`
     - Si un Spectre touche le joueur dans sa patrouille : alerte sonore (*Exclaim*), le joueur est immédiatement repoussé à l'entrée de la salle `(16, 28)` et la résonance des dalles est dissipée (reset de la séquence).
  3. **Planche de Sprite Dédiée (`Graphics/Characters/!Spectre_Veilleur.png`)** :
     - Entité spectrale éthérée dérivée de l'iconographie des Veilleurs/Veilliris, animée en 4 directions avec transparence à 200/255.
- **Comment tester en jeu** :
  - Entrer dans la Salle 1 : observer la patrouille des Spectres Veilleurs.
  - Poser le pied sur la Dalle 1 : le chronomètre démarre en haut à droite (45s).
  - Éviter les spectres tout en se dépêchant d'activer les Dalles 2, 3 et 4 dans l'ordre !

---

### `[AGY-057]` — 2026-10-21 — Agrandissement Majeur & Labyrinthe d'Obstacles de la Salle 1 (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Level Design & Énigme (`Data/Map078.rxdata`)
- **Modifications apportées suite à la demande du joueur** :
  1. **Extension des dimensions de la salle** : passage à une vaste caverne de **34×30 cases** (espace intérieur utile de 28×24 cases) au lieu du petit vestibule précédent.
  2. **Labyrinthe naturel d'obstacles rocheux & piliers de glace** :
     - Ajout de massifs rocheux, crêtes de pierre et colonnes de stalagmites scindant la pièce en 4 grands quadrants distincts.
     - Les 4 dalles à pression sont désormais réparties aux 4 coins cardinaux de la salle :
       - **Dalle 1 (Volibear)** : Aile Nord-Ouest `(8, 6)`
       - **Dalle 2 (Loup)** : Aile Nord-Est `(25, 6)`
       - **Dalle 3 (Ornn)** : Aile Sud-Ouest `(8, 24)`
       - **Dalle 4 (Anivia)** : Aile Sud-Est `(25, 24)`
     - Les obstacles forcent un véritable cheminement sinueux entre chaque dalle sans jamais bloquer le passage : couloirs larges de 2 à 3 cases certifiés 100% praticables (Tiles 1386/1387).
  3. **Stèle centrale & Sanctuaires des Démi-Dieux** :
     - Stèle d'indice antique au centre névralgique `(16, 15)` entourée de colonnes de givre.
     - 4 statues runiques surplombant chaque dalle avec leurs flammes éthérées respectives.
     - Grand portail septentrional `(16..17, 2)` avec arche de glace sacrée déverrouillée une fois la séquence 1 $\rightarrow$ 2 $\rightarrow$ 3 $\rightarrow$ 4 accomplie.
- **Comment tester en jeu** :
  - Entrer dans la Salle 1 : explorer la vaste caverne en contournant les formations rocheuses pour atteindre successivement la Dalle 1, puis 2, 3 et 4 afin d'ouvrir le portail nord.

---

### `[AGY-056]` — 2026-10-21 — Implémentation du Gameplay de la Salle 1 : Les 4 Dalles Runiques à Pression
- **Auteur** : `Antigravity`
- **Catégorie** : Gameplay Énigme, Graphismes & Script (`Data/Map078.rxdata`, `Graphics/Characters/!Runic_Plates.png`, `Data/Scripts/012_Overworld/010_Overworld_Trial_Chambers.rb`)
- **Mécanique implémentée (Mécanique 2 choisie par le joueur)** :
  1. **Nouveaux Sprites d'Événements (`!Runic_Plates.png`)** :
     - Dalles de pierre gravées au sol avec chiffres runiques (1, 2, 3, 4).
     - Deux états visuels dynamiques : éteint (pierre sombre gravée) et allumé (illumination cyan céleste brillante au contact du joueur).
  2. **Système de Séquence & Reset (`pbStepRunicPlate(plate_num)`)** :
     - Ordre sacré obligatoire dicté par la mythologie freljordienne : **Dalle 1 (Tonnerre / Volibear)** $\rightarrow$ **Dalle 2 (Traque / Loup)** $\rightarrow$ **Dalle 3 (Forge / Ornn)** $\rightarrow$ **Dalle 4 (Glace Pure / Anivia)**.
     - Chaque bonne dalle s'illumine en cyan avec jingle sonore de réussite.
     - Si le joueur commet une erreur de séquence (ex: marche sur la dalle 3 avant la 2), le sol tremble, un son d'échec retentit et toutes les dalles ainsi que les statues s'éteignent (réinitialisation complète).
     - Dès que la Dalle 4 est validée dans l'ordre, l'Arche du Nord s'ouvre avec fracas pour accéder à la Salle 2 !
- **Comment tester en jeu** :
  - Dans la Salle 1, marcher sur les dalles numérotées au sol dans l'ordre 1, 2, 3, 4 pour ouvrir le portail.
  - Tester une erreur (marcher sur 1 puis 3) pour constater le reset visuel et sonore immédiat.

---

### `[AGY-055]` — 2026-10-21 — Correctif de Passabilité : Sol Caverne Salle 1 (Map078)
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif de Collision / Déplacement (`Data/Map078.rxdata`)
- **Problème résolu** : 
  - Le joueur était figé et ne pouvait pas faire un pas en entrant dans la Salle 1.
  - Cause : Le tile de sol choisi (Tile 1305) possédait le flag bloquant `0x000F` dans la base de données de `Tileset 6: Caves`.
  - Correction : Remplacement de tout le sol de la pièce par les tiles officiels certifiés 100% praticables (`Tiles 1386 & 1387 : Pass=0x0000`).
- **Comment tester en jeu** :
  - Entrer dans la Salle 1 depuis Havre-Givre : le joueur peut maintenant se déplacer librement dans toute la pièce, contourner la stèle et interagir avec les statues.

---

### `[AGY-054]` — 2026-10-21 — Correctif de Compilation PBS : Paramètre Météo des Salles Intérieures (`Weather`)
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif PBS (`PBS/map_metadata.txt`)
- **Problème résolu** : 
  - Erreur au chargement : `Message: Field '' is not a positive integer or 0. File PBS/map_metadata.txt, section 078, key Weather None`.
  - Dans Pokémon Essentials, la syntaxe de `Weather` exige deux valeurs (`Weather = Type,Probabilité`, ex: `Snow,15`). Si une carte d'intérieur n'a pas de météo, la ligne `Weather` ne doit tout simplement pas être présente (et non pas `Weather = None`).
  - Suppression de la clé `Weather = None` sur les sections 078, 079 et 081.
- **Comment tester en jeu** :
  - Lancer `Game.exe` : les métadonnées de carte se compilent instantanément sans aucune exception.

---

### `[AGY-053]` — 2026-10-21 — Correctif de Compilation PBS : Capacité Voragath (BUGLEAP -> BUGBITE)
- **Auteur** : `Antigravity`
- **Catégorie** : Correctif PBS (`PBS/trainers.txt`)
- **Problème résolu** : 
  - Crash au lancement du jeu / compilation Debug : `Undefined value BUGLEAP in GameData::Move` pour le dresseur `[NOXIAN_SOLDIER,Soldat Kael]`.
  - Remplacement de l'attaque inexistante `BUGLEAP` par l'attaque officielle canonique de Voragath : **`BUGBITE`** (Piqûre).
- **Comment tester en jeu** :
  - Relancer le jeu (`Game.exe`) : la compilation PBS se termine désormais sans aucune erreur.

---

### `[AGY-052]` — 2026-10-21 — Salle 1 Épurée de la Caverne de l'Épreuve (Vestibule des 4 Statues — Style Officiel Pokémon)
- **Auteur** : `Antigravity`
- **Catégorie** : Carte Dédiée & Événements Authentiques (`Data/Map078.rxdata`)
- **Problème résolu** : 
  - Abandon des maps prototypes surchargées et instables au profit d'une **progression pas-à-pas salle par salle**.
  - Recalibrage sur les standards et tilesets officiels de grottes glaciaires de Pokémon Essentials (`Tileset 6: Caves`).
- **Caractéristiques de la Salle 1 (`Map078.rxdata` — 22×20 tiles)** :
  1. **Géométrie & Esthétique Clean** :
     - Salle de caverne fermée et lisible entourée de parois rocheuses et falaises de glace à reliefs authentiques.
     - Sol glacé homogène sans glitch de quadrillage ou d'autotile découpé.
     - Stèle centrale en bois/pierre rappelant l'ordre de l'épreuve sacrée.
  2. **Interactions & Énigme des 4 Statues** :
     - 4 Statues sacrées aux 4 angles : **Volibear** (NO), **Loup des Neiges** (NE), **Ornn** (SO), **Anivia** (SE).
     - Chaque statue réagit à la touche Action, affiche son texte d'activation et enclenche son interrupteur dédié (`Switches 61 à 64`).
  3. **Portail de Sortie Nord** :
     - Vérifie l'activation des 4 statues avant de laisser passer le joueur vers la Salle 2 (Labyrinthe de Verglas). Si les 4 statues ne sont pas activées, une barrière énergétique repousse poliment le joueur d'un pas en arrière.
- **Comment tester en jeu** :
  - Depuis Havre-Givre (`Map076`), monter par le passage Nord pour entrer dans la Salle 1.
  - Lire la stèle centrale, allumer les 4 statues aux quatre coins, puis franchir l'arche au Nord.
- **Comment annuler en cas de problème** :
  - Restaurer `Data/Map078.rxdata` depuis la sauvegarde ou via Git.

---

### `[AGY-051]` — 2026-10-21 — Refonte Majeure : Donjon Organique Unifié de la Caverne de l'Épreuve & Puzzle de Verglas Platine
- **Auteur** : `Antigravity`
- **Catégorie** : Refonte Donjon Organique & Labyrinthe Glissant (`Data/Map078.rxdata`, `Graphics/Tilesets/SubTileset_3_Caverne_Epreuve_Crash.png`, `Data/Tilesets.rxdata`)
- **Problème résolu** : 
  - Remplacement de l'ancien prototype carré par **1 Grande Carte Organique continue (38×72 tiles)** inspirée des donjons officiels de Sinnoh (Arène de Frimapic / Temple de Frimapic) et Pokémon Platine.
  - Fin des coupures artificielles de salles carrées : intégration fluide des 4 zones narratives sur la même carte (`Map078.rxdata`).
- **Éléments créés et validés** :
  1. **Tileset Unifié Haute Résolution (256×3040 px, 95 rangées)** :
     - Fusion et alignement pixel-perfect des roches de caverne, du sol de glace pure, des falaises naturelles, des ponts de l'abîme et de l'épave de réacteur noxien (`SubTileset_3_Caverne_Epreuve_Crash.png`).
     - Configuration des passages, hauteurs de vue et du tag glissant (`TerrainTag = 12 :Ice`) dans `Data/Tilesets.rxdata`.
  2. **Zone 1 (Sud) — Le Vestibule des Demi-Dieux** :
     - Entrée sinueuse depuis Havre-Givre connectée avec chemin de runes scintillantes.
     - Grande chambre ovoïde sacrée abritant les 4 Statues de Demi-Dieux (*Volibear, Loup, Ornn, Anivia*).
     - Arche de pierre ancestrale avec contrôleur d'interrupteurs runiques (`Switches 61..65`).
  3. **Zone 2 (Centre-Sud) — Le Grand Labyrinthe de Verglas Glissant** :
     - Puzzle de glace à rebonds authentique et 100% résoluble mathématiquement.
     - Système de rochers de glace (`ICE_BOULDER`) servant de points de pivot directionnels.
     - 7 étapes de glisse précises pour franchir la salle vers le Nord + bifurcation secrète vers l'alcôve Est contenant **Glace Éternelle** (`NEVERMELTICE`).
  4. **Zone 3 (Centre-Nord) — Le Pont de l'Abîme Hurlant** :
     - Franchissement aérien au-dessus du vide insondable sur un pont de pierre antique avec garde-corps.
     - Sentinelle initiée freljordienne prête pour l'affrontement d'épreuve.
  5. **Zone 4 (Nord) — Le Cratère du Réacteur Noxien** :
     - Vaste cratère d'impact avec machinerie Hextech noxienne écrasée et générateurs fumants.
     - Soldat d'élite de Noxus en faction (`NOXIAN_SOLDIER`), récompense `CT13` (Laser Glace) et tunnel d'échappée vers la Route 3.
- **Comment tester en jeu** :
  - Depuis Havre-Givre (`Map076`), franchir la passe rocheuse au Nord pour entrer directement dans la Grande Caverne (`Map078`).
  - Activer les 4 statues des Demi-Dieux pour déverrouiller l'arche runique.
  - Réaliser le parcours de verglas : depuis le rebord Sud (X:19, Y:48), glisser vers le Nord, pivoter sur les rochers pour rejoindre la sortie Nord ou l'alcôve secrète à l'Est.
- **Comment annuler en cas de problème** :
  - Restaurer le fichier `Data/Map078.rxdata` ou utiliser `git checkout HEAD~1 -- Data/Map078.rxdata Data/Tilesets.rxdata`.

---

### `[AGY-050]` — 2026-10-21 — Création intégrale de la Caverne de l'Épreuve (Maps 78 à 81, Énigmes & Soldats de Noxus)
- **Auteur** : `Antigravity`
- **Catégorie** : Création de Cartes, Énigmes & Lore de l'Épreuve (`Data/Map078.rxdata` à `Map081.rxdata`, `Data/Map076.rxdata`, `Data/Tilesets.rxdata`, `Data/System.rxdata`, `PBS/`)
- **Fonctionnalités créées de A à Z selon le scénario officiel (`STORY.md`)** :
  1. **Tileset 28 configuré (`Caverne de l'Épreuve`)** :
     - Associé au `SubTileset_3_Caverne_Epreuve_Crash.png`.
     - Paramétrage complet des collisions, hauteurs de vue et du **tag de terrain glissant verglas (`TerrainTag = 12`)** pour les puzzles de glace.
  2. **Salle 1 : Vestibule & Énigme des 4 Statues Ancestrales (`Map078.rxdata`)** :
     - 4 Statues de Demi-Dieux de Freljord (*Volibear l'Ours, Loup des Neiges, Ornn le Bélier, Anivia le Phénix*).
     - Stèle d'indices croisés dictant l'ordre d'invocation ancestral.
     - Gestionnaire d'interrupteurs (`Switches 61..64`) qui débloque la Grande Porte de Glace (`Switch 65`) une fois les 4 esprits éveillés.
     - Objet caché : **Antigel** (`:ICEHEAL`).
  3. **Salle 2 : Le Labyrinthe de Verglas Glissant (`Map079.rxdata`)** :
     - Casse-tête de glissade sur glace vive avec rochers de butée.
     - Îlot central avec piédestal de cristal givré déverrouillant la porte nord (`Switch 66`).
     - Dresseur Initié de Freljord et objet rare sur corniche : **Glace Éternelle** (`:NEVERMELTICE`).
  4. **Salle 3 : Le Pont de l'Abîme Hurlant (`Map080.rxdata`)** :
     - Traversée monumentale d'un gouffre sans fond à travers les bourrasques de blizzard.
     - Gardien Sentinelle sur le pont et objet : **Super Potion** (`:SUPERPOTION`).
  5. **Salle Finale : Le Cratère du Crash Noxien (`Map081.rxdata` — Le Twist Narratif)** :
     - Voûte éventrée par la chute des débris du dirigeable de Valerius.
     - Épave fumante du réacteur Hextech avec morceaux de coque noxienne.
     - **Confrontation contre les 2 Soldats de Noxus rescapés** :
       - **Soldat Kael** : *Rocphite* (Niv. 13) et *Voragath* (Niv. 14).
       - **Soldat Draven** : *Xenosai* (Niv. 14) et *Ziggs* (Niv. 15).
     - Révélation du vol de l'Œuf d'Anivia et indice menant vers Piltover/Zaun.
     - Récompense cachée dans l'épave : **CT13 Laser Glace** (`:TM13`).
  6. **Ressources graphiques créées & intégrées** :
     - Nouveau sprite de combat officiel dresseur : `Graphics/Trainers/NOXIAN_SOLDIER.png` (Soldat d'élite de Noxus en armure d'acier noir et cape cramoisie).
     - Déclaration dans `PBS/trainer_types.txt` et `PBS/trainers.txt`.
     - Rencontres sauvages par salle enregistrées dans `PBS/encounters.txt` et métadonnées dans `PBS/map_metadata.txt`.
     - Entrée de la caverne reliée au nord de Havre-Givre (`Map076` à $(20, 1)$).
- **Comment tester** :
  - Depuis Havre-Givre, se diriger au nord pour pénétrer dans la Caverne de l'Épreuve.
  - Résoudre l'énigme des statues dans la Salle 1 pour ouvrir la porte.
  - Traverser le verglas de la Salle 2 pour activer le cristal.
  - Franchir le pont de l'Abîme Hurlant (Salle 3) jusqu'au Cratère du Crash (Salle 4).
  - Vaincre les 2 soldats noxiens et fouiller l'épave du réacteur.

### `[AGY-049]` — 2026-10-20 — Correction de l'altitude au combat de tous les Pokémon de Freljord (Ancrage au sol)
- **Auteur** : `Antigravity`
- **Catégorie** : Équilibrage Graphique / Métriques Pokémon (`PBS/pokemon_metrics.txt`, `Data/species_metrics.dat`)
- **Modifications apportées suite aux retours utilisateur** :
  1. **Analyse de la cause de la lévitation / flottement en combat** :
     - Dans Pokémon Essentials, l'altitude du sprite d'un Pokémon adverse sur le socle de combat est déterminée par le paramètre `FrontSprite = X,Y` dans `PBS/pokemon_metrics.txt`.
     - Les Pokémon officiels du jeu possèdent un offset vertical `Y` descendant de `+18` à `+26` pour aligner leurs pieds avec le sol de l'arène.
     - Tous nos Pokémon personnalisés avaient été initialisés à `FrontSprite = 0,0`, ce qui laissait le vide transparent sous leurs pattes flotter au-dessus de leur ombre et du socle.
  2. **Ajustement précis de l'ancrage au sol de tous les 19 Pokémon de Freljord** :
     - **Petits Pokémon au sol (haute correction)** :
       - `CAMALYX` : `FrontSprite = 0,22` (pattes posées fermement au sol)
       - `ZIGGS` : `FrontSprite = 0,20`
       - `KINDRAME` : `FrontSprite = 0,12`
       - `FIDDLEFFROI` : `FrontSprite = 0,12`
       - `VEILLIRIS` : `FrontSprite = 0,10`
       - `VORAGATH` : `FrontSprite = 0,10`
     - **Pokémon moyens & grands au sol** :
       - `TYRAKOUP`, `GELOUPIOT`, `XENOSAI`, `VOLIBJORN` : `FrontSprite = 0,6`
       - `RUNOLITHE`, `RAGNARUNE` : `FrontSprite = 0,5`
       - `LYCANGLAS`, `FENRIMAS`, `THORAKLAK`, `AURELIASTRE`, `SYLVERN`, `OMBREVEX` : `FrontSprite = 0,4`
       - `ROCPHITE` : `FrontSprite = 0,2`
  3. **Recompilation automatique** :
     - Suppression du cache compilé binaire `Data/species_metrics.dat`. Au prochain lancement du jeu, Essentials recompilera automatiquement les métriques pour une prise en compte immédiate.
- **Comment tester** :
  - Lancer un combat contre un dresseur ou un Pokémon sauvage : observer les pieds du Pokémon adverse, ils sont désormais posés directement sur l'herbe/le socle sans aucun vide ni lévitation.

### `[AGY-048]` — 2026-10-20 — Suppression de l'écran noir de transition entre Route 1 et Havre-Givre (Connexion fluide native)
- **Auteur** : `Antigravity`
- **Catégorie** : Transition de Cartes / Map Connections (`Data/Map048.rxdata`, `Data/Map076.rxdata`, `PBS/map_connections.txt`)
- **Modifications apportées suite aux retours utilisateur** :
  1. **Identification de la cause de l'écran noir de 2 secondes** :
     - La Route 1 (`Map048`) et Havre-Givre (`Map076`) sont déjà reliées de façon native et sans coupure par le moteur Essentials via `PBS/map_connections.txt` (`48,N,0,76,S,0`).
     - Des événements de téléportation manuelle `Transfer` (avec fondu au noir `Fade to black` et temporisation) avaient été superposés à la frontière nord de la Route 1 $(X=19..21, Y=0)$ et sud de Havre-Givre $(X=19..21, Y=29)$, créant un conflit et un écran noir forcé de 2 secondes.
  2. **Suppression des téléportations en doublon** :
     - Retrait des événements `Transfer` 4, 5, 6 sur `Map048`.
     - Retrait des événements `Transfer` 1, 2, 3 sur `Map076`.
  3. **Résultat** :
     - Le passage entre la Route 1 et Havre-Givre est maintenant **100% instantané, fluide et sans aucun écran noir** (défilement continu de la caméra comme sur les routes officielles de Pokémon).
- **Comment tester** :
  - Marcher vers le nord sur la Route 1 et franchir la ligne $Y=0$ : la caméra défile directement sur Havre-Givre sans aucun temps de chargement ni écran noir.

### `[AGY-047]` — 2026-10-20 — Refonte Krag : Combat optionnel sur dialogue, cinématique de démontage pièce par pièce & garnison permanente
- **Auteur** : `Antigravity`
- **Catégorie** : Événements & Cinématique RPG Maker XP (`Data/Map048.rxdata`, `Data/System.rxdata`)
- **Modifications apportées suite aux retours utilisateur** :
  1. **Suppression de l'agression automatique de Krag au regard** :
     - Renommage de l'événement de `Trainer(3)` en `Krag`.
     - Déclencheur passé en touche d'action (`Trigger = 0`). Krag ne bouge plus et n'attaque plus tout seul.
  2. **Choix explicite du joueur pour lancer le combat** :
     - Krag interpelle le joueur amicalement : *"Halte voyageur ! Je monte la garde devant les Portes des Tours boréales. Es-tu prêt pour un duel d'entraînement ?"*.
     - Boîte de choix (`code 102`) :
       - **"Oui, je suis prêt !"** : Lance le combat contre Krag (`TrainerBattle.start(:HIKER, "Krag")`).
       - **"Pas encore"** : Krag répond poliment d'aller s'entraîner et de revenir quand on sera prêt.
  3. **Cinématique visuelle de démontage de la barrière de bois pièce par pièce** :
     - Une fois vaincu, Krag félicite le joueur et annonce qu'il va démonter la barricade.
     - Découpage du barrage en 3 sections animées indépendantes avec les interrupteurs `Switch 51` (gauche), `Switch 52` (milieu) et `Switch 53` (droite).
     - Krag se déplace physiquement devant chaque bout de bois avec bruitage et temporisation :
       - Il monte à $(20, 6)$ et **se tourne directement vers le haut (`turn_up`) pour faire face à la poutre du milieu** $\rightarrow$ bruit de démontage $\rightarrow$ la poutre centrale disparaît (`Switch 52 = ON`).
       - Il marche à gauche à $(19, 6)$ face au haut (`turn_up`) $\rightarrow$ bruit de démontage $\rightarrow$ la poutre de gauche disparaît (`Switch 51 = ON`).
       - Il marche à droite à $(21, 6)$ face au haut (`turn_up`) $\rightarrow$ bruit de démontage $\rightarrow$ la poutre de droite disparaît (`Switch 53 = ON`).
       - Validation finale de l'ouverture complète de la route (`Switch 50 = ON`).
  4. **Placement permanent de Krag devant la tour** :
     - Krag avance de 2 pas vers la droite pour se placer directement à $(23, 6)$ (une case plus haut qu'auparavant, juste au pied de la tour droite) et se tourne vers le bas.
     - Activation de l'interrupteur local `Self Switch A`.
     - Page 2 permanente : Krag reste posté là pour toujours avec un dialogue encourageant pour la suite de l'aventure vers Havre-Givre.
- **Comment tester** :
  - Sur la Route 1, aller devant les tours : Krag reste immobile et n'attaque pas automatiquement.
  - Lui parler : refuser d'abord pour vérifier qu'aucun combat ne se lance.
  - Lui reparler et choisir "Oui, je suis prêt !" : battre son équipe.
  - Observer la cinématique : Krag marche vers chaque poteau en bois et les retire un à un, puis s'installe définitivement à côté de la tour droite.

### `[AGY-046]` — 2026-10-20 — Connexion Village 1 -> Route 001 -> Havre-Givre & Boss Gardien Krag aux Portes des Tours
- **Auteur** : `Antigravity`
- **Catégorie** : Événements, Boss Dresseur & Transitions de cartes (`Data/Map022.rxdata`, `Data/Map048.rxdata`, `Data/Map076.rxdata`, `PBS/trainers.txt`)
- **Modifications apportées** :
  1. **Connexion fluide Village 1 (`Map022`) <-> Route 001 (`Map048`)** :
     - Événements de téléportation placés au sud du village $(X=26..29, Y=43)$ vers le début sud de la Route 1 à $(20, 28)$.
     - Téléportations retour au bas de la Route 1 $(X=19..21, Y=29)$ ramenant le joueur au village à $(27, 42)$.
  2. **Boss Gardien des Portes : Krag le Gardien (`Map048.rxdata` à $X=20, Y=7$)** :
     - Situé en sentinelle juste devant le mur en bois reliant les deux tours nordiques $(X=17..18$ et $X=22..23)$.
     - Interpelle le joueur au regard (`Trainer(3)`) : *"Halte ! Personne ne franchit les Portes des Tours sans prouver sa valeur au combat !"*.
     - Combat officiel contre **`[HIKER,Krag]`** avec son équipe de Freljord : **Rocphite** (Niveau 6) et **Tyrakoup** (Niveau 7).
  3. **Système de Barrière des Tours verrouillée / déverrouillée (Disparition visuelle)** :
     - Les tuiles du barrage de bois ont été retirées de la couche statique de la carte et converties en événements interactifs avec apparence de tuile aux coordonnées $(19..21, 5..6)$.
     - Utilisation de l'interrupteur libre **`Switch 50` ("Route 1 Gate Open")** au lieu du Switch 16 (qui était écrasé par le système météo horaire d'Essentials `isMorning?`).
     - **Tant que Krag n'est pas battu (`Switch 50 == OFF`)** : Le barrage de bois est visible à l'écran et bloque physiquement le passage.
     - **Dès que Krag est battu (`Switch 50 == ON`)** : Le barrage de bois **disparaît immédiatement de l'écran**, libérant totalement l'accès vers Havre-Givre !
  4. **Connexion Route 001 (`Map048`) <-> Havre-Givre (`Map076`)** :
     - Téléportations nord $(X=19..21, Y=0)$ menant directement à l'entrée sud de Havre-Givre à $(20, 28)$.
     - Téléportations retour au sud de Havre-Givre ramenant à la Route 1.
  5. **Objet à ramasser sur la Route 1** :
     - Ajout d'une Poké Ball d'objet (`Item`) contenant une **Super Potion** (`:SUPERPOTION`) à $(9, 16)$.
- **Comment tester** :
  - Sortir au sud du Village 1 : le joueur arrive sur la Route 1.
  - Traverser la Route 1 vers le nord jusqu'aux deux tours : Krag bloque le passage et lance le duel de boss.
  - Vaincre Krag : la barrière s'ouvre, permettant d'accéder au village d'étape Havre-Givre !

### `[AGY-045]` — 2026-10-20 — Ajustement Événements : Maman dans la maison, Starters officiels et Cinématique dynamique de Soren arrivant de gauche
- **Auteur** : `Antigravity`
- **Catégorie** : Événements RPG Maker XP (`Data/Map033.rxdata`, `Data/Map042.rxdata`, `Data/Map004.rxdata`, `Data/Map022.rxdata`)
- **Modifications apportées suite aux retours utilisateur** :
  1. **Maman intégrée dans la maison de départ (`Map033.rxdata`)** :
     - Ajout de l'événement Maman (`NPC 28`) à $(7, 4)$ au rez-de-chaussée de la maison du joueur.
     - Dialogue adapté à l'Épreuve de Freljord : elle encourage le joueur, lui remet le **Pokégéar** et les **Chaussures de Course** (`$player.has_pokegear = true`, `$player.has_running_shoes = true`), et soigne l'équipe après les combats (`Starting Over`).
  2. **Starters officiels de Freljord dans le Laboratoire (`Map042.rxdata` & `Map004.rxdata`)** :
     - Correction du sérialiseur binaire Ruby Marshal (`scratch/MarshalHelper.cs`) pour encoder directement les scripts modifiés.
     - Poké Ball 1 : **Geloupiot** (`:GELOUPIOT`, niveau 5, Glace).
     - Poké Ball 2 : **Tyrakoup** (`:TYRAKOUP`, niveau 5, Combat).
     - Poké Ball 3 : **Veilliris** (`:VEILLIRIS`, niveau 5, Psy).
  3. **Arrivée cinématique de Soren depuis la gauche à la sortie du labo (`Map022.rxdata`)** :
     - **Avant d'avoir son starter (`Variable 7 == 0`)** : Soren est **100% invisible** (graphique indépendant vide et opacité 0). Le parvis du laboratoire est parfaitement dégagé.
     - **Dès la sortie du laboratoire avec le starter (`Variable 7 >= 1`)** : Un événement de cinématique automatique se déclenche à la sortie $(37, 16)$ : Soren surgit en courant depuis la gauche du village, interpelle le joueur en criant *"Hé ! Attends-moi !"*, le joueur se tourne vers lui, Soren propose le premier combat de rivalité, puis s'écarte pour le laisser libre de partir vers la Route 1 !
- **Comment tester** :
  - Lancer le jeu, descendre dans la maison (`Map033`) : parler à Maman pour obtenir les chaussures et le Pokégéar.
  - Sortir dans `village 1` : Soren n'est PAS là devant le labo.
  - Entrer dans le labo : choisir Geloupiot, Tyrakoup ou Veilliris.
  - Ressortir du labo : Soren vous interpelle immédiatement pour le combat de rivaux !

### `[AGY-044]` — 2026-10-20 — Implémentation du Prologue & Scénario du Choix de Starter (Labo Map042 & Village 1 Map022)
- **Auteur** : `Antigravity`
- **Catégorie** : Événements In-Game & Scénarisation (`Data/Map042.rxdata`, `Data/Map022.rxdata`, `PBS/trainers.txt`)
- **Sauvegardes de sécurité créées** :
  - `Data/Map042_backup_before_starter_event.rxdata`
  - `Data/Map022_backup_before_starter_event.rxdata`
- **Contenu & Événements intégrés** :
  - **Scène du Choix dans le Laboratoire (`Map042.rxdata`)** :
    - *Guidage automatique du joueur* : Déplacement programmé du joueur montant 7 pas depuis l'entrée puis tournant à droite de 4 pas pour se positionner directement devant les 3 Poké Balls.
    - *Attribution des Starters de Freljord* :
      - Poké Ball Gauche $(9, 4)$ : **`GELOUPIOT`** (Niveau 5 — Type Glace).
      - Poké Ball Centre $(10, 4)$ : **`TYRAKOUP`** (Niveau 5 — Type Combat).
      - Poké Ball Droite $(11, 4)$ : **`VEILLIRIS`** (Niveau 5 — Type Psy).
    - *Dialogues d'ambiance d'Épreuve* : Le Professeur annonce l'âge de la Grande Épreuve et invite le joueur à choisir son partenaire officiel.
  - **Événements Extérieurs de `village 1` (`Map022.rxdata`)** :
    - *Sentinelle de sortie (Blocage vers Route 1 à $X=27..28, Y=42$)* : Tant que le starter n'est pas choisi (`Var 7 == 0`), le passage est bloqué et le garde repousse le joueur vers le village. Dès le starter obtenu, le passage s'ouvre librement.
    - *Rival Soren devant le laboratoire ($X=37, Y=18$)* :
      - Avant le choix : invite le joueur à entrer dans le labo.
      - Après le choix : interpelle le joueur et déclenche le **Premier Combat de rivalité** avec le starter opposé (niveau 5).
      - Post-combat : félicite le joueur et part en éclaireur sur la Route 1 vers Havre-Givre.
  - **Données Dresseurs (`PBS/trainers.txt`)** :
    - Définition de `[RIVAL1,Soren]` avec 3 variations selon le starter choisi par le joueur.
- **Comment tester en jeu** :
  - Lancer le jeu, sortir de la maison et aller parler à Soren devant le labo à $(37, 18)$.
  - Entrer dans le labo : observer le déplacement automatique vers la droite devant les 3 Poké Balls.
  - Choisir son starter (Geloupiot, Tyrakoup ou Veilliris).
  - Sortir du labo : affronter Soren, puis descendre librement vers la Route 1 au Sud !
- **Comment désactiver en cas de bug** :
  - `cp Data/Map042_backup_before_starter_event.rxdata Data/Map042.rxdata`
  - `cp Data/Map022_backup_before_starter_event.rxdata Data/Map022.rxdata`

---

### `[AGY-043]` — 2026-10-18 — Finalisation & Injection In-Game de l'Acte 1 (Havre-Givre Map 076 & Route 1 Map 048)
- **Auteur** : `Antigravity`
- **Catégorie** : Cartes / Level Design In-Game & Données (`Data/Map076.rxdata`, `Data/Map048.rxdata`, `Data/Tilesets.rxdata`, `Graphics/Tilesets/SubTileset_5_Routes_Freljord.png`, `PBS/map_connections.txt`, `PBS/encounters.txt`)
- **Sauvegardes de sécurité créées** :
  - `Data/Map076_backup_before_v13.rxdata`
  - `Data/Map048_backup_before_v13.rxdata`
  - `Graphics/Tilesets/SubTileset_5_Routes_Freljord_backup.png`
- **Éléments construits & intégrés directement dans le moteur de jeu** :
  - **Havre-Givre (`Map076.rxdata`, 40×30 cases, Tileset 25 `SubTileset_4_Villages_Freljord_Port`)** :
    - *7 Bâtiments natifs complets* : Toitures intégrales sans aucune coupure ($Y \ge 4$), Centre Pokémon (Refuge), Boutique Poké Mart, Grand Chalet, Cabane rustique, Long Lodge en rondins, Manoir du lac et Cabane de pêcheur.
    - *Réseau d'allées intelligent* : Grande Avenue centrale reliant la Route 1 au Sud ($X=19..21$) jusqu'au Col d'altitude au Nord, boulevard civique ouest, quartier artisanal et promenade du port à l'Est.
    - *Milieu aquatique & Port* : Canal gelé continu ($X=24..26$) débouchant sur la Grande Baie boréale ($X=22..36, Y=17..29$) surmontée d'un grand ponton d'amarrage en bois.
    - *Place centrale & Mobilier* : Spire de guet en glace boréale au centre de la place, lampadaires nordiques, bancs en bois chaud, statue de gardien, puits de neige et panneau de bienvenue.
    - *Bordures infranchissables* : Forêt dense de sapins boréaux de 3 cases de profondeur sur les 4 bordures (« 3 de 3 de largeur ») pour empêcher la caméra de voir le vide.
  - **Route 1 (`Map048.rxdata`, 40×30 cases, Tileset 27 `SubTileset_5_Routes_Freljord`)** :
    - *Level Design Pokémon authentique* : Avenue centrale bloquée vers le Nord par un rebord naturel de montagne sautable au Sud ($Y=20$), forçant le joueur à explorer vers l'Ouest.
    - *Progression & Clairières* : Clairière inférieure de hautes herbes enneigées boréales, sentier montant le long de la falaise Ouest, terrasse supérieure à embranchements.
    - *Bivouac d'éclaireur (Nord-Ouest)* : Tente en peau 100% propre de face (sans aucun artefact), marmite sur feu de camp animé, banc en rondins, lit de camp, provisions et tas de bois à la hache.
    - *Bosquet secret (Nord-Est)* : Autel de pierre gravé de runes, bannière clanique de Freljord, grand cairn mégalithique, cristaux de Vrai Givre géants et Pokéball dissimulée.
    - *Raccourci de retour* : Rebord sautable au Sud ($Y=20$) permettant de redescendre instantanément à l'entrée Sud.
    - *Raccordement territorial 1:1* : Alignement parfait de l'Avenue ($X=19..21$) avec la sortie Sud de Havre-Givre.
    - *Bordures infranchissables* : Périmètre forestier de 3 cases d'épaisseur sur les 4 côtés.
  - **Harmonisation Graphique & Collisions (`SubTileset_5_Routes_Freljord.png` & `Data/Tilesets.rxdata`)** :
    - Harmonisation des rangées 0-2 de SubTileset_5 avec le sol de neige pure, le pavage de pierre et les sapins de SubTileset_4 pour une continuité visuelle 100% sans raccord entre les deux cartes.
    - Configuration des tags de terrain : Tag 2 (Hautes Herbes boréales déclenchant les combats sauvages), Tag 1 (Rebord sautable vers le Sud), et flags de passage infranchissables sur les sapins, rochers et bâtiments.
  - **Métadonnées & Rencontres Sauvages** :
    - Connexion `48,N,0,76,S,0` ajoutée dans `PBS/map_connections.txt`.
    - Rencontres sauvages boréales configurées dans `PBS/encounters.txt` pour `[048]` (Geloupiot, Tyrakoup, Camalyx).
- **Comment tester en jeu** :
  - Ouvrir le projet dans **RPG Maker XP** : les cartes `048` et `076` s'affichent avec leur disposition finale.
  - Lancer le jeu en mode Debug : marcher de la Route 1 vers Havre-Givre via l'avenue $X=19..21$ pour constater la transition fluide et sans coupure, tester le saut du rebord vers le bas et déclencher des rencontres sauvages dans les hautes herbes boréales.
- **Comment désactiver en cas de bug** :
  - Restaurer les sauvegardes :
    `cp Data/Map048_backup_before_v13.rxdata Data/Map048.rxdata`
    `cp Data/Map076_backup_before_v13.rxdata Data/Map076.rxdata`
    `cp Graphics/Tilesets/SubTileset_5_Routes_Freljord_backup.png Graphics/Tilesets/SubTileset_5_Routes_Freljord.png`

---

### `[AGY-042]` — 2026-10-18 — Création du Village de Transition de Freljord « Havre-Givre » (Map076)
- **Auteur** : `Antigravity`
- **Catégorie** : Cartes / Level Design & Données (`Data/Map076.rxdata`, `Data/MapInfos.rxdata`, `PBS/map_metadata.txt`, `Data/Scripts/012_Overworld/011_Overworld_HavreGivre_Freljord.rb`)
- **Éléments construits & intégrés** :
  - **Level Design de Havre-Givre (`Map076.rxdata`, 45×30 cases)** :
    - *Place centrale & Allées* : Grand croisement en dalles de pierre boréale reliant la Route 1 (Sud), le Poste de traite (Ouest), le Pont sur le canal gelé (Est) et le Col d'altitude (Nord).
    - *Refuge de Montagne (Centre Pokémon)* : Grand chalet en bois chaud avec toiture enneigée et cheminée fumante au centre du village.
    - *Poste de Garde & Ravitaillement (Boutique Mart)* : Cottage d'approvisionnement avec tour de guet fortifiée en bois (2×4 cases) et tas de bois de chauffe.
    - *Secteur Résidentiel & Canal Gelé* : Deux chalets d'habitants séparés par une rivière gelée franchie par un pont en madriers de bois.
    - *Ambiance & Décorations* : Lampadaires nordiques à lanterne bleue, bonhomme de neige, bancs en bois, panneaux indicateurs et petits Poros curieux.
  - **Enregistrement RPG Maker XP & Métadonnées** :
    - Ajout de l'entrée `[076]` dans `PBS/map_metadata.txt` (`Name = Havre-Givre`, `Weather = Snow,25`).
    - Enregistrement de `Map 76` dans `Data/MapInfos.rxdata` comme enfant de la Route 1.
  - **Script d'Overworld (`011_Overworld_HavreGivre_Freljord.rb`)** :
    - Mécaniques d'auberge (`pbHealAtHavreGivreRefuge`), de boutique de survie (`pbShopHavreGivre`), dialogue d'éclaireur (`pbScoutHavreGivre`) et interactions Poro.
- **Comment tester en jeu** :
  - Ouvrir le projet dans **RPG Maker XP** (la carte `Havre-Givre [076]` apparaît désormais dans l'arborescence sous la Route 1).
  - Ou lancer le jeu en mode Debug et se téléporter sur la carte `076`.
- **Comment désactiver en cas de bug** :
  - Restaurer la sauvegarde : `cp Data/Map076_backup_user.rxdata Data/Map076.rxdata`

---

### `[AGY-041]` — 2026-10-18 — Construction & Aménagement de la Route 1 de Freljord (Map048)
- **Auteur** : `Antigravity`
- **Catégorie** : Cartes / Level Design & Données (`Data/Map048.rxdata`, `PBS/map_metadata.txt`, `PBS/encounters.txt`, `Graphics/Tilesets/SubTileset_5_Routes_Freljord.png`)
- **Éléments construits & intégrés** :
  - **Level Design de la Route 1** : Aménagement complet de la carte `Map048` ("route 1 ", 40×30 cases) en conservant les structures posées par le joueur (tente, bivouac, chemin, sapins).
  - **Nouveaux Sprites de Hautes Herbes Givrés & Rebords de Neige** : Ajout de tuiles de hautes herbes enneigées boréales et de rebords sautables dans le tileset officiel.
  - **Tracé & Aménagement** : Grandes clairières de hautes herbes givrées, camp d'étape avec barricades et bannières, cristaux de givre, rochers et rebords de retour.
  - **Rencontres sauvages configurées dans `encounters.txt`** : Rencontres de niveau 3 à 5 incluant *Geloupiot*, *Tyrakoup*, *Camalyx*, Roucool et Hoothoot nocturne.
  - **Métadonnées de la carte** : Enregistrement de `[048]` avec météo de neige boréale.
- **Comment tester en jeu** :
  - Lancer le jeu ou recharger le projet RPG Maker XP pour voir directement la carte `Map048` actualisée.
- **Comment désactiver en cas de bug** :
  - Restaurer la sauvegarde : `cp Data/Map048_backup_user.rxdata Data/Map048.rxdata`

---

### `[AGY-040]` — 2026-10-17 — Intégration du Méga-Tileset Officiel pour les Routes & Extérieurs de Freljord
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes / Tilesets (`Graphics/Tilesets/`)
- **Contenu & Découpe RPG Maker XP** :
  - **Calage strict 32×32 px** : Format normalisé de 256 px de large (8 colonnes) avec fond transparent sans aucun décalage de pixel.
  - **Intégration complète de la planche de sprites de routes Freljord** :
    - *Sols & Passages* : Neige fraîche, sentiers avec traces de pas, dalles de pierre froide, glace fissurée, lac gelé avec berges, escaliers de pierre taillée, ledges de saut Pokémon, et hautes herbes boréales de rencontres sauvages.
    - *Reliefs & Grottes* : Parois de falaises escarpées enneigées, grottes de glace et de roche, stalagmites géantes, stalactites, pics rocheux et cavités givrées.
    - *Végétation Boréale* : Grands sapins enneigés individuels, bosquets denses, cimes de forêts boréales pour bordures infranchissables, souches et buissons de baies enneigés.
    - *Campements & Bivouacs* : Grandes tentes nordiques en peaux, tentes trappeur moyennes, feux de camp actifs avec marmite fumante, feux de camp compacts, feux éteints, lits de camp, duvets, haches, billots, tas de bois et tonneaux de provisions.
    - *Lore Freljord & Défenses* : Statues colossales du bélier d'Ornn, tours de guet en bois de Freljord (2x4 tiles), menhirs de pierre avec runes cyan éclatantes, cristaux de Vrai Givre géants, bannières de clan de Freljord, râteliers d'armes (épées, haches, boucliers), barricades et chevaux de frise.
    - *Ponts & Mobilier* : Ponts suspendus en corde (horizontaux et verticaux), lanternes boréales, bornes de sentier, panneaux indicateurs enneigés, clôtures de corde et murets de pierre.
    - *Vie Sauvage* : Mini Poros sauvages, poros qui roulent, poro surpris, bonhomme de neige poro et empreintes de pattes dans la neige.
- **Fichiers modifiés** :
  - `Graphics/Tilesets/SubTileset_5_Routes_Freljord.png`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Ouvrir l'éditeur RPG Maker XP, associer `SubTileset_5_Routes_Freljord` à un tileset ou à une carte extérieure pour peindre les routes avec toute la panoplie d'éléments de Freljord calés au carreau près.
- **Comment désactiver en cas de bug** :
  - `git checkout HEAD~1 -- "Graphics/Tilesets/SubTileset_5_Routes_Freljord.png"`

---

### `[AGY-039]` — 2026-10-16 — Nettoyage Intégral du Halo et Cadrage au Sol de Veilliris de Dos
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes / Sprites Combat de Dos (`Graphics/Pokemon/Back/` & `Back shiny/`)
- **Problème résolu & Exigence Canonique Gen 5** :
  - **Suppression du voile/halo flou et des impuretés** : Élimination complète de l'aura grisâtre opaque qui entourait la stèle, des résidus sur le flanc gauche et des bruits de pixels autour de la traînée spectrale pour une netteté pixel-art 100% pure sur fond transparent.
  - **Cadrage de combat Gen 5 au sol (Coupe Moyenne Équilibrée)** : Le sprite n'est plus flottant au milieu du cadre. La base de la stèle est coupée naturellement et posée sur la ligne d'assise du combat (`Y = 159`), harmonisée avec les autres dos officiels et custom (Camalyx, Runolithe, Sylvern).
  - **Déclinaison Shiny synchronisée** (`Back shiny/VEILLIRIS.png`) : Même traitement appliqué avec élimination du voile sombre et découpe nette de la base au sol.
- **Fichiers modifiés** :
  - `Graphics/Pokemon/Back/VEILLIRIS.png`
  - `Graphics/Pokemon/Back shiny/VEILLIRIS.png`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Lancer un combat avec Veilliris en tête d'équipe pour admirer son sprite de dos net, sans halo et posé au premier plan.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-038]` — 2026-10-16 — Intégration du Vrai Dos de Combat de Sylvern (Vue 180° / Légère Orientation 3/4 Droite et Nettoyage de Feuillage)
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes / Sprites Combat de Dos (`Graphics/Pokemon/Back/` & `Back shiny/`)
- **Problème résolu & Exigence Canonique Gen 5** :
  - **Véritable vue arrière 180°** : Suppression de l'effet "visage effacé" antérieur. Sylvern présente fidèlement l'arrière de son crâne d'écorce sculptée, sa collerette feuillue enveloppante et ses ramures en perspective arrière.
  - **Orientation de combat naturelle** : Légère rotation d'environ 10° vers la droite (direction du Pokémon adverse en haut à droite de l'arène de combat DS), avec la fleur de tournesol fidèlement positionnée sur sa corne gauche (côté gauche de l'écran vu de dos).
  - **Nettoyage pixel-art** : Élimination de la feuille parasite détachée sur le flanc gauche pour une silhouette parfaitement nette et fluide.
  - **Cadrage Gen 5 officiel** : Format strict 160×160 px, coupe naturelle au niveau du bas du torse posée à la ligne d'assise (`Y = 159`).
  - **Déclinaison Shiny synchronisée** (`Back shiny/SYLVERN.png`) : Écorce de bouleau mystique clair aux reflets lilas, collerette florale sakura rose et tournesol bleu cyan éclatant.
- **Fichiers modifiés** :
  - `Graphics/Pokemon/Back/SYLVERN.png`
  - `Graphics/Pokemon/Back shiny/SYLVERN.png`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Lancer un combat avec Sylvern en tête d'équipe pour admirer son nouveau dos de combat orienté vers l'adversaire.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-037]` — 2026-10-16 — Correction de la Posture de Combat et de l'Orientation du Dos de Fiddleffroi
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes / Sprites Combat de Dos (`Graphics/Pokemon/Back/` & `Back shiny/`)
- **Problème résolu & Exigence Canonique Gen 5** :
  - **Correction anatomique et orientation fidèle** : Sur l'ancien sprite, la posture était raide, flottante et les membres étaient inversés. La nouvelle vue de combat à 180° replace fidèlement la **faux dans la main droite levée** (à droite de l'écran, prête à frapper) et l'**aile démoniaque de corbeau sur l'épaule gauche** (à gauche de l'écran).
  - **Posture 3/4 vers l'adversaire** : Tête en sac de jute inclinée vers le haut-droite fixant le Pokémon adverse, chapeau pointu vu de dos avec ses clochettes dorées, et cape déchirée laissant voir les braises incandescentes du thorax.
  - **Cadrage Gen 5** : Posé au sol (`Y = 159`) coupé à mi-corps pour une immersion de combat optimale.
  - **Déclinaison Shiny synchronisée** (`Back shiny/FIDDLEFFROI.png`) : Chapeau teal mystique, tête ardoise spectrale et ailes aux plumes cyan étincelantes.
- **Fichiers modifiés** :
  - `Graphics/Pokemon/Back/FIDDLEFFROI.png`
  - `Graphics/Pokemon/Back shiny/FIDDLEFFROI.png`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Lancer un combat en mode Debug avec Fiddleffroi en tête d'équipe pour admirer sa posture de combat avec la faux levée prête à frapper.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-036]` — 2026-10-16 — Validation et Intégration du Vrai Dos de Combat de Runolithe (Vue 180° Orientée vers l'Adversaire et Coupée au Premier Plan)
- **Auteur** : `Antigravity`
- **Catégorie** : Graphismes / Sprites Combat de Dos (`Graphics/Pokemon/Back/` & `Back shiny/`)
- **Problème résolu & Exigence Canonique Gen 5** :
  - Intégration d'une **véritable vue de dos à 180°** sans visage (nuque, colonne de lumière runique, anneau et mégalithes vus de derrière), **orientée vers le haut-droite (face à l'adversaire)** exactement comme le modèle de référence **Camalyx**.
  - Cadrage immersif Gen 5 : **coupé net à mi-corps sous l'anneau** et posé au ras du bas de l'écran (`Y = 159`).
  - Déclinaison chromatique assortie (`Back shiny/RUNOLITHE.png`) avec l'esprit de flamme dorée et les mégalithes d'ambre.
- **Fichiers modifiés** :
  - `Graphics/Pokemon/Back/RUNOLITHE.png`
  - `Graphics/Pokemon/Back shiny/RUNOLITHE.png`
  - `CHANGELOG.md`
- **Comment tester en jeu** :
  - Lancer un combat en Debug (`F9`) avec Runolithe pour observer sa posture de dos tournée vers l'adversaire et son cadrage mi-corps.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

### `[AGY-033]` — 2026-10-16 — Refonte Visuelle Complète des Évolutions de Veilliris (Direction A : Gardien Spectral Runique)
- **Auteur** : `Antigravity`
- **Catégorie** : Sprites Pokémon Combat 5G (`Graphics/Pokemon/`)
- **Fichiers modifiés / remplacés** :
  - **Runolithe (`[RUNOLITHE]`, Stade 2 — Psy / Sol)** :
    - Remplacement de l'ancien modèle de roche compacte par le design **Direction A** : Esprit spectral cyan élancé et gracieux émergeant d'un cercle de mégalithes, avec anneau d'orbes/runes orbitales et gantelets de pierre taillée.
    - `Graphics/Pokemon/Front/RUNOLITHE.png` & `Front shiny/RUNOLITHE.png` (`160×160 px`).
    - `Graphics/Pokemon/Back/RUNOLITHE.png` & `Back shiny/RUNOLITHE.png` (`160×160 px`, perspective dorsale 180°).
    - `Graphics/Pokemon/Icons/RUNOLITHE.png` & `Icons shiny/RUNOLITHE.png` (`128×64 px`).
    - `Graphics/Pokemon/Footprints/RUNOLITHE.png` (`16×16 px`).
  - **Ragnarune (`[RAGNARUNE]`, Stade 3 — Psy / Sol)** :
    - Remplacement du golem massif par le design **Direction A** : Titan céleste/spectral de Freljord aux immenses ailes de flammes cyan, plastron d'obsidienne gravée, couronne royale et gantelets mégalithiques flottants crépitants d'aura magique.
    - `Graphics/Pokemon/Front/RAGNARUNE.png` & `Front shiny/RAGNARUNE.png` (`160×160 px`).
    - `Graphics/Pokemon/Back/RAGNARUNE.png` & `Back shiny/RAGNARUNE.png` (`160×160 px`, perspective dorsale 180°).
    - `Graphics/Pokemon/Icons/RAGNARUNE.png` & `Icons shiny/RAGNARUNE.png` (`128×64 px`).
    - `Graphics/Pokemon/Footprints/RAGNARUNE.png` (`16×16 px`).
- **Aperçu de validation (Dossier d'artefacts)** :
  - `apercu_final_direction_a_integree.png` (Tableau 12 sprites de la lignée complète Veilliris -> Runolithe -> Ragnarune sur damier transparent).
- **Comment tester en jeu** :
  - Lancer en Debug (`F9`) -> Menu Pokémon -> Donner Pokémon (`RUNOLITHE`, `RAGNARUNE`) pour observer les nouveaux sprites de face, de dos et shiny en combat.
- **Comment désactiver en cas de bug** :
  - `git revert HEAD`

---

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

#===============================================================================
# Havre-Givre — Village Intermédiaire & Refuge de Montagne (Map 76)
#===============================================================================
# Fichier : Data/Scripts/012_Overworld/011_Overworld_HavreGivre_Freljord.rb
# Auteur  : Antigravity [AGY-042 / AGY-100]
#
# Ce script gère les interactions et la vie du village intermédiaire Havre-Givre :
# 1. Soin complet de l'équipe au Refuge de Montagne (Centre Pokémon / Chalet)
# 2. Marché boréal & Ravitaillement (Objets de soin + Composants d'artisanat LoL)
# 3. Forge d'Artisanat de Havre-Givré (Enclume LoL - Combinaisons d'objets)
# 4. Éclaireur de Freljord surveillant la passe vers la Grande Ville de l'Épreuve
# 5. Progression des Quêtes MQS (Étape 1 validée, début de l'Étape 2)
# 6. Poros interactifs
#===============================================================================

# Soin de montagne au Refuge de Havre-Givre
def pbHealAtHavreGivreRefuge
  pbMessage(_INTL("Aubergiste : Bienvenue au Refuge de Havre-Givre, jeune voyageur !\\1"))
  pbMessage(_INTL("La tempête souffle fort sur la passe de la montagne. Vos Pokémon ont l'air frigorifiés."))
  if pbConfirmMessage(_INTL("Voulez-vous réchauffer et soigner votre équipe près de l'âtre ?"))
    pbMessage(_INTL("Reposez-vous un instant au coin du feu..."))
    pbFadeOutIn {
      $player.party.each { |pkmn| pkmn.heal }
      pbSEPlay("Pkmn exp full")
      Graphics.frame_count += 40
    }
    pbMessage(_INTL("Vos Pokémon sont en pleine forme et regorgent d'énergie !\\1"))
    pbMessage(_INTL("Prenez garde aux vents glaciaux en montant vers les Cimes."))
    # Avancement quête 2 si active
    if defined?(advanceQuestToStage) && defined?(getCurrentStage)
      advanceQuestToStage(:Quest2, 2) if getCurrentStage(:Quest2) == 1
    end
  else
    pbMessage(_INTL("N'hésitez pas à repasser avant de vous aventurer plus haut dans le col !"))
  end
end

# Marché boréal de Havre-Givre (Consommables & Composants LoL)
def pbMarketHavreGivre
  pbMessage(_INTL("Marchand du Nord : Salutations ! Sur nos étals, vous trouverez des remèdes contre le froid et des matériaux forgés."))
  items = [
    :POTION,
    :SUPERPOTION,
    :ANTIDOTE,
    :ICEHEAL,
    :POKEBALL,
    :GREATBALL,
    :REPEL,
    :ESCAPEROPE,
    :LONGSWORD,
    :CLOTHARMOR,
    :RUBYCRYSTAL
  ]
  if defined?(pbPokemonMart)
    pbPokemonMart(items, speech: _INTL("Que voulez-vous acquérir pour votre périple ?"))
  else
    pbCommerce(items)
  end
  pbMessage(_INTL("Revenez quand vous aurez besoin de vous ravitailler !"))
end

alias pbShopHavreGivre pbMarketHavreGivre

# Forge d'Artisanat de Havre-Givre (Enclume LoL)
def pbForgeHavreGivre
  pbMessage(_INTL("Forgeron Boréal : Marteau et enclume ! Ici, nous transformons les composants de combat en armes de légende.\\1"))
  pbMessage(_INTL("Deux Épées Longues peuvent devenir un B.F. Glaive, et deux Cottes de Tissu une Cotte de Mailles solide."))
  
  # Déblocage automatique des recettes de base
  if defined?(pbUnlockRecipe)
    pbUnlockRecipe(:BFSword)
    pbUnlockRecipe(:ChainVest)
    pbUnlockRecipe(:InfinityEdge)
    pbUnlockRecipe(:Thornmail)
  end

  if pbConfirmMessage(_INTL("Voulez-vous utiliser la Forge de Havre-Givre ?"))
    if defined?(pbOpenForge)
      pbOpenForge
    elsif defined?(pbItemCrafter) && defined?(pbGetRecipes)
      pbItemCrafter(pbGetRecipes)
    else
      pbMessage(_INTL("La forge est en cours de préparation..."))
    end
    # Progression quête
    if defined?(advanceQuestToStage) && defined?(getCurrentStage)
      advanceQuestToStage(:Quest2, 3) if getCurrentStage(:Quest2) == 2
    end
  else
    pbMessage(_INTL("Revenez frapper l'enclume dès que vous aurez réuni les composants nécessaires !"))
  end
end

# Dialogue de l'Éclaireur de montagne (Garde la passe vers la Grande Ville)
def pbScoutHavreGivre
  # Validation de l'étape 1 et déclenchement de la quête 2 si non fait
  if defined?(completeQuest) && defined?(activateQuest) && defined?(getCurrentStage)
    if getCurrentStage(:Quest1) == 2 || getCurrentStage(:Quest1) == 3
      completeQuest(:Quest1)
      activateQuest(:Quest2)
    end
  end

  pbMessage(_INTL("Éclaireur Boréal : Halte, voyageur ! Vous vous trouvez à Havre-Givre, le village intermédiaire de Freljord.\\1"))
  pbMessage(_INTL("Plus au Nord, par-delà le col enneigé, s'étend la majestueuse Grande Ville de Freljord.\\1"))
  pbMessage(_INTL("C'est là-bas que les champions et dresseurs d'élite se rassemblent pour passer la Grande Épreuve tellurique ancestrale !\\1"))
  pbMessage(_INTL("Avant de vous y aventurer, reposez-vous au refuge et renforcez votre équipement à la forge."))
end

# Interaction avec les Poros du village
def pbPoroHavreGivre
  pbPlayCry(:EEVEE) rescue nil
  pbMessage(_INTL("Un adorable Poro pelucheux sautille joyeusement dans la neige !"))
  pbMessage(_INTL("Il frotte son museau tiède contre vos bottes. *Mewww !*"))
end

# Déclencheur automatique à l'entrée de Havre-Givre (Arrivée depuis la Route 1)
def pbOnEnterHavreGivre
  if defined?(advanceQuestToStage) && defined?(getCurrentStage)
    if getCurrentStage(:Quest1) == 2
      advanceQuestToStage(:Quest1, 3)
      pbMessage(_INTL("Vous avez atteint Havre-Givre, le village intermédiaire de la montagne !"))
    end
  end
end

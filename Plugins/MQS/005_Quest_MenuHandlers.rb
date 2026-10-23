#===============================================================================
# Modern Quest System (MQS) — Quêtes Officielles de l'Acte 1 (Freljord & Noxus)
#===============================================================================

# Si true : le bouton Quêtes apparaît en permanence dans le Menu Pause.
# Si false : le bouton n'apparaît qu'une fois au moins une quête activée.
ALWAYS_SHOW_QUEST_MENU = true

# Sécurisation nil-safety de la carte d'origine dans l'interface de détails
class QuestList_Scene
  alias mqs_drawOtherInfo drawOtherInfo unless method_defined?(:mqs_drawOtherInfo)
  def drawOtherInfo(quest)
    quest.location ||= "???"
    mqs_drawOtherInfo(quest)
  end
end

#===============================================================================
# Intégration au Menu Pause (Échap / Touche X)
#===============================================================================
MenuHandlers.add(:pause_menu, :quests, {
  "name"      => _INTL("Quêtes"),
  "order"     => 45,
  "condition" => proc { next (defined?(ALWAYS_SHOW_QUEST_MENU) && ALWAYS_SHOW_QUEST_MENU) || hasAnyQuests? },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      pbViewQuests
      menu.pbRefresh
    end
    next false
  }
})

#===============================================================================
# Registre des Quêtes de l'Histoire & Quêtes Secondaires (League of Legends)
#===============================================================================
module QuestModule

  # ---------------------------------------------------------------------------
  # 1. Quête Principale — Prologue : L'Éveil du Freljord
  # ---------------------------------------------------------------------------
  Quest_Prologue = {
    :ID => "1",
    :Name => "L'Éveil du Freljord",
    :QuestGiver => "Anivia",
    :Stage1 => "Choisissez votre premier compagnon auprès du Sanctuaire des Glaces.",
    :Stage2 => "Assistez aux manigances du Dirigeable noxien et protégez l'Œuf d'Anivia.",
    :Stage3 => "Descendez le col de montagne et frayez-vous un chemin vers la Route 1.",
    :Location1 => "Sanctuaire des Glaces",
    :Location2 => "Sommet d'Anivia",
    :Location3 => "Sentier Boréal",
    :QuestDescription => "Les cieux de Freljord s'assombrissent. Un navire volant noxien menace l'antique Sanctuaire. Choisissez votre premier Pokémon et faites vos premiers pas.",
    :RewardString => "Bénédiction d'Anivia & Sac d'Aventurier"
  }
  # Rétro-compatibilité
  QuestFreljord1 = Quest_Prologue

  # ---------------------------------------------------------------------------
  # 2. Quête Principale — Route 1 : La Traversée du Blizzard
  # ---------------------------------------------------------------------------
  Quest_Route1 = {
    :ID => "2",
    :Name => "La Traversée du Blizzard",
    :QuestGiver => "Garde de Freljord",
    :Stage1 => "Traversez les hautes herbes enneigées de la Route 1.",
    :Stage2 => "Battez les soldats éclaireurs noxiens en déroute près du campement.",
    :Stage3 => "Atteignez les portes fortifiées du village de Havre-Givre.",
    :Location1 => "Route 1 de Freljord",
    :Location2 => "Campement Boréal",
    :Location3 => "Havre-Givre",
    :QuestDescription => "La tempête souffle fort sur la passe de la montagne. Frayez-vous un chemin à travers la faune hostile et les éclaireurs noxiens jusqu'au refuge.",
    :RewardString => "5 Poké Balls & 3 Potions"
  }

  # ---------------------------------------------------------------------------
  # 3. Quête Principale — Havre-Givre : Le Dernier Rempart
  # ---------------------------------------------------------------------------
  Quest_Refuge = {
    :ID => "3",
    :Name => "Le Dernier Rempart",
    :QuestGiver => "Aubergiste du Refuge",
    :Stage1 => "Réchauffez votre équipe de Pokémon près de l'âtre du Refuge.",
    :Stage2 => "Ravitaillez-vous en remèdes et vivres au Poste de Traite.",
    :Stage3 => "Consultez l'Éclaireur de la Griffe au sujet de la Caverne sacrée.",
    :Location1 => "Refuge de Havre-Givre",
    :Location2 => "Poste de Traite",
    :Location3 => "Pont Nord de Havre-Givre",
    :QuestDescription => "Havre-Givre est le dernier village avant les hauteurs interdites. Préparez minutieusement votre équipe avant d'affronter les cavernes runiques.",
    :RewardString => "Passe de Montagne & 3 Guérisons"
  }

  # ---------------------------------------------------------------------------
  # 4. Quête Principale — Caverne sacrée : L'Épreuve des Quatre Démi-Dieux
  # ---------------------------------------------------------------------------
  Quest_Epreuve = {
    :ID => "4",
    :Name => "L'Épreuve des Quatre Démi-Dieux",
    :QuestGiver => "Stèle Runique des Veilleurs",
    :Stage1 => "Éveillez la Rune du Tonnerre auprès de la Statue de Volibear.",
    :Stage2 => "Éveillez la Rune de la Chasse auprès de la Statue du Loup des Neiges.",
    :Stage3 => "Éveillez la Rune de la Forge auprès de la Statue d'Ornn.",
    :Stage4 => "Éveillez la Rune de Glace Pure auprès de la Statue d'Anivia.",
    :Stage5 => "Traversez le Pont de Glace et triomphez du Gardien Ancestral.",
    :Location1 => "Caverne de l'Épreuve - Est",
    :Location2 => "Caverne de l'Épreuve - Sud",
    :Location3 => "Caverne de l'Épreuve - Ouest",
    :Location4 => "Caverne de l'Épreuve - Nord",
    :Location5 => "Grande Rotonde de Glace",
    :QuestDescription => "La Caverne ancestrale met à l'épreuve quiconque ose s'aventurer vers les Cimes. Harmonisez les quatre statues runiques pour révéler le chemin sacré.",
    :RewardString => "Cristal de Vraie Glace & Accès aux Cimes"
  }

  # ---------------------------------------------------------------------------
  # 5. Quête Principale — Crash du Dirigeable : Le Siège de l'Épave
  # ---------------------------------------------------------------------------
  Quest_CrashNoxus = {
    :ID => "5",
    :Name => "Le Siège de l'Épave",
    :QuestGiver => "Ashe",
    :Stage1 => "Localisez la carcasse fumante du Dirigeable noxien dans les crevasses.",
    :Stage2 => "Infiltrez les décombres et déjouez la garde de l'infanterie noxienne.",
    :Stage3 => "Affrontez le Commandant Kael en duel de dresseur et reprenez l'Œuf d'Anivia.",
    :Location1 => "Crevasse du Crash",
    :Location2 => "Épave du Dirigeable",
    :Location3 => "Pont Supérieur du Dirigeable",
    :QuestDescription => "Abattu par le blizzard et la foudre, le navire noxien s'est crashé. Les soldats rescapés tentent de fortifier leur position avec l'Œuf volé. Il faut frapper vite !",
    :RewardString => "Œuf d'Anivia & Armure Noxienne"
  }

  # ---------------------------------------------------------------------------
  # 6. Quête Secondaire : Un Poro dans la Tourmente
  # ---------------------------------------------------------------------------
  Quest_PoroPerdu = {
    :ID => "11",
    :Name => "Un Poro dans la Tourmente",
    :QuestGiver => "Enfant Frigorifié",
    :Stage1 => "Retrouvez la piste du petit Poro enfui sur la Route 1.",
    :Stage2 => "Attirez le Poro avec une friandise ou des paroles douces sous les sapins.",
    :Stage3 => "Ramenez le Poro sain et sauf à son maître à Havre-Givre.",
    :Location1 => "Route 1 - Bosquet",
    :Location2 => "Sous le Grand Sapin",
    :Location3 => "Havre-Givre",
    :QuestDescription => "Un enfant de Havre-Givre pleure la disparition de sa boule de poils préférée. Le pauvre Poro ne survivra pas longtemps seul dans le blizzard.",
    :RewardString => "3 Poro-Snax & Clochette Zen"
  }

  # ---------------------------------------------------------------------------
  # 7. Quête Secondaire : Le Bestiaire du Pergélisol
  # ---------------------------------------------------------------------------
  Quest_ChasseursGivre = {
    :ID => "12",
    :Name => "Le Bestiaire du Pergélisol",
    :QuestGiver => "Trappeur Boréal",
    :Stage1 => "Capturez un Blizzapin (Glace/Plante) dans les herbes des neiges.",
    :Stage2 => "Capturez un Givracorn (Roche/Glace) dans les parois rocheuses.",
    :Stage3 => "Capturez un Cryocrust (Glace/Insecte) au fond des cavernes.",
    :Stage4 => "Montrez votre trio boréal au Trappeur de Havre-Givre.",
    :Location1 => "Hautes herbes de Freljord",
    :Location2 => "Falaises du Col",
    :Location3 => "Grotte de Glace",
    :Location4 => "Refuge de Havre-Givre",
    :QuestDescription => "Le Trappeur étudie l'adaptation unique des créatures sauvages au froid extrême. Aidez-le à compléter ses recherches sur les trois espèces endémiques.",
    :RewardString => "Glace Éternelle & 5 Super Balls"
  }

  # ---------------------------------------------------------------------------
  # 8. Quête Secondaire : Les Vestiges de la Forge d'Ornn
  # ---------------------------------------------------------------------------
  Quest_BraisesOrnn = {
    :ID => "13",
    :Name => "Les Vestiges de la Forge",
    :QuestGiver => "Artisan Nomade",
    :Stage1 => "Récupérez 3 Pierres Thermiques enfouies près des failles volcaniques.",
    :Stage2 => "Rapportez les pierres au brasero runique du village.",
    :Stage3 => "Frappez le métal incandescent sous la bénédiction d'Ornn.",
    :Location1 => "Fissures Chaudes",
    :Location2 => "Atelier de Havre-Givre",
    :Location3 => "Enclume Runique",
    :QuestDescription => "Sous la glace millénaire sommeillent encore les braises du Démi-Dieu Forgeron. Ravivez l'enclume pour forger un équipement de légende.",
    :RewardString => "Cotte Épineuse (Objet LoL d'Armure)"
  }

  # ---------------------------------------------------------------------------
  # 9. Quête Secondaire : L'Artificier Déjanté (Ziggs)
  # ---------------------------------------------------------------------------
  Quest_ZiggsExplosif = {
    :ID => "14",
    :Name => "L'Artificier Déjanté",
    :QuestGiver => "Ziggs",
    :Stage1 => "Enquêtez sur les détonations suspectes qui font trembler la montagne.",
    :Stage2 => "Affrontez le petit Yordle artificier et survivez à ses bombes minérales.",
    :Stage3 => "Aidez Ziggs à déblayer les éboulis bloquant le col Nord.",
    :Location1 => "Canyon Ébouleur",
    :Location2 => "Atelier de Bombes",
    :Location3 => "Passage Bloqué",
    :QuestDescription => "Ziggs trouve que le Freljord est beaucoup trop silencieux ! Il a décidé d'égayer le paysage avec quelques explosions de haute précision.",
    :RewardString => "Orbe Pyrotechnique & Ziggs rejoint l'équipe !"
  }

end

#===============================================================================
# Hooks Automatiques dans les Événements du Monde
#===============================================================================

# Progression automatique lors des déplacements entre les cartes clés
EventHandlers.add(:on_enter_map, :mqs_freljord_map_progression,
  proc { |_old_map_id|
    next if !$game_map || !$PokemonGlobal

    case $game_map.map_id
    # Map 48 : Route 1 de Freljord (sortie du Sanctuaire)
    when 48
      if getCurrentStage(:Quest_Prologue) == 2
        advanceQuestToStage(:Quest_Prologue, 3) rescue nil
      end
      if !getActiveQuests.include?(:Quest_Route1) && !getCompletedQuests.include?(:Quest_Route1)
        activateQuest(:Quest_Route1, colorQuest("cyan"), true) rescue nil
      end

    # Map 76 : Havre-Givre (arrivée au village refuge)
    when 76
      if getActiveQuests.include?(:Quest_Prologue)
        completeQuest(:Quest_Prologue) rescue nil
      end
      if getActiveQuests.include?(:Quest_Route1)
        advanceQuestToStage(:Quest_Route1, 3) rescue nil
        completeQuest(:Quest_Route1) rescue nil
      end
      if !getActiveQuests.include?(:Quest_Refuge) && !getCompletedQuests.include?(:Quest_Refuge)
        activateQuest(:Quest_Refuge, colorQuest("yellow"), true) rescue nil
      end

    # Map 78 : Caverne de l'Épreuve - Salle 1 (Entrée dans les épreuves)
    when 78
      if getActiveQuests.include?(:Quest_Refuge)
        completeQuest(:Quest_Refuge) rescue nil
      end
      if !getActiveQuests.include?(:Quest_Epreuve) && !getCompletedQuests.include?(:Quest_Epreuve)
        activateQuest(:Quest_Epreuve, colorQuest("purple"), true) rescue nil
      end
    end
  }
)

# Progression automatique lors du Soin au Refuge de Havre-Givre
if defined?(pbHealAtHavreGivreRefuge)
  alias mqs_pbHealAtHavreGivreRefuge pbHealAtHavreGivreRefuge unless defined?(mqs_pbHealAtHavreGivreRefuge)
  def pbHealAtHavreGivreRefuge
    mqs_pbHealAtHavreGivreRefuge
    if getActiveQuests.include?(:Quest_Refuge) && getCurrentStage(:Quest_Refuge) == 1
      advanceQuestToStage(:Quest_Refuge, 2) rescue nil
    end
  end
end

# Progression automatique lors des achats au Poste de Traite
if defined?(pbShopHavreGivre)
  alias mqs_pbShopHavreGivre pbShopHavreGivre unless defined?(mqs_pbShopHavreGivre)
  def pbShopHavreGivre
    mqs_pbShopHavreGivre
    if getActiveQuests.include?(:Quest_Refuge) && getCurrentStage(:Quest_Refuge) == 2
      advanceQuestToStage(:Quest_Refuge, 3) rescue nil
    end
  end
end

# Progression automatique lors du dialogue avec l'Éclaireur de la Griffe
if defined?(pbScoutHavreGivre)
  alias mqs_pbScoutHavreGivre pbScoutHavreGivre unless defined?(mqs_pbScoutHavreGivre)
  def pbScoutHavreGivre
    mqs_pbScoutHavreGivre
    if getActiveQuests.include?(:Quest_Refuge)
      completeQuest(:Quest_Refuge) rescue nil
    end
    if !getActiveQuests.include?(:Quest_Epreuve) && !getCompletedQuests.include?(:Quest_Epreuve)
      activateQuest(:Quest_Epreuve, colorQuest("purple"), true) rescue nil
    end
  end
end

# Progression automatique lors de l'activation des Statues Démi-Dieux
if defined?(pbActivateStatue)
  alias mqs_pbActivateStatue pbActivateStatue unless defined?(mqs_pbActivateStatue)
  def pbActivateStatue(statue_id)
    ret = mqs_pbActivateStatue(statue_id)
    if getActiveQuests.include?(:Quest_Epreuve)
      case statue_id
      when 1 then advanceQuestToStage(:Quest_Epreuve, 2) rescue nil
      when 2 then advanceQuestToStage(:Quest_Epreuve, 3) rescue nil
      when 3 then advanceQuestToStage(:Quest_Epreuve, 4) rescue nil
      when 4 then advanceQuestToStage(:Quest_Epreuve, 5) rescue nil
      end
    end
    return ret
  end
end

# Activation du Prologue lors du choix du Starter
if defined?(pbFreljordStarterSelection)
  alias mqs_pbFreljordStarterSelection pbFreljordStarterSelection unless defined?(mqs_pbFreljordStarterSelection)
  def pbFreljordStarterSelection
    ret = mqs_pbFreljordStarterSelection
    if !getActiveQuests.include?(:Quest_Prologue) && !getCompletedQuests.include?(:Quest_Prologue)
      activateQuest(:Quest_Prologue, colorQuest("blue"), true) rescue nil
      advanceQuestToStage(:Quest_Prologue, 2) rescue nil
    end
    return ret
  end
end

# Activation automatique si DiegoWTsStarterSelection est appelé directement
if defined?(DiegoWTsStarterSelection)
  class DiegoWTsStarterSelection
    alias mqs_closeScene pbCloseScene unless method_defined?(:mqs_closeScene)
    def pbCloseScene
      mqs_closeScene
      if defined?(activateQuest) && defined?(QuestModule) && defined?(QuestModule::Quest_Prologue)
        if !getActiveQuests.include?(:Quest_Prologue) && !getCompletedQuests.include?(:Quest_Prologue)
          activateQuest(:Quest_Prologue, colorQuest("blue"), true) rescue nil
          advanceQuestToStage(:Quest_Prologue, 2) rescue nil
        end
      end
    end
  end
end

#===============================================================================
# Modern Quest System (MQS) — Intégration Moteur & Quêtes Freljord
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
# Données de Quête — Acte 1 : Freljord
#===============================================================================
module QuestModule
  QuestFreljord1 = {
    :ID => "101",
    :Name => "L'Éveil du Freljord",
    :QuestGiver => "Anivia",
    :Stage1 => "Choisissez votre premier compagnon auprès du Sanctuaire des Glaces.",
    :Stage2 => "Traversez le col de neige et atteignez le village refuge de Havre-Givre.",
    :Stage3 => "Pénétrez dans la Caverne sacrée de l'Épreuve et affrontez le Gardien.",
    :Location1 => "Sanctuaire des Glaces",
    :Location2 => "Havre-Givre",
    :Location3 => "Caverne de l'Épreuve",
    :QuestDescription => "Une ombre noxienne plane sur les terres glacées du Freljord. Prouvez votre valeur auprès des esprits primordiaux pour protéger l'Œuf d'Anivia.",
    :RewardString => "Bénédiction du Freljord"
  }
end

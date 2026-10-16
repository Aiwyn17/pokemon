#===============================================================================
# Encounter List UI - Menu Integration (Essentials v21.1)
# Adds the Encounter List to the Pause Menu
#===============================================================================

MenuHandlers.add(:pause_menu, :encounter_list, {
  "name"      => _INTL("Radar de Zone"),
  "order"     => 35,
  "condition" => proc { next $game_map != nil },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      pbViewEncounters
    }
    next false
  }
})

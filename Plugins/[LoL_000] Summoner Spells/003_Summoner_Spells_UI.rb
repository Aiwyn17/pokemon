#===============================================================================
# LoL Summoner Spells - User Interface & Scene Integration
#===============================================================================

class Battle::Scene
  #-----------------------------------------------------------------------------
  # Summoner Spells Menu in Battle
  #-----------------------------------------------------------------------------
  def pbSummonerSpellsMenu(idxBattler)
    spells = @battle.summoner_spells[0] || []
    if spells.empty?
      pbDisplay(_INTL("Aucun Sort d'Invocateur disponible !"))
      return false
    end

    commands = []
    spells.each do |sp|
      data = LoLSummonerSpells.spell_data(sp)
      charges = @battle.summoner_spells_charges[0][sp] || 0
      status = (charges > 0) ? "[PRÊT]" : "[UTILISÉ]"
      commands.push("#{data[:symbol_icon]} #{data[:name]}  #{status}")
    end
    commands.push(_INTL("⬅ Retour"))

    msg = _INTL("Sorts d'Invocateur (Option 4) :")
    cmd = pbShowCommands(msg, commands, commands.length - 1)

    if cmd >= 0 && cmd < spells.length
      selected_spell = spells[cmd]
      data = LoLSummonerSpells.spell_data(selected_spell)
      charges = @battle.summoner_spells_charges[0][selected_spell] || 0
      if charges <= 0
        pbPlayBuzzerSE
        pbDisplay(_INTL("{1} a déjà été utilisé pendant ce duel !", data[:name]))
        return pbSummonerSpellsMenu(idxBattler)
      end

      # Display spell effect summary
      pbDisplay(_INTL("{1} : {2}", data[:name], data[:description]))
      if pbConfirmMessage(_INTL("Voulez-vous lancer {1} ?", data[:name]))
        @battle.pbCastSummonerSpell(0, selected_spell)
        return false # Leaves player in command phase to select their move
      else
        return pbSummonerSpellsMenu(idxBattler)
      end
    end
    return false
  end
end

#-------------------------------------------------------------------------------
# Battle Command Phase Hook (Replaces 'Run' with 'Sorts' in Trainer Battles)
#-------------------------------------------------------------------------------
class Battle
  alias lol_pbRunMenu pbRunMenu
  def pbRunMenu(idxBattler)
    if trainerBattle?
      # In trainer battles, Run is replaced by Summoner Spells
      return @scene.pbSummonerSpellsMenu(idxBattler)
    end
    return lol_pbRunMenu(idxBattler)
  end
end

#-------------------------------------------------------------------------------
# Fight Menu Action Button Trigger (Shift / Z / Action Key)
#-------------------------------------------------------------------------------
class Battle::Scene
  alias lol_pbFightMenu_Action pbFightMenu_Action
  def pbFightMenu_Action(battler, specialAction, cw)
    if @battle.trainerBattle? && (!specialAction || specialAction == :none)
      pbSummonerSpellsMenu(battler.index)
      return true
    end
    return lol_pbFightMenu_Action(battler, specialAction, cw)
  end
end

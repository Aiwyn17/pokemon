#===============================================================================
# LoL Summoner Spells - Core System
# Inspired by League of Legends Summoner Spells for Pokémon Essentials v21.1
# Restricted to Trainer & Boss Battles (Option 4)
#===============================================================================

module LoLSummonerSpells
  SPELLS = {
    :FLASH => {
      :name        => "Saut Éclair",
      :symbol_icon => "⚡",
      :description => "Esquive le prochain coup fatal ou confère la priorité absolue ce tour.",
      :sound       => "Anim/Teleport",
      :cooldown    => 1 # 1 use per battle
    },
    :IGNITE => {
      :name        => "Embrasement",
      :symbol_icon => "🔥",
      :description => "Enflamme la cible pendant 4 tours (1/8 PV bruts/tour + Hémorragie -50% soins).",
      :sound       => "Anim/Fire3",
      :cooldown    => 1
    },
    :HEAL => {
      :name        => "Soin",
      :symbol_icon => "💚",
      :description => "Restaure 35 % des PV max, guérit la confusion et confère un bonus de Vitesse.",
      :sound       => "Anim/Recovery",
      :cooldown    => 1
    },
    :BARRIER => {
      :name        => "Barrière",
      :symbol_icon => "🛡️",
      :description => "Génère un bouclier absorbant les dégâts jusqu'à 40 % des PV max pendant 2 tours.",
      :sound       => "Anim/Barrier",
      :cooldown    => 1
    },
    :EXHAUST => {
      :name        => "Fatigue",
      :symbol_icon => "🌀",
      :description => "Neutralise la cible : réduit ses dégâts de 35 % et sa Vitesse de 30 % pendant 2 tours.",
      :sound       => "Anim/Curse",
      :cooldown    => 1
    }
  }

  def self.spell_data(id)
    return SPELLS[id]
  end

  def self.spell_name(id)
    data = SPELLS[id]
    return data ? "#{data[:symbol_icon]} #{data[:name]}" : id.to_s
  end
end

#-------------------------------------------------------------------------------
# Global save data for player's equipped summoner spells
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_writer :summoner_spells

  def summoner_spells
    @summoner_spells ||= [:FLASH, :IGNITE]
    return @summoner_spells
  end
end

#-------------------------------------------------------------------------------
# Battler effects for summoner spells
#-------------------------------------------------------------------------------
class Battle::Battler
  attr_accessor :lol_flash_dodge
  attr_accessor :lol_ignite_turns
  attr_accessor :lol_grievous_wounds
  attr_accessor :lol_barrier_shield
  attr_accessor :lol_barrier_turns
  attr_accessor :lol_exhaust_turns

  alias lol_initEffects pbInitEffects
  def pbInitEffects(batonPass)
    lol_initEffects(batonPass)
    @lol_flash_dodge     = false
    @lol_ignite_turns    = 0
    @lol_grievous_wounds = 0
    @lol_barrier_shield  = 0
    @lol_barrier_turns   = 0
    @lol_exhaust_turns   = 0
  end
end

#-------------------------------------------------------------------------------
# Battle class hooks for initializing and casting Summoner Spells
#-------------------------------------------------------------------------------
class Battle
  attr_accessor :summoner_spells
  attr_accessor :summoner_spells_charges

  alias lol_pbStartBattleCore pbStartBattleCore
  def pbStartBattleCore
    lol_pbStartBattleCore
    pbInitSummonerSpells
  end

  # Initializes Summoner Spells ONLY for Trainer Battles (Option 4)
  def pbInitSummonerSpells
    @summoner_spells = { 0 => [], 1 => [] }
    @summoner_spells_charges = { 0 => {}, 1 => {} }

    return if !trainerBattle? # Disabled in wild Pokémon battles!

    # 1. Player Spells (Side 0)
    player_spells = $PokemonGlobal ? $PokemonGlobal.summoner_spells : [:FLASH, :IGNITE]
    @summoner_spells[0] = player_spells.clone
    player_spells.each { |sp| @summoner_spells_charges[0][sp] = 1 }

    # 2. Opponent Spells (Side 1)
    opponent_spells = pbDetermineOpponentSummonerSpells
    @summoner_spells[1] = opponent_spells.clone
    opponent_spells.each { |sp| @summoner_spells_charges[1][sp] = 1 }
  end

  def pbDetermineOpponentSummonerSpells
    tr = @opponent ? @opponent.first : nil
    return [:FLASH, :IGNITE] if !tr

    type_id = tr.trainer_type
    name = tr.name.upcase

    # Custom boss setups
    if name.include?("KAEL") || name.include?("DRAVEN") || name.include?("DARIUS") || name.include?("NOXUS")
      return [:IGNITE, :FLASH]
    elsif name.include?("BRAUM") || name.include?("SEJUANI") || name.include?("VOLIBEAR")
      return [:BARRIER, :FLASH]
    elsif name.include?("ASHE") || name.include?("ANIVIA") || name.include?("SWAIN")
      return [:EXHAUST, :IGNITE]
    elsif type_id == :CHAMPION || type_id == :LEADER
      return [:FLASH, :IGNITE]
    elsif type_id == :BLACKBELT || type_id == :CRUSHGIRL
      return [:EXHAUST, :FLASH]
    elsif type_id == :DOCTOR || type_id == :NURSE
      return [:HEAL, :BARRIER]
    end

    return [:FLASH, :IGNITE]
  end

  def pbCanCastSummonerSpell?(side, spell_id)
    return false if !trainerBattle?
    return false if !@summoner_spells_charges || !@summoner_spells_charges[side]
    return (@summoner_spells_charges[side][spell_id] || 0) > 0
  end

  def pbCastSummonerSpell(side, spell_id, target = nil)
    return false if !pbCanCastSummonerSpell?(side, spell_id)

    @summoner_spells_charges[side][spell_id] -= 1
    caster_name = (side == 0) ? pbPlayer.name : (pbGetOwnerName(1) rescue "L'adversaire")
    data = LoLSummonerSpells.spell_data(spell_id)
    spell_name = data ? data[:name] : spell_id.to_s

    pbSEPlay(data[:sound]) if data && data[:sound]

    case spell_id
    when :FLASH
      user_battler = (side == 0) ? @battlers[0] : @battlers[1]
      return false if !user_battler || user_battler.fainted?
      user_battler.lol_flash_dodge = true
      pbDisplay(_INTL("{1} déclenche ⚡ SAUT ÉCLAIR !", caster_name))
      pbDisplay(_INTL("{1} se téléporte instantanément et prépare une esquive réflexe !", user_battler.pbThis))

    when :IGNITE
      target_battler = target || ((side == 0) ? @battlers[1] : @battlers[0])
      return false if !target_battler || target_battler.fainted?
      target_battler.lol_ignite_turns = 4
      target_battler.lol_grievous_wounds = 4
      pbDisplay(_INTL("{1} lance 🔥 EMBRASEMENT sur {2} !", caster_name, target_battler.pbThis))
      pbDisplay(_INTL("{1} est enveloppé de flammes infernales et subit Hémorragie !", target_battler.pbThis))

    when :HEAL
      user_battler = (side == 0) ? @battlers[0] : @battlers[1]
      return false if !user_battler || user_battler.fainted?
      heal_amt = [(user_battler.totalhp * 0.35).floor, 1].max
      user_battler.pbRecoverHP(heal_amt)
      user_battler.effects[PBEffects::Confusion] = 0
      user_battler.pbRaiseStatStageByAbility(:SPEED, 1, user_battler, false) if user_battler.pbCanRaiseStatStage?(:SPEED, user_battler)
      pbDisplay(_INTL("{1} utilise 💚 SOIN !", caster_name))
      pbDisplay(_INTL("{1} récupère des PV et un élan de vitesse !", user_battler.pbThis))

    when :BARRIER
      user_battler = (side == 0) ? @battlers[0] : @battlers[1]
      return false if !user_battler || user_battler.fainted?
      shield_amt = [(user_battler.totalhp * 0.40).floor, 1].max
      user_battler.lol_barrier_shield = shield_amt
      user_battler.lol_barrier_turns = 2
      pbDisplay(_INTL("{1} déploie 🛡️ BARRIÈRE !", caster_name))
      pbDisplay(_INTL("Un bouclier protecteur de {1} PV protège {2} !", shield_amt, user_battler.pbThis))

    when :EXHAUST
      target_battler = target || ((side == 0) ? @battlers[1] : @battlers[0])
      return false if !target_battler || target_battler.fainted?
      target_battler.lol_exhaust_turns = 2
      pbDisplay(_INTL("{1} abat 🌀 FATIGUE sur {2} !", caster_name, target_battler.pbThis))
      pbDisplay(_INTL("{1} est accablé par la fatigue ! Dégâts et Vitesse réduits !", target_battler.pbThis))
    end

    return true
  end
end

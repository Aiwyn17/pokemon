# Advanced AI System - Threat Assessment

module AdvancedAI
  module ThreatAssessment
    def self.assess_threat(battle, attacker, opponent, skill_level = 100)
      return 5 unless battle && attacker && opponent && !opponent.fainted?

      threat = 5.0  # Base threat

      threat += assess_stat_threat(attacker, opponent)

      threat += assess_type_threat(attacker, opponent)

      if skill_level >= 50
        threat += assess_move_threat(battle, attacker, opponent)
      end

      if skill_level >= 60
        threat += assess_ability_threat(attacker, opponent)
      end

      threat *= assess_hp_modifier(opponent)

      if skill_level >= 55
        threat += assess_setup_threat(opponent)
      end

      threat += assess_speed_threat(attacker, opponent)

      return [[threat, 0].max, 10].min  # Clamp 0-10
    end

    def self.assess_stat_threat(attacker, opponent)
      threat = 0.0

      if opponent.attack > attacker.defense * 1.5
        threat += 1.0
      elsif opponent.attack > attacker.defense
        threat += 0.5
      end

      if opponent.spatk > attacker.spdef * 1.5
        threat += 1.0
      elsif opponent.spatk > attacker.spdef
        threat += 0.5
      end

      return [threat, 2.5].min
    end

    def self.assess_type_threat(attacker, opponent)
      threat = 0.0

      opponent_types = opponent.pbTypes(true)
      attacker_types = attacker.pbTypes(true)

      opponent_types.each do |opp_type|
        effectiveness = Effectiveness.calculate(opp_type, *attacker_types)

        if Effectiveness.super_effective?(effectiveness)
          threat += 1.0
        elsif Effectiveness.not_very_effective?(effectiveness)
          threat -= 0.5
        elsif Effectiveness.ineffective?(effectiveness)
          threat -= 1.0
        end
      end

      return [threat, 2.0].min
    end

    def self.assess_move_threat(battle, attacker, opponent)
      threat = 0.0
      memory = AdvancedAI::MoveMemory.get_memory(battle, opponent)

      if memory[:moves]
        memory[:moves].each do |move_id|
          move_data = GameData::Move.try_get(move_id)
          next unless move_data

          threat += 0.5 if move_data.priority > 0 && move_data.power > 0

          if move_data.power > 0
            attacker_types = attacker.pbTypes(true)
            resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(opponent, move_data)
            effectiveness = Effectiveness.calculate(resolved_type, *attacker_types)
            threat += 0.8 if Effectiveness.super_effective?(effectiveness)
          end

          threat += 1.0 if [:GUILLOTINE, :FISSURE, :SHEERCOLD, :HORNDRILL].include?(move_id)

          threat += 0.3 if move_data.function_code.start_with?("RaiseUser")
        end
      end

      max_damage = AdvancedAI::MoveMemory.max_known_damage(battle, opponent, attacker)
      if max_damage > attacker.hp * 0.8
        threat += 1.0
      elsif max_damage > attacker.hp * 0.5
        threat += 0.5
      end

      return [threat, 2.0].min
    end

    def self.assess_ability_threat(attacker, opponent)
      threat = 0.0
      # Respect ability suppression (Gastro Acid, Neutralizing Gas)
      if opponent.respond_to?(:abilityActive?)
        ability = opponent.abilityActive? ? opponent.ability_id : nil
      else
        ability = opponent.respond_to?(:ability_id) ? opponent.ability_id : nil
      end

      return 0.0 unless ability

      # === Mold Breaker Family (ignores defensive abilities) ===
      if [:MOLDBREAKER, :TURBOBLAZE, :TERAVOLT].include?(ability)
        if attacker.respond_to?(:abilityActive?)
          attacker_ability = attacker.abilityActive? ? attacker.ability_id : nil
        else
          attacker_ability = attacker.respond_to?(:ability_id) ? attacker.ability_id : nil
        end
        if [:WONDERGUARD, :MULTISCALE, :STURDY, :MAGICGUARD, :LEVITATE].include?(attacker_ability)
          threat += 1.5  # Bypasses our protection
        else
          threat += 0.4
        end
      end

      if ability == :MYCELIUMMIGHT
        threat += 0.3
      end

      if [:HUGEPOWER, :PUREPOWER, :PARENTALBOND, :GORILLATACTICS, :PROTOSYNTHESIS, :QUARKDRIVE].include?(ability)
        threat += 1.5
      end

      if [:ADAPTABILITY, :SHEERFORCE, :TECHNICIAN, :SKILLLINK, :STRONGJAW, :TOUGHCLAWS, :SHARPNESS].include?(ability)
        threat += 0.8
      end

      if ability == :SUPREMEOVERLORD
        threat += 0.6
      end

      if ability == :ORICHALCUMPULSE
        threat += 0.7  # Sets Sun + boosts Attack
      end

      if ability == :HADRONENGINE
        threat += 0.7  # Sets Electric Terrain + boosts SpAtk
      end

      if ability == :TOXICCHAIN
        threat += 0.5  # 30% Toxic chance on all moves
      end

      if ability == :ROCKYPAYLOAD
        threat += 0.4  # Rock-type boost
      end

      if ability == :SWORDOFRUIN
        threat += 1.0
      end

      if ability == :BEADSOFRUIN
        threat += 1.0
      end

      if ability == :TABLETSOFRUIN
        threat += 0.5  # Defensive for them, threat to us
      end

      if ability == :VESSELOFRUIN
        threat += 0.5  # Defensive for them, threat to us
      end

      if ability == :ICESCALES
        if attacker.spatk > attacker.attack
          threat += 0.6  # Our special attacks are halved
        else
          threat += 0.2
        end
      end

      if ability == :STAMINA
        threat += 0.4
      end

      if ability == :WEAKARMOR
        threat += 0.3
      end

      if ability == :ANGERSHELL
        hp_percent = opponent.hp.to_f / opponent.totalhp
        if hp_percent > 0.5
          threat += 0.5  # Could activate if we hit them
        else
          threat += 0.3  # Already activated
        end
      end

      if ability == :ELECTROMORPHOSIS
        threat += 0.3
      end

      if ability == :WINDPOWER
        threat += 0.2
      end

      if ability == :TOXICBOOST
        if opponent.poisoned?
          threat += 0.8  # Active — scary physical threat
        else
          threat += 0.3
        end
      end

      if ability == :FLAREBOOST
        if opponent.burned?
          threat += 0.8  # Active — scary special threat
        else
          threat += 0.3
        end
      end

      if ability == :COTTONDOWN
        threat += 0.2
      end

      if ability == :ZEROTOHERO
        if opponent.respond_to?(:form) && opponent.form == 1
          threat += 1.5  # Hero form Palafin is extremely dangerous
        else
          threat += 0.3  # Not yet transformed
        end
      end

      if ability == :SUPERSWEETSYRUP
        threat += 0.3
      end

      if ability == :POISONPUPPETEER
        threat += 0.6
      end

      if ability == :EMBODYASPECT
        threat += 0.5
      end

      if ability == :TERASHELL
        if opponent.hp == opponent.totalhp
          threat += 0.8  # Extremely tanky at full HP
        end
      end

      if ability == :TERAFORMZERO
        threat += 0.4
      end

      if ability == :TERASHIFT
        threat += 0.3
      end

      if ability == :ASONEGLASTRIER
        threat += 1.2
      end
      if ability == :ASONESPECTRIER
        threat += 1.2
      end

      if ability == :SEEDSOWER
        threat += 0.4
      end

      if ability == :MINDSEYE
        threat += 0.5
      end

      if [:GALEWINGS, :PRANKSTER, :QUICKDRAW].include?(ability)
        threat += 0.6
      end

      if ability == :ARMORTAIL
        if attacker.moves&.any? { |m| m && m.priority > 0 }
          threat += 0.5  # Counters our strategy
        end
      end

      if [:SPEEDBOOST, :UNBURDEN, :MOTORDRIVE].include?(ability)
        threat += 0.5
      end

      if [:WONDERGUARD, :MULTISCALE, :REGENERATOR, :MAGICBOUNCE].include?(ability)
        threat += 0.3
      end

      if ability == :GOODASGOLD
        threat += 0.4
      end

      if ability == :PURIFYINGSALT
        threat += 0.3
      end

      if ability == :GUARDDOG
        threat += 0.3
      end

      if ability == :WINDRIDER
        threat += 0.3
      end

      if [:WELLBAKEDBODY, :EARTHEATER].include?(ability)
        threat += 0.2
      end

      return [threat, 3.0].min  # Raised cap for all the new abilities (Ruin can exceed 2.0)
    end

    def self.assess_hp_modifier(opponent)
      hp_percent = opponent.hp.to_f / opponent.totalhp

      if hp_percent < 0.2
        return 0.3  # Almost fainted
      elsif hp_percent < 0.4
        return 0.6
      elsif hp_percent < 0.6
        return 0.8
      elsif hp_percent > 0.9
        return 1.2  # Full Power
      else
        return 1.0
      end
    end

    def self.assess_setup_threat(opponent)
      threat = 0.0

      [:ATTACK, :SPECIAL_ATTACK, :SPEED].each do |stat|
        stage = opponent.stages[stat]
        threat += stage * 0.3 if stage > 0
      end

      return [threat, 1.5].min
    end

    def self.assess_speed_threat(attacker, opponent)
      return 0.0 if opponent.pbSpeed <= attacker.pbSpeed

      speed_ratio = opponent.pbSpeed.to_f / attacker.pbSpeed

      if speed_ratio > 2.0
        return 1.0
      elsif speed_ratio > 1.5
        return 0.7
      else
        return 0.4
      end
    end

    def self.most_threatening_opponent(battle, attacker, skill_level = 100)
      return nil unless battle && attacker

      opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
      return nil if opponents.empty?

      threats = opponents.map do |opp|
        [opp, assess_threat(battle, attacker, opp, skill_level)]
      end

      threats.max_by { |opp, threat| threat }&.first
    end

    def self.priority_target(battle, attacker, opp1, opp2, skill_level = 100)
      return opp1 unless opp2
      return opp2 unless opp1

      threat1 = assess_threat(battle, attacker, opp1, skill_level)
      threat2 = assess_threat(battle, attacker, opp2, skill_level)

      AdvancedAI.log("#{opp1.pbThis}: #{threat1.round(2)} threat vs #{opp2.pbThis}: #{threat2.round(2)} threat", "Threat")

      threat1 >= threat2 ? opp1 : opp2
    end
  end
end

module AdvancedAI
  def self.assess_threat(battle, attacker, opponent, skill_level = 100)
    ThreatAssessment.assess_threat(battle, attacker, opponent, skill_level)
  end

  def self.most_threatening_opponent(battle, attacker, skill_level = 100)
    ThreatAssessment.most_threatening_opponent(battle, attacker, skill_level)
  end

  def self.priority_target(battle, attacker, opp1, opp2, skill_level = 100)
    ThreatAssessment.priority_target(battle, attacker, opp1, opp2, skill_level)
  end
end

class Battle::AI
  def apply_threat_assessment(score, move, user, target)
    skill = @trainer&.skill || 100
    return score unless AdvancedAI.feature_enabled?(:core, skill)
    return score unless target

    real_user = user.respond_to?(:battler) ? user.battler : user
    real_target = target.respond_to?(:battler) ? target.battler : target

    threat = AdvancedAI.assess_threat(@battle, real_user, real_target, skill)

    if move.damagingMove?
      score += (threat * 5).to_i  # 0-50 Points
    end

    if threat < 3.0 && skill >= 50
      score -= 15  # Other targets more attractive
    end

    return score
  end
end

AdvancedAI.log("Threat Assessment System loaded", "Threat")

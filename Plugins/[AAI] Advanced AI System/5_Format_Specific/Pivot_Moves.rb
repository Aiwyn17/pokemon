# Advanced AI System - Pivot Moves

module AdvancedAI
  module PivotMoves

    OFFENSIVE_PIVOTS = [:UTURN, :VOLTSWITCH, :FLIPTURN]
    DEFENSIVE_PIVOTS = [:PARTINGSHOT, :TELEPORT, :BATONPASS, :CHILLYRECEPTION, :SHEDTAIL]
    SLOW_PIVOTS = [:TELEPORT]  # Move last for safe switch

    ALL_PIVOTS = OFFENSIVE_PIVOTS + DEFENSIVE_PIVOTS

    def self.evaluate_pivot(battle, attacker, move, target, skill_level = 100)
      return 0 unless skill_level >= 60
      return 0 unless ALL_PIVOTS.include?(move.id)

      score = 0

      if OFFENSIVE_PIVOTS.include?(move.id)
        score += evaluate_offensive_pivot(battle, attacker, move, target, skill_level)
      end

      if DEFENSIVE_PIVOTS.include?(move.id)
        score += evaluate_defensive_pivot(battle, attacker, move, target, skill_level)
      end

      if SLOW_PIVOTS.include?(move.id)
        score += evaluate_slow_pivot(battle, attacker, skill_level)
      end

      score
    end

    def self.evaluate_offensive_pivot(battle, attacker, move, target, skill_level)
      score = 0

      # === SUBSTITUTE AWARENESS ===
      # Pivot moves still switch the user out even when the target has a Sub,
      # but the damage is absorbed by the Sub instead of the target's HP.
      target_has_sub = target && target.effects[PBEffects::Substitute] &&
                       target.effects[PBEffects::Substitute] > 0

      if target
        resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
        type_mod = Effectiveness.calculate(resolved_type, *target.pbTypes(true))

        if Effectiveness.ineffective?(type_mod)
          return -50  # Volt Switch blocked by Ground
        elsif Effectiveness.super_effective?(type_mod)
          score += target_has_sub ? 10 : 20
        elsif Effectiveness.not_very_effective?(type_mod)
          score -= 10
        end
      end

      if target_has_sub
        score += 15  # Switch-out value despite Sub absorbing damage
      end

      switch_in = find_best_switch_in(battle, attacker, target, skill_level)
      if switch_in
        score += 25
      else
        score -= 15  # No good switch target
      end

      if target && at_type_disadvantage?(attacker, target)
        score += 30  # Get out while dealing damage
      end

      if is_offensive_team?(battle, attacker)
        score += 15
      end

      opp_side = battle.sides[1 - (attacker.index & 1)]  # opponent side (safe in doubles)
      if opp_side.effects[PBEffects::StealthRock]
        score += 10  # They take rocks on switch
      end

      our_side = battle.sides[attacker.index & 1]  # own side (& 1 is safe in doubles)
      if our_side.effects[PBEffects::StealthRock]
        score -= 10  # Our switch takes rocks
      end

      if target && target.effects[PBEffects::ChoiceBand]
        if target.lastMoveUsed
          last_move = GameData::Move.try_get(target.lastMoveUsed)
          if last_move
            resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, last_move)
            type_mod = Effectiveness.calculate(resolved_type, *attacker.pbTypes(true))
            if Effectiveness.not_very_effective?(type_mod)
              score += 20  # Pivot to something that resists better
            end
          end
        end
      end

      score
    end

    def self.evaluate_defensive_pivot(battle, attacker, move, target, skill_level)
      score = 0

      case move.id
      when :PARTINGSHOT
        score += evaluate_parting_shot(battle, attacker, target, skill_level)
      when :TELEPORT
        score += evaluate_teleport(battle, attacker, skill_level)
      when :BATONPASS
        score += evaluate_baton_pass(battle, attacker, skill_level)
      when :CHILLYRECEPTION
        score += evaluate_chilly_reception(battle, attacker, skill_level)
      end

      score
    end

    def self.evaluate_parting_shot(battle, attacker, target, skill_level)
      score = 0

      opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

      # Evaluate the actual target when provided, otherwise pick best
      targets_to_eval = target ? [target] : opponents

      best_target_score = targets_to_eval.map do |opp|
        ts = 0
        ts += 15 if opp.attack >= 100 || opp.spatk >= 100
        if opp.stages[:ATTACK] > -6 || opp.stages[:SPECIAL_ATTACK] > -6
          ts += 20
        else
          ts -= 30  # Already at -6
        end
        if opp.hasActiveAbility?(:CLEARBODY) || opp.hasActiveAbility?(:WHITESMOKE) || opp.hasActiveAbility?(:FULLMETALBODY)
          ts -= 40
        end
        if opp.hasActiveAbility?(:COMPETITIVE) || opp.hasActiveAbility?(:DEFIANT)
          ts -= 200
        end
        if opp.hasActiveAbility?(:CONTRARY)
          ts -= 200
        end
        if opp.hasActiveAbility?(:MIRRORARMOR)
          ts -= 40
        end
        ts
      end.max || 0
      score += best_target_score

      switch_in = find_best_switch_in(battle, attacker, opponents.first, skill_level)
      if switch_in
        score += 20
      else
        score -= 25
      end

      score
    end

    def self.evaluate_teleport(battle, attacker, skill_level)
      score = 0

      frail_sweepers = switch_in_candidates(battle, attacker).count do |pkmn|
        (pkmn.attack >= 120 || pkmn.spatk >= 120) &&
        (pkmn.defense < 80 || pkmn.spdef < 80)
      end

      score += frail_sweepers * 20

      opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
      can_damage = opponents.any? do |opp|
        attacker.moves.any? do |m|
          next false unless m && m.damagingMove?
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, m)
          type_mod = Effectiveness.calculate(resolved_type, *opp.pbTypes(true))
          Effectiveness.super_effective?(type_mod) || type_mod >= Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
        end
      end

      unless can_damage
        score += 30  # We're not threatening anyway
      end

      wish_val = (battle.positions[attacker.index].effects[PBEffects::Wish] rescue 0)
      if wish_val.is_a?(Numeric) && wish_val > 0
        score += 35
      end

      score
    end

    def self.evaluate_baton_pass(battle, attacker, skill_level)
      score = 0

      total_boosts = 0
      attacker.stages.each do |stat, stage|
        total_boosts += stage if stage > 0
      end

      score += total_boosts * 15

      if attacker.effects[PBEffects::Substitute] && attacker.effects[PBEffects::Substitute] > 0
        score += 35
      end

      if attacker.effects[PBEffects::AquaRing]
        score += 20
      end
      if attacker.effects[PBEffects::MagnetRise] && attacker.effects[PBEffects::MagnetRise] > 0
        score += 25
      end
      if attacker.effects[PBEffects::Ingrain]
        score += 15
      end

      recipients = switch_in_candidates(battle, attacker).count do |pkmn|
        pkmn.attack >= 100 || pkmn.spatk >= 100
      end

      if recipients > 0
        score += 20
      else
        score -= 30  # No one to pass to
      end

      score
    end

    def self.evaluate_chilly_reception(battle, attacker, skill_level)
      score = 0

      effective_weather = AdvancedAI::Utilities.current_weather(battle)
      if effective_weather == :Snow || effective_weather == :Hail
        score -= 30  # Already snowy
      end

      party = battle.pbParty(attacker.index & 1)
      ice_types = party.count { |p| p && !p.fainted? && p.hasType?(:ICE) }
      score += ice_types * 15

      slush_rush = party.count { |p| p && !p.fainted? && p.ability_id == :SLUSHRUSH }
      score += slush_rush * 25

      score += 20  # Snow allows Aurora Veil

      score
    end

    def self.evaluate_slow_pivot(battle, attacker, skill_level)
      score = 0

      if attacker.defense >= 100 || attacker.spdef >= 100
        score += 20  # We can tank a hit
      end

      hp_percent = attacker.hp.to_f / attacker.totalhp
      if hp_percent < 0.3
        score += 25
      end

      score
    end

    def self.switch_in_candidates(battle, attacker)
      battle.pbParty(attacker.index).each_with_index.filter_map do |pkmn, i|
        next unless battle.pbCanSwitchIn?(attacker.index, i)
        reserved = battle.allSameSideBattlers(attacker.index).any? do |ally|
          battle.choices[ally.index][0] == :SwitchOut && battle.choices[ally.index][1] == i
        end
        pkmn unless reserved
      end
    end

    def self.find_best_switch_in(battle, attacker, opponent, skill_level)
      return nil unless skill_level >= 60

      candidates = []
      switch_in_candidates(battle, attacker).each do |pkmn|

        candidate_score = 0

        if opponent
          # Type advantage (pkmn is party Pokemon, use .types)
          pkmn_types = pkmn.types.compact

          opp_stab = opponent.pbTypes(true).compact
          opp_stab.each do |opp_type|
            type_mod = Effectiveness.calculate(opp_type, *pkmn_types)
            if Effectiveness.not_very_effective?(type_mod)
              candidate_score += 20
            elsif Effectiveness.ineffective?(type_mod)
              candidate_score += 40
            end
          end

          pkmn.moves.each do |move|
            next unless move && move.is_a?(Pokemon::Move)
            move_data = GameData::Move.try_get(move.id)
            next unless move_data
            if move_data.power > 0  # Physical or Special
              resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(pkmn, move_data)
              type_mod = Effectiveness.calculate(resolved_type, *opponent.pbTypes(true))
              if Effectiveness.super_effective?(type_mod)
                candidate_score += 25
              end
            end
          end
        end

        hp_percent = pkmn.hp.to_f / pkmn.totalhp
        candidate_score += (hp_percent * 30).to_i

        candidates << { pokemon: pkmn, score: candidate_score }
      end

      best = candidates.max_by { |c| c[:score] }
      best && best[:score] > 20 ? best[:pokemon] : nil
    end

    def self.pivot_vs_attack(battle, attacker, pivot_move, attack_move, target, skill_level = 100)
      return :attack unless skill_level >= 65
      return :pivot unless attack_move
      return :attack unless pivot_move

      pivot_score = evaluate_pivot(battle, attacker, pivot_move, target, skill_level)

      attack_score = 0
      if attack_move.damagingMove? && target
        resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, attack_move)
        type_mod = Effectiveness.calculate(resolved_type, *target.pbTypes(true))

        if Effectiveness.super_effective?(type_mod)
          attack_score += 40
        end

        if AdvancedAI::CombatUtilities.resolve_move_power(attack_move) >= 100
          attack_score += 20
        end

        estimated_damage = estimate_damage_percent(attacker, target, attack_move)
        if estimated_damage >= 100
          attack_score += 50  # KO is high value
        end
      end

      pivot_score > attack_score ? :pivot : :attack
    end

    private

    def self.at_type_disadvantage?(user, target)
      return false unless target

      target_stab = target.pbTypes(true).compact

      target_stab.any? do |type|
        type_mod = Effectiveness.calculate(type, *user.pbTypes(true))
        Effectiveness.super_effective?(type_mod)
      end
    end

    def self.is_offensive_team?(battle, attacker)
      party = battle.pbParty(attacker.index & 1)

      offensive = party.count do |pkmn|
        next false unless pkmn && !pkmn.fainted?
        pkmn.attack >= 100 || pkmn.spatk >= 100
      end

      offensive >= 3
    end

    def self.estimate_damage_percent(attacker, target, move)
      return 0 unless move && move.damagingMove?

      AdvancedAI::CombatUtilities.estimate_damage(
        attacker, move, target, :as_percent => true
      ) * 100
    end
  end
end

module AdvancedAI
  def self.evaluate_pivot(battle, attacker, move, target, skill_level = 100)
    PivotMoves.evaluate_pivot(battle, attacker, move, target, skill_level)
  end

  def self.find_best_switch_in(battle, attacker, opponent, skill_level = 100)
    PivotMoves.find_best_switch_in(battle, attacker, opponent, skill_level)
  end

  def self.pivot_vs_attack(battle, attacker, pivot_move, attack_move, target, skill_level = 100)
    PivotMoves.pivot_vs_attack(battle, attacker, pivot_move, attack_move, target, skill_level)
  end

  def self.is_pivot_move?(move)
    return false unless move
    PivotMoves::ALL_PIVOTS.include?(move.id)
  end
end

AdvancedAI.log("Pivot Moves System loaded", "Pivot")
AdvancedAI.log("  - U-turn / Volt Switch / Flip Turn", "Pivot")
AdvancedAI.log("  - Parting Shot evaluation", "Pivot")
AdvancedAI.log("  - Teleport (slow pivot)", "Pivot")
AdvancedAI.log("  - Baton Pass optimization", "Pivot")
AdvancedAI.log("  - Chilly Reception (Snow + pivot)", "Pivot")
AdvancedAI.log("  - Switch-in target selection", "Pivot")
AdvancedAI.log("  - Pivot vs Attack decision making", "Pivot")

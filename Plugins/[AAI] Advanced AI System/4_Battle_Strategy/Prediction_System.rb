module AdvancedAI
  module PredictionSystem

    def self.predict_switch_chance(battle, opponent)
      return 0 if !battle || !opponent

      return 0 unless battle.pbParty(opponent.index).each_index.any? { |i| battle.pbCanSwitch?(opponent.index, i) }
      chance = 0

      foes = battle.allOtherSideBattlers(opponent.index).select { |b| b && !b.fainted? }
      foes.each do |foe|
        memory = AdvancedAI.get_memory(battle, foe)
        next unless memory && memory[:moves]
        usable_ids = foe.moves.each_with_index.filter_map do |candidate, i|
          candidate.id if candidate && battle.pbCanChooseMove?(foe.index, i, false)
        end
        threatened = memory[:moves].any? do |move_id|
          next false unless usable_ids.include?(move_id)
          move = GameData::Move.try_get(move_id)
          next false if !move || move.category == 2
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(foe, move)
          effectiveness = Effectiveness.calculate(resolved_type, *opponent.pbTypes(true))
          Effectiveness.super_effective?(effectiveness)
        end
        if threatened
          chance += 30
          break
        end
      end

      if opponent.hp < opponent.totalhp * 0.3
        chance += 25
      elsif opponent.hp < opponent.totalhp * 0.5
        chance += 15
      end

      if opponent.stages[:ATTACK] <= -2 || opponent.stages[:SPECIAL_ATTACK] <= -2
        chance += 20
      end

      if opponent.stages[:SPEED] <= -2
        chance += 15
      end

      if opponent.status == :BURN || opponent.status == :POISON
        chance += 15
      end

      if opponent.status == :PARALYSIS
        chance += 10
      end

      if opponent.moves.each_index.none? { |i| battle.pbCanChooseMove?(opponent.index, i, false) }
        chance += 50  # Struggle forced
      end

      if opponent.turnCount <= 1
        chance -= 30
      end

      chance = [[chance, 95].min, 0].max

      return chance
    end

    def self.predict_switch_target(battle, opponent)
      return nil if !battle || !opponent

      return nil unless battle.pbParty(opponent.index).each_index.any? { |i| battle.pbCanSwitch?(opponent.index, i) }
      party = battle.pbParty(opponent.index)

      best_counter = nil
      best_score = 0

      foes = battle.allOtherSideBattlers(opponent.index).select { |b| b && !b.fainted? }
      user = foes.first
      return nil if !user

      party.each_with_index do |pokemon, i|
        next unless battle.pbCanSwitch?(opponent.index, i)
        next if pokemon == opponent.pokemon  # Not current Pokemon
        next if battle.pbFindBattler(i, opponent.index % 2)  # Skip already-active Pokemon (doubles)

        score = 0

        user.moves.each do |move|
          next if !move || !move.damagingMove? || move.pp == 0
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
          effectiveness = Effectiveness.calculate(resolved_type, *pokemon.types)

          if Effectiveness.not_very_effective?(effectiveness) || Effectiveness.ineffective?(effectiveness)
            score += 30
          elsif Effectiveness.super_effective?(effectiveness)
            score -= 20
          end
        end

        score += 20 if pokemon.hp == pokemon.totalhp

        roles = AdvancedAI.detect_roles(pokemon)
        score += 15 if roles.include?(:wall) || roles.include?(:tank)

        if score > best_score
          best_score = score
          best_counter = pokemon
        end
      end

      return best_counter
    end

    def self.predict_next_move(battle, opponent, skill = 100)
      return nil if !battle || !opponent
      return nil if AdvancedAI.prediction_depth(skill) == 0

      memory = AdvancedAI.get_memory(battle, opponent)
      return nil if !memory || !memory[:move_counts]

      usable = opponent.moves.each_with_index.select do |move, i|
        move && battle.pbCanChooseMove?(opponent.index, i, false)
      end.map { |move, i| move.id }
      counts = memory[:move_counts].select { |id, count| usable.include?(id) && count > 0 }
      most_used = counts.max_by { |id, count| count }&.first
      if AdvancedAI.tier_feature(skill, :learn_patterns) && most_used == memory[:last_move] && counts.length > 1
        alternative = counts.reject { |id, count| id == most_used }.max_by { |id, count| count }&.first
        most_used = alternative if counts[most_used] - counts[alternative] <= 1
      end

      return most_used
    end

    def self.score_prediction_bonus(battle, user, target, move, predicted_move, skill = 100)
      return 0 if !battle || !user || !target || !move || !predicted_move
      return 0 if AdvancedAI.prediction_depth(skill) == 0

      bonus = 0
      predicted_move_data = GameData::Move.try_get(predicted_move)
      return 0 if !predicted_move_data
      predicted = Battle::Move.from_pokemon_move(battle, Pokemon::Move.new(predicted_move))
      resolved_power = AdvancedAI::CombatUtilities.resolve_move_power(predicted, target, user)
      resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, predicted_move_data)
      protection = AdvancedAI::MoveCategories::PROTECT_MOVES[move.id]
      blocks_damage = protection && !protection[:team] && !protection[:hp]

      if blocks_damage
        if predicted.damagingMove? && predicted.canProtectAgainst? && resolved_power >= 80 &&
           calculate_predicted_damage(target, user, predicted) > 0
          bonus += 40
        end
      end

      effectiveness = AdvancedAI::Utilities.type_mod(resolved_type, user)
      if predicted.damagingMove? && (Effectiveness.not_very_effective?(effectiveness) || Effectiveness.ineffective?(effectiveness))
        bonus += 25
      end

      if move.id == :WILLOWISP && predicted_move_data.category == 0
        bonus += 35
      end

      if move.id == :TAUNT && predicted_move_data.category == 2  # status move
        bonus += 35
      end

      if predicted.damagingMove?
        damage = calculate_predicted_damage(target, user, predicted)
        if damage >= user.hp
          bonus += 50 if AdvancedAI.pivot_move?(move.id) && AdvancedAI.tier_feature(skill, :pivot_preference)
          bonus += 45 if (blocks_damage || move.id == :ENDURE) && predicted.canProtectAgainst?
        end
      end

      return bonus
    end

    @battle_patterns = {}

    def self.track_pattern(battle, trainer_name, action)
      return if !battle || !trainer_name || !action

      @battle_patterns[trainer_name] ||= []
      @battle_patterns[trainer_name] << {
        turn: battle.turnCount,
        action: action
      }

      @battle_patterns[trainer_name] = @battle_patterns[trainer_name].last(20)
    end

    def self.detect_pattern(trainer_name, pattern_type)
      return false if !trainer_name || !@battle_patterns[trainer_name]

      patterns = @battle_patterns[trainer_name]
      return false if patterns.size < 3

      case pattern_type
      when :always_setup_turn1
        turn1_actions = patterns.select { |p| p[:turn] == 1 }
        return false if turn1_actions.empty?

        setup_count = turn1_actions.count { |p| p[:action] == :setup }
        return setup_count >= turn1_actions.size * 0.8

      when :switches_on_disadvantage
        disadvantage_switches = patterns.count { |p| p[:action] == :switch_on_disadvantage }
        return disadvantage_switches >= 3

      when :always_attack
        attack_count = patterns.count { |p| p[:action] == :attack }
        return attack_count >= patterns.size * 0.9
      end

      return false
    end

    def self.should_double_switch?(battle, user, predicted_switch)
      return false if !battle || !user || !predicted_switch

      party = battle.pbParty(user.index % 2)
      return false if !party

      best_counter = nil
      best_score = 0

      party.each do |pokemon|
        next if !pokemon || pokemon.fainted? || pokemon.egg?
        next if pokemon == user.pokemon

        score = 0

        pokemon.moves.each do |move|
          next if !move
          move_data = GameData::Move.try_get(move.id)
          next unless move_data
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(pokemon, move_data)
          effectiveness = Effectiveness.calculate(resolved_type, *predicted_switch.types)
          score += 40 if Effectiveness.super_effective?(effectiveness)
        end

        predicted_switch.moves.each do |move|
          next if !move
          move_data = GameData::Move.try_get(move.id)
          next unless move_data
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(predicted_switch, move_data)
          effectiveness = Effectiveness.calculate(resolved_type, *pokemon.types)
          score += 20 if Effectiveness.not_very_effective?(effectiveness)
          score += 30 if Effectiveness.ineffective?(effectiveness)
        end

        if score > best_score
          best_score = score
          best_counter = pokemon
        end
      end

      return best_score >= 60
    end

    def self.calculate_predicted_damage(attacker, defender, move)
      return 0 if !attacker || !defender || !move

      battle_move = AdvancedAI::CombatUtilities.battle_move_for(attacker, move)
      return 0 unless battle_move
      AdvancedAI::CombatUtilities.estimate_damage(attacker, battle_move, defender)
    end

  end
end

module AdvancedAI
  def self.predict_switch_chance(battle, opponent)
    PredictionSystem.predict_switch_chance(battle, opponent)
  end

  def self.predict_switch_target(battle, opponent)
    PredictionSystem.predict_switch_target(battle, opponent)
  end

  def self.predict_next_move(battle, opponent, skill = 100)
    PredictionSystem.predict_next_move(battle, opponent, skill)
  end

  def self.score_prediction_bonus(battle, user, target, move, predicted_move, skill = 100)
    PredictionSystem.score_prediction_bonus(battle, user, target, move, predicted_move, skill)
  end

  def self.track_pattern(battle, trainer_name, action)
    PredictionSystem.track_pattern(battle, trainer_name, action)
  end

  def self.detect_pattern(trainer_name, pattern_type)
    PredictionSystem.detect_pattern(trainer_name, pattern_type)
  end

  def self.should_double_switch?(battle, user, predicted_switch)
    PredictionSystem.should_double_switch?(battle, user, predicted_switch)
  end
end

class Battle::AI
  def apply_prediction_logic(score, move, user, target)
    return score unless move && target
    skill = @_resolved_skill || @trainer&.skill || 100
    return score if AdvancedAI.prediction_depth(skill) == 0

    predicted_move = AdvancedAI.predict_next_move(@battle, target, skill)
    if predicted_move
      bonus = AdvancedAI.score_prediction_bonus(@battle, user, target, move, predicted_move, skill)
      score += bonus if bonus && bonus > 0
    end

    switch_chance = if AdvancedAI.tier_feature(skill, :switch_prediction) && AdvancedAI.get_setting(:switch_prediction) > 0
                      AdvancedAI.predict_switch_chance(@battle, target)
                    else
                      0
                    end
    if switch_chance && switch_chance > 50
      score += 15 if AdvancedAI.pivot_move?(move.id) && AdvancedAI.tier_feature(skill, :pivot_preference)
      score += 20 if move.id == :PURSUIT
    end

    return score
  end
end

module AdvancedAI
  module SetupRecognition

    SETUP_COUNTERS = {
      :ROAR         => { type: :phaze, priority: -6, bypasses_sub: true },
      :WHIRLWIND    => { type: :phaze, priority: -6, bypasses_sub: true },
      :DRAGONTAIL   => { type: :phaze, priority: -6, damage: true },
      :CIRCLETHROW  => { type: :phaze, priority: -6, damage: true },

      :HAZE         => { type: :reset, affects: :all },
      :CLEARSMOG    => { type: :reset, affects: :target, damage: true },

      :ENCORE       => { type: :lock, duration: 3 },
      :TAUNT        => { type: :block, duration: 3, status_only: true },
      :DISABLE      => { type: :block, duration: 4, last_move: true },
      :TORMENT      => { type: :lock, no_repeat: true },

      :PSYCHUP      => { type: :copy, positive_only: true },
      :SPECTRALTHIEF => { type: :steal, damage: true },

      :PUNISHMENT   => { type: :punish, max_power: 200 },
      :STOREDPOWER  => { type: :reward, max_power: 860 },
    }

    def self.has_setup?(battler)
      return false if !battler

      [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE,
       :SPEED, :ACCURACY, :EVASION].each do |stat|
        return true if battler.stages[stat] > 0
      end

      return false
    end

    def self.count_setup_stages(battler)
      return 0 if !battler

      total = 0
      [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE,
       :SPEED, :ACCURACY, :EVASION].each do |stat|
        total += battler.stages[stat] if battler.stages[stat] > 0
      end

      return total
    end

    def self.recently_setup?(battle, battler)
      return false if !battle || !battler
      return false if !AdvancedAI.feature_enabled?(:setup, 100)

      memory = AdvancedAI.get_memory(battle, battler)
      return false if !memory

      last_move = memory[:last_move]
      return false if !last_move

      return AdvancedAI.setup_move?(last_move)
    end

    def self.assess_setup_threat(battle, attacker, defender)
      return 0.0 if !battle || !attacker || !defender

      threat = 0.0

      stages = count_setup_stages(attacker)
      threat += stages * 0.5

      if attacker.stages[:ATTACK] >= 2 || attacker.stages[:SPECIAL_ATTACK] >= 2
        threat += 2.0  # Offensive threat
      end

      if attacker.stages[:SPEED] >= 2
        threat += 1.5  # Speed threat (hard to stop)
      end

      if attacker.stages[:EVASION] >= 1
        threat += 2.0  # Evasion = very annoying
      end

      if attacker.attack >= 120 || attacker.spatk >= 120
        threat += 1.0
      end

      if attacker.speed >= 100
        threat += 1.0
      end

      known_moves = AdvancedAI.get_memory(battle, attacker)
      if known_moves && known_moves[:moves]
        coverage_count = 0
        known_moves[:moves].each do |move_id|
          move = GameData::Move.try_get(move_id)
          next if !move || move.power == 0  # skip status moves (GameData::Move has no .statusMove?)
          coverage_count += 1
        end

        threat += coverage_count * 0.3  # More Coverage = more dangerous
      end

      if defender.hp < defender.totalhp * 0.5
        threat += 1.5  # Defender weak = higher danger
      end

      remaining_pokemon = battle.pbAbleNonActiveCount(defender.index & 1)
      if remaining_pokemon <= 1
        threat += 2.0  # Last Pokemon = critical
      end

      threat = [threat, 10.0].min

      return threat
    end

    def self.find_best_counter(battle, user, target)
      return nil if !battle || !user || !target

      best_move = nil
      best_score = 0

      user.moves.each_with_index do |move, index|
        next if !move || move.pp <= 0
        next unless battle.pbCanChooseMove?(user.index, index, false)
        next if AdvancedAI::Utilities.counter_shield_blocked?(battle, move, user, target)
        move_id = move.id

        if [:ROAR, :WHIRLWIND, :DRAGONTAIL, :CIRCLETHROW].include?(move_id)
          next unless AdvancedAI::Utilities.phazing_possible?(battle, move, user, target)
          score = 100

          score += count_setup_stages(target) * 10

          if score > best_score
            best_score = score
            best_move = move_id
          end
        end

        if move_id == :HAZE
          next if count_setup_stages(target) <= 0
          next unless AdvancedAI::Utilities.stat_reset_hits_target?(battle, move, user, target)
          score = 90
          score += count_setup_stages(target) * 10

          if score > best_score
            best_score = score
            best_move = move_id
          end
        end

        if move_id == :CLEARSMOG
          next if count_setup_stages(target) <= 0
          next unless AdvancedAI::Utilities.stat_reset_hits_target?(battle, move, user, target)
          score = 85
          score += count_setup_stages(target) * 10

          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
          effectiveness = AdvancedAI::Utilities.type_mod(resolved_type, target)
          score += 20 if Effectiveness.super_effective?(effectiveness)
          score -= 20 if Effectiveness.not_very_effective?(effectiveness)

          if score > best_score
            best_score = score
            best_move = move_id
          end
        end

        if move_id == :ENCORE
          next unless AdvancedAI::Utilities.setup_disruption_hits?(battle, move, user, target)
          score = 80

          if recently_setup?(battle, target)
            score += 40
          end

          if score > best_score
            best_score = score
            best_move = move_id
          end
        end

        if move_id == :TAUNT
          next unless AdvancedAI::Utilities.setup_disruption_hits?(battle, move, user, target)
          score = 70

          roles = AdvancedAI.detect_roles(target)
          score += 30 if roles.include?(:support)

          if score > best_score
            best_score = score
            best_move = move_id
          end
        end
      end

      return best_move
    end

    def self.should_counter_now?(battle, user, target, skill_level)
      return false if !battle || !user || !target

      threat = assess_setup_threat(battle, target, user)

      threshold = case skill_level
      when 100 then 4.0   # Master: Counter early
      when 90  then 5.0   # Expert
      when 80  then 6.0   # Advanced
      when 70  then 7.0   # Skilled
      else 8.0            # Core: Only if extreme danger
      end

      return threat >= threshold
    end

    def self.baton_pass_chain?(battle, side_index)
      return false if !battle

      baton_pass_count = 0
      setup_move_count = 0

      battle.eachInTeamFromBattlerIndex(side_index) do |pokemon, _index|
        next if !pokemon || pokemon.egg? || pokemon.fainted?

        ids = pokemon.moves.map(&:id).uniq
        baton_pass_count += 1 if ids.include?(:BATONPASS)
        setup_move_count += ids.count { |id| AdvancedAI.setup_move?(id) }
      end

      return baton_pass_count >= 2 && setup_move_count >= 3
    end

    def self.baton_chain_priority(battle, user, move = nil, target = nil, skill = 100)
      return 0 unless battle && user && AdvancedAI.get_setting(:setup_chains, 0) > 0
      return 0 unless AdvancedAI.feature_enabled?(:setup, skill) && AdvancedAI.tier_feature(skill, :setup_detection)
      user = user.battler if user.respond_to?(:battler)
      target = target.battler if target.respond_to?(:battler)
      targets = target ? [target] : battle.allOtherSideBattlers(user).to_a
      bonuses = targets.map do |opponent|
        next 0 unless opponent.opposes?(user) && baton_pass_chain?(battle, opponent.index)
        counter = find_best_counter(battle, user, opponent)
        next 0 unless counter && (!move || move.id == counter)
        [:TAUNT, :ENCORE].include?(counter) ? 20 : 30
      end
      bonuses.max || 0
    end

  end
end

module AdvancedAI
  def self.has_setup?(battler)
    SetupRecognition.has_setup?(battler)
  end

  def self.count_setup_stages(battler)
    SetupRecognition.count_setup_stages(battler)
  end

  def self.assess_setup_threat(battle, attacker, defender)
    SetupRecognition.assess_setup_threat(battle, attacker, defender)
  end

  def self.find_best_setup_counter(battle, user, target)
    SetupRecognition.find_best_counter(battle, user, target)
  end

  def self.should_counter_setup_now?(battle, user, target, skill_level)
    SetupRecognition.should_counter_now?(battle, user, target, skill_level)
  end

  def self.baton_pass_chain?(battle, side_index)
    SetupRecognition.baton_pass_chain?(battle, side_index)
  end
end

class Battle::AI
  def apply_setup_evaluation(score, move, user, target)
    return score unless move
    skill = @_resolved_skill || @trainer&.skill || 100

    real_user = user.respond_to?(:battler) ? user.battler : user

    if target
      real_target = target.respond_to?(:battler) ? target.battler : target
      if [:ROAR, :WHIRLWIND, :DRAGONTAIL, :CIRCLETHROW, :HAZE, :CLEARSMOG, :ENCORE, :TAUNT].include?(move.id)
        return score if AdvancedAI::Utilities.counter_shield_blocked?(@battle, move, real_user, real_target)
      end
      if [:HAZE, :CLEARSMOG].include?(move.id)
        index = real_user.moves.index { |m| m.id == move.id }
        return score if index && !@battle.pbCanChooseMove?(real_user.index, index, false)
        return score unless real_target.stages.values.any? { |stage| stage > 0 }
        return score unless AdvancedAI::Utilities.stat_reset_hits_target?(@battle, move, real_user, real_target)
      end
      if [:ROAR, :WHIRLWIND, :DRAGONTAIL, :CIRCLETHROW].include?(move.id)
        index = real_user.moves.index { |m| m.id == move.id }
        return score if index && !@battle.pbCanChooseMove?(real_user.index, index, false)
        return score unless AdvancedAI::Utilities.phazing_possible?(@battle, move, real_user, real_target)
      end
      score += AdvancedAI::SetupRecognition.baton_chain_priority(@battle, real_user, move, real_target, skill)
      threat = AdvancedAI.assess_setup_threat(@battle, real_target, real_user)

      if threat >= 5.0
        phaze_moves = [:ROAR, :WHIRLWIND, :DRAGONTAIL, :CIRCLETHROW, :HAZE, :CLEARSMOG]
        if phaze_moves.include?(move.id)
          score += (threat * 5).to_i  # Up to +50 for Haze/phaze vs boosted foe
        end

        if move.priority > 0 && move.damagingMove?
          score += (threat * 3).to_i  # Up to +30
        end
      end

      if AdvancedAI.should_counter_setup_now?(@battle, real_user, real_target, skill)
        counter_move = AdvancedAI.find_best_setup_counter(@battle, real_user, real_target)
        if counter_move && move.id == counter_move
          score += 25  # Boost the recommended counter move
        end
      end
    end

    if AdvancedAI.setup_move?(move.id) && target
      real_target = target.respond_to?(:battler) ? target.battler : target
      # Don't set up if opponent is already boosted and threatening
      opponent_threat = AdvancedAI.assess_setup_threat(@battle, real_target, real_user)
      if opponent_threat >= 6.0
        score -= 20  # Don't set up when opponent is already boosted
      end
    end

    return score
  end
end

# Advanced AI System - Move Memory

module AdvancedAI
  module MoveMemory
    @battle_memory = {}

    def self.initialize_battle(battle)
      @battle_memory[battle.object_id] ||= {}
    end

    def self.remember_move(battle, battler, move)
      return unless battle && battler && move
      initialize_battle(battle)

      battler_key = "#{battler.index}_#{battler.pokemon.personalID}"
      @battle_memory[battle.object_id][battler_key] ||= {
        moves: [],
        move_counts: Hash.new(0),
        last_move: nil,
        priority_moves: [],
        healing_moves: [],
        setup_moves: [],
        status_moves: [],
        max_power: 0
      }

      memory = @battle_memory[battle.object_id][battler_key]
      move_id = move.id

      memory[:moves] << move_id unless memory[:moves].include?(move_id)
      memory[:move_counts][move_id] += 1
      memory[:last_move] = move_id

      memory[:priority_moves] << move_id if move.priority > 0 && !memory[:priority_moves].include?(move_id)
      memory[:healing_moves] << move_id if move.healingMove? && !memory[:healing_moves].include?(move_id)

      is_setup = move.function_code.start_with?("RaiseUser")
      memory[:setup_moves] << move_id if is_setup && !memory[:setup_moves].include?(move_id)

      memory[:status_moves] << move_id if move.statusMove? && !memory[:status_moves].include?(move_id)
      memory[:max_power] = [memory[:max_power], AdvancedAI::CombatUtilities.resolve_move_power(move)].max

      move_type = if move.damagingMove?
                    "Damaging (#{move.power} BP)"
                  elsif move.statusMove?
                    "Status"
                  else
                    "Other"
                  end
      AdvancedAI.log("Move Memory: #{battler.name} used #{move.name} (#{move_type}) - Total uses: #{memory[:move_counts][move_id]}", "Memory")
    end

    def self.get_memory(battle, battler)
      return {} unless battle && battler
      initialize_battle(battle)

      if battler.respond_to?(:index)
        pkmn = battler.respond_to?(:pokemon) ? battler.pokemon : battler
        battler_key = "#{battler.index}_#{pkmn.personalID}"
      elsif battler.respond_to?(:personalID)
        pid = battler.personalID
        store = @battle_memory[battle.object_id]
        store.each do |key, val|
          return val if key.end_with?("_#{pid}")
        end
        return {}
      else
        return {}
      end
      @battle_memory[battle.object_id][battler_key] || {}
    end

    def self.knows_move?(battle, battler, move_id)
      memory = get_memory(battle, battler)
      memory[:moves]&.include?(move_id) || false
    end

    def self.has_priority_move?(battle, battler)
      memory = get_memory(battle, battler)
      !memory[:priority_moves].nil? && memory[:priority_moves].any?
    end

    def self.has_healing_move?(battle, battler)
      memory = get_memory(battle, battler)
      !memory[:healing_moves].nil? && memory[:healing_moves].any?
    end

    def self.has_setup_move?(battle, battler)
      memory = get_memory(battle, battler)
      !memory[:setup_moves].nil? && memory[:setup_moves].any?
    end

    def self.strongest_known_move(battle, battler)
      memory = get_memory(battle, battler)
      return nil if memory[:moves].nil? || memory[:moves].empty?

      memory[:moves].max_by do |move_id|
        data = GameData::Move.try_get(move_id)
        data ? data.power : 0
      end
    end

    def self.max_known_damage(battle, attacker, defender)
      return 0 unless attacker && defender
      memory = get_memory(battle, attacker)
      return 0 if memory[:moves].nil? || memory[:moves].empty?

      memory[:moves].filter_map do |move_id|
        move_data = GameData::Move.try_get(move_id)
        next unless move_data && move_data.power > 0
        battle_move = AdvancedAI::CombatUtilities.battle_move_for(attacker, move_data)
        next unless battle_move
        AdvancedAI::CombatUtilities.estimate_damage(attacker, battle_move, defender)
      end.max || 0
    end

    def self.last_move(battle, battler)
      memory = get_memory(battle, battler)
      memory[:last_move]
    end

    def self.move_frequency(battle, battler, move_id)
      memory = get_memory(battle, battler)
      memory[:move_counts]&.[](move_id) || 0
    end

    def self.cleanup_battle(battle)
      @battle_memory.delete(battle.object_id) if battle
    end
  end
end

class Battle
  alias_method :aai_memory_pbEndOfBattle, :pbEndOfBattle unless method_defined?(:aai_memory_pbEndOfBattle) || private_method_defined?(:aai_memory_pbEndOfBattle)
  def pbEndOfBattle
    AdvancedAI::MoveMemory.cleanup_battle(self)
    aai_memory_pbEndOfBattle
  end
end

class Battle::Battler
  alias_method :aai_memory_pbFindUser, :pbFindUser unless method_defined?(:aai_memory_pbFindUser) || private_method_defined?(:aai_memory_pbFindUser)
  def pbFindUser(choice, move)
    AdvancedAI::MoveMemory.remember_move(@battle, self, move) if move
    aai_memory_pbFindUser(choice, move)
  end
end

module AdvancedAI
  def self.get_memory(battle, battler)
    MoveMemory.get_memory(battle, battler)
  end

  def self.knows_move?(battle, battler, move_id)
    MoveMemory.knows_move?(battle, battler, move_id)
  end

  def self.has_priority_move?(battle, battler)
    MoveMemory.has_priority_move?(battle, battler)
  end

  def self.has_healing_move?(battle, battler)
    MoveMemory.has_healing_move?(battle, battler)
  end

  def self.has_setup_move?(battle, battler)
    MoveMemory.has_setup_move?(battle, battler)
  end

  def self.strongest_known_move(battle, battler)
    MoveMemory.strongest_known_move(battle, battler)
  end

  def self.max_known_damage(battle, attacker, defender)
    MoveMemory.max_known_damage(battle, attacker, defender)
  end

  def self.last_move(battle, battler)
    MoveMemory.last_move(battle, battler)
  end

  def self.move_frequency(battle, battler, move_id)
    MoveMemory.move_frequency(battle, battler, move_id)
  end
end

AdvancedAI.log("Move Memory System loaded (Reborn-inspired)", "Memory")

class Battle::AI
  def apply_move_memory(score, move, user, target)
    return score unless move && target

    freq = AdvancedAI.move_frequency(@battle, user, move.id)
    skill = @_resolved_skill || @trainer&.skill || 100
    if AdvancedAI.tier_feature(skill, :learn_patterns) && freq >= 3
      score -= 10  # Slight penalty for using same move 3+ times
    end

    if AdvancedAI.has_priority_move?(@battle, target)
      if AdvancedAI.protect_move?(move.id)
        score += 10  # Protect is good against priority users
      end
    end

    if AdvancedAI.has_healing_move?(@battle, target)
      if move.damagingMove? && AdvancedAI::CombatUtilities.resolve_move_power(move) < 60
        score -= 10  # Weak attacks get outhealed
      end
      if AdvancedAI.setup_move?(move.id)
        score += 5  # Setup to overpower healing
      end
    end

    return score
  end
end

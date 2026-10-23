# Advanced AI System - Terastallization Intelligence (DBK_006 Integration)
# Strategic Tera Timing and Type Advantage Analysis

class Battle::AI
  def should_terastallize?(user, skill)
    uname = user.respond_to?(:battler) ? user.battler.name : user.name
    AdvancedAI.log("should_terastallize? called for #{uname} (skill #{skill})", "Tera")

    unless skill >= 100
      AdvancedAI.log("  ❌ Skill too low (#{skill} < 100)", "Tera")
      return false
    end

    unless AdvancedAI.dbk_enabled?(:terastallization)
      AdvancedAI.log("  ❌ Terastallization not enabled", "Tera")
      return false
    end

    unless @battle.pbCanTerastallize?(user.index)
      AdvancedAI.log("  ❌ @battle.pbCanTerastallize? returned false", "Tera")
      return false
    end

    if user.tera?
      AdvancedAI.log("  ❌ Already Terastallized", "Tera")
      return false
    end

    score = calculate_tera_score(user, skill)

    if @battle.wildBattle?
      score += 10
      AdvancedAI.log("  Wild Pokemon Tera bonus: +10", "Tera")
    end

    AdvancedAI.log("Tera score for #{user.pbThis}: #{score}", "Tera")

    return true if score >= 80   # Emergency/Guaranteed value
    return true if score >= 60   # Strong Situation
    return true if score >= 40 && remaining_pokemon_count(user) <= 2  # Good + few remaining

    return false
  end

  private

  def calculate_tera_score(user, skill)
    score = 0

    score += evaluate_tera_timing(user, skill)

    score += evaluate_tera_type_advantage(user, skill)

    score += evaluate_tera_sweep(user, skill)

    score += evaluate_tera_survival(user, skill)

    score += evaluate_tera_party(user, skill)

    score += evaluate_tera_momentum(user, skill)

    return score
  end

  def evaluate_tera_timing(user, skill)
    score = 0
    turn = @battle.turnCount

    if turn <= 2
      score += 10
    elsif turn <= 6
      score += 20
    else
      score += 15
    end

    alive = remaining_pokemon_count(user)
    score -= 10 if alive >= 5  # Too early
    score += 10 if alive <= 2  # Critical

    return score
  end

  def evaluate_tera_type_advantage(user, skill)
    score = 0
    tera_type = user.tera_type

    return 0 unless tera_type

    if tera_type == :STELLAR
      move_types = user.moves.select { |m| m && m.damagingMove? }.map { |m|
        AdvancedAI::CombatUtilities.resolve_move_type(user, m)
      }.uniq
      current_types = user.pbTypes(true) rescue []

      score += [move_types.length * 5, 20].min

      @battle.allOtherSideBattlers(user.index).each do |target|
        next unless target && !target.fainted?
        move_types.each do |mtype|
          type_mod = Effectiveness.calculate(mtype, *target.pbTypes(true))
          score += 5 if Effectiveness.super_effective?(type_mod)
        end
      end

      return [score, 40].min
    end

    current_types = user.pbTypes(true) rescue []
    user.moves.each do |move|
      next unless move && move.damagingMove?
      resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
      if resolved_type == tera_type
        score += 15

        @battle.allOtherSideBattlers(user.index).each do |target|
          next unless target && !target.fainted?

          type_mod = Effectiveness.calculate(tera_type, *target.pbTypes(true))
          score += 10 if Effectiveness.super_effective?(type_mod)
        end
      elsif current_types.include?(resolved_type) && resolved_type != tera_type
        score -= 10
      end
    end

    @battle.allOtherSideBattlers(user.index).each do |target|
      next unless target && !target.fainted?

      target.moves.each do |move|
        next unless move && move.damagingMove?

        resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, move)
        current_mod = Effectiveness.calculate(resolved_type, *user.pbTypes(true))
        tera_mod = Effectiveness.calculate(resolved_type, tera_type)

        if Effectiveness.super_effective?(current_mod) && Effectiveness.not_very_effective?(tera_mod)
          score += 25  # Turns Weakness into Resistance
        elsif Effectiveness.super_effective?(current_mod) && tera_mod == Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
          score += 15  # Neutralizes Weakness
        end
      end
    end

    return [score, 40].min
  end

  def evaluate_tera_sweep(user, skill)
    score = 0

    positive_boosts = user.stages.values.count { |stage| stage > 0 }
    if positive_boosts >= 3
      score += 20
    elsif positive_boosts >= 1
      score += 10
    end

    hp_percent = user.hp.to_f / user.totalhp
    score += 15 if hp_percent > 0.7
    score += 10 if hp_percent > 0.5

    user_tera_type = user.tera_type  # Cache once — avoid shadowing outer tera_type variable
    weak_to_tera = 0
    unless user_tera_type == :STELLAR
      weak_to_tera = @battle.allOtherSideBattlers(user.index).count do |target|
        next false unless target && !target.fainted?
        next false unless user_tera_type

        type_mod = Effectiveness.calculate(user_tera_type, *target.pbTypes(true))
        Effectiveness.super_effective?(type_mod)
      end
    end
    score += weak_to_tera * 8

    alive_enemies = alive_enemies_count(user)
    if alive_enemies <= 2 && positive_boosts >= 2
      score += 15  # Can end game
    end

    return [score, 35].min
  end

  def evaluate_tera_survival(user, skill)
    score = 0
    hp_percent = user.hp.to_f / user.totalhp
    tera_type = user.tera_type

    return 0 unless tera_type

    return 0 if tera_type == :STELLAR

    if hp_percent < 0.3
      score += 30
    elsif hp_percent < 0.5
      score += 15
    end

    imminent_ko = false
    @battle.allOtherSideBattlers(user.index).each do |target|
      next unless target && !target.fainted?

      target.moves.each do |move|
        next unless move && move.damagingMove?

        current_damage = calculate_rough_damage(move, target, user)
        if current_damage >= user.hp
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, move)
          tera_mod = Effectiveness.calculate(resolved_type, tera_type)
          if Effectiveness.not_very_effective?(tera_mod) || Effectiveness.ineffective?(tera_mod)
            score += 45  # Tera saves
            imminent_ko = true
            break
          end
        end
      end
      break if imminent_ko
    end

    if remaining_pokemon_count(user) == 1
      score += 20  # Last Pokemon
    end

    return [score, 45].min
  end

  def evaluate_tera_party(user, skill)
    score = 0
    party = @battle.pbParty(user.index & 1)

    better_candidates = party.count do |pkmn|
      next false if !pkmn || pkmn.fainted? || pkmn.egg?
      next false unless pkmn.tera_type

      pkmn.attack > user.attack || pkmn.spatk > user.spatk
    end

    if better_candidates > 0
      score -= [better_candidates * 10, 25].min
    end

    alive = remaining_pokemon_count(user)
    score += 15 if alive == 1

    return score
  end

  def evaluate_tera_momentum(user, skill)
    score = 0

    if user_has_momentum?(user)
      score += 10
    end

    @battle.allOtherSideBattlers(user.index).each do |target|
      next unless target && !target.fainted?

      if target.hp < target.totalhp * 0.4
        score += 8  # Finishing blow
      end
    end

    hp_disadvantage = user.hp.to_f / user.totalhp < 0.5
    enemy_advantage = @battle.allOtherSideBattlers(user.index).all? { |b|
      b && !b.fainted? && b.hp > b.totalhp * 0.6
    }

    score += 15 if hp_disadvantage && enemy_advantage

    return [score, 25].min
  end
end

# Keep DBK's implementations and only provide fallbacks when they are absent.
class Battle::Battler
  unless method_defined?(:can_terastallize?)
    def can_terastallize?
      return false unless @battle.respond_to?(:pbCanTerastallize?)
      return @battle.pbCanTerastallize?(@index)
    end
  end

  unless method_defined?(:tera?)
    def tera?
      return false unless @pokemon && @pokemon.respond_to?(:tera?)
      @pokemon.tera?
    end
  end

  unless method_defined?(:tera_type)
    def tera_type
      return nil unless @pokemon && @pokemon.respond_to?(:tera_type)
      @pokemon.tera_type
    end
  end
end

class Battle::AI::AIBattler
  def tera?
    return @battler.tera? if @battler.respond_to?(:tera?)
    return false
  end

  def tera_type
    return @battler.tera_type if @battler.respond_to?(:tera_type)
    return nil
  end
end

AdvancedAI.log("Terastallization Intelligence loaded (DBK_006)", "Tera")

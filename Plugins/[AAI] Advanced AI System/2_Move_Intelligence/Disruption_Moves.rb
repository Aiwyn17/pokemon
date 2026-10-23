# Advanced AI System - Disruption Move Intelligence

class Battle::AI

  alias_method :disruption_pbRegisterMove, :pbRegisterMove unless method_defined?(:disruption_pbRegisterMove) || private_method_defined?(:disruption_pbRegisterMove)
  def pbRegisterMove(user, move)
    score = disruption_pbRegisterMove(user, move)

    return score unless user && move

    targets = @_resolved_target ? [@_resolved_target] : @battle.allOtherSideBattlers(user.index)
    viable_targets = targets.select { |t| t && !t.fainted? && t.opposes?(user) }

    # Single-target disruption: use best (max) target score, not sum
    if move.id == :TAUNT
      best = viable_targets.map { |t| evaluate_taunt_value(user, t) }.max || 0
      score += best
    end

    if move.id == :ENCORE
      best = viable_targets.map { |t| evaluate_encore_value(user, t) }.max || 0
      score += best
    end

    if move.id == :KNOCKOFF
      best = viable_targets.map { |t| evaluate_knockoff_value(user, t) }.max || 0
      score += best
    end

    if [:TRICK, :SWITCHEROO].include?(move.id)
      best = viable_targets.map { |t| evaluate_trick_value(user, t, move) }.max || 0
      score += best
    end

    return score
  end

  def aai_disruption_fails?(id, user, target)
    preview = @battle.clone
    move = Battle::Move.from_pokemon_move(preview, Pokemon::Move.new(id))
    preview.moldBreaker = AdvancedAI::Utilities.ignores_ability?(user, move, target)
    move.pbFailsAgainstTarget?(user, target, false)
  end

  def evaluate_taunt_value(user, target)
    return -90 if aai_disruption_fails?(:TAUNT, user, target)
    score = 0

    # Don't use if target already taunted
    if target.effects[PBEffects::Taunt] > 0
      AdvancedAI.log("  Taunt blocked: Already taunted", "Disruption")
      return -90
    end

    status_moves = target.moves.count { |m| m && m.statusMove? }

    if status_moves == 0
      score -= 50  # Useless
      AdvancedAI.log("  Taunt: -50 (no status moves)", "Disruption")
      return score
    end

    setup_moves = [:SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :QUIVERDANCE, :CALMMIND,
                   :SHELLSMASH, :COIL, :BULKUP, :AGILITY, :ROCKPOLISH,
                   :VICTORYDANCE, :FILLETAWAY, :TIDYUP, :SHIFTGEAR, :NORETREAT,
                   :CLANGOROUSSOUL, :GEOMANCY]
    has_setup = target.moves.any? { |m| m && setup_moves.include?(m.id) }

    if has_setup
      score += 60
      AdvancedAI.log("  Taunt vs setup: +60 (blocks sweep)", "Disruption")

      if target.stages.values.any? { |stage| stage > 0 }
        score += 40
        AdvancedAI.log("  Already boosted: +40 (stop snowball)", "Disruption")
      end
    end

    recovery_moves = [:RECOVER, :ROOST, :SOFTBOILED, :WISH, :REST, :SLACKOFF,
                     :MOONLIGHT, :SYNTHESIS, :MORNINGSUN, :SHOREUP, :STRENGTHSAP,
                     :LIFEDEW, :MILKDRINK, :HEALORDER, :JUNGLEHEALING, :LUNARBLESSING]
    has_recovery = target.moves.any? { |m| m && recovery_moves.include?(m.id) }

    if has_recovery
      score += 45
      AdvancedAI.log("  Taunt vs wall: +45 (blocks recovery)", "Disruption")
    end

    hazard_moves = [:STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB]
    has_hazards = target.moves.any? { |m| m && hazard_moves.include?(m.id) }

    if has_hazards
      score += 35
      AdvancedAI.log("  Taunt vs hazard setter: +35", "Disruption")
    end

    if target.moves.any? { |m| m && m.id == :SUBSTITUTE }
      score += 30
      AdvancedAI.log("  Taunt vs Substitute: +30", "Disruption")
    end

    status_inflict = [:THUNDERWAVE, :WILLOWISP, :TOXIC, :SLEEPPOWDER, :SPORE]
    has_status = target.moves.any? { |m| m && status_inflict.include?(m.id) }

    if has_status
      score += 20
      AdvancedAI.log("  Taunt vs status: +20", "Disruption")
    end

    tr_active = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
    user_moves_first = tr_active ? (user.pbSpeed * 1.3 < target.pbSpeed) : (user.pbSpeed > target.pbSpeed * 1.3)
    if user_moves_first
      score += 15
      AdvancedAI.log("  Outspeeds: +15 (locks them in)", "Disruption")
    end

    return score
  end

  def evaluate_encore_value(user, target)
    return -90 if aai_disruption_fails?(:ENCORE, user, target)
    score = 0

    # Don't use if target already Encored
    if target.effects[PBEffects::Encore] > 0
      AdvancedAI.log("  Encore blocked: Already encored", "Disruption")
      return -90
    end

    last_move = target.lastRegularMoveUsed
    return -80 unless last_move  # No move used yet

    last_move_data = GameData::Move.try_get(last_move)
    return -80 unless last_move_data

    setup_moves = [:SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :SHELLSMASH, :CALMMIND,
                   :QUIVERDANCE, :BULKUP, :AGILITY, :ROCKPOLISH, :COIL,
                   :VICTORYDANCE, :FILLETAWAY, :TIDYUP, :SHIFTGEAR, :NORETREAT,
                   :CLANGOROUSSOUL, :GEOMANCY]
    if setup_moves.include?(last_move)
      setup = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(last_move))
      stats = setup.respond_to?(:statUp) ? setup.statUp.each_slice(2).map(&:first) : [:ATTACK, :SPECIAL_ATTACK]
      if target.hasActiveAbility?(:CONTRARY)
        stats = setup.respond_to?(:statDown) ? setup.statDown.each_slice(2).map(&:first) : []
      end
      opp_max_off_stage = stats.empty? ? 6 : stats.map { |stat| target.stages[stat] || 0 }.min

      if opp_max_off_stage >= 5
        score += 80
        AdvancedAI.log("  Encore setup move at max boosts: +80 (waste turns)", "Disruption")
      elsif opp_max_off_stage >= 3
        if user.moves.any? { |m| m && [:ROAR, :WHIRLWIND, :DRAGONTAIL, :CIRCLETHROW, :HAZE].include?(m.id) }
          score += 50
          AdvancedAI.log("  Encore setup at +#{opp_max_off_stage} with phaze: +50", "Disruption")
        else
          score -= 20
          AdvancedAI.log("  Encore setup at +#{opp_max_off_stage} no phaze: -20 (lets them max out!)", "Disruption")
        end
      else
        score -= 40
        AdvancedAI.log("  Encore setup at +#{opp_max_off_stage}: -40 (lets them sweep!)", "Disruption")
      end

      if opp_max_off_stage >= 5 && user.moves.any? { |m| m && setup_moves.include?(m.id) }
        score += 30
        AdvancedAI.log("  Can counter-setup while they're capped: +30", "Disruption")
      end
    elsif last_move_data.power == 0  # status move (GameData::Move has no .statusMove?)
      score += 50
      AdvancedAI.log("  Encore status move: +50 (free turns)", "Disruption")
    end

    encore_resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, last_move_data)
    if last_move_data.power > 0  # damaging move (GameData::Move has no .damagingMove?)
      type_mod = Effectiveness.calculate(encore_resolved_type, *user.pbTypes(true))
      if Effectiveness.not_very_effective?(type_mod)
        score += 40
        AdvancedAI.log("  Encore resisted move: +40", "Disruption")
      elsif Effectiveness.ineffective?(type_mod)
        score += 70
        AdvancedAI.log("  Encore immune move: +70 (free turns!)", "Disruption")
      end
    end

    weak_moves = [:SPLASH, :CELEBRATE, :TELEPORT]
    if weak_moves.include?(last_move)
      score += 90
      AdvancedAI.log("  Encore useless move: +90 (jackpot!)", "Disruption")
    end

    # PENALTY: Don't Encore strong super-effective moves
    if last_move_data.power > 0  # damaging move — use .power > 0 (GameData::Move has no .damagingMove?)
      type_mod = Effectiveness.calculate(encore_resolved_type, *user.pbTypes(true))
      if Effectiveness.super_effective?(type_mod)
        score -= 40
        AdvancedAI.log("  Encore SE move: -40 (bad idea)", "Disruption")
      end
    end

    return score
  end

  def evaluate_knockoff_value(user, target)
    score = 0

    unless target.item
      AdvancedAI.log("  Knock Off: No item (still 65 BP)", "Disruption")
      return 0  # Base damage is fine
    end

    item_id = target.item_id

    return 0 if target.unlosableItem?(target.item)
    move = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(:KNOCKOFF))
    power_bonus = Settings::MECHANICS_GENERATION >= 6 ? 20 : 0
    if (target.hasActiveAbility?(:STICKYHOLD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)) ||
       (target.effects[PBEffects::Substitute] > 0 && !move.ignoresSubstitute?(user))
      return power_bonus
    end

    choice_items = [:CHOICEBAND, :CHOICESCARF, :CHOICESPECS]
    if choice_items.include?(item_id)
      score += 70
      AdvancedAI.log("  Knock Off Choice item: +70 (unlocks moves)", "Disruption")
    end

    defensive_items = [:LEFTOVERS, :ASSAULTVEST, :ROCKYHELMET, :EVIOLITE, :HEAVYDUTYBOOTS]
    if defensive_items.include?(item_id)
      score += 50
      AdvancedAI.log("  Knock Off defensive item: +50", "Disruption")

      if item_id == :EVIOLITE
        nfe = false
        begin
          evos = target.pokemon&.species_data&.get_evolutions(true)
          nfe = evos && !evos.empty?
        rescue
          nfe = true  # Conservative: assume active if we can't tell
        end
        if nfe
          score += 30
          AdvancedAI.log("  Eviolite removal: +30 (cuts bulk on NFE)", "Disruption")
        else
          AdvancedAI.log("  Eviolite removal: no NFE bonus (fully evolved holder)", "Disruption")
        end
      end

      if item_id == :HEAVYDUTYBOOTS
        target_side = target.pbOwnSide
        if target_side.effects[PBEffects::StealthRock] || target_side.effects[PBEffects::Spikes] > 0
          score += 40
          AdvancedAI.log("  Boots removal (hazards up): +40", "Disruption")
        end
      end
    end

    offensive_items = [:LIFEORB, :EXPERTBELT, :WISEGLASSES, :MUSCLEBAND]
    if offensive_items.include?(item_id)
      score += 45
      AdvancedAI.log("  Knock Off offensive item: +45", "Disruption")
    end

    if item_id == :FOCUSSASH && target.hp == target.totalhp
      score += 60
      AdvancedAI.log("  Knock Off Focus Sash: +60 (removes survival)", "Disruption")
    end

    if item_id == :WEAKNESSPOLICY
      score += 35
      AdvancedAI.log("  Knock Off Weakness Policy: +35", "Disruption")
    end

    if GameData::Item.try_get(item_id)&.is_berry?
      score += 25
      AdvancedAI.log("  Knock Off Berry: +25", "Disruption")
    end

    score += power_bonus
    AdvancedAI.log("  Knock Off damage boost: +20 (97.5 BP)", "Disruption")

    return score
  end

  def evaluate_trick_value(user, target, move = nil)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    move = move.move if move && move.respond_to?(:move)
    return 0 if move && !AdvancedAI::WinConditions.move_available?(user, move)
    move ||= Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(:TRICK))
    return -90 if target.effects[PBEffects::Substitute] > 0 && !move.ignoresSubstitute?(user)
    return -90 if AdvancedAI::Utilities.counter_priority_blocked?(@battle, move, user, target)
    return -90 if AdvancedAI::Utilities.counter_shield_blocked?(@battle, move, user, target)
    preview = @battle.clone
    native = Battle::Move.from_pokemon_move(preview, Pokemon::Move.new(move.id))
    native.calcType = native.pbCalcType(user)
    preview.moldBreaker = AdvancedAI::Utilities.ignores_ability?(user, native, target)
    return -90 if native.pbImmunityByAbility(user, target, false)
    score = 0
    user_item = user.item_id
    target_item = target.item_id

    return -80 unless user_item || target_item
    return -90 if user.wild? || native.pbFailsAgainstTarget?(user, target, false)
    return 0 if user_item == target_item
    recipient = target.clone
    recipient.instance_variable_set(:@pokemon, target.pokemon.clone)
    recipient.item = user_item
    receiver = user.clone
    receiver.instance_variable_set(:@pokemon, user.pokemon.clone)
    receiver.item = target_item

    choice_items = [:CHOICEBAND, :CHOICESCARF, :CHOICESPECS]
    if choice_items.include?(user_item) && recipient.hasActiveItem?(user_item)
      status_moves = target.moves.count { |m| m && m.statusMove? }

      if status_moves >= 2
        score += 80
        AdvancedAI.log("  Trick Choice item: +80 (cripples support)", "Disruption")
      elsif status_moves >= 1
        score += 50
        AdvancedAI.log("  Trick Choice item: +50", "Disruption")
      end

      recovery_moves = [:RECOVER, :ROOST, :SOFTBOILED, :WISH, :REST, :SLACKOFF,
                       :MOONLIGHT, :SYNTHESIS, :MORNINGSUN, :SHOREUP, :STRENGTHSAP,
                       :LIFEDEW, :MILKDRINK, :HEALORDER, :JUNGLEHEALING, :LUNARBLESSING]
      if target.moves.any? { |m| m && recovery_moves.include?(m.id) }
        score += 40
        AdvancedAI.log("  Trick vs wall: +40 (limits options)", "Disruption")
      end
    end

    if [:LAGGINGTAIL, :IRONBALL].include?(user_item) && recipient.hasActiveItem?(user_item)
      score += 60
      AdvancedAI.log("  Trick speed item: +60 (cripples speed)", "Disruption")
    end

    if target_item
      valuable_items = [:LEFTOVERS, :LIFEORB, :CHOICEBAND, :CHOICESCARF, :CHOICESPECS,
                       :ASSAULTVEST, :FOCUSSASH, :WEAKNESSPOLICY]
      if valuable_items.include?(target_item) && receiver.hasActiveItem?(target_item)
        score += 50
        AdvancedAI.log("  Trick steal valuable: +50", "Disruption")
      end
    end

    # PENALTY: Don't give away our own valuable items
    if user_item && !choice_items.include?(user_item)
      valuable_items = [:LEFTOVERS, :LIFEORB, :ASSAULTVEST, :FOCUSSASH]
      if valuable_items.include?(user_item) && user.hasActiveItem?(user_item)
        score -= 40
        AdvancedAI.log("  Trick lose valuable: -40", "Disruption")
      end
    end

    return score
  end
end

AdvancedAI.log("Disruption Move Intelligence loaded", "Core")
AdvancedAI.log("  - Taunt (blocks setup/support)", "Disruption")
AdvancedAI.log("  - Encore (locks into moves)", "Disruption")
AdvancedAI.log("  - Knock Off (item removal)", "Disruption")
AdvancedAI.log("  - Trick/Switcheroo (item swap)", "Disruption")

# Advanced AI System - Move Scorer

class PriorityMoveResult
  attr_reader :auto_select, :priority_boost

  def initialize(auto_select: false, priority_boost: 0)
    @auto_select = auto_select
    @priority_boost = priority_boost
  end

  def auto_select?
    @auto_select
  end

  def boost_value
    @auto_select ? 0 : @priority_boost
  end
end

class Battle::AI
  alias_method :aai_command_set_up_move_check, :set_up_move_check unless method_defined?(:aai_command_set_up_move_check)
  def set_up_move_check(move)
    @aai_command_move = move
    aai_command_set_up_move_check(move)
  end

  def get_tera_type_for_move(user)
    battler = user.respond_to?(:battler) ? user.battler : user
    if battler.respond_to?(:tera?) && battler.tera?
      return battler.pokemon.tera_type if battler.pokemon.respond_to?(:tera_type) && battler.pokemon.tera_type
    end
    if @battle.respond_to?(:pbRegisteredTerastallize?) && @battle.pbRegisteredTerastallize?(user.index)
      return battler.pokemon.tera_type if battler.pokemon.respond_to?(:tera_type) && battler.pokemon.tera_type
    end
    nil
  end

  def pbRegisterMove(user, move)
    return 0 unless move && user
    # Use pre-resolved target/skill from pbGetMoveScore pipeline if available,
    # otherwise fall back to finding first valid opponent and default skill.
    target = @_resolved_target || @battle.allOtherSideBattlers(user.index).find { |b| b && !b.fainted? }
    return 0 unless target
    skill = @_resolved_skill || 100
    score_move_advanced(move, user, target, skill)
  end

  def score_move_advanced(move, user, target, skill)
    return 0 unless move && user

    # Side/field-targeting moves (Stealth Rock, Spikes, Reflect, Light Screen, etc.)
    # are called without a target. Pick a fallback opponent for scoring context.
    if target.nil?
      target = @battle.allOtherSideBattlers(user.index).find { |b| b && !b.fainted? }
      return 0 unless target
    end

    if move.function_code == "HealUserByHalfOfDamageDoneIfTargetAsleep" &&
       target.status != :SLEEP && !target.hasActiveAbility?(:COMATOSE)
      return -1000
    end

    if move.pp == 0 && move.total_pp > 0
      return -1000
    end

    if move.statusMove? && user.hasActiveItem?(:ASSAULTVEST) &&
       move.function_code != "UseMoveTargetIsAboutToUse"
      return -1000  # Assault Vest blocks all status moves
    end

    if user.effects[PBEffects::ChoiceBand] && user.effects[PBEffects::ChoiceBand] != move.id &&
       user.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF])
      return -1000  # Can't use any other move when Choice-locked
    end

    if user.respond_to?(:hasActiveAbility?) && user.hasActiveAbility?(:GORILLATACTICS)
      if user.effects[PBEffects::ChoiceBand] && user.effects[PBEffects::ChoiceBand] != move.id
        return -1000  # Gorilla Tactics move lock
      end
    end

    command_move = move
    if move.equal?(@move) && @aai_command_move && @aai_command_move.callsAnotherMove?
      command_move = @aai_command_move
    end
    if user.effects[PBEffects::Encore] > 0 && user.effects[PBEffects::EncoreMove]
      return -1000 if command_move.id != user.effects[PBEffects::EncoreMove]
    end

    if user.effects[PBEffects::Disable] > 0 && user.effects[PBEffects::DisableMove]
      return -1000 if command_move.id == user.effects[PBEffects::DisableMove]
    end

    if user.effects[PBEffects::Taunt] > 0 && move.statusMove?
      return -1000
    end

    fc = move.function_code.to_s rescue ""
    if fc.include?("UserFaints") || [:EXPLOSION, :SELFDESTRUCT, :MISTYEXPLOSION, :FINALGAMBIT].include?(move.id)
      remaining = @battle.pbAbleCount(user.index & 1) rescue 1
      hp_pct = user.hp.to_f / [user.totalhp, 1].max
      selfko_penalty = 0
      if remaining > 1
        # Heavy penalty when we have reserves — don't throw away a Pokemon
        selfko_penalty -= 150
        selfko_penalty += 60 if hp_pct < 0.2
        selfko_penalty += 30 if hp_pct < 0.35
      elsif hp_pct > 0.5
        selfko_penalty -= 80
      end
      selfko_penalty -= 60 if move.id == :FINALGAMBIT && hp_pct < 0.3
      return selfko_penalty
    end

    # Heal Block: Can't use healing moves (includes drain moves in Gen 5+)
    if user.effects[PBEffects::HealBlock] > 0
      healing_moves = [:RECOVER, :SOFTBOILED, :ROOST, :SLACKOFF, :MOONLIGHT, :MORNINGSUN,
                       :SYNTHESIS, :WISH, :SHOREUP, :LIFEDEW, :JUNGLEHEALING, :LUNARBLESSING,
                       :PURIFY, :MILKDRINK, :HEALORDER, :REST, :STRENGTHSAP, :FLORALHEALING,
                       :LEECHLIFE, :GIGADRAIN, :DRAININGKISS, :DRAINPUNCH, :HORNLEECH,
                       :OBLIVIONWING, :PARABOLICCHARGE, :ABSORB, :MEGADRAIN,
                       :BITTERBLADE, :STRENGTHSAP]
      return -1000 if healing_moves.include?(move.id)
    end

    # Imprison: Can't use moves the opponent has imprisoned
    @battle.allOtherSideBattlers(user.index).each do |opp|
      next unless opp && !opp.fainted?
      if opp.effects[PBEffects::Imprison]
        opp.moves.each do |opp_move|
          return -1000 if opp_move && opp_move.id == move.id
        end
      end
    end

    # Torment: Can't use the same move twice in a row
    if user.effects[PBEffects::Torment] && user.lastMoveUsed == move.id
      return -1000
    end

    if [:FAKEOUT, :FIRSTIMPRESSION].include?(move.id) && user.turnCount > 0
      return -1000  # These moves fail after turn 1
    end

    # Throat Chop: Can't use sound moves
    if user.effects[PBEffects::ThroatChop] > 0 && move.soundMove?
      return -1000
    end

    # Gravity: Can't use airborne moves
    if @battle.field.effects[PBEffects::Gravity] > 0
      gravity_blocked = [:FLY, :BOUNCE, :SKYDROP, :MAGNETRISE, :TELEKINESIS, :HIGHJUMPKICK, :JUMPKICK, :FLYINGPRESS]
      return -1000 if gravity_blocked.include?(move.id)
    end

    if [:ROAR, :WHIRLWIND].include?(move.id) &&
       !AdvancedAI::Utilities.phazing_possible?(@battle, move, user, target)
      return -1000
    end

    ally_only_moves = [:HEALPULSE, :AFTERYOU, :AROMATICMIST,
                       :HELPINGHAND, :COACHING, :FLORALHEALING]
    if ally_only_moves.include?(move.id) && target
      same_side = (user.index & 1) == (target.index & 1)
      unless same_side
        return -1000  # Never use ally-support moves on opponents
      end
    end

    if AdvancedAI::Utilities.prankster_blocked?(user, target, move)
      return -1000  # Prankster status move blocked by Dark type
    end

    # Magic Bounce: Use the engine's reflection flag instead of a partial move
    # list. Targetless moves (entry hazards) can be bounced by any active foe.
    target_data = move.pbTarget(user) rescue nil
    can_be_bounced = move.statusMove? && (move.move.canMagicCoat? rescue false)
    if can_be_bounced && target_data
      bouncer = nil
      if target_data.num_targets == 0
        bouncer = @battle.allOtherSideBattlers(user.index).find { |b|
          b && !b.fainted? && b.hasActiveAbility?(:MAGICBOUNCE) &&
            !AdvancedAI::Utilities.ignores_ability?(user, move, b)
        }
      elsif target_data.num_targets == 1 && target.opposes?(user) &&
            target.hasActiveAbility?(:MAGICBOUNCE) &&
            !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        bouncer = target
      end
      if bouncer
        AdvancedAI.log("#{move.name} bounced by Magic Bounce on #{bouncer.name}", "Ability")
        return -1000
      end
    end

    # Good as Gold only blocks status moves directed at its bearer. Side, field
    # and self moves merely use an opponent as scoring context and must stay valid.
    if move.statusMove? && target_data && target_data.num_targets == 1 &&
       target.index != user.index && target.hasActiveAbility?(:GOODASGOLD) &&
       !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      AdvancedAI.log("#{move.name} blocked by Good as Gold on #{target.name}", "Ability")
      return -1000
    end

    # Status-inflicting moves: Don't use if target already has a status condition
    # Only pure status moves belong here — damaging moves with side-effect status
    # (Scald, Flare Blitz, Body Slam, etc.) should not be penalized -1000
    status_moves = {
      :THUNDERWAVE => :PARALYSIS,
      :STUNSPORE => :PARALYSIS,
      :GLARE => :PARALYSIS,
      :TOXIC => :POISON,
      :POISONPOWDER => :POISON,
      :POISONGAS => :POISON,
      :WILLOWISP => :BURN,
      :SLEEPPOWDER => :SLEEP,
      :SPORE => :SLEEP,
      :HYPNOSIS => :SLEEP,
      :DARKVOID => :SLEEP,
      :GRASSWHISTLE => :SLEEP,
      :LOVELYKISS => :SLEEP,
      :SING => :SLEEP
    }

    if status_moves.key?(move.id)
      if target.status != :NONE
        AdvancedAI.log("#{move.name} blocked: #{target.name} already has #{target.status}", "StatusSpam")
        return -1000  # Can't inflict status on already-statused Pokemon
      end

      if target.pbOwnSide.effects[PBEffects::Safeguard] > 0
        AdvancedAI.log("#{move.name} blocked: Safeguard active on #{target.name}'s side", "StatusSpam")
        return -1000  # Safeguard blocks status
      end

      if @battle.field.terrain == :Misty
        if !target.airborne? && !target.hasActiveAbility?(:LEVITATE)
          AdvancedAI.log("#{move.name} blocked: #{target.name} protected by Misty Terrain", "StatusSpam")
          return -1000  # Misty Terrain prevents status for grounded
        end
      end

      if @battle.field.terrain == :Electric && status_moves[move.id] == :SLEEP
        if !target.airborne? && !target.hasActiveAbility?(:LEVITATE)
          AdvancedAI.log("#{move.name} blocked: #{target.name} protected by Electric Terrain", "StatusSpam")
          return -1000  # Electric Terrain prevents sleep for grounded
        end
      end

      if status_moves[move.id] == :SLEEP && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        sleep_immune = [:INSOMNIA, :VITALSPIRIT, :COMATOSE]
        if sleep_immune.any? { |a| target.hasActiveAbility?(a) }
          AdvancedAI.log("#{move.name} blocked: #{target.name} has #{target.ability_id} (sleep immune)", "StatusSpam")
          return -1000  # Sleep move will fail — ability prevents sleep
        end
        if @battle.allSameSideBattlers(target.index).any? { |b|
             b && !b.fainted? && b.hasActiveAbility?(:SWEETVEIL) }
          AdvancedAI.log("#{move.name} blocked: Sweet Veil protects #{target.name}'s side", "StatusSpam")
          return -1000  # Sweet Veil prevents sleep on the entire side
        end
      end

      if status_moves[move.id] == :PARALYSIS
        if target.hasActiveAbility?(:LIMBER) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
          AdvancedAI.log("#{move.name} blocked: #{target.name} has Limber", "StatusSpam")
          return -1000
        end
        if target.pbHasType?(:ELECTRIC)
          AdvancedAI.log("#{move.name} blocked: #{target.name} is Electric type (para immune)", "StatusSpam")
          return -1000
        end
      end

      if status_moves[move.id] == :BURN
        if target.pbHasType?(:FIRE)
          AdvancedAI.log("#{move.name} blocked: #{target.name} is Fire type (burn immune)", "StatusSpam")
          return -1000
        end
        burn_immune = [:WATERBUBBLE, :WATERVEIL, :THERMALEXCHANGE]
        if burn_immune.any? { |a| target.hasActiveAbility?(a) } && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
          AdvancedAI.log("#{move.name} blocked: #{target.name} has #{target.ability_id} (burn immune)", "StatusSpam")
          return -1000
        end
      end

      if status_moves[move.id] == :POISON
        if (target.pbHasType?(:POISON) || target.pbHasType?(:STEEL)) && !user.hasActiveAbility?(:CORROSION)
          AdvancedAI.log("#{move.name} blocked: #{target.name} is Poison/Steel type (poison immune)", "StatusSpam")
          return -1000
        end
        if target.hasActiveAbility?(:IMMUNITY) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
          AdvancedAI.log("#{move.name} blocked: #{target.name} has Immunity", "StatusSpam")
          return -1000
        end
      end

      if target.hasActiveAbility?(:LEAFGUARD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
         @battle && [:Sun, :HarshSun].include?(@battle.pbWeather)
        AdvancedAI.log("#{move.name} blocked: #{target.name} has Leaf Guard in Sun", "StatusSpam")
        return -1000
      end

      powder_moves = [:SLEEPPOWDER, :SPORE, :STUNSPORE, :POISONPOWDER]
      if powder_moves.include?(move.id)
        if target.pbHasType?(:GRASS)
          AdvancedAI.log("#{move.name} blocked: #{target.name} is Grass type (powder immune)", "StatusSpam")
          return -1000
        end
        if target.hasActiveAbility?(:OVERCOAT) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
          AdvancedAI.log("#{move.name} blocked: #{target.name} has Overcoat (powder immune)", "StatusSpam")
          return -1000
        end
        if target.hasActiveItem?(:SAFETYGOGGLES)
          AdvancedAI.log("#{move.name} blocked: #{target.name} has Safety Goggles (powder immune)", "StatusSpam")
          return -1000
        end
      end
    end

    # Leech Seed: Can't use on already seeded targets or Grass types
    if move.id == :LEECHSEED
      if target.effects[PBEffects::LeechSeed] >= 0
        AdvancedAI.log("Leech Seed blocked: #{target.name} already seeded", "RedundantMove")
        return -1000
      end
      return -1000 if target.pbHasType?(:GRASS)  # Grass types are immune
    end

    # Substitute: Don't use if we already have a substitute
    if move.id == :SUBSTITUTE
      if user.effects[PBEffects::Substitute] > 0
        AdvancedAI.log("Substitute blocked: #{user.name} already has Substitute", "RedundantMove")
        return -1000
      end
    end

    # Yawn: Don't use if target is already drowsy or asleep
    if move.id == :YAWN
      if target.effects[PBEffects::Yawn] > 0
        AdvancedAI.log("Yawn blocked: #{target.name} already drowsy", "RedundantMove")
        return -1000
      end
      if target.status == :SLEEP
        AdvancedAI.log("Yawn blocked: #{target.name} already asleep", "RedundantMove")
        return -1000
      end
    end

    # Taunt: Don't use if target is already taunted or has Mental Herb
    if move.id == :TAUNT
      if target.effects[PBEffects::Taunt] > 0
        AdvancedAI.log("Taunt blocked: #{target.name} already taunted", "RedundantMove")
        return -1000
      end
    end

    # Encore: Don't use if target is already encored
    if move.id == :ENCORE
      if target.effects[PBEffects::Encore] > 0
        AdvancedAI.log("Encore blocked: #{target.name} already encored", "RedundantMove")
        return -1000
      end
    end

    # Disable: Don't use if the target already has a move disabled
    if move.id == :DISABLE
      if target.effects[PBEffects::Disable] > 0
        AdvancedAI.log("Disable blocked: #{target.name} already has a disabled move", "RedundantMove")
        return -1000
      end
    end

    if [:TAUNT, :ENCORE, :DISABLE, :TORMENT].include?(move.id)
      if target.hasActiveItem?(:MENTALHERB)
        AdvancedAI.log("#{move.name} reduced value: #{target.name} has Mental Herb", "Item")
        return -50  # Not totally useless (consumes the herb) but far less valuable
      end
    end

    # Embargo: Don't use if target is already embargoed
    if move.id == :EMBARGO
      if target.effects[PBEffects::Embargo] > 0
        AdvancedAI.log("Embargo blocked: #{target.name} already embargoed", "RedundantMove")
        return -1000
      end
    end

    # Torment: Don't use if target is already tormented
    if move.id == :TORMENT
      if target.effects[PBEffects::Torment]
        AdvancedAI.log("Torment blocked: #{target.name} already tormented", "RedundantMove")
        return -1000
      end
    end

    # Ingrain: Don't use if we're already ingrained
    if move.id == :INGRAIN
      if user.effects[PBEffects::Ingrain]
        AdvancedAI.log("Ingrain blocked: #{user.name} already ingrained", "RedundantMove")
        return -1000
      end
    end

    # Aqua Ring: Don't use if we already have Aqua Ring
    if move.id == :AQUARING
      if user.effects[PBEffects::AquaRing]
        AdvancedAI.log("Aqua Ring blocked: #{user.name} already has Aqua Ring", "RedundantMove")
        return -1000
      end
    end

    # Screens: Don't use if already active on our side
    if move.id == :REFLECT
      if user.pbOwnSide.effects[PBEffects::Reflect] > 0
        AdvancedAI.log("Reflect blocked: already active", "ScreenSpam")
        return -1000
      end
    end

    if move.id == :LIGHTSCREEN
      if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
        AdvancedAI.log("Light Screen blocked: already active", "ScreenSpam")
        return -1000
      end
    end

    if move.id == :AURORAVEIL
      if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        AdvancedAI.log("Aurora Veil blocked: already active", "ScreenSpam")
        return -1000
      end
      unless [:Hail, :Snow].include?(@battle.pbWeather)
        AdvancedAI.log("Aurora Veil blocked: no Hail/Snow weather", "ScreenSpam")
        return -1000  # Aurora Veil fails without Hail or Snow
      end
    end

    # Hazards: Don't set if already at maximum layers
    if move.id == :STEALTHROCK
      if target.pbOwnSide.effects[PBEffects::StealthRock]
        AdvancedAI.log("Stealth Rock blocked: already active on opponent's side", "HazardSpam")
        return -1000
      end
    end

    if move.id == :SPIKES
      spikes_count = target.pbOwnSide.effects[PBEffects::Spikes]
      if spikes_count >= 3
        AdvancedAI.log("Spikes blocked: max 3 layers already active", "HazardSpam")
        return -1000  # Max 3 layers
      end
    end

    if move.id == :TOXICSPIKES
      toxic_spikes_count = target.pbOwnSide.effects[PBEffects::ToxicSpikes]
      if toxic_spikes_count >= 2
        AdvancedAI.log("Toxic Spikes blocked: max 2 layers already active", "HazardSpam")
        return -1000  # Max 2 layers
      end
    end

    if move.id == :STICKYWEB
      if target.pbOwnSide.effects[PBEffects::StickyWeb]
        AdvancedAI.log("Sticky Web blocked: already active on opponent's side", "HazardSpam")
        return -1000
      end
    end

    # Tailwind: Don't use if already active
    if move.id == :TAILWIND
      if user.pbOwnSide.effects[PBEffects::Tailwind] > 0
        AdvancedAI.log("Tailwind blocked: already active", "FieldSpam")
        return -1000
      end
    end

    # Trick Room: Don't use if already active (unless intentionally turning it off)
    if move.id == :TRICKROOM
      if @battle.field.effects[PBEffects::TrickRoom] > 0 && skill < 80
        AdvancedAI.log("Trick Room blocked: already active (low skill AI)", "FieldSpam")
        return -1000  # Low skill AI won't understand toggling
      end
    end

    # Wish: Don't use if we already have Wish coming
    # Wish is stored in position effects, not battler effects
    if move.id == :WISH
      wish_val = (@battle.positions[user.index].effects[PBEffects::Wish] rescue 0)
      return -1000 if wish_val.is_a?(Numeric) && wish_val > 0
    end

    # === PRIORITY TIER SYSTEM ===
    # Run this only after every hard failure/redundancy check. Auto-select must
    # never resurrect a move that the engine will reject or reflect.
    priority_result = check_priority_tier_moves(move, user, target, skill)
    if priority_result.is_a?(PriorityMoveResult) && priority_result.auto_select?
      final_score = 500 + priority_result.priority_boost
      AdvancedAI.log("#{move.name} AUTO-SELECTED (Tactical Priority): Score #{final_score}", "Priority")
      return final_score
    end
    priority_boost = priority_result.is_a?(PriorityMoveResult) ? priority_result.boost_value : 0

    base_score = 100  # Neutral Start

    @_score_factors = nil
    @_actual_base_score = 100  # Track the real base for debug display
    factors = AdvancedAI::DEBUG_MODE ? {} : nil

    status_multiplier = 1.0
    if move.statusMove?
      status_multiplier = AdvancedAI.tier_feature(skill, :status_value) || 1.0
      base_score = 100 + (20 * status_multiplier)
      @_actual_base_score = base_score
    end

    base_score += priority_boost
    if factors && priority_boost != 0
      factors["Priority Tier"] = priority_boost
    end

    # === TYPE-ABSORBING ABILITY CHECK ===
    # Don't attack into Water Absorb, Volt Absorb, Flash Fire, Sap Sipper, etc.
    if move.damagingMove?
      effective_move_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
      if move.id == :TERABLAST
        tera_type = get_tera_type_for_move(user)
        effective_move_type = tera_type if tera_type
      end
      absorption_penalty = AdvancedAI::Utilities.score_type_absorption_penalty(user, target, move, effective_move_type)
      if absorption_penalty < -100
        return absorption_penalty  # Heavy penalty - avoid this move
      end
      base_score += absorption_penalty

      if AdvancedAI::Utilities.bulletproof_immune?(user, target, move)
        return -200  # Ball/bomb move blocked
      end

      if AdvancedAI::Utilities.soundproof_immune?(user, target, move)
        return -200  # Sound move blocked
      end
    end

    if move.damagingMove?
      v = score_damage_potential(move, user, target, skill)
      base_score += v; factors["Damage Potential"] = v if factors && v != 0

      v = score_type_effectiveness(move, user, target)
      base_score += v; factors["Type Effectiveness"] = v if factors && v != 0

      v = score_stab_bonus(move, user)
      base_score += v; factors["STAB"] = v if factors && v != 0

      v = score_crit_potential(move, user, target)
      base_score += v; factors["Crit Potential"] = v if factors && v != 0

      if move.contactMove?
        v = score_contact_punishment(move, user, target)
        base_score -= v; factors["Contact Punishment"] = -v if factors && v != 0
      end
    end

    if move.statusMove?
      # Penalty for status moves when we have a KO-able target
      # (Don't waste a turn setting up or statusing when you can win right now)
      if target && skill >= 70
        has_ko_move = user.battler.moves.any? do |m|
          next false unless m && m.damagingMove? && m.pp > 0
          rough = (calculate_rough_damage(m, user, target) rescue 0)
          rough >= target.hp
        end
        if has_ko_move
          base_score -= 120  # Strong penalty: finishing the target is usually better
          factors["KO Available"] = -120 if factors
        end
      end
      v = score_status_utility(move, user, target, skill, status_multiplier)
      base_score += v; factors["Status Utility"] = v if factors && v != 0
    end

    if move.function_code.start_with?("RaiseUser") || AdvancedAI.setup_move?(move.id)
      v = score_setup_value(move, user, target, skill, status_multiplier)
      base_score += v; factors["Setup Value"] = v if factors && v != 0

      v = score_setup_vs_mirror_herb(move, user, target)
      base_score += v; factors["Mirror Herb Risk"] = v if factors && v != 0
    end

    v = score_priority(move, user, target)
    base_score += v; factors["Priority"] = v if factors && v != 0

    v = score_accuracy(move, skill, user)
    base_score += v; factors["Accuracy"] = v if factors && v != 0

    v = score_recoil_risk(move, user)
    base_score += v; factors["Recoil Risk"] = v if factors && v != 0

    v = score_secondary_effects(move, user, target)
    base_score += v; factors["Secondary Effects"] = v if factors && v != 0

    v = score_gen9_extras(move, user, target)
    base_score += v; factors["Gen 9 Extras"] = v if factors && v != 0

    v = score_moody_pressure(move, user, target)
    base_score += v; factors["Moody Pressure"] = v if factors && v != 0

    v = score_status_vs_berry(move, user, target)
    base_score += v; factors["Status vs Berry"] = v if factors && v != 0

    v = score_protect_utility(move, user, target)
    base_score += v; factors["Protect Utility"] = v if factors && v != 0

    v = score_prankster_bonus(move, user, target)
    base_score += v; factors["Prankster Bonus"] = v if factors && v != 0

    v = score_pivot_utility(move, user, target, skill)
    base_score += v; factors["Pivot Utility"] = v if factors && v != 0

    v = score_stall_synergy(move, user, target)
    base_score += v; factors["Stall Synergy"] = v if factors && v != 0

    v = score_role_synergy(move, user, target, skill)
    base_score += v; factors["Role Synergy"] = v if factors && v != 0

    v = score_move_repetition_penalty(move, user)
    base_score += v; factors["Repetition Penalty"] = v if factors && v != 0

    v = score_destiny_bond_awareness(move, user, target)
    base_score += v; factors["Destiny Bond Awareness"] = v if factors && v != 0

    v = score_sucker_punch_risk(move, user, target, skill)
    base_score += v; factors["Sucker Punch Risk"] = v if factors && v != 0

    v = score_forced_switch_items(move, user, target)
    base_score += v; factors["Forced Switch Items"] = v if factors && v != 0

    v = score_item_disruption(move, user, target)
    base_score += v; factors["Item Disruption"] = v if factors && v != 0

    v = score_trapping_moves(move, user, target, skill)
    base_score += v; factors["Trapping"] = v if factors && v != 0

    v = score_choice_prelock(move, user, target)
    base_score += v; factors["Choice Pre-lock"] = v if factors && v != 0

    v = score_cleric_urgency(move, user)
    base_score += v; factors["Cleric Urgency"] = v if factors && v != 0

    v = score_user_destiny_bond(move, user, target)
    base_score += v; factors["Destiny Bond"] = v if factors && v != 0

    v = score_ghost_curse(move, user, target)
    base_score += v; factors["Ghost Curse"] = v if factors && v != 0

    v = score_counter_mirror_coat(move, user, target)
    base_score += v; factors["Counter/Mirror Coat"] = v if factors && v != 0

    v = score_pp_conservation(move, user, target)
    base_score += v; factors["PP Conservation"] = v if factors && v != 0

    v = score_substitute_combo(move, user, target)
    base_score += v; factors["Substitute Combo"] = v if factors && v != 0

    v = score_disable_optimization(move, user, target)
    base_score += v; factors["Disable"] = v if factors && v != 0

    v = score_healing_wish_target(move, user)
    base_score += v; factors["Healing Wish"] = v if factors && v != 0

    v = score_mixed_attacker(move, user, target)
    base_score += v; factors["Mixed Attacker"] = v if factors && v != 0

    v = score_transform_ditto(move, user, target)
    base_score += v; factors["Transform"] = v if factors && v != 0

    if move.id == :TOPSYTURVY
      topsy_start = base_score
      total_boosts = 0
      total_drops = 0
      GameData::Stat.each_battle do |stat|
        stage = target.stages[stat.id] rescue 0
        total_boosts += stage if stage > 0
        total_drops += stage.abs if stage < 0
      end
      if total_boosts >= 4
        base_score += 80
        AdvancedAI.log("  Topsy-Turvy: inverting #{total_boosts} boost stages (+80)", "Tactic")
      elsif total_boosts >= 2
        base_score += 50  # Good payoff
      elsif total_boosts == 1
        base_score += 15  # Minor benefit
      elsif total_boosts == 0 && total_drops > 0
        base_score -= 40  # Would invert their drops into boosts!
      else
        base_score -= 20  # No stat changes to invert
      end
      factors["Topsy-Turvy"] = base_score - topsy_start if factors
    end

    if move.id == :ARMORCANNON
      if user.hasActiveAbility?(:CONTRARY)
        base_score += 30
      else
        if user.hp > user.totalhp * 0.5
          base_score -= 10  # Def/SpDef drops are risky but manageable at high HP
        else
          base_score -= 25  # At low HP, defensive drops are very dangerous
        end
      end
      # But if this KOs the target, the drops don't matter
      rough_damage = calculate_rough_damage(move, user, target)
      if rough_damage >= target.hp
        base_score += 20  # KO negates the drawback
      end
      factors["Armor Cannon"] = -10 if factors
    end

    if user.hasActiveAbility?(:CONTRARY)
      contrary_boost_moves = [:OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :PSYCHOBOOST,
                              :SUPERPOWER, :CLOSECOMBAT, :VCREATE, :HAMMERARM,
                              :FLEURCANNON, :MAKEITRAIN, :HEADLONGRUSH,
                              :ICEHAMMER, :SPINOUT, :CLANGINGSCALES,
                              :DRAGONASCENT, :HYPERSPACEFURY]
      if contrary_boost_moves.include?(move.id)
        base_score += 50
      end
    end

    if move.id == :BITTERBLADE
      hp_pct = user.hp.to_f / user.totalhp
      if hp_pct < 0.5
        base_score += 25  # Great when at low HP, heals while dealing damage
      elsif hp_pct < 0.75
        base_score += 15  # Useful sustain
      else
        base_score += 5   # Minor benefit at high HP
      end
      factors["Bitter Blade Drain"] = 15 if factors
    end

    if move.id == :GLAIVERUSH
      expected_retaliation = estimate_incoming_damage(user, target)
      doubled_damage = expected_retaliation * 2

      if doubled_damage >= user.hp
        base_score -= 80  # High chance of dying next turn
      elsif doubled_damage >= user.hp * 0.7
        base_score -= 40  # Significant risk
      elsif doubled_damage >= user.hp * 0.4
        base_score -= 20  # Moderate risk
      else
        base_score -= 5   # Minor risk
      end

      rough_damage = calculate_rough_damage(move, user, target)
      if rough_damage >= target.hp
        base_score += 50  # KO negates the drawback
      end
    end

    @_score_factors = factors

    return base_score
  end

  private

  def score_damage_potential(move, user, target, skill)
    score = 0

    return 0 if [:COUNTER, :MIRRORCOAT, :METALBURST].include?(move.id)

    bp = calculate_effective_power(move, user, target)

    score += (bp / 4.0) if bp > 0

    if skill >= 60
      rough_damage = calculate_rough_damage(move, user, target, bp)
      if rough_damage >= target.hp
        score += 100  # Guaranteed KO
      elsif rough_damage >= target.hp * 0.7
        score += 50   # Likely KO
      elsif rough_damage >= target.hp * 0.4
        score += 25
      end

      if (target.hasActiveAbility?(:EMERGENCYEXIT) || target.hasActiveAbility?(:WIMPOUT)) &&
         !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
         target.hp > target.totalhp / 2  # Currently above 50%
        if rough_damage >= target.hp - (target.totalhp / 2)
          score += 20  # Will trigger forced switch-out — free momentum
        end
      end

      if target.hasActiveAbility?(:BERSERK) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
         target.hp > target.totalhp / 2  # Currently above 50%
        would_trigger = rough_damage >= target.hp - (target.totalhp / 2)
        would_ko = rough_damage >= target.hp
        if would_trigger && !would_ko
          score -= 20  # Triggering Berserk without KO is bad
          score -= 10 if target.spatk > target.attack  # Even worse on special attackers
        end
      end
    end

    score += 30 if move.pbTarget(user).num_targets > 1 && @battle.pbSideSize(0) > 1

    return score
  end

  def score_type_effectiveness(move, user, target)
    effective_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)

    if move.id == :TERABLAST
      tera_type = get_tera_type_for_move(user)
      effective_type = tera_type if tera_type
    end

    type_mod = AdvancedAI::CombatUtilities.move_type_effectiveness(move, user, target, effective_type)

    if target.hasActiveAbility?(:WONDERGUARD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      return Effectiveness.super_effective?(type_mod) ? 40 : -200
    end

    if Effectiveness.super_effective?(type_mod)
      return 40
    elsif Effectiveness.not_very_effective?(type_mod)
      return user.hasActiveAbility?(:TINTEDLENS) ? -5 : -30
    elsif Effectiveness.ineffective?(type_mod)
      return -200
    end

    return 0
  end

  def score_stab_bonus(move, user)
    effective_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)

    if move.id == :TERABLAST
      tera_type_override = get_tera_type_for_move(user)
      effective_type = tera_type_override if tera_type_override
    end

    tera_registered = false
    tera_type = nil
    if @battle.respond_to?(:pbRegisteredTerastallize?) && @battle.pbRegisteredTerastallize?(user.index)
      battler = user.respond_to?(:battler) ? user.battler : user
      if battler.pokemon.respond_to?(:tera_type) && battler.pokemon.tera_type
        tera_registered = true
        tera_type = battler.pokemon.tera_type
      end
    end

    if tera_registered && tera_type
      if effective_type == tera_type
        # Tera STAB: 2x if same as original type, 1.5x otherwise
        return 25 if user.pbHasType?(effective_type)  # Double STAB with Tera
        return 20  # New STAB from Tera type
      elsif user.pbHasType?(effective_type)
        return 15  # Original STAB but no longer boosted by Tera
      end
    else
      return 20 if user.pbHasType?(effective_type)
    end

    if user.hasActiveAbility?(:PROTEAN) || user.hasActiveAbility?(:LIBERO)
      # If Protean/Libero has already activated, user's type IS already the first move's type.
      # Subsequent moves don't get re-typed. Use pbHasType? to check current STAB.
      # If first turn out (turnCount == 0), they haven't activated yet — first move will get STAB.
      if user.turnCount == 0
        return 15  # First move out: will become this type → STAB
      end
      # Otherwise, check if user already has this type (from previous Protean activation)
      return 15 if user.pbHasType?(effective_type)
    end
    return 0
  end

  def score_crit_potential(move, user, target)
    score = 0

    unless AdvancedAI::Utilities.ignores_ability?(user, move, target)
      return 0 if target.hasActiveAbility?(:BATTLEARMOR) || target.hasActiveAbility?(:SHELLARMOR)
    end
    return 0 if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0

    is_high_crit = (move.function_code == "HighCriticalHitRate")
    is_always_crit = move.function_code.include?("AlwaysCriticalHit")

    # 2. Synergy: Focus Energy + High Crit Move
    # Focus Energy (+2 stages) + High Crit Move (+1 stage) = +3 stages (100% Crit)
    # NOTE: Do NOT give a synergy bonus for AlwaysCriticalHit moves, because Focus Energy
    # adds nothing to them (they already crit).
    if user.effects[PBEffects::FocusEnergy] > 0
      if is_high_crit
        score += 50
      elsif !is_always_crit
        score += 20
      end
    elsif is_high_crit
      score += 15
    end

    ignore_target_def = (target.stages[:DEFENSE] > 0 && move.physicalMove?) ||
                        (target.stages[:SPECIAL_DEFENSE] > 0 && move.specialMove?)

    ignore_user_debuff = (user.stages[:ATTACK] < 0 && move.physicalMove?) ||
                         (user.stages[:SPECIAL_ATTACK] < 0 && move.specialMove?)

    if ignore_target_def || ignore_user_debuff
      if user.effects[PBEffects::FocusEnergy] > 0 || move.function_code.include?("AlwaysCriticalHit")
        score += 30 # Value bypassing the stats
      end
    end

    # Sniper: crits deal 2.25x instead of 1.5x — huge crit strategy boost
    if user.hasActiveAbility?(:SNIPER)
      score = (score * 1.5).to_i
    end

    if user.hasActiveAbility?(:MERCILESS) && (target.poisoned? rescue false)
      score += 40  # Guaranteed crit on every hit
    end

    return score
  end

  def score_status_utility(move, user, target, skill, status_multiplier = 1.0)
    score = 0

    opponent_side = target.pbOwnSide

    case move.function_code
    when "AddSpikesToFoeSide"
      return 0 unless AdvancedAI.tier_feature(skill, :hazard_awareness)
      score += 60 if opponent_side.effects[PBEffects::Spikes] < 3
    when "AddStealthRocksToFoeSide"
      return 0 unless AdvancedAI.tier_feature(skill, :hazard_awareness)
      unless opponent_side.effects[PBEffects::StealthRock]
        score += 100 * status_multiplier
        score += 60 if @battle.turnCount <= 1  # Verify turn 1
        score += 40 if user.hp > user.totalhp * 0.8
      end
    when "AddToxicSpikesToFoeSide"
      return 0 unless AdvancedAI.tier_feature(skill, :hazard_awareness)
      score += 50 if opponent_side.effects[PBEffects::ToxicSpikes] < 2
    when "AddStickyWebToFoeSide"
      return 0 unless AdvancedAI.tier_feature(skill, :hazard_awareness)
      score += 60 unless opponent_side.effects[PBEffects::StickyWeb]
    when "StartWeakenPhysicalDamageAgainstUserSide" # Reflect
      if user.pbOwnSide.effects[PBEffects::Reflect] == 0
        score += 80 * status_multiplier
        score += 50 if @battle.turnCount <= 1
        if target.lastRegularMoveUsed
          move_data = GameData::Move.try_get(target.lastRegularMoveUsed)
          score += 40 if move_data&.category == 0  # Physical move
        end
      end
    when "StartWeakenSpecialDamageAgainstUserSide" # Light Screen
      if user.pbOwnSide.effects[PBEffects::LightScreen] == 0
        score += 80 * status_multiplier
        score += 50 if @battle.turnCount <= 1
        if target.lastRegularMoveUsed
          move_data = GameData::Move.try_get(target.lastRegularMoveUsed)
          score += 40 if move_data&.category == 1  # Special move
        end
      end
    when "StartWeakenDamageAgainstUserSideIfHail" # Aurora Veil
      if (@battle.pbWeather == :Hail || @battle.pbWeather == :Snow) && user.pbOwnSide.effects[PBEffects::AuroraVeil] == 0
        score += 60
        if target.lastRegularMoveUsed
          move_data = GameData::Move.try_get(target.lastRegularMoveUsed)
          score += 40 if move_data&.power.to_i > 0  # Damaging move (GameData::Move has no .damaging?)
        end
      end
    end

    # Light Clay bonus: screens last 8 turns instead of 5
    if ["StartWeakenPhysicalDamageAgainstUserSide",
        "StartWeakenSpecialDamageAgainstUserSide",
        "StartWeakenDamageAgainstUserSideIfHail"].include?(move.function_code)
      if user.hasActiveItem?(:LIGHTCLAY)
        score += 25  # Extended screen duration is very valuable
      end
    end

    case move.function_code

    when "HealUserHalfOfTotalHP", "HealUserDependingOnWeather",
         "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn",  # Roost
         "HealUserDependingOnSandstorm",                  # Shore Up
         "CureTargetStatusHealUserHalfOfTotalHP"           # Purify
      hp_percent = user.hp.to_f / user.totalhp
      if hp_percent < 0.3
        score += 150  # Critical urgency
      elsif hp_percent < 0.5
        score += 100  # Strong urgency
      elsif hp_percent < 0.7
        score += 40   # Maintenance
      end

      trick_room = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
      moves_first = trick_room ? (user.pbSpeed < target.pbSpeed) : (user.pbSpeed > target.pbSpeed)
      score += 30 if moves_first && AdvancedAI.tier_feature(skill, :recovery_timing)

      # Shore Up heals 2/3 in sandstorm instead of 1/2
      if move.function_code == "HealUserDependingOnSandstorm"
        weather = @battle.pbWeather rescue nil
        score += 25 if weather == :Sandstorm
      end

      if move.function_code == "CureTargetStatusHealUserHalfOfTotalHP"
        if !target || target.status == :NONE
          score -= 200  # Will fail — target needs a status
        else
          score -= 30  # Penalty for removing opponent's status condition
          score -= 20 if target.burned? && target.attack > target.spatk  # Restoring physical attacker
          score -= 20 if target.poisoned?  # Removing chip damage
        end
      end

    when "HealUserByTargetAttackLowerTargetAttack1"
      hp_percent = user.hp.to_f / user.totalhp
      target_atk = target.attack
      if target.hasActiveAbility?(:LIQUIDOOZE, true)
        stage = target.stages[:ATTACK] + Battle::Battler::STAT_STAGE_MAXIMUM
        damage = (target_atk.to_f * Battle::Battler::STAT_STAGE_MULTIPLIERS[stage] /
                  Battle::Battler::STAT_STAGE_DIVISORS[stage]).floor
        score -= damage >= user.hp ? 500 : 100
        score += 40 if target_atk > target.spatk
        return score
      end
      heal_ratio = target_atk.to_f / user.totalhp

      if hp_percent < 0.3
        score += 130
      elsif hp_percent < 0.5
        score += 90
      elsif hp_percent < 0.7
        score += 40
      end

      score += 40 if target_atk > target.spatk

      if heal_ratio > 0.5
        score += 30
      elsif heal_ratio > 0.3
        score += 15
      end

      trick_room = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
      moves_first = trick_room ? (user.pbSpeed < target.pbSpeed) : (user.pbSpeed > target.pbSpeed)
      score += 20 if moves_first && AdvancedAI.tier_feature(skill, :recovery_timing)

    when "RevivePokemonHalfHP"
      party = @battle.pbParty(user.index & 1)
      fainted_count = party.count { |pkmn| pkmn && pkmn.fainted? }
      if fainted_count == 0
        score -= 200  # Will fail — no fainted Pokemon
      else
        score += 70  # Base value for reviving
        score += 15 * (fainted_count - 1)  # More fainted = more valuable
        party.each do |pkmn|
          next unless pkmn && pkmn.fainted?
          bst = pkmn.baseStats.values.sum
          if bst > 500
            score += 30
            break
          end
        end
        alive = party.count { |pkmn| pkmn && !pkmn.fainted? }
        score += 25 if alive <= 2
      end

    when "ParalyzeTarget"
      # Type immunity: Electric-types can't be paralyzed
      if target.pbHasType?(:ELECTRIC)
        score -= 200  # Will fail
      elsif target.pbHasType?(:GROUND) && move.type == :ELECTRIC
        score -= 200  # Will fail
      elsif target.pbHasType?(:GRASS) && [:STUNSPORE].include?(move.id)
        score -= 200  # Powder move blocked
      elsif [:STUNSPORE].include?(move.id) &&
            (target.hasActiveAbility?(:OVERCOAT) || target.hasActiveItem?(:SAFETYGOGGLES))
        score -= 200  # Powder move blocked by Overcoat/Safety Goggles
      elsif target.hasActiveAbility?(:LIMBER) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail
      elsif target.hasActiveAbility?(:LEAFGUARD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
            @battle && [:Sun, :HarshSun].include?(@battle.pbWeather)
        score -= 200  # Will fail
      elsif target.status == :NONE
        trick_room_active = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
        target_moves_first = trick_room_active ? (target.pbSpeed < user.pbSpeed) : (target.pbSpeed > user.pbSpeed)
        if target_moves_first
          score += 80
          target_speed_after = target.pbSpeed / 2
          user_moves_first_after = trick_room_active ? (user.pbSpeed < target_speed_after) : (user.pbSpeed > target_speed_after)
          if user_moves_first_after
            score += 30  # Now we outspeed and can KO
          end
        else
          score += 25  # Still useful vs targets we already outspeed
        end
      end

    when "BurnTarget"
      # Type immunity: Fire-types can't be burned
      if target.pbHasType?(:FIRE)
        score -= 200  # Will fail
      elsif target.hasActiveAbility?(:WATERBUBBLE) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail
      elsif (target.hasActiveAbility?(:WATERVEIL) || target.hasActiveAbility?(:THERMALEXCHANGE)) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail
      elsif target.hasActiveAbility?(:LEAFGUARD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
            @battle && [:Sun, :HarshSun].include?(@battle.pbWeather)
        score -= 200  # Will fail
      elsif target.attack > target.spatk && target.status == :NONE
        score += 100
        if target.lastRegularMoveUsed
          last_move = GameData::Move.try_get(target.lastRegularMoveUsed)
          if last_move && last_move.category == 0  # Physical move (GameData::Move has no .physical?)
            score += 40  # They're locked into physical damage
          end
        end
      elsif target.status == :NONE
        score += 30  # Still useful for passive damage
      end

    when "PoisonTarget"
      if move.id == :POISONPOWDER
        if target.pbHasType?(:GRASS)
          score -= 200  # Powder move blocked by Grass type
        elsif target.hasActiveAbility?(:OVERCOAT) || target.hasActiveItem?(:SAFETYGOGGLES)
          score -= 200  # Powder move blocked by Overcoat/Safety Goggles
        end
      end
      # Type immunity: Poison/Steel-types can't be poisoned (Corrosion bypasses)
      if (target.pbHasType?(:POISON) || target.pbHasType?(:STEEL)) && !user.hasActiveAbility?(:CORROSION)
        score -= 200  # Will fail
      elsif target.hasActiveAbility?(:IMMUNITY) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail
      elsif target.hasActiveAbility?(:PASTELVEIL) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail
      elsif @battle && @battle.allSameSideBattlers(target.index).any? { |b|
            b && !b.fainted? && b.hasActiveAbility?(:PASTELVEIL) } &&
            !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail — Pastel Veil on their side
      elsif target.hasActiveAbility?(:LEAFGUARD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
            @battle && [:Sun, :HarshSun].include?(@battle.pbWeather)
        score -= 200  # Will fail
      elsif target.status == :NONE && target.hp > target.totalhp * 0.7
        score += 35
        if target.defense + target.spdef > 200
          score += 25  # Walls hate poison
        end
      end

    when "BadPoisonTarget"
      # Type immunity: Poison/Steel-types can't be poisoned (Corrosion bypasses)
      if (target.pbHasType?(:POISON) || target.pbHasType?(:STEEL)) && !user.hasActiveAbility?(:CORROSION)
        score -= 200  # Will fail
      elsif target.hasActiveAbility?(:IMMUNITY) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail
      elsif target.hasActiveAbility?(:PASTELVEIL) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail
      elsif @battle && @battle.allSameSideBattlers(target.index).any? { |b|
            b && !b.fainted? && b.hasActiveAbility?(:PASTELVEIL) } &&
            !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail — Pastel Veil on their side
      elsif target.hasActiveAbility?(:LEAFGUARD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
            @battle && [:Sun, :HarshSun].include?(@battle.pbWeather)
        score -= 200  # Will fail
      elsif target.status == :NONE
        score += 60  # Strong base value
        if target.defense + target.spdef > 200
          score += 70  # Toxic destroys walls
        end
        if target.hasActiveAbility?(:REGENERATOR)
          score += 50  # Counter regenerator stalling
        end
        stall_moves = [:PROTECT, :DETECT, :KINGSSHIELD, :SPIKYSHIELD, :BANEFULBUNKER,
                      :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK,
                      :RECOVER, :ROOST, :SOFTBOILED, :SLACKOFF, :WISH, :REST,
                      :MOONLIGHT, :MORNINGSUN, :SYNTHESIS, :SHOREUP, :STRENGTHSAP,
                      :MILKDRINK, :HEALORDER, :LIFEDEW, :JUNGLEHEALING, :LUNARBLESSING]
        user_knows_stall = user.battler.moves.any? { |m| stall_moves.include?(m.id) }
        if user_knows_stall
          score += 40  # Can stall out Toxic damage
        end
      end

    when "SleepTarget"
      if [:SLEEPPOWDER, :SPORE].include?(move.id) && target.pbHasType?(:GRASS)
        score -= 200  # Powder move blocked by Grass type
      elsif [:SLEEPPOWDER, :SPORE].include?(move.id) &&
            (target.hasActiveAbility?(:OVERCOAT) || target.hasActiveItem?(:SAFETYGOGGLES))
        score -= 200  # Powder move blocked by Overcoat/Safety Goggles
      elsif (target.hasActiveAbility?(:INSOMNIA) || target.hasActiveAbility?(:VITALSPIRIT) || target.hasActiveAbility?(:COMATOSE)) &&
            !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail — ability prevents sleep
      elsif @battle && @battle.allSameSideBattlers(target.index).any? { |b|
            b && !b.fainted? && b.hasActiveAbility?(:SWEETVEIL) } &&
            !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        score -= 200  # Will fail — Sweet Veil on their side
      elsif target.hasActiveAbility?(:LEAFGUARD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
            @battle && [:Sun, :HarshSun].include?(@battle.pbWeather)
        score -= 200  # Will fail — Leaf Guard active in Sun
      elsif target.status == :NONE
        score += 90  # Sleep is incredibly powerful
        setup_moves = user.battler.moves.any? { |m| AdvancedAI.setup_move?(m.id) }
        if setup_moves
          score += 60  # Free setup turns!
        end
        if target.attack > 120 || target.spatk > 120
          score += 40  # Neutralize sweepers
        end
        sleep_only  = ["HealUserByHalfOfDamageDoneIfTargetAsleep",   # Dream Eater
                       "StartDamageTargetEachTurnIfTargetAsleep",    # Nightmare
                       "DoublePowerIfTargetAsleepCureTarget"]        # Wake-Up Slap
        any_status  = ["DoublePowerIfTargetStatusProblem"]           # Hex
        @battle.allSameSideBattlers(user.index).each do |b|
          next unless b && !b.fainted?
          own = (b.index == user.index)
          if b.moves.any? { |m| m && sleep_only.include?(m.function_code) }
            score += own ? 90 : 40   # An ally's payoff needs them to survive the turn
          elsif b.moves.any? { |m| m && any_status.include?(m.function_code) }
            score += own ? 25 : 12
          end
          score += own ? 40 : 30 if b.hasActiveAbility?(:BADDREAMS)
        end
      end

    when "LowerTargetAttack1", "LowerTargetAttack2",
         "LowerTargetSpeed1", "LowerTargetSpeed2",
         "LowerTargetDefense1", "LowerTargetDefense2",
         "LowerTargetSpAtk1", "LowerTargetSpAtk2",
         "LowerTargetSpDef1", "LowerTargetSpDef2",
         "LowerTargetAtkDef1", "LowerTargetEvasion1", "LowerTargetEvasion2"
      stat_drop_blocked = false
      if !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        if (target.hasActiveAbility?(:CLEARBODY) || target.hasActiveAbility?(:WHITESMOKE) || target.hasActiveAbility?(:FULLMETALBODY))
          score -= 200  # Move will completely fail
          stat_drop_blocked = true
        elsif target.hasActiveAbility?(:MIRRORARMOR)
          score -= 200  # Stat drop reflects back onto us!
          stat_drop_blocked = true
        end
      end
      if !stat_drop_blocked && AdvancedAI::Utilities.has_clear_amulet?(target)
        score -= 200  # Move will completely fail
        stat_drop_blocked = true
      end
      if !stat_drop_blocked
        case move.function_code
        when "LowerTargetAttack1", "LowerTargetAttack2"
          score -= 200 if target.stages[:ATTACK] <= -6
          score += 30 if target.attack > target.spatk
        when "LowerTargetSpeed1", "LowerTargetSpeed2"
          score -= 200 if target.stages[:SPEED] <= -6
          tr_active = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
          target_moves_first = tr_active ? (target.pbSpeed < user.pbSpeed) : (target.pbSpeed > user.pbSpeed)
          score += 35 if target_moves_first
        when "LowerTargetDefense1", "LowerTargetDefense2"
          score -= 200 if target.stages[:DEFENSE] <= -6
          score += 25 if target.defense > target.spdef
        when "LowerTargetSpAtk1", "LowerTargetSpAtk2"
          score -= 200 if target.stages[:SPECIAL_ATTACK] <= -6
          score += 30 if target.spatk > target.attack
        when "LowerTargetSpDef1", "LowerTargetSpDef2"
          score -= 200 if target.stages[:SPECIAL_DEFENSE] <= -6
          score += 25 if target.spdef > target.defense
        when "LowerTargetEvasion1", "LowerTargetEvasion2"
          score -= 200 if target.stages[:EVASION] <= -6
          score += 20
        when "LowerTargetAtkDef1"
          score += 35
        end
      end
    end

    if target.hasActiveAbility?(:NATURALCURE) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      if ["ParalyzeTarget", "BurnTarget", "PoisonTarget", "BadPoisonTarget", "SleepTarget"].include?(move.function_code)
        score -= 30  # Will be cured when they switch — still useful to force the switch
      end
    end

    if target.hasActiveAbility?(:SYNCHRONIZE) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      case move.function_code
      when "BurnTarget"
        if user.status == :NONE
          score -= 50  # We'll get burned too — very bad for physical attackers
          score -= 20 if user.attack > user.spatk  # Extra penalty for physical users
        end
      when "PoisonTarget", "BadPoisonTarget"
        if user.status == :NONE
          score -= 40  # We'll get poisoned too
          score -= 20 if move.function_code == "BadPoisonTarget"  # Toxic is worse for us
        end
      when "ParalyzeTarget"
        if user.status == :NONE
          score -= 45  # We'll get paralyzed too — speed loss is devastating
        end
      end
    end

    if move.function_code == "StartSaltCureTarget"
      salt_cured = (defined?(PBEffects::SaltCure) && target.effects[PBEffects::SaltCure] rescue false)
      if salt_cured
        score -= 200  # Already Salt Cured — will fail
      else
        score += 40  # Good passive damage (damaging move, so base damage adds too)
        if target.pbHasType?(:WATER) || target.pbHasType?(:STEEL)
          score += 50  # Double damage per turn!
        end
        if target.defense + target.spdef > 200
          score += 25
        end
        protect_moves = [:PROTECT, :DETECT, :KINGSSHIELD, :SPIKYSHIELD, :BANEFULBUNKER,
                        :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK]
        if user.battler.moves.any? { |m| protect_moves.include?(m.id) }
          score += 30
        end
      end
    end

    return score
  end

  def score_setup_value(move, user, target, skill, status_multiplier = 1.0)
    return 0 unless skill >= 55
    score = 0

    # === STAT-MAX CHECK ===
    # If all stats this move would boost are already at +6, don't use it
    setup_data = AdvancedAI.get_setup_data(move.id)
    if setup_data
      stat_key = setup_data[:stat]
      boosted_stats = case stat_key
        when :attack                then [:ATTACK]
        when :spatk                 then [:SPECIAL_ATTACK]
        when :defense               then [:DEFENSE]
        when :spdef                 then [:SPECIAL_DEFENSE]
        when :speed                 then [:SPEED]
        when :evasion               then [:EVASION]
        when :accuracy              then [:ACCURACY]
        when :attack_defense        then [:ATTACK, :DEFENSE]
        when :attack_speed          then [:ATTACK, :SPEED]
        when :attack_spatk          then [:ATTACK, :SPECIAL_ATTACK]
        when :attack_accuracy       then [:ATTACK, :ACCURACY]
        when :attack_defense_accuracy then [:ATTACK, :DEFENSE, :ACCURACY]
        when :spatk_spdef           then [:SPECIAL_ATTACK, :SPECIAL_DEFENSE]
        when :spatk_spdef_speed     then [:SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]
        when :spatk_speed           then [:SPECIAL_ATTACK, :SPEED]
        when :defense_spdef         then [:DEFENSE, :SPECIAL_DEFENSE]
        when :attack_defense_speed  then [:ATTACK, :DEFENSE, :SPEED]
        when :attack_spatk_speed    then [:ATTACK, :SPECIAL_ATTACK, :SPEED]
        when :all                   then [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]
        else nil
        end
      if boosted_stats && !boosted_stats.empty?
        maxed_count = boosted_stats.count { |s| (user.stages[s] rescue 0) >= 6 }
        if maxed_count >= boosted_stats.length
          AdvancedAI.log("#{move.name}: all target stats already at +6, skipping setup", "SetupMax")
          return -200
        elsif maxed_count > 0
          waste_ratio = maxed_count.to_f / boosted_stats.length
          penalty = -(waste_ratio * 80).to_i
          score += penalty
          AdvancedAI.log("#{move.name}: #{maxed_count}/#{boosted_stats.length} stats maxed (#{penalty})", "SetupMax")
        end
      end
    elsif move.function_code.start_with?("RaiseUser")
      fc = move.function_code
      check_stats = []
      check_stats << :ATTACK if fc.include?("Attack") || fc.include?("Atk")
      check_stats << :DEFENSE if fc.include?("Defense") || fc.include?("Def")
      check_stats << :SPECIAL_ATTACK if fc.include?("SpAtk")
      check_stats << :SPECIAL_DEFENSE if fc.include?("SpDef")
      check_stats << :SPEED if fc.include?("Speed") || fc.include?("Spd")
      if !check_stats.empty?
        maxed_count = check_stats.count { |s| (user.stages[s] rescue 0) >= 6 }
        if maxed_count >= check_stats.length
          AdvancedAI.log("#{move.name}: all target stats already at +6 (function code), skipping", "SetupMax")
          return -200
        elsif maxed_count > 0
          waste_ratio = maxed_count.to_f / check_stats.length
          score += -(waste_ratio * 80).to_i
        end
      end
    end

    if target.hasActiveAbility?(:UNAWARE) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      return -60  # Setting up is literally pointless
    end

    anti_setup_penalty = 0

    target.moves.each_with_index do |tmove, index|
      next unless tmove
      next unless @battle.pbCanChooseMove?(target.index, index, false)
      move_id = tmove.id rescue (tmove.respond_to?(:id) ? tmove.id : nil)
      next unless move_id

      case move_id
      when :ROAR, :WHIRLWIND, :DRAGONTAIL, :CIRCLETHROW
        index = target.moves.index(tmove)
        if @battle.pbCanChooseMove?(target.index, index, false) &&
           AdvancedAI::Utilities.phazing_possible?(@battle, tmove, target, user)
          anti_setup_penalty -= 80
        end
      when :HAZE, :CLEARSMOG
        index = target.moves.index(tmove)
        if @battle.pbCanChooseMove?(target.index, index, false) &&
           AdvancedAI::Utilities.stat_reset_hits_target?(@battle, tmove, target, user)
          anti_setup_penalty -= (move_id == :HAZE ? 90 : 70)
        end
      when :SPECTRALTHIEF
        if AdvancedAI::CombatUtilities.estimate_damage(target, tmove, user) > 0
          anti_setup_penalty -= 80
        end
      when :TOPSYTURVY
        if AdvancedAI::Utilities.setup_disruption_hits?(@battle, tmove, target, user, true)
          anti_setup_penalty -= 90
        end
      when :ENCORE
        if AdvancedAI::Utilities.setup_disruption_hits?(@battle, tmove, target, user, true)
          anti_setup_penalty -= 60
        end
      when :YAWN
        if AdvancedAI::Utilities.delayed_setup_threat?(@battle, tmove, target, user)
          anti_setup_penalty -= 50
        end
      when :PERISHSONG
        if AdvancedAI::Utilities.delayed_setup_threat?(@battle, tmove, target, user)
          anti_setup_penalty -= 40
        end
      when :TRICK, :SWITCHEROO
        if AdvancedAI::Utilities.delayed_setup_threat?(@battle, tmove, target, user)
          anti_setup_penalty -= 30
        end
      when :TAUNT
        if AdvancedAI::Utilities.setup_disruption_hits?(@battle, tmove, target, user, true)
          anti_setup_penalty -= 25
        end
      when :DISABLE
        if AdvancedAI::Utilities.delayed_setup_threat?(@battle, tmove, target, user)
          anti_setup_penalty -= 20
        end
      end
    end

    anti_setup_penalty = [anti_setup_penalty, -100].max

    if anti_setup_penalty <= -60
      return anti_setup_penalty
    end

    simple_mult = 1.0
    if user.hasActiveAbility?(:SIMPLE)
      simple_mult = 2.0
    end

    if user.hasActiveAbility?(:CONTRARY)
      setup_data = AdvancedAI.get_setup_data(move.id)
      if setup_data
        has_negative = setup_data[:defense_spdef] && setup_data[:defense_spdef] < 0
        if has_negative
        else
          return -200
        end
      end
    end

    safe_to_setup = is_safe_to_setup?(user, target)

    if safe_to_setup

      total_boosts = 0

      setup_data = AdvancedAI.get_setup_data(move.id)
      if setup_data
        stages_per = setup_data[:stages] || 1
        # Weather-conditional boosts (e.g., Growth raises +2 in Sun instead of +1)
        if setup_data[:sun_stages] && @battle &&
           [:Sun, :HarshSun].include?(@battle.pbWeather)
          stages_per = setup_data[:sun_stages]
        end
        stat_key = setup_data[:stat]
        stat_count = case stat_key
          when :attack, :spatk, :defense, :spdef, :speed, :evasion, :accuracy, :random then 1
          when :attack_defense, :attack_speed, :attack_spatk, :attack_accuracy,
               :spatk_spdef, :spatk_speed, :defense_spdef then 2
          when :attack_defense_accuracy, :spatk_spdef_speed, :attack_defense_speed,
               :attack_spatk_speed then 3
          when :all then 5
          else 1
          end
        total_boosts = stages_per * stat_count
        total_boosts += (setup_data[:speed_extra] || 0)
        if setup_data[:hp_cost]
          hp_threshold = setup_data[:hp_cost]  # e.g., 0.5 for Belly Drum
          if user.hp <= user.totalhp * hp_threshold
            return -100  # Would faint or leave at 1 HP — too dangerous
          end
          # Must have recovery item (Sitrus Berry) or high HP to justify
          has_recovery = [:SITRUSBERRY, :ORANBERRY, :AGUAVBERRY, :FIGYBERRY,
                          :IAPAPABERRY, :MAGOBERRY, :WIKIBERRY].include?(user.item_id)
          if has_recovery
            score += 80  # Belly Drum + Sitrus = devastating combo
          elsif user.hp > user.totalhp * 0.8
            score += 20  # Risky but we have the HP
          else
            score -= 40  # Too risky without recovery item
          end
        end
      elsif move.function_code.start_with?("RaiseUser")
        total_boosts = move.function_code.scan(/\d+/).first.to_i
        total_boosts = 1 if total_boosts == 0
      else
        total_boosts = 1
      end

      score += (total_boosts * 40 * status_multiplier * simple_mult).to_i

      if user.hp > user.totalhp * 0.7
        score += 30
      end

      score += anti_setup_penalty
    else
      score -= 40  # Dangerous to setup
    end

    return score
  end

  def score_priority(move, user, target)
    return 0 if move && move.statusMove?
    return 0 unless move
    move_priority = AdvancedAI::PriorityTiers.get_priority_tier(move, user)
    return 0 if move_priority <= 0
    return 0 if AdvancedAI.protect_move?(move.id)

    score = move_priority * 15

    trick_room = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
    user_is_slower = trick_room ? (user.pbSpeed > target.pbSpeed) : (user.pbSpeed < target.pbSpeed)
    if user.hp <= user.totalhp * 0.33 && user_is_slower
      score += 40
    end

    if move_priority > 0 && target.opposes?(user)
      if @battle.field.terrain == :Psychic && target.affectedByTerrain?
        return -100
      end

      blocking_abilities = [:DAZZLING, :QUEENLYMAJESTY, :ARMORTAIL]
      unless user.hasMoldBreaker?
        if blocking_abilities.any? { |a| target.hasActiveAbility?(a) }
          return -100
        end
        if @battle.pbSideSize(target.index) > 1
          @battle.allSameSideBattlers(target.index).each do |ally|
            next if ally == target || ally.fainted?
            if blocking_abilities.any? { |a| ally.hasActiveAbility?(a) }
              return -100
            end
          end
        end
      end
    end

    # Extra Bonus if slower (priority lets us move first when we otherwise wouldn't)
    score += 30 if user_is_slower

    if move.damagingMove?
      rough_damage = calculate_rough_damage(move, user, target)
      score += 40 if rough_damage >= target.hp
    end

    return score
  end

  def score_accuracy(move, skill, user = nil)
    accuracy = move.respond_to?(:move) ? move.move.accuracy : move.accuracy
    return 0 if accuracy == 0  # Never-miss moves

    if user && user.hasActiveAbility?(:NOGUARD)
      return accuracy < 70 ? 15 : 0
    end

    if user && user.hasActiveAbility?(:COMPOUNDEYES)
      accuracy = [accuracy * 1.3, 100].min.to_i
    end

    if user && user.hasActiveAbility?(:VICTORYSTAR)
      accuracy = [accuracy * 1.1, 100].min.to_i
    end

    if user && user.hasActiveAbility?(:HUSTLE)
      raw_move = move.respond_to?(:move) ? move.move : move
      if raw_move.respond_to?(:physicalMove?) && raw_move.physicalMove?
        accuracy = (accuracy * 0.8).to_i
      end
    end

    if accuracy < 70
      return -40
    elsif accuracy < 85
      return -20
    elsif accuracy < 95
      return -10
    end

    return 0
  end

  def score_recoil_risk(move, user)
    return 0 unless move.recoilMove?

    return 0 if user.hasActiveAbility?(:MAGICGUARD)

    return 0 if user.hasActiveAbility?(:ROCKHEAD)

    hp_percent = user.hp.to_f / user.totalhp

    if hp_percent < 0.3
      return -50  # Dangerous at low HP
    elsif hp_percent < 0.5
      return -25
    else
      return -10  # Acceptable risk
    end
  end

  def score_secondary_effects(move, user, target)
    score = 0

    if AdvancedAI::Utilities.has_covert_cloak?(target)
      return 0  # No secondary effect value
    end

    if target.hasActiveAbility?(:SHIELDDUST)
      return 0
    end

    if user.hasActiveAbility?(:POISONTOUCH) && move.contactMove?
      target_types = target.pbTypes(true)
      unless target_types.include?(:POISON) || target_types.include?(:STEEL)
        unless target.hasActiveAbility?(:IMMUNITY) || target.hasActiveAbility?(:PASTELVEIL) ||
               target.hasActiveAbility?(:PURIFYINGSALT) || target.hasActiveAbility?(:COMATOSE)
          score += 10  # 30% poison chance is a nice bonus
          score += 5 if user.hasActiveAbility?(:SERENEGRACE)  # 60% with Serene Grace
        end
      end
    end

    if user.hasActiveAbility?(:TOXICCHAIN) && move.damagingMove?
      target_types = target.pbTypes(true)
      unless target_types.include?(:POISON) || target_types.include?(:STEEL)
        unless target.hasActiveAbility?(:IMMUNITY) || target.hasActiveAbility?(:PASTELVEIL) ||
               target.hasActiveAbility?(:PURIFYINGSALT) || target.hasActiveAbility?(:COMATOSE) ||
               target.status != :NONE
          score += 18
          score += 9 if user.hasActiveAbility?(:SERENEGRACE)  # 60% with Serene Grace
          if target.totalhp > 0
            bulk = (target.totalhp + (target.defense rescue 0) + (target.spdef rescue 0))
            score += 12 if bulk > 600
          end
        end
      end
    end

    # Seed Sower (Arboliva): if we hit a target with Seed Sower with a damaging
    # move, it sets Grassy Terrain. Penalize if WE don't benefit from that.
    if move.damagingMove? && target.hasActiveAbility?(:SEEDSOWER) && @battle
      cur_terrain = (@battle.field.terrain rescue :None)
      if cur_terrain != :Grassy
        unless target.hasActiveAbility?(:SHIELDDUST)
          our_grass_types = user.pbTypes(true).include?(:GRASS)
          our_grounded = !user.airborne?
          if our_grass_types && our_grounded
            score += 10  # We benefit too (Grass STAB boost + heal)
          elsif our_grounded
            score += 5   # Heal but no STAB boost
          else
            score -= 10  # We're airborne — only opponent benefits
          end
          user.moves.each do |m|
            next unless m && m.damagingMove?
            if [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE].include?(m.id)
              score -= 8
              break
            end
          end
        end
      end
    end

    has_innate_flinch = move.flinchingMove?
    # Stench: 10% flinch on all damaging moves that don't already flinch
    has_stench_flinch = !has_innate_flinch && move.damagingMove? && user.hasActiveAbility?(:STENCH)
    has_item_flinch = !has_innate_flinch && move.damagingMove? && [:KINGSROCK, :RAZORFANG].include?(user.item_id)
    if has_innate_flinch || has_stench_flinch || has_item_flinch
      unless target.hasActiveAbility?(:INNERFOCUS) || target.hasActiveAbility?(:SHIELDDUST)
        flinch_bonus = has_innate_flinch ? 20 : 8  # Lower bonus for 10% chance
        flinch_bonus = (flinch_bonus * 1.8).to_i if user.hasActiveAbility?(:SERENEGRACE)
        trick_room = @battle && @battle.field.effects[PBEffects::TrickRoom] > 0
        moves_first = trick_room ? (user.pbSpeed < target.pbSpeed) : (user.pbSpeed > target.pbSpeed)
        score += flinch_bonus if moves_first
      end
    end

    if move.function_code.start_with?("LowerTarget") && move.damagingMove?
      if AdvancedAI::Utilities.has_clear_amulet?(target)
        score -= 30  # Secondary stat-drop wasted
      elsif !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
            (target.hasActiveAbility?(:CLEARBODY) || target.hasActiveAbility?(:WHITESMOKE) ||
             target.hasActiveAbility?(:FULLMETALBODY) || target.hasActiveAbility?(:MIRRORARMOR))
        score -= 30  # Secondary stat-drop wasted (Mirror Armor reflects it back!)
      else
        stat_drop_bonus = 20
        stat_drop_bonus = (stat_drop_bonus * 1.5).to_i if user.hasActiveAbility?(:SERENEGRACE)
        score += stat_drop_bonus
      end
    end

    if ["ParalyzeTarget", "BurnTarget", "PoisonTarget", "SleepTarget", "FreezeTarget"].any? {|code| move.function_code.include?(code)}
      status_bonus = move.addlEffect / 2
      status_bonus = (status_bonus * 1.8).to_i if user.hasActiveAbility?(:SERENEGRACE)
      score += status_bonus
    end

    case move.function_code
    when "SplintersTargetGen8AddSpikesGen9"
      opp_side = target.pbOwnSide
      if opp_side.effects[PBEffects::Spikes] < 3
        score += 30 + (15 * (3 - opp_side.effects[PBEffects::Spikes]))
      end
    when "SplintersTargetGen8AddStealthRocksGen9"
      opp_side = target.pbOwnSide
      unless opp_side.effects[PBEffects::StealthRock]
        score += 60
        score += 25 if @battle.turnCount <= 1
      end
    end

    return score
  end

  def score_gen9_extras(move, user, target)
    return 0 unless AdvancedAI::GEN9_PACK_COMPAT
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    move = move.move if move.respond_to?(:move)
    score = 0
    return score unless move && target

    covert = AdvancedAI::Utilities.has_covert_cloak?(target) rescue false
    shield_dust = target.hasActiveAbility?(:SHIELDDUST) rescue false
    secondary_blocked = covert || shield_dust

    case move.id
    when :BLOODMOON, :GIGATONHAMMER
      # Cannot be used twice in a row. Penalize if used last turn (and we'd be locked).
      last = (user.lastMoveUsed rescue nil)
      score -= 200 if last == move.id  # Will fail if same move used last turn

    when :TRAILBLAZE
      cur = (user.stages[:SPEED] rescue 0)
      if cur < 6
        score += 25  # Free speed boost — very strong on offensive Pokemon
        score += 10 if cur <= 0  # Especially valuable when not yet boosted
      end

    when :ICESPINNER
      terrain = (@battle && @battle.field.terrain) rescue nil
      if terrain && terrain != :None
        if [:Electric, :Grassy, :Psychic, :Misty].include?(terrain)
          opp_benefits = false
          begin
            opps = @battle.allOtherSideBattlers(user.index).select { |b| b && !b.fainted? }
            opp_benefits = opps.any? do |o|
              case terrain
              when :Electric then o.hasActiveAbility?(:SURGESURFER) || o.hasActiveAbility?(:QUARKDRIVE) || o.hasActiveAbility?(:HADRONENGINE)
              when :Grassy   then true  # heals + boosts Grass
              when :Psychic  then true  # blocks our priority
              when :Misty    then true  # blocks our status
              end
            end
          rescue
          end
          score += opp_benefits ? 35 : 10
        end
      end

    when :LUMINACRASH
      unless secondary_blocked
        if AdvancedAI::Utilities.has_clear_amulet?(target) ||
           (!AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
            (target.hasActiveAbility?(:CLEARBODY) || target.hasActiveAbility?(:WHITESMOKE) ||
             target.hasActiveAbility?(:FULLMETALBODY) || target.hasActiveAbility?(:MIRRORARMOR)))
          score -= 10
        else
          cur = (target.stages[:SPECIAL_DEFENSE] rescue 0)
          if cur > -6
            score += 30
            score += 15 if cur >= 0
          end
        end
      end

    when :SYRUPBOMB
      unless secondary_blocked
        cur = (target.stages[:SPEED] rescue 0)
        if cur > -6 && !AdvancedAI::Utilities.has_clear_amulet?(target)
          score += 25  # 3-turn speed shred
        end
      end

    when :TEMPERFLARE
      last_failed = false
      begin
        last_failed = user.lastMoveFailed if user.respond_to?(:lastMoveFailed)
      rescue
      end
      score += 25 if last_failed

    when :SUPERCELLSLAM
      acc = (move.accuracy rescue 95)
      if acc > 0 && acc < 100
        miss_chance = (100 - acc) / 100.0
        crash_dmg = user.totalhp / 2  # Half max HP on miss
        risk = (miss_chance * crash_dmg * 100.0 / [user.totalhp, 1].max)
        score -= risk.to_i
        score -= 30 if user.hp < user.totalhp / 2  # Don't risk it at low HP
      end

    when :PSYCHICNOISE
      unless secondary_blocked
        unless target.hasActiveAbility?(:SOUNDPROOF)
          target_has_recovery = false
          begin
            recovery_moves = [:RECOVER, :ROOST, :SOFTBOILED, :MILKDRINK, :SLACKOFF,
                              :MOONLIGHT, :MORNINGSUN, :SYNTHESIS, :SHOREUP, :STRENGTHSAP,
                              :REST, :WISH, :PAIN_SPLIT, :PAINSPLIT, :HEALORDER, :LIFEDEW,
                              :JUNGLEHEALING, :LUNARDANCE, :HEALPULSE, :FLORALHEALING]
            target_has_recovery = target.moves.any? { |m| m && recovery_moves.include?(m.id) } rescue false
          rescue
          end
          score += target_has_recovery ? 50 : 15
          score += 15 if target.item_id == :LEFTOVERS || target.item_id == :BLACKSLUDGE
        end
      end

    when :MALIGNANTCHAIN
      unless secondary_blocked
        target_types = target.pbTypes(true)
        unless target_types.include?(:POISON) || target_types.include?(:STEEL) ||
               target.hasActiveAbility?(:IMMUNITY) || target.hasActiveAbility?(:PASTELVEIL) ||
               target.hasActiveAbility?(:PURIFYINGSALT) || target.hasActiveAbility?(:COMATOSE) ||
               target.status != :NONE
          score += 30  # 50% Toxic chance vs unstatused non-immune target
          if target.totalhp >= 300 || target.defense + target.spdef > 200
            score += 15
          end
        end
      end

    when :DRAGONCHEER
      if @battle && @battle.pbSideSize(user.index & 1) > 1
        ally = nil
        begin
          ally = @battle.allSameSideBattlers(user.index).find { |b| b && b.index != user.index && !b.fainted? }
        rescue
          ally = nil
        end
        if ally
          ally_crit = (ally.effects[PBEffects::FocusEnergy] rescue 0) rescue 0
          if ally_crit < 2
            score += 25
            score += 15 if ally.pbHasType?(:DRAGON)  # +2 crit stages instead of +1
            score += 10 if (ally.attack >= 120 || ally.spatk >= 120)
          else
            score -= 50  # Already at max crit
          end
        else
          score -= 50  # No ally — wasted move
        end
      else
        score -= 100  # Singles — useless
      end

    when :IVYCUDGEL
    when :TERASTARSTORM

    when :SPICYEXTRACT
      unless secondary_blocked
        cur_atk   = (target.stages[:ATTACK] rescue 0)
        cur_speed = (target.stages[:SPEED] rescue 0)
        atk_stat  = (target.attack rescue 100)
        spa_stat  = (target.spatk  rescue 100)

        if spa_stat > atk_stat + 30
          score -= 60  # Bad — handing them +2 Speed
        elsif cur_atk <= -6
          score -= 50  # Atk already minimized
        elsif AdvancedAI::Utilities.has_clear_amulet?(target) ||
              (!AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
               (target.hasActiveAbility?(:CLEARBODY) || target.hasActiveAbility?(:WHITESMOKE) ||
                target.hasActiveAbility?(:FULLMETALBODY) || target.hasActiveAbility?(:CONTRARY)))
          if !AdvancedAI::Utilities.ignores_ability?(user, move, target) && target.hasActiveAbility?(:CONTRARY)
            score += 40  # Speed shred + Atk boost is fine vs them only if they're physical
          else
            score -= 40
          end
        else
          if cur_speed >= 4
            score -= 30  # Already fast, don't boost further
          else
            score += 10
          end
        end
      end

    when :POUNCE
      unless secondary_blocked
        cur = (target.stages[:SPEED] rescue 0)
        if cur > -6 && !AdvancedAI::Utilities.has_clear_amulet?(target)
          our_spe   = (user.speed rescue 100)
          their_spe = (target.speed rescue 100)
          score += (their_spe > our_spe) ? 25 : 10
        end
      end

    when :FUTURESIGHT, :DOOMDESIRE
      pos = (@battle && @battle.positions[target.index] rescue nil)
      already = false
      already = true if pos && defined?(PBEffects::FutureSightCounter) &&
                        (pos.effects[PBEffects::FutureSightCounter].to_i > 0 rescue false)
      if already
        score -= 200
      else
        score += 15
        # Bonus when target is bulky (we'd otherwise struggle to dent them)
        score += 15 if target.totalhp >= 320
        recovery_moves = [:RECOVER, :ROOST, :SOFTBOILED, :MILKDRINK, :SLACKOFF,
                          :MOONLIGHT, :MORNINGSUN, :SYNTHESIS, :SHOREUP, :STRENGTHSAP, :REST]
        has_recovery = (target.moves.any? { |m| m && recovery_moves.include?(m.id) } rescue false)
        score -= 20 if has_recovery
      end

    when :MAGICROOM
      threat_items = [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF, :LEFTOVERS, :BLACKSLUDGE,
                      :LIFEORB, :HEAVYDUTYBOOTS, :FOCUSSASH, :ASSAULTVEST, :EVIOLITE,
                      :PUNCHINGGLOVE, :LOADEDDICE, :BOOSTERENERGY, :CLEARAMULET, :MIRRORHERB,
                      :COVERTCLOAK]
      opp_item_value = 0
      begin
        @battle.allOtherSideBattlers(user.index).each do |o|
          next unless o && !o.fainted?
          opp_item_value += 15 if threat_items.include?(o.item_id)
        end
      rescue
      end
      our_item_value = 0
      begin
        @battle.allSameSideBattlers(user.index).each do |a|
          next unless a && !a.fainted?
          our_item_value += 15 if threat_items.include?(a.item_id)
        end
      rescue
      end
      score += (opp_item_value - our_item_value)
      # Already up — don't refresh
      already_up = false
      already_up = true if @battle && defined?(PBEffects::MagicRoom) &&
                           (@battle.field.effects[PBEffects::MagicRoom].to_i > 0 rescue false)
      score -= 200 if already_up

    when :WONDERROOM
      our_phys = (user.attack rescue 100)
      our_spec = (user.spatk  rescue 100)
      bonus = 0
      begin
        @battle.allOtherSideBattlers(user.index).each do |o|
          next unless o && !o.fainted?
          if our_phys > our_spec && o.defense > o.spdef
            bonus += 15
          elsif our_spec > our_phys && o.spdef > o.defense
            bonus += 15
          end
        end
      rescue
      end
      score += bonus
      already_up = false
      already_up = true if @battle && defined?(PBEffects::WonderRoom) &&
                           (@battle.field.effects[PBEffects::WonderRoom].to_i > 0 rescue false)
      score -= 200 if already_up

    when :TIDYUP
      return score unless AdvancedAI::WinConditions.move_available?(user, move)
      attack_delta = aai_self_stage_delta(user, move, :ATTACK)
      speed_delta = aai_self_stage_delta(user, move, :SPEED)
      speed_value = @battle.field.effects[PBEffects::TrickRoom] > 0 ? -15 : 15
      bonus = attack_delta * 15 + speed_delta * speed_value
      our_side = user.pbOwnSide
      opp_side = user.pbOpposingSide
      bonus += 25 if our_side.effects[PBEffects::StealthRock]
      bonus += 20 * our_side.effects[PBEffects::Spikes]
      bonus += 15 * our_side.effects[PBEffects::ToxicSpikes]
      bonus += 20 if our_side.effects[PBEffects::StickyWeb]
      bonus -= 15 if opp_side.effects[PBEffects::StealthRock]
      bonus -= 10 * opp_side.effects[PBEffects::Spikes]
      bonus -= 10 * opp_side.effects[PBEffects::ToxicSpikes]
      bonus -= 10 if opp_side.effects[PBEffects::StickyWeb]
      @battle.allBattlers.each do |b|
        next if b.fainted? || b.effects[PBEffects::Substitute] <= 0
        bonus += b.opposes?(user) ? 20 : -20
      end
      score += bonus

    when :MORTALSPIN
      return score if aai_removal_target_state(user, move, target) == :blocked
      our_side = user.pbOwnSide
      score += 25 if our_side.effects[PBEffects::StealthRock]
      score += 20 * our_side.effects[PBEffects::Spikes]
      score += 15 * our_side.effects[PBEffects::ToxicSpikes]
      score += 20 if our_side.effects[PBEffects::StickyWeb]
      score += 30 if user.effects[PBEffects::LeechSeed] >= 0
      score += 30 if user.effects[PBEffects::Trapping] > 0
      score += 10 if aai_secondary_poison_useful?(user, move, target)

    when :RAPIDSPIN
      return score if aai_removal_target_state(user, move, target) == :blocked
      speed_delta = Settings::MECHANICS_GENERATION >= 8 ? aai_self_stage_delta(user, move, :SPEED) : 0
      speed_value = @battle.field.effects[PBEffects::TrickRoom] > 0 ? -15 : 15
      bonus = speed_delta * speed_value
      begin
        our_side = user.pbOwnSide
        bonus += 25 if our_side.effects[PBEffects::StealthRock]
        bonus += 20 * (our_side.effects[PBEffects::Spikes].to_i)
        bonus += 15 * (our_side.effects[PBEffects::ToxicSpikes].to_i)
        bonus += 20 if our_side.effects[PBEffects::StickyWeb]
      rescue
      end
      score += bonus

    when :REVIVALBLESSING
      return score unless AdvancedAI::WinConditions.move_available?(user, move)
      if aai_revival_candidates(user.index).empty?
        score -= 200
      else
        score += 80
        score += 20 if user.hp < user.totalhp * 0.30
      end

    end

    if target && target.hasActiveAbility?(:ANGERSHELL) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
       move.damagingMove?
      threshold = target.totalhp / 2
      if target.hp > threshold
        rough = (calculate_rough_damage(move, user, target) rescue 0)
        post_hp = target.hp - rough
        if post_hp > 0 && post_hp <= threshold
          score -= 40  # Activates Anger Shell without KO
        end
      end
    end

    if target && target.hasActiveAbility?(:TOXICDEBRIS) && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
       move.physicalMove?
      our_side = (user.pbOwnSide rescue nil)
      tspikes = (our_side && our_side.effects[PBEffects::ToxicSpikes].to_i rescue 0)
      score -= (tspikes < 2 ? 15 : 0)
    end

    if target && target.hasActiveAbility?(:LINGERINGAROMA) && move.contactMove? &&
       !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      critical_abilities = [:HUGEPOWER, :PUREPOWER, :PROTOSYNTHESIS, :QUARKDRIVE, :ORICHALCUMPULSE,
                            :HADRONENGINE, :SHARPNESS, :TECHNICIAN, :TOUGHCLAWS, :STRONGJAW,
                            :IRONFIST, :PUNKROCK, :GUTS, :ADAPTABILITY, :CONTRARY,
                            :MAGICGUARD, :MULTISCALE, :REGENERATOR, :NATURALCURE,
                            :GORILLATACTICS, :SUPREMEOVERLORD]
      our_ab = (user.ability_id rescue nil)
      score -= (critical_abilities.include?(our_ab) ? 30 : 10)
    end

    if target && target.hasActiveAbility?(:WINDRIDER) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      wind_moves = [:HURRICANE, :GUST, :AIRCUTTER, :TAILWIND, :BLIZZARD, :ICYWIND, :TWISTER,
                    :HEATWAVE, :RAZORWIND, :WHIRLWIND, :PETALBLIZZARD, :FAIRYWIND, :SANDSTORM,
                    :BLEAKWINDSTORM, :SANDSEARSTORM, :WILDBOLTSTORM, :SPRINGTIDESTORM]
      if wind_moves.include?(move.id)
        score -= 80  # Move absorbed AND gives them +1 Atk
      end
    end

    terrain_seed_map = {
      :ELECTRICTERRAIN => :ELECTRICSEED,
      :GRASSYTERRAIN   => :GRASSYSEED,
      :MISTYTERRAIN    => :MISTYSEED,
      :PSYCHICTERRAIN  => :PSYCHICSEED
    }
    if terrain_seed_map.key?(move.id) && @battle
      seed = terrain_seed_map[move.id]
      begin
        @battle.allOtherSideBattlers(user.index).each do |o|
          next unless o && !o.fainted?
          if o.item_id == seed
            score -= 25  # Hand them a free +1 defensive boost
          end
        end
        @battle.allSameSideBattlers(user.index).each do |a|
          next unless a && !a.fainted?
          if a.item_id == seed
            score += 15  # Allies benefit
          end
        end
      rescue
      end
    end

    if move.damagingMove? && target && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      move_type = (move.pbCalcType(user) rescue move.type)
      wind_moves = [:HURRICANE, :GUST, :AIRCUTTER, :TAILWIND, :BLIZZARD, :ICYWIND,
                    :HEATWAVE, :PETALBLIZZARD, :FAIRYWIND, :SANDSTORM,
                    :BLEAKWINDSTORM, :SANDSEARSTORM, :WILDBOLTSTORM, :SPRINGTIDESTORM]
      if target.hasActiveAbility?(:WINDPOWER) && wind_moves.include?(move.id)
        has_electric = target.moves.any? { |m| m && m.damagingMove? && m.type == :ELECTRIC } rescue false
        score -= (has_electric ? 25 : 8)
      end
      if target.hasActiveAbility?(:ELECTROMORPHOSIS) && move_type == :ELECTRIC
        has_electric = target.moves.any? { |m| m && m.damagingMove? && m.type == :ELECTRIC } rescue false
        score -= (has_electric ? 20 : 5)
      end
    end

    # === Ripen target awareness ===
    # Ripen doubles berry effect. If our move would trigger their berry (via threshold),
    # they get DOUBLE the benefit (e.g. Sitrus heals 50% instead of 25%, Liechi gives +2 Atk).
    if move.damagingMove? && target && target.hasActiveAbility?(:RIPEN) &&
       !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      power_berries = [:LIECHIBERRY, :PETAYABERRY, :GANLONBERRY, :APICOTBERRY, :SALACBERRY,
                       :STARFBERRY, :MICLEBERRY, :CUSTAPBERRY,
                       :SITRUSBERRY, :ENIGMABERRY, :ORANBERRY, :BERRYJUICE,
                       :LANSATBERRY, :MARANGABERRY, :KEEBERRY]
      if power_berries.include?(target.item_id)
        rough = (calculate_rough_damage(move, user, target) rescue 0)
        post_hp = target.hp - rough
        pinch_threshold = target.totalhp / 4
        if post_hp > 0 && post_hp <= pinch_threshold && target.hp > pinch_threshold
          score -= 25  # Triggers pinch berry → DOUBLE effect
        elsif post_hp > 0 && post_hp <= (target.totalhp / 2) && target.hp > (target.totalhp / 2) &&
              [:SITRUSBERRY, :ORANBERRY, :ENIGMABERRY, :BERRYJUICE].include?(target.item_id)
          score -= 20  # Sitrus heal threshold doubled
        end
      end
    end

    if target && target.hasActiveAbility?(:CUDCHEW) &&
       defined?(PBEffects::CudChewCounter) && (target.effects[PBEffects::CudChewCounter].to_i > 0 rescue false)
      score += 8  # Slight urgency bonus on damaging moves
    end

    # === Guard Dog awareness ===
    # Intimidate is REVERSED on Guard Dog (they get +1 Atk instead of -1).

    return score
  end

  def score_contact_punishment(move, user, target)
    return 0 unless move && move.contactMove?
    return 0 unless target
    # Magic Guard blocks indirect contact damage. Non-damaging contact effects
    # (Static, Flame Body, etc.) must still be evaluated below.
    magic_guard = user.hasActiveAbility?(:MAGICGUARD)

    return 0 if user.hasActiveAbility?(:LONGREACH)

    return 0 if user.hasActiveItem?(:PROTECTIVEPADS)

    is_punching = (move.respond_to?(:punchingMove?) && move.punchingMove?) rescue false
    return 0 if is_punching && user.hasActiveItem?(:PUNCHINGGLOVE)

    score_penalty = 0
    mold_breaker = AdvancedAI::Utilities.ignores_ability?(user, move, target)

    unless mold_breaker
      if !magic_guard && (target.hasActiveAbility?(:ROUGHSKIN) || target.hasActiveAbility?(:IRONBARBS))
        recoil_damage = user.totalhp / 8
        hp_percent_lost = (recoil_damage * 100.0 / [user.hp, 1].max)

        if hp_percent_lost >= 100
          score_penalty += 80  # Would KO self
        elsif hp_percent_lost >= 50
          score_penalty += 40  # Major damage
        elsif hp_percent_lost >= 25
          score_penalty += 20
        else
          score_penalty += 10
        end
      end

      if user.status == :NONE
        if target.hasActiveAbility?(:FLAMEBODY)
          if user.attack > user.spatk
            score_penalty += 25
          else
            score_penalty += 10
          end
        end

        if target.hasActiveAbility?(:STATIC)
          if user.pbSpeed >= 100
            score_penalty += 20
          else
            score_penalty += 8
          end
        end

        if target.hasActiveAbility?(:POISONPOINT)
          score_penalty += 10
        end

        if target.hasActiveAbility?(:EFFECTSPORE)
          score_penalty += 15 unless user.hasActiveItem?(:SAFETYGOGGLES)
        end
      end

      if target.hasActiveAbility?(:GOOEY) || target.hasActiveAbility?(:TANGLINGHAIR)
        tr_active = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
        user_moves_first = tr_active ? (user.pbSpeed < target.pbSpeed) : (user.pbSpeed >= target.pbSpeed)
        if user_moves_first
          score_penalty += 15  # Could lose speed advantage
        else
          score_penalty += 5   # Already slower (in current context)
        end
      end

      if target.hasActiveAbility?(:STAMINA) && move.physicalMove?
        score_penalty += 15  # Each hit makes next hit weaker
        physical_moves = user.battler.moves.count { |m| m && m.physicalMove? && m.damagingMove? } rescue 0
        score_penalty += 10 if physical_moves >= 3  # Mostly physical = Stamina is devastating
      end

      if target.hasActiveAbility?(:WEAKARMOR) && move.physicalMove?
        if target.pbSpeed < user.pbSpeed
          score_penalty += 10  # They might outspeed us after the boost
        end
      end

      if target.hasActiveAbility?(:PERISHBODY)
        score_penalty += 30 unless user.effects[PBEffects::PerishSong] > 0
      end

      if target.hasActiveAbility?(:MUMMY) || target.hasActiveAbility?(:LINGERINGAROMA)
        good_abilities = [:HUGEPOWER, :PUREPOWER, :SPEEDBOOST, :PROTEAN, :LIBERO,
                          :WONDERGUARD, :MAGICGUARD, :MULTISCALE, :SHADOWSHIELD]
        score_penalty += 25 if user.hasActiveAbility?(good_abilities)
      end

      if target.hasActiveAbility?(:WANDERINGSPIRIT)
        score_penalty += 15  # Usually undesirable
      end

      if target.hasActiveAbility?(:CUTECHARM) && user.status == :NONE
        if user.gender != 2 && target.gender != 2 && user.gender != target.gender
          score_penalty += 12  # Infatuation = 50% chance of doing nothing each turn
        end
      end

      if target.hasActiveAbility?(:COTTONDOWN)
        tr_active = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
        user_moves_first = tr_active ? (user.pbSpeed < target.pbSpeed) : (user.pbSpeed >= target.pbSpeed)
        score_penalty += 8 if user_moves_first
      end

      if target.hasActiveAbility?(:ELECTROMORPHOSIS)
        has_electric = target.moves.any? { |m| m && m.type == :ELECTRIC && m.damagingMove? }
        score_penalty += 15 if has_electric
      end

      if target.hasActiveAbility?(:ANGERSHELL) && target.hp > target.totalhp / 2
        score_penalty += 15  # Could trigger dangerous stat boosts
      end
    end

    if !magic_guard && target.hasActiveItem?(:ROCKYHELMET)
      recoil_damage = user.totalhp / 6
      hp_percent_lost = (recoil_damage * 100.0 / [user.hp, 1].max)

      if hp_percent_lost >= 100
        score_penalty += 100  # Would KO self
      elsif hp_percent_lost >= 50
        score_penalty += 50
      elsif hp_percent_lost >= 25
        score_penalty += 25
      else
        score_penalty += 12
      end
    end

    return score_penalty
  end

  def calculate_rough_damage(move, user, target, override_bp = nil)
    return 0 unless move.damagingMove?

    effective_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
    if move.id == :TERABLAST
      tera_type = get_tera_type_for_move(user)
      effective_type = tera_type if tera_type
    end
    grounds_target = move.function_code == "HitsTargetInSkyGroundsTarget"
    if effective_type == :GROUND && !grounds_target &&
       AdvancedAI::Utilities.item_active?(target, :AIRBALLOON)
      return 0
    end
    type_mod = AdvancedAI::CombatUtilities.move_type_effectiveness(move, user, target, effective_type)
    return 0 if Effectiveness.ineffective?(type_mod)

    if target.hasActiveAbility?(:WONDERGUARD) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      return 0 unless Effectiveness.super_effective?(type_mod)
    end

    return 0 if AdvancedAI::Utilities.type_absorbing_immunity?(user, target, effective_type, move)

    bp = override_bp || move.power
    if !override_bp && bp == 1 && move.respond_to?(:move)
      ai_user = user.is_a?(Battle::AI::AIBattler) ? user : (@battlers[user.index] rescue nil)
      ai_target = target.is_a?(Battle::AI::AIBattler) ? target : (@battlers[target.index] rescue nil)
      if ai_user && ai_target
        bp = Battle::AI::Handlers.get_base_power(
          move.function_code, bp, move, ai_user, ai_target, self, @battle
        )
      end
    end
    bp = AdvancedAI::CombatUtilities.resolve_move_power(move, user, target) if !override_bp && bp == 1
    return 0 if bp == 0
    if move.function_code.start_with?("OHKO")
      return 0 if target.level > user.level
      return 0 if effective_type == :ICE && target.pbHasType?(:ICE)
      if target.hasActiveAbility?(:STURDY) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        return 0
      end
      return target.hp
    end
    return user.level if move.function_code == "FixedDamageUserLevelRandom"

    if [:ERUPTION, :WATERSPOUT, :DRAGONENERGY].include?(move.id)
      bp = [150 * user.hp / [user.totalhp, 1].max, 1].max
    end

    if [:FLAIL, :REVERSAL].include?(move.id)
      n = 48 * user.hp / [user.totalhp, 1].max
      if n < 2
        bp = 200
      elsif n < 5
        bp = 150
      elsif n < 10
        bp = 100
      elsif n < 17
        bp = 80
      elsif n < 33
        bp = 40
      else
        bp = 20
      end
    end

    if [:CRUSHGRIP, :WRINGOUT].include?(move.id)
      bp = [120 * target.hp / [target.totalhp, 1].max, 1].max
    end

    if move.id == :GYROBALL
      user_speed = [user.pbSpeed, 1].max
      target_speed = [target.pbSpeed, 1].max
      bp = [(25 * target_speed / user_speed), 150].min
      bp = [bp, 1].max
    end

    if move.id == :ELECTROBALL
      user_speed = [user.pbSpeed, 1].max
      target_speed = [target.pbSpeed, 1].max
      ratio = user_speed / target_speed
      if ratio >= 4
        bp = 150
      elsif ratio >= 3
        bp = 120
      elsif ratio >= 2
        bp = 80
      elsif ratio >= 1
        bp = 60
      else
        bp = 40
      end
    end

    if move.id == :LASTRESPECTS && @battle
      bp = AdvancedAI::Utilities.last_respects_power(@battle, user)
    end

    if move.id == :RAGEFIST
      bp = AdvancedAI::Utilities.rage_fist_power(user)
    end

    if AdvancedAI::Utilities.collision_move_boost?(move)
      resolved_cc_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
      type_check = Effectiveness.calculate(resolved_cc_type, *target.pbTypes(true))
      bp = (bp * 1.33).to_i if Effectiveness.super_effective?(type_check)
    end

    if move.id == :HARDPRESS && target.totalhp > 0
      bp = [(100 * target.hp / target.totalhp.to_f).floor, 1].max
    end

    if move.id == :FICKLEBEAM
      bp = 104
    end

    if move.id == :COMEUPPANCE
      last_dmg = (user.lastHPLost rescue 0)
      if last_dmg > 0
        return (last_dmg * 1.5).to_i
      else
        return 0  # Will fail
      end
    end

    hit_multiplier = override_bp ? 1.0 : AdvancedAI::CombatUtilities.expected_hit_multiplier(move, user)
    bp = (bp * hit_multiplier).to_i if hit_multiplier > 1.0

    if move.id == :FUSIONFLARE && @battle &&
       (@battle.field.effects[PBEffects::FusionBolt] rescue false)
      bp *= 2
    elsif move.id == :FUSIONBOLT && @battle &&
          (@battle.field.effects[PBEffects::FusionFlare] rescue false)
      bp *= 2
    end

    # === HYDRO STEAM (Gen 9) ===
    # Water move that gets 1.5x BOOST in Sun instead of being weakened
    if move.id == :HYDROSTEAM && @battle
      weather = @battle.pbWeather rescue :None
      if [:Sun, :HarshSun].include?(weather)
        bp = (bp * 1.5).to_i  # Boosted in Sun!
      end
    end

    if move.id == :PSYBLADE && @battle
      terrain = @battle.field.terrain rescue nil
      if terrain == :Electric
        bp = (bp * 1.5).to_i
      end
    end

    if move.id == :RISINGVOLTAGE && @battle
      terrain = @battle.field.terrain rescue nil
      if terrain == :Electric && target.respond_to?(:affectedByTerrain?) && target.affectedByTerrain?
        bp *= 2
      end
    end

    if move.id == :EXPANDINGFORCE && @battle
      terrain = @battle.field.terrain rescue nil
      if terrain == :Psychic && user.respond_to?(:affectedByTerrain?) && user.affectedByTerrain?
        bp = (bp * 1.5).to_i
      end
    end

    if move.id == :MISTYEXPLOSION && @battle
      terrain = @battle.field.terrain rescue nil
      if terrain == :Misty && user.respond_to?(:affectedByTerrain?) && user.affectedByTerrain?
        bp = (bp * 1.5).to_i
      end
    end

    if [:SOLARBEAM, :SOLARBLADE].include?(move.id) && @battle
      weather = @battle.pbWeather rescue :None
      if [:Rain, :HeavyRain, :Sandstorm, :Hail, :Snow].include?(weather)
        bp = (bp / 2.0).to_i
        bp = [bp, 1].max
      end
    end

    if [:FIREPLEDGE, :WATERPLEDGE, :GRASSPLEDGE].include?(move.id) &&
       (user.effects[PBEffects::FirstPledge] rescue nil)
      bp *= 2
    end

    if move.id == :TERRAINPULSE && @battle
      terrain = @battle.field.terrain rescue nil
      if terrain && user.affectedByTerrain?
        bp *= 2  # Doubles in active terrain
        case terrain
        when :Electric then effective_type = :ELECTRIC
        when :Grassy   then effective_type = :GRASS
        when :Psychic  then effective_type = :PSYCHIC
        when :Misty    then effective_type = :FAIRY
        end
      end
    end

    if [:HEAVYSLAM, :HEATCRASH].include?(move.id)
      user_weight = user.pbWeight rescue 100
      target_weight = target.pbWeight rescue 100
      ratio = user_weight.to_f / [target_weight, 1].max
      if ratio >= 5
        bp = 120
      elsif ratio >= 4
        bp = 100
      elsif ratio >= 3
        bp = 80
      elsif ratio >= 2
        bp = 60
      else
        bp = 40
      end
    end

    if [:LOWKICK, :GRASSKNOT].include?(move.id)
      target_weight = target.pbWeight rescue 100
      if target_weight >= 2000
        bp = 120
      elsif target_weight >= 1000
        bp = 100
      elsif target_weight >= 500
        bp = 80
      elsif target_weight >= 250
        bp = 60
      elsif target_weight >= 100
        bp = 40
      else
        bp = 20
      end
    end

    if move.id == :FACADE && user.status != :NONE
      bp *= 2
    end

    if move.id == :HEX && target.status != :NONE
      bp *= 2
    end

    if move.id == :VENOSHOCK && (target.status == :POISON || target.status == :TOXIC)
      bp *= 2
    end

    if move.id == :BRINE && target.hp < target.totalhp / 2
      bp *= 2
    end

    if [:AVALANCHE, :REVENGE].include?(move.id) && user.lastHPLost > 0
      bp *= 2
    end

    if [:STOREDPOWER, :POWERTRIP].include?(move.id)
      stat_boosts = 0
      GameData::Stat.each_battle do |stat|
        stage = user.stages[stat.id] rescue 0
        stat_boosts += stage if stage > 0
      end
      bp = 20 + (20 * stat_boosts)
    end

    if move.id == :KNOCKOFF && target.item && target.item != :NONE
      bp = (bp * 1.5).to_i
    end

    if move.id == :ACROBATICS && (!user.item || user.item == :NONE)
      bp *= 2
    end

    if move.id == :POLTERGEIST && (!target.item || target.item == :NONE)
      return 0  # Move fails
    end

    is_physical = move.physicalMove?
    if [:PHOTONGEYSER, :LIGHTTHATBURNSTHESKY].include?(move.id) ||
       (move.id == :TERABLAST && get_tera_type_for_move(user))
      physical_attack = user.attack * AdvancedAI::CombatUtilities.stage_multiplier(user.stages[:ATTACK])
      special_attack = user.spatk * AdvancedAI::CombatUtilities.stage_multiplier(user.stages[:SPECIAL_ATTACK])
      is_physical = physical_attack > special_attack
    end
    uses_physical_defense = is_physical
    uses_physical_defense = true if [:PSYSHOCK, :PSYSTRIKE, :SECRETSWORD].include?(move.id)
    if @battle && defined?(PBEffects::WonderRoom) &&
       (@battle.field.effects[PBEffects::WonderRoom] rescue 0).to_i > 0
      uses_physical_defense = !uses_physical_defense
    end

    atk = is_physical ? user.attack : user.spatk
    defense = uses_physical_defense ? target.defense : target.spdef
    atk_stage = is_physical ? user.stages[:ATTACK] : user.stages[:SPECIAL_ATTACK]
    def_stage = uses_physical_defense ? target.stages[:DEFENSE] : target.stages[:SPECIAL_DEFENSE]

    if move.id == :FOULPLAY
      atk = target.attack
      atk_stage = target.stages[:ATTACK]
    end

    # Body Press - uses user's Defense instead of Attack
    if move.id == :BODYPRESS
      atk = user.defense
      atk_stage = user.stages[:DEFENSE]
    end

    if [:SEISMICTOSS, :NIGHTSHADE].include?(move.id)
      return user.level
    end

    if [:SUPERFANG, :NATURESMADNESS].include?(move.id)
      return [target.hp / 2, 1].max
    end

    if move.id == :RUINATION
      return [target.hp / 2, 1].max
    end

    if move.id == :FINALGAMBIT
      return user.hp
    end

    if move.id == :DRAGONRAGE
      return 40
    end

    if move.id == :SONICBOOM
      return 20
    end

    if move.id == :ENDEAVOR
      return [target.hp - user.hp, 0].max
    end

    guaranteed_crit = move.function_code.include?("AlwaysCriticalHit") ||
                      (user.hasActiveAbility?(:MERCILESS) && (target.poisoned? rescue false)) ||
                      ((user.effects[PBEffects::LaserFocus] rescue 0) > 0)
    crit_blocked = target.pbOwnSide.effects[PBEffects::LuckyChant] > 0 rescue false
    unless AdvancedAI::Utilities.ignores_ability?(user, move, target)
      crit_blocked ||= target.hasActiveAbility?(:BATTLEARMOR) || target.hasActiveAbility?(:SHELLARMOR)
    end
    guaranteed_crit = false if crit_blocked

    if target.hasActiveAbility?(:UNAWARE) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      atk_stage = 0
    end
    if user.hasActiveAbility?(:UNAWARE)
      def_stage = 0
    end
    atk_stage = 0 if guaranteed_crit && atk_stage < 0
    def_stage = 0 if guaranteed_crit && def_stage > 0
    atk = [(atk * AdvancedAI::CombatUtilities.stage_multiplier(atk_stage)).to_i, 1].max
    defense = [(defense * AdvancedAI::CombatUtilities.stage_multiplier(def_stage)).to_i, 1].max

    burn_mod = 1.0
    if user.status == :BURN && is_physical
      if user.hasActiveAbility?(:GUTS)
        burn_mod = 1.5
      elsif move.id == :FACADE
        burn_mod = 1.0  # Facade ignores burn penalty (Gen 5+)
      else
        burn_mod = 0.5  # Burn halves physical damage
      end
    end

    if is_physical && user.hasActiveAbility?(:GUTS) && user.status != :NONE && user.status != :BURN
      burn_mod = 1.5
    end

    if user.hasActiveAbility?(:TOXICBOOST) && user.poisoned? && is_physical
      burn_mod = [burn_mod, 1.5].max  # Don't stack, take the higher
    end

    if user.hasActiveAbility?(:FLAREBOOST) && user.burned? && !is_physical
      burn_mod = 1.5  # Override burn penalty for special moves
    end

    effective_type = move.type
    ate_boost = 1.0
    if move.type == :NORMAL
      ate_map = {
        :PIXILATE => :FAIRY, :REFRIGERATE => :ICE,
        :AERILATE => :FLYING, :GALVANIZE => :ELECTRIC
      }
      ate_ability = ate_map.keys.find { |a| user.hasActiveAbility?(a) }
      if ate_ability
        effective_type = ate_map[ate_ability]
        ate_boost = 1.2
      end
    end

    if move.id == :WEATHERBALL && @battle
      weather = @battle.pbWeather rescue :None
      case weather
      when :Sun, :HarshSun
        effective_type = :FIRE
        bp = 100
      when :Rain, :HeavyRain
        effective_type = :WATER
        bp = 100
      when :Sandstorm
        effective_type = :ROCK
        bp = 100
      when :Hail, :Snow
        effective_type = :ICE
        bp = 100
      end
    end

    if move.id == :TERABLAST
      tera_type = get_tera_type_for_move(user)
      effective_type = tera_type if tera_type
    end

    type_mod = AdvancedAI::CombatUtilities.move_type_effectiveness(move, user, target, effective_type)

    stab = user.pbHasType?(effective_type) ? 1.5 : 1.0

    if user.hasActiveAbility?(:PROTEAN) || user.hasActiveAbility?(:LIBERO)
      stab = [stab, 1.5].max
    end

    if user.hasActiveAbility?(:ADAPTABILITY) && user.pbHasType?(effective_type)
      stab = 2.0
    end

    ability_mod = 1.0
    real_user = user.respond_to?(:battler) ? user.battler : user
    real_move = move.respond_to?(:move) ? move.move : move
    contact_move = if real_move.respond_to?(:pbContactMove?)
                     real_move.pbContactMove?(real_user) rescue false
                   else
                     move.contactMove?
                   end

    if (user.hasActiveAbility?(:HUGEPOWER) || user.hasActiveAbility?(:PUREPOWER)) && is_physical
      ability_mod *= 2.0
    end

    if user.hasActiveAbility?(:HUSTLE) && is_physical
      ability_mod *= 1.5
    end

    if user.hasActiveAbility?(:GORILLATACTICS) && is_physical
      ability_mod *= 1.5
    end

    if user.hasActiveAbility?(:TRANSISTOR) && effective_type == :ELECTRIC
      ability_mod *= 1.5
    end

    if user.hasActiveAbility?(:DRAGONSMAW) && effective_type == :DRAGON
      ability_mod *= 1.5
    end

    ability_mod *= AdvancedAI::CombatUtilities.ruin_damage_modifier(
      @battle, user, target, is_physical
    )

    if target.hasActiveAbility?(:ICESCALES) && !is_physical && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.5
    end

    if target.hasActiveAbility?(:FURCOAT) && uses_physical_defense && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.5
    end

    if target.hasActiveAbility?(:FLUFFY) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.5 if contact_move
      ability_mod *= 2.0 if effective_type == :FIRE
    end

    if (target.hasActiveAbility?(:FILTER) || target.hasActiveAbility?(:SOLIDROCK)) &&
       Effectiveness.super_effective?(type_mod) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.75
    end
    if target.hasActiveAbility?(:PRISMARMOR) && Effectiveness.super_effective?(type_mod)
      ability_mod *= 0.75
    end

    if user.hasActiveAbility?(:TINTEDLENS) && Effectiveness.not_very_effective?(type_mod)
      ability_mod *= 2.0
    end

    if user.hasActiveAbility?(:SHEERFORCE) && move.addlEffect.to_i > 0
      ability_mod *= 1.3
    end

    if user.hasActiveAbility?(:TOUGHCLAWS) && contact_move
      ability_mod *= 1.3
    end

    if user.hasActiveAbility?(:STRONGJAW) && move.respond_to?(:bitingMove?) && move.bitingMove?
      ability_mod *= 1.5
    end

    if user.hasActiveAbility?(:IRONFIST) && move.respond_to?(:punchingMove?) && move.punchingMove?
      ability_mod *= 1.2
    end

    if user.hasActiveAbility?(:TECHNICIAN) && bp <= 60 && bp > 0
      ability_mod *= 1.5
    end

    if user.hasActiveAbility?(:WATERBUBBLE) && effective_type == :WATER
      ability_mod *= 2.0
    end
    if target.hasActiveAbility?(:WATERBUBBLE) && effective_type == :FIRE && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.5
    end

    if user.hasActiveAbility?(:STEELWORKER) && effective_type == :STEEL
      ability_mod *= 1.5
    end

    if user.hasActiveAbility?(:SANDFORCE) && @battle && @battle.pbWeather == :Sandstorm
      if [:GROUND, :ROCK, :STEEL].include?(effective_type)
        ability_mod *= 1.3
      end
    end

    if user.hasActiveAbility?(:SOLARPOWER) && !is_physical
      if @battle && [:Sun, :HarshSun].include?(@battle.pbWeather)
        ability_mod *= 1.5
      end
    end

    if user.hasActiveAbility?(:ANALYTIC)
      trick_room = @battle && @battle.field.effects[PBEffects::TrickRoom] > 0
      moves_last = trick_room ? (user.pbSpeed > target.pbSpeed) : (user.pbSpeed < target.pbSpeed)
      ability_mod *= 1.3 if moves_last
    end

    if user.hasActiveAbility?(:NEUROFORCE) && Effectiveness.super_effective?(type_mod)
      ability_mod *= 1.25
    end

    if user.hasActiveAbility?(:PARENTALBOND)
      is_multi = move.respond_to?(:multiHitMove?) && move.multiHitMove?
      ability_mod *= 1.25 unless is_multi
    end

    if user.hasActiveAbility?(:MEGALAUNCHER) && move.respond_to?(:pulseMove?) && move.pulseMove?
      ability_mod *= 1.5
    end

    if @battle
      aura_break = @battle.allBattlers.any? { |b| b && !b.fainted? && b.hasActiveAbility?(:AURABREAK) }
      if @battle.allBattlers.any? { |b| b && !b.fainted? && b.hasActiveAbility?(:DARKAURA) }
        if effective_type == :DARK
          ability_mod *= aura_break ? 0.75 : 1.33
        end
      end
      if @battle.allBattlers.any? { |b| b && !b.fainted? && b.hasActiveAbility?(:FAIRYAURA) }
        if effective_type == :FAIRY
          ability_mod *= aura_break ? 0.75 : 1.33
        end
      end
    end

    if target.hasActiveAbility?(:THICKFAT) && [:FIRE, :ICE].include?(effective_type) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.5
    end

    if target.hasActiveAbility?(:HEATPROOF) && effective_type == :FIRE && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.5
    end

    if target.hasActiveAbility?(:MULTISCALE) && target.hp == target.totalhp && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.5
    end
    if target.hasActiveAbility?(:SHADOWSHIELD) && target.hp == target.totalhp
      ability_mod *= 0.5
    end

    ability_mod *= ate_boost

    if move.respond_to?(:soundMove?) && move.soundMove?
      if user.hasActiveAbility?(:PUNKROCK)
        ability_mod *= 1.3
      end
      if target.hasActiveAbility?(:PUNKROCK) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        ability_mod *= 0.5
      end
    end

    if user.hasActiveAbility?(:RECKLESS) && move.respond_to?(:recoilMove?) && move.recoilMove?
      ability_mod *= 1.2
    end

    if user.hp <= user.totalhp / 3
      pinch_map = {
        :BLAZE => :FIRE, :TORRENT => :WATER, :OVERGROW => :GRASS, :SWARM => :BUG
      }
      pinch_ability = pinch_map.keys.find { |a| user.hasActiveAbility?(a) }
      if pinch_ability && effective_type == pinch_map[pinch_ability]
        ability_mod *= 1.5
      end
    end

    if user.hasActiveAbility?(:SUPREMEOVERLORD) && @battle
      fainted_allies = @battle.allSameSideBattlers(user.index).count { |b| b && b.fainted? } rescue 0
      fainted_party = 0
      begin
        party = @battle.pbParty(user.index & 1)
        fainted_party = party.count { |p| p && p.fainted? } rescue 0
      rescue
        fainted_party = 0
      end
      fainted_count = [fainted_party, 5].min
      ability_mod *= (1.0 + fainted_count * 0.1) if fainted_count > 0
    end

    if user.hasActiveAbility?(:STAKEOUT)
      target_choice = @battle.choices[target.index] rescue nil
      if target_choice && target_choice[0] == :SwitchOut
        ability_mod *= 2.0
      end
    end

    if user.hasActiveAbility?(:ORICHALCUMPULSE) && is_physical
      if @battle && [:Sun, :HarshSun].include?(@battle.pbWeather)
        ability_mod *= 1.33
      end
    end

    if user.hasActiveAbility?(:HADRONENGINE) && !is_physical
      if @battle && (@battle.field.terrain == :Electric rescue false)
        ability_mod *= 1.33
      end
    end

    if user.hasActiveAbility?(:SHARPNESS) && move.respond_to?(:slicingMove?) && move.slicingMove?
      ability_mod *= 1.5
    end

    if user.hasActiveAbility?(:ROCKYPAYLOAD) && effective_type == :ROCK
      ability_mod *= 1.5
    end

    if user.hasActiveAbility?(:FLASHFIRE) && effective_type == :FIRE
      if defined?(PBEffects::FlashFire) && (user.effects[PBEffects::FlashFire] rescue false)
        ability_mod *= 1.5
      end
    end

    if effective_type == :ELECTRIC
      if defined?(PBEffects::Charge) && (user.effects[PBEffects::Charge].to_i > 0 rescue false)
        ability_mod *= 2.0
      end
    end

    if target.hasActiveAbility?(:DRYSKIN) && effective_type == :FIRE && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 1.25
    end

    if target.hasActiveAbility?(:PURIFYINGSALT) && effective_type == :GHOST && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.5
    end

    if target.hasActiveAbility?(:MARVELSCALE) && target.status != :NONE &&
       uses_physical_defense && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      ability_mod *= 0.67  # Effective 1/1.5 damage reduction
    end

    weather_mod = 1.0
    if @battle
      weather = @battle.pbWeather rescue :None
      target_umbrella = target.respond_to?(:item_id) && target.item_id == :UTILITYUMBRELLA
      user_umbrella = user.respond_to?(:item_id) && user.item_id == :UTILITYUMBRELLA
      unless target_umbrella || user_umbrella
        case weather
        when :Sun, :HarshSun
          weather_mod *= 1.5 if effective_type == :FIRE
          weather_mod *= 0.5 if effective_type == :WATER && move.id != :HYDROSTEAM
        when :Rain, :HeavyRain
          weather_mod *= 1.5 if effective_type == :WATER
          weather_mod *= 0.5 if effective_type == :FIRE
        end
      end
    end

    if @battle && !uses_physical_defense
      weather = @battle.pbWeather rescue :None
      if weather == :Sandstorm && target.pbHasType?(:ROCK)
        defense = (defense * 1.5).to_i
      end
    end
    if @battle && uses_physical_defense
      weather = @battle.pbWeather rescue :None
      if weather == :Snow && target.pbHasType?(:ICE)
        defense = (defense * 1.5).to_i
      end
    end

    screen_mod = guaranteed_crit ? 1.0 :
      AdvancedAI::CombatUtilities.screen_modifier(@battle, user, target, is_physical)

    item_mod = 1.0

    if user.item_id == :LIFEORB
      item_mod *= 1.3
    elsif user.item_id == :CHOICEBAND && is_physical
      item_mod *= 1.5
    elsif user.item_id == :CHOICESPECS && !is_physical
      item_mod *= 1.5
    elsif user.item_id == :EXPERTBELT && Effectiveness.super_effective?(type_mod)
      item_mod *= 1.2
    end

    type_items = {
      :SILKSCARF => :NORMAL, :BLACKBELT => :FIGHTING, :SHARPBEAK => :FLYING,
      :POISONBARB => :POISON, :SOFTSAND => :GROUND, :HARDSTONE => :ROCK,
      :SILVERPOWDER => :BUG, :SPELLTAG => :GHOST, :METALCOAT => :STEEL,
      :CHARCOAL => :FIRE, :MYSTICWATER => :WATER, :MIRACLESEED => :GRASS,
      :MAGNET => :ELECTRIC, :TWISTEDSPOON => :PSYCHIC, :NEVERMELTICE => :ICE,
      :DRAGONFANG => :DRAGON, :BLACKGLASSES => :DARK, :FAIRYFEATHER => :FAIRY
    }
    if type_items.key?(user.item_id) && effective_type == type_items[user.item_id]
      item_mod *= 1.2
    end

    plate_types = {
      :FISTPLATE => :FIGHTING, :SKYPLATE => :FLYING, :TOXICPLATE => :POISON,
      :EARTHPLATE => :GROUND, :STONEPLATE => :ROCK, :INSECTPLATE => :BUG,
      :SPOOKYPLATE => :GHOST, :IRONPLATE => :STEEL, :FLAMEPLATE => :FIRE,
      :SPLASHPLATE => :WATER, :MEADOWPLATE => :GRASS, :ZAPPLATE => :ELECTRIC,
      :MINDPLATE => :PSYCHIC, :ICICLEPLATE => :ICE, :DRACOPLATE => :DRAGON,
      :DREADPLATE => :DARK, :PIXIEPLATE => :FAIRY
    }
    if plate_types.key?(user.item_id) && effective_type == plate_types[user.item_id]
      item_mod *= 1.2
    end

    if user.item_id == :MUSCLEBAND && is_physical
      item_mod *= 1.1
    elsif user.item_id == :WISEGLASSES && !is_physical
      item_mod *= 1.1
    end

    if user.item_id == :THICKCLUB && is_physical
      species = (user.species rescue nil)
      if [:CUBONE, :MAROWAK, :MAROWAKALOLA].include?(species)
        item_mod *= 2.0
      end
    end
    if user.item_id == :LIGHTBALL
      species = (user.species rescue nil)
      if [:PIKACHU, :PIKACHUCOSPLAY, :PIKACHUROCKSTAR, :PIKACHUBELLE,
          :PIKACHUPOPSTAR, :PIKACHUPHD, :PIKACHULIBRE, :PIKACHUORIGINAL,
          :PIKACHUHOENN, :PIKACHUSINNOH, :PIKACHUUNOVA, :PIKACHUKALOS,
          :PIKACHUALOLA, :PIKACHUPARTNER, :PIKACHUWORLD].include?(species)
        item_mod *= 2.0
      end
    end
    if user.item_id == :DEEPSEATOOTH && !is_physical
      species = (user.species rescue nil)
      item_mod *= 2.0 if species == :CLAMPERL
    end

    if user.item_id == :ADAMANTORB && [:DRAGON, :STEEL].include?(effective_type)
      species = (user.species rescue nil)
      item_mod *= 1.2 if [:DIALGA, :DIALGAORIGIN].include?(species)
    elsif user.item_id == :LUSTROUSORB && [:DRAGON, :WATER].include?(effective_type)
      species = (user.species rescue nil)
      item_mod *= 1.2 if [:PALKIA, :PALKIAORIGIN].include?(species)
    elsif user.item_id == :GRISEOUSORB && [:DRAGON, :GHOST].include?(effective_type)
      species = (user.species rescue nil)
      item_mod *= 1.2 if [:GIRATINA, :GIRATINAORIGIN].include?(species)
    elsif user.item_id == :SOULDEW && [:DRAGON, :PSYCHIC].include?(effective_type)
      species = (user.species rescue nil)
      item_mod *= 1.2 if [:LATIOS, :LATIAS].include?(species)
    end

    target_mod = 1.0

    if target.item_id == :EVIOLITE
      # Eviolite check: target must not be fully evolved
      # If we can't determine evolution, skip (safe default)
      species_data = (GameData::Species.get(target.species) rescue nil)
      if species_data
        evos = species_data.get_evolutions rescue []
        if evos && evos.length > 0  # Has evolutions → NFE → Eviolite active
          if uses_physical_defense
            target_mod *= 0.67  # ~1/1.5 = 0.67 (Def boosted)
          else
            target_mod *= 0.67  # SpDef boosted
          end
        end
      end
    end

    if target.item_id == :DEEPSEASCALE && !uses_physical_defense
      species = (target.species rescue nil)
      target_mod *= 0.5 if species == :CLAMPERL
    end

    if defined?(PBEffects::GlaiveRush) && target.effects[PBEffects::GlaiveRush] > 0
      target_mod *= 2.0
    end

    if AdvancedAI::Utilities.has_resist_berry?(target, effective_type) &&
       Effectiveness.super_effective?(type_mod)
      target_mod *= 0.5
    end

    if target.item_id == :ASSAULTVEST && !uses_physical_defense
      target_mod *= 0.67  # 1/1.5 = 0.67 (SpDef boosted by AV)
    end

    terrain_mod = 1.0
    if @battle
      terrain = @battle.field.terrain rescue nil
      if terrain && user.respond_to?(:affectedByTerrain?) && user.affectedByTerrain?
        case terrain
        when :Electric
          terrain_mod *= 1.3 if effective_type == :ELECTRIC
        when :Grassy
          terrain_mod *= 1.3 if effective_type == :GRASS
        when :Psychic
          terrain_mod *= 1.3 if effective_type == :PSYCHIC
        end
      end
      if terrain == :Misty && effective_type == :DRAGON
        if target.respond_to?(:affectedByTerrain?) && target.affectedByTerrain?
          terrain_mod *= 0.5
        end
      end
      if terrain == :Grassy && [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE].include?(move.id)
        if target.respond_to?(:affectedByTerrain?) && target.affectedByTerrain?
          terrain_mod *= 0.5
        end
      end
    end

    damage = ((2 * user.level / 5.0 + 2) * bp * atk / [defense, 1].max / 50 + 2)
    damage *= type_mod / Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    damage *= stab
    damage *= burn_mod
    damage *= ability_mod
    damage *= weather_mod
    damage *= terrain_mod
    damage *= screen_mod
    damage *= item_mod
    damage *= target_mod
    damage *= 1.5 if guaranteed_crit
    damage *= AdvancedAI::CombatUtilities.spread_damage_modifier(@battle, user, move)

    return [damage.to_i, 0].max
  end

  def is_safe_to_setup?(user, target)
    return false if user.hp < user.totalhp * 0.5

    yawn_val = (user.effects[PBEffects::Yawn] rescue 0)
    return false if yawn_val.is_a?(Numeric) && yawn_val > 0

    perish_val = (user.effects[PBEffects::PerishSong] rescue 0)
    return false if perish_val.is_a?(Numeric) && perish_val > 0

    # Already confused — may hit ourselves instead of benefiting
    confusion_val = (user.effects[PBEffects::Confusion] rescue 0)
    return false if confusion_val.is_a?(Numeric) && confusion_val > 0

    # Encored — locked into the setup move, can't use boosted attacks
    encore_val = (user.effects[PBEffects::Encore] rescue 0)
    return false if encore_val.is_a?(Numeric) && encore_val > 0

    trick_room = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
    if trick_room
      return false if user.pbSpeed > target.pbSpeed * 1.5  # In TR, faster raw speed = moves last
    else
      return false if target.pbSpeed > user.pbSpeed * 1.5
    end

    max_incoming = 0
    target.moves.each_with_index do |move, index|
      next unless move && move.damagingMove?
      next unless @battle.pbCanChooseMove?(target.index, index, false)
      next if AdvancedAI::Utilities.counter_priority_blocked?(@battle, move, target, user)
      dmg = AdvancedAI::CombatUtilities.estimate_damage(target, move, user)
      next if dmg <= 0
      resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, move)
      type_mod = Effectiveness.calculate(resolved_type, *user.pbTypes(true))
      return false if Effectiveness.super_effective?(type_mod)
      max_incoming = dmg if dmg > max_incoming
    end
    return false if max_incoming > user.hp * 0.55  # Would 2HKO us

    return true
  end

  def calculate_effective_power(move, user, target)
    bp = AdvancedAI::CombatUtilities.resolve_move_power(move)
    return 0 if bp == 0

    if move.function_code.include?("AlwaysCriticalHit")
      is_immune = target.hasActiveAbility?(:BATTLEARMOR) ||
                  target.hasActiveAbility?(:SHELLARMOR) ||
                  target.pbOwnSide.effects[PBEffects::LuckyChant] > 0

      unless is_immune
        bp = (bp * 1.5).to_i
      end
    end

    return bp unless move.multiHitMove? || move.function_code == "HitTwoTimes"

    if move.multiHitMove?
      if user.hasActiveAbility?(:SKILLLINK)
        return bp * 5
      elsif user.hasActiveItem?(:LOADEDDICE)
        return bp * 4 # Average 4-5 hits
      else
        begin
          num_hits = move.pbNumHits(user, [target])
          return bp * 2 if num_hits == 2  # Fixed 2-hit moves
          return bp * num_hits if num_hits > 0
        rescue NoMethodError, StandardError
          case move.function_code
          when "HitOncePerUserTeamMember"  # Beat Up - estimate party size
            party = @battle.pbParty(user.index & 1)
            able_count = party.count { |p| p && p.able? && p.status == :NONE }
            return bp * [able_count, 1].max
          when "HitTenTimes"  # Population Bomb
            return bp * 7  # Average hits
          else
            return bp * 3  # Default average for 2-5 hit moves
          end
        end
      end
    elsif move.function_code == "HitTwoTimes"
       return bp * 2
    end

    return bp
  end

  # Destiny Bond Awareness - don't KO if we die too
  def score_destiny_bond_awareness(move, user, target)
    return 0 unless move.damagingMove?
    return 0 unless target.effects[PBEffects::DestinyBond]

    return 0 unless AdvancedAI::EndgameScenarios.can_ko?(user, target, move)

    hp_percent = user.hp.to_f / user.totalhp

    if hp_percent <= 0.3
      return -100
    elsif hp_percent <= 0.5
      return -60   # Risky trade
    else
      return -20   # We're healthy, might be worth the trade
    end
  end

  def score_sucker_punch_risk(move, user, target, skill)
    return 0 unless move.id == :SUCKERPUNCH
    return 0 unless skill >= 60

    score = 0

    status_move_count = target.moves.count { |m| m && m.statusMove? }
    total_moves = target.moves.count { |m| m }

    return 0 if total_moves == 0

    status_ratio = status_move_count.to_f / total_moves

    if status_ratio >= 0.5
      score -= 40  # Very likely to fail
    elsif status_ratio >= 0.25
      score -= 20  # Some risk
    end

    if target.hp < target.totalhp * 0.3
      score += 25  # They'll probably try to attack
    end

    has_protect = target.moves.any? { |m| m && AdvancedAI.protect_move?(m.id) }
    if has_protect
      # Sucker Punch ALWAYS fails when target uses Protect (a non-attacking move),
      # regardless of Unseen Fist — the failure is because target didn't select
      # an attacking move, NOT because of the Protect barrier.
      score -= 15  # Risk of Protect (Sucker Punch auto-fails vs non-attacks)
    end

    if target.lastMoveUsed
      last_move_data = GameData::Move.try_get(target.lastMoveUsed)
      if last_move_data && last_move_data.power > 0
        score += 15  # Pattern suggests attacking
      end
    end

    score
  end

  def score_forced_switch_items(move, user, target)
    return 0 unless move.damagingMove?
    score = 0

    if target.item_id == :EJECTBUTTON
      if target.stages[:ATTACK] >= 2 || target.stages[:SPECIAL_ATTACK] >= 2
        score += 30
      else
        score += 10  # Neutral to slightly good
      end
    end

    if target.item_id == :REDCARD
      if user.stages[:ATTACK] >= 2 || user.stages[:SPECIAL_ATTACK] >= 2
        score -= 40  # Don't lose our boosts!
      elsif user.effects[PBEffects::Substitute] && user.effects[PBEffects::Substitute] > 0
        score -= 30  # Don't lose our Sub!
      else
        score -= 10  # Generally don't want forced switch
      end
    end

    score
  end

  def estimate_incoming_damage(defender, attacker)
    return 0 unless attacker && attacker.moves

    attacker.moves.filter_map do |move|
      next unless move && move.damagingMove?
      AdvancedAI::CombatUtilities.estimate_damage(attacker, move, defender)
    end.max || 0
  end

  def score_item_disruption(move, user, target)
    score = 0

    if [:THIEF, :COVET].include?(move.id)
      return -30 if user.item && user.item != :NONE  # We already have item
      return -30 if !target.item || target.item == :NONE  # Nothing to steal
      score += 20  # Steal their item
    end

    if move.id == :CORROSIVEGAS
      score += 15 if target.item && target.item != :NONE
    end

    if move.id == :INCINERATE
      berry_items = AdvancedAI::Utilities::TYPE_RESIST_BERRIES.keys +
                    [:SITRUSBERRY, :LUMBERRY, :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY,
                     :MAGOBERRY, :WIKIBERRY, :LIECHIBERRY, :PETAYABERRY, :SALACBERRY]
      if berry_items.include?(target.item_id)
        score += 20  # Destroy their berry
      end
    end

    score
  end

  def score_moody_pressure(move, user, target)
    return 0 unless target && target.hasActiveAbility?(:MOODY)

    bonus = 0

    # Prioritize attacking Moody Pokemon - don't let them accumulate boosts
    if move.damagingMove?
      bonus += 20  # Pressure Moody before they scale

      total_boosts = 0
      GameData::Stat.each_battle do |stat|
        stage = target.stages[stat.id] rescue 0
        total_boosts += stage if stage > 0
      end
      bonus += total_boosts * 8
    end

    if [:HAZE, :CLEARSMOG].include?(move.id) &&
       AdvancedAI::Utilities.stat_reset_hits_target?(@battle, move, user, target) &&
       !AdvancedAI::Utilities.counter_shield_blocked?(@battle, move, user, target)
      total_boosts = 0
      GameData::Stat.each_battle do |stat|
        stage = target.stages[stat.id] rescue 0
        total_boosts += stage if stage > 0
      end
      bonus += total_boosts * 15
    end

    if move.id == :TAUNT
      bonus += 15
    end

    bonus
  end

  # MIRROR HERB - Don't boost if opponent will copy
  def score_setup_vs_mirror_herb(move, user, target)
    return 0 unless AdvancedAI.setup_move?(move.id)

    penalty = 0

    @battle.allOtherSideBattlers(user.index).each do |opp|
      next unless opp && !opp.fainted?

      if opp.item_id == :MIRRORHERB
        penalty -= 35  # Significant penalty

        if move.function_code.include?("Attack") && opp.attack > opp.spatk
          penalty -= 15
        end
      end

      if opp.hasActiveAbility?(:OPPORTUNIST)
        penalty -= 25
      end
    end

    penalty
  end

  # LUM BERRY TIMING - Don't status if they have Lum Berry
  def score_status_vs_berry(move, user, target)
    return 0 unless move.statusMove?
    return 0 unless target && target.opposes?(user)
    real_user = user.respond_to?(:battler) ? user.battler : user
    real_target = target.respond_to?(:battler) ? target.battler : target
    return 0 if move.pbTarget(real_user).id == :User
    berry = target.item_id if target.hasActiveItem?(target.item_id) && real_target.canConsumeBerry?

    status_codes = ["Poison", "Paralyze", "Burn", "Sleep", "Freeze", "Confuse"]
    is_status_move = status_codes.any? { |code| move.function_code.include?(code) }

    status_move_ids = [:WILLOWISP, :THUNDERWAVE, :TOXIC, :POISONPOWDER,
                       :STUNSPORE, :SLEEPPOWDER, :SPORE, :NUZZLE,
                       :GLARE, :HYPNOSIS, :DARKVOID, :YAWN, :CONFUSERAY]
    is_status_move ||= status_move_ids.include?(move.id)

    return 0 unless is_status_move

    penalty = 0

    if berry == :LUMBERRY
      penalty -= 60  # Status will be immediately cured - waste of turn!
    end

    if berry == :CHESTOBERRY
      if move.function_code.include?("Sleep") ||
         [:SPORE, :SLEEPPOWDER, :HYPNOSIS, :DARKVOID, :YAWN].include?(move.id)
        penalty -= 50
      end
    end

    case berry
    when :RAWSTBERRY
      penalty -= 40 if move.function_code.include?("Burn") || move.id == :WILLOWISP
    when :PECHABERRY
      penalty -= 40 if move.function_code.include?("Poison") || [:TOXIC, :POISONPOWDER].include?(move.id)
    when :CHERIBERRY
      penalty -= 40 if move.function_code.include?("Paralyze") || [:THUNDERWAVE, :STUNSPORE, :NUZZLE, :GLARE].include?(move.id)
    when :ASPEARBERRY
      penalty -= 40 if move.function_code.include?("Freeze")
    when :PERSIMBERRY
      penalty -= 40 if move.function_code.include?("Confuse") || move.id == :CONFUSERAY
    end

    if target.hasActiveAbility?(:OWNTEMPO) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
      if move.function_code.include?("Confuse") || move.id == :CONFUSERAY || move.id == :SWAGGER
        penalty -= 50
      end
    end

    penalty
  end

  def score_protect_utility(move, user, target)
    return 0 unless AdvancedAI.protect_move?(move.id)
    real_user = user.respond_to?(:battler) ? user.battler : user
    protect_rate = user.effects[PBEffects::ProtectRate] rescue 0
    protect_rate = protect_rate || 1
    native = move.respond_to?(:move) ? move.move : move
    if Settings::MECHANICS_GENERATION >= 6 && native.is_a?(Battle::Move::ProtectMove) &&
       native.instance_variable_get(:@sidedEffect)
      protect_rate = 1
    end

    if protect_rate >= 9
      AdvancedAI.log("Protect rejected: success chance #{(100.0 / protect_rate).round}%", "ProtectSpam")
      return -300  # Almost certainly fails
    elsif protect_rate >= 3
      penalty = -(40 * protect_rate).to_i
      penalty = [penalty, -200].max  # Cap at -200
      AdvancedAI.log("Protect penalized: rate=#{protect_rate}, penalty=#{penalty}", "ProtectSpam")
      score = penalty
    else
      score = 0
    end

    protect_uses = (AdvancedAI::MoveMemory.move_frequency(@battle, user, move.id) rescue 0)
    if protect_uses > 0
      repeat_penalty = [-40 * protect_uses, -120].max
      AdvancedAI.log("Protect used #{protect_uses}x this battle: #{repeat_penalty}", "ProtectSpam")
      score += repeat_penalty
    end

    passive_recovery =
      (user.hasActiveItem?(:LEFTOVERS) ||
       (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON)) ||
       user.effects[PBEffects::Ingrain] ||
       user.effects[PBEffects::AquaRing] ||
       (user.hasActiveAbility?(:POISONHEAL) && user.poisoned?) ||
       ((user.hasActiveAbility?(:DRYSKIN) || user.hasActiveAbility?(:RAINDISH)) &&
         [:Rain, :HeavyRain].include?(real_user.effectiveWeather)) ||
       (user.hasActiveAbility?(:ICEBODY) && [:Hail, :Snow].include?(real_user.effectiveWeather)) ||
       (@battle.field.terrain == :Grassy && real_user.affectedByTerrain?))

    if passive_recovery && real_user.canHeal?
      hp_percent = user.hp.to_f / user.totalhp
      if hp_percent < 0.9
        score += 40  # Heal up safely
        score += 20 if hp_percent < 0.5  # Critical heal
      end
    end

    if user.hasActiveAbility?(:SPEEDBOOST) || user.hasActiveAbility?(:MOODY)
      score += 50  # Free boost
    end

    wish_turns = (@battle.positions[user.index].effects[PBEffects::Wish] rescue 0)
    if wish_turns == 1 && real_user.canHeal?
      score += 80  # Protect to receive Wish is standard play
    end

    if target
      leech_seed_val = (target.effects[PBEffects::LeechSeed] rescue -1)
      curse_val      = (target.effects[PBEffects::Curse] rescue false)
      salt_cure_val  = (defined?(PBEffects::SaltCure) ? (target.effects[PBEffects::SaltCure] rescue false) : false)
      real_target = target.respond_to?(:battler) ? target.battler : target
      poison_damage = target.poisoned? && !target.hasActiveAbility?(:POISONHEAL)
      passive_damage = poison_damage || target.burned? ||
                       (leech_seed_val.is_a?(Numeric) && leech_seed_val >= 0) ||
                       curse_val ||
                       salt_cure_val

      if passive_damage && real_target.takesIndirectDamage?
        score += 45  # Let them rot
        score += 20 if target.hp < target.totalhp * 0.25 # Finish them off
      end

      perish_val = (target.effects[PBEffects::PerishSong] rescue 0)
      if perish_val.is_a?(Numeric) && perish_val > 0
        score += 60  # Stall out Perish turns
      end
    end

    if @battle.pbSideSize(0) > 1 && @battle.turnCount == 0
      score += 20  # Protect turn 1 in doubles is common
    end

    return score
  end

  def score_prankster_bonus(move, user, target = nil)
    return 0 unless user.hasActiveAbility?(:PRANKSTER)
    return 0 unless move.statusMove?

    score = 40  # Base bonus for having priority status

    high_value_moves = [:THUNDERWAVE, :WILLOWISP, :TOXIC, :REFLECT, :LIGHTSCREEN,
                        :AURORAVEIL, :TAILWIND, :TAUNT, :ENCORE, :DISABLE, :SUBSTITUTE,
                        :SPIKES, :STEALTHROCK, :TOXICSPIKES, :SPORE, :SLEEPPOWDER]

    if high_value_moves.include?(move.id)
      score += 25  # Priority disable/hazards/screens are GODLY
    end

    return score
  end

  def score_pivot_utility(move, user, target, skill)
    return 0 unless AdvancedAI::PivotMoves::ALL_PIVOTS.include?(move.id)

    return AdvancedAI::PivotMoves.evaluate_pivot(@battle, user, move, target, skill)
  end

  def score_move_repetition_penalty(move, user)
    score = 0

    last_move = user.battler.lastMoveUsed
    return 0 unless last_move  # No previous move

    if move.id == last_move
      spam_allowed = [:SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :QUIVERDANCE,  # Setup
                      :CALMMIND, :IRONDEFENSE, :AMNESIA, :AGILITY,  # More setup
                      :SHELLSMASH, :GEOMANCY, :VICTORYDANCE]  # Ultra setup

      escalating_moves = [:ROLLOUT, :ICEBALL, :FURYCUTTER, :ECHOEDVOICE]

      return 0 if spam_allowed.include?(move.id)
      return 0 if escalating_moves.include?(move.id)

      if move.damagingMove?
        score -= 15
        AdvancedAI.log("#{move.name}: -15 for repetition (attacking move)", "MoveSpam")
      end

      if move.statusMove?
        score -= 40
        AdvancedAI.log("#{move.name}: -40 for repetition (status move spam prevention)", "MoveSpam")
      end
    end

    if defined?(AdvancedAI::MoveMemory)
      frequency = AdvancedAI::MoveMemory.move_frequency(@battle, user, move.id)

      if frequency >= 3
        score -= 20  # Used 3+ times = major spam
        AdvancedAI.log("#{move.name}: -20 for frequency spam (used #{frequency} times)", "MoveSpam")
      elsif frequency >= 2
        score -= 10  # Used 2 times = minor spam
        AdvancedAI.log("#{move.name}: -10 for repeated use (used #{frequency} times)", "MoveSpam")
      end
    end

    return score
  end

  def check_priority_tier_moves(move, user, target, skill)
    return PriorityMoveResult.new unless move.statusMove?

    is_recovery = move.function_code.start_with?("HealUser")
    if move.function_code == "HealUserByTargetAttackLowerTargetAttack1" &&
       target && target.hasActiveAbility?(:LIQUIDOOZE, true)
      is_recovery = false
    end
    if skill >= 70 && !is_recovery && can_ko_opponent?(user)
      AdvancedAI.log("#{move.name}: tactical priority suppressed — can KO this turn", "Priority")
      return PriorityMoveResult.new
    end

    hp_percent = user.hp.to_f / user.totalhp
    turn = @battle.turnCount

    if [:STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB].include?(move.id)
      opponent_side = target.pbOwnSide

      if move.id == :STEALTHROCK && !opponent_side.effects[PBEffects::StealthRock]
        if turn <= 3 && hp_percent > 0.7
          return PriorityMoveResult.new(auto_select: true, priority_boost: 100)
        elsif turn <= 5 && hp_percent > 0.6
          return PriorityMoveResult.new(priority_boost: 250)
        end
      end

      if move.id == :SPIKES && opponent_side.effects[PBEffects::Spikes] < 3
        layers = opponent_side.effects[PBEffects::Spikes]
        if layers == 0 && turn <= 2 && hp_percent > 0.7
          return PriorityMoveResult.new(auto_select: true, priority_boost: 50)
        elsif layers < 3 && turn <= 4 && hp_percent > 0.6
          return PriorityMoveResult.new(priority_boost: 200)
        end
      end

      if move.id == :TOXICSPIKES && opponent_side.effects[PBEffects::ToxicSpikes] < 2
        if opponent_side.effects[PBEffects::ToxicSpikes] == 0 && turn <= 3 && hp_percent > 0.7
          return PriorityMoveResult.new(auto_select: true, priority_boost: 40)
        end
      end

      if move.id == :STICKYWEB && !opponent_side.effects[PBEffects::StickyWeb]
        if turn <= 2 && hp_percent > 0.7
          return PriorityMoveResult.new(auto_select: true, priority_boost: 60)
        end
      end
    end

    if is_recovery
      if hp_percent < 0.35
        incoming_damage_estimate = 0
        if target && target.moves
          target.moves.each do |opp_move|
            next unless opp_move && opp_move.damagingMove?
            rough_dmg = calculate_rough_damage(opp_move, target, user) rescue 0
            incoming_damage_estimate = [incoming_damage_estimate, rough_dmg].max
          end
        end

        if incoming_damage_estimate < user.hp * 0.9
          return PriorityMoveResult.new(auto_select: true, priority_boost: 200)
        end
      elsif hp_percent < 0.5
        return PriorityMoveResult.new(priority_boost: 200)
      elsif hp_percent < 0.7
        return PriorityMoveResult.new(priority_boost: 120)
      end
    end

    if [:REFLECT, :LIGHTSCREEN, :AURORAVEIL].include?(move.id)
      user_side = user.pbOwnSide

      if move.id == :REFLECT && user_side.effects[PBEffects::Reflect] == 0
        if turn <= 2 && hp_percent > 0.6
          has_physical_threat = target.moves.any? { |m| m && m.physicalMove? }
          return PriorityMoveResult.new(auto_select: true, priority_boost: 80) if has_physical_threat
        elsif turn <= 4 && hp_percent > 0.5
          return PriorityMoveResult.new(priority_boost: 180)
        end
      end

      if move.id == :LIGHTSCREEN && user_side.effects[PBEffects::LightScreen] == 0
        if turn <= 2 && hp_percent > 0.6
          has_special_threat = target.moves.any? { |m| m && m.specialMove? }
          return PriorityMoveResult.new(auto_select: true, priority_boost: 80) if has_special_threat
        elsif turn <= 4 && hp_percent > 0.5
          return PriorityMoveResult.new(priority_boost: 180)
        end
      end

      if move.id == :AURORAVEIL && user_side.effects[PBEffects::AuroraVeil] == 0
        if [:Hail, :Snow].include?(@battle.pbWeather) && turn <= 2 && hp_percent > 0.6
          return PriorityMoveResult.new(auto_select: true, priority_boost: 90)
        end
      end
    end

    if AdvancedAI.setup_move?(move.id) || move.function_code.start_with?("RaiseUser")
      if is_safe_to_setup?(user, target)
        setup_value = 200  # Base high priority

        if [:SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :QUIVERDANCE, :SHELLSMASH].include?(move.id)
          setup_value = 250  # Sweep enablers
        end

        if hp_percent > 0.7
          setup_value += 50
        end

        return PriorityMoveResult.new(priority_boost: setup_value)
      end
    end

    if [:THUNDERWAVE, :WILLOWISP, :TOXIC, :SLEEPPOWDER, :SPORE].include?(move.id)
      if target.status == :NONE
        # === TYPE IMMUNITY CHECKS ===
        # Fire-types can't be burned
        if move.id == :WILLOWISP && target.pbHasType?(:FIRE)
          return PriorityMoveResult.new  # Will fail — no boost
        end
        # Electric-types can't be paralyzed; Ground-types are immune to T-Wave
        if move.id == :THUNDERWAVE
          if target.pbHasType?(:ELECTRIC) || target.pbHasType?(:GROUND)
            return PriorityMoveResult.new  # Will fail — no boost
          end
        end
        # Poison/Steel-types can't be poisoned
        if move.id == :TOXIC
          if target.pbHasType?(:POISON) || target.pbHasType?(:STEEL)
            return PriorityMoveResult.new  # Will fail — no boost
          end
        end
        if [:SLEEPPOWDER, :SPORE].include?(move.id) && target.pbHasType?(:GRASS)
          return PriorityMoveResult.new  # Will fail — no boost
        end

        if move.id == :THUNDERWAVE
          tr_active = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
          target_moves_first = tr_active ? (target.pbSpeed < user.pbSpeed) : (target.pbSpeed > user.pbSpeed)
          if target_moves_first
            return PriorityMoveResult.new(priority_boost: 180)
          end
        end

        if move.id == :WILLOWISP && target.attack > target.spatk
          return PriorityMoveResult.new(priority_boost: 180)
        end

        if move.id == :TOXIC
          if target.defense + target.spdef > 200
            return PriorityMoveResult.new(priority_boost: 200)
          else
            return PriorityMoveResult.new(priority_boost: 140)
          end
        end

        if [:SLEEPPOWDER, :SPORE].include?(move.id)
          return PriorityMoveResult.new(priority_boost: 220)
        end
      end
    end

    if move.id == :TAILWIND && user.pbOwnSide.effects[PBEffects::Tailwind] == 0
      if turn <= 3
        return PriorityMoveResult.new(priority_boost: 160)
      end
    end

    return PriorityMoveResult.new
  end

  def score_role_synergy(move, user, target, skill)
    return 0 unless user && target && move
    return 0 unless skill >= 55  # Only for mid+ skill trainers

    primary_role, secondary_role = AdvancedAI.detect_roles(user)
    return 0 if primary_role == :balanced && secondary_role.nil?

    score = 0
    move_id = move.id

    resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)

    if primary_role == :sweeper || secondary_role == :sweeper
      if AdvancedAI.setup_move?(move_id)
        score += 20
        user_boosts = user.stages.values.count { |s| s > 0 }
        score += 15 if user_boosts == 0 && user.hp > user.totalhp * 0.7
      end

      if AdvancedAI.priority_move?(move_id) && move.damagingMove?
        score += 15
        score += 10 if user.hp < user.totalhp * 0.4
      end

      if move.damagingMove?
        type_mod = Effectiveness.calculate(resolved_type, *target.pbTypes(true))
        score += 10 if Effectiveness.super_effective?(type_mod)
      end

      if move.statusMove? && !AdvancedAI.setup_move?(move_id)
        score -= 10 unless [:SUBSTITUTE, :TAUNT].include?(move_id)
      end
    end

    if primary_role == :wall || secondary_role == :wall
      if AdvancedAI.healing_move?(move_id)
        score += 20
        hp_percent = user.hp.to_f / user.totalhp
        score += 15 if hp_percent < 0.65  # More urgent when damaged
      end

      if AdvancedAI.status_move?(move_id) || [:TOXIC, :WILLOWISP, :THUNDERWAVE].include?(move_id)
        if target.status == :NONE
          # Don't boost status moves the target is immune to
          immune = false
          immune = true if move_id == :TOXIC && (target.pbHasType?(:POISON) || target.pbHasType?(:STEEL))
          immune = true if move_id == :WILLOWISP && target.pbHasType?(:FIRE)
          immune = true if move_id == :THUNDERWAVE && (target.pbHasType?(:ELECTRIC) || target.pbHasType?(:GROUND))
          score += 15 unless immune
        end
      end

      if [:WHIRLWIND, :ROAR, :DRAGONTAIL, :CIRCLETHROW].include?(move_id) &&
         AdvancedAI::Utilities.phazing_possible?(@battle, move, user, target)
        score += 15
      end

      # Walls don't benefit much from setup (except Iron Defense / Calm Mind on some)
      if AdvancedAI.setup_move?(move_id)
        setup_data = AdvancedAI::MoveCategories.get_setup_data(move_id)
        unless setup_data && [:defense, :defense_spdef, :spdef, :spatk_spdef].include?(setup_data[:stat])
          score -= 10  # Offensive setup is suboptimal for walls
        end
      end
    end

    if primary_role == :tank || secondary_role == :tank
      if move.damagingMove? && user.pbHasType?(resolved_type)
        score += 10  # STAB reliability matters for tanks
        score += 10 if AdvancedAI::CombatUtilities.resolve_move_power(move) >= 80  # Prefer solid power
      end

      if AdvancedAI.healing_move?(move_id)
        score += 15
        hp_percent = user.hp.to_f / user.totalhp
        score += 10 if hp_percent < 0.55
      end

      if move.damagingMove?
        type_mod = Effectiveness.calculate(resolved_type, *target.pbTypes(true))
        score += 10 if Effectiveness.super_effective?(type_mod)
      end
    end

    if primary_role == :support || secondary_role == :support
      if AdvancedAI.screen_move?(move_id)
        score += 25
        # Check if screen is already active (don't re-set)
        own_side = user.index.even? ? @battle.sides[0] : @battle.sides[1]
        if move_id == :REFLECT && own_side.effects[PBEffects::Reflect] > 0
          score -= 40  # Already active
        elsif move_id == :LIGHTSCREEN && own_side.effects[PBEffects::LightScreen] > 0
          score -= 40  # Already active
        elsif move_id == :AURORAVEIL && own_side.effects[PBEffects::AuroraVeil] > 0
          score -= 40  # Already active
        end
      end

      if AdvancedAI.hazard_move?(move_id)
        score += 25
        score += 15 if @battle.turnCount <= 3
        opponent_side = user.index.even? ? @battle.sides[1] : @battle.sides[0]
        if move_id == :STEALTHROCK && opponent_side.effects[PBEffects::StealthRock]
          score -= 50  # Already up — DON'T use again
        end
        if [:SPIKES, :TOXICSPIKES].include?(move_id)
          max_layers = move_id == :SPIKES ? 3 : 2
          current = move_id == :SPIKES ? opponent_side.effects[PBEffects::Spikes] : opponent_side.effects[PBEffects::ToxicSpikes]
          score -= 50 if current >= max_layers  # Maxed out
        end
      end

      if [:TOXIC, :WILLOWISP, :THUNDERWAVE, :TAUNT, :ENCORE].include?(move_id)
        score += 20 if target.status == :NONE || [:TAUNT, :ENCORE].include?(move_id)
      end

      if [:WISH, :HEALBELL, :AROMATHERAPY].include?(move_id)
        score += 20
      end

      if move.damagingMove? && AdvancedAI::CombatUtilities.resolve_move_power(move) < 70
        score -= 10  # Weak attacks are not the support's focus
      end
    end

    if primary_role == :wallbreaker || secondary_role == :wallbreaker
      if move.damagingMove?
        eff_power = AdvancedAI::CombatUtilities.resolve_move_power(move)
        score += 15 if eff_power >= 100
        score += 10 if eff_power >= 80 && eff_power < 100

        type_mod = Effectiveness.calculate(resolved_type, *target.pbTypes(true))
        score += 15 if Effectiveness.super_effective?(type_mod)

        score += 10 if user.pbHasType?(resolved_type)

        if move.physicalMove? && user.attack > user.spatk
          score += 5  # Using better offensive stat
        elsif move.specialMove? && user.spatk > user.attack
          score += 5
        end
      end

      if move.statusMove? && ![:SWORDSDANCE, :NASTYPLOT].include?(move_id)
        score -= 15 unless AdvancedAI.setup_move?(move_id)  # One setup move is OK
      end
    end

    if primary_role == :pivot || secondary_role == :pivot
      if AdvancedAI.pivot_move?(move_id)
        has_type_disadvantage = false
        target.moves.each do |t_move|
          next unless t_move && t_move.damagingMove? && t_move.type
          resolved_t_type = AdvancedAI::CombatUtilities.resolve_move_type(target, t_move)
          type_mod = Effectiveness.calculate(resolved_t_type, *user.pbTypes(true))
          has_type_disadvantage = true if Effectiveness.super_effective?(type_mod)
        end
        score += 25 if has_type_disadvantage  # GET OUT with momentum
        score += 10 unless has_type_disadvantage  # Still good for scouting
      end

      if !AdvancedAI.pivot_move?(move_id) && move.damagingMove?
        has_type_disadvantage = false
        target.moves.each do |t_move|
          next unless t_move && t_move.damagingMove? && t_move.type
          resolved_t_type = AdvancedAI::CombatUtilities.resolve_move_type(target, t_move)
          type_mod = Effectiveness.calculate(resolved_t_type, *user.pbTypes(true))
          has_type_disadvantage = true if Effectiveness.super_effective?(type_mod)
        end
        score -= 10 if has_type_disadvantage  # Should be pivoting out, not attacking
      end
    end

    if primary_role == :lead || secondary_role == :lead
      if @battle.turnCount <= 1
        if AdvancedAI.hazard_move?(move_id)
          score += 30  # Top priority on turn 1
          score += 10 if move_id == :STEALTHROCK
        end

        if move_id == :TAUNT
          score += 25
          opp_role, _ = AdvancedAI.detect_roles(target)
          score += 15 if [:lead, :support, :wall, :stall].include?(opp_role)
        end

        score += 20 if move_id == :FAKEOUT
      end

      if @battle.turnCount > 2
        opponent_side = user.index.even? ? @battle.sides[1] : @battle.sides[0]
        hazards_set = opponent_side.effects[PBEffects::StealthRock] ||
                      opponent_side.effects[PBEffects::Spikes] > 0 ||
                      opponent_side.effects[PBEffects::ToxicSpikes] > 0
        if hazards_set
          score += 20 if AdvancedAI.pivot_move?(move_id)
          score -= 20 if AdvancedAI.hazard_move?(move_id)
        end
      end
    end

    return score
  end

  def score_stall_synergy(move, user, target)
    return 0 unless user && target && move

    return 0 unless AdvancedAI.has_stall_moveset?(user)

    stall_data = AdvancedAI.get_stall_data(move.id)
    return 0 unless stall_data

    score = 0

    score += 30  # Baseline: stall moves are always valuable for stall mons

    case stall_data[:role]
    when :passive_damage
      if [:TOXIC, :WILLOWISP, :THUNDERWAVE].include?(move.id)
        if move.id == :TOXIC && (target.pbHasType?(:POISON) || target.pbHasType?(:STEEL))
          return 0  # Poison/Steel immune to Toxic — no stall synergy
        elsif move.id == :WILLOWISP && target.pbHasType?(:FIRE)
          return 0  # Fire immune to burn — no stall synergy
        elsif move.id == :THUNDERWAVE && target.pbHasType?(:ELECTRIC)
          return 0  # Electric immune to paralysis — no stall synergy
        elsif move.id == :THUNDERWAVE && target.pbHasType?(:GROUND)
          return 0  # Ground immune to Thunder Wave — no stall synergy
        end
      end
      if target.status == :NONE
        score += 40  # Applying status IS the stall gameplan

        has_protect = user.battler.moves.any? { |m| m && AdvancedAI.protect_move?(m.id) }
        score += 25 if has_protect

        has_recovery = user.battler.moves.any? { |m| m && AdvancedAI.healing_move?(m.id) }
        score += 20 if has_recovery
      end

      if move.id == :LEECHSEED
        leech_seed_val = (target.effects[PBEffects::LeechSeed] rescue -1)
        if leech_seed_val.is_a?(Numeric) && leech_seed_val < 0
          score += 35
          score += 20 if target.totalhp > 300
        end
      end

    when :recovery
      hp_percent = user.hp.to_f / user.totalhp

      if hp_percent < 0.75
        score += 30  # Stall mons want to stay near full HP
      end

      leech_seed_val = (target.effects[PBEffects::LeechSeed] rescue -1)
      target_has_passive = target.poisoned? || target.burned? ||
                           (leech_seed_val.is_a?(Numeric) && leech_seed_val >= 0)
      if target_has_passive
        score += 35  # We're winning the long game, just stay alive
      end

      if move.id == :WISH
        wish_turns = (@battle.positions[user.index].effects[PBEffects::Wish] rescue 0)
        if wish_turns.is_a?(Numeric) && wish_turns == 0 && hp_percent < 0.85
          score += 25  # Set up future healing proactively
        end
      end

    when :protection
      leech_seed_val = (target.effects[PBEffects::LeechSeed] rescue -1)
      target_has_passive = target.poisoned? || target.burned? ||
                           (leech_seed_val.is_a?(Numeric) && leech_seed_val >= 0)
      if target_has_passive
        score += 20  # Protect is the core of the Toxic stall loop
      end

    when :utility
      if move.id == :SCALD && target.status == :NONE && target.attack > target.spatk
        score += 25  # Scald burn chance is the stall gameplan vs physical mons
      end

      if [:WHIRLWIND, :ROAR].include?(move.id) &&
         AdvancedAI::Utilities.phazing_possible?(@battle, move, user, target)
        opponent_side = user.index.even? ? @battle.sides[1] : @battle.sides[0]
        if opponent_side.effects[PBEffects::StealthRock] ||
           opponent_side.effects[PBEffects::Spikes] > 0
          score += 30  # Phaze into hazards
        end
        target_boosts = target.stages.values.count { |s| s > 0 }
        score += 25 if target_boosts >= 2
      end

    when :hazard
      score += 15  # Stall teams rely on chip damage
    end

    return score
  end

  TRAPPING_MOVES = [
    :MEANLOOK, :BLOCK, :SPIDERWEB, :SPIRITSHACKLE, :ANCHORSHOT, :JAWLOCK,
    :THOUSANDWAVES, :OCTOLOCK, :BIND, :WRAP,
    :FIRESPIN, :WHIRLPOOL, :SANDTOMB, :CLAMP, :MAGMASTORM,
    :INFESTATION, :THUNDERCAGE, :SNAPTRAP
  ]

  def score_trapping_moves(move, user, target, skill)
    return 0 unless target
    return 0 unless TRAPPING_MOVES.include?(move.id)
    score = 0

    if AdvancedAI.has_shed_shell?(target)
      AdvancedAI.log("  Trapping #{target.name}: -30 (has Shed Shell)", "Tactic")
      return -30  # Trapping is nearly useless against Shed Shell holders
    end

    # Don't trap if target is Ghost (can escape Mean Look/Block)
    if [:MEANLOOK, :BLOCK].include?(move.id)
      target_types = target.respond_to?(:pbTypes) ? target.pbTypes(true) : target.types rescue [:NORMAL]
      return -30 if target_types.include?(:GHOST)
    end

    incoming = estimate_incoming_damage(user, target)
    if incoming < user.totalhp * 0.2
      score += 40  # They can't break us, we win this 1v1
      AdvancedAI.log("  Trapping #{target.name}: +40 (favorable)", "Tactic")
    elsif incoming < user.totalhp * 0.35
      score += 20
    elsif incoming > user.totalhp * 0.5
      score -= 20  # Don't trap what kills us
    end

    user.moves.each do |m|
      next unless m
      score += 15 if m.id == :TOXIC
      score += 10 if m.id == :PERISHSONG
    end if user.respond_to?(:moves)

    score += 10 if skill >= 80
    score
  end

  def score_choice_prelock(move, user, target)
    return 0 unless target
    user_battler = user.respond_to?(:battler) ? user.battler : user
    item = user_battler.item_id rescue nil
    return 0 unless [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(item) && user_battler.hasActiveItem?(item)

    return 0 if user_battler.effects[PBEffects::ChoiceBand]

    score = 0

    if AdvancedAI.pivot_move?(move.id)
      score += 25
      AdvancedAI.log("  Choice pre-lock: +25 pivot", "Tactic")
    end

    if move.damagingMove?
      neutral_or_better = 0
      choice_resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
      @battle.allOtherSideBattlers(user.index).each do |opp|
        next if !opp || opp.fainted?
        opp_types = opp.respond_to?(:pbTypes) ? opp.pbTypes(true) : opp.types rescue [:NORMAL]
        eff = Effectiveness.calculate(choice_resolved_type, *opp_types) rescue Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
        neutral_or_better += 1 if eff >= Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      score += 15 if neutral_or_better >= 2
    end

    if move.statusMove? && !AdvancedAI.pivot_move?(move.id)
      score -= 40
      AdvancedAI.log("  Choice pre-lock: -40 (status on Choice)", "Tactic")
    end

    score
  end

  def score_cleric_urgency(move, user)
    user = user.battler if user.respond_to?(:battler)
    move = move.move if move.respond_to?(:move)
    return 0 unless [:HEALBELL, :AROMATHERAPY].include?(move.id)
    return 0 unless AdvancedAI::WinConditions.move_available?(user, move)
    score = 0
    statused_count = 0
    critical_statused = 0
    preview = @battle.clone
    native = Battle::Move.from_pokemon_move(preview, Pokemon::Move.new(move.id))
    native.calcType = native.pbCalcType(user)
    active = @battle.allSameSideBattlers(user.index)
    @battle.pbParty(user.index).each do |pkmn|
      next unless pkmn && pkmn.able?
      recipient = active.find { |b| b.pokemon.equal?(pkmn) }
      beneficiary = recipient || pkmn
      next if beneficiary.status == :NONE
      if recipient && native.pbTarget(user).num_targets > 0
        next unless @battle.pbMoveCanTarget?(user.index, recipient.index, native.pbTarget(user))
        next if recipient.index != user.index && recipient.effects[PBEffects::Substitute] > 0 && !native.ignoresSubstitute?(user)
        preview.moldBreaker = (user.hasMoldBreaker? || user.hasActiveAbility?(:MYCELIUMMIGHT)) && !recipient.hasActiveItem?(:ABILITYSHIELD)
        next if native.pbImmunityByAbility(user, recipient, false)
      end
      statused_count += 1
      critical_statused += 1 if beneficiary.attack >= 100 || beneficiary.spatk >= 100 || beneficiary.speed >= 100
    end

    if statused_count == 0
      score -= 80  # Nobody needs cleansing
    elsif statused_count == 1
      score += 15
    elsif statused_count == 2
      score += 35
    else
      score += 55  # Multiple teammates cured
    end
    score += critical_statused * 15

    AdvancedAI.log("  Cleric: #{statused_count} statused, bonus=#{score}", "Tactic") if statused_count > 0
    score
  end

  def score_user_destiny_bond(move, user, target)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    move = move.move if move.respond_to?(:move)
    return 0 unless move.id == :DESTINYBOND
    return 0 unless target
    return 0 unless AdvancedAI::WinConditions.move_available?(user, move)
    return 0 if Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBond]
    score = 0

    user_hp_pct = user.hp.to_f / user.totalhp
    user_spd = user.respond_to?(:pbSpeed) ? user.pbSpeed : (user.speed rescue 80)
    target_spd = target.respond_to?(:pbSpeed) ? target.pbSpeed : (target.speed rescue 80)
    trick_room = (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
    user_moves_first = trick_room ? (user_spd < target_spd) : (user_spd > target_spd)

    if user_hp_pct <= 0.25
      score += 60  # About to die — take them with us
      score += 20 if user_moves_first
      score -= 10 unless user_moves_first
    elsif user_hp_pct <= 0.40
      score += 30
    else
      score -= 40  # Too healthy
    end

    target_boosts = target.stages.values.sum rescue 0
    score += 15 if target_boosts >= 3

    AdvancedAI.log("  User Destiny Bond: #{score} (HP=#{(user_hp_pct*100).to_i}%)", "Tactic") if score > 0
    score
  end

  def score_ghost_curse(move, user, target)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    move = move.move if move.respond_to?(:move)
    return 0 unless move.id == :CURSE
    return 0 unless target

    user_types = user.respond_to?(:pbTypes) ? user.pbTypes(true) : user.types rescue [:NORMAL]
    return 0 unless user_types.include?(:GHOST)  # Only Ghost Curse is different

    return 0 unless AdvancedAI::WinConditions.move_available?(user, move)
    return 0 if target.effects[PBEffects::Curse] || !target.takesIndirectDamage?

    score = 0
    user_hp_pct = user.hp.to_f / user.totalhp

    if user_hp_pct <= 0.3
      score -= 50
    elsif user_hp_pct <= 0.55
      score += 10
    else
      score += 40
    end

    if AdvancedAI.has_healing_move?(@battle, target)
      score += 20
    end

    target_roles = AdvancedAI.detect_roles(target) rescue [:balanced]
    if target_roles.include?(:stall) || target_roles.include?(:wall)
      score += 25
      AdvancedAI.log("  Ghost Curse vs stall: +25", "Tactic")
    end

    target_memory = AdvancedAI.get_memory(@battle, target) rescue nil
    if target_memory && target_memory[:moves]
      score -= 20 if target_memory[:moves].any? { |m| AdvancedAI.pivot_move?(m) }
    end

    score
  end

  # #11: Counter / Mirror Coat intelligence
  # Spread move usage instead of burning one move down to Struggle. Small
  # enough to never outweigh a KO (+100), big enough to break near-ties.
  # Substitute / Focus Punch as a plan: the Sub shields the charge turn.
  def score_substitute_combo(move, user, target)
    sub_up = (user.effects[PBEffects::Substitute].to_i > 0 rescue false)
    knows_punch = user.battler.moves.any? { |m| m && m.id == :FOCUSPUNCH } rescue false
    case move.id
    when :FOCUSPUNCH
      return sub_up ? 70 : -60
    when :SUBSTITUTE
      score = 0
      score += 40 if knows_punch
      score += 15 if (user.pbSpeed > target.pbSpeed rescue false)
      return score
    end
    0
  end

  def score_pp_conservation(move, user, target)
    total = move.total_pp.to_i
    return 0 if total <= 0            # Struggle / PP-less move
    left = move.pp.to_i
    return 0 if left <= 0             # unusable anyway, handled elsewhere
    # Pressure drains 2 PP per use, so the reserve is effectively halved.
    if target && !AdvancedAI::Utilities.ignores_ability?(user, move, target) &&
       (target.hasActiveAbility?(:PRESSURE) rescue false)
      left = (left / 2.0).ceil
    end
    return -25 if left <= 1
    return -12 if left <= 2
    return -8  if left <= (total * 0.25).ceil
    0
  end

  def score_counter_mirror_coat(move, user, target)
    return 0 unless [:COUNTER, :MIRRORCOAT, :METALBURST].include?(move.id)
    return 0 unless target
    score = 0

    # Must survive the incoming hit
    incoming = estimate_incoming_damage(user, target)
    if incoming >= user.hp
      return -60  # Dead before reflecting
    end

    predicted_move = AdvancedAI.predict_next_move(@battle, target) rescue nil
    if predicted_move
      pred_data = GameData::Move.try_get(predicted_move)
      if pred_data
        if move.id == :COUNTER && pred_data.category == 0  # Physical
          score += 20
          AdvancedAI.log("  Counter vs predicted physical: +20", "Tactic")
        elsif move.id == :MIRRORCOAT && pred_data.category == 1  # Special
          score += 20
          AdvancedAI.log("  Mirror Coat vs predicted special: +20", "Tactic")
        elsif move.id == :METALBURST && pred_data.power > 0
          score += 15  # Metal Burst reflects both
        elsif move.id == :COUNTER && pred_data.category != 0  # Not physical
          score -= 40  # Wrong type
        elsif move.id == :MIRRORCOAT && pred_data.category != 1  # Not special
          score -= 40
        end
      end
    else
      if move.id == :COUNTER && target.attack > target.spatk
        score += 10
      elsif move.id == :MIRRORCOAT && target.spatk > target.attack
        score += 10
      elsif move.id == :METALBURST
        score += 8  # Works against either
      end
    end

    uses = (AdvancedAI::MoveMemory.move_frequency(@battle, user, move.id) rescue 0)
    score += [-40 * uses, -120].max if uses > 0

    score += 10 if user.hp > user.totalhp * 0.7  # More HP = bigger reflect
    score
  end

  def score_disable_optimization(move, user, target)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    move = move.move if move.respond_to?(:move)
    return 0 unless move.id == :DISABLE
    return 0 unless target
    return 0 unless AdvancedAI::WinConditions.move_available?(user, move)
    return 0 if AdvancedAI::Utilities.counter_priority_blocked?(@battle, move, user, target)
    return 0 if AdvancedAI::Utilities.counter_shield_blocked?(@battle, move, user, target)
    preview = @battle.clone
    native = Battle::Move.from_pokemon_move(preview, Pokemon::Move.new(move.id))
    native.calcType = native.pbCalcType(user)
    preview.moldBreaker = AdvancedAI::Utilities.ignores_ability?(user, native, target)
    return 0 if target.effects[PBEffects::MagicCoat]
    return 0 if target.hasActiveAbility?(:MAGICBOUNCE) && !preview.moldBreaker
    return 0 if native.pbImmunityByAbility(user, target, false)
    return 0 if native.pbFailsAgainstTarget?(user, target, false)
    score = 0

    last_used = target.respond_to?(:lastRegularMoveUsed) ? target.lastRegularMoveUsed : nil
    last_used ||= AdvancedAI.last_move(@battle, target) rescue nil
    return -30 unless last_used  # Can't Disable without target using a move

    last_data = GameData::Move.try_get(last_used)
    return -20 unless last_data

    resolved_power = AdvancedAI::CombatUtilities.resolve_move_power(last_data)
    if resolved_power >= 100
      score += 40  # Disabling a nuke
    elsif resolved_power >= 70
      score += 25
    elsif AdvancedAI.setup_move?(last_used)
      score += 35
    elsif AdvancedAI.healing_move?(last_used)
      score += 30
    elsif last_data.power == 0  # Status move (GameData::Move has no .statusMove?)
      score += 15
    else
      score += 10
    end

    memory = AdvancedAI.get_memory(@battle, target) rescue nil
    if memory && memory[:moves] && memory[:moves].length <= 2
      score += 15
    end

    AdvancedAI.log("  Disable #{last_used}: +#{score}", "Tactic") if score > 0
    score
  end

  def score_healing_wish_target(move, user)
    return 0 unless [:HEALINGWISH, :LUNARDANCE].include?(move.id)

    user_hp_pct = user.hp.to_f / user.totalhp
    return 0 if user_hp_pct > 0.45  # Already handled in Special_Moves

    best_value = 0
    active = @battle.allSameSideBattlers(user.index).map { |b| b.pokemon }
    @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _index|
      next if !pkmn || pkmn.fainted? || pkmn.egg?
      next if active.include?(pkmn)

      hp_pct = pkmn.hp.to_f / pkmn.totalhp
      needs_pp = move.id == :LUNARDANCE && pkmn.moves.any? { |m| m && m.pp < m.total_pp / 2 }
      next if hp_pct > 0.8 && pkmn.status == :NONE && !needs_pp

      value = 0
      bst = pkmn.attack + pkmn.spatk + pkmn.speed
      value += ((1.0 - hp_pct) * 30).to_i
      value += 20 if bst >= 300
      value += 15 if pkmn.status != :NONE
      value += 10 if needs_pp

      best_value = value if value > best_value
    end

    AdvancedAI.log("  #{move.name} teammate value: #{best_value}", "Tactic") if best_value > 0
    best_value.to_i
  end

  def score_mixed_attacker(move, user, target)
    return 0 unless target && move.damagingMove?
    score = 0

    if move.physicalMove? && target.spdef < target.defense * 0.75
      score -= 5  # A special move would hit harder
    elsif move.specialMove? && target.defense < target.spdef * 0.75
      score -= 5  # A physical move would hit harder
    end

    if [:PSYSHOCK, :PSYSTRIKE, :SECRETSWORD].include?(move.id)
      if target.defense < target.spdef
        score += 15  # Exploiting lower Def
        AdvancedAI.log("  Mixed: #{move.name} exploits lower Def (+15)", "Tactic")
      end
    end

    score
  end

  def score_transform_ditto(move, user, target)
    return 0 unless move.id == :TRANSFORM
    return 0 unless target
    score = 0

    target_bst = (target.attack + target.defense + target.spatk + target.spdef + target.speed) rescue 300
    score += 30 if target_bst >= 500
    score += 15 if target_bst >= 400 && target_bst < 500

    target_boosts = target.stages.values.sum rescue 0
    if target_boosts >= 3
      score += 40
      AdvancedAI.log("  Transform copies +#{target_boosts} boosts! (+40)", "Tactic")
    elsif target_boosts >= 1
      score += 15
    elsif target_boosts < 0
      score -= 20
    end

    score -= 10 if target.moves.count { |m| m && m.power > 0 } <= 2
    score
  end
end

AdvancedAI.log("Move Scorer loaded", "Scorer")
AdvancedAI.log("  - Moody pressure logic", "Scorer")
AdvancedAI.log("  - Mirror Herb awareness", "Scorer")
AdvancedAI.log("  - Lum Berry timing", "Scorer")

Battle::AI::Handlers::MoveFailureCheck.add("AttackerFaintsIfUserFaints",
  proc { |move, user, ai, battle|
    Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBond]
  }
)

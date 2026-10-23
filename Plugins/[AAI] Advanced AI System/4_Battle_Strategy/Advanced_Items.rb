# Advanced AI System - Advanced Item Intelligence

module AdvancedAI
  PINCH_BERRIES = {
    :SITRUSBERRY  => 0.50,  # Heals when â‰¤50% HP
    :ORANBERRY    => 0.50,  # Heals 10 HP
    :FIGYBERRY    => 0.25,  # Heals 1/3 HP at 25%
    :WIKIBERRY    => 0.25,  #
    :MAGOBERRY    => 0.25,  #
    :AGUAVBERRY   => 0.25,  #
    :IAPAPABERRY  => 0.25,  #
    :LIECHIBERRY  => 0.25,  # +1 Atk
    :PETAYABERRY  => 0.25,  # +1 SpAtk
    :SALACBERRY   => 0.25,  # +1 Speed
    :GANLONBERRY  => 0.25,  # +1 Def
    :APICOTBERRY  => 0.25,  # +1 SpDef
    :STARFBERRY   => 0.25,  # +2 random stat
    :CUSTAPBERRY  => 0.25,  # Priority
  }

  TYPE_RESIST_BERRIES = {
    :OCCABERRY    => :FIRE,
    :PASSHOBERRY  => :WATER,
    :WACANBERRY   => :ELECTRIC,
    :RINDOBERRY   => :GRASS,
    :YACHEBERRY   => :ICE,
    :CHOPLEBERRY  => :FIGHTING,
    :KEBIABERRY   => :POISON,
    :SHUCABERRY   => :GROUND,
    :COBABERRY    => :FLYING,
    :PAYAPABERRY  => :PSYCHIC,
    :TANGABERRY   => :BUG,
    :CHARTIBERRY  => :ROCK,
    :KASIBBERRY   => :GHOST,
    :HABANBERRY   => :DRAGON,
    :COLBURBERRY  => :DARK,
    :BABIRIBERRY  => :STEEL,
    :CHILANBERRY  => :NORMAL,
    :ROSELIBERRY  => :FAIRY,
  }
end

class Battle::AI

  alias_method :advanced_items_pbRegisterMove, :pbRegisterMove unless method_defined?(:advanced_items_pbRegisterMove) || private_method_defined?(:advanced_items_pbRegisterMove)
  def pbRegisterMove(user, move)
    score = advanced_items_pbRegisterMove(user, move)

    return score unless user && move

    target_data = move.pbTarget(user) rescue nil
    targets = []
    if target_data && target_data.num_targets > 0
      targets = @_resolved_targets || [@_resolved_target].compact
    end
    targets.each do |target|
      next unless target && !target.fainted?
      next unless target.opposes?(user)

      if AdvancedAI::PINCH_BERRIES.key?(target.item_id)
        score += evaluate_pinch_berry(user, move, target)
      end

      if AdvancedAI::TYPE_RESIST_BERRIES.key?(target.item_id)
        score += evaluate_resist_berry(user, move, target)
      end

      if [:EJECTBUTTON, :REDCARD].include?(target.item_id)
        score += evaluate_eject_mechanics(user, move, target)
      end

      if target.item_id == :AIRBALLOON
        score += evaluate_air_balloon(user, move, target)
      end

      if target.item_id == :WEAKNESSPOLICY && move.damagingMove?
        score += evaluate_weakness_policy(user, move, target)
      end

      if target.item_id == :EJECTPACK
        score += evaluate_eject_pack(user, move, target)
      end

      if target.item_id == :ROCKYHELMET || target.hasActiveAbility?(:IRONBARBS) || target.hasActiveAbility?(:ROUGHSKIN)
        score += evaluate_contact_damage(user, move, target)
      end
    end

    return score
  end

  def evaluate_pinch_berry(user, move, target)
    return 0 unless target.item && target.itemActive?
    return 0 unless target.canConsumeBerry?
    return 0 unless move.damagingMove?

    score = 0
    berry_id = target.item_id
    activation_threshold = AdvancedAI::PINCH_BERRIES[berry_id]

    return 0 unless activation_threshold

    # Gluttony: pinch berries activate at 50% instead of 25%
    if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:GLUTTONY) && activation_threshold < 0.50
      activation_threshold = 0.50
    end

    hp_percent = target.hp.to_f / target.totalhp
    rough_damage = AdvancedAI::CombatUtilities.estimate_damage(user, move, target, as_percent: true)
    hp_after = hp_percent - rough_damage

    will_trigger = (hp_after > 0 && hp_percent > activation_threshold && hp_after <= activation_threshold)

    if will_trigger
      case berry_id
      when :ORANBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY
        score -= 20
        AdvancedAI.log("  #{berry_id}: -20 (triggers heal)", "Items")
      when :LIECHIBERRY, :PETAYABERRY, :SALACBERRY, :GANLONBERRY, :APICOTBERRY, :STARFBERRY
        score -= 35
        AdvancedAI.log("  #{berry_id}: -35 (triggers stat boost)", "Items")

      when :CUSTAPBERRY
        score -= 10
        AdvancedAI.log("  Custap Berry: -10 (grants priority)", "Items")
      end
    end

    return score
  end

  def evaluate_resist_berry(user, move, target)
    return 0 unless target.item && target.itemActive?
    return 0 unless target.canConsumeBerry?
    return 0 unless move.damagingMove?

    score = 0
    berry_id = target.item_id
    resisted_type = AdvancedAI::TYPE_RESIST_BERRIES[berry_id]

    resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
    if resolved_type == resisted_type
      type_mod = Effectiveness.calculate(resolved_type, *target.pbTypes(true))

      if Effectiveness.super_effective?(type_mod) || (berry_id == :CHILANBERRY && !Effectiveness.ineffective?(type_mod))
        score -= 25
        AdvancedAI.log("  #{berry_id}: -25 (reduces damage)", "Items")

        rough_damage = AdvancedAI::CombatUtilities.estimate_damage(user, move, target, as_percent: true)
        halved_damage = rough_damage * 0.5

        if halved_damage >= target.hp.to_f / target.totalhp
          score += 40  # Still KO
          AdvancedAI.log("  But still KOs: +40", "Items")
        end
      end
    end

    return score
  end

  def evaluate_eject_mechanics(user, move, target)
    return 0 unless target.item && target.itemActive?
    return 0 unless move.damagingMove?

    score = 0
    item_id = target.item_id
    damage = AdvancedAI::CombatUtilities.estimate_damage(user, move, target)
    return 0 if damage <= 0 || damage >= target.hp
    return 0 if user.hasActiveAbility?(:SHEERFORCE) && move.addlEffect.to_i > 0
    switcher = item_id == :EJECTBUTTON ? target : user
    return 0 unless @battle.pbCanChooseNonActive?(switcher.index)
    if item_id == :REDCARD
      return 0 if user.effects[PBEffects::Ingrain]
      return 0 if user.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
    end

    if item_id == :EJECTBUTTON
      hp_percent = target.hp.to_f / target.totalhp

      if hp_percent < 0.4
        score += 15
        AdvancedAI.log("  Eject Button (weak target): +15 (forces out)", "Items")
      else
        score -= 20
        AdvancedAI.log("  Eject Button: -20 (free switch)", "Items")
      end

    elsif item_id == :REDCARD
      score -= 30
      AdvancedAI.log("  Red Card: -30 (forces us out)", "Items")

      if user.hp < user.totalhp * 0.3
        score += 25  # Fine, we wanted out
        AdvancedAI.log("  But low HP: +25 (wanted to switch)", "Items")
      end
    end

    return score
  end

  def evaluate_air_balloon(user, move, target)
    return 0 unless target.item && target.itemActive?
    return 0 unless move.damagingMove?

    score = 0

    if AdvancedAI::CombatUtilities.resolve_move_type(user, move) == :GROUND && target.airborne?
      score -= 80
      AdvancedAI.log("  Air Balloon: -80 (Ground immunity)", "Items")
    else
      score += 15
      AdvancedAI.log("  Air Balloon: +15 (pop it!)", "Items")

      if user.moves.any? { |m| m && m.type == :GROUND }
        score += 10
        AdvancedAI.log("  Have Ground move: +10 (follow-up)", "Items")
      end
    end

    return score
  end

  def evaluate_weakness_policy(user, move, target)
    return 0 unless target.item && target.itemActive?
    return 0 unless move.damagingMove?

    score = 0
    resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
    type_mod = Effectiveness.calculate(resolved_type, *target.pbTypes(true))

    if Effectiveness.super_effective?(type_mod)
      rough_damage = AdvancedAI::CombatUtilities.estimate_damage(user, move, target, as_percent: true)

      if rough_damage >= target.hp.to_f / target.totalhp
        score += 30
        AdvancedAI.log("  Weakness Policy: +30 (KO before trigger)", "Items")
      else
        score -= 50
        AdvancedAI.log("  Weakness Policy: -50 (triggers +2/+2!)", "Items")

        if target.attack > 100 || target.spatk > 100
          score -= 30
          AdvancedAI.log("  High offense: -30 (becomes unstoppable)", "Items")
        end
      end
    end

    return score
  end

  def evaluate_eject_pack(user, move, target)
    return 0 unless target.item && target.itemActive?
    return 0 unless move.function_code.start_with?("LowerTarget")

    score = 0

    score -= 35
    AdvancedAI.log("  Eject Pack: -35 (escapes stat drop)", "Items")

    positive_boost_sum = target.stages.values.select { |v| v > 0 }.sum
    if positive_boost_sum >= 2
      score += 40  # Reset their boosts
      AdvancedAI.log("  But removes boosts: +40", "Items")
    end

    return score
  end

  def evaluate_contact_damage(user, move, target)
    return 0 unless move.damagingMove?
    return 0 unless move.pbContactMove?(user) && user.affectedByContactEffect?
    return 0 unless user.takesIndirectDamage?
    return 0 unless target.hasActiveItem?(:ROCKYHELMET) || target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])

    score = 0

    user_hp_percent = user.hp.to_f / user.totalhp

    if user_hp_percent < 0.3
      score -= 25
      AdvancedAI.log("  Rocky Helmet (low HP): -25 (avoid contact)", "Items")
    elsif user_hp_percent < 0.5
      score -= 15
      AdvancedAI.log("  Rocky Helmet: -15 (contact damage)", "Items")
    else
      score -= 5
      AdvancedAI.log("  Rocky Helmet: -5 (minor chip)", "Items")
    end

    rough_damage = AdvancedAI::CombatUtilities.estimate_damage(user, move, target, as_percent: true)
    if rough_damage >= target.hp.to_f / target.totalhp
      score += 20  # Worth it for the KO
      AdvancedAI.log("  But KOs: +20 (worth it)", "Items")
    end

    return score
  end
end

AdvancedAI.log("Advanced Item Intelligence loaded", "Core")
AdvancedAI.log("  - Pinch Berry awareness (Sitrus, Liechi, etc.)", "Items")
AdvancedAI.log("  - Type Resist Berries", "Items")
AdvancedAI.log("  - Eject mechanics (Button, Red Card, Pack)", "Items")
AdvancedAI.log("  - Air Balloon strategy", "Items")
AdvancedAI.log("  - Contact damage (Rocky Helmet, Iron Barbs)", "Items")

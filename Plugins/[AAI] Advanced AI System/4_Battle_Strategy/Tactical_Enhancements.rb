# Advanced AI System - Tactical Enhancements

module AdvancedAI
  module TacticalEnhancements

    MAGIC_BOUNCE_ABILITIES = [:MAGICBOUNCE]
    def self.magic_bounce_penalty(user, target, move)
      return 0 unless user && target && move
      target_data = move.pbTarget(user) rescue nil
      return 0 unless target_data && target_data.num_targets > 0
      return 0 unless target.opposes?(user)
      return 0 unless target.respond_to?(:hasActiveAbility?) && MAGIC_BOUNCE_ABILITIES.any? { |a| target.hasActiveAbility?(a) }
      return 0 if AdvancedAI::Utilities.ignores_ability?(user, move, target)
      return 0 unless move.statusMove? && (move.move.canMagicCoat? rescue false)

      AdvancedAI.log("#{move.name} blocked by Magic Bounce on #{target.name}", "Ability")
      -500
    end

    # #2 MOLD BREAKER FAMILY — bypass target abilities in damage calc
    # Mold Breaker/Teravolt/Turboblaze ignore Levitate, Sturdy, Multiscale etc.
    MOLD_BREAKER_ABILITIES = [:MOLDBREAKER, :TERAVOLT, :TURBOBLAZE]

    # Bonus when user has Mold Breaker and target has a defensive ability
    BYPASSED_ABILITIES = [:LEVITATE, :STURDY, :MULTISCALE, :SHADOWSHIELD,
                          :DISGUISE, :ICEFACE, :WONDERGUARD, :MAGICBOUNCE,
                          :FLASHFIRE, :WATERABSORB, :VOLTABSORB, :LIGHTNINGROD,
                          :STORMDRAIN, :SAPSIPPER, :MOTORDRIVE, :DRYSKIN,
                          :WELLBAKEDBODY, :EARTHEATER,
                          :BATTLEARMOR, :SHELLARMOR, :UNAWARE, :FURCOAT,
                          :ICESCALES, :TERASHELL, :SEEDSOWER]

    def self.mold_breaker_bonus(user, target, move)
      return 0 unless user && target && move && move.damagingMove?
      return 0 unless user.respond_to?(:hasActiveAbility?) && MOLD_BREAKER_ABILITIES.any? { |a| user.hasActiveAbility?(a) }
      target_ability = nil
      BYPASSED_ABILITIES.each { |a| target_ability = a if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(a) }
      return 0 unless target_ability

      bonus = 0
      case target_ability
      when :LEVITATE
        bonus += 40 if move.type == :GROUND
        AdvancedAI.log("Mold Breaker bypasses Levitate: +#{bonus} for #{move.name}", "Ability") if bonus > 0
      when :STURDY
        bonus += 20  # Can OHKO from full HP now
      when :MULTISCALE, :SHADOWSHIELD
        bonus += 25  # Full damage at full HP
      when :DISGUISE, :ICEFACE
        bonus += 15  # Breaks form AND does damage
      when :WONDERGUARD
        type_mod = Effectiveness.calculate(move.type, *target.pbTypes(true)) rescue 0
        bonus += 50 unless Effectiveness.super_effective?(type_mod)
      when :MAGICBOUNCE
        bonus += 10  # Not huge for damaging moves but still relevant
      when :FLASHFIRE, :WELLBAKEDBODY
        bonus += 35 if move.type == :FIRE
      when :WATERABSORB, :DRYSKIN, :STORMDRAIN
        bonus += 35 if move.type == :WATER
      when :VOLTABSORB, :LIGHTNINGROD, :MOTORDRIVE
        bonus += 35 if move.type == :ELECTRIC
      when :SAPSIPPER
        bonus += 35 if move.type == :GRASS
      when :EARTHEATER
        bonus += 35 if move.type == :GROUND
      when :FURCOAT
        bonus += 15  # Full physical damage
      when :UNAWARE
        bonus += 10  # Our boosts count
      when :ICESCALES
        bonus += 20  # Full special damage (normally halved)
      when :TERASHELL
        bonus += 25  # Full damage at full HP (normally all NVE)
      when :SEEDSOWER
        bonus += 10  # Prevents Grassy Terrain from being set on hit
      else
        bonus += 10  # Generic bypass bonus
      end
      bonus
    end

    MULTI_HIT_MOVES = [
      :BULLETSEED, :ICICLESPEAR, :ROCKBLAST, :SCALESHOT, :WATERSHURIKEN,
      :TAILSLAP, :TRIPLEAXEL, :SURGINGSTRIKES, :BONERUSH, :PINMISSILE,
      :DOUBLEHIT, :DOUBLEKICK, :TWINEEDLE, :POPULATIONBOMB,
      :ARMTHRUST, :BARRAGE, :COMETPUNCH, :FURYATTACK, :FURYSWIPES,
      :SPIKECANNON, :DUALWINGBEAT, :TRIPLEKICK, :DUALCHOP, :DOUBLESLAP,
      :GEARGRIND, :BONEMERANG, :DRAGONDARTS, :DOUBLEIRONBASH,
      :TRIPLEDIVE, :TWINBEAM, :TACHYONCUTTER
    ]

    def self.sturdy_awareness(user, target, move)
      return 0 unless target && move && move.damagingMove?
      return 0 unless target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:STURDY)

      hp_pct = target.hp.to_f / target.totalhp
      return 0 unless hp_pct >= 0.99

      bonus = 0
      if MULTI_HIT_MOVES.include?(move.id)
        bonus += 40  # Multi-hit bypasses Sturdy!
        AdvancedAI.log("#{move.name} bypasses Sturdy (multi-hit): +40", "Ability")
      elsif move.power && AdvancedAI::CombatUtilities.resolve_move_power(move) <= 60
        bonus += 10  # Weak move to break Sturdy, then follow up
      else
        bonus -= 15  # Strong move wasted — they'll survive at 1 HP
      end
      bonus
    end

    # #4 MULTISCALE / SHADOW SHIELD — half damage at full HP
    # Prefer chip/hazards first; don't waste strongest move at full HP
    def self.multiscale_awareness(user, target, move)
      return 0 unless target && move
      return 0 unless target.respond_to?(:hasActiveAbility?) && (target.hasActiveAbility?(:MULTISCALE) || target.hasActiveAbility?(:SHADOWSHIELD))

      hp_pct = target.hp.to_f / target.totalhp
      return 0 unless hp_pct >= 0.99  # Only active at full HP

      bonus = 0
      if move.damagingMove?
        eff_power = AdvancedAI::CombatUtilities.resolve_move_power(move)
        if move.power && eff_power <= 60
          bonus += 15  # Good — break Multiscale with chip
          AdvancedAI.log("#{move.name} chips Multiscale/ShadowShield (weak move): +15", "Ability")
        elsif move.power && eff_power >= 100
          bonus -= 20  # Bad — wasting strong move at half damage
          AdvancedAI.log("#{move.name} halved by Multiscale/ShadowShield: -20", "Ability")
        end
      end

      if move.statusMove?
        if [:TOXIC, :WILLOWISP, :THUNDERWAVE].include?(move.id)
          bonus += 10  # Status breaks Multiscale for next turn
        end
      end
      bonus
    end

    # #5 FOCUS SASH CONSUMPTION TRACKING
    # If Sash is consumed (HP < 100% at any point), don't play around it
    @sash_consumed = {}

    def self.mark_sash_consumed(battler_index)
      @sash_consumed[battler_index] = true
    end

    def self.sash_consumed?(battler_index)
      @sash_consumed[battler_index] == true
    end

    def self.cleanup_sash_tracking
      @sash_consumed = {}
    end

    def self.focus_sash_awareness(user, target, move)
      return 0 unless target && move && move.damagingMove?
      target_item = target.respond_to?(:item_id) ? target.item_id : nil
      return 0 unless target_item == :FOCUSSASH

      hp_pct = target.hp.to_f / target.totalhp
      idx = target.respond_to?(:index) ? target.index : 0
      if hp_pct < 0.99 || sash_consumed?(idx)
        mark_sash_consumed(idx)
        return 0  # Sash already broken — score normally
      end

      if MULTI_HIT_MOVES.include?(move.id)
        AdvancedAI.log("#{move.name} bypasses Focus Sash (multi-hit): +30", "Item")
        return 30
      end

      if move.power && AdvancedAI::CombatUtilities.resolve_move_power(move) >= 100
        return -15  # Use a weaker move first to pop Sash
      end
      0
    end

    # #6 FLAME ORB + GUTS + FACADE SYNERGY
    # Don't burn Guts mons; prefer Facade when Guts-active
    GUTS_ABILITIES = [:GUTS, :MARVELSCALE, :QUICKFEET]

    def self.guts_status_penalty(target, move)
      return 0 unless target && move
      # Don't inflict status on Guts/Marvel Scale/Quick Feet targets
      if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:GUTS)
        if [:WILLOWISP, :TOXIC, :THUNDERWAVE].include?(move.id)
          AdvancedAI.log("#{move.name} powers up Guts on #{target.name}: -60", "Ability")
          return -60  # You're powering them up!
        end
        if move.id == :SCALD
          return -30
        end
      end

      if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:MARVELSCALE)
        if [:WILLOWISP, :TOXIC, :THUNDERWAVE].include?(move.id)
          return -40  # +50% Defense when statused
        end
      end

      if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:QUICKFEET)
        if [:THUNDERWAVE, :WILLOWISP, :TOXIC].include?(move.id)
          return -30  # 1.5x Speed when statused
        end
      end
      0
    end

    def self.facade_guts_bonus(user, move)
      return 0 unless user && move
      return 0 unless move.id == :FACADE
      user_status = user.respond_to?(:status) ? user.status : :NONE

      if user_status != :NONE
        bonus = 30  # Facade doubles to 140 BP when statused
        if user.respond_to?(:hasActiveAbility?) && user.hasActiveAbility?(:GUTS)
          bonus += 25  # 1.5x on top of 140 BP = 210 effective BP!
          AdvancedAI.log("Facade + Guts: +55 (210 effective BP!)", "Ability")
        end
        return bonus
      end
      0
    end

    # Don't inflict status on Poison Heal mons either
    def self.poison_heal_penalty(target, move)
      return 0 unless target && move
      return 0 unless target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:POISONHEAL)

      if [:TOXIC, :POISONPOWDER, :POISONGAS].include?(move.id)
        AdvancedAI.log("#{move.name} heals Poison Heal on #{target.name}: -80", "Ability")
        return -80  # You're giving them 1/8 HP recovery per turn!
      end
      0
    end

    # #7 TRAPPING ABILITY AWARENESS
    # When WE have Arena Trap/Shadow Tag/Magnet Pull: opponent can't switch
    # → boost setup & Toxic; reduce switch-pressure concern
    TRAPPING_ABILITIES = [:ARENATRAP, :SHADOWTAG, :MAGNETPULL]

    def self.trapping_ability_bonus(user, target, move)
      return 0 unless user && target && move
      user_ability = nil
      TRAPPING_ABILITIES.each { |a| user_ability = a if user.respond_to?(:hasActiveAbility?) && user.hasActiveAbility?(a) }
      return 0 unless user_ability

      can_escape = false

      if target.respond_to?(:item_id) && target.item_id == :SHEDSHELL
        return 0
      end

      if target.respond_to?(:pbHasType?) && target.pbHasType?(:GHOST)
        return 0
      end

      case user_ability
      when :ARENATRAP
        can_escape = true if target.respond_to?(:pbHasType?) && target.pbHasType?(:FLYING)
        can_escape = true if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:LEVITATE)
        can_escape = true if target.respond_to?(:item_id) && target.item_id == :AIRBALLOON
      when :SHADOWTAG
        can_escape = true if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:SHADOWTAG)  # Mirror match
      when :MAGNETPULL
        can_escape = true unless target.respond_to?(:pbHasType?) && target.pbHasType?(:STEEL)
      end
      return 0 if can_escape

      bonus = 0
      # Target can't escape — boost setup & status moves
      if AdvancedAI.setup_move?(move.id)
        bonus += 25  # Free setup — they can't switch to a counter
        AdvancedAI.log("Trapped foe: +25 for setup #{move.name}", "Tactic")
      end
      if [:TOXIC, :WILLOWISP, :THUNDERWAVE].include?(move.id)
        bonus += 20  # Status sticks — no switching out
      end
      if move.id == :PERISHSONG
        bonus += 40  # Perish trap combo!
        AdvancedAI.log("Perish trap: +40 for Perish Song", "Tactic")
      end
      if [:ROAR, :WHIRLWIND, :DRAGONTAIL, :CIRCLETHROW].include?(move.id)
        bonus -= 20  # Don't phaze — we want them trapped
      end
      bonus
    end

    def self.intimidate_cycle_bonus(battle, user, skill)
      return 0 unless battle && user && skill >= 70
      return 0 unless battle.pbSideSize(0) > 1  # Doubles only
      return 0 unless user.respond_to?(:hasActiveAbility?) && user.hasActiveAbility?(:INTIMIDATE)

      physical_threat_count = 0
      battle.allOtherSideBattlers(user.index).each do |opp|
        next unless opp && !opp.fainted?
        return 0 if opp.hasActiveAbility?([:DEFIANT, :COMPETITIVE, :CONTRARY, :MIRRORARMOR])
        if Settings::MECHANICS_GENERATION >= 8
          next if opp.hasActiveAbility?([:OBLIVIOUS, :OWNTEMPO, :INNERFOCUS, :SCRAPPY])
        end
        next unless opp.pbCanLowerStatStage?(:ATTACK, user)
        phys_moves = opp.moves.count do |m|
          m && m.physicalMove? && m.power && AdvancedAI::CombatUtilities.resolve_move_power(m) >= 60
        end
        physical_threat_count += 1 if phys_moves >= 2
      end

      return 0 if physical_threat_count == 0

      bonus = 0
      if user.turnCount >= 2 && physical_threat_count >= 1
        bonus += physical_threat_count * 15  # More physical threats = more value
        AdvancedAI.log("Intimidate cycle value: +#{bonus} (#{physical_threat_count} phys threats)", "Doubles")
      end
      bonus
    end

    def self.setup_speed_advantage?(battle, user, target, increment)
      battler = user.respond_to?(:battler) ? user.battler : user
      return false unless battler && target && !battler.fainted?
      before = battler.pbSpeed
      if !battle.moldBreaker
        increment *= -1 if battler.hasActiveAbility?(:CONTRARY)
        increment *= 2 if battler.hasActiveAbility?(:SIMPLE)
      end
      limit = Battle::Battler::STAT_STAGE_MAXIMUM
      stage = [[battler.stages[:SPEED] + increment, -limit].max, limit].min
      stage = 0 if stage < 0 && battler.hasActiveItem?(:WHITEHERB)
      projected = battler.dup
      projected.instance_variable_set(:@stages, battler.stages.dup)
      projected.stages[:SPEED] = stage
      after = projected.pbSpeed
      target_speed = target.pbSpeed
      if battle.field.effects[PBEffects::TrickRoom] > 0
        return after < before && after < target_speed
      end
      return after > before && after > target_speed
    end

    def self.usable_priority_attack?(battle, user, target)
      user = user.battler if user.respond_to?(:battler)
      target = target.battler if target.respond_to?(:battler)
      return false unless battle && user && target
      user.moves.each_with_index.any? do |move, index|
        next false unless move && move.damagingMove? && battle.pbCanChooseMove?(user.index, index, false)
        next false unless AdvancedAI::PriorityTiers.get_priority_tier(move, user) > 0
        next false if AdvancedAI::Utilities.counter_priority_blocked?(battle, move, user, target)
        AdvancedAI::CombatUtilities.estimate_damage(user, move, target) > 0
      end
    end

    def self.multi_turn_bonus(battle, user, move, target, skill)
      return 0 unless user && move && skill >= 75
      depth = AdvancedAI.prediction_depth(skill)
      return 0 if depth < 2
      bonus = 0

      user_moves = user.moves.map { |m| m.id if m }.compact
      hp_pct = user.hp.to_f / user.totalhp

      if move.id == :BELLYDRUM
        has_priority = usable_priority_attack?(battle, user, target)
        if has_priority && hp_pct > 0.55
          bonus += 40  # Belly Drum + priority = sweep potential
          AdvancedAI.log("Multi-turn: Belly Drum → priority sweep: +40", "Plan")
        elsif !has_priority && AdvancedAI.get_setting(:revenge_kill, 0) > 0
          bonus -= 10  # No priority = risky (can be revenge killed)
        end
      end

      if move.id == :SHELLSMASH
        if user.hasActiveItem?(:WHITEHERB)
          bonus += 30  # No defense drops!
          AdvancedAI.log("Multi-turn: Shell Smash + White Herb: +30", "Plan")
        end
        bonus += 20 if target && setup_speed_advantage?(battle, user, target, 2)
      end

      if move.id == :TOXIC
        has_protect = user_moves.any? { |mid| [:PROTECT, :DETECT, :KINGSSHIELD, :SPIKYSHIELD,
                    :BANEFULBUNKER, :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK].include?(mid) }
        has_recovery = user_moves.any? { |mid| AdvancedAI.healing_move?(mid) rescue false }
        if depth >= 3 && has_protect && has_recovery
          bonus += 20  # Toxic stall plan
          AdvancedAI.log("Multi-turn: Toxic → Protect → Recover plan: +20", "Plan")
        end
      end

      if move.id == :SUBSTITUTE && hp_pct > 0.3
        has_setup = user_moves.any? { |mid| AdvancedAI.setup_move?(mid) rescue false }
        if has_setup
          bonus += 15  # Sub → setup is a classic competitive sequence
          AdvancedAI.log("Multi-turn: Substitute → setup: +15", "Plan")
        end
        if user_moves.include?(:FOCUSPUNCH)
          bonus += 25
          AdvancedAI.log("Multi-turn: Sub → Focus Punch: +25", "Plan")
        end
      end

      if target && [:DRAGONDANCE, :QUIVERDANCE, :SHIFTGEAR].include?(move.id)
        increment = move.id == :SHIFTGEAR ? 2 : 1
        if setup_speed_advantage?(battle, user, target, increment)
          bonus += 15
          AdvancedAI.log("Multi-turn: #{move.name} improves turn order: +15", "Plan")
        end
      end

      if [:SWORDSDANCE, :NASTYPLOT, :CALMMIND].include?(move.id)
        if hp_pct > 0.7 && user.effects[PBEffects::Substitute] > 0
          bonus += 20  # Behind Sub = safe setup
        end
      end

      bonus
    end

    CHARGE_MOVES = [
      :SOLARBEAM, :SOLARBLADE, :METEORBEAM, :PHANTOMFORCE, :SHADOWFORCE,
      :SKULLBASH, :SKYATTACK, :FLY, :DIG, :DIVE, :BOUNCE, :GEOMANCY,
      :FREEZESHOCK, :ICEBURN, :RAZORWIND, :ELECTROSHOT
    ]

    def self.power_herb_bonus(user, move)
      return 0 unless user && move
      return 0 unless user.hasActiveItem?(:POWERHERB)
      return 0 unless CHARGE_MOVES.include?(move.id)

      bonus = 35
      bonus += 15 if move.id == :METEORBEAM
      bonus += 25 if move.id == :GEOMANCY
      AdvancedAI.log("Power Herb: #{move.name} instant: +#{bonus}", "Item")
      bonus
    end

    SELF_DROP_MOVES = [:SHELLSMASH, :CLOSECOMBAT, :SUPERPOWER, :OVERHEAT,
                       :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST,
                       :VCREATE, :HEADLONGRUSH, :ARMORCANNON, :DRAGONASCENT,
                       :HAMMERARM, :ICEHAMMER, :CLANGINGSCALES, :HYPERSPACEFURY,
                       :MAKEITRAIN, :SPINOUT]

    def self.white_herb_bonus(user, move)
      return 0 unless user && move
      return 0 unless user.hasActiveItem?(:WHITEHERB)
      return 0 unless SELF_DROP_MOVES.include?(move.id)

      bonus = 0
      case move.id
      when :SHELLSMASH
        bonus += 35
        AdvancedAI.log("White Herb + Shell Smash: +35 (no def drops!)", "Item")
      when :CLOSECOMBAT, :SUPERPOWER, :HEADLONGRUSH, :ARMORCANNON, :DRAGONASCENT
        bonus += 15  # No Def/SpDef drops
      when :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST, :MAKEITRAIN
        bonus += 20  # No SpAtk drop = can spam
        AdvancedAI.log("White Herb + #{move.name}: +20 (no SpAtk drop)", "Item")
      when :VCREATE
        bonus += 15
      when :HAMMERARM, :ICEHAMMER
        bonus += 10  # No Speed drop
      when :CLANGINGSCALES, :HYPERSPACEFURY
        bonus += 10  # No Def drop
      when :SPINOUT
        bonus += 15  # No -2 Speed drop
      end
      bonus
    end

    def self.disguise_iceface_awareness(user, target, move)
      return 0 unless target && move && move.damagingMove?

      if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:DISGUISE)
        form = target.respond_to?(:form) ? target.form : 0
        if form == 0  # Disguised form
          eff_power = AdvancedAI::CombatUtilities.resolve_move_power(move)
          if move.power && eff_power <= 60
            return 20  # Good — use weak move to pop Disguise
          elsif move.power && eff_power >= 100
            return -25  # Bad — wasting strong move on Disguise
          end
        end
      end

      if target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:ICEFACE)
        form = target.respond_to?(:form) ? target.form : 0
        if form == 0 && move.physicalMove?  # Ice Face blocks first physical hit
          eff_power = AdvancedAI::CombatUtilities.resolve_move_power(move)
          if move.power && eff_power <= 60
            return 15  # Good — pop Ice Face cheaply
          elsif move.power && eff_power >= 100
            return -20  # Bad — wasting strong physical move
          end
        end
        if form == 0 && move.specialMove?
          return 10  # Special moves go through Ice Face (when active)
        end
      end
      0
    end

    # #13 POISON HEAL / GUTS STATUS IMMUNITY (aggregated)
    # Combined: don't inflict status on ability-immune targets
    # (Implemented in #6 above — guts_status_penalty + poison_heal_penalty)

    def self.good_as_gold_penalty(user, target, move)
      return 0 unless user && target && move
      target_data = move.pbTarget(user) rescue nil
      return 0 unless target_data && target_data.num_targets > 0
      return 0 if target.index == user.index
      return 0 unless target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:GOODASGOLD)
      return 0 if AdvancedAI::Utilities.ignores_ability?(user, move, target)
      return 0 unless move.statusMove?

      AdvancedAI.log("#{move.name} blocked by Good as Gold on #{target.name}: -200", "Ability")
      -200  # All status moves fail against Good as Gold
    end

    def self.future_sight_bonus(battle, user, move, target)
      user = user.battler if user.respond_to?(:battler)
      move = move.move if move.respond_to?(:move)
      return 0 unless move && user
      return 0 unless move.id == :FUTURESIGHT || move.id == :DOOMDESIRE

      target = target.battler if target.respond_to?(:battler)
      return 0 unless battle && target && !target.fainted?
      return 0 unless AdvancedAI::WinConditions.move_available?(user, move)
      bonus = 0
      if battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
        return -50  # Already active — don't stack
      end

      party = battle.pbParty(user.index)
      good_partners = 0
      party.each_with_index do |pkmn, index|
        next unless battle.pbCanSwitchIn?(user.index, index)
        pkmn_roles = AdvancedAI.detect_roles(pkmn) rescue [:balanced]
        good_partners += 1 if pkmn_roles.include?(:wallbreaker) || pkmn_roles.include?(:sweeper)
      end

      if good_partners >= 1
        bonus += 20  # Future Sight + switch to attacker = double pressure
        bonus += 10 if good_partners >= 2
        AdvancedAI.log("Future Sight + switch option: +#{bonus}", "Tactic")
      end

      user_moves = user.moves.filter_map { |m| m.id if m && m.pp > 0 }
      pivot_moves = [:UTURN, :VOLTSWITCH, :FLIPTURN, :PARTINGSHOT, :TELEPORT, :BATONPASS,
                     :SHEDTAIL, :CHILLYRECEPTION]
      if user_moves.any? { |mid| pivot_moves.include?(mid) }
        bonus += 10  # Can pivot out after Future Sight
      end
      bonus
    end

    def self.wish_proactive_bonus(battle, user, move)
      user = user.battler if user.respond_to?(:battler)
      move = move.move if move.respond_to?(:move)
      return 0 unless move && user
      return 0 unless move.id == :WISH

      bonus = 0
      hp_pct = user.hp.to_f / user.totalhp

      return 0 unless battle && AdvancedAI::WinConditions.move_available?(user, move)
      return 0 if battle.positions[user.index].effects[PBEffects::Wish] > 0

      if hp_pct > 0.85
        party = battle.pbParty(user.index)
        low_teammates = party.each_with_index.count do |pkmn, index|
          next false unless battle.pbCanSwitchIn?(user.index, index)
          pkmn.hp.to_f / pkmn.totalhp < 0.5
        end

        if low_teammates >= 1
          bonus += 25  # Wish-pass to heal a teammate
          AdvancedAI.log("Wish-pass: low teammate needs healing: +25", "Tactic")
        else
          bonus += 10  # Proactive Wish at high HP = prepare for future
        end
      end

      user_moves = user.moves.filter_map { |m| m.id if m && m.pp > 0 }
      if user_moves.any? { |mid| [:PROTECT, :DETECT, :KINGSSHIELD, :SPIKYSHIELD,
                  :BANEFULBUNKER, :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK].include?(mid) }
        bonus += 10  # Can guarantee Wish landing with Protect next turn
      end
      bonus
    end

    def self.belly_drum_eval(battle, user, move, target, skill)
      return 0 unless move && move.id == :BELLYDRUM
      return 0 unless user

      hp_pct = user.hp.to_f / user.totalhp
      return -200 if hp_pct <= 0.5

      bonus = 0
      user_moves = user.moves.map { |m| m.id if m }.compact
      user_item = user.respond_to?(:item_id) ? user.item_id : nil

      has_priority = usable_priority_attack?(battle, user, target)

      if has_priority
        bonus += 50  # Belly Drum + priority = guaranteed sweep
      end

      if user_item == :SITRUSBERRY
        bonus += 20  # Recover 25% after Drum → 75% HP at +6
      end

      if target
        our_atk_boosted = user.attack * 4  # +6 stages
        their_def = target.respond_to?(:defense) ? target.defense : 100
        if our_atk_boosted > their_def * 3
          bonus += 20  # Likely sweeping
        end
      end

      if target && AdvancedAI.get_setting(:revenge_kill, 0) > 0
        target_eff_speed = AdvancedAI::SpeedTiers.calculate_effective_speed(battle, target)
        user_eff_speed = AdvancedAI::SpeedTiers.calculate_effective_speed(battle, user)
        slower = battle.field.effects[PBEffects::TrickRoom] > 0 ? user_eff_speed > target_eff_speed : user_eff_speed < target_eff_speed
        if slower && !has_priority
          bonus -= 30  # They outspeed us = revenge killed post-Drum
        end
      end

      AdvancedAI.log("Belly Drum eval: #{bonus} (priority=#{has_priority}, HP=#{(hp_pct * 100).to_i}%)", "Plan") if bonus != 0
      bonus
    end

    def self.stallbreaker_bonus(battle, user, move, target, skill)
      return 0 unless battle && user && move && skill >= 70
      return 0 unless target

      state = AdvancedAI::StrategicAwareness.get_state(battle) rescue nil
      archetype = state ? state[:opponent_archetype] : nil
      return 0 unless archetype == :stall

      bonus = 0
      if move.id == :TAUNT
        bonus += 30
        AdvancedAI.log("Stallbreaker: Taunt vs stall: +30", "Strategy")
      end

      if move.id == :KNOCKOFF
        bonus += 20
      end

      if AdvancedAI.setup_move?(move.id)
        target_roles = AdvancedAI.detect_roles(target) rescue [:balanced]
        if target_roles.include?(:wall) || target_roles.include?(:stall) || target_roles.include?(:support)
          bonus += 20
          AdvancedAI.log("Stallbreaker: setup on passive #{target.name}: +20", "Strategy")
        end
      end

      if [:TRICK, :SWITCHEROO].include?(move.id)
        user_item = user.respond_to?(:item_id) ? user.item_id : nil
        if AdvancedAI.choice_item?(user_item) &&
           AdvancedAI::WinConditions.move_available?(user, move) &&
           AdvancedAI::Utilities.delayed_setup_threat?(battle, move, user, target) &&
           !AdvancedAI.choice_item?(target.item_id)
          bonus += 25  # Lock wall into one move
        end
      end

      if move.damagingMove? && move.power && AdvancedAI::CombatUtilities.resolve_move_power(move) >= 100
        bonus += 10  # Raw power vs stall
      end
      bonus
    end

    def self.hazard_order_bonus(battle, user, move, target)
      return 0 unless move && user && target
      return 0 unless [:STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB].include?(move.id)

      bonus = 0
      opp_party = battle.pbParty(1 - (user.index & 1)) rescue []

      case move.id
      when :TOXICSPIKES
        immune_count = opp_party.count do |pkmn|
          next false if !pkmn || pkmn.fainted? || pkmn.egg?
          types = pkmn.types rescue []
          types.include?(:STEEL) || types.include?(:POISON)
        end
        alive_count = opp_party.count { |p| p && !p.fainted? && !p.egg? }
        if alive_count > 0 && immune_count.to_f / alive_count >= 0.5
          bonus -= 30  # Half+ the team is immune
          AdvancedAI.log("TSpikes deprioritized: #{immune_count}/#{alive_count} immune", "Hazard")
        end

        airborne_count = opp_party.count do |pkmn|
          next false if !pkmn || pkmn.fainted? || pkmn.egg?
          types = pkmn.types rescue []
          abilities = pkmn.respond_to?(:ability_id) ? [pkmn.ability_id] : []
          types.include?(:FLYING) || abilities.include?(:LEVITATE)
        end
        if alive_count > 0 && airborne_count.to_f / alive_count >= 0.5
          bonus -= 20  # Many fliers
        end

      when :STICKYWEB
        fast_count = opp_party.count do |pkmn|
          next false if !pkmn || pkmn.fainted? || pkmn.egg?
          base_speed = pkmn.respond_to?(:speed) ? pkmn.speed : 80
          base_speed >= 90  # Fast enough to benefit from speed drop
        end
        alive_count = opp_party.count { |p| p && !p.fainted? && !p.egg? }
        if alive_count > 0 && fast_count.to_f / alive_count < 0.3
          bonus -= 20  # Mostly slow team — Sticky Web less impactful
        end

        if battle.field.effects[PBEffects::TrickRoom] > 0
          bonus -= 40  # Speed drop helps them in TR!
        end

      when :SPIKES
        grounded_count = opp_party.count do |pkmn|
          next false if !pkmn || pkmn.fainted? || pkmn.egg?
          types = pkmn.types rescue []
          abilities = pkmn.respond_to?(:ability_id) ? [pkmn.ability_id] : []
          !types.include?(:FLYING) && !abilities.include?(:LEVITATE)
        end
        alive_count = opp_party.count { |p| p && !p.fainted? && !p.egg? }
        if alive_count > 0 && grounded_count.to_f / alive_count < 0.4
          bonus -= 20  # Most of team avoids Spikes
        end
      end
      bonus
    end

    def self.ally_switch_bonus(battle, user, move, target, skill)
      return 0 unless move && move.id == :ALLYSWITCH
      return 0 unless battle.pbSideSize(0) > 1  # Doubles only

      bonus = 0
      partner = battle.allSameSideBattlers(user.index).find { |b| b && b.index != user.index && !b.fainted? }
      return 0 unless partner

      partner_hp_pct = partner.hp.to_f / partner.totalhp
      user_hp_pct = user.hp.to_f / user.totalhp

      if partner_hp_pct < 0.4 && user_hp_pct > 0.6
        bonus += 25  # Save low-HP partner by swapping positions
      end

      bonus += 10 if skill >= 85
      AdvancedAI.log("Ally Switch: +#{bonus}", "Doubles") if bonus > 0
      bonus
    end

    def self.tr_setter_followup(battle, user, move, skill)
      return 0 unless battle && user && move && skill >= 70
      return 0 unless battle.pbSideSize(0) > 1  # Doubles only

      bonus = 0
      if battle.field.effects[PBEffects::TrickRoom] > 0
        our_speed = AdvancedAI::SpeedTiers.calculate_effective_speed(battle, user)
        partner = battle.allSameSideBattlers(user.index).find { |b| b && b.index != user.index && !b.fainted? }
        if partner
          partner_speed = AdvancedAI::SpeedTiers.calculate_effective_speed(battle, partner)
          if our_speed > partner_speed
            if [:PROTECT, :DETECT, :KINGSSHIELD, :SPIKYSHIELD, :BANEFULBUNKER,
                :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK].include?(move.id)
              bonus += 15  # Protect while sweeper attacks
            end
            if move.id == :HELPINGHAND
              bonus += 20  # Boost the TR sweeper
            end
            if [:MEMENTO, :HEALINGWISH, :LUNARDANCE].include?(move.id)
              bonus += 15  # Set up replacement
            end
          end
        end
      end
      bonus
    end

    PARADOX_ABILITIES = [:PROTOSYNTHESIS, :QUARKDRIVE]

    def self.booster_energy_bonus(user, move)
      return 0 unless user && move
      user_item = user.respond_to?(:item_id) ? user.item_id : nil
      return 0 unless user.respond_to?(:hasActiveAbility?) && PARADOX_ABILITIES.any? { |a| user.hasActiveAbility?(a) }
      return 0 unless user_item == :BOOSTERENERGY

      bonus = 0
      stats = {
        atk: user.respond_to?(:attack) ? user.attack : 0,
        spa: user.respond_to?(:spatk) ? user.spatk : 0,
        speed: user.respond_to?(:speed) ? user.speed : 0,
        def_stat: user.respond_to?(:defense) ? user.defense : 0,
        spd: user.respond_to?(:spdef) ? user.spdef : 0,
      }
      best_stat = stats.max_by { |_, v| v }.first

      case best_stat
      when :atk
        bonus += 10 if move.physicalMove?  # Leverage boosted Atk
      when :spa
        bonus += 10 if move.specialMove?   # Leverage boosted SpAtk
      when :speed
        bonus += 5  # Speed boost = outspeed more things
      end
      bonus
    end

    def self.tactical_score(battle, user, move, target, skill = 100)
      return 0 unless skill >= 50
      total = 0

      begin
        if target
          total += magic_bounce_penalty(user, target, move)
          total += mold_breaker_bonus(user, target, move)
          total += sturdy_awareness(user, target, move)
          total += multiscale_awareness(user, target, move)
          total += focus_sash_awareness(user, target, move)
          total += guts_status_penalty(target, move)
          total += poison_heal_penalty(target, move)
          total += good_as_gold_penalty(user, target, move)
          total += disguise_iceface_awareness(user, target, move)
          total += trapping_ability_bonus(user, target, move)
        end

        total += facade_guts_bonus(user, move)
        total += power_herb_bonus(user, move)
        total += white_herb_bonus(user, move)
        total += booster_energy_bonus(user, move)

        total += multi_turn_bonus(battle, user, move, target, skill) if skill >= 75
        total += belly_drum_eval(battle, user, move, target, skill) if move.id == :BELLYDRUM

        total += future_sight_bonus(battle, user, move, target) if target
        total += wish_proactive_bonus(battle, user, move) if move.id == :WISH
        total += stallbreaker_bonus(battle, user, move, target, skill) if target
        total += hazard_order_bonus(battle, user, move, target) if target

        if target && move.id == :KNOCKOFF && target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:HARVEST) && target.item
          total += 25  # Permanently removes berry that Harvest would regenerate
          AdvancedAI.log("Knock Off vs Harvest: +25 (shuts down berry recycling)", "Tactical")
        end

        if target && target.respond_to?(:hasActiveAbility?) && target.hasActiveAbility?(:HARVEST) && target.respond_to?(:item_id) && target.item_id == :LUMBERRY
          if move.statusMove? && ["ParalyzeTarget", "BurnTarget", "PoisonTarget",
              "BadPoisonTarget", "SleepTarget"].include?(move.function_code)
            total -= 40  # Lum Berry will cure AND regrow via Harvest
            AdvancedAI.log("Status vs Harvest+Lum: -40 (cured and regrown)", "Tactical")
          end
        end

        if battle.pbSideSize(0) > 1
          total += intimidate_cycle_bonus(battle, user, skill)
          total += ally_switch_bonus(battle, user, move, target, skill) if move.id == :ALLYSWITCH
          total += tr_setter_followup(battle, user, move, skill)
        end
      rescue => e
        AdvancedAI.log("Error: #{e.message}", "Tactical")
      end

      total
    end

    def self.cleanup
      @sash_consumed = {}
    end
  end
end

module AdvancedAI
  def self.tactical_score(battle, user, move, target, skill = 100)
    TacticalEnhancements.tactical_score(battle, user, move, target, skill)
  end

  def self.mark_sash_consumed(battler_index)
    TacticalEnhancements.mark_sash_consumed(battler_index)
  end
end

class Battle::AI
  def apply_tactical_enhancements(score, move, user, target, skill = 100)
    return score unless move && user
    begin
      real_user = user.respond_to?(:battler) ? user.battler : user
      real_target = target ? (target.respond_to?(:battler) ? target.battler : target) : nil
      bonus = AdvancedAI.tactical_score(@battle, real_user, move, real_target, skill)
      score += bonus if bonus && bonus != 0
    rescue => e
      AdvancedAI.log("Pipeline error: #{e.message}", "Tactical")
    end
    return score
  end
end

class Battle
  alias_method :aai_tactical_cleanup_pbEndOfBattle, :pbEndOfBattle unless method_defined?(:aai_tactical_cleanup_pbEndOfBattle) || private_method_defined?(:aai_tactical_cleanup_pbEndOfBattle)
  def pbEndOfBattle
    AdvancedAI::TacticalEnhancements.cleanup
    aai_tactical_cleanup_pbEndOfBattle
  end
end

AdvancedAI.log("Tactical Enhancements loaded", "Tactical")
AdvancedAI.log("  - #1 Magic Bounce in-battle penalty", "Tactical")
AdvancedAI.log("  - #2 Mold Breaker ability bypass", "Tactical")
AdvancedAI.log("  - #3 Sturdy multi-hit/chip awareness", "Tactical")
AdvancedAI.log("  - #4 Multiscale/Shadow Shield chip logic", "Tactical")
AdvancedAI.log("  - #5 Focus Sash consumption tracking", "Tactical")
AdvancedAI.log("  - #6 Guts/Facade/Poison Heal synergy", "Tactical")
AdvancedAI.log("  - #7 Trapping ability awareness", "Tactical")
AdvancedAI.log("  - #8 Intimidate cycling (Doubles)", "Tactical")
AdvancedAI.log("  - #9 Multi-turn look-ahead planning", "Tactical")
AdvancedAI.log("  - #10 Power Herb + charge moves", "Tactical")
AdvancedAI.log("  - #11 White Herb + Shell Smash synergy", "Tactical")
AdvancedAI.log("  - #12 Disguise/Ice Face form breaking", "Tactical")
AdvancedAI.log("  - #13 Status immunity abilities", "Tactical")
AdvancedAI.log("  - #14 Good as Gold full status immune", "Tactical")
AdvancedAI.log("  - #15 Future Sight + switch synergy", "Tactical")
AdvancedAI.log("  - #16 Wish proactive + Wish-pass", "Tactical")
AdvancedAI.log("  - #17 Belly Drum dedicated eval", "Tactical")
AdvancedAI.log("  - #18 Stall-breaker mode", "Tactical")
AdvancedAI.log("  - #19 Hazard stacking order", "Tactical")
AdvancedAI.log("  - #20 Ally Switch + TR coordination", "Tactical")
AdvancedAI.log("  - #21 Booster Energy scoring", "Tactical")

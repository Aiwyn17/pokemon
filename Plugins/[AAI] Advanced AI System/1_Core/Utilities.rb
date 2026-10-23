# Advanced AI System - Centralized Utilities

module AdvancedAI
  module Utilities
    def self.battle_for(*subjects)
      subjects.each do |subject|
        subject = subject.battler if subject.respond_to?(:battler)
        next unless subject.respond_to?(:battle)
        battle = subject.battle
        return battle if battle
      end
      nil
    end

    def self.type_mod(attack_type, defender)
      return Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER unless defender

      type = attack_type.is_a?(Symbol) ? attack_type : attack_type.type

      if defender.respond_to?(:pbTypes)
        types = defender.pbTypes(true)
      elsif defender.respond_to?(:types)
        types = defender.types
      else
        types = [defender.type1]
        types << defender.type2 if defender.respond_to?(:type2) && defender.type2 != defender.type1
      end

      Effectiveness.calculate(type, *types)
    end

    def self.super_effective?(attack_type, defender)
      Effectiveness.super_effective?(type_mod(attack_type, defender))
    end

    def self.not_very_effective?(attack_type, defender)
      Effectiveness.not_very_effective?(type_mod(attack_type, defender))
    end

    def self.ineffective?(attack_type, defender)
      Effectiveness.ineffective?(type_mod(attack_type, defender))
    end

    ABILITY_IGNORING = [:MOLDBREAKER, :TURBOBLAZE, :TERAVOLT]

    def self.ability_active?(battler, ability)
      return false unless battler
      if battler.respond_to?(:hasActiveAbility?)
        battler.hasActiveAbility?(ability)
      else
        battler.ability_id == ability
      end
    end

    def self.item_active?(battler, item, battle = nil)
      return false unless battler && item
      return battler.hasActiveItem?(item) if battler.respond_to?(:hasActiveItem?)
      battle ||= battler.battle if battler.respond_to?(:battle)
      if battle && defined?(PBEffects::MagicRoom) &&
         (battle.field.effects[PBEffects::MagicRoom] rescue 0).to_i > 0
        return false
      end
      return false if ability_active?(battler, :KLUTZ)
      battler.respond_to?(:item_id) && battler.item_id == item
    end

    def self.has_type?(battler, type)
      return false unless battler
      return battler.pbHasType?(type) if battler.respond_to?(:pbHasType?)
      return battler.hasType?(type) if battler.respond_to?(:hasType?)
      battler.respond_to?(:types) && battler.types.include?(type)
    end

    def self.ignores_ability?(user, move = nil, target = nil)
      return false unless user

      real_target = target.respond_to?(:battler) ? target.battler : target
      if real_target
        battle = battle_for(user, real_target)
        shielded = item_active?(real_target, :ABILITYSHIELD, battle)
        return false if shielded
      end

      return true if user.respond_to?(:hasMoldBreaker?) && user.hasMoldBreaker?
      if move && move.respond_to?(:function_code) &&
         ["IgnoreTargetAbility", "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(move.function_code)
        return true
      end

      ability = user.respond_to?(:ability_id) ? user.ability_id : nil
      return true if ABILITY_IGNORING.include?(ability)
      return true if ability == :MYCELIUMMIGHT && move && !move.damagingMove?
      false
    end

    def self.target_has_ability?(user, target, *abilities)
      return false unless target
      return false if ignores_ability?(user, nil, target)

      abilities.flatten.any? { |a| ability_active?(target, a) }
    end

    TYPE_ABSORBING_ABILITIES = {
      WATER: [
        [:WATERABSORB, :heal],      # Heals 25% HP
        [:DRYSKIN, :heal],          # Heals 25% HP (also takes 25% extra Fire damage)
        [:STORMDRAIN, :boost_spa],  # +1 SpA
      ],
      ELECTRIC: [
        [:VOLTABSORB, :heal],       # Heals 25% HP
        [:LIGHTNINGROD, :boost_spa], # +1 SpA
        [:MOTORDRIVE, :boost_speed], # +1 Speed
      ],
      FIRE: [
        [:FLASHFIRE, :boost_fire],  # Boosts Fire moves 1.5x
        [:WELLBAKEDBODY, :boost_def], # +2 Defense (Gen 9)
      ],
      GRASS: [
        [:SAPSIPPER, :boost_atk],   # +1 Attack
      ],
      GROUND: [
        [:EARTHEATER, :heal],       # Heals 25% HP (Gen 9)
        [:LEVITATE, :immune],       # Complete immunity
      ],
    }

    def self.type_absorbing_immunity?(user, target, move_type, move = nil)
      return nil unless target
      return nil if ignores_ability?(user, move, target)

      type_sym = move_type.to_sym rescue move_type
      absorbers = TYPE_ABSORBING_ABILITIES[type_sym]
      return nil unless absorbers

      absorbers.each do |ability, effect|
        ability = [ability] unless ability.is_a?(Array)
        ability.each do |ab|
          if ab == :LEVITATE && move && move.respond_to?(:function_code) &&
             move.function_code == "HitsTargetInSkyGroundsTarget"
            next
          end
          if ab == :LEVITATE
            battle = battle_for(user, target)
            next if grounded?(target, battle)
          end
          if ability_active?(target, ab)
            return { ability: ab, effect: effect }
          end
        end
      end

      nil
    end

    def self.score_type_absorption_penalty(user, target, move, override_type = nil)
      return 0 unless move && move.damagingMove?

      move_type = override_type || move.type
      immunity = type_absorbing_immunity?(user, target, move_type, move)
      return 0 unless immunity

      case immunity[:effect]
      when :heal
        return -150  # They heal, we waste turn
      when :boost_atk, :boost_spa, :boost_speed, :boost_def
        return -180
      when :boost_fire
        return -160  # Flash Fire boost
      when :immune
        return -200  # Complete immunity (Levitate)
      else
        return -150  # Default heavy penalty
      end
    end

    BALL_BOMB_MOVES = [
      :ACIDSPRAY, :AURASPHERE, :BARRAGE, :BEAKBLAST, :BULLETSEED,
      :EGGBOMB, :ELECTROBALL, :ENERGYBALL, :FOCUSBLAST, :GYROBALL,
      :ICEBALL, :MAGNETBOMB, :MISTBALL, :MUDBOMB, :OCTAZOOKA,
      :POLLENPUFF, :PYROBALL, :ROCKBLAST, :ROCKWRECKER, :SEARINGSHOT,
      :SEEDBOMB, :SHADOWBALL, :SLUDGEBOMB, :SYRUPBOMB, :WEATHERBALL,
      :ZAPCANNON
    ]

    def self.bulletproof_immune?(user, target, move)
      return false unless target
      return false if ignores_ability?(user, move, target)
      return false unless ability_active?(target, :BULLETPROOF)

      BALL_BOMB_MOVES.include?(move.id)
    end

    SOUND_MOVES = [
      :ALLURINGVOICE, :BOOMBURST, :BUGBUZZ, :CHATTER, :CLANGOROUSSOUL,
      :CLANGINGSCALES, :CONFIDE, :DISARMINGVOICE, :ECHOEDVOICE, :EERIESPELL,
      :GRASSWHISTLE, :GROWL, :HEALBELL, :HOWL, :HYPERVOICE, :METALSOUND,
      :NOBLEROAR, :OVERDRIVE, :PARTINGSHOT, :PERISHSONG, :PSYCHICNOISE,
      :RELICSONG, :ROAR, :ROUND, :SCREAM, :SCREECH, :SHADOWPANIC, :SING,
      :SNARL, :SNORE, :SPARKLINGARIA, :SUPERSONIC, :TORCHSONG, :UPROAR
    ]

    def self.soundproof_immune?(user, target, move)
      return false unless target
      return false if ignores_ability?(user, move, target)
      return false unless ability_active?(target, :SOUNDPROOF)

      move.soundMove? rescue SOUND_MOVES.include?(move.id)
    end

    def self.grounded?(battler, battle = nil)
      return true unless battler

      # Grounding effects take priority over airborne checks.

      if battle && battle.field.effects[PBEffects::Gravity] && battle.field.effects[PBEffects::Gravity] > 0
        return true
      end

      return true if item_active?(battler, :IRONBALL, battle)

      if battler.respond_to?(:effects) && battler.effects[PBEffects::Ingrain]
        return true
      end

      if battler.respond_to?(:effects) && battler.effects[PBEffects::SmackDown]
        return true
      end

      has_flying = battler.respond_to?(:pbHasType?) ? battler.pbHasType?(:FLYING) :
                   (battler.respond_to?(:hasType?) ? battler.hasType?(:FLYING) : false)
      return false if has_flying

      return false if ability_active?(battler, :LEVITATE)

      return false if item_active?(battler, :AIRBALLOON, battle)

      if battler.respond_to?(:effects)
        if battler.effects[PBEffects::MagnetRise] && battler.effects[PBEffects::MagnetRise] > 0
          return false
        end

        if battler.effects[PBEffects::Telekinesis] && battler.effects[PBEffects::Telekinesis] > 0
          return false
        end
      end

      true
    end

    CONTACT_PUNISH_ABILITIES = {
      ROUGHSKIN: { damage: 8, type: :fixed },      # 1/8 max HP
      IRONBARBS: { damage: 8, type: :fixed },
      FLAMEBODY: { damage: 0, type: :status, status: :BURN, chance: 30 },
      STATIC: { damage: 0, type: :status, status: :PARALYSIS, chance: 30 },
      POISONPOINT: { damage: 0, type: :status, status: :POISON, chance: 30 },
      EFFECTSPORE: { damage: 0, type: :status, chance: 30 },
      CUTECHARM: { damage: 0, type: :status, chance: 30 },
      GOOEY: { damage: 0, type: :stat, stat: :SPEED, stages: -1 },
      TANGLINGHAIR: { damage: 0, type: :stat, stat: :SPEED, stages: -1 },
      PERISHBODY: { damage: 0, type: :special },
      WANDERINGSPIRIT: { damage: 0, type: :special },
      MUMMY: { damage: 0, type: :special },
      LINGERINGAROMA: { damage: 0, type: :special },
      COTTONDOWN: { damage: 0, type: :stat, stat: :SPEED, stages: -1, aoe: true },
      STAMINA: { damage: 0, type: :self_boost, stat: :DEFENSE, stages: 1 },
      WEAKARMOR: { damage: 0, type: :self_mixed, speed_up: 2, def_down: 1 },
      ELECTROMORPHOSIS: { damage: 0, type: :charge },
      WINDPOWER: { damage: 0, type: :charge, condition: :wind_move },
      ANGERSHELL: { damage: 0, type: :conditional_boost, threshold: 0.5 },
    }

    def self.contact_punishment(attacker, defender, move)
      return 0 unless move && move.contactMove?
      return 0 unless defender

      return 0 if move.respond_to?(:pbContactMove?) && !move.pbContactMove?(attacker)
      return 0 if ability_active?(attacker, :LONGREACH)
      return 0 if attacker.hasActiveItem?(:PROTECTIVEPADS)
      indirect_damage = !ability_active?(attacker, :MAGICGUARD)

      score_penalty = 0

      unless ignores_ability?(attacker, move, defender)
        ab_key = CONTACT_PUNISH_ABILITIES.keys.find { |a| ability_active?(defender, a) }
        ability_data = ab_key ? CONTACT_PUNISH_ABILITIES[ab_key] : nil
        if ability_data
          case ability_data[:type]
          when :fixed
            damage = attacker.totalhp / ability_data[:damage]
            score_penalty += (damage * 100 / [attacker.hp, 1].max) / 3 if indirect_damage
          when :status
            if attacker.status == :NONE
              score_penalty += 15 * (ability_data[:chance] / 100.0)
            end
          when :stat
            score_penalty += 10
          when :special
            score_penalty += 20
          when :self_boost
            score_penalty += 12
          when :self_mixed
            score_penalty += 8
          when :charge
            score_penalty += 10
          when :conditional_boost
            if defender.hp > defender.totalhp * (ability_data[:threshold] || 0.5)
              score_penalty += 15  # Could trigger the boost
            end
          end
        end
      end

      if indirect_damage && defender.hasActiveItem?(:ROCKYHELMET)
        damage = attacker.totalhp / 6
        score_penalty += (damage * 100 / [attacker.hp, 1].max) / 3
      end

      score_penalty.to_i
    end

    def self.protect_likely_to_fail?(battler)
      return false unless battler
      return false unless battler.respond_to?(:effects)

      protect_rate = battler.effects[PBEffects::ProtectRate] || 1

      protect_rate >= 4
    end

    def self.protect_success_chance(battler)
      return 100 unless battler && battler.respond_to?(:effects)

      rate = battler.effects[PBEffects::ProtectRate] || 1
      (100.0 / rate).round
    end

    def self.expected_multi_hits(attacker, move)
      return 1 unless move
      return 1 unless move.multiHitMove?

      fixed_hits = {
        TRIPLEKICK: 3, TRIPLEAXEL: 3, SURGINGSTRIKES: 3, TRIPLEDIVE: 3,
        DOUBLEHIT: 2, BONEMERANG: 2, DOUBLEIRONBASH: 2,
        DRAGONDARTS: 2, TWINBEAM: 2, DUALWINGBEAT: 2, DUALCHOP: 2,
        GEARGRIND: 2, TACHYONCUTTER: 2, DOUBLEKICK: 2, TWINEEDLE: 2
      }

      return fixed_hits[move.id] if fixed_hits[move.id]

      if move.id == :POPULATIONBOMB
        return attacker.item_id == :LOADEDDICE ? 7 : 5
      end

      if ability_active?(attacker, :SKILLLINK)
        return 5
      end

      if attacker.item_id == :LOADEDDICE
        return 4.5
      end

      3.17
    end

    def self.multi_hit_breaks_endure?(attacker, move, target)
      return false unless move && move.multiHitMove?
      return false unless target

      return true if target.item_id == :FOCUSSASH && target.hp == target.totalhp

      return true if ability_active?(target, :STURDY) && target.hp == target.totalhp && !ignores_ability?(attacker, move, target)

      return true if [:DISGUISE, :ICEFACE].any? { |a| ability_active?(target, a) } && !ignores_ability?(attacker, move, target)

      false
    end

    def self.status_immune?(attacker, target, status, battle = nil, move = nil)
      return true unless target
      return true if target.status != :NONE && status != :NONE  # Already has status

      has_type = lambda { |t| target.respond_to?(:pbHasType?) ? target.pbHasType?(t) : target.hasType?(t) }

      powder_moves = [:SPORE, :SLEEPPOWDER, :STUNSPORE, :POISONPOWDER, :RAGEPOWDER,
                      :COTTONSPORE, :MAGICPOWDER, :POWDER]

      move_id = move.respond_to?(:id) ? move.id : move
      is_powder = move_id && powder_moves.include?(move_id)

      case status
      when :SLEEP
        return true if has_type.call(:GRASS) && is_powder

        unless ignores_ability?(attacker, move, target)
          return true if [:VITALSPIRIT, :INSOMNIA, :COMATOSE].any? { |a| ability_active?(target, a) }

          # Sweet Veil requires ally context.
          if battle
            allies = battle.allSameSideBattlers(target.index)
            return true if allies.any? { |a| a && ability_active?(a, :SWEETVEIL) }
          end

          if ability_active?(target, :LEAFGUARD) && battle && [:Sun, :HarshSun].include?(current_weather(battle))
            return true
          end
        end

        if battle
          return true if battle.field.terrain == :Electric && grounded?(target, battle)
          return true if battle.field.terrain == :Misty && grounded?(target, battle)
        end

        return true if target.item_id == :SAFETYGOGGLES && is_powder

      when :POISON, :TOXIC
        attacker_has_corrosion = attacker && attacker.respond_to?(:hasActiveAbility?) &&
                                 attacker.hasActiveAbility?(:CORROSION)
        unless attacker_has_corrosion
          return true if has_type.call(:POISON)
          return true if has_type.call(:STEEL)
        end

        unless ignores_ability?(attacker, move, target)
          return true if ability_active?(target, :IMMUNITY)
          return true if ability_active?(target, :PASTELVEIL)
          return true if ability_active?(target, :PURIFYINGSALT)
        end

      when :BURN
        return true if has_type.call(:FIRE)

        unless ignores_ability?(attacker, move, target)
          return true if ability_active?(target, :WATERVEIL)
          return true if ability_active?(target, :WATERBUBBLE)
          return true if ability_active?(target, :THERMALEXCHANGE)
          return true if ability_active?(target, :PURIFYINGSALT)
        end

      when :PARALYSIS
        return true if has_type.call(:ELECTRIC)

        unless ignores_ability?(attacker, move, target)
          return true if ability_active?(target, :LIMBER)
          return true if ability_active?(target, :PURIFYINGSALT)
        end

      when :FREEZE
        return true if has_type.call(:ICE)

        unless ignores_ability?(attacker, move, target)
          return true if ability_active?(target, :MAGMAARMOR)
          return true if ability_active?(target, :PURIFYINGSALT)
        end

        if battle && [:Sun, :HarshSun].include?(current_weather(battle))
          return true
        end
      end

      unless ignores_ability?(attacker, move, target)
        return true if ability_active?(target, :GOODASGOLD)
      end

      false
    end

    WEATHER_NULLIFIERS = [:AIRLOCK, :CLOUDNINE]

    def self.weather_active?(battle)
      return false unless battle
      return false if battle.field.weather == :None

      battle.allBattlers.each do |b|
        next unless b && !b.fainted?
        return false if b.hasActiveAbility?(:AIRLOCK) || b.hasActiveAbility?(:CLOUDNINE)
      end

      true
    end

    def self.current_weather(battle)
      return :None unless weather_active?(battle)
      battle.field.weather
    end

    def self.move_blocked_by_weather?(battle, move)
      return false unless battle && move && move.damagingMove?

      weather = current_weather(battle)

      case weather
      when :HarshSun
        return true if move.type == :WATER  # Water moves fail
      when :HeavyRain
        return true if move.type == :FIRE   # Fire moves fail
      end

      false
    end

    GEN9_OFFENSIVE_ABILITIES = {
      SUPREMEOVERLORD: { boost: true, condition: :fainted_allies },
      ORICHALCUMPULSE: { boost: true, sets: :Sun },
      HADRONENGINE: { boost: true, sets: :Electric },  # Terrain
      TOXICCHAIN: { poison_chance: 30 },
      SHARPNESS: { boost: 1.5, condition: :slicing_move },
      ROCKYPAYLOAD: { boost: 1.5, type: :ROCK },
      WINDPOWER: { sets_charge: true, condition: :wind_move_hit },
      ELECTROMORPHOSIS: { sets_charge: true, condition: :any_hit },
      SWORDOFRUIN: { aura: true, reduces: :DEF, amount: 0.75 },
      BEADSOFRUIN: { aura: true, reduces: :SPDEF, amount: 0.75 },
      TOXICBOOST: { boost: 1.5, condition: :poisoned, category: :physical },
      FLAREBOOST: { boost: 1.5, condition: :burned, category: :special },
      ZEROTOHERO: { form_change: true, hero_form: 1 },
      POISONPUPPETEER: { poison_confuse: true },
      EMBODYASPECT: { boost_on_entry: true },
      ASONEGLASTRIER: { ko_boost: :ATK, includes: :UNNERVE },
      ASONESPECTRIER: { ko_boost: :SPATK, includes: :UNNERVE },
      MINDSEYE: { ignore_evasion: true, ghost_hit: true },
    }

    GEN9_DEFENSIVE_ABILITIES = {
      PURIFYINGSALT: { status_immune: true, ghost_resist: true },
      GOODASGOLD: { status_move_immune: true },
      ARMORTAIL: { priority_block: true },
      WINDRIDER: { wind_immune: true, attack_boost: true },
      GUARDDOG: { intimidate_immune: true, attack_boost: true },
      WELLBAKEDBODY: { fire_immune: true, defense_boost: true },
      EARTHEATER: { ground_immune: true, heal: true },
      HOSPITALITY: { heal_ally_on_entry: true },
      ICESCALES: { special_halved: true },
      STAMINA: { def_boost_on_hit: true },
      WEAKARMOR: { def_down_speed_up_on_physical: true },
      ANGERSHELL: { below_half_boost: true },
      COTTONDOWN: { speed_drop_all_on_hit: true },
      TABLETSOFRUIN: { aura: true, reduces: :ATK, amount: 0.75 },
      VESSELOFRUIN: { aura: true, reduces: :SPATK, amount: 0.75 },
      TERASHELL: { all_nve_at_full_hp: true },
      TERAFORMZERO: { removes_weather_terrain: true },
      TERASHIFT: { auto_transform: true },
      SUPERSWEETSYRUP: { evasion_drop_on_entry: true },
      SEEDSOWER: { sets_terrain: :Grassy, condition: :hit },
    }

    def self.has_gen9_offensive_ability?(battler)
      GEN9_OFFENSIVE_ABILITIES.keys.any? { |a| ability_active?(battler, a) }
    end

    def self.has_gen9_defensive_ability?(battler)
      GEN9_DEFENSIVE_ABILITIES.keys.any? { |a| ability_active?(battler, a) }
    end

    def self.prankster_blocked?(user, target, move)
      return false unless user && target && move
      return false unless ability_active?(user, :PRANKSTER)
      return false unless move.statusMove?
      target_data = move.pbTarget(user) rescue nil
      return false unless target_data && target_data.num_targets > 0
      return false unless target.opposes?(user)

      has_dark = target.respond_to?(:pbHasType?) ? target.pbHasType?(:DARK) : target.hasType?(:DARK)
      has_dark
    end

    def self.gale_wings_active?(user)
      return false unless user
      return false unless ability_active?(user, :GALEWINGS)
      user.hp == user.totalhp
    end

    HEALING_MOVES = [
      :RECOVER, :SOFTBOILED, :ROOST, :SLACKOFF, :MOONLIGHT, :MORNINGSUN,
      :SYNTHESIS, :WISH, :SHOREUP, :LIFEDEW, :JUNGLEHEALING, :LUNARBLESSING,
      :LEECHLIFE, :DRAININGKISS, :DRAINPUNCH, :GIGADRAIN, :HORNLEECH,
      :LEECHSEED, :PARABOLICCHARGE, :OBLIVIONWING, :STRENGTHSAP,
      :ABSORB, :MEGADRAIN, :POLLENPUFF, :BITTERBLADE, :MATCHAGOTCHA
    ]

    def self.triage_active?(user, move)
      return false unless user && move
      return false unless ability_active?(user, :TRIAGE)
      HEALING_MOVES.include?(move.id)
    end

    def self.effective_priority(user, move, battle = nil)
      return 0 unless move

      base_priority = move.priority rescue 0

      if ability_active?(user, :PRANKSTER) && move.statusMove?
        base_priority += 1
      end

      if gale_wings_active?(user)
        resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(user, move)
        if resolved_type == :FLYING
          base_priority += 1
        end
      end

      if triage_active?(user, move)
        base_priority += 3
      end

      if move.id == :GRASSYGLIDE && battle && battle.field.terrain == :Grassy
        base_priority = 1
      end

      base_priority
    end

    def self.rage_fist_power(user)
      base_power = 50
      # The engine tracks Rage Fist hits via Battler#num_times_hit (Gen 9 Pack,
      real = (user.respond_to?(:battler) && user.battler) ? user.battler : user
      hits_taken = (real.respond_to?(:num_times_hit) ? real.num_times_hit.to_i : 0) rescue 0
      [base_power + (hits_taken * 50), 350].min
    end

    def self.last_respects_power(battle, user)
      base_power = 50
      return base_power unless battle

      fainted_count = 0
      party = battle.pbParty(user.index & 1)
      party.each do |p|
        next unless p
        fainted_count += 1 if p.fainted?
      end

      base_power + (fainted_count * 50)
    end

    def self.used_glaive_rush?(user)
      return false unless user
      user.lastMoveUsed == :GLAIVERUSH
    end

    COLLISION_MOVES = [:COLLISIONCOURSE, :ELECTRODRIFT]

    def self.collision_move_boost?(move)
      COLLISION_MOVES.include?(move.id)
    end

    def self.eject_pack_active?(battler)
      return false unless battler
      battler.item_id == :EJECTPACK && battler.statsLoweredThisRound
    end

    def self.throat_spray_active?(user, move)
      return false unless user && move
      user.item_id == :THROATSPRAY && (move.soundMove? rescue false)
    end

    def self.blunder_policy_bonus(user)
      return 0 unless user
      return 0 unless user.item_id == :BLUNDERPOLICY
      return 0 unless user.lastMoveFailed
      2  # +2 Speed stages
    end

    def self.effective_stat_change(user, stages)
      return stages unless user

      if ability_active?(user, :CONTRARY)
        return -stages  # Reversed
      elsif ability_active?(user, :SIMPLE)
        return stages * 2  # Doubled
      end

      stages
    end

    def self.setup_beneficial?(user, move_id)
      return true unless user

      stat_lowering_moves = [:OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON,
                             :PSYCHOBOOST, :CLOSECOMBAT, :SUPERPOWER, :HAMMERARM,
                             :VCREATE, :SHELLSMASH, :MAKEITRAIN, :HEADLONGRUSH,
                             :ARMORCANNON, :DRAGONASCENT, :ICEHAMMER, :SPINOUT,
                             :CLANGINGSCALES, :HYPERSPACEFURY]

      if ability_active?(user, :CONTRARY)
        return true if stat_lowering_moves.include?(move_id)
        return false if Utilities::ALL_SETUP_MOVES.include?(move_id)
      end

      true
    end

    SETUP_MOVES = {
      physical: [:SWORDSDANCE, :DRAGONDANCE, :BELLYDRUM, :BULKUP, :HOWL, :COIL,
                 :VICTORYDANCE, :FILLETAWAY, :HONECLAWS, :CURSE],
      special: [:NASTYPLOT, :CALMMIND, :QUIVERDANCE, :TAILGLOW, :GEOMANCY,
                :TAKEHEART, :TORCHSONG],
      speed: [:AGILITY, :ROCKPOLISH, :AUTOTOMIZE, :SHIFTGEAR, :TAILWIND,
              :DRAGONDANCE],  # DD is both
      mixed: [:SHELLSMASH, :GROWTH, :WORKUP, :ANCIENTPOWER, :OMINOUSWIND,
              :SILVERWIND, :CLANGOROUSSOUL, :NORETREAT],
      defensive: [:IRONDEFENSE, :ACIDARMOR, :BARRIER, :COTTONGUARD,
                  :AMNESIA, :COSMICPOWER, :STOCKPILE, :SHELTER],
      evasion: [:MINIMIZE, :DOUBLETEAM],
      special_types: [:FOCUSENERGY, :CHARGE, :MAGNETRISE, :AQUARING]
    }

    ALL_SETUP_MOVES = SETUP_MOVES.values.flatten.uniq

    def self.is_setup_move?(move)
      return false unless move
      ALL_SETUP_MOVES.include?(move.id)
    end

    def self.get_setup_type(move)
      return nil unless move

      SETUP_MOVES.each do |type, moves|
        return type if moves.include?(move.id)
      end

      nil
    end
  end
end

module AdvancedAI
  def self.type_mod(attack_type, defender)
    Utilities.type_mod(attack_type, defender)
  end

  def self.ignores_ability?(user, move = nil, target = nil)
    Utilities.ignores_ability?(user, move, target)
  end

  def self.target_has_ability?(user, target, *abilities)
    Utilities.target_has_ability?(user, target, *abilities)
  end

  def self.grounded?(battler, battle = nil)
    Utilities.grounded?(battler, battle)
  end

  def self.contact_punishment(attacker, defender, move)
    Utilities.contact_punishment(attacker, defender, move)
  end

  def self.protect_likely_to_fail?(battler)
    Utilities.protect_likely_to_fail?(battler)
  end

  def self.expected_multi_hits(attacker, move)
    Utilities.expected_multi_hits(attacker, move)
  end

  def self.multi_hit_breaks_endure?(attacker, move, target)
    Utilities.multi_hit_breaks_endure?(attacker, move, target)
  end

  def self.status_immune?(attacker, target, status, battle = nil, move = nil)
    Utilities.status_immune?(attacker, target, status, battle, move)
  end

  def self.weather_active?(battle)
    Utilities.weather_active?(battle)
  end

  def self.move_blocked_by_weather?(battle, move)
    Utilities.move_blocked_by_weather?(battle, move)
  end

  def self.is_setup_move?(move)
    Utilities.is_setup_move?(move)
  end

  def self.setup_move?(move_id)
    Utilities::ALL_SETUP_MOVES.include?(move_id)
  end

  def self.type_absorbing_immunity?(user, target, move_type, move = nil)
    Utilities.type_absorbing_immunity?(user, target, move_type, move)
  end

  def self.score_type_absorption_penalty(user, target, move, override_type = nil)
    Utilities.score_type_absorption_penalty(user, target, move, override_type)
  end

  def self.bulletproof_immune?(user, target, move)
    Utilities.bulletproof_immune?(user, target, move)
  end

  def self.soundproof_immune?(user, target, move)
    Utilities.soundproof_immune?(user, target, move)
  end

  module Utilities
    TYPE_RESIST_BERRIES = {
      :OCCABERRY => :FIRE,      :PASSHOBERRY => :WATER,   :WACANBERRY => :ELECTRIC,
      :RINDOBERRY => :GRASS,    :YACHEBERRY => :ICE,      :CHOPLEBERRY => :FIGHTING,
      :KEBIABERRY => :POISON,   :SHUCABERRY => :GROUND,   :COBABERRY => :FLYING,
      :PAYAPABERRY => :PSYCHIC, :TANGABERRY => :BUG,      :CHARTIBERRY => :ROCK,
      :KASIBBERRY => :GHOST,    :HABANBERRY => :DRAGON,   :COLBURBERRY => :DARK,
      :BABIRIBERRY => :STEEL,   :ROSELIBERRY => :FAIRY,   :CHILANBERRY => :NORMAL
    }

    def self.has_resist_berry?(target, move_type)
      return false unless target && target.item_id
      TYPE_RESIST_BERRIES[target.item_id] == move_type
    end

    def self.resist_berry_mod(target, move_type, type_effectiveness)
      return 1.0 unless Effectiveness.super_effective?(type_effectiveness)
      return 1.0 unless has_resist_berry?(target, move_type)
      0.5  # Halves SE damage
    end

    def self.has_clear_amulet?(battler)
      battler && battler.item_id == :CLEARAMULET
    end

    def self.has_covert_cloak?(battler)
      battler && battler.item_id == :COVERTCLOAK
    end

    def self.has_utility_umbrella?(battler)
      battler && battler.item_id == :UTILITYUMBRELLA
    end

    def self.has_power_herb?(battler)
      battler && battler.item_id == :POWERHERB
    end

    def self.has_white_herb?(battler)
      battler && battler.item_id == :WHITEHERB
    end

    def self.aegislash_in_shield_form?(battler)
      return false unless battler
      battler.isSpecies?(:AEGISLASH) && battler.form == 0
    end

    def self.aegislash_in_blade_form?(battler)
      return false unless battler
      battler.isSpecies?(:AEGISLASH) && battler.form == 1
    end

    def self.darmanitan_can_zen?(battler)
      return false unless battler
      return false unless battler.isSpecies?(:DARMANITAN)
      ability_active?(battler, :ZENMODE) && battler.hp <= battler.totalhp / 2
    end

    def self.palafin_hero_form?(battler)
      return false unless battler
      battler.isSpecies?(:PALAFIN) && battler.form == 1
    end

    def self.wishiwashi_schooling?(battler)
      return false unless battler
      return false unless battler.isSpecies?(:WISHIWASHI)
      battler.hp > battler.totalhp / 4 && battler.level >= 20
    end

    def self.minior_shields_down?(battler)
      return false unless battler
      return false unless battler.isSpecies?(:MINIOR)
      battler.hp <= battler.totalhp / 2
    end

    def self.zygarde_can_transform?(battler)
      return false unless battler
      return false unless battler.isSpecies?(:ZYGARDE)
      ability_active?(battler, :POWERCONSTRUCT) && battler.hp <= battler.totalhp / 2
    end
  end
end

AdvancedAI.log("Centralized Utilities Module loaded", "Utils")
AdvancedAI.log("  - Type effectiveness helpers", "Utils")
AdvancedAI.log("  - Mold Breaker / ability ignoring", "Utils")
AdvancedAI.log("  - Grounded check (comprehensive)", "Utils")
AdvancedAI.log("  - Contact punishment calculation", "Utils")
AdvancedAI.log("  - Protect stale detection", "Utils")
AdvancedAI.log("  - Multi-hit move handling", "Utils")
AdvancedAI.log("  - Status immunity checks", "Utils")
AdvancedAI.log("  - Weather nullification (Air Lock/Cloud Nine)", "Utils")
AdvancedAI.log("  - Primordial weather move blocking", "Utils")
AdvancedAI.log("  - Gen 9 ability awareness", "Utils")
AdvancedAI.log("  - Centralized setup move list", "Utils")
AdvancedAI.log("  - Type-absorbing ability immunities", "Utils")
AdvancedAI.log("  - Bulletproof / Soundproof immunities", "Utils")

module AdvancedAI::Utilities
  def self.phazing_possible?(battle, move, user, target)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    return false unless battle && user && target && !user.fainted? && !target.fainted?
    return false if counter_priority_blocked?(battle, move, user, target)
    return false unless [:ROAR, :WHIRLWIND, :DRAGONTAIL, :CIRCLETHROW].include?(move.id)
    preview = battle.clone
    native = Battle::Move.from_pokemon_move(preview, Pokemon::Move.new(move.id))
    preview.moldBreaker = ignores_ability?(user, native, target)
    if native.statusMove?
      return false if target.effects[PBEffects::MagicCoat]
      unless preview.moldBreaker
        return false if target.hasActiveAbility?([:MAGICBOUNCE, :GOODASGOLD])
        return false if target.hasActiveAbility?(:WINDRIDER) && native.respond_to?(:windMove?) && native.windMove?
      end
      return false if soundproof_immune?(user, target, native)
      return !native.pbFailsAgainstTarget?(user, target, false)
    end
    return false if target.effects[PBEffects::Substitute] > 0 && !native.ignoresSubstitute?(user)
    return false if AdvancedAI::CombatUtilities.estimate_damage(user, native, target) <= 0
    if target.wild?
      return target.allAllies.empty? && battle.canRun && target.level <= user.level
    end
    return false if target.effects[PBEffects::Ingrain]
    return false if target.hasActiveAbility?([:SUCTIONCUPS, :GUARDDOG]) && !preview.moldBreaker
    return false if target.respond_to?(:isCommander?) && target.isCommander?
    battle.pbCanChooseNonActive?(target.index)
  end
end

module AdvancedAI::Utilities
  def self.stat_reset_hits_target?(battle, move, user, target)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    return false unless battle && user && target && !user.fainted? && !target.fainted?
    return false if counter_priority_blocked?(battle, move, user, target)
    return true if move.id == :HAZE
    return false unless move.id == :CLEARSMOG
    native = Battle::Move.from_pokemon_move(battle, Pokemon::Move.new(move.id))
    return false if target.effects[PBEffects::Substitute] > 0 && !native.ignoresSubstitute?(user)
    AdvancedAI::CombatUtilities.estimate_damage(user, native, target) > 0
  end
end

module AdvancedAI::Utilities
  def self.setup_disruption_hits?(battle, move, user, target, future_setup = false)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    return false unless battle && user && target && !user.fainted? && !target.fainted?
    return false if counter_priority_blocked?(battle, move, user, target)
    return false unless [:TOPSYTURVY, :ENCORE, :TAUNT].include?(move.id)
    preview = battle.clone
    native = Battle::Move.from_pokemon_move(preview, Pokemon::Move.new(move.id))
    preview.moldBreaker = ignores_ability?(user, native, target)
    return false if target.effects[PBEffects::Substitute] > 0 && !native.ignoresSubstitute?(user)
    return false if target.effects[PBEffects::MagicCoat]
    unless preview.moldBreaker
      return false if target.hasActiveAbility?([:MAGICBOUNCE, :GOODASGOLD])
      return false if move.id == :TAUNT && Settings::MECHANICS_GENERATION >= 6 && target.hasActiveAbility?(:OBLIVIOUS)
    end
    if [:ENCORE, :TAUNT].include?(move.id)
      return false if native.pbMoveFailedAromaVeil?(user, target, false)
    end
    # Future setup changes the stages and last move that these handlers inspect.
    future_setup || !native.pbFailsAgainstTarget?(user, target, false)
  end
end

module AdvancedAI::Utilities
  def self.delayed_setup_threat?(battle, move, user, target)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    return false unless battle && user && target && !user.fainted? && !target.fainted?
    return false if counter_priority_blocked?(battle, move, user, target)
    return false unless [:YAWN, :PERISHSONG, :TRICK, :SWITCHEROO, :DISABLE].include?(move.id)
    preview = battle.clone
    battlers = battle.battlers.map do |b|
      next nil unless b
      copy = b.clone
      copy.instance_variable_set(:@pokemon, b.pokemon.clone) if b.pokemon
      copy.instance_variable_set(:@battle, preview)
      copy.instance_variable_set(:@effects, b.effects.dup)
      copy.instance_variable_set(:@stages, b.stages.dup)
      copy
    end
    preview.instance_variable_set(:@battlers, battlers)
    user = battlers[user.index]
    target = battlers[target.index]
    native = Battle::Move.from_pokemon_move(preview, Pokemon::Move.new(move.id))
    preview.moldBreaker = ignores_ability?(user, native, target)
    return false if target.effects[PBEffects::Substitute] > 0 && !native.ignoresSubstitute?(user)
    if native.canMagicCoat?
      return false if target.effects[PBEffects::MagicCoat]
      return false if target.hasActiveAbility?(:MAGICBOUNCE) && !preview.moldBreaker
    end
    return false if native.pbImmunityByAbility(user, target, false)
    case move.id
    when :YAWN
      return false if target.effects[PBEffects::Yawn] > 0
      return false unless target.pbCanSleep?(user, false, native) && target.pbCanSleepYawn?
      return false if target.hasActiveItem?([:LUMBERRY, :CHESTOBERRY]) && target.canConsumeBerry?
      return true
    when :TRICK, :SWITCHEROO
      return false if user.wild? || ![:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(user.item_id)
      return false if native.pbFailsAgainstTarget?(user, target, false)
      target.item = user.item_id
      return target.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF])
    when :DISABLE
      attack = target.moves.find { |m| m && m.damagingMove? && m.pp > 0 }
      return false unless attack
      # A future attack, rather than the setup move, must be available to disable.
      target.lastRegularMoveUsed = attack.id
    end
    !native.pbFailsAgainstTarget?(user, target, false)
  end
end

module AdvancedAI::Utilities
  def self.counter_priority_blocked?(battle, move, user, target)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    move = move.move if move.respond_to?(:move)
    return false unless target.opposes?(user)
    preview = battle.clone
    native = Battle::Move.from_pokemon_move(preview, Pokemon::Move.new(move.id))
    return false if native.pbTarget(user).num_targets == 0
    if Settings::MECHANICS_GENERATION >= 7 && native.statusMove? &&
       user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK)
      return true
    end
    priority = AdvancedAI::PriorityTiers.get_priority_tier(native, user)
    return false if priority <= 0
    return true if battle.field.terrain == :Psychic && target.affectedByTerrain?
    choices = battle.choices.map(&:dup)
    choices[user.index][4] = priority
    preview.instance_variable_set(:@choices, choices)
    battle.allBattlers.any? do |bearer|
      next false unless bearer.hasActiveAbility?([:DAZZLING, :QUEENLYMAJESTY, :ARMORTAIL])
      Battle::AbilityEffects.triggerMoveBlocking(bearer.ability, bearer, user, [target], native, preview)
    end
  end
end

module AdvancedAI::Utilities
  def self.counter_shield_blocked?(battle, move, user, target)
    user = user.battler if user.respond_to?(:battler)
    target = target.battler if target.respond_to?(:battler)
    return false unless battle && user && target && user.index != target.index
    native = Battle::Move.from_pokemon_move(battle, Pokemon::Move.new(move.id))
    targets = native.pbTarget(user)
    return false if targets.num_targets == 0
    side = target.pbOwnSide.effects
    return true if side[PBEffects::CraftyShield] && native.statusMove? && !targets.targets_all
    return false if user.hasActiveAbility?(:UNSEENFIST) && native.contactMove?
    if side[PBEffects::WideGuard] && targets.num_targets > 1 &&
       (Settings::MECHANICS_GENERATION >= 7 || native.damagingMove?)
      return true
    end
    return false unless native.canProtectAgainst?
    if side[PBEffects::QuickGuard] && AdvancedAI::PriorityTiers.get_priority_tier(native, user) > 0
      return true
    end
    return true if [:Protect, :SpikyShield, :BanefulBunker].any? { |effect| target.effects[PBEffects.const_get(effect)] }
    if native.damagingMove?
      return true if side[PBEffects::MatBlock]
      return true if [:KingsShield, :Obstruct, :SilkTrap, :BurningBulwark].any? do |effect|
        PBEffects.const_defined?(effect) && target.effects[PBEffects.const_get(effect)]
      end
    end
    false
  end
end

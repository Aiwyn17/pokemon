# Advanced AI System - Doubles Coordination

module AdvancedAI
  module DoublesCoordination
    def self.prevent_overkill(battle, attacker, target, skill_level = 100)
      return 0 unless skill_level >= 50
      return 0 unless battle.pbSideSize(0) > 1  # Doubles/Triples only
      return 0 unless target

      partner = find_partner(battle, attacker)
      return 0 unless partner

      partner_targeting_same = partner_targets?(battle, partner, target)
      return 0 unless partner_targeting_same

      hp_percent = target.hp.to_f / target.totalhp
      if hp_percent < 0.3
        return -40  # Switch target to avoid overkill
      elsif hp_percent < 0.5
        return -20
      end

      0
    end

    def self.prevent_move_conflicts(battle, attacker, move, skill_level = 100)
      return 0 unless skill_level >= 50
      return 0 unless battle.pbSideSize(0) > 1

      partner = find_partner(battle, attacker)
      return 0 unless partner

      partner_move = partner_planned_move_id(battle, partner)
      return 0 unless partner_move  # Partner hasn't chosen yet or is attacking

      screen_moves  = [:REFLECT, :LIGHTSCREEN, :AURORAVEIL]
      hazard_moves  = [:STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB]
      weather_moves = [:SUNNYDAY, :RAINDANCE, :SANDSTORM, :HAIL, :SNOWSCAPE, :CHILLYRECEPTION]

      if screen_moves.include?(move.id) && screen_moves.include?(partner_move)
        return -60  # Partner already setting a screen
      end

      if hazard_moves.include?(move.id) && hazard_moves.include?(partner_move)
        return -50
      end

      if weather_moves.include?(move.id) && weather_moves.include?(partner_move)
        return -40
      end

      0
    end

    def self.optimize_spread_moves(battle, attacker, move, skill_level = 100)
      return 0 unless skill_level >= 60
      return 0 unless battle.pbSideSize(0) > 1
      return 0 unless move.damagingMove?
      target_data = move.pbTarget(attacker) rescue nil
      return 0 unless target_data && target_data.num_targets > 1

      score = 0
      partner = find_partner(battle, attacker)

      score -= 8  # Small penalty for reduced damage per target

      if partner && hits_partner?(move, attacker, partner)
        resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
        type_mod = Effectiveness.calculate(resolved_type, *partner.pbTypes(true))

        if Effectiveness.ineffective?(type_mod)
          score += 30  # Partner immune → very good!
        elsif Effectiveness.not_very_effective?(type_mod)
          score += 15  # Partner resists
        else
          dmg = (AdvancedAI::CombatUtilities.estimate_damage(attacker, move, partner) rescue 0)
          hp  = [partner.hp, 1].max
          if dmg >= hp
            score -= 150  # would KO our own partner
          elsif dmg >= hp * 0.5
            score -= 80
          elsif dmg >= hp * 0.25
            score -= 40
          else
            score -= 15
          end
        end
      end

      enemies_hit = count_enemies_hit(battle, attacker, move)
      score += enemies_hit * 20

      score
    end

    def self.coordinate_field_effects(battle, attacker, move, skill_level = 100)
      return 0 unless skill_level >= 70
      return 0 unless battle.pbSideSize(0) > 1

      score = 0
      partner = find_partner(battle, attacker)
      return 0 unless partner

      if move.function_code.include?("Weather")
        if move.id == :RAINDANCE && (partner.hasActiveAbility?(:SWIFTSWIM) || partner.hasActiveAbility?(:DRIZZLE))
          score += 40  # Partner benefits
        elsif move.id == :SUNNYDAY && (partner.hasActiveAbility?(:CHLOROPHYLL) || partner.hasActiveAbility?(:DROUGHT))
          score += 40
        elsif move.id == :SANDSTORM && (partner.hasActiveAbility?(:SANDRUSH) || partner.hasActiveAbility?(:SANDSTREAM))
          score += 40
        elsif [:HAIL, :SNOWSCAPE].include?(move.id) && (partner.hasActiveAbility?(:SLUSHRUSH) || partner.hasActiveAbility?(:SNOWWARNING))
          score += 40
        end
      end

      if move.function_code.include?("Terrain")
        if move.id == :ELECTRICTERRAIN && (partner.hasActiveAbility?(:SURGESURFER) || partner.hasActiveAbility?(:QUARKDRIVE) || partner.hasActiveAbility?(:HADRONENGINE))
          score += 35
        elsif move.id == :GRASSYTERRAIN && (partner.pbHasType?(:GRASS) || partner.hasActiveAbility?(:GRASSPELT))
          score += 25
        elsif move.id == :PSYCHICTERRAIN && partner.hasActiveAbility?(:PSYCHICSURGE)
          score += 35
        end
      end

      score
    end

    def self.protect_setup_combo(battle, attacker, move, skill_level = 100)
      return 0 unless skill_level >= 65
      return 0 unless battle.pbSideSize(0) > 1

      partner = find_partner(battle, attacker)
      return 0 unless partner

      if move.id == :PROTECT || move.id == :DETECT
        partner_setup = partner.moves.any? { |m| m && (AdvancedAI.setup_move?(m.id) || m.function_code.to_s.start_with?("RaiseUser")) }
        return 50 if partner_setup && partner.hp > partner.totalhp * 0.7
      end

      0
    end

    module ProtectiveMovesDoubles
      SPREAD_MOVES = [
        :EARTHQUAKE, :SURF, :ROCKSLIDE, :DISCHARGE, :LAVAPLUME,
        :BLIZZARD, :HEATWAVE, :MUDDYWATER, :RAZORLEAF,
        :BULLDOZE, :SNARL, :GLACIATE, :ORIGINPULSE, :PRECIPICEBLADES,
        :DIAMONDSTORM, :PARABOLICCHARGE, :DAZZLINGGLEAM, :EXPLOSION,
        :SELFDESTRUCT, :MAGNITUDE, :BOOMBURST, :HYPERVOICE, :SLUDGEWAVE,
        :ICYWIND, :ERUPTION, :WATERSPOUT, :PETALBLIZZARD,
        :SPRINGTIDESTORM, :BLEAKWINDSTORM, :WILDBOLTSTORM, :SANDSEARSTORM,
        :MAKEITRAIN, :MATCHAGOTCHA, :MORTALSPIN
      ]

      PRIORITY_MOVES = [
        :FAKEOUT, :AQUAJET, :MACHPUNCH, :BULLETPUNCH, :ICESHARD,
        :SHADOWSNEAK, :VACUUMWAVE, :QUICKATTACK, :EXTREMESPEED,
        :ACCELEROCK, :FIRSTIMPRESSION, :WATERSHURIKEN, :SUCKERPUNCH,
        :JETPUNCH, :GRASSYGLIDE, :THUNDERCLAP, :UPPERHAND
      ]

      def self.predict_spread_moves(battle, attacker)
        return [] unless battle.pbSideSize(0) > 1

        predicted_moves = []
        battle.allOtherSideBattlers(attacker.index).each do |opponent|
          next unless opponent && !opponent.fainted?

          opponent.moves.each_with_index do |move, i|
            next unless move && move.damagingMove?
            next unless battle.pbCanChooseMove?(opponent.index, i, false)
            if SPREAD_MOVES.include?(move.id)
              predicted_moves << move.id
            elsif move.pbTarget(opponent).num_targets > 1
              predicted_moves << move.id
            end
          end
        end

        predicted_moves.uniq
      end

      def self.predict_priority_moves(battle, attacker)
        return [] unless battle.pbSideSize(0) > 1

        predicted_moves = []
        battle.allOtherSideBattlers(attacker.index).each do |opponent|
          next unless opponent && !opponent.fainted?

          opponent.moves.each_with_index do |move, i|
            next unless move && battle.pbCanChooseMove?(opponent.index, i, false)
            next unless move.pbTarget(opponent).targets_foe
            if AdvancedAI::PriorityTiers.get_priority_tier(move, opponent) > 0
              predicted_moves << move.id
            end
          end
        end

        predicted_moves.uniq
      end

      def self.evaluate_wide_guard(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :WIDEGUARD

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)

        predicted_spread = predict_spread_moves(battle, attacker)

        if predicted_spread.empty?
          return -30  # No spread moves predicted, don't waste turn
        end

        score += 40

        if partner
          predicted_spread.each do |move_id|
            move_data = GameData::Move.try_get(move_id)
            next unless move_data

            resolved_type = move_data.type
            battle.allOtherSideBattlers(attacker.index).each do |opp|
              next unless opp && !opp.fainted?
              if opp.moves.any? { |m| m.id == move_id }
                resolved_type = CombatUtilities.resolve_move_type(opp, move_data)
                break
              end
            end
            type_mod = Effectiveness.calculate(resolved_type, *partner.pbTypes(true))

            if Effectiveness.super_effective?(type_mod)
              score += 30  # Partner is weak to this spread move!
            elsif Effectiveness.not_very_effective?(type_mod)
              score += 10  # Still good to protect
            end
          end
        end

        allies_count = battle.allSameSideBattlers(attacker.index).count { |b| b && !b.fainted? }
        score += (allies_count - 1) * 15

        if attacker.effects[PBEffects::ProtectRate] > 1
          score -= 40  # Protect-like moves have diminishing returns
        end

        score
      end

      def self.evaluate_quick_guard(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :QUICKGUARD

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)

        predicted_priority = predict_priority_moves(battle, attacker)

        if predicted_priority.empty?
          return -30  # No priority moves predicted
        end

        score += 35

        if partner && partner.hp < partner.totalhp * 0.4
          score += 40
        end

        if battle.turnCount == 0 && predicted_priority.include?(:FAKEOUT)
          score += 50
        end

        if attacker.effects[PBEffects::ProtectRate] > 1
          score -= 35
        end

        score
      end
    end

    module RedirectionStrategies
      def self.partner_is_setting_up?(partner)
        return false unless partner

        setup_moves = [:SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :CALMMIND,
                       :BULKUP, :AGILITY, :ROCKPOLISH, :QUIVERDANCE,
                       :SHELLSMASH, :GEOMANCY, :GROWTH, :WORKUP,
                       :VICTORYDANCE, :FILLETAWAY, :TIDYUP, :NORETREAT,
                       :CLANGOROUSSOUL, :SHIFTGEAR, :COIL]

        partner.moves.any? { |m| m && setup_moves.include?(m.id) }
      end

      def self.good_redirector?(attacker)
        return false unless attacker

        def_stat = attacker.defense
        spdef_stat = attacker.spdef
        hp_stat = attacker.hp

        total_bulk = def_stat + spdef_stat + (hp_stat / 2)
        return total_bulk > 300  # Arbitrary threshold
      end

      def self.evaluate_follow_me(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :FOLLOWME || move.id == :RAGEPOWDER

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        partner_move = DoublesCoordination.partner_planned_move_id(battle, partner)
        if partner_move
          if partner_move == :HELPINGHAND
            score -= 200  # Redirect + Helping Hand = zero offense
          end
          if DoublesCoordination::REDIRECT_MOVE_IDS.include?(partner_move)
            score -= 150  # Both redirecting = wasted
          end
          if DoublesCoordination::PROTECT_MOVE_IDS.include?(partner_move)
            score -= 100  # Redirect + Protect = partner is safe already
          end
        end

        if partner_is_setting_up?(partner)
          score += 70
          if partner.hp > partner.totalhp * 0.7
            score += 20
          end
        end

        if partner.hp < partner.totalhp * 0.3
          score += 60
        elsif partner.hp < partner.totalhp * 0.5
          score += 30
        end

        if good_redirector?(attacker)
          score += 25
        end

        if attacker.hp > attacker.totalhp * 0.8
          score += 20
        end

        # Penalty if already used recently (can't spam)
        if attacker.effects[PBEffects::FollowMe] > 0
          score -= 80
        end

        score
      end

      def self.evaluate_rage_powder(battle, attacker, move, skill_level = 100)
        return 0 unless move.id == :RAGEPOWDER

        score = evaluate_follow_me(battle, attacker, move, skill_level)

        immune_opponents = battle.allOtherSideBattlers(attacker.index).any? do |opp|
          next false unless opp && !opp.fainted?
          opp.pbHasType?(:GRASS) || opp.hasActiveAbility?(:OVERCOAT)
        end

        score -= 40 if immune_opponents

        score
      end

      def self.should_protect_partner?(battle, attacker, partner)
        return false unless partner

        return true if partner_is_setting_up?(partner)

        return true if partner.hp < partner.totalhp * 0.4

        if partner.attack > 120 || partner.spatk > 120
          return true
        end

        false
      end
    end

    def self.evaluate_fake_out(battle, attacker, move, target, skill_level = 100)
      return 0 unless skill_level >= 60
      return 0 unless battle.pbSideSize(0) > 1
      return 0 unless move.id == :FAKEOUT

      score = 0

      if battle.turnCount == 0 || attacker.turnCount == 0
        score += 50  # Strong bonus for Turn 1
      else
        return -80  # Fake Out fails if not Turn 1
      end

      partner = find_partner(battle, attacker)
      if partner && target
        target.moves.each do |target_move|
          next unless target_move

          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, target_move)
          type_mod = Effectiveness.calculate(resolved_type, *partner.pbTypes(true))
          if Effectiveness.super_effective?(type_mod)
            score += 30  # Target threatens partner!
          end
        end

        setup_moves = [:SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :SHELLSMASH,
                       :QUIVERDANCE, :CALMMIND, :BULKUP, :AGILITY, :ROCKPOLISH, :COIL,
                       :VICTORYDANCE, :FILLETAWAY, :TIDYUP, :SHIFTGEAR, :NORETREAT,
                       :CLANGOROUSSOUL, :GEOMANCY]
        if target.moves.any? { |m| m && setup_moves.include?(m.id) }
          score += 40
        end
      end

      if partner && partner.moves.any? { |m| m && m.id == :FAKEOUT }
        score -= 30  # Don't both use Fake Out
      end

      score
    end

    def self.evaluate_protect_doubles(battle, attacker, move, skill_level = 100)
      return 0 unless skill_level >= 65
      return 0 unless battle.pbSideSize(0) > 1
      return 0 unless [:PROTECT, :DETECT, :KINGSSHIELD, :SPIKYSHIELD, :BANEFULBUNKER,
                        :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK].include?(move.id)

      score = 0
      partner = find_partner(battle, attacker)

      if partner
        partner.moves.each do |partner_move|
          next unless partner_move

          if hits_partner?(partner_move, partner, attacker)
            resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(partner, partner_move)
            type_mod = Effectiveness.calculate(resolved_type, *attacker.pbTypes(true))

            if !Effectiveness.ineffective?(type_mod)
              score += 55  # Protect from partner's spread move!
            end
          end
        end

        if RedirectionStrategies.partner_is_setting_up?(partner)
          score += 50
        end
      end

      # Alternate Protect usage (don't spam)
      if attacker.effects[PBEffects::ProtectRate] > 1
        score -= 60  # Diminishing returns
      end

      predicted_spread = ProtectiveMovesDoubles.predict_spread_moves(battle, attacker)
      if !predicted_spread.empty?
        score += 25
      end

      score
    end

    module SpeedControlDoubles
      TRICK_ROOM_THRESHOLD = 60  # Base speed threshold

      TAILWIND_THRESHOLD = 80  # Base speed threshold

      SPEED_CONTROL_MOVES = [:ICYWIND, :ELECTROWEB, :STRINGSHOT, :BULLDOZE, :ROCKTOMB, :GLACIATE]

      def self.evaluate_tailwind(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :TAILWIND

        score = 0

        if attacker.pbOwnSide.effects[PBEffects::Tailwind] > 0
          return -80  # Already have Tailwind
        end

        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        fast_allies = allies.count { |b| b.speed >= TAILWIND_THRESHOLD }

        score += fast_allies * 25

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        slower_count = 0
        allies.each do |ally|
          opponents.each do |opp|
            slower_count += 1 if AdvancedAI::SpeedTiers.calculate_effective_speed(battle, ally) < AdvancedAI::SpeedTiers.calculate_effective_speed(battle, opp)
          end
        end

        score += slower_count * 15

        if battle.field.effects[PBEffects::TrickRoom] > 0
          score -= 70
        end

        if battle.turnCount == 0
          score += 30
        end

        partner = DoublesCoordination.find_partner(battle, attacker)
        if partner
          if partner.attack > 120 || partner.spatk > 120
            score += 25  # Partner is offensive
          end
        end

        score
      end

      def self.evaluate_trick_room(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :TRICKROOM

        score = 0

        trick_room_active = battle.field.effects[PBEffects::TrickRoom] > 0

        if trick_room_active
          allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          slow_allies = allies.count { |b| b.speed < TRICK_ROOM_THRESHOLD }

          if slow_allies >= allies.length / 2
            return -60  # Don't turn OFF our own Trick Room
          else
            score += 40  # Turn off opponent's Trick Room
          end
        else
          allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          slow_allies = allies.count { |b| b.speed < TRICK_ROOM_THRESHOLD }

          if slow_allies == 0
            return -50  # No slow Pokemon to benefit
          end

          score += slow_allies * 30

          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          fast_opponents = opponents.count { |b| b.speed >= TAILWIND_THRESHOLD }
          score += fast_opponents * 20

          if attacker.pbOwnSide.effects[PBEffects::Tailwind] > 0
            score -= 50
          end

          if battle.turnCount == 0
            score += 25
          end
        end

        score
      end

      def self.evaluate_speed_control_attack(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless SPEED_CONTROL_MOVES.include?(move.id)

        score = 0

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        outsped = 0
        allies.each do |ally|
          opponents.each do |opp|
            outsped += 1 if AdvancedAI::SpeedTiers.calculate_effective_speed(battle, ally) < AdvancedAI::SpeedTiers.calculate_effective_speed(battle, opp)
          end
        end

        score += outsped * 15

        if move.id == :ICYWIND
          score += opponents.count * 10
        end

        if battle.field.effects[PBEffects::TrickRoom] > 0
          score -= 40
        end

        score
      end

      def self.team_benefits_from_trick_room?(battle, side)
        battlers = []
        battle.allSameSideBattlers(side).each { |b| battlers << b if b && !b.fainted? }

        slow_count = battlers.count { |b| b.speed < TRICK_ROOM_THRESHOLD }
        slow_count >= battlers.length / 2
      end
    end

    module WeatherCoordinationDoubles
      WEATHER_ABILITIES = {
        :Sun  => [:DROUGHT, :ORICHALCUMPULSE, :DESOLATELAND],
        :Rain => [:DRIZZLE, :PRIMORDIALSEA],
        :Sandstorm => [:SANDSTREAM, :SANDSPIT],
        :Snow => [:SNOWWARNING]
      }

      WEATHER_SYNERGY = {
        :Sun  => [:CHLOROPHYLL, :SOLARPOWER, :FLOWERGIFT, :LEAFGUARD, :HARVEST, :PROTOSYNTHESIS],
        :Rain => [:SWIFTSWIM, :RAINDISH, :DRYSKIN, :HYDRATION],
        :Sandstorm => [:SANDRUSH, :SANDFORCE, :SANDVEIL],
        :Hail => [:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :ICEFACE],
        :Snow => [:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :ICEFACE]
      }

      WEATHER_MOVE_BOOST = {
        :Sun  => :FIRE,
        :Rain => :WATER
      }

      def self.evaluate_weather_move(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1

        weather_moves = {
          :SUNNYDAY => :Sun,
          :RAINDANCE => :Rain,
          :SANDSTORM => :Sandstorm,
          :HAIL => :Hail,
          :SNOWSCAPE => :Snow,
          :CHILLYRECEPTION => :Snow
        }

        target_weather = weather_moves[move.id]
        return 0 unless target_weather

        score = 0

        current_weather = AdvancedAI::Utilities.current_weather(battle)
        if current_weather == target_weather
          return -60  # Already have this weather
        end

        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        synergy_abilities = WEATHER_SYNERGY[target_weather] || []

        allies.each do |ally|
          if synergy_abilities.any? { |a| ally.hasActiveAbility?(a) }
            score += 40
          end

          boost_type = WEATHER_MOVE_BOOST[target_weather]
          if boost_type
            stab_moves = ally.moves.count { |m| m && m.type == boost_type }
            score += stab_moves * 15
          end
        end

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        opponents.each do |opp|
          if synergy_abilities.any? { |a| opp.hasActiveAbility?(a) }
            score -= 35
          end
        end

        if battle.turnCount == 0
          score += 20
        end

        # Check partner's ability for auto-weather (don't override)
        partner = DoublesCoordination.find_partner(battle, attacker)
        if partner
          WEATHER_ABILITIES.each do |weather_type, abilities|
            if abilities.any? { |a| partner.hasActiveAbility?(a) }
              if weather_type == target_weather
                score -= 30  # Partner already sets this weather
              else
                score -= 20  # Weather conflict with partner
              end
            end
          end
        end

        score
      end

      def self.evaluate_weather_boosted_move(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless battle.pbSideSize(0) > 1

        score = 0
        current_weather = AdvancedAI::Utilities.current_weather(battle)

        if current_weather == :Sun
          score += 25 if move.type == :FIRE
          score -= 20 if move.type == :WATER
          # Solar Beam / Solar Blade don't need charging
          score += 30 if [:SOLARBEAM, :SOLARBLADE].include?(move.id)
        end

        if current_weather == :Rain
          score += 25 if move.type == :WATER
          score -= 20 if move.type == :FIRE
          # Thunder / Hurricane don't miss
          score += 20 if [:THUNDER, :HURRICANE].include?(move.id)
        end

        if current_weather == :Hail || current_weather == :Snow
          score += 20 if move.id == :BLIZZARD
          score += 30 if move.id == :AURORAVEIL
        end

        if move.id == :WEATHERBALL && current_weather != :None
          score += 25
        end

        score
      end
    end

    module AllySynergyDoubles
      ALLY_BOOST_MOVES = [:HELPINGHAND, :COACHING, :DECORATE, :AROMATHERAPY,
                          :HEALBELL, :LIFEDEW, :POLLENPUFF, :HEALPULSE]

      def self.evaluate_helping_hand(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :HELPINGHAND

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return -50 unless partner  # No partner to help

        partner_move = DoublesCoordination.partner_planned_move_id(battle, partner)
        if partner_move
          if DoublesCoordination::REDIRECT_MOVE_IDS.include?(partner_move)
            return -200  # Redirect + Helping Hand = wasted turn
          end
          if DoublesCoordination::PROTECT_MOVE_IDS.include?(partner_move)
            return -150  # Protect + Helping Hand = wasted turn
          end
          if partner_move == :HELPINGHAND
            return -100  # Both using Helping Hand = no attacks
          end
        end

        if partner.attack > 120 || partner.spatk > 120
          score += 40
        end

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        faster_than_all = opponents.all? { |opp| AdvancedAI::SpeedTiers.calculate_effective_speed(battle, partner) > AdvancedAI::SpeedTiers.calculate_effective_speed(battle, opp) }
        score += 25 if faster_than_all

        has_spread = partner.moves.any? do |m|
          m && m.pbTarget(partner).num_targets > 1
        end
        score += 30 if has_spread

        score -= 20 if RedirectionStrategies.partner_is_setting_up?(partner)

        score
      end

      def self.evaluate_coaching(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :COACHING

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return -50 unless partner

        if partner.attack > partner.spatk
          score += 35
          if partner.stages[:ATTACK] < 6
            score += 20
          end
        end

        if partner.hp < partner.totalhp * 0.3
          score -= 30  # Partner likely fainted before they can use the boost
        end

        score
      end

      def self.evaluate_ally_heal(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless [:LIFEDEW, :HEALPULSE, :POLLENPUFF].include?(move.id)

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return -30 unless partner

        hp_percent = partner.hp.to_f / partner.totalhp

        if hp_percent < 0.3
          score += 60
        elsif hp_percent < 0.5
          score += 40
        elsif hp_percent < 0.7
          score += 20
        else
          score -= 30  # Partner is healthy
        end

        if move.id == :POLLENPUFF
          score += 15  # Versatile move
        end

        score
      end

      def self.evaluate_ally_switch(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 80
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :ALLYSWITCH

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return -30 unless partner

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        partner_threatened = false
        attacker_resists = false

        opponents.each do |opp|
          opp.moves.each do |opp_move|
            next unless opp_move && opp_move.damagingMove?

            resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(opp, opp_move)
            partner_mod = Effectiveness.calculate(resolved_type, *partner.pbTypes(true))
            attacker_mod = Effectiveness.calculate(resolved_type, *attacker.pbTypes(true))

            if Effectiveness.super_effective?(partner_mod)
              partner_threatened = true
              if Effectiveness.not_very_effective?(attacker_mod) || Effectiveness.ineffective?(attacker_mod)
                attacker_resists = true
              end
            end
          end
        end

        if partner_threatened && attacker_resists
          score += 60  # Swap to take resisted hit
        elsif partner_threatened
          score += 25  # At least swap positions
        end

        # Don't spam (becomes predictable)
        if defined?(PBEffects::AllySwitch) && attacker.effects[PBEffects::AllySwitch]
          score -= 40
        end

        score
      end
    end

    module ComboCoordinationDoubles
      CLASSIC_COMBOS = {
        :EARTHQUAKE => [:LEVITATE, :FLYINGTYPE, :AIRBALLOON, :TELEKINESIS, :EARTHEATER],
        :SURF => [:WATERABSORB, :DRYSKIN, :STORMDRAIN],
        :DISCHARGE => [:LIGHTNINGROD, :VOLTABSORB, :MOTORDRIVE],
        :HEATWAVE => [:FLASHFIRE, :WELLBAKEDBODY],
        :BEATUP => [:JUSTIFIED],  # Beat Up + Justified combo
        :SWAGGER => [:OWNTEMPO],  # Swagger + Own Tempo combo
      }

      def self.check_combo_potential(battle, attacker, move)
        return 0 unless battle.pbSideSize(0) > 1

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        combo_synergy = CLASSIC_COMBOS[move.id]
        return 0 unless combo_synergy

        score = 0

        combo_synergy.each do |synergy|
          case synergy
          when :FLYINGTYPE
            score += 50 if partner.pbHasType?(:FLYING)
          when :AIRBALLOON
            score += 40 if partner.item_id == :AIRBALLOON
          else
            score += 45 if partner.hasActiveAbility?(synergy)
          end
        end

        score
      end

      def self.evaluate_setup_for_partner(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        if [:REFLECT, :LIGHTSCREEN, :AURORAVEIL].include?(move.id)
          if partner.attack > 100 || partner.spatk > 100
            score += 25
          end
        end

        if move.id == :BEATUP && partner.hasActiveAbility?(:JUSTIFIED)
          score += 80  # Classic combo!
        end

        if move.id == :DECORATE
          score += 60
        end

        score
      end
    end

    module TurnOrderDoubles
      def self.evaluate_after_you(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :AFTERYOU

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return -50 unless partner

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        partner_outsped = opponents.any? { |opp| AdvancedAI::SpeedTiers.calculate_effective_speed(battle, partner) < AdvancedAI::SpeedTiers.calculate_effective_speed(battle, opp) }

        if partner_outsped
          score += 35

          if RedirectionStrategies.partner_is_setting_up?(partner)
            score += 40
          end

          if partner.attack > 120 || partner.spatk > 120
            score += 25
          end

          if partner.hp < partner.totalhp * 0.4
            score += 30
          end
        else
          score -= 30  # Partner already faster, After You less useful
        end

        score
      end

      def self.evaluate_quash(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :QUASH
        return 0 unless target

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)

        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        target_faster_than_allies = allies.any? { |ally| AdvancedAI::SpeedTiers.calculate_effective_speed(battle, target) > AdvancedAI::SpeedTiers.calculate_effective_speed(battle, ally) }

        if target_faster_than_allies
          score += 40

          setup_moves = [:SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :SHELLSMASH, :QUIVERDANCE,
                         :CALMMIND, :VICTORYDANCE, :FILLETAWAY, :GEOMANCY]
          if target.moves.any? { |m| m && setup_moves.include?(m.id) }
            score += 35
          end

          if target.moves.any? { |m| m && m.priority > 0 }
            score += 25
          end
        else
          score -= 25  # Target already slow
        end

        score
      end

      def self.evaluate_instruct(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :INSTRUCT

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return -50 unless partner

        if partner.lastRegularMoveUsed
          last_move = GameData::Move.try_get(partner.lastRegularMoveUsed)
          if last_move
            eff_power = AdvancedAI::CombatUtilities.resolve_move_power(last_move)
            if eff_power >= 100
              score += 50
            elsif eff_power >= 70
              score += 30
            elsif last_move.power == 0
              score -= 30  # Status move, less value
            end

            # Spread move = extra value (hits multiple)
            # last_move.target is a Symbol (e.g. :AllNearFoes) from GameData::Move,
            # so we must resolve it to a GameData::Target object first
            target_data = GameData::Target.try_get(last_move.target)
            if target_data && target_data.num_targets > 1
              score += 25
            end
          end
        else
          if partner.attack > 120 || partner.spatk > 120
            score += 25  # Offensive partner likely used strong move
          end
        end

        score
      end
    end

    module AdditionalProtectionDoubles
      def self.evaluate_mat_block(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :MATBLOCK

        score = 0

        if attacker.turnCount != 0
          return -100  # Fails if not first turn out
        end

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        threat = opponents.any? do |opp|
          usable = opp.moves.each_with_index.select do |candidate, i|
            candidate && battle.pbCanChooseMove?(opp.index, i, false)
          end
          usable.empty? || usable.any? { |candidate, _| candidate.damagingMove? }
        end
        return -40 unless threat

        score += 60

        partner = DoublesCoordination.find_partner(battle, attacker)
        if partner && RedirectionStrategies.partner_is_setting_up?(partner)
          score += 40
        end

        high_offense = opponents.count { |opp| opp.attack > 100 || opp.spatk > 100 }
        score += high_offense * 20

        score
      end

      def self.evaluate_crafty_shield(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :CRAFTYSHIELD

        score = 0

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        status_moves = 0
        opponents.each do |opp|
          opp.moves.each_with_index do |opp_move, i|
            next unless opp_move && opp_move.statusMove?
            next unless battle.pbCanChooseMove?(opp.index, i, false)
            next unless opp_move.pbTarget(opp).targets_foe
            status_moves += 1
          end
        end

        if status_moves == 0
          return -40  # No status moves to block
        end

        score += status_moves * 15

        partner = DoublesCoordination.find_partner(battle, attacker)
        if partner
          if partner.attack > partner.spatk
            score += 15
          end
          if partner.speed > 100
            score += 15
          end
        end

        if attacker.effects[PBEffects::ProtectRate] > 1
          score -= 40
        end

        score
      end

      def self.evaluate_spotlight(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :SPOTLIGHT
        return 0 unless target

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        punishing_abilities = [:ROUGHSKIN, :IRONBARBS, :FLAMEBODY, :STATIC, :POISONPOINT]
        if punishing_abilities.any? { |a| target.hasActiveAbility?(a) }
          score -= 40
        end

        if target.defense > 100 || target.spdef > 100
          score -= 25
        end

        if target.item_id == :ROCKYHELMET
          score -= 30
        end

        hp_pct = target.hp.to_f / target.totalhp
        if hp_pct < 0.5
          score += 35
        end

        score
      end
    end

    module Gen9DoublesStrategies
      def self.evaluate_revival_blessing(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :REVIVALBLESSING

        score = 0

        party = battle.pbParty(attacker.index & 1)
        fainted_count = party.count { |pkmn| pkmn && pkmn.fainted? }

        if fainted_count == 0
          return -100  # No one to revive
        end

        score += 70  # Strong move to bring back ally

        party.each do |pkmn|
          next unless pkmn && pkmn.fainted?
          bst = pkmn.baseStats.values.sum
          if bst > 500
            score += 30  # Strong Pokemon worth reviving
            break
          end
        end

        score
      end

      def self.evaluate_shed_tail(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :SHEDTAIL

        score = 0

        if attacker.hp <= attacker.totalhp / 2
          return -50  # Too low HP to use
        end

        party = battle.pbParty(attacker.index & 1)
        available = party.count { |pkmn| pkmn && !pkmn.fainted? && pkmn != attacker.pokemon }

        if available == 0
          return -100  # No one to switch in
        end

        score += 50

        party.each do |pkmn|
          next unless pkmn && !pkmn.fainted? && pkmn != attacker.pokemon
          pkmn.moves.each do |m|
            next unless m
            if [:SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :SHELLSMASH, :QUIVERDANCE, :CALMMIND,
                :VICTORYDANCE, :FILLETAWAY, :GEOMANCY].include?(m.id)
              score += 35
              break
            end
          end
        end

        score
      end

      def self.evaluate_doodle(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :DOODLE
        return 0 unless target

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        good_abilities = [:INTIMIDATE, :HUGEPOWER, :PUREPOWER, :SPEEDBOOST, :PROTEAN,
                          :LIBERO, :ADAPTABILITY, :CONTRARY, :MOODY, :UNAWARE,
                          :MAGICGUARD, :MULTISCALE, :STURDY, :LEVITATE]

        if good_abilities.any? { |a| target.hasActiveAbility?(a) }
          score += 50

          if target.hasActiveAbility?(:HUGEPOWER) || target.hasActiveAbility?(:PUREPOWER)
            score += 30 if partner.attack > partner.spatk
          elsif target.hasActiveAbility?(:SPEEDBOOST)
            score += 25 if partner.speed < 100
          elsif target.hasActiveAbility?(:INTIMIDATE)
            score += 20  # Always useful
          end
        end

        score
      end

      def self.check_commander_combo(battle, attacker)
        return 0 unless battle.pbSideSize(0) > 1

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        if attacker.hasActiveAbility?(:COMMANDER) && partner.species == :DONDOZO
          return 100
        elsif partner.hasActiveAbility?(:COMMANDER) && attacker.species == :DONDOZO
          return 80  # Bonus for being the Dondozo
        end

        0
      end

      def self.evaluate_tidy_up(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless move.id == :TIDYUP

        score = 0

        own_side = attacker.pbOwnSide
        hazard_count = 0
        hazard_count += 1 if own_side.effects[PBEffects::StealthRock]
        hazard_count += own_side.effects[PBEffects::Spikes] if own_side.effects[PBEffects::Spikes]
        hazard_count += own_side.effects[PBEffects::ToxicSpikes] if own_side.effects[PBEffects::ToxicSpikes]
        hazard_count += 1 if own_side.effects[PBEffects::StickyWeb]

        score += hazard_count * 20

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        subs = opponents.count { |opp| opp.effects[PBEffects::Substitute] > 0 }
        score += subs * 25

        if attacker.stages[:ATTACK] < 6
          score += 20
        end
        if attacker.stages[:SPEED] < 6
          score += 15
        end

        score
      end

      def self.evaluate_psychic_terrain_doubles(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :PSYCHICTERRAIN

        score = 0

        if battle.field.terrain == :Psychic
          return -60
        end

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        priority_count = 0
        opponents.each do |opp|
          opp.moves.each do |m|
            next unless m
            priority_count += 1 if m.priority > 0
          end
        end

        score += priority_count * 20

        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        psychic_users = allies.count do |ally|
          ally.moves.any? { |m| m && m.type == :PSYCHIC && m.damagingMove? }
        end
        score += psychic_users * 25

        expanding_force_users = allies.count do |ally|
          ally.moves.any? { |m| m && m.id == :EXPANDINGFORCE }
        end
        score += expanding_force_users * 40

        score
      end

      def self.check_ability_synergy(battle, attacker, move, target = nil)
        return 0 unless battle.pbSideSize(0) > 1

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        score = 0

        wind_moves = [:TAILWIND, :BLEAKWINDSTORM, :SPRINGTIDESTORM, :WILDBOLTSTORM,
                     :SANDSEARSTORM, :ICYWIND, :BLIZZARD, :PETALBLIZZARD,
                     :HURRICANE, :GUST, :TWISTER, :FAIRYWIND]
        if partner.hasActiveAbility?(:WINDRIDER) && wind_moves.include?(move.id)
          score += 45  # Partner gets Attack boost
        end

        if partner.hasActiveAbility?(:STEAMENGINE)
          if move.type == :FIRE || move.type == :WATER
            if DoublesCoordination.hits_partner?(move, attacker, partner, target)
              score += 35
            end
          end
        end

        if partner.hasActiveAbility?(:ANGERPOINT)
          if [:FROSTBREATH, :STORMTHROW].include?(move.id)
            if DoublesCoordination.hits_partner?(move, attacker, partner, target)
              score += 60  # Guaranteed max Attack!
            end
          end
        end

        score
      end

      def self.check_hospitality_synergy(battle, attacker)
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless attacker.hasActiveAbility?(:HOSPITALITY)

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        if partner.hp < partner.totalhp * 0.75
          return 20  # Partner appreciates the heal
        end

        0
      end
    end

    module DynamaxDoublesStrategies
      MAX_TEAM_MOVES = {
        :MAXAIRSTREAM => :SPEED,      # +1 Speed to all allies
        :MAXSTEELSPIKE => :DEFENSE,   # +1 Defense to all allies
        :MAXQUAKE => :SPDEF,          # +1 SpDef to all allies
        :MAXOOZE => :SPATK,           # +1 SpAtk to all allies
        :MAXKNUCKLE => :ATTACK,       # +1 Attack to all allies
      }

      MAX_WEATHER_MOVES = {
        :MAXFLARE => :Sun,
        :MAXGEYSER => :Rain,
        :MAXROCKFALL => :Sandstorm,
        :MAXHAILSTORM => :Hail
      }

      MAX_TERRAIN_MOVES = {
        :MAXLIGHTNING => :Electric,
        :MAXOVERGROWTH => :Grassy,
        :MAXMINDSTORM => :Psychic,
        :MAXSTARFALL => :Misty
      }

      def self.evaluate_max_guard(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :MAXGUARD

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        dynamaxed_opponents = opponents.count { |opp| opp.dynamax? rescue false }

        score += dynamaxed_opponents * 30

        if partner && RedirectionStrategies.partner_is_setting_up?(partner)
          score += 45
        end

        if attacker.effects[PBEffects::ProtectRate] > 1
          score -= 50
        end

        score
      end

      def self.evaluate_max_team_move(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1

        stat_boost = MAX_TEAM_MOVES[move.id]
        return 0 unless stat_boost

        score = 0
        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        case stat_boost
        when :SPEED
          slow_allies = allies.count { |a| a.stages[:SPEED] < 6 }
          score += slow_allies * 25

          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          outsped = allies.count { |a| opponents.any? { |o| AdvancedAI::SpeedTiers.calculate_effective_speed(battle, o) > AdvancedAI::SpeedTiers.calculate_effective_speed(battle, a) } }
          score += outsped * 15

        when :ATTACK
          phys_attackers = allies.count { |a| a.attack > a.spatk && a.stages[:ATTACK] < 6 }
          score += phys_attackers * 20

        when :SPATK
          spec_attackers = allies.count { |a| a.spatk > a.attack && a.stages[:SPECIAL_ATTACK] < 6 }
          score += spec_attackers * 20

        when :DEFENSE
          score += allies.count * 15
          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          phys_threats = opponents.count { |o| o.attack > o.spatk }
          score += phys_threats * 10

        when :SPDEF
          score += allies.count * 15
          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          spec_threats = opponents.count { |o| o.spatk > o.attack }
          score += spec_threats * 10
        end

        score
      end

      def self.evaluate_max_weather_move(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1

        weather_type = MAX_WEATHER_MOVES[move.id]
        return 0 unless weather_type

        base_weather_id = { :Sun => :SUNNYDAY, :Rain => :RAINDANCE,
                            :Sandstorm => :SANDSTORM, :Hail => :HAIL }[weather_type]
        if base_weather_id
          proxy_data = GameData::Move.try_get(base_weather_id)
          if proxy_data
            proxy_move = Battle::Move.from_pokemon_move(battle, Pokemon::Move.new(base_weather_id)) rescue nil
            if proxy_move
              score = WeatherCoordinationDoubles.evaluate_weather_move(battle, attacker, proxy_move, skill_level)
            else
              score = 0
            end
          else
            score = 0
          end
        else
          score = 0
        end

        score += 15

        score
      end

      def self.evaluate_max_terrain_move(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1

        terrain_type = MAX_TERRAIN_MOVES[move.id]
        return 0 unless terrain_type

        base_terrain_id = { :Electric => :ELECTRICTERRAIN, :Grassy => :GRASSYTERRAIN,
                            :Psychic => :PSYCHICTERRAIN, :Misty => :MISTYTERRAIN }[terrain_type]
        if base_terrain_id
          proxy_move = Battle::Move.from_pokemon_move(battle, Pokemon::Move.new(base_terrain_id)) rescue nil
          if proxy_move
            score = TerrainSynergyDoubles.evaluate_terrain_doubles(battle, attacker, proxy_move, skill_level)
          else
            score = 0
          end
        else
          score = 0
        end

        score += 15

        score
      end

      def self.evaluate_dynamax_timing(battle, attacker, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)

        # Don't both Dynamax at the same time
        if partner && (partner.dynamax? rescue false)
          score -= 60  # Partner already Dynamaxed
        end

        if attacker.attack > 130 || attacker.spatk > 130
          score += 30
        end

        if attacker.hp < attacker.totalhp * 0.5
          score += 25
        end

        if partner
          support_moves = [:HELPINGHAND, :FOLLOWME, :RAGEPOWDER, :ALLYSWITCH]
          has_support = partner.moves.any? { |m| m && support_moves.include?(m.id) }
          score += 35 if has_support
        end

        score
      end

      def self.evaluate_gmax_move(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1

        score = 0

        if move.id == :GMAXVOLCALITH
          opponents = battle.allOtherSideBattlers(attacker.index).count { |b| b && !b.fainted? }
          score += opponents * 20
        end

        if [:GMAXVINELASH, :GMAXWILDFIRE, :GMAXCANNONADE].include?(move.id)
          opponents = battle.allOtherSideBattlers(attacker.index).count { |b| b && !b.fainted? }
          score += opponents * 20
        end

        if move.id == :GMAXWINDRAGE
          opp_side = attacker.pbOpposingSide
          has_screens = opp_side.effects[PBEffects::Reflect] > 0 ||
                        opp_side.effects[PBEffects::LightScreen] > 0 ||
                        opp_side.effects[PBEffects::AuroraVeil] > 0
          score += 40 if has_screens
        end

        if move.id == :GMAXRESONANCE
          if attacker.pbOwnSide.effects[PBEffects::AuroraVeil] == 0
            score += 50
          end
        end

        score
      end
    end

    module Gen9ExtendedStrategies
      def self.evaluate_tera_timing_doubles(battle, attacker, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless battle.pbSideSize(0) > 1

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)

        # Don't both Tera at the same time (usually)
        if partner && (partner.tera? rescue false)
          score -= 30  # Partner already Terastallized
        end

        tera_type = attacker.tera_type rescue nil
        if tera_type
          tera_moves = attacker.moves.count do |m|
            next false unless m && m.damagingMove?
            AdvancedAI::CombatUtilities.resolve_move_type(attacker, m) == tera_type
          end
          score += tera_moves * 20
        end

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        if attacker.hp < attacker.totalhp * 0.6
          score += 15  # More likely to Tera for survival
        end

        score
      end

      def self.evaluate_paradox_moves(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless [:COLLISIONCOURSE, :ELECTRODRIFT].include?(move.id)
        return 0 unless target

        score = 0

        resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
        type_mod = Effectiveness.calculate(resolved_type, *target.pbTypes(true))
        if Effectiveness.super_effective?(type_mod)
          score += 35  # Bonus for using on weak target
        end

        score
      end

      def self.evaluate_terrain_removal(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless [:ICESPINNER, :STEELROLLER].include?(move.id)

        score = 0

        if battle.field.terrain != :None
          score += 30

          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

          case battle.field.terrain
          when :Electric
            electric_benefit = opponents.any? { |o| o.hasActiveAbility?(:SURGESURFER) }
            score += 25 if electric_benefit
          when :Psychic
            allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }
            ally_priority = allies.count { |a| a.moves.any? { |m| m && m.priority > 0 } }
            score += ally_priority * 15  # Remove if WE have priority
          when :Grassy
            score += 15
          end
        else
          if move.id == :STEELROLLER
            return -100
          end
        end

        score
      end

      def self.evaluate_court_change(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless move.id == :COURTCHANGE

        score = 0
        own_side = attacker.pbOwnSide
        opp_side = attacker.pbOpposingSide

        our_hazards = 0
        our_hazards += 1 if own_side.effects[PBEffects::StealthRock]
        our_hazards += own_side.effects[PBEffects::Spikes] if own_side.effects[PBEffects::Spikes]
        our_hazards += own_side.effects[PBEffects::ToxicSpikes] if own_side.effects[PBEffects::ToxicSpikes]
        our_hazards += 1 if own_side.effects[PBEffects::StickyWeb]

        their_hazards = 0
        their_hazards += 1 if opp_side.effects[PBEffects::StealthRock]
        their_hazards += opp_side.effects[PBEffects::Spikes] if opp_side.effects[PBEffects::Spikes]
        their_hazards += opp_side.effects[PBEffects::ToxicSpikes] if opp_side.effects[PBEffects::ToxicSpikes]
        their_hazards += 1 if opp_side.effects[PBEffects::StickyWeb]

        our_screens = 0
        our_screens += 1 if own_side.effects[PBEffects::Reflect] > 0
        our_screens += 1 if own_side.effects[PBEffects::LightScreen] > 0
        our_screens += 1 if own_side.effects[PBEffects::AuroraVeil] > 0

        their_screens = 0
        their_screens += 1 if opp_side.effects[PBEffects::Reflect] > 0
        their_screens += 1 if opp_side.effects[PBEffects::LightScreen] > 0
        their_screens += 1 if opp_side.effects[PBEffects::AuroraVeil] > 0

        score += (our_hazards - their_hazards) * 20
        score += (their_screens - our_screens) * 25

        our_tailwind = own_side.effects[PBEffects::Tailwind] > 0 ? 1 : 0
        their_tailwind = opp_side.effects[PBEffects::Tailwind] > 0 ? 1 : 0
        score += (their_tailwind - our_tailwind) * 30

        score
      end

      def self.evaluate_mortal_spin(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless move.id == :MORTALSPIN

        score = 0
        own_side = attacker.pbOwnSide

        hazard_count = 0
        hazard_count += 1 if own_side.effects[PBEffects::StealthRock]
        hazard_count += own_side.effects[PBEffects::Spikes] if own_side.effects[PBEffects::Spikes]
        hazard_count += own_side.effects[PBEffects::ToxicSpikes] if own_side.effects[PBEffects::ToxicSpikes]
        hazard_count += 1 if own_side.effects[PBEffects::StickyWeb]

        score += hazard_count * 25

        if battle.pbSideSize(0) > 1
          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          poisonable = opponents.count do |opp|
            !opp.pbHasType?(:POISON) && !opp.pbHasType?(:STEEL) && opp.status == :NONE
          end
          score += poisonable * 15
        end

        score
      end

      def self.evaluate_make_it_rain(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :MAKEITRAIN

        score = 0
        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        score += opponents.count * 20

        if attacker.hp < attacker.totalhp * 0.3
          score -= 10  # Too close to fainting to benefit from spread
        end

        score
      end

      def self.evaluate_triple_arrows(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless move.id == :TRIPLEARROWS
        return 0 unless target

        score = 0

        partner = DoublesCoordination.find_partner(battle, attacker)
        if partner && partner.attack > partner.spatk
          score += 25
        end

        if AdvancedAI::SpeedTiers.calculate_effective_speed(battle, attacker) > AdvancedAI::SpeedTiers.calculate_effective_speed(battle, target)
          score += 15
        end

        score
      end

      def self.evaluate_stat_lowering_attacks(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless [:TRAILBLAZE, :CHILLINGWATER, :LUMINACRASH].include?(move.id)
        return 0 unless target

        score = 0

        case move.id
        when :TRAILBLAZE
          if attacker.stages[:SPEED] < 6
            score += 20
          end
        when :CHILLINGWATER
          partner = DoublesCoordination.find_partner(battle, attacker)
          if partner && target.attack > target.spatk
            score += 25  # Reduce threat to partner
          end
        when :LUMINACRASH
          partner = DoublesCoordination.find_partner(battle, attacker)
          if partner && partner.spatk > partner.attack
            score += 30  # Partner can capitalize
          end
        end

        score
      end

      def self.evaluate_order_up(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless move.id == :ORDERUP

        score = 0

        if attacker.species == :DONDOZO
          score += 30
        end

        score
      end

      def self.evaluate_salt_cure(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless move.id == :SALTCURE
        return 0 unless target

        score = 0

        if target.pbHasType?(:WATER) || target.pbHasType?(:STEEL)
          score += 50  # Double damage per turn!
        else
          score += 25  # Still good chip damage
        end

        if target.hp > target.totalhp * 0.7
          score += 15
        end

        score
      end

      def self.evaluate_rage_fist(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless move.id == :RAGEFIST

        score = 0

        real = (attacker.respond_to?(:battler) && attacker.battler) ? attacker.battler : attacker
        times_hit = (real.respond_to?(:num_times_hit) ? real.num_times_hit.to_i : 0) rescue 0

        effective_power = [50 + (times_hit * 50), 350].min

        if effective_power >= 200
          score += 40
        elsif effective_power >= 150
          score += 25
        elsif effective_power >= 100
          score += 10
        end

        score
      end
    end

    module TerrainSynergyDoubles
      TERRAIN_MOVES = {
        :ELECTRICTERRAIN => :Electric,
        :GRASSYTERRAIN => :Grassy,
        :PSYCHICTERRAIN => :Psychic,
        :MISTYTERRAIN => :Misty
      }

      TERRAIN_ABILITIES = {
        :Electric => [:SURGESURFER, :QUARKDRIVE, :HADRONENGINE],
        :Grassy => [:GRASSPELT],
        :Psychic => [],
        :Misty => []
      }

      def self.evaluate_terrain_doubles(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1

        terrain_type = TERRAIN_MOVES[move.id]
        return 0 unless terrain_type

        score = 0

        if battle.field.terrain == terrain_type
          return -60
        end

        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        synergy_abilities = TERRAIN_ABILITIES[terrain_type] || []
        allies.each do |ally|
          if synergy_abilities.any? { |a| ally.hasActiveAbility?(a) }
            score += 35
          end

          seed_items = {
            :Electric => :ELECTRICSEED,
            :Grassy => :GRASSYSEED,
            :Psychic => :PSYCHICSEED,
            :Misty => :MISTYSEED
          }
          if ally.item_id == seed_items[terrain_type]
            score += 40
          end
        end

        case terrain_type
        when :Electric
          electric_users = allies.count do |a|
            a.moves.any? { |m| m && m.damagingMove? && AdvancedAI::CombatUtilities.resolve_move_type(a, m) == :ELECTRIC }
          end
          score += electric_users * 20
          rising_voltage_users = allies.count { |a| a.moves.any? { |m| m && m.id == :RISINGVOLTAGE } }
          score += rising_voltage_users * 35

        when :Grassy
          grass_users = allies.count { |a| a.moves.any? { |m| m && m.type == :GRASS && m.damagingMove? } }
          score += grass_users * 20
          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          eq_users = opponents.count { |o| o.moves.any? { |m| m && m.id == :EARTHQUAKE } }
          score += eq_users * 15
          grassy_glide_users = allies.count { |a| a.moves.any? { |m| m && m.id == :GRASSYGLIDE } }
          score += grassy_glide_users * 30

        when :Psychic
          psychic_users = allies.count { |a| a.moves.any? { |m| m && m.type == :PSYCHIC && m.damagingMove? } }
          score += psychic_users * 20
          expanding_force_users = allies.count { |a| a.moves.any? { |m| m && m.id == :EXPANDINGFORCE } }
          score += expanding_force_users * 40

        when :Misty
          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          dragon_users = opponents.count { |o| o.moves.any? { |m| m && m.type == :DRAGON && m.damagingMove? } }
          score += dragon_users * 20
          misty_explosion_users = allies.count { |a| a.moves.any? { |m| m && m.id == :MISTYEXPLOSION } }
          score += misty_explosion_users * 25
        end

        score
      end
    end

    module ItemAwarenessDoubles
      # Focus Sash awareness - don't overkill, need to break sash first
      def self.check_focus_sash(battle, attacker, target, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless target
        return 0 unless target.item_id == :FOCUSSASH
        return 0 unless target.hp == target.totalhp  # Sash only works at full HP

        score = 0

        if move.multiHitMove?
          score += 40
        end

        partner = DoublesCoordination.find_partner(battle, attacker)
        if partner && battle.pbSideSize(0) > 1
          score += 25
        end

        effective_weather = AdvancedAI::Utilities.current_weather(battle)
        if effective_weather != :None
          weather_damages = [:Sandstorm]
          if !defined?(Settings::HAIL_WEATHER_TYPE) || Settings::HAIL_WEATHER_TYPE == 0
            weather_damages << :Hail
          end
          if weather_damages.include?(effective_weather)
            weather_hurts = case effective_weather
                            when :Sandstorm
                              !target.pbHasType?(:ROCK) && !target.pbHasType?(:GROUND) && !target.pbHasType?(:STEEL)
                            when :Hail
                              !target.pbHasType?(:ICE)
                            else false
                            end
            if weather_hurts
              score += 20  # Weather will break sash
            end
          end
        end

        score
      end

      def self.evaluate_weakness_policy_abuse(battle, attacker, move, target = nil, skill_level = 100)
        return 0 unless skill_level >= 80
        return 0 unless battle.pbSideSize(0) > 1

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner
        return 0 unless partner.item_id == :WEAKNESSPOLICY

        score = 0

        if DoublesCoordination.hits_partner?(move, attacker, partner, target)
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
          type_mod = Effectiveness.calculate(resolved_type, *partner.pbTypes(true))

          if Effectiveness.super_effective?(type_mod)
            eff_power = AdvancedAI::CombatUtilities.resolve_move_power(move)
            if eff_power <= 40
              score += 80  # Weak move triggers WP without killing
            elsif eff_power <= 60
              score += 50
            else
              score -= 20  # Too strong, might KO
            end
          end
        end

        if move.id == :BEATUP && partner.hasActiveAbility?(:JUSTIFIED) && partner.item_id == :WEAKNESSPOLICY
          if target && target.index == partner.index
            score += 100  # +4 Attack and +2 Attack/SpAtk!
          end
        end

        score
      end

      def self.check_safety_goggles(battle, attacker, target, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless target
        return 0 unless target.item_id == :SAFETYGOGGLES

        score = 0

        powder_moves = [:SPORE, :SLEEPPOWDER, :STUNSPORE, :POISONPOWDER, :RAGEPOWDER,
                        :POWDER, :COTTONSPORE]

        if powder_moves.include?(move.id)
          score -= 80  # Move will fail
        end

        score
      end

      def self.check_assault_vest_target(battle, target, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless target
        return 0 unless target.item_id == :ASSAULTVEST

        # Target can't use status moves - less Protect, less setup
        30  # Bonus - opponent is limited
      end

      def self.check_choice_item(battle, attacker, target, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless target

        choice_items = [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]
        return 0 unless choice_items.include?(target.item_id)

        score = 0

        if target.lastMoveUsed
          score += 25  # We know what they're locked into

          last_move = GameData::Move.try_get(target.lastMoveUsed)
          if last_move
            resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, last_move)
            type_mod = Effectiveness.calculate(resolved_type, *attacker.pbTypes(true))
            if Effectiveness.not_very_effective?(type_mod) || Effectiveness.ineffective?(type_mod)
              score += 35  # They're locked into bad move vs us
            end
          end
        end

        score
      end

      def self.check_ejection_items(battle, target, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless target

        if target.item_id == :EJECTBUTTON
          return -15
        elsif target.item_id == :REDCARD
          return -25
        end

        0
      end

      def self.check_air_balloon(battle, target, move, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless target
        return 0 unless target.item_id == :AIRBALLOON

        if move.type == :GROUND
          return -80
        end

        if move.damagingMove?
          return 15  # Pop their balloon
        end

        0
      end

      def self.check_stat_trigger_items(battle, attacker, partner, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless partner

        score = 0

        if partner.item_id == :ROOMSERVICE
          if battle.field.effects[PBEffects::TrickRoom] > 0
            score += 30  # Partner got speed drop for TR
          end
        end

        if partner.item_id == :ADRENALINEORB
          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          if opponents.any? { |o| o.hasActiveAbility?(:INTIMIDATE) }
            score += 25
          end
        end

        score
      end

      def self.check_healing_berries(battle, target, skill_level = 100)
        return 0 unless skill_level >= 60
        return 0 unless target

        healing_berries = [:SITRUSBERRY, :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY,
                          :MAGOBERRY, :WIKIBERRY, :ORANBERRY]

        return 0 unless healing_berries.include?(target.item_id)

        if target.hp > target.totalhp * 0.5
          return 15  # Try to burst through the heal threshold
        else
          return -10  # They'll heal, might not KO
        end
      end

      def self.check_covert_cloak(battle, target, move, skill_level = 100)
        return 0 unless AdvancedAI::GEN9_PACK_COMPAT
        return 0 unless skill_level >= 65
        return 0 unless target
        return 0 unless target.item_id == :COVERTCLOAK
        if move.power > 0 && move.addlEffect.to_i > 0
          return -25
        end
        0
      end

      def self.check_clear_amulet(battle, target, move, skill_level = 100)
        return 0 unless AdvancedAI::GEN9_PACK_COMPAT
        return 0 unless skill_level >= 65
        return 0 unless target
        return 0 unless target.item_id == :CLEARAMULET
        stat_drop_status = [:CHARM, :FEATHERDANCE, :GROWL, :SCREECH, :TAILWHIP,
                            :FAKETEARS, :METALSOUND, :CAPTIVATE, :TEARFULLOOK]
        return -60 if move.power == 0 && stat_drop_status.include?(move.id)
        0
      end

      def self.check_mirror_herb(battle, attacker, target, move, skill_level = 100)
        return 0 unless AdvancedAI::GEN9_PACK_COMPAT
        return 0 unless skill_level >= 75
        return 0 unless target
        return 0 unless target.item_id == :MIRRORHERB
        return -50 if AdvancedAI.setup_move?(move.id)
        0
      end

      def self.check_loaded_dice(battle, attacker, move, skill_level = 100)
        return 0 unless AdvancedAI::GEN9_PACK_COMPAT
        return 0 unless skill_level >= 60
        return 0 unless attacker.item_id == :LOADEDDICE
        return 0 unless move.multiHitMove?
        score = 30
        score += 20 if attacker.hasActiveAbility?(:SKILLLINK)
        score
      end

      def self.check_booster_energy(battle, attacker, skill_level = 100)
        return 0 unless AdvancedAI::GEN9_PACK_COMPAT
        return 0 unless skill_level >= 70
        return 0 unless attacker.item_id == :BOOSTERENERGY
        return 0 unless attacker.hasActiveAbility?(:PROTOSYNTHESIS) || attacker.hasActiveAbility?(:QUARKDRIVE)
        weather = AdvancedAI::Utilities.current_weather(battle) rescue :None
        terrain = battle.field.terrain rescue nil
        return 20 if attacker.hasActiveAbility?(:PROTOSYNTHESIS) && ![:Sun, :HarshSun].include?(weather)
        return 20 if attacker.hasActiveAbility?(:QUARKDRIVE) && terrain != :Electric
        0
      end

      def self.check_ability_shield(battle, target, move, skill_level = 100)
        return 0 unless AdvancedAI::GEN9_PACK_COMPAT
        return 0 unless skill_level >= 65
        return 0 unless target
        return 0 unless target.item_id == :ABILITYSHIELD
        ability_change_moves = [:SKILLSWAP, :ENTRAINMENT, :ROLEPLAY, :GASTROACID,
                                :WORRYSEED, :SIMPLEBEAM]
        return -80 if ability_change_moves.include?(move.id)
        0
      end
    end

    module AbilitySynergyDoubles
      def self.check_intimidate(battle, attacker, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)

        if attacker.hasActiveAbility?(:INTIMIDATE)
          opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
          phys_attackers = opponents.count { |o| o.attack > o.spatk }
          score += phys_attackers * 15

          punishing_abilities = [:DEFIANT, :COMPETITIVE, :CONTRARY, :MIRRORARMOR]
          if opponents.any? { |o| punishing_abilities.any? { |a| o.hasActiveAbility?(a) } }
            score -= 40
          end
        end

        if partner
          if partner.hasActiveAbility?(:DEFIANT) || partner.hasActiveAbility?(:COMPETITIVE)
            opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
            if opponents.any? { |o| o.hasActiveAbility?(:INTIMIDATE) }
              score += 35
            end
          end
        end

        score
      end

      def self.check_prankster(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless attacker.hasActiveAbility?(:PRANKSTER)
        return 0 unless move.category == 2  # Status move

        score = 0

        score += 20

        if target && AdvancedAI::Utilities.prankster_blocked?(attacker, target, move)
          score -= 80  # Move fails
        end

        score
      end

      def self.check_flinch_immunity(battle, target, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless target

        flinch_immune = [:INNERFOCUS, :SHIELDDUST]

        if flinch_immune.any? { |a| target.hasActiveAbility?(a) }
          if move.id == :FAKEOUT || move.function_code.to_s.include?("Flinch")
            return -50  # Flinch won't work
          end
        end

        0
      end

      def self.check_friend_guard(battle, attacker, target, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless target
        return 0 unless battle.pbSideSize(0) > 1

        partner = DoublesCoordination.find_partner(battle, target)
        return 0 unless partner

        if partner.hasActiveAbility?(:FRIENDGUARD)
          return -15  # 25% damage reduction
        end

        0
      end

      def self.check_telepathy(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 65
        return 0 unless battle.pbSideSize(0) > 1

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        if partner.hasActiveAbility?(:TELEPATHY)
          if DoublesCoordination.hits_partner?(move, attacker, partner)
            return 40  # Partner won't be hit
          end
        end

        0
      end

      # Neutralizing Gas awareness
      def self.check_neutralizing_gas(battle, attacker, skill_level = 100)
        return 0 unless skill_level >= 75

        # Check if anyone has Neutralizing Gas active
        all_battlers = battle.allBattlers
        if all_battlers.any? { |b| b && !b.fainted? && b.hasActiveAbility?(:NEUTRALIZINGGAS) }
          return 20  # Simplifies calculations
        end

        0
      end

      def self.evaluate_ability_manipulation(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 80
        return 0 unless [:SKILLSWAP, :ENTRAINMENT, :ROLEPLAY, :GASTROACID].include?(move.id)
        return 0 unless target

        score = 0

        case move.id
        when :SKILLSWAP
          good_abilities = [:HUGEPOWER, :PUREPOWER, :SPEEDBOOST, :INTIMIDATE,
                           :MULTISCALE, :MAGICGUARD, :LEVITATE, :PRANKSTER]
          if good_abilities.any? { |a| target.hasActiveAbility?(a) }
            score += 50
          end

          bad_abilities = [:SLOWSTART, :TRUANT, :DEFEATIST, :STALL]
          if bad_abilities.any? { |a| attacker.hasActiveAbility?(a) }
            score += 60  # Give them our bad ability
          end

        when :ENTRAINMENT
          bad_for_them = [:TRUANT, :SLOWSTART, :DEFEATIST]
          if bad_for_them.any? { |a| attacker.hasActiveAbility?(a) }
            score += 70
          end

        when :GASTROACID
          strong_abilities = [:HUGEPOWER, :INTIMIDATE, :LEVITATE, :MULTISCALE,
                             :MAGICGUARD, :WONDERGUARD]
          if strong_abilities.any? { |a| target.hasActiveAbility?(a) }
            score += 55
          end
        end

        score
      end

      def self.check_slow_start(battle, attacker, target, skill_level = 100)
        return 0 unless skill_level >= 65

        if target && target.hasActiveAbility?(:SLOWSTART)
          return 25  # Take advantage
        end

        if attacker.hasActiveAbility?(:SLOWSTART)
          return -20
        end

        0
      end

      def self.check_power_spot(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move && move.damagingMove?

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner && !partner.fainted?

        if partner.hasActiveAbility?(:POWERSPOT)
          return 25
        end

        0
      end

      def self.check_battery(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move && move.specialMove?

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner && !partner.fainted?

        if partner.hasActiveAbility?(:BATTERY)
          return 25
        end

        0
      end

      def self.check_steely_spirit(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move && move.damagingMove? && move.type == :STEEL

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner && !partner.fainted?

        if partner.hasActiveAbility?(:STEELYSPIRIT)
          return 40
        end

        if attacker.hasActiveAbility?(:STEELYSPIRIT)
          return 10
        end

        0
      end

      def self.check_flower_gift(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1

        weather = AdvancedAI::Utilities.current_weather(battle)
        return 0 unless [:Sun, :HarshSun].include?(weather)

        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner && !partner.fainted?

        score = 0

        if partner.hasActiveAbility?(:FLOWERGIFT)
          if move && move.physicalMove?
            score += 35  # 50% Attack boost
          end
          score += 15
        end

        if attacker.hasActiveAbility?(:FLOWERGIFT)
          score += 10
        end

        score
      end

      def self.check_ally_boosting_abilities(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1

        score = 0
        score += check_power_spot(battle, attacker, move, skill_level)
        score += check_battery(battle, attacker, move, skill_level)
        score += check_steely_spirit(battle, attacker, move, skill_level)
        score += check_flower_gift(battle, attacker, move, skill_level)

        score
      end
    end

    module VGCMetaStrategies
      def self.evaluate_perish_trap(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 80
        return 0 unless move.id == :PERISHSONG

        score = 0

        partner = DoublesCoordination.find_partner(battle, attacker)
        trapping_moves = [:MEANLOOK, :BLOCK, :SPIDERWEB, :SPIRITSHACKLE, :ANCHORSHOT, :JAWLOCK, :THOUSANDWAVES, :OCTOLOCK]
        trapping_abilities = [:SHADOWTAG, :ARENATRAP, :MAGNETPULL]

        has_trapping = false
        if partner
          has_trapping = partner.moves.any? { |m| m && trapping_moves.include?(m.id) }
          has_trapping ||= trapping_abilities.any? { |a| partner.hasActiveAbility?(a) }
        end
        has_trapping ||= attacker.moves.any? { |m| m && trapping_moves.include?(m.id) }
        has_trapping ||= trapping_abilities.any? { |a| attacker.hasActiveAbility?(a) }

        if has_trapping
          score += 60
        else
          score -= 20  # Opponents can just switch out
        end

        own_party = battle.pbParty(attacker.index & 1)
        fainted_own = own_party.count { |p| p && p.fainted? }

        opp_party = battle.pbParty(1 - (attacker.index & 1))
        fainted_opp = opp_party.count { |p| p && p.fainted? }

        if fainted_own < fainted_opp
          score += 40  # We have more reserves
        end

        score
      end

      def self.evaluate_taunt_doubles(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 70
        return 0 unless battle.pbSideSize(0) > 1
        return 0 unless move.id == :TAUNT
        return 0 unless target

        score = 0

        usable_status = target.moves.each_with_index.filter_map do |candidate, i|
          candidate if candidate && candidate.statusMove? &&
                       battle.pbCanChooseMove?(target.index, i, false)
        end
        status_moves = usable_status.length

        if status_moves >= 3
          score += 60  # Target relies on status moves
        elsif status_moves >= 2
          score += 40
        elsif status_moves >= 1
          score += 20
        else
          score -= 30  # Pure attacker, Taunt does little
        end

        priority_taunt = [:TRICKROOM, :TAILWIND, :PROTECT, :FOLLOWME, :RAGEPOWDER,
                         :SPORE, :WILLOWISP, :THUNDERWAVE]
        if usable_status.any? { |candidate| priority_taunt.include?(candidate.id) }
          score += 35
        end

        if target.item_id == :MENTALHERB
          score -= 25
        end

        if attacker.hasActiveAbility?(:PRANKSTER)
          score += 25
        end

        score
      end

      def self.evaluate_encore_doubles(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless move.id == :ENCORE
        return 0 unless target

        score = 0

        if target.lastRegularMoveUsed
          last_move = GameData::Move.try_get(target.lastRegularMoveUsed)
          if last_move
            bad_to_encore = [:PROTECT, :DETECT, :SPLASH, :HELPINGHAND]
            if bad_to_encore.include?(target.lastRegularMoveUsed)
              score += 70  # Locked into useless move
            end

            if last_move.power > 0
              resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(target, last_move)
              type_mod = Effectiveness.calculate(resolved_type, *attacker.pbTypes(true))
              if Effectiveness.not_very_effective?(type_mod)
                score += 40
              elsif Effectiveness.ineffective?(type_mod)
                score += 60
              end
            end
          end
        end

        score
      end

      def self.evaluate_imprison(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 80
        return 0 unless move.id == :IMPRISON

        score = 0

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        our_moves = attacker.moves.map { |m| m&.id }.compact

        key_moves = [:PROTECT, :TRICKROOM, :TAILWIND, :FAKEOUT, :SPORE]

        opponents.each do |opp|
          opp.moves.each do |opp_move|
            next unless opp_move
            if our_moves.include?(opp_move.id) && key_moves.include?(opp_move.id)
              score += 30
            end
          end
        end

        score
      end

      def self.evaluate_soak(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless move.id == :SOAK
        return 0 unless target

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)

        if partner
          grass_elec = partner.moves.any? do |m|
            next false unless m && m.damagingMove?
            [:GRASS, :ELECTRIC].include?(AdvancedAI::CombatUtilities.resolve_move_type(partner, m))
          end
          if grass_elec
            score += 50  # Make target weak to partner's moves
          end
        end

        if target.pbHasType?(:GROUND)
          score += 35  # Remove Ground immunity to Electric
        end
        if target.pbHasType?(:GHOST)
          score += 30  # Remove Ghost immunities
        end

        score
      end

      def self.evaluate_ally_switch_prediction(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 85
        return 0 unless move.id == :ALLYSWITCH
        return 0 unless battle.pbSideSize(0) > 1

        score = 0
        partner = DoublesCoordination.find_partner(battle, attacker)
        return 0 unless partner

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        partner_in_danger = false
        we_resist = false

        opponents.each do |opp|
          opp.moves.each do |opp_move|
            next unless opp_move && opp_move.damagingMove?

            resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(opp, opp_move)
            partner_mod = Effectiveness.calculate(resolved_type, *partner.pbTypes(true))
            our_mod = Effectiveness.calculate(resolved_type, *attacker.pbTypes(true))

            if Effectiveness.super_effective?(partner_mod)
              partner_in_danger = true
              if Effectiveness.not_very_effective?(our_mod) || Effectiveness.ineffective?(our_mod)
                we_resist = true
              end
            end
          end
        end

        if partner_in_danger && we_resist
          score += 55
        elsif partner_in_danger
          score += 25
        end

        if skill_level >= 90 && rand(100) < 30
          score += 20  # Sometimes do it anyway
        end

        score
      end

      def self.evaluate_gravity(battle, attacker, move, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless move.id == :GRAVITY

        score = 0

        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }
        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        ground_users = allies.count { |a| a.moves.any? { |m| m && m.type == :GROUND && m.damagingMove? } }

        flying_opponents = opponents.count do |o|
          o.pbHasType?(:FLYING) || o.hasActiveAbility?(:LEVITATE) || o.item_id == :AIRBALLOON
        end

        score += ground_users * 25
        score += flying_opponents * 30

        low_accuracy_moves = allies.count do |a|
          a.moves.any? { |m| m && m.damagingMove? && m.accuracy > 0 && m.accuracy < 80 }
        end
        score += low_accuracy_moves * 15

        score
      end

      def self.evaluate_stat_split(battle, attacker, move, target, skill_level = 100)
        return 0 unless skill_level >= 75
        return 0 unless [:GUARDSPLIT, :POWERSPLIT].include?(move.id)
        return 0 unless target

        score = 0

        case move.id
        when :GUARDSPLIT
          our_def = attacker.defense + attacker.spdef
          their_def = target.defense + target.spdef

          if their_def > our_def * 1.5
            score += 45  # We gain bulk, they lose it
          end

        when :POWERSPLIT
          our_off = attacker.attack + attacker.spatk
          their_off = target.attack + target.spatk

          if their_off > our_off * 1.5
            score += 50  # Neuters their offense
          end
        end

        score
      end
    end

    module SwitchInAwareness
      def self.predict_intimidate_switch(battle, attacker, skill_level = 100)
        return 0 unless skill_level >= 70

        opponents = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        if opponents.any? { |o| o.hasActiveAbility?(:INTIMIDATE) }
          if attacker.stages[:ATTACK] < 0
            return -15  # We're already debuffed
          end
        end

        0
      end

      def self.predict_weather_switch(battle, attacker, skill_level = 100)
        return 0 unless skill_level >= 70

        # Score the current weather; reserve abilities are not exposed here.
        current_weather = AdvancedAI::Utilities.current_weather(battle)

        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        weather_synergy = {
          :Sun => [:CHLOROPHYLL, :SOLARPOWER, :FLOWERGIFT, :LEAFGUARD, :HARVEST, :PROTOSYNTHESIS],
          :Rain => [:SWIFTSWIM, :RAINDISH, :DRYSKIN, :HYDRATION],
          :Sandstorm => [:SANDRUSH, :SANDFORCE, :SANDVEIL],
          :Hail => [:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :ICEFACE],
          :Snow => [:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :ICEFACE]
        }

        synergy_abilities = weather_synergy[current_weather] || []
        if allies.any? { |a| synergy_abilities.any? { |ab| a.hasActiveAbility?(ab) } }
          return 25  # We benefit from current weather
        end

        0
      end

      def self.predict_terrain_switch(battle, attacker, skill_level = 100)
        return 0 unless skill_level >= 70

        terrain_setters = {
          :Electric => [:ELECTRICSURGE, :HADRONENGINE],
          :Grassy => [:GRASSYSURGE],
          :Psychic => [:PSYCHICSURGE],
          :Misty => [:MISTYSURGE]
        }

        current_terrain = battle.field.terrain

        allies = battle.allSameSideBattlers(attacker.index).select { |b| b && !b.fainted? }

        our_setter = false
        terrain_setters.each do |terrain, abilities|
          if current_terrain == terrain
            if allies.any? { |a| abilities.any? { |ab| a.hasActiveAbility?(ab) } }
              our_setter = true
              break
            end
          end
        end

        our_setter ? 20 : 0
      end
    end

    def self.find_partner(battle, attacker)
      battle.allSameSideBattlers(attacker.index).find { |b| b && b.index != attacker.index && !b.fainted? }
    end

    def self.partner_planned_move_id(battle, partner)
      return nil unless partner
      begin
        choice = battle.choices[partner.index] rescue nil
        if choice && choice[0] == :UseMove && choice[2]
          return choice[2].id rescue nil
        end
      rescue
      end
      nil
    end

    REDIRECT_MOVE_IDS  = [:FOLLOWME, :RAGEPOWDER, :SPOTLIGHT]
    PROTECT_MOVE_IDS   = [:PROTECT, :DETECT, :KINGSSHIELD, :SPIKYSHIELD,
                          :BANEFULBUNKER, :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK]
    SUPPORT_ONLY_MOVES = REDIRECT_MOVE_IDS + PROTECT_MOVE_IDS + [:HELPINGHAND]

    def self.partner_planned_support_only?(battle, partner)
      mid = partner_planned_move_id(battle, partner)
      return false unless mid
      SUPPORT_ONLY_MOVES.include?(mid)
    end

    def self.partner_targets?(battle, partner, target)
      return false unless partner && target
      begin
        partner_choice = battle.choices[partner.index] rescue nil
        if partner_choice && partner_choice[0] == :UseMove
          partner_target_idx = partner_choice[3]  # Target index
          return partner_target_idx == target.index if partner_target_idx
        end
      rescue
      end

      if target.hp < target.totalhp * 0.35
        return true  # Low HP target is a likely shared target
      end

      false
    end

    def self.hits_partner?(move, attacker, partner, selected_target = nil)
      real_attacker = attacker.respond_to?(:battler) ? attacker.battler : attacker
      battle = real_attacker.battle
      target_data = move.pbTarget(real_attacker)
      can_target = battle.pbMoveCanTarget?(real_attacker.index, partner.index, target_data)
      return false unless can_target
      return true if target_data.num_targets > 1
      if selected_target
        return selected_target.index == partner.index
      end
      false
    rescue
      false
    end

    def self.count_enemies_hit(battle, attacker, move)
      real_attacker = attacker.respond_to?(:battler) ? attacker.battler : attacker
      target_data = move.pbTarget(real_attacker) rescue nil
      return 0 unless target_data
      battle.allOtherSideBattlers(attacker.index).count do |battler|
        battler && !battler.fainted? &&
          battle.pbMoveCanTarget?(real_attacker.index, battler.index, target_data)
      end
    rescue
      0
    end
  end
end

module AdvancedAI
  def self.prevent_overkill(battle, attacker, target, skill_level = 100)
    DoublesCoordination.prevent_overkill(battle, attacker, target, skill_level)
  end

  def self.prevent_move_conflicts(battle, attacker, move, skill_level = 100)
    DoublesCoordination.prevent_move_conflicts(battle, attacker, move, skill_level)
  end

  def self.optimize_spread_moves(battle, attacker, move, skill_level = 100)
    DoublesCoordination.optimize_spread_moves(battle, attacker, move, skill_level)
  end

  def self.coordinate_field_effects(battle, attacker, move, skill_level = 100)
    DoublesCoordination.coordinate_field_effects(battle, attacker, move, skill_level)
  end

  def self.protect_setup_combo(battle, attacker, move, skill_level = 100)
    DoublesCoordination.protect_setup_combo(battle, attacker, move, skill_level)
  end

  def self.evaluate_wide_guard(battle, attacker, move, skill_level = 100)
    DoublesCoordination::ProtectiveMovesDoubles.evaluate_wide_guard(battle, attacker, move, skill_level)
  end

  def self.evaluate_quick_guard(battle, attacker, move, skill_level = 100)
    DoublesCoordination::ProtectiveMovesDoubles.evaluate_quick_guard(battle, attacker, move, skill_level)
  end

  def self.evaluate_follow_me(battle, attacker, move, skill_level = 100)
    DoublesCoordination::RedirectionStrategies.evaluate_follow_me(battle, attacker, move, skill_level)
  end

  def self.evaluate_rage_powder(battle, attacker, move, skill_level = 100)
    DoublesCoordination::RedirectionStrategies.evaluate_rage_powder(battle, attacker, move, skill_level)
  end

  def self.evaluate_fake_out(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination.evaluate_fake_out(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_protect_doubles(battle, attacker, move, skill_level = 100)
    DoublesCoordination.evaluate_protect_doubles(battle, attacker, move, skill_level)
  end

  def self.evaluate_tailwind(battle, attacker, move, skill_level = 100)
    DoublesCoordination::SpeedControlDoubles.evaluate_tailwind(battle, attacker, move, skill_level)
  end

  def self.evaluate_trick_room(battle, attacker, move, skill_level = 100)
    DoublesCoordination::SpeedControlDoubles.evaluate_trick_room(battle, attacker, move, skill_level)
  end

  def self.evaluate_speed_control_attack(battle, attacker, move, skill_level = 100)
    DoublesCoordination::SpeedControlDoubles.evaluate_speed_control_attack(battle, attacker, move, skill_level)
  end

  def self.evaluate_weather_move_doubles(battle, attacker, move, skill_level = 100)
    DoublesCoordination::WeatherCoordinationDoubles.evaluate_weather_move(battle, attacker, move, skill_level)
  end

  def self.evaluate_weather_boosted_move(battle, attacker, move, skill_level = 100)
    DoublesCoordination::WeatherCoordinationDoubles.evaluate_weather_boosted_move(battle, attacker, move, skill_level)
  end

  def self.evaluate_helping_hand(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AllySynergyDoubles.evaluate_helping_hand(battle, attacker, move, skill_level)
  end

  def self.evaluate_coaching(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AllySynergyDoubles.evaluate_coaching(battle, attacker, move, skill_level)
  end

  def self.evaluate_ally_heal(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AllySynergyDoubles.evaluate_ally_heal(battle, attacker, move, skill_level)
  end

  def self.evaluate_ally_switch(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AllySynergyDoubles.evaluate_ally_switch(battle, attacker, move, skill_level)
  end

  def self.check_combo_potential(battle, attacker, move)
    DoublesCoordination::ComboCoordinationDoubles.check_combo_potential(battle, attacker, move)
  end

  def self.evaluate_setup_for_partner(battle, attacker, move, skill_level = 100)
    DoublesCoordination::ComboCoordinationDoubles.evaluate_setup_for_partner(battle, attacker, move, skill_level)
  end

  def self.evaluate_after_you(battle, attacker, move, skill_level = 100)
    DoublesCoordination::TurnOrderDoubles.evaluate_after_you(battle, attacker, move, skill_level)
  end

  def self.evaluate_quash(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::TurnOrderDoubles.evaluate_quash(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_instruct(battle, attacker, move, skill_level = 100)
    DoublesCoordination::TurnOrderDoubles.evaluate_instruct(battle, attacker, move, skill_level)
  end

  def self.evaluate_mat_block(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AdditionalProtectionDoubles.evaluate_mat_block(battle, attacker, move, skill_level)
  end

  def self.evaluate_crafty_shield(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AdditionalProtectionDoubles.evaluate_crafty_shield(battle, attacker, move, skill_level)
  end

  def self.evaluate_spotlight(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::AdditionalProtectionDoubles.evaluate_spotlight(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_revival_blessing(battle, attacker, move, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9DoublesStrategies.evaluate_revival_blessing(battle, attacker, move, skill_level)
  end

  def self.evaluate_shed_tail(battle, attacker, move, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9DoublesStrategies.evaluate_shed_tail(battle, attacker, move, skill_level)
  end

  def self.evaluate_doodle(battle, attacker, move, target, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9DoublesStrategies.evaluate_doodle(battle, attacker, move, target, skill_level)
  end

  def self.check_commander_combo(battle, attacker)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9DoublesStrategies.check_commander_combo(battle, attacker)
  end

  def self.evaluate_tidy_up(battle, attacker, move, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9DoublesStrategies.evaluate_tidy_up(battle, attacker, move, skill_level)
  end

  def self.evaluate_psychic_terrain_doubles(battle, attacker, move, skill_level = 100)
    DoublesCoordination::Gen9DoublesStrategies.evaluate_psychic_terrain_doubles(battle, attacker, move, skill_level)
  end

  def self.check_ability_synergy(battle, attacker, move, target = nil)
    DoublesCoordination::Gen9DoublesStrategies.check_ability_synergy(battle, attacker, move, target)
  end

  def self.evaluate_terrain_doubles(battle, attacker, move, skill_level = 100)
    DoublesCoordination::TerrainSynergyDoubles.evaluate_terrain_doubles(battle, attacker, move, skill_level)
  end

  def self.evaluate_max_guard(battle, attacker, move, skill_level = 100)
    DoublesCoordination::DynamaxDoublesStrategies.evaluate_max_guard(battle, attacker, move, skill_level)
  end

  def self.evaluate_max_team_move(battle, attacker, move, skill_level = 100)
    DoublesCoordination::DynamaxDoublesStrategies.evaluate_max_team_move(battle, attacker, move, skill_level)
  end

  def self.evaluate_max_weather_move(battle, attacker, move, skill_level = 100)
    DoublesCoordination::DynamaxDoublesStrategies.evaluate_max_weather_move(battle, attacker, move, skill_level)
  end

  def self.evaluate_max_terrain_move(battle, attacker, move, skill_level = 100)
    DoublesCoordination::DynamaxDoublesStrategies.evaluate_max_terrain_move(battle, attacker, move, skill_level)
  end

  def self.evaluate_dynamax_timing(battle, attacker, skill_level = 100)
    DoublesCoordination::DynamaxDoublesStrategies.evaluate_dynamax_timing(battle, attacker, skill_level)
  end

  def self.evaluate_gmax_move(battle, attacker, move, skill_level = 100)
    DoublesCoordination::DynamaxDoublesStrategies.evaluate_gmax_move(battle, attacker, move, skill_level)
  end

  def self.evaluate_tera_timing_doubles(battle, attacker, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_tera_timing_doubles(battle, attacker, skill_level)
  end

  def self.evaluate_paradox_moves(battle, attacker, move, target, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_paradox_moves(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_terrain_removal(battle, attacker, move, skill_level = 100)
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_terrain_removal(battle, attacker, move, skill_level)
  end

  def self.evaluate_court_change(battle, attacker, move, skill_level = 100)
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_court_change(battle, attacker, move, skill_level)
  end

  def self.evaluate_mortal_spin(battle, attacker, move, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_mortal_spin(battle, attacker, move, skill_level)
  end

  def self.evaluate_make_it_rain(battle, attacker, move, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_make_it_rain(battle, attacker, move, skill_level)
  end

  def self.evaluate_triple_arrows(battle, attacker, move, target, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_triple_arrows(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_stat_lowering_attacks(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_stat_lowering_attacks(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_order_up(battle, attacker, move, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_order_up(battle, attacker, move, skill_level)
  end

  def self.evaluate_salt_cure(battle, attacker, move, target, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_salt_cure(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_rage_fist(battle, attacker, move, skill_level = 100)
    return 0 unless GEN9_PACK_COMPAT
    DoublesCoordination::Gen9ExtendedStrategies.evaluate_rage_fist(battle, attacker, move, skill_level)
  end

  def self.check_focus_sash(battle, attacker, target, move, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.check_focus_sash(battle, attacker, target, move, skill_level)
  end

  def self.evaluate_weakness_policy_abuse(battle, attacker, move, target = nil, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.evaluate_weakness_policy_abuse(battle, attacker, move, target, skill_level)
  end

  def self.check_safety_goggles(battle, attacker, target, move, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.check_safety_goggles(battle, attacker, target, move, skill_level)
  end

  def self.check_assault_vest_target(battle, target, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.check_assault_vest_target(battle, target, skill_level)
  end

  def self.check_choice_item(battle, attacker, target, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.check_choice_item(battle, attacker, target, skill_level)
  end

  def self.check_ejection_items(battle, target, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.check_ejection_items(battle, target, skill_level)
  end

  def self.check_air_balloon(battle, target, move, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.check_air_balloon(battle, target, move, skill_level)
  end

  def self.check_stat_trigger_items(battle, attacker, partner, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.check_stat_trigger_items(battle, attacker, partner, skill_level)
  end

  def self.check_healing_berries(battle, target, skill_level = 100)
    DoublesCoordination::ItemAwarenessDoubles.check_healing_berries(battle, target, skill_level)
  end

  def self.check_intimidate(battle, attacker, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_intimidate(battle, attacker, skill_level)
  end

  def self.check_prankster(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_prankster(battle, attacker, move, target, skill_level)
  end

  def self.check_flinch_immunity(battle, target, move, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_flinch_immunity(battle, target, move, skill_level)
  end

  def self.check_friend_guard(battle, attacker, target, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_friend_guard(battle, attacker, target, skill_level)
  end

  def self.check_telepathy(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_telepathy(battle, attacker, move, skill_level)
  end

  def self.check_neutralizing_gas(battle, attacker, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_neutralizing_gas(battle, attacker, skill_level)
  end

  def self.evaluate_ability_manipulation(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.evaluate_ability_manipulation(battle, attacker, move, target, skill_level)
  end

  def self.check_slow_start(battle, attacker, target, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_slow_start(battle, attacker, target, skill_level)
  end

  def self.check_ally_boosting_abilities(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_ally_boosting_abilities(battle, attacker, move, skill_level)
  end

  def self.check_power_spot(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_power_spot(battle, attacker, move, skill_level)
  end

  def self.check_battery(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_battery(battle, attacker, move, skill_level)
  end

  def self.check_steely_spirit(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_steely_spirit(battle, attacker, move, skill_level)
  end

  def self.check_flower_gift(battle, attacker, move, skill_level = 100)
    DoublesCoordination::AbilitySynergyDoubles.check_flower_gift(battle, attacker, move, skill_level)
  end

  def self.evaluate_perish_trap(battle, attacker, move, skill_level = 100)
    DoublesCoordination::VGCMetaStrategies.evaluate_perish_trap(battle, attacker, move, skill_level)
  end

  def self.evaluate_taunt_doubles(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::VGCMetaStrategies.evaluate_taunt_doubles(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_encore_doubles(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::VGCMetaStrategies.evaluate_encore_doubles(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_imprison(battle, attacker, move, skill_level = 100)
    DoublesCoordination::VGCMetaStrategies.evaluate_imprison(battle, attacker, move, skill_level)
  end

  def self.evaluate_soak(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::VGCMetaStrategies.evaluate_soak(battle, attacker, move, target, skill_level)
  end

  def self.evaluate_ally_switch_prediction(battle, attacker, move, skill_level = 100)
    DoublesCoordination::VGCMetaStrategies.evaluate_ally_switch_prediction(battle, attacker, move, skill_level)
  end

  def self.evaluate_gravity(battle, attacker, move, skill_level = 100)
    DoublesCoordination::VGCMetaStrategies.evaluate_gravity(battle, attacker, move, skill_level)
  end

  def self.evaluate_stat_split(battle, attacker, move, target, skill_level = 100)
    DoublesCoordination::VGCMetaStrategies.evaluate_stat_split(battle, attacker, move, target, skill_level)
  end

  def self.predict_intimidate_switch(battle, attacker, skill_level = 100)
    DoublesCoordination::SwitchInAwareness.predict_intimidate_switch(battle, attacker, skill_level)
  end

  def self.predict_weather_switch(battle, attacker, skill_level = 100)
    DoublesCoordination::SwitchInAwareness.predict_weather_switch(battle, attacker, skill_level)
  end

  def self.predict_terrain_switch(battle, attacker, skill_level = 100)
    DoublesCoordination::SwitchInAwareness.predict_terrain_switch(battle, attacker, skill_level)
  end
end

class Battle::AI
  def apply_doubles_coordination(score, move, user, target, skill = 100)
    return score unless @battle.pbSideSize(0) > 1
    return score unless AdvancedAI.feature_enabled?(:core, skill)

    score += AdvancedAI.prevent_overkill(@battle, user, target, skill) if target
    score += AdvancedAI.prevent_move_conflicts(@battle, user, move, skill)
    score += AdvancedAI.optimize_spread_moves(@battle, user, move, skill)
    score += AdvancedAI.coordinate_field_effects(@battle, user, move, skill)
    score += AdvancedAI.protect_setup_combo(@battle, user, move, skill)

    score += AdvancedAI.evaluate_wide_guard(@battle, user, move, skill)
    score += AdvancedAI.evaluate_quick_guard(@battle, user, move, skill)

    score += AdvancedAI.evaluate_follow_me(@battle, user, move, skill) unless move.id == :RAGEPOWDER
    score += AdvancedAI.evaluate_rage_powder(@battle, user, move, skill)

    score += AdvancedAI.evaluate_fake_out(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_protect_doubles(@battle, user, move, skill)

    score += AdvancedAI.evaluate_tailwind(@battle, user, move, skill)
    score += AdvancedAI.evaluate_trick_room(@battle, user, move, skill)
    score += AdvancedAI.evaluate_speed_control_attack(@battle, user, move, skill)

    score += AdvancedAI.evaluate_weather_move_doubles(@battle, user, move, skill)
    score += AdvancedAI.evaluate_weather_boosted_move(@battle, user, move, skill)

    score += AdvancedAI.evaluate_helping_hand(@battle, user, move, skill)
    score += AdvancedAI.evaluate_coaching(@battle, user, move, skill)
    score += AdvancedAI.evaluate_ally_heal(@battle, user, move, skill)
    score += AdvancedAI.evaluate_ally_switch(@battle, user, move, skill)

    score += AdvancedAI.check_combo_potential(@battle, user, move)
    score += AdvancedAI.evaluate_setup_for_partner(@battle, user, move, skill)

    score += AdvancedAI.evaluate_after_you(@battle, user, move, skill)
    score += AdvancedAI.evaluate_quash(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_instruct(@battle, user, move, skill)

    score += AdvancedAI.evaluate_mat_block(@battle, user, move, skill)
    score += AdvancedAI.evaluate_crafty_shield(@battle, user, move, skill)
    score += AdvancedAI.evaluate_spotlight(@battle, user, move, target, skill) if target

    score += AdvancedAI.evaluate_max_guard(@battle, user, move, skill)
    score += AdvancedAI.evaluate_max_team_move(@battle, user, move, skill)
    score += AdvancedAI.evaluate_max_weather_move(@battle, user, move, skill)
    score += AdvancedAI.evaluate_max_terrain_move(@battle, user, move, skill)
    score += AdvancedAI.evaluate_gmax_move(@battle, user, move, skill)

    score += AdvancedAI.evaluate_revival_blessing(@battle, user, move, skill)
    score += AdvancedAI.evaluate_shed_tail(@battle, user, move, skill)
    score += AdvancedAI.evaluate_doodle(@battle, user, move, target, skill) if target
    score += AdvancedAI.check_commander_combo(@battle, user)
    score += AdvancedAI.evaluate_tidy_up(@battle, user, move, skill)
    score += AdvancedAI.evaluate_psychic_terrain_doubles(@battle, user, move, skill)
    score += AdvancedAI.check_ability_synergy(@battle, user, move, target)

    score += AdvancedAI.evaluate_paradox_moves(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_terrain_removal(@battle, user, move, skill)
    score += AdvancedAI.evaluate_court_change(@battle, user, move, skill)
    score += AdvancedAI.evaluate_mortal_spin(@battle, user, move, skill)
    score += AdvancedAI.evaluate_make_it_rain(@battle, user, move, skill)
    score += AdvancedAI.evaluate_triple_arrows(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_stat_lowering_attacks(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_order_up(@battle, user, move, skill)
    score += AdvancedAI.evaluate_salt_cure(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_rage_fist(@battle, user, move, skill)

    score += AdvancedAI.evaluate_terrain_doubles(@battle, user, move, skill)

    if target
      score += AdvancedAI.check_focus_sash(@battle, user, target, move, skill)
      score += AdvancedAI.check_safety_goggles(@battle, user, target, move, skill)
      score += AdvancedAI.check_assault_vest_target(@battle, target, skill)
      score += AdvancedAI.check_choice_item(@battle, user, target, skill)
      score += AdvancedAI.check_ejection_items(@battle, target, skill)
      score += AdvancedAI.check_air_balloon(@battle, target, move, skill)
      score += AdvancedAI.check_healing_berries(@battle, target, skill)
      score += AdvancedAI::DoublesCoordination::ItemAwarenessDoubles.check_covert_cloak(@battle, target, move, skill)
      score += AdvancedAI::DoublesCoordination::ItemAwarenessDoubles.check_clear_amulet(@battle, target, move, skill)
      score += AdvancedAI::DoublesCoordination::ItemAwarenessDoubles.check_mirror_herb(@battle, user, target, move, skill)
      score += AdvancedAI::DoublesCoordination::ItemAwarenessDoubles.check_ability_shield(@battle, target, move, skill)
    end
    score += AdvancedAI::DoublesCoordination::ItemAwarenessDoubles.check_loaded_dice(@battle, user, move, skill)
    score += AdvancedAI::DoublesCoordination::ItemAwarenessDoubles.check_booster_energy(@battle, user, skill)
    score += AdvancedAI.evaluate_weakness_policy_abuse(@battle, user, move, target, skill)
    partner = @battle.allSameSideBattlers(user.index).find { |b| b && b.index != user.index && !b.fainted? }
    score += AdvancedAI.check_stat_trigger_items(@battle, user, partner, skill) if partner

    score += AdvancedAI.check_intimidate(@battle, user, skill)
    score += AdvancedAI.check_prankster(@battle, user, move, target, skill) if target
    score += AdvancedAI.check_flinch_immunity(@battle, target, move, skill) if target
    score += AdvancedAI.check_friend_guard(@battle, user, target, skill) if target
    score += AdvancedAI.check_telepathy(@battle, user, move, skill)
    score += AdvancedAI.check_neutralizing_gas(@battle, user, skill)
    score += AdvancedAI.evaluate_ability_manipulation(@battle, user, move, target, skill) if target
    score += AdvancedAI.check_slow_start(@battle, user, target, skill) if target

    score += AdvancedAI.check_ally_boosting_abilities(@battle, user, move, skill)

    score += AdvancedAI.evaluate_perish_trap(@battle, user, move, skill)
    score += AdvancedAI.evaluate_taunt_doubles(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_encore_doubles(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_imprison(@battle, user, move, skill)
    score += AdvancedAI.evaluate_soak(@battle, user, move, target, skill) if target
    score += AdvancedAI.evaluate_ally_switch_prediction(@battle, user, move, skill)
    score += AdvancedAI.evaluate_gravity(@battle, user, move, skill)
    score += AdvancedAI.evaluate_stat_split(@battle, user, move, target, skill) if target

    score += AdvancedAI.predict_intimidate_switch(@battle, user, skill)
    score += AdvancedAI.predict_weather_switch(@battle, user, skill)
    score += AdvancedAI.predict_terrain_switch(@battle, user, skill)

    if target
      real_user = user.respond_to?(:battler) ? user.battler : user
      real_target = target.respond_to?(:battler) ? target.battler : target
      score += AdvancedAI::DoublesCoordination.joint_target_bonus(@battle, real_user, move, real_target, skill) rescue 0
    end

    return score
  end
end

module AdvancedAI
  module DoublesCoordination
    def self.joint_target_bonus(battle, attacker, move, target, skill_level = 100)
      return 0 unless skill_level >= 60
      return 0 unless battle.pbSideSize(0) > 1
      return 0 unless target && move

      partner = find_partner(battle, attacker)
      return 0 unless partner

      bonus = 0
      enemies = battle.allOtherSideBattlers(attacker.index).select { |b| b && !b.fainted? }
      return 0 if enemies.length < 2  # Only one target anyway

      our_damage = AdvancedAI::CombatUtilities.estimate_damage(attacker, move, target, as_percent: true) rescue 0

      partner_on_same = partner_targets?(battle, partner, target)

      if partner_on_same && our_damage >= target.hp.to_f / target.totalhp
        bonus -= 10
      end

      if partner_on_same && our_damage < 0.5
        other_targets = enemies.reject { |e| e == target }
        other_targets.each do |other|
          other_hp_pct = other.hp.to_f / other.totalhp
          if other_hp_pct < 0.4
            bonus -= 15  # Other target is low, pick them off instead
            break
          end
        end
      end

      if move.damagingMove?
        target_types = target.respond_to?(:pbTypes) ? target.pbTypes(true) : [:NORMAL]
        resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
        eff = Effectiveness.calculate(resolved_type, *target_types)
        if Effectiveness.super_effective?(eff)
          bonus += 10  # We have SE on this target
        end
      end

      bonus
    end
  end
end

AdvancedAI.log("Doubles Coordination System loaded", "Doubles")
AdvancedAI.log("  - Wide Guard & Quick Guard strategies", "Doubles")
AdvancedAI.log("  - Follow Me / Rage Powder redirection", "Doubles")
AdvancedAI.log("  - Fake Out & Protect coordination", "Doubles")
AdvancedAI.log("  - Tailwind & Trick Room speed control", "Doubles")
AdvancedAI.log("  - Enhanced weather coordination", "Doubles")
AdvancedAI.log("  - Ally synergy moves (Helping Hand, Coaching)", "Doubles")
AdvancedAI.log("  - Combo detection (Beat Up + Justified, etc.)", "Doubles")
AdvancedAI.log("  - Turn order manipulation (After You, Quash, Instruct)", "Doubles")
AdvancedAI.log("  - Additional protection (Mat Block, Crafty Shield)", "Doubles")
AdvancedAI.log("  - Gen 8 Dynamax coordination (Max Airstream, G-Max moves)", "Doubles")
AdvancedAI.log("  - Gen 9 strategies (Revival Blessing, Shed Tail, Doodle)", "Doubles")
AdvancedAI.log("  - Commander combo (Tatsugiri + Dondozo)", "Doubles")
AdvancedAI.log("  - Gen 9 extended (Salt Cure, Rage Fist, Court Change)", "Doubles")
AdvancedAI.log("  - Terastallization & Paradox Pokemon moves", "Doubles")
AdvancedAI.log("  - Terrain synergy (Rising Voltage, Expanding Force, etc.)", "Doubles")
AdvancedAI.log("  - Item awareness (Focus Sash, Weakness Policy, Choice items)", "Doubles")
AdvancedAI.log("  - Ability synergy (Intimidate, Prankster, Telepathy)", "Doubles")
AdvancedAI.log("  - Ally-boosting abilities (Power Spot, Battery, Steely Spirit, Flower Gift)", "Doubles")
AdvancedAI.log("  - VGC Meta strategies (Perish Trap, Taunt, Encore, Imprison)", "Doubles")
AdvancedAI.log("  - Switch-In awareness (Intimidate, Weather, Terrain)", "Doubles")
AdvancedAI.log("  - Spread move 75% damage reduction awareness", "Doubles")
AdvancedAI.log("  - #8 Intimidate cycling switch bonus", "Doubles")
AdvancedAI.log("  - #20 Ally Switch awareness + TR setter coordination", "Doubles")

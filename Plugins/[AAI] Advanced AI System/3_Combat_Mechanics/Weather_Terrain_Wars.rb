# Advanced AI System - Weather & Terrain Wars

class Battle::AI

  alias_method :weather_wars_pbRegisterMove, :pbRegisterMove unless method_defined?(:weather_wars_pbRegisterMove) || private_method_defined?(:weather_wars_pbRegisterMove)
  def pbRegisterMove(user, move)
    score = weather_wars_pbRegisterMove(user, move)

    return score unless user && move

    if move_sets_weather?(move)
      score += evaluate_weather_setting(user, move)
    end

    if move_sets_terrain?(move)
      score += evaluate_terrain_setting(user, move)
    end

    return score
  end

  def move_sets_weather?(move)
    weather_moves = {
      :SUNNYDAY    => :Sun,
      :RAINDANCE   => :Rain,
      :SANDSTORM   => :Sandstorm,
      :HAIL        => :Hail,
      :SNOWSCAPE   => :Snow,
      :CHILLYRECEPTION => :Snow,  # Gen 9: sets Snow + switches
    }
    return weather_moves.key?(move.id)
  end

  def evaluate_weather_setting(user, move)
    score = 0

    weather_map = {
      :SUNNYDAY  => :Sun,
      :RAINDANCE => :Rain,
      :SANDSTORM => :Sandstorm,
      :HAIL      => :Hail,
      :SNOWSCAPE => :Snow,
      :CHILLYRECEPTION => :Snow,  # Gen 9: sets Snow + switches
    }

    new_weather = weather_map[move.id]
    current_weather = AdvancedAI::Utilities.current_weather(@battle)

    if [:HarshSun, :HeavyRain, :StrongWinds].include?(current_weather)
      AdvancedAI.log("  #{move.name}: -100 (fails under extreme weather)", "Weather")
      return -100
    end

    # Don't set weather that's already active
    if current_weather == new_weather
      AdvancedAI.log("  #{move.name}: -80 (already active)", "Weather")
      return -80
    end

    if weather_benefits_opponent?(current_weather, user)
      score += 50
      AdvancedAI.log("  #{move.name}: +50 (counter opponent weather)", "Weather")
    end

    our_benefit = calculate_weather_benefit(user, new_weather)
    if our_benefit > 0
      score += our_benefit
      AdvancedAI.log("  #{move.name}: +#{our_benefit} (benefits us)", "Weather")
    elsif our_benefit < 0
      score += our_benefit  # Penalty
      AdvancedAI.log("  #{move.name}: #{our_benefit} (hurts us!)", "Weather")
    end

    opponent_penalty = calculate_opponent_weather_penalty(new_weather, user)
    if opponent_penalty != 0
      score += opponent_penalty
      if opponent_penalty > 0
        AdvancedAI.log("  #{move.name}: +#{opponent_penalty} (hurts opponent)", "Weather")
      else
        AdvancedAI.log("  #{move.name}: #{opponent_penalty} (benefits opponent!)", "Weather")
      end
    end

    if weather_activates_ability?(user, new_weather)
      score += 40
      AdvancedAI.log("  #{move.name}: +40 (activates ability)", "Weather")
    end

    return score
  end

  def weather_benefits_opponent?(weather, user = nil)
    return false if weather == :None

    opp_side = user ? @battle.allOtherSideBattlers(user.index) :
                      @battle.allSameSideBattlers(0)
    opp_side.each do |battler|
      next unless battler && !battler.fainted?

      weather_abilities = {
        :Sun       => [:SOLARPOWER, :CHLOROPHYLL, :FLOWERGIFT, :LEAFGUARD, :HARVEST, :PROTOSYNTHESIS],
        :Rain      => [:SWIFTSWIM, :RAINDISH, :DRYSKIN, :HYDRATION],
        :Sandstorm => [:SANDFORCE, :SANDRUSH, :SANDVEIL],
        :Hail      => [:ICEBODY, :SNOWCLOAK, :SLUSHRUSH, :ICEFACE],
        :Snow      => [:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :ICEFACE],
      }

      if weather_abilities[weather]&.any? { |a| battler.hasActiveAbility?(a) }
        return true
      end

      battler.moves.each do |m|
        next unless m

        case weather
        when :Sun
          return true if [:FIRE].include?(m.type)
        when :Rain
          return true if [:WATER].include?(m.type)
        when :Sandstorm
          return true if battler.pbTypes(true).any? { |t| [:ROCK, :GROUND, :STEEL].include?(t) }
        end
      end
    end

    return false
  end

  def calculate_weather_benefit(user, weather)
    benefit = 0

    case weather
    when :Sun
      fire_moves = user.moves.count { |m| m && m.type == :FIRE }
      water_moves = user.moves.count { |m| m && m.type == :WATER }

      benefit += fire_moves * 20
      benefit -= water_moves * 15

      if user.hasActiveAbility?(:CHLOROPHYLL) || user.hasActiveAbility?(:SOLARPOWER) || user.hasActiveAbility?(:FLOWERGIFT) ||
         user.hasActiveAbility?(:LEAFGUARD) || user.hasActiveAbility?(:HARVEST) || user.hasActiveAbility?(:PROTOSYNTHESIS)
        benefit += 30
      end

    when :Rain
      water_moves = user.moves.count { |m| m && m.type == :WATER }
      fire_moves = user.moves.count { |m| m && m.type == :FIRE }

      benefit += water_moves * 20
      benefit -= fire_moves * 15

      if user.hasActiveAbility?(:SWIFTSWIM) || user.hasActiveAbility?(:RAINDISH) || user.hasActiveAbility?(:DRYSKIN) ||
         user.hasActiveAbility?(:HYDRATION)
        benefit += 30
      end

    when :Sandstorm
      if user.pbTypes(true).include?(:ROCK)
        benefit += 25
      end

      if user.hasActiveAbility?(:SANDRUSH) || user.hasActiveAbility?(:SANDFORCE) || user.hasActiveAbility?(:SANDVEIL)
        benefit += 30
      end

      unless user.pbTypes(true).any? { |t| [:ROCK, :GROUND, :STEEL].include?(t) }
        benefit -= 10  # Hurts us
      end

    when :Hail
      if defined?(Settings::HAIL_WEATHER_TYPE) && Settings::HAIL_WEATHER_TYPE > 0 &&
         user.pbTypes(true).include?(:ICE)
        benefit += 25
      end

      if user.hasActiveAbility?(:SLUSHRUSH)
        benefit += 30
      end
      if user.hasActiveAbility?(:ICEBODY)
        benefit += 15
      end
      if user.hasActiveAbility?(:SNOWCLOAK)
        benefit += 20
      end
      if user.hasActiveAbility?(:ICEFACE)
        benefit += 20  # Ice Face regenerates in Hail
      end

      if (!defined?(Settings::HAIL_WEATHER_TYPE) || Settings::HAIL_WEATHER_TYPE == 0) &&
         !user.pbTypes(true).include?(:ICE)
        benefit -= 10
      end

    when :Snow
      if user.pbTypes(true).include?(:ICE)
        benefit += 30  # Defense boost
      end

      if user.hasActiveAbility?(:SLUSHRUSH)
        benefit += 35
      end

      if user.hasActiveAbility?(:ICEBODY)
        benefit += 15
      end
      if user.hasActiveAbility?(:SNOWCLOAK)
        benefit += 20
      end
      if user.hasActiveAbility?(:ICEFACE)
        benefit += 20  # Ice Face regenerates in Snow
      end
    end

    return benefit
  end

  def calculate_opponent_weather_penalty(weather, user = nil)
    penalty = 0

    opp_side = user ? @battle.allOtherSideBattlers(user.index) :
                      @battle.allSameSideBattlers(0)
    opp_side.each do |battler|
      next unless battler && !battler.fainted?

      case weather
      when :Sun
        water_moves = battler.moves.count { |m| m && m.type == :WATER }
        penalty += water_moves * 10

      when :Rain
        fire_moves = battler.moves.count { |m| m && m.type == :FIRE }
        penalty += fire_moves * 10

      when :Sandstorm
        unless battler.pbTypes(true).any? { |t| [:ROCK, :GROUND, :STEEL].include?(t) }
          penalty += 15
        end

      when :Hail
        if !defined?(Settings::HAIL_WEATHER_TYPE) || Settings::HAIL_WEATHER_TYPE == 0
          unless battler.pbTypes(true).include?(:ICE)
            penalty += 15
          end
        end

      when :Snow
        if battler.pbTypes(true).include?(:ICE)
          penalty -= 10  # Negative penalty (benefit to them), reduce our score
        end
      end
    end

    return penalty
  end

  def weather_activates_ability?(user, weather)
    activations = {
      :Sun       => [:CHLOROPHYLL, :SOLARPOWER, :FLOWERGIFT, :LEAFGUARD, :HARVEST, :PROTOSYNTHESIS],
      :Rain      => [:SWIFTSWIM, :RAINDISH, :DRYSKIN, :HYDRATION],
      :Sandstorm => [:SANDRUSH, :SANDFORCE, :SANDVEIL],
      :Hail      => [:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :ICEFACE],
      :Snow      => [:SLUSHRUSH, :ICEBODY, :SNOWCLOAK, :ICEFACE],
    }

    return activations[weather]&.any? { |a| user.hasActiveAbility?(a) } || false
  end

  def move_sets_terrain?(move)
    terrain_moves = {
      :ELECTRICTERRAIN => :Electric,
      :GRASSYTERRAIN   => :Grassy,
      :MISTYTERRAIN    => :Misty,
      :PSYCHICTERRAIN  => :Psychic,
    }
    return terrain_moves.key?(move.id)
  end

  def evaluate_terrain_setting(user, move)
    score = 0

    terrain_map = {
      :ELECTRICTERRAIN => :Electric,
      :GRASSYTERRAIN   => :Grassy,
      :MISTYTERRAIN    => :Misty,
      :PSYCHICTERRAIN  => :Psychic,
    }

    new_terrain = terrain_map[move.id]
    current_terrain = @battle.field.terrain

    # Don't set terrain that's already active
    if current_terrain == new_terrain
      AdvancedAI.log("  #{move.name}: -80 (already active)", "Terrain")
      return -80
    end

    if terrain_benefits_opponent?(current_terrain, user)
      score += 45
      AdvancedAI.log("  #{move.name}: +45 (counter opponent terrain)", "Terrain")
    end

    case new_terrain
    when :Electric
      electric_moves = user.moves.count { |m| m && m.type == :ELECTRIC }
      score += electric_moves * 25

      score += 15

    when :Grassy
      grass_moves = user.moves.count { |m| m && m.type == :GRASS }
      score += grass_moves * 20

      score += 20

    when :Misty
      dragon_moves_opponent = 0
      @battle.allOtherSideBattlers(user.index).each do |opp|
        next unless opp
        dragon_moves_opponent += opp.moves.count { |m| m && m.type == :DRAGON }
      end
      score += dragon_moves_opponent * 25

      score += 20

    when :Psychic
      psychic_moves = user.moves.count { |m| m && m.type == :PSYCHIC }
      score += psychic_moves * 25

      score += 30  # Very valuable
    end

    if terrain_activates_ability?(user, new_terrain)
      score += 35
      AdvancedAI.log("  #{move.name}: +35 (activates ability)", "Terrain")
    end

    return score
  end

  def terrain_benefits_opponent?(terrain, user = nil)
    return false if terrain == :None

    opp_side = user ? @battle.allOtherSideBattlers(user.index) :
                      @battle.allSameSideBattlers(0)
    opp_side.each do |battler|
      next unless battler && !battler.fainted?

      case terrain
      when :Electric
        return true if battler.hasActiveAbility?(:SURGESURFER) || battler.hasActiveAbility?(:QUARKDRIVE) || battler.hasActiveAbility?(:HADRONENGINE)
        return true if battler.moves.any? { |m| m && m.type == :ELECTRIC }
      when :Grassy
        return true if battler.hasActiveAbility?(:GRASSPELT)
        return true if battler.moves.any? { |m| m && m.type == :GRASS }
      when :Psychic
        return true if battler.moves.any? { |m| m && m.type == :PSYCHIC }
      when :Misty
        # Misty Terrain halves Dragon damage and prevents status — it hurts
        # Dragon users rather than helping them, so it does NOT benefit the
        # opponent if they have Dragon moves. No positive benefit check here.
      end
    end

    return false
  end

  def terrain_activates_ability?(user, terrain)
    activations = {
      :Electric => [:SURGESURFER, :QUARKDRIVE, :HADRONENGINE],
      :Grassy   => [:GRASSPELT],
      :Psychic  => [],  # No specific ability activations
      :Misty    => [],
    }

    return activations[terrain]&.any? { |a| user.hasActiveAbility?(a) } || false
  end
end

AdvancedAI.log("Weather & Terrain Wars loaded", "Core")
AdvancedAI.log("  - Counter-weather strategy", "Weather")
AdvancedAI.log("  - Counter-terrain strategy", "Terrain")
AdvancedAI.log("  - Ability synergy detection", "Weather")

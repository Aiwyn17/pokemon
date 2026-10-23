# [015] Item Intelligence - 693+ Item Analysis
# Intelligent Item Recognition and Usage
# Categories:
# - Choice Items (Choice Band, Choice Specs, Choice Scarf)
# - Life Orb & Damage Boost Items
# - Assault Vest & Defensive Items
# - Recovery Items (Leftovers, Black Sludge, etc.)
# - Type-Boosting Items (Charcoal, Mystic Water, etc.)
# - Status Items (Flame Orb, Toxic Orb, etc.)
# - Terrain/Weather Extenders
# - Z-Crystals & Mega Stones (DBK Integration)

module AdvancedAI
  module ItemIntelligence

    CHOICE_ITEMS = {
      :CHOICEBAND   => { stat: :attack, multiplier: 1.5 },
      :CHOICESPECS  => { stat: :spatk, multiplier: 1.5 },
      :CHOICESCARF  => { stat: :speed, multiplier: 1.5 },
    }

    DAMAGE_BOOST_ITEMS = {
      :LIFEORB      => { multiplier: 1.3, recoil: 0.1 },

      :EXPERTBELT   => { multiplier: 1.2, condition: :super_effective },

      :MUSCLEBAND   => { multiplier: 1.1, category: :physical },
      :WISEGLASSES  => { multiplier: 1.1, category: :special },

      :METRONOME    => { multiplier: 1.2, stacks: true, max: 2.0 },

      :PUNCHINGGLOVE => { multiplier: 1.1, moves: :punching, no_contact: true },

      :LOADEDDICE   => { multihit: true, min: 4 },
    }

    TYPE_BOOST_ITEMS = {
      :CHARCOAL       => :FIRE,
      :MYSTICWATER    => :WATER,
      :MIRACLESEED    => :GRASS,
      :MAGNET         => :ELECTRIC,
      :NEVERMELTICE   => :ICE,
      :BLACKBELT      => :FIGHTING,
      :POISONBARB     => :POISON,
      :SOFTSAND       => :GROUND,
      :SHARPBEAK      => :FLYING,
      :TWISTEDSPOON   => :PSYCHIC,
      :SILVERPOWDER   => :BUG,
      :HARDSTONE      => :ROCK,
      :SPELLTAG       => :GHOST,
      :DRAGONFANG     => :DRAGON,
      :BLACKGLASSES   => :DARK,
      :METALCOAT      => :STEEL,
      :SILKSCARF      => :NORMAL,
      :PIXIEPLATE     => :FAIRY,
    }

    PLATE_ITEMS = [
      :FLAMEPLATE, :SPLASHPLATE, :MEADOWPLATE, :ZAPPLATE,
      :ICICLEPLATE, :FISTPLATE, :TOXICPLATE, :EARTHPLATE,
      :SKYPLATE, :MINDPLATE, :INSECTPLATE, :STONEPLATE,
      :SPOOKYPLATE, :DRACOPLATE, :DREADPLATE, :IRONPLATE,
      :PIXIEPLATE,
    ]

    MEMORY_ITEMS = [
      :FIREMEMORY, :WATERMEMORY, :GRASSMEMORY, :ELECTRICMEMORY,
      :ICEMEMORY, :FIGHTINGMEMORY, :POISONMEMORY, :GROUNDMEMORY,
      :FLYINGMEMORY, :PSYCHICMEMORY, :BUGMEMORY, :ROCKMEMORY,
      :GHOSTMEMORY, :DRAGONMEMORY, :DARKMEMORY, :STEELMEMORY,
      :FAIRYMEMORY,
    ]

    DEFENSIVE_ITEMS = {
      :ASSAULTVEST  => { stat: :spdef, multiplier: 1.5, no_status: true },

      :EVIOLITE     => { stat: :both, multiplier: 1.5, nfe_only: true },

      :ROCKYHELMET  => { recoil: 0.167, contact: true },

      :FOCUSSASH    => { survive: true, full_hp: true },

      :FOCUSBAND    => { survive: true, chance: 0.1 },

      :WEAKNESSPOLICY => { trigger: :super_effective, boost: 2 },

      :AIRBALLOON   => { immunity: :GROUND, until_hit: true },

      :HEAVYDUTYBOOTS => { hazard_immunity: true },

      :ABILITYSHIELD => { ability_protection: true },

      :SHEDSHELL    => { trap_escape: true },
    }

    RECOVERY_ITEMS = {
      :LEFTOVERS    => { heal: 0.0625, per_turn: true },
      :BLACKSLUDGE  => { heal: 0.0625, per_turn: true, poison_only: true },
      :SHELLBELL    => { heal: 0.125, on_damage: true },
      :SITRUSBERRY  => { heal: 0.25, trigger: :low_hp },
      :ORANBERRY    => { heal: 10, trigger: :low_hp },
    }

    STATUS_ORBS = {
      :FLAMEORB     => { status: :burn, turn: 1 },
      :TOXICORB     => { status: :toxic, turn: 1 },
    }

    EXTENDER_ITEMS = {
      :HEATROCK     => { weather: :sun, turns: 3 },
      :DAMPROCK     => { weather: :rain, turns: 3 },
      :SMOOTHROCK   => { weather: :sandstorm, turns: 3 },
      :ICYROCK      => { weather: :snow, turns: 3 },
      :TERRAINEXTENDER => { terrain: :any, turns: 3 },
    }

    def self.choice_item?(item_id)
      return false if !item_id
      item_id = item_id.to_sym if item_id.is_a?(String)
      return CHOICE_ITEMS.key?(item_id)
    end

    def self.damage_boost_item?(item_id)
      return false if !item_id
      item_id = item_id.to_sym if item_id.is_a?(String)
      return DAMAGE_BOOST_ITEMS.key?(item_id)
    end

    def self.type_boost_item?(item_id)
      return false if !item_id
      item_id = item_id.to_sym if item_id.is_a?(String)
      return TYPE_BOOST_ITEMS.key?(item_id) || PLATE_ITEMS.include?(item_id) || MEMORY_ITEMS.include?(item_id)
    end

    def self.defensive_item?(item_id)
      return false if !item_id
      item_id = item_id.to_sym if item_id.is_a?(String)
      return DEFENSIVE_ITEMS.key?(item_id)
    end

    def self.recovery_item?(item_id)
      return false if !item_id
      item_id = item_id.to_sym if item_id.is_a?(String)
      return RECOVERY_ITEMS.key?(item_id)
    end

    def self.calculate_item_multiplier(battler, move)
      return 1.0 if !battler || !move
      item = battler.item_id
      return 1.0 if !item

      multiplier = 1.0

      if CHOICE_ITEMS.key?(item)
        data = CHOICE_ITEMS[item]
        if (data[:stat] == :attack && move.physicalMove?) ||
           (data[:stat] == :spatk && move.specialMove?)
          multiplier *= data[:multiplier]
        end
      end

      if item == :LIFEORB
        multiplier *= 1.3
      end

      if item == :EXPERTBELT
      end

      if TYPE_BOOST_ITEMS.key?(item)
        resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(battler, move)
        multiplier *= 1.2 if resolved_type == TYPE_BOOST_ITEMS[item]
      end

      if item == :MUSCLEBAND && move.physicalMove?
        multiplier *= 1.1
      elsif item == :WISEGLASSES && move.specialMove?
        multiplier *= 1.1
      end

      if item == :LIGHTBALL
        species = battler.respond_to?(:species) ? battler.species : nil
        if species == :PIKACHU || species == :PIKACHUORIGINAL ||
           species == :PIKACHUHOENN || species == :PIKACHUSINNOH ||
           species == :PIKACHUUNOVA || species == :PIKACHUKALOS ||
           species == :PIKACHUALOLA || species == :PIKACHUPARTNER ||
           species == :PIKACHUCOSPLAY
          multiplier *= 2.0  # Doubles both Atk and SpAtk
        end
      end

      if item == :THICKCLUB && move.physicalMove?
        species = battler.respond_to?(:species) ? battler.species : nil
        if [:CUBONE, :MAROWAK, :MAROWAKALOLA].include?(species)
          multiplier *= 2.0  # Doubles Attack stat
        end
      end

      return multiplier
    end

    def self.choice_locked?(battler)
      return false if !battler
      return false if !battler.item_id
      return false if !choice_item?(battler.item_id)
      return false unless battler.respond_to?(:effects)

      return battler.effects[PBEffects::ChoiceBand] if defined?(PBEffects::ChoiceBand)
      return false
    end

    def self.blocks_status_moves?(battler)
      return false if !battler
      if battler.respond_to?(:hasActiveItem?)
        return battler.hasActiveItem?(:ASSAULTVEST)
      end
      return battler.item_id == :ASSAULTVEST
    end

    def self.get_item_threat_modifier(battler)
      return 0.0 if !battler
      item = battler.item_id
      return 0.0 if !item

      modifier = 0.0

      modifier += 1.0 if choice_item?(item)

      modifier += 0.8 if item == :LIFEORB

      modifier -= 0.5 if item == :ASSAULTVEST

      modifier += 0.5 if item == :WEAKNESSPOLICY

      modifier -= 0.3 if item == :FOCUSSASH

      modifier -= 0.2 if item == :HEAVYDUTYBOOTS

      modifier -= 0.3 if item == :ABILITYSHIELD

      modifier += 0.8 if item == :LIGHTBALL

      modifier += 0.8 if item == :THICKCLUB

      modifier -= 0.2 if item == :SHEDSHELL

      return modifier
    end

    def self.recommend_item_for_role(pokemon, role)
      return nil if !pokemon || !role

      case role
      when :sweeper
        if pokemon.speed >= 100
          return :CHOICESCARF  # Outspeed everything
        elsif pokemon.attack >= pokemon.spatk
          return :CHOICEBAND   # Physical sweeper
        else
          return :CHOICESPECS  # Special sweeper
        end

      when :wall
        return :LEFTOVERS

      when :tank
        return :ASSAULTVEST

      when :support
        return :LIGHTCLAY

      when :wallbreaker
        return :LIFEORB

      when :pivot
        return :HEAVYDUTYBOOTS

      when :lead
        return :FOCUSSASH
      end

      return nil
    end

    def self.has_utility_umbrella?(battler)
      return false unless battler
      item = battler.respond_to?(:item_id) ? battler.item_id : nil
      item == :UTILITYUMBRELLA
    end

    TYPE_GEMS = {
      :NORMALGEM   => :NORMAL,   :FIREGEM    => :FIRE,    :WATERGEM   => :WATER,
      :ELECTRICGEM => :ELECTRIC, :GRASSGEM   => :GRASS,   :ICEGEM     => :ICE,
      :FIGHTINGGEM => :FIGHTING, :POISONGEM  => :POISON,  :GROUNDGEM  => :GROUND,
      :FLYINGGEM   => :FLYING,   :PSYCHICGEM => :PSYCHIC, :BUGGEM     => :BUG,
      :ROCKGEM     => :ROCK,     :GHOSTGEM   => :GHOST,   :DRAGONGEM  => :DRAGON,
      :DARKGEM     => :DARK,     :STEELGEM   => :STEEL,   :FAIRYGEM   => :FAIRY,
    }

    def self.has_type_gem?(battler, move_type = nil)
      return false unless battler
      item = battler.respond_to?(:item_id) ? battler.item_id : nil
      return false unless item && TYPE_GEMS.key?(item)
      return true unless move_type
      TYPE_GEMS[item] == move_type
    end

    def self.has_sticky_barb?(battler)
      return false unless battler
      item = battler.respond_to?(:item_id) ? battler.item_id : nil
      item == :STICKYBARB
    end

    def self.has_mental_herb?(battler)
      return false unless battler
      item = battler.respond_to?(:item_id) ? battler.item_id : nil
      item == :MENTALHERB
    end

    def self.has_ability_shield?(battler)
      return false unless battler
      item = battler.respond_to?(:item_id) ? battler.item_id : nil
      item == :ABILITYSHIELD
    end

    def self.has_shed_shell?(battler)
      return false unless battler
      item = battler.respond_to?(:item_id) ? battler.item_id : nil
      item == :SHEDSHELL
    end

    def self.extends_weather?(battler, weather_type = nil)
      return false unless battler
      item = battler.respond_to?(:item_id) ? battler.item_id : nil
      return false unless item && EXTENDER_ITEMS.key?(item)
      return true unless weather_type
      ext = EXTENDER_ITEMS[item]
      ext[:weather].to_s.downcase == weather_type.to_s.downcase
    end

    def self.gem_damage_bonus(battler, move)
      return 0 unless battler && move && move.damagingMove?
      resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(battler, move)
      return 0 unless has_type_gem?(battler, resolved_type)
      15
    end

    def self.mental_herb_penalty(target, move)
      return 0 unless target && move
      return 0 unless [:TAUNT, :ENCORE, :DISABLE, :TORMENT].include?(move.id)
      return 0 unless has_mental_herb?(target)
      -25  # They'll cure it immediately
    end

    def self.utility_umbrella_penalty(target, move)
      return 0 unless target && move
      return 0 unless has_utility_umbrella?(target)
      weather_boosted = [:THUNDER, :HURRICANE, :SOLARBEAM, :SOLARBLADE, :WEATHERBALL, :BLIZZARD]
      return -20 if weather_boosted.include?(move.id)
      0
    end

  end
end

module AdvancedAI
  def self.choice_item?(item_id)
    ItemIntelligence.choice_item?(item_id)
  end

  def self.choice_locked?(battler)
    ItemIntelligence.choice_locked?(battler)
  end

  def self.blocks_status_moves?(battler)
    ItemIntelligence.blocks_status_moves?(battler)
  end

  def self.calculate_item_multiplier(battler, move)
    ItemIntelligence.calculate_item_multiplier(battler, move)
  end

  def self.get_item_threat_modifier(battler)
    ItemIntelligence.get_item_threat_modifier(battler)
  end

  def self.recommend_item_for_role(pokemon, role)
    ItemIntelligence.recommend_item_for_role(pokemon, role)
  end

  def self.has_utility_umbrella?(battler)
    ItemIntelligence.has_utility_umbrella?(battler)
  end

  def self.has_type_gem?(battler, move_type = nil)
    ItemIntelligence.has_type_gem?(battler, move_type)
  end

  def self.has_sticky_barb?(battler)
    ItemIntelligence.has_sticky_barb?(battler)
  end

  def self.has_mental_herb?(battler)
    ItemIntelligence.has_mental_herb?(battler)
  end

  def self.has_ability_shield?(battler)
    ItemIntelligence.has_ability_shield?(battler)
  end

  def self.has_shed_shell?(battler)
    ItemIntelligence.has_shed_shell?(battler)
  end

  def self.gem_damage_bonus(battler, move)
    ItemIntelligence.gem_damage_bonus(battler, move)
  end

  def self.mental_herb_penalty(target, move)
    ItemIntelligence.mental_herb_penalty(target, move)
  end

  def self.utility_umbrella_penalty(target, move)
    ItemIntelligence.utility_umbrella_penalty(target, move)
  end
end

class Battle::AI
  def apply_item_intelligence(score, move, user, target)
    return score unless move && user

    if move.damagingMove?
      real_user = user.respond_to?(:battler) ? user.battler : user
      multiplier = AdvancedAI.calculate_item_multiplier(real_user, move)
      if multiplier > 1.0
        bonus = ((multiplier - 1.0) * 50).to_i
        score += bonus
      end
    end

    if target
      real_user = user.respond_to?(:battler) ? user.battler : user
      if AdvancedAI.choice_locked?(real_user)
        last = real_user.lastMoveUsed rescue nil
        if last && move.id != last
          score -= 100  # Can't use this move while choice-locked
        end
      end

      real_target = target.respond_to?(:battler) ? target.battler : target
      if move.statusMove? && AdvancedAI.blocks_status_moves?(real_user)
        score -= 200  # Assault Vest completely prevents status moves — they WILL fail
      end
    end

    real_user = user.respond_to?(:battler) ? user.battler : user

    score += AdvancedAI.gem_damage_bonus(real_user, move)

    if target
      real_target = target.respond_to?(:battler) ? target.battler : target

      score += AdvancedAI.utility_umbrella_penalty(real_target, move)

      score += AdvancedAI.mental_herb_penalty(real_target, move)

      if move.respond_to?(:contactMove?) && move.contactMove? && AdvancedAI.has_sticky_barb?(real_target)
        score -= 10  # Risk inheriting Sticky Barb
      end
    end

    if move.respond_to?(:id)
      weather_moves = {
        :RAINDANCE  => "rain",  :SUNNYDAY    => "sun",
        :SANDSTORM  => "sandstorm",  :HAIL    => "snow",
        :SNOWSCAPE  => "snow",
        :CHILLYRECEPTION => "snow",  # Gen 9: sets Snow + switches
      }
      wtype = weather_moves[move.id]
      if wtype && AdvancedAI::ItemIntelligence.extends_weather?(real_user, wtype)
        score += 10  # 8 turns instead of 5 is significant
      end
    end

    user_item = real_user.respond_to?(:item_id) ? real_user.item_id : nil
    charge_moves = [:SOLARBEAM, :SOLARBLADE, :METEORBEAM, :PHANTOMFORCE,
                    :SHADOWFORCE, :SKULLBASH, :SKYATTACK, :FLY, :DIG, :DIVE,
                    :BOUNCE, :GEOMANCY, :FREEZESHOCK, :ICEBURN, :RAZORWIND, :ELECTROSHOT]
    if user_item == :POWERHERB && charge_moves.include?(move.id)
      bonus = 35
      bonus += 15 if move.id == :METEORBEAM  # Also raises SpAtk
      bonus += 25 if move.id == :GEOMANCY    # +1 SpAtk/SpDef/Speed
      score += bonus
    end

    if target
      real_target = target.respond_to?(:battler) ? target.battler : target
      target_item = real_target.respond_to?(:item_id) ? real_target.item_id : nil
      if target_item == :ABILITYSHIELD
        ability_change_moves = [:GASTROACID, :WORRYSEED, :SIMPLEBEAM, :ENTRAINMENT,
                                :SKILLSWAP, :ROLEPLAY, :DOODLE, :CORROSIVEGAS]
        if ability_change_moves.include?(move.id)
          score -= 40  # Move will fail against Ability Shield
          AdvancedAI.log("#{move.name} blocked by Ability Shield", "Item") rescue nil
        end
        if move.respond_to?(:contactMove?) && move.contactMove?
          if real_target.respond_to?(:hasActiveAbility?) &&
             [:MUMMY, :LINGERINGAROMA, :WANDERINGSPIRIT].any? { |a| real_target.hasActiveAbility?(a) }
          end
        end
      end
      if user_item == :ABILITYSHIELD
        critical_abilities = [:HUGEPOWER, :PUREPOWER, :SPEEDBOOST, :MAGICGUARD,
                              :WONDERGUARD, :PROTEAN, :LIBERO, :UNBURDEN, :POISONHEAL]
        if real_user.respond_to?(:hasActiveAbility?) && critical_abilities.any? { |a| real_user.hasActiveAbility?(a) }
          score += 5 if move.damagingMove?
        end
      end
    end

    stat_drop_moves = [:SHELLSMASH, :CLOSECOMBAT, :SUPERPOWER, :OVERHEAT,
                       :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST,
                       :VCREATE, :HEADLONGRUSH, :ARMORCANNON, :DRAGONASCENT,
                       :HAMMERARM, :ICEHAMMER, :CLANGINGSCALES, :HYPERSPACEFURY,
                       :MAKEITRAIN, :SPINOUT]
    if user_item == :WHITEHERB && stat_drop_moves.include?(move.id)
      bonus = move.id == :SHELLSMASH ? 35 : 15
      score += bonus
    end

    if user_item == :BOOSTERENERGY &&
       real_user.respond_to?(:hasActiveAbility?) &&
       [:PROTOSYNTHESIS, :QUARKDRIVE].any? { |a| real_user.hasActiveAbility?(a) }
      if move.damagingMove?
        atk = real_user.respond_to?(:attack) ? real_user.attack : 0
        spa = real_user.respond_to?(:spatk) ? real_user.spatk : 0
        if atk > spa
          score += 10 if move.physicalMove?
        else
          score += 10 if move.specialMove?
        end
      end
    end

    return score
  end
end

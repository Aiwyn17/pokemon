# Advanced AI System - Doubles/VGC Optimizations

module AdvancedAI
  module DoublesStrategy

    SPREAD_MOVES = [
      :EARTHQUAKE, :SURF, :DISCHARGE, :LAVAPLUME, :ROCKSLIDE,
      :BLIZZARD, :HEATWAVE, :SLUDGEWAVE, :DAZZLINGGLEAM, :MUDDYWATER,
      :RAZORLEAF, :ICYWIND, :BULLDOZE, :PARABOLICCHARGE, :GMAXCANNONADE,
      :BOOMBURST, :RELICSONG, :PETALBLIZZARD, :EXPLOSION, :SELFDESTRUCT,
      :MAGNITUDE, :GLACIATE, :ORIGINPULSE, :PRECIPICEBLADES, :ERUPTION,
      :WATERSPOUT, :SNARL, :STRUGGLE, :HYPERVOICE, :DIAMONDSTORM,
      :SPRINGTIDESTORM, :BLEAKWINDSTORM, :WILDBOLTSTORM, :SANDSEARSTORM,
      :MAKEITRAIN, :MATCHAGOTCHA, :MORTALSPIN
    ]

    SPREAD_DAMAGE_MULTIPLIER = 0.75

    REDIRECTION_MOVES = {
      :FOLLOWME => { priority: 2, duration: 1 },
      :RAGEPOWDER => { priority: 2, duration: 1 },
      :SPOTLIGHT => { priority: 3, duration: 1 }
    }

    REDIRECTION_ABILITIES = [:LIGHTNINGROD, :STORMDRAIN]

    HELPING_HAND_BOOST = 1.5

    def self.adjust_damage_for_doubles(base_damage, move, battle)
      return base_damage unless battle.pbSideSize(0) > 1  # Only in doubles

      if SPREAD_MOVES.include?(move.id)
        base_damage *= SPREAD_DAMAGE_MULTIPLIER
      end

      return base_damage
    end

    def self.has_active_redirection?(battle, side_index)
      return false unless battle.pbSideSize(0) > 1

      battle.allSameSideBattlers(side_index).each do |battler|
        next if battler.fainted?

        return true if battler.effects[PBEffects::FollowMe] > 0

        return true if battler.effects[PBEffects::Spotlight] > 0

        if battler.respond_to?(:hasActiveAbility?) && REDIRECTION_ABILITIES.any? { |a| battler.hasActiveAbility?(a) }
          return true
        end
      end

      return false
    end

    def self.score_redirection_move(user, move, battle, skill_level = 100)
      return 0 unless skill_level >= 70
      return 0 unless battle.pbSideSize(0) > 1
      return 0 unless REDIRECTION_MOVES.key?(move.id)

      score = 0

      partner = user.allAllies.first
      return 0 unless partner && !partner.fainted?

      partner_hp_percent = AdvancedAI::CombatUtilities.hp_percent(partner)
      score += AdvancedAI::CombatUtilities.hp_threshold_score(
        partner_hp_percent,
        AdvancedAI::CombatUtilities::PARTNER_HP_CONCERN
      )
      score += 15  # Base value for setup/support

      if partner.effects[PBEffects::FocusEnergy] > 0 ||
         partner.stages[:ATTACK] > 0 || partner.stages[:SPECIAL_ATTACK] > 0
        score += 40  # Protect setup sweeper
      end

      # Penalty if user is frail (can't take hits)
      user_hp_percent = AdvancedAI::CombatUtilities.hp_percent(user)
      if user_hp_percent < 0.33
        score -= 60  # Can't redirect if we'll die
      elsif user_hp_percent < 0.50
        score -= 30
      end

      partner_move = DoublesCoordination.partner_planned_move_id(battle, partner) rescue nil
      if partner_move
        if partner_move == :HELPINGHAND
          score -= 200  # Redirect + Helping Hand = zero offense
        end
        if DoublesCoordination::PROTECT_MOVE_IDS.include?(partner_move)
          score -= 100  # Partner protected — doesn't need redirect cover
        end
      end

      return score
    end

    def self.score_helping_hand(user, target, battle, skill_level = 100)
      return 0 unless skill_level >= 75
      return 0 unless battle.pbSideSize(0) > 1

      score = 0

      return 0 if target.index == user.index
      return 0 unless user.allAllies.include?(target)

      partner_move = DoublesCoordination.partner_planned_move_id(battle, target) rescue nil
      if partner_move
        if DoublesCoordination::REDIRECT_MOVE_IDS.include?(partner_move)
          return -200  # Redirect + Helping Hand = zero offense turn
        end
        if DoublesCoordination::PROTECT_MOVE_IDS.include?(partner_move)
          return -150  # Protect + Helping Hand = wasted
        end
      end

      partner_has_strong_move = target.moves.any? do |m|
        m.damagingMove? && m.power && AdvancedAI::CombatUtilities.resolve_move_power(m) >= 80
      end

      if partner_has_strong_move
        score += 60  # Boost strong attack

        score += 40
      else
        score += 20  # Generic bonus
      end

      user_can_ko = user.moves.any? do |m|
        m.damagingMove? && m.power && AdvancedAI::CombatUtilities.resolve_move_power(m) >= 100
      end

      if user_can_ko
        score -= 40  # Maybe better to attack yourself
      end

      return score
    end

    def self.score_fake_out_doubles(user, target, battle, skill_level = 100)
      return 0 unless skill_level >= 60
      return 0 unless battle.pbSideSize(0) > 1
      return 0 if user.turnCount > 0  # Only first turn after entering battle

      score = 0

      score += 80  # High base value - flinch + free turn for partner

      partner = user.allAllies.first
      if partner && !partner.fainted?
        partner_has_setup = partner.moves.any? do |m|
          [:TAILWIND, :TRICKROOM, :REFLECT, :LIGHTSCREEN, :AURORAVEIL,
           :SWORDSDANCE, :NASTYPLOT, :DRAGONDANCE, :SHELLSMASH, :QUIVERDANCE,
           :CALMMIND, :BULKUP, :VICTORYDANCE, :GEOMANCY].include?(m.id)
        end

        if partner_has_setup
          score += 60  # Free setup turn!
        end
      end

      if target.pbSpeed > user.pbSpeed
        score += 30  # Prevent opponent from moving first
      end

      if target.attack > 120 || target.spatk > 120
        score += 25  # Flinch the sweeper
      end

      return score
    end

    def self.score_protect_coordination(user, battle)
      return 0 unless battle.pbSideSize(0) > 1

      penalty = 0

      partner = user.allAllies.first
      if partner && !partner.fainted?
        # If partner used Protect last turn, don't both Protect this turn
        if partner.lastMoveUsed && [:PROTECT, :DETECT, :KINGSSHIELD, :SPIKYSHIELD,
                                      :BANEFULBUNKER, :OBSTRUCT, :SILKTRAP, :BURNINGBULWARK].include?(partner.lastMoveUsed)
          penalty += 50  # Don't both protect - wasteful
        end

      end

      return -penalty
    end

    def self.prefer_spread_move?(user, battle, skill_level = 100)
      return false unless skill_level >= 80
      return false unless battle.pbSideSize(0) > 1

      has_spread = user.moves.any? { |m| SPREAD_MOVES.include?(m.id) }
      return false unless has_spread

      opponents = user.allOpposing
      return false if opponents.length < 2

      both_low_hp = opponents.all? { |opp| opp.hp < opp.totalhp * 0.4 }
      return true if both_low_hp

      return false
    end

    def self.has_wide_guard?(side, battle)
      return false unless battle.pbSideSize(0) > 1

      return side.effects[PBEffects::WideGuard] if side.effects[PBEffects::WideGuard]

      return false
    end

    def self.has_quick_guard?(side, battle)
      return false unless battle.pbSideSize(0) > 1

      return side.effects[PBEffects::QuickGuard] if side.effects[PBEffects::QuickGuard]

      return false
    end

    def self.score_guard_penalty(user, move, target, battle)
      return 0 unless battle.pbSideSize(0) > 1

      penalty = 0
      target_side = target.pbOwnSide

      if has_wide_guard?(target_side, battle) && SPREAD_MOVES.include?(move.id)
        penalty += 200  # Move will fail!
      end

      if has_quick_guard?(target_side, battle) && move.priority > 0
        penalty += 200  # Move will fail!
      end

      return -penalty
    end

  end
end

class Battle::AI
  alias_method :doubles_strategy_pbRegisterMove, :pbRegisterMove unless method_defined?(:doubles_strategy_pbRegisterMove) || private_method_defined?(:doubles_strategy_pbRegisterMove)

  def pbRegisterMove(user, move)
    score = doubles_strategy_pbRegisterMove(user, move)

    return score unless @battle.pbSideSize(0) > 1
    return score unless user && move

    skill_level = @_resolved_skill || 100
    target = @_resolved_target || @battle.allOtherSideBattlers(user.index).find { |b| b && !b.fainted? }

    if target
      guard_penalty = AdvancedAI::DoublesStrategy.score_guard_penalty(user, move, target, @battle)
      score += guard_penalty
    end

    return score
  end
end

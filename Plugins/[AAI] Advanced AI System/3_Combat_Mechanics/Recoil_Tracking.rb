# Advanced AI System - Recoil and Self-Damage Tracking

module AdvancedAI
  module RecoilTracking

    RECOIL_MOVES = {
      :BRAVEBIRD => { type: :dealt, percent: (1.0 / 3) },
      :DOUBLEEDGE => { type: :dealt, percent: (1.0 / 3) },
      :HEADSMASH => { type: :dealt, percent: 0.50 },
      :LIGHTOFRUIN => { type: :dealt, percent: 0.50 },
      :VOLTTACKLE => { type: :dealt, percent: (1.0 / 3) },
      :WOODHAMMER => { type: :dealt, percent: (1.0 / 3) },
      :FLAREBLITZ => { type: :dealt, percent: (1.0 / 3) },
      :WAVECRASH => { type: :dealt, percent: (1.0 / 3) },
      :WILDCHARGE => { type: :dealt, percent: 0.25 },
      :HEADCHARGE => { type: :dealt, percent: 0.25 },
      :SUBMISSION => { type: :dealt, percent: 0.25 },
      :TAKEDOWN => { type: :dealt, percent: 0.25 },

      :BELLYDRUM => { type: :max_hp, percent: 0.50 },
      :FILLETAWAY => { type: :max_hp, percent: 0.50 },
      :MINDBLOWN => { type: :max_hp, percent: 0.50 },
      :STEELBEAM => { type: :max_hp, percent: 0.50 },
      :CHLOROBLAST => { type: :max_hp, percent: 0.50 },
    }

    LIFE_ORB_RECOIL = 0.10

    CONFUSION_DAMAGE_BP = 40
    CONFUSION_CHANCE = 0.33

    SUBSTITUTE_COST = 0.25

    CONTACT_DAMAGE_FRACTION = 0.125

    def self.calculate_recoil_damage(user, move, damage_dealt = nil, target = nil)
      return 0 unless user && move
      user = user.battler if user.respond_to?(:battler)
      move = move.move if move.respond_to?(:move)
      target = target.battler if target && target.respond_to?(:battler)
      struggle_cost = move.id == :STRUGGLE && damage_dealt != 0 ? [(user.totalhp / 4.0).round, 1].max : 0

      total_recoil = 0

      if RECOIL_MOVES.key?(move.id)
        recoil_data = RECOIL_MOVES[move.id]

        if recoil_data[:type] == :dealt
          unless user.hasActiveAbility?(:ROCKHEAD)
            damage = damage_dealt.nil? ? user.totalhp * 0.5 : damage_dealt
            total_recoil += [(damage * recoil_data[:percent]).round, 1].max if damage > 0
          end

        elsif recoil_data[:type] == :max_hp
          cost = user.totalhp * recoil_data[:percent]
          total_recoil += move.damagingMove? ? cost.ceil : cost.floor
        end
      end

      if move.damagingMove? && user.hasActiveItem?(:LIFEORB) && damage_dealt != 0 &&
         (!target || target.effects[PBEffects::Substitute] == 0 || move.ignoresSubstitute?(user))
        sheer_force_active = user.hasActiveAbility?(:SHEERFORCE) && move.addlEffect.to_i > 0
        unless sheer_force_active
          total_recoil += [(user.totalhp * LIFE_ORB_RECOIL).to_i, 1].max
        end
      end

      if user.hasActiveAbility?(:MAGICGUARD)
        if move.id == :BELLYDRUM || move.id == :FILLETAWAY
          total_recoil = (user.totalhp * 0.50).to_i
        else
          total_recoil = 0
        end
      end

      return total_recoil + struggle_cost
    end

    def self.score_recoil_penalty(user, move, target, damage_dealt = nil)
      return 0 unless user && move

      estimated_damage = damage_dealt
      if move.damagingMove? && target
        estimated_damage ||= self.calculate_rough_damage_for_recoil(user, move, target)
        available_hp = target.hp
        if target.effects[PBEffects::Substitute] > 0 && !move.ignoresSubstitute?(user)
          available_hp = target.effects[PBEffects::Substitute]
        end
        estimated_damage = [[estimated_damage, available_hp].min, 0].max
      end
      recoil_damage = self.calculate_recoil_damage(user, move, estimated_damage, target)
      return 0 if recoil_damage == 0

      penalty = 0
      hp_percent_lost = (recoil_damage.to_f / [user.hp, 1].max)

      if recoil_damage >= user.hp
        penalty += 500  # NEVER use move that kills self (unless it KOs opponent)
      elsif hp_percent_lost >= 0.75
        penalty += 120  # Extremely risky - 75%+ HP loss
      elsif hp_percent_lost >= 0.50
        penalty += 80   # Very risky - 50%+ HP loss
      elsif hp_percent_lost >= 0.33
        penalty += 50   # Risky - 33%+ HP loss
      elsif hp_percent_lost >= 0.20
        penalty += 30   # Moderate risk - 20%+ HP loss
      elsif hp_percent_lost >= 0.10
        penalty += 15   # Minor risk - 10%+ HP loss
      else
        penalty += 5    # Negligible risk
      end

      if move.damagingMove? && target &&
         (target.effects[PBEffects::Substitute] == 0 || move.ignoresSubstitute?(user))

        survives = target.effects[PBEffects::Endure]
        if target.hp == target.totalhp
          survives ||= target.hasActiveItem?(:FOCUSSASH)
          survives ||= target.hasActiveAbility?(:STURDY) && !AdvancedAI::Utilities.ignores_ability?(user, move, target)
        end
        if estimated_damage >= target.hp && !survives
          penalty = (penalty * 0.2).to_i  # 80% penalty reduction

          if recoil_damage >= user.hp
            battle = user.respond_to?(:battle) ? user.battle : user.instance_variable_get(:@battle)
            opposing_idx = battle ? (battle.pbOpposingIndices(user.index)[0] rescue ((user.index.even?) ? 1 : 0)) : ((user.index.even?) ? 1 : 0)
            advantage = AdvancedAI::CombatUtilities.team_advantage(
              battle, user.index, opposing_idx
            )

            case advantage
            when 1
              penalty = -30  # Small BONUS for trading when ahead
            when 0
              penalty = 10  # Tiny penalty (acceptable)
            when -1
              penalty = 40  # Moderate penalty (avoid unless necessary)
            end
          end
        end
      end

      return -penalty  # Return negative score (penalty)
    end

    def self.calculate_confusion_damage(user)
      return 0 unless user
      return 0 if user.effects[PBEffects::Confusion] <= 1

      level = user.level
      atk = user.attack
      defense = user.defense

      base_damage = ((2.0 * level / 5 + 2) * CONFUSION_DAMAGE_BP * atk / [defense, 1].max / 50 + 2)
      expected_damage = (base_damage * CONFUSION_CHANCE).to_i

      return expected_damage
    end

    def self.score_confusion_risk(user)
      return 0 unless user
      return 0 if user.effects[PBEffects::Confusion] <= 1

      confusion_damage = calculate_confusion_damage(user)
      hp_percent = (confusion_damage.to_f / [user.hp, 1].max)

      penalty = 0
      if hp_percent >= 0.50
        penalty += 60  # Huge risk - 50%+ HP from self-hit
      elsif hp_percent >= 0.33
        penalty += 40
      elsif hp_percent >= 0.20
        penalty += 25
      else
        penalty += 10
      end

      return -penalty
    end

    def self.can_afford_substitute?(user)
      return false unless user

      required_hp = [(user.totalhp * SUBSTITUTE_COST).to_i, 1].max
      return user.hp > required_hp
    end

    def self.score_substitute_cost(user)
      return 0 unless user
      return -200 unless can_afford_substitute?(user)  # Can't afford

      hp_percent = user.hp.to_f / user.totalhp

      penalty = 0
      if hp_percent < 0.40
        penalty += 80  # Very low HP - risky
      elsif hp_percent < 0.60
        penalty += 40  # Moderate HP
      else
        penalty += 10  # Healthy - minimal penalty
      end

      return -penalty
    end

    def self.calculate_rough_damage_for_recoil(user, move, target)
      AdvancedAI::CombatUtilities.estimate_damage(user, move, target)
    end

  end
end

class Battle::AI
  alias_method :recoil_tracking_pbRegisterMove, :pbRegisterMove unless method_defined?(:recoil_tracking_pbRegisterMove) || private_method_defined?(:recoil_tracking_pbRegisterMove)

  def pbRegisterMove(user, move)
    score = recoil_tracking_pbRegisterMove(user, move)

    return score unless user && move

    if AdvancedAI::RecoilTracking::RECOIL_MOVES.key?(move.id) ||
       (move.damagingMove? && user.hasActiveItem?(:LIFEORB))
      target = @_resolved_target || @battle.allOtherSideBattlers(user.index).find { |b| b && !b.fainted? }
      if target
        recoil_penalty = AdvancedAI::RecoilTracking.score_recoil_penalty(user, move, target)
        score += recoil_penalty
      end
    end

    if user.effects[PBEffects::Confusion] > 0
      confusion_penalty = AdvancedAI::RecoilTracking.score_confusion_risk(user)
      score += confusion_penalty if confusion_penalty < 0
    end

    if move.id == :SUBSTITUTE
      sub_penalty = AdvancedAI::RecoilTracking.score_substitute_cost(user)
      score += sub_penalty
    end

    return score
  end
end

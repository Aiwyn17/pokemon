#===============================================================================
# LoL Summoner Spells - Battle Hooks & Combat Resolution
#===============================================================================

class Battle::Battler
  #-----------------------------------------------------------------------------
  # Flash Dodge Hook (Guaranteed evasion against next direct move)
  #-----------------------------------------------------------------------------
  alias lol_pbSuccessCheckAgainstTarget pbSuccessCheckAgainstTarget
  def pbSuccessCheckAgainstTarget(move, user, target, targets)
    if target.lol_flash_dodge && !move.statusMove?
      target.lol_flash_dodge = false
      @battle.pbDisplay(_INTL("{1} a esquivé l'attaque grâce à Saut Éclair !", target.pbThis))
      return false
    end
    return lol_pbSuccessCheckAgainstTarget(move, user, target, targets)
  end

  #-----------------------------------------------------------------------------
  # Barrier Shield Hook (Absorbs incoming damage before HP is reduced)
  #-----------------------------------------------------------------------------
  alias lol_pbReduceHP pbReduceHP
  def pbReduceHP(amt, anim = true, registerDamage = true, anyAnim = true)
    if @lol_barrier_shield && @lol_barrier_shield > 0 && amt > 0
      absorbed = [amt, @lol_barrier_shield].min
      @lol_barrier_shield -= absorbed
      amt -= absorbed
      @battle.pbDisplay(_INTL("La Barrière de {1} absorbe {2} dégâts !", pbThis, absorbed))
      if @lol_barrier_shield <= 0
        @lol_barrier_shield = 0
        @lol_barrier_turns = 0
        @battle.pbDisplay(_INTL("La Barrière de {1} s'est brisée !", pbThis))
      end
    end
    return 0 if amt <= 0
    return lol_pbReduceHP(amt, anim, registerDamage, anyAnim)
  end

  #-----------------------------------------------------------------------------
  # Grievous Wounds Hook from Ignite (Reduces incoming healing by 50%)
  #-----------------------------------------------------------------------------
  alias lol_pbRecoverHP pbRecoverHP
  def pbRecoverHP(amt, anim = true, anyAnim = true)
    if @lol_grievous_wounds && @lol_grievous_wounds > 0 && amt > 1
      amt = (amt * 0.5).round
      amt = 1 if amt < 1 && @hp < @totalhp
      @battle.pbDisplay(_INTL("L'Hémorragie d'Embrasement réduit les soins de {1} de 50 % !", pbThis))
    end
    return lol_pbRecoverHP(amt, anim, anyAnim)
  end

  #-----------------------------------------------------------------------------
  # Exhaust Speed Reduction Hook (-30% Speed)
  #-----------------------------------------------------------------------------
  alias lol_pbSpeed pbSpeed
  def pbSpeed
    speed = lol_pbSpeed
    speed = (speed * 0.70).floor if @lol_exhaust_turns && @lol_exhaust_turns > 0
    return speed
  end
end

#-------------------------------------------------------------------------------
# Exhaust Damage Reduction Hook (-35% Damage Dealt)
#-------------------------------------------------------------------------------
class Battle::Move
  alias lol_pbCalcDamageMultipliers pbCalcDamageMultipliers
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    lol_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    if user.lol_exhaust_turns && user.lol_exhaust_turns > 0
      multipliers[:final_damage_multiplier] *= 0.65
    end
  end
end

#-------------------------------------------------------------------------------
# End of Round Phase (True Damage from Ignite & Duration Depletion)
#-------------------------------------------------------------------------------
class Battle
  alias lol_pbEndOfRoundPhase pbEndOfRoundPhase
  def pbEndOfRoundPhase
    lol_pbEndOfRoundPhase
    return if !trainerBattle?

    allBattlers.each do |b|
      next if !b || b.fainted?

      # 1. Ignite True Damage (1/8 Total HP per turn)
      if b.lol_ignite_turns > 0
        b.lol_ignite_turns -= 1
        true_dmg = [1, (b.totalhp / 8.0).floor].max
        b.pbReduceHP(true_dmg, true)
        pbDisplay(_INTL("{1} subit {2} dégâts bruts des flammes d'Embrasement !", b.pbThis, true_dmg))
        if b.fainted?
          b.pbFaint
          next
        end
        if b.lol_ignite_turns == 0
          b.lol_grievous_wounds = 0
          pbDisplay(_INTL("Les flammes d'Embrasement sur {1} se sont consumées.", b.pbThis))
        end
      end

      # 2. Barrier Duration Depletion
      if b.lol_barrier_turns > 0
        b.lol_barrier_turns -= 1
        if b.lol_barrier_turns == 0 && b.lol_barrier_shield > 0
          b.lol_barrier_shield = 0
          pbDisplay(_INTL("La Barrière de {1} s'est dissipée.", b.pbThis))
        end
      end

      # 3. Exhaust Duration Depletion
      if b.lol_exhaust_turns > 0
        b.lol_exhaust_turns -= 1
        if b.lol_exhaust_turns == 0
          pbDisplay(_INTL("{1} n'est plus sous l'effet de Fatigue !", b.pbThis))
        end
      end

      # 4. Flash Reflex Reset (Lasts 1 turn)
      b.lol_flash_dodge = false
    end
  end
end

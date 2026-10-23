#===============================================================================
# LoL Summoner Spells - Intelligent Enemy AI
#===============================================================================

class Battle::AI
  alias lol_pbDefaultChooseEnemyCommand pbDefaultChooseEnemyCommand
  def pbDefaultChooseEnemyCommand(idxBattler)
    pbCheckAndUseSummonerSpellAI(idxBattler)
    lol_pbDefaultChooseEnemyCommand(idxBattler)
  end

  #-----------------------------------------------------------------------------
  # Tactical Decision Engine for Opponent Trainer / Boss
  #-----------------------------------------------------------------------------
  def pbCheckAndUseSummonerSpellAI(idxBattler)
    return if !@battle.trainerBattle?

    enemy_battler = @battle.battlers[idxBattler]
    return if !enemy_battler || enemy_battler.fainted?

    side = enemy_battler.idxOwnSide
    return if side != 1 # Opponent side only

    player_battler = enemy_battler.pbDirectOpposing
    return if !player_battler || player_battler.fainted?

    # 1. IGNITE KILL-SECURE:
    # If player HP is low (<= 35%) and Ignite is ready:
    if @battle.pbCanCastSummonerSpell?(1, :IGNITE) && player_battler.hp <= (player_battler.totalhp * 0.35)
      @battle.pbCastSummonerSpell(1, :IGNITE, player_battler)
      return
    end

    # 2. FLASH REFLEX / SURVIVAL:
    # If enemy battler HP is critical (<= 25%) and Flash is ready:
    if @battle.pbCanCastSummonerSpell?(1, :FLASH) && enemy_battler.hp <= (enemy_battler.totalhp * 0.25)
      @battle.pbCastSummonerSpell(1, :FLASH, enemy_battler)
      return
    end

    # 3. HEAL CLUTCH:
    # If enemy battler HP is low (<= 30%) and Heal is ready:
    if @battle.pbCanCastSummonerSpell?(1, :HEAL) && enemy_battler.hp <= (enemy_battler.totalhp * 0.30)
      @battle.pbCastSummonerSpell(1, :HEAL, enemy_battler)
      return
    end

    # 4. BARRIER DEFENSE:
    # If enemy battler HP <= 50% and facing offensive pressure, and Barrier is ready:
    if @battle.pbCanCastSummonerSpell?(1, :BARRIER) && enemy_battler.hp <= (enemy_battler.totalhp * 0.50)
      @battle.pbCastSummonerSpell(1, :BARRIER, enemy_battler)
      return
    end

    # 5. EXHAUST THREAT-NEUTRALIZATION:
    # If player battler has boosted stats (>= 2 stages Atk/SpAtk), or high burst, and Exhaust is ready:
    if @battle.pbCanCastSummonerSpell?(1, :EXHAUST)
      player_boosted = (player_battler.stages[:ATTACK] >= 2 || player_battler.stages[:SPECIAL_ATTACK] >= 2)
      if player_boosted || (enemy_battler.hp <= (enemy_battler.totalhp * 0.60) && @battle.turnCount == 1)
        @battle.pbCastSummonerSpell(1, :EXHAUST, player_battler)
        return
      end
    end
  end
end

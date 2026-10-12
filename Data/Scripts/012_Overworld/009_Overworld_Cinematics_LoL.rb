#===============================================================================
# Cinématiques Overworld — Acte 1 (Freljord & Dirigeable de Noxus)
#===============================================================================
# Fichier : Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb
# Ajouté par : Antigravity
#
# UTILISATION (dans "001: Intro" et "002: Quick start intro" ou tout événement) :
#
#   pbCinematiqueDirigeableNoxus
#
# DÉROULEMENT COMPLET (Prologue Cinématique -> Début Classique Pokémon) :
# 1. Affiche le Toit de la Montagne Enneigée (Fond_Sanctuaire_Glace.png) avec
#    neige qui tombe en continu et le GRAND Œuf d'Anivia (144x120) positionné
#    à Y = 166..286 (100% AU-DESSUS de la boîte de dialogue Y = 288..384 !).
# 2. Le Commandant Valerius et ses 2 soldats marchent jusqu'à l'Œuf et parlent
#    (le texte ne cache aucun pixel de l'Œuf !).
# 3. Le GRAND Dirigeable de Noxus (346x282, ballon 100% visible) arrive en haut,
#    déroule une ÉCHELLE DE CORDE depuis le pont : les 3 Noxiens marchent jusqu'à
#    l'échelle et GRIMPENT les barreaux de dos jusqu'à la cabine du bateau !
# 4. Le GRAND TREUIL descend jusqu'à l'Œuf, le saisit et le soulève :
#    -> L'ÉCRAN TREMBLE VIOLEMMENT (tremblement du Viewport + secousses continues) !
#    -> DÉCLENCHE IMMÉDIATEMENT LA VRAIE TEMPÊTE (BLIZZARD + TONNERRES/ÉCLAIRS) !
#    -> L'Œuf 100% complet (144x120) est hissé sous la coque (Y = 126..280,
#       toujours 100% au-dessus de la boîte de dialogue !).
# 5. Un tonnerre géant frappe l'hélice arrière du Dirigeable qui s'enfuit.
# 6. Fondu au noir -> Réveil dans la chambre du joueur pour le début classique !
#===============================================================================

class Game_Temp
  attr_accessor :noxus_dirigeable_sprite
  attr_accessor :noxus_dirigeable_viewport
  attr_accessor :noxus_snowstorm
end

#-------------------------------------------------------------------------------
# Système de Neige, Vraie Tempête Blizzard, Tonnerres & Tremblement d'Écran
#-------------------------------------------------------------------------------
class NoxusSnowStorm
  def initialize(viewport)
    @viewport = viewport
    @disposed = false
    @mode = :snow
    @frame = 0
    @w = Graphics.width
    @h = Graphics.height

    # Tremblement réel du Viewport de la cinématique (ox / oy)
    @shake_power = 0
    @shake_duration = 0
    @continuous_rumble = false

    # Voile atmosphérique de blizzard glacé (actif en mode :blizzard)
    @veil_sprite = Sprite.new(@viewport)
    @veil_bmp = Bitmap.new(@w + 32, @h + 32)
    @veil_bmp.fill_rect(0, 0, @w + 32, @h + 32, Color.new(175, 225, 255, 255))
    @veil_sprite.bitmap = @veil_bmp
    @veil_sprite.x = -16
    @veil_sprite.y = -16
    @veil_sprite.z = 680
    @veil_sprite.opacity = 0

    # Bitmaps partagés d'Éclairs / Tonnerres ramifiés (3 variantes pixel-art)
    @bolt_bmps = [101, 202, 303].map { |seed| build_lightning_bitmap(84, 230, seed) }
    @bolt_sprite = Sprite.new(@viewport)
    @bolt_sprite.bitmap = @bolt_bmps[0]
    @bolt_sprite.z = 480
    @bolt_sprite.visible = false
    @bolt_timer = 0

    # Bitmaps partagés pour les flocons (2x2, 3x3, 4x4, 5x5)
    @flake_bmps = [2, 3, 4, 5].map do |sz|
      b = Bitmap.new(sz, sz)
      b.fill_rect(0, 0, sz, sz, Color.new(245, 252, 255, 245))
      b.fill_rect(1, 1, sz - 2, sz - 2, Color.new(255, 255, 255, 255)) if sz >= 4
      b
    end

    # Bitmaps partagés pour les rafales de vent diagonales en mode :blizzard
    @streak_bmp_1 = Bitmap.new(36, 16)
    @streak_bmp_2 = Bitmap.new(24, 12)
    16.times do |i|
      x1 = 34 - (i * 2)
      @streak_bmp_1.fill_rect(x1, i, 3, 2, Color.new(220, 245, 255, 195)) if x1 >= 0
    end
    12.times do |i|
      x2 = 22 - (i * 2)
      @streak_bmp_2.fill_rect(x2, i, 2, 1, Color.new(200, 235, 255, 165)) if x2 >= 0
    end

    # 160 flocons (65 actifs en neige douce, 160 actifs en tempête !)
    @flakes = []
    160.times do |i|
      spr = Sprite.new(@viewport)
      spr.bitmap = @flake_bmps[i % @flake_bmps.length]
      spr.z = (i % 3 == 0) ? 720 : 690
      px = rand(@w)
      py = rand(@h)
      spr.x = px
      spr.y = py
      spr.opacity = 185 + rand(70)
      spr.visible = (i < 65)
      @flakes << {
        sprite: spr,
        x: px.to_f,
        y: py.to_f,
        vx_snow: -0.6 - rand * 1.1,
        vy_snow: 1.5 + rand * 1.8,
        vx_bliz: -8.5 - rand * 6.5,
        vy_bliz: 4.8 + rand * 4.5,
        phase: rand * 6.28
      }
    end

    # 28 rafales de vent glacé (visibles uniquement pendant la tempête !)
    @streaks = []
    28.times do |i|
      spr = Sprite.new(@viewport)
      spr.bitmap = (i.even? ? @streak_bmp_1 : @streak_bmp_2)
      spr.z = 730
      px = rand(@w)
      py = rand(@h)
      spr.x = px
      spr.y = py
      spr.visible = false
      @streaks << {
        sprite: spr,
        x: px.to_f,
        y: py.to_f,
        vx: -15.5 - rand * 7.0,
        vy: 6.5 + rand * 3.5
      }
    end
  end

  # Génère un éclair ramifié en pixel-art (lueur cyan + cœur blanc pur)
  def build_lightning_bitmap(w, h, seed)
    bmp = Bitmap.new(w, h)
    c_glow = Color.new(90, 215, 255, 150)
    c_mid  = Color.new(185, 240, 255, 230)
    c_core = Color.new(255, 255, 255, 255)
    cx = w / 2
    cy = 0
    step = 0
    while cy < h - 4
      step += 1
      dir = ((seed + step * 37) % 15) - 7
      nx = (cx + dir * 2).clamp(10, w - 10)
      ny = [cy + 14 + ((seed + step * 13) % 10), h - 1].min
      draw_thick_line(bmp, cx, cy, nx, ny, c_glow, c_mid, c_core)
      if (step % 3) == 0
        bx = (nx + ((step.even? ? 1 : -1) * (12 + (step * 5) % 14))).clamp(4, w - 4)
        by = [ny + 18 + (step * 7) % 12, h - 1].min
        draw_thick_line(bmp, nx, ny, bx, by, c_glow, c_mid, c_core)
      end
      cx = nx
      cy = ny
    end
    return bmp
  end

  def draw_thick_line(bmp, x0, y0, x1, y1, c_glow, c_mid, c_core)
    steps = [(x1 - x0).abs, (y1 - y0).abs, 1].max
    steps.times do |i|
      t = i.to_f / steps
      px = (x0 + (x1 - x0) * t).round
      py = (y0 + (y1 - y0) * t).round
      bmp.fill_rect(px - 3, py - 1, 7, 3, c_glow)
      bmp.fill_rect(px - 2, py,     5, 2, c_mid)
      bmp.fill_rect(px - 1, py,     3, 2, c_core)
    end
  end

  # Déclenche un vrai tremblement de tout l'écran de la cinématique !
  def trigger_shake!(power = 8, duration = 30)
    @shake_power = [power, @shake_power].max
    @shake_duration = [duration, @shake_duration].max
    $game_screen.start_shake(power, 7, duration) if $game_screen
  end

  def continuous_rumble=(val)
    @continuous_rumble = val
    if !val && @shake_duration <= 0 && @viewport && !@viewport.disposed?
      @viewport.ox = 0
      @viewport.oy = 0
    end
  end

  # Déclenche un coup de tonnerre / éclair + secousse d'écran
  def strike_thunder!(bolt_x = nil, play_sound = true, shake_pow = 6)
    return if @disposed
    @bolt_sprite.bitmap = @bolt_bmps[rand(@bolt_bmps.length)]
    @bolt_sprite.x = bolt_x || (24 + rand(@w - 130))
    @bolt_sprite.y = 0
    @bolt_sprite.visible = true
    @bolt_sprite.opacity = 255
    @bolt_timer = 10
    trigger_shake!(shake_pow, 14) if shake_pow > 0
    $game_screen.start_flash(Color.new(185, 240, 255, 145), 6) if $game_screen
    if play_sound
      pbSEPlay("Battle thunder", 85, 90 + rand(20)) rescue nil
    end
  end

  # Déclenche immédiatement la VRAIE TEMPÊTE DE NEIGE + TREMBLEMENT D'ÉCRAN !
  def trigger_blizzard!
    return if @disposed || @mode == :blizzard
    @mode = :blizzard
    @continuous_rumble = true
    @flakes.each_with_index do |f, idx|
      f[:sprite].visible = true if f[:sprite] && !f[:sprite].disposed?
      f[:sprite].bitmap = @flake_bmps[(idx + 1) % @flake_bmps.length]
    end
    @streaks.each do |s|
      s[:sprite].visible = true if s[:sprite] && !s[:sprite].disposed?
    end
    pbSEPlay("PR SFX- Icy Wind", 95, 85) rescue nil
    pbSEPlay("Mining collapse", 90, 65) rescue nil
    trigger_shake!(10, 45)
    strike_thunder!(48, true, 10)
  end

  def update
    return if @disposed
    @frame += 1

    # Mise à jour du tremblement réel de l'écran (Viewport ox / oy)
    if @viewport && !@viewport.disposed?
      if @shake_duration > 0
        @shake_duration -= 1
        cur_p = @shake_power
        @viewport.ox = rand(-cur_p..cur_p)
        @viewport.oy = rand(-(cur_p / 2)..(cur_p / 2))
        @shake_power = 4 if @shake_duration == 0 && @continuous_rumble
      elsif @continuous_rumble
        # Grondement sismique continu pendant que l'Œuf est arraché de la montagne
        @viewport.ox = (@frame.even? ? -3 : 3) + rand(-2..2)
        @viewport.oy = rand(-2..2)
      else
        @viewport.ox = 0
        @viewport.oy = 0
      end
    end

    # Animation d'extinction de l'éclair actif
    if @bolt_timer > 0
      @bolt_timer -= 1
      if @bolt_sprite && !@bolt_sprite.disposed?
        @bolt_sprite.opacity = (@bolt_timer.even? ? 255 : 120)
        @bolt_sprite.visible = false if @bolt_timer <= 0
      end
    end

    if @mode == :snow
      @flakes.each_with_index do |f, i|
        next if i >= 65
        spr = f[:sprite]
        next if !spr || spr.disposed?
        sway = Math.sin(@frame * 0.06 + f[:phase]) * 0.6
        f[:x] += f[:vx_snow] + sway
        f[:y] += f[:vy_snow]
        f[:x] += (@w + 12) if f[:x] < -8
        f[:x] -= (@w + 12) if f[:x] > @w + 4
        if f[:y] > @h + 4
          f[:y] = -6.0
          f[:x] = rand(@w).to_f
        end
        spr.x = f[:x].round
        spr.y = f[:y].round
      end
    else
      # Mode :blizzard — Vraie tempête de neige intense + Tonnerres périodiques !
      if @veil_sprite && !@veil_sprite.disposed?
        target_op = 54 + (Math.sin(@frame * 0.14) * 20).round
        @veil_sprite.opacity = target_op.clamp(32, 78)
      end

      if (@frame % 55) == 0
        strike_thunder!(nil, true, 6)
      elsif (@frame % 95) == 0
        pbSEPlay("PR SFX- Icy Wind", 80, 90) rescue nil
      end

      @flakes.each do |f|
        spr = f[:sprite]
        next if !spr || spr.disposed?
        f[:x] += f[:vx_bliz]
        f[:y] += f[:vy_bliz]
        f[:x] += (@w + 16) if f[:x] < -10
        if f[:y] > @h + 8
          f[:y] = -8.0
          f[:x] = rand(@w + 80).to_f
        end
        spr.x = f[:x].round
        spr.y = f[:y].round
      end

      @streaks.each do |s|
        spr = s[:sprite]
        next if !spr || spr.disposed?
        s[:x] += s[:vx]
        s[:y] += s[:vy]
        if s[:x] < -40 || s[:y] > @h + 20
          s[:x] = (@w + rand(120)).to_f
          s[:y] = (rand(@h) - 60).to_f
        end
        spr.x = s[:x].round
        spr.y = s[:y].round
      end
    end
  end

  def disposed?
    @disposed
  end

  def dispose
    return if @disposed
    @disposed = true
    if @viewport && !@viewport.disposed?
      @viewport.ox = 0
      @viewport.oy = 0
    end
    @flakes.each { |f| f[:sprite].dispose if f[:sprite] && !f[:sprite].disposed? }
    @streaks.each { |s| s[:sprite].dispose if s[:sprite] && !s[:sprite].disposed? }
    @flake_bmps.each { |b| b.dispose if b && !b.disposed? }
    @bolt_bmps.each { |b| b.dispose if b && !b.disposed? }
    @bolt_sprite.dispose if @bolt_sprite && !@bolt_sprite.disposed?
    @streak_bmp_1.dispose if @streak_bmp_1 && !@streak_bmp_1.disposed?
    @streak_bmp_2.dispose if @streak_bmp_2 && !@streak_bmp_2.disposed?
    @veil_sprite.dispose if @veil_sprite && !@veil_sprite.disposed?
    @veil_bmp.dispose if @veil_bmp && !@veil_bmp.disposed?
  end
end

# Hook dans pbUpdateSceneMap pour que la neige, le blizzard, les tonnerres et
# le tremblement d'écran continuent même pendant que les boîtes de dialogue sont ouvertes !
alias __noxus_cinematic_orig_pbUpdateSceneMap pbUpdateSceneMap unless defined?(__noxus_cinematic_orig_pbUpdateSceneMap)
def pbUpdateSceneMap
  __noxus_cinematic_orig_pbUpdateSceneMap
  if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.update
  end
end

def pbUpdateSceneForCinematic(frames = 1)
  frames.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

#-------------------------------------------------------------------------------
# Acteur animé (PNJ ou Objet 4x4 depuis Graphics/Characters/)
#-------------------------------------------------------------------------------
class NoxusCutsceneActor
  attr_reader :sprite, :dir

  # dir : 2 = Bas, 4 = Gauche, 6 = Droite, 8 = Haut
  def initialize(viewport, char_name, x, y, dir = 2, z = 300)
    @sprite = Sprite.new(viewport)
    @bitmap = Bitmap.new("Graphics/Characters/" + char_name)
    @cw = @bitmap.width / 4
    @ch = @bitmap.height / 4
    @sprite.bitmap = @bitmap
    @sprite.ox = @cw / 2
    @sprite.oy = @ch
    @x = x.to_f
    @y = y.to_f
    @z = z
    @dir = dir
    @pattern = 0
    @anim_count = 0
    # Cadence douce : 20 frames par étape pour l'Œuf, 14 frames par pas pour les PNJ
    @step_div = char_name.to_s.include?("Oeuf") ? 20 : 14
    refresh_rect
    update_position
  end

  def turn(dir)
    @dir = dir
    @pattern = 0
    @anim_count = 0
    refresh_rect
  end

  def stop_walk
    @pattern = 0
    @anim_count = 0
    refresh_rect
  end

  def step_frame
    @anim_count += 1
    @pattern = (@anim_count / @step_div) % 4
    refresh_rect
  end

  def x; @x; end
  def y; @y; end

  def x=(val)
    @x = val.to_f
    @sprite.x = @x.round if @sprite && !@sprite.disposed?
  end

  def y=(val)
    @y = val.to_f
    @sprite.y = @y.round if @sprite && !@sprite.disposed?
  end

  def z=(val)
    @z = val
    @sprite.z = val if @sprite && !@sprite.disposed?
  end

  def visible=(val)
    @sprite.visible = val if @sprite && !@sprite.disposed?
  end

  def opacity=(val)
    @sprite.opacity = val if @sprite && !@sprite.disposed?
  end

  def jump_in_place(height = 8, frames = 28)
    base_y = @y
    frames.times do |i|
      t = (i + 1).to_f / frames
      arc = Math.sin(t * Math::PI) * height
      @sprite.y = (base_y - arc).round
      pbUpdateSceneForCinematic(1)
    end
    @sprite.y = base_y.round
    pbUpdateSceneForCinematic(14)
  end

  def refresh_rect
    row = case @dir
          when 2 then 0
          when 4 then 1
          when 6 then 2
          when 8 then 3
          else 0
          end
    @sprite.src_rect.set(@pattern * @cw, row * @ch, @cw, @ch)
  end

  def update_position
    @sprite.x = @x.round
    @sprite.y = @y.round
    @sprite.z = @z
  end

  def dispose
    @sprite.dispose if @sprite && !@sprite.disposed?
    @bitmap.dispose if @bitmap && !@bitmap.disposed?
  end
end

def pbGetNoxusCinematicViewport
  if !$game_temp.noxus_dirigeable_viewport || $game_temp.noxus_dirigeable_viewport.disposed?
    $game_temp.noxus_dirigeable_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    $game_temp.noxus_dirigeable_viewport.z = 99900
  end
  return $game_temp.noxus_dirigeable_viewport
end

def pbGetNoxusDirigeableSprite
  vp = pbGetNoxusCinematicViewport
  if !$game_temp.noxus_dirigeable_sprite || $game_temp.noxus_dirigeable_sprite.disposed?
    $game_temp.noxus_dirigeable_sprite = Sprite.new(vp)
    $game_temp.noxus_dirigeable_sprite.z = 500
  end
  return $game_temp.noxus_dirigeable_sprite
end

def pbDisposeNoxusDirigeableSprite
  if $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.dispose
  end
  $game_temp.noxus_snowstorm = nil
  if $game_temp.noxus_dirigeable_sprite && !$game_temp.noxus_dirigeable_sprite.disposed?
    $game_temp.noxus_dirigeable_sprite.bitmap.dispose if $game_temp.noxus_dirigeable_sprite.bitmap
    $game_temp.noxus_dirigeable_sprite.dispose
  end
  if $game_temp.noxus_dirigeable_viewport && !$game_temp.noxus_dirigeable_viewport.disposed?
    $game_temp.noxus_dirigeable_viewport.dispose
  end
  $game_temp.noxus_dirigeable_sprite = nil
  $game_temp.noxus_dirigeable_viewport = nil
end

def pbFindAniviaEggEvent(explicit_id = nil)
  return nil if !$game_map || !$game_map.events
  if explicit_id && $game_map.events[explicit_id]
    return $game_map.events[explicit_id]
  end
  $game_map.events.each_value do |ev|
    next if !ev
    if ev.character_name.to_s.include?("Oeuf_Anivia") || ev.name.to_s.downcase.include?("oeuf")
      return ev
    end
  end
  return nil
end

#-------------------------------------------------------------------------------
# ÉTAPE 1 : Arrivée nocturne lente et imposante du GRAND Dirigeable de Noxus (346x282, y = 0)
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_Arrivee(target_x = nil, target_y = 0, duration_frames = 260, egg_actor = nil)
  spr = pbGetNoxusDirigeableSprite
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_1_Vol")
  target_x = (Graphics.width - spr.bitmap.width) / 2 if target_x.nil?

  start_x = -spr.bitmap.width - 20
  start_y = -24
  spr.x = start_x
  spr.y = start_y
  spr.opacity = 255

  pbSEPlay("Mining collapse", 75, 65) rescue nil

  duration_frames.times do |i|
    t = (i + 1).to_f / duration_frames
    # Courbe en S très douce (pas d'accélération brusque au départ)
    ease = t * t * (3.0 - 2.0 * t)
    spr.x = (start_x + (target_x - start_x) * ease).round
    bobbing = (Math.sin(i * 0.045) * 2.0).round
    spr.y = (start_y + (target_y - start_y) * ease).round + bobbing
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  pbDirigeableNoxus_Flottement(1, egg_actor)
end

def pbDirigeableNoxus_Flottement(cycles = 1, egg_actor = nil)
  spr = $game_temp.noxus_dirigeable_sprite
  return if !spr || spr.disposed?
  base_y = spr.y
  total_frames = cycles * 90
  total_frames.times do |i|
    spr.y = base_y + (Math.sin(i * 0.07) * 2.0).round
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end
  spr.y = base_y
end

#-------------------------------------------------------------------------------
# ÉTAPE 1-BIS : Échelle de corde déroulée lentement depuis le pont du Dirigeable !
#               Valerius et ses 2 soldats marchent calmement jusqu'à l'échelle et
#               GRIMPENT barreau par barreau jusqu'à la cabine (sans précipitation)
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_EmbarquementEchelle(actors_to_board = [], egg_actor = nil)
  return if actors_to_board.empty?
  vp = pbGetNoxusCinematicViewport
  spr = pbGetNoxusDirigeableSprite

  ladder_x = spr.x + 92  # Sur la neige 100% dégagée à gauche de l'Œuf (plus aucun rocher !)
  ladder_top_y = spr.y + 84
  ladder_bot_y = 192
  max_h = ladder_bot_y - ladder_top_y

  ladder_spr = Sprite.new(vp)
  ladder_bmp = Bitmap.new(28, max_h)
  ladder_spr.bitmap = ladder_bmp
  ladder_spr.ox = 14
  ladder_spr.x = ladder_x
  ladder_spr.y = ladder_top_y
  ladder_spr.z = 510

  c_outline = Color.new(22, 18, 26)
  c_rope    = Color.new(215, 170, 78)
  c_rung    = Color.new(165, 115, 48)

  # 1) L'échelle de corde se déroule lentement depuis le pont du Dirigeable (70 frames)
  pbSEPlay("Battle Throw", 75, 85) rescue nil
  unroll_frames = 70
  unroll_frames.times do |i|
    cur_h = ((i + 1) * max_h.to_f / unroll_frames).round.clamp(8, max_h)
    ladder_bmp.clear
    ladder_bmp.fill_rect(2,  0, 4, cur_h, c_outline)
    ladder_bmp.fill_rect(22, 0, 4, cur_h, c_outline)
    ladder_bmp.fill_rect(3,  0, 2, cur_h, c_rope)
    ladder_bmp.fill_rect(23, 0, 2, cur_h, c_rope)
    ry = 6
    while ry < cur_h - 2
      ladder_bmp.fill_rect(5, ry - 1, 18, 4, c_outline)
      ladder_bmp.fill_rect(5, ry,     18, 2, c_rung)
      ry += 10
    end
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  # Courte pause une fois l'échelle déroulée
  25.times do
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  # 2) Les 3 Noxiens marchent calmement en file indienne vers la gauche (dir = 4) sur la neige au Sud de l'Œuf
  #    jusqu'à l'axe de l'échelle (x = ladder_x), puis tournent au Nord (dir = 8) et montent
  #    tout droit dans le couloir dégagé jusqu'au pied de l'échelle !
  queue_offsets = [0, 24, 48]
  target_ys     = queue_offsets.map { |off| (ladder_bot_y + off).to_f }
  start_delays  = [0, 52, 25] # Décalage naturel pour qu'ils se suivent en file indienne sans jamais se chevaucher
  walk_speed    = 1.35        # Vitesse de marche constante et naturelle (px/frame)

  actors_to_board.each { |a| a.z = 520 if a }

  frame_idx = 0
  loop do
    frame_idx += 1
    all_arrived = true
    actors_to_board.each_with_index do |act, idx|
      next if !act
      if frame_idx <= start_delays[idx]
        all_arrived = false
        next
      end

      tx = ladder_x.to_f
      ty = target_ys[idx]

      if (act.x - tx).abs > 0.8
        # Étape A : Marche horizontale vers l'alignement de l'échelle (sur la neige dégagée au Sud de l'Œuf)
        all_arrived = false
        dir_h = (act.x > tx) ? 4 : 6
        act.turn(dir_h) if act.dir != dir_h
        step_x = (tx - act.x).clamp(-walk_speed, walk_speed)
        act.x += step_x
        act.step_frame
      elsif (act.y - ty).abs > 0.8
        # Étape B : Une fois aligné sur x = ladder_x, marche verticale tout droit vers le Nord jusqu'à l'échelle !
        all_arrived = false
        act.x = tx
        dir_v = (act.y > ty) ? 8 : 2
        act.turn(dir_v) if act.dir != dir_v
        step_y = (ty - act.y).clamp(-walk_speed, walk_speed)
        act.y += step_y
        act.step_frame
      else
        # Arrivé à sa place au pied de l'échelle : s'arrête proprement de dos (dir = 8)
        act.x = tx
        act.y = ty
        act.stop_walk
        act.turn(8)
      end
    end

    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
    break if all_arrived
  end

  # Courte pause au pied de l'échelle avant de grimper
  25.times do
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  # 3) Ils grimpent lentement les barreaux un par un jusqu'au pont (185 frames) !
  climb_frames = 185
  climb_frames.times do |i|
    actors_to_board.each do |act|
      next if !act
      if act.y > ladder_top_y + 12
        act.y -= 0.88
        act.step_frame
        if (i % 22) == 0 && act == actors_to_board[0]
          pbSEPlay("Player bump", 55, 120) rescue nil
        end
      else
        act.visible = false
      end
    end
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end
  actors_to_board.each { |act| act.visible = false if act }

  # 4) L'échelle de corde se rétracte tranquillement sur le pont (60 frames)
  retract_frames = 60
  retract_frames.times do |i|
    cur_h = (max_h * (1.0 - (i + 1).to_f / retract_frames)).round.clamp(0, max_h)
    ladder_bmp.clear
    if cur_h > 4
      ladder_bmp.fill_rect(2,  0, 4, cur_h, c_outline)
      ladder_bmp.fill_rect(22, 0, 4, cur_h, c_outline)
      ladder_bmp.fill_rect(3,  0, 2, cur_h, c_rope)
      ladder_bmp.fill_rect(23, 0, 2, cur_h, c_rope)
      ry = 6
      while ry < cur_h - 2
        ladder_bmp.fill_rect(5, ry - 1, 18, 4, c_outline)
        ladder_bmp.fill_rect(5, ry,     18, 2, c_rung)
        ry += 10
      end
    end
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  ladder_bmp.dispose
  ladder_spr.dispose

  # Pause avant l'activation du treuil
  30.times do
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end
end

#-------------------------------------------------------------------------------
# ÉTAPE 2 : Le GRAND TREUIL descend lentement jusqu'au Grand Œuf (144x120, y = 226),
#           se verrouille dessus, L'ÉCRAN TREMBLE VIOLEMMENT, LA TEMPÊTE + TONNERRES ÉCLATENT,
#           et le treuil hisse lentement l'Œuf 100% COMPLET sous la coque (y = 205,
#           100% au-dessus de la boîte de dialogue Y = 288 !)
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_CaptureOeuf(egg_event = nil, egg_actor = nil, altar_cx = 256, altar_cy = 226)
  vp = pbGetNoxusCinematicViewport
  spr = pbGetNoxusDirigeableSprite

  ship_belly_y = spr.y + 140 # Bas de la coque du grand Dirigeable

  # 1) Descente lente et lourde du GRAND TREUIL (130 frames)
  cable_sprite = Sprite.new(vp)
  cable_sprite.z = 515
  max_cable_len = (altar_cy - ship_belly_y - 12).clamp(36, 160)
  cable_bmp = Bitmap.new(128, max_cable_len)
  cable_sprite.bitmap = cable_bmp
  cable_sprite.ox = 64
  cable_sprite.x = altar_cx
  cable_sprite.y = ship_belly_y

  c_outline = Color.new(22, 18, 26)
  c_gold    = Color.new(235, 190, 80)
  c_red     = Color.new(195, 38, 46)

  pbSEPlay("Battle Throw", 85, 65) rescue nil
  descent_frames = 130
  descent_frames.times do |i|
    t = (i + 1).to_f / descent_frames
    ease = t * t * (3.0 - 2.0 * t)
    cur_len = (max_cable_len * ease).round.clamp(12, max_cable_len)
    cable_bmp.clear
    cable_bmp.fill_rect(28, 0, 8, cur_len - 10, c_outline)
    cable_bmp.fill_rect(30, 0, 4, cur_len - 10, c_gold)
    cable_bmp.fill_rect(92, 0, 8, cur_len - 10, c_outline)
    cable_bmp.fill_rect(94, 0, 4, cur_len - 10, c_gold)
    cable_bmp.fill_rect(60, 0, 8, cur_len - 10, c_outline)
    cable_bmp.fill_rect(62, 0, 4, cur_len - 10, c_red)
    cable_bmp.fill_rect(6,  cur_len - 12, 116, 12, c_outline)
    cable_bmp.fill_rect(8,  cur_len - 10, 112, 8,  c_red)
    if (i % 32) == 0 && i > 0
      pbSEPlay("Battle catch click", 65, 75) rescue nil
    end
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  # 2) Les grandes pinces du treuil s'accrochent et se verrouillent sur l'Œuf (pause de 55 frames !)
  pbSEPlay("Battle catch click", 95, 80) rescue nil
  $game_screen.start_flash(Color.new(120, 235, 255, 220), 18)

  if egg_event
    $game_self_switches[[$game_map.map_id, egg_event.id, "A"]] = true
    $game_map.need_refresh = true
    $game_map.refresh
  end
  # L'Œuf est maintenant dans les pinces du Grand Treuil :
  egg_actor.visible = false if egg_actor

  lift_sprite = Sprite.new(vp)
  lift_sprite.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Grappin_Oeuf")
  lift_sprite.ox = lift_sprite.bitmap.width / 2
  lift_sprite.oy = lift_sprite.bitmap.height / 2
  lift_sprite.z = 525
  lift_sprite.x = altar_cx
  lift_sprite.y = altar_cy

  # Pause dramatique pendant que les pinces enserrent l'Œuf au sol avant de l'arracher
  30.times do |i|
    pbSEPlay("Battle catch click", 85, 95) rescue nil if i == 15
    pbUpdateSceneForCinematic(1)
  end

  # -> DÈS QUE L'ŒUF EST ARRACHÉ DU SOL :
  #    1) L'ÉCRAN TREMBLE VIOLEMMENT (tremblement du Viewport + secousses continues) !
  #    2) LA VRAIE TEMPÊTE (BLIZZARD + TONNERRES) ÉCLATE !
  if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.trigger_blizzard!
  end

  # Courte secousse sur place au moment où l'Œuf se détache de sa glace pure (25 frames)
  25.times do
    pbUpdateSceneForCinematic(1)
  end

  # 3) Le GRAND TREUIL hisse lentement et lourdement le GRAND ŒUF COMPLET (220 frames !)
  start_lift_y = altar_cy
  end_lift_y   = spr.y + 128 + (lift_sprite.bitmap.height / 2) # Aligné au pixel près avec Dirigeable_Noxus_2_Capture (y = 205, bas de l'Œuf à y = 282 < 288 !)

  lift_frames = 220
  pbSEPlay("Mining reveal", 85, 65) rescue nil
  lift_frames.times do |i|
    t = (i + 1).to_f / lift_frames
    ease = t * t * (3.0 - 2.0 * t)
    cur_y = (start_lift_y + (end_lift_y - start_lift_y) * ease).round
    lift_sprite.x = altar_cx
    lift_sprite.y = cur_y

    # Grondements sismiques pendant la lente montée de l'Œuf
    if i == 75 || i == 150
      pbSEPlay("Mining collapse", 85, 75) rescue nil
      if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
        $game_temp.noxus_snowstorm.trigger_shake!(8, 30)
      end
    end

    top_of_winch = cur_y - (lift_sprite.bitmap.height / 2) + 28
    rem_len = (top_of_winch - ship_belly_y).round.clamp(0, max_cable_len)
    cable_bmp.clear
    if rem_len > 4
      cable_bmp.fill_rect(28, 0, 8, rem_len, c_outline)
      cable_bmp.fill_rect(30, 0, 4, rem_len, c_gold)
      cable_bmp.fill_rect(92, 0, 8, rem_len, c_outline)
      cable_bmp.fill_rect(94, 0, 4, rem_len, c_gold)
      cable_bmp.fill_rect(60, 0, 8, rem_len, c_outline)
      cable_bmp.fill_rect(62, 0, 4, rem_len, c_red)
    end

    pbUpdateSceneForCinematic(1)
  end

  # Fin de la montée : on garde de légères secousses d'orage lors des tonnerres
  if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.continuous_rumble = false
  end

  cable_bmp.dispose
  cable_sprite.dispose
  lift_sprite.bitmap.dispose if lift_sprite.bitmap
  lift_sprite.dispose

  # 4) Le Grand Œuf complet reste suspendu au Grand Treuil sous le Dirigeable (100% au-dessus de Y=288 !)
  spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_2_Capture")
  pbSEPlay("Battle catch click", 90, 100) rescue nil

  pbDirigeableNoxus_Flottement(1)
end

#-------------------------------------------------------------------------------
# ÉTAPE 3 : Tonnerre géant sur l'hélice arrière, Explosion & Fuite lourde dans la tempête
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_ExplosionEtFuite(duration_frames = 260, dispose_at_end = true)
  spr = pbGetNoxusDirigeableSprite

  if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.strike_thunder!(spr.x + 10, true, 12)
  end
  pbSEPlay("Battle thunder", 100, 95) rescue nil
  $game_screen.start_flash(Color.new(190, 245, 255, 245), 18)

  spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_3_Explosion")

  base_y = spr.y
  95.times do |i|
    spr.y = base_y + ((i % 6 < 3) ? -2 : 2)
    if i == 45 && $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
      $game_temp.noxus_snowstorm.strike_thunder!(spr.x + 260, true, 10)
    end
    pbUpdateSceneForCinematic(1)
  end

  pbSEPlay("Battle damage super", 85, 70) rescue nil
  start_x = spr.x
  end_x   = Graphics.width + 40
  duration_frames.times do |i|
    t = (i + 1).to_f / duration_frames
    ease = t * t * (3.0 - 2.0 * t)
    spr.x = (start_x + (end_x - start_x) * ease).round
    spr.y = base_y - (t * 14).round + (Math.sin(i * 0.06) * 2.5).round
    pbUpdateSceneForCinematic(1)
  end

  pbDisposeNoxusDirigeableSprite if dispose_at_end
end

#-------------------------------------------------------------------------------
# CINÉMATIQUE COMPLÈTE AUTOMATIQUE + TRANSITION VERS LE DÉBUT CLASSIQUE POKÉMON
#-------------------------------------------------------------------------------
def pbCinematiqueDirigeableNoxus(explicit_egg_event_id = nil, utiliser_ma_carte = nil)
  vp = pbGetNoxusCinematicViewport
  egg_event = pbFindAniviaEggEvent(explicit_egg_event_id)

  if utiliser_ma_carte.nil?
    utiliser_ma_carte = ($game_map && $game_map.map_id != 3 && $game_map.map_id != 1)
  end

  old_transparent = $game_player ? $game_player.transparent : false
  if utiliser_ma_carte && $game_player
    $game_player.transparent = true
    pbUpdateSceneForCinematic(2)
  end

  # Position Y = 226 : le Grand Œuf (144x120) occupe Y = 166..286,
  # soit 100% AU-DESSUS de la boîte de dialogue (Y = 288..384) !
  altar_cx = Graphics.width / 2
  altar_cy = 226

  # 0) Fond plein écran du Toit de la Montagne Enneigée (avec marges de 12px pour le tremblement d'écran !)
  bg_sprite = nil
  if !utiliser_ma_carte
    bg_sprite = Sprite.new(vp)
    raw_bg = Bitmap.new("Graphics/Pictures/Fond_Sanctuaire_Glace")
    padded_bg = Bitmap.new(raw_bg.width + 24, raw_bg.height + 24)
    padded_bg.blt(12, 12, raw_bg, Rect.new(0, 0, raw_bg.width, raw_bg.height))
    padded_bg.stretch_blt(Rect.new(0, 12, 12, raw_bg.height), raw_bg, Rect.new(0, 0, 2, raw_bg.height))
    padded_bg.stretch_blt(Rect.new(raw_bg.width + 12, 12, 12, raw_bg.height), raw_bg, Rect.new(raw_bg.width - 2, 0, 2, raw_bg.height))
    padded_bg.stretch_blt(Rect.new(0, 0, raw_bg.width + 24, 12), padded_bg, Rect.new(0, 12, raw_bg.width + 24, 2))
    padded_bg.stretch_blt(Rect.new(0, raw_bg.height + 12, raw_bg.width + 24, 12), padded_bg, Rect.new(0, raw_bg.height + 10, raw_bg.width + 24, 2))
    raw_bg.dispose
    bg_sprite.bitmap = padded_bg
    bg_sprite.x = -12
    bg_sprite.y = -12
    bg_sprite.z = 50
  end

  # -> Lancement de la NEIGE EN CONTINU dès le début de la cinématique !
  if $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.dispose
  end
  $game_temp.noxus_snowstorm = NoxusSnowStorm.new(vp)

  # [AGY-018] BGM : Neige calme du Freljord (Route 216 — Pokémon D/P)
  pbBGMPlay("Freljord_Calme", 85, 95)

  if egg_event
    altar_cx = egg_event.screen_x
    altar_cy = egg_event.screen_y - 16
  end

  # 1) Affichage du GRAND Œuf d'Anivia animé (!Oeuf_Anivia.png : 168x138 par frame)
  #    Bas du sprite à altar_cy + 62 = 288 (aligné au pixel près sur y = 150..288 au-dessus de la boîte de texte !)
  egg_actor = NoxusCutsceneActor.new(vp, "!Oeuf_Anivia", altar_cx, altar_cy + 62, 2, 150)
  egg_event.transparent = true if egg_event

  # 2) Arrivée par le Sud du plateau en marchant vers le Nord directement en direction de l'Œuf (dir = 8, 155 frames) !
  valerius = NoxusCutsceneActor.new(vp, "trainer_ROCKETBOSS",   altar_cx,      398, 8, 300)
  soldat_g = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_M", altar_cx - 56, 414, 8, 290)
  soldat_d = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_F", altar_cx + 56, 414, 8, 290)

  walk_in_frames = 155
  walk_in_frames.times do |i|
    t = (i + 1).to_f / walk_in_frames
    valerius.y = 398 + (288 - 398) * t
    soldat_g.y = 414 + (296 - 414) * t
    soldat_d.y = 414 + (296 - 414) * t
    valerius.step_frame
    soldat_g.step_frame
    soldat_d.step_frame
    egg_actor.step_frame
    pbUpdateSceneForCinematic(1)
  end

  valerius.stop_walk
  soldat_g.stop_walk
  soldat_d.stop_walk
  valerius.turn(8) # Tourné vers le Nord (face à l'Œuf d'Anivia)
  soldat_g.turn(8) # Tourné vers le Nord (face à l'Œuf d'Anivia)
  soldat_d.turn(8) # Tournée vers le Nord (face à l'Œuf d'Anivia)
  30.times do
    egg_actor.step_frame
    pbUpdateSceneForCinematic(1)
  end

  # Dialogues des personnages sur le sommet enneigé (l'Œuf est 100% visible au-dessus du texte !)
  valerius.jump_in_place(8, 28)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Enfin... Nous avons atteint le toit de la montagne sacrée de Freljord. L'Œuf d'Anivia est entre nos mains !"))

  soldat_g.jump_in_place(7, 26)
  pbMessage(_INTL("\\bSoldat de Noxus :\\b Commandant ! L'Œuf du Cryophénix est gigantesque ! Les balises de treuillage sont verrouillées !"))

  valerius.jump_in_place(8, 28)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Parfait ! Faites approcher le Dirigeable ! Remontons à bord par l'échelle et actionnons le grand treuil !"))

  # 3) Le GRAND Dirigeable arrive lentement et lourdement dans le ciel étoilé au-dessus des montagnes (260 frames)
  # [AGY-018] BGM : Transition vers la tempête de Freljord (Battle Regi — Pokémon Pt)
  pbBGMFade(2.5)
  pbBGMPlay("Freljord_Tempete", 100, 90)
  target_ship_x = (Graphics.width - 346) / 2
  pbDirigeableNoxus_Arrivee(target_ship_x, 0, 260, egg_actor)

  # 4) L'échelle de corde se déroule et les 3 Noxiens grimpent calmement à bord !
  pbDirigeableNoxus_EmbarquementEchelle([valerius, soldat_g, soldat_d], egg_actor)

  # 5) Le GRAND TREUIL descend lentement jusqu'à l'Œuf, le saisit -> TREMBLEMENT D'ÉCRAN + TEMPÊTE + TONNERRES !
  pbDirigeableNoxus_CaptureOeuf(egg_event, egg_actor, altar_cx, altar_cy)

  pbMessage(_INTL("\\bCommandant Valerius :\\b Ahahaha ! L'Œuf d'Anivia est suspendu sous notre coque ! Peu importe ce séisme et ce blizzard, en route vers Port-Brumeux !"))
  pbMessage(_INTL("Un cri glacial déchire soudain la tempête de Freljord ! La foudre s'abat violemment sur le dirigeable !"))

  # 6) Tonnerre géant, explosion de l'hélice arrière & fuite lourde du Dirigeable avec le Grand Œuf complet (260 frames)
  pbDirigeableNoxus_ExplosionEtFuite(260, false)

  pbMessage(_INTL("L'Œuf d'Anivia a été emporté par le Dirigeable de Noxus au cœur de l'orage de neige... Mais son hélice arrière a explosé vers la Caverne de l'Épreuve !"))

  # 7) TRANSITION DOUCE VERS LE DÉBUT CLASSIQUE POKÉMON (Réveil dans la chambre)
  fade_sprite = Sprite.new(vp)
  fade_bmp = Bitmap.new(Graphics.width + 32, Graphics.height + 32)
  fade_bmp.fill_rect(0, 0, Graphics.width + 32, Graphics.height + 32, Color.new(0, 0, 0, 255))
  fade_sprite.bitmap = fade_bmp
  fade_sprite.x = -16
  fade_sprite.y = -16
  fade_sprite.z = 900
  fade_sprite.opacity = 0

  # [AGY-018] BGM : Fondu de la musique avec le noir de fin de cinématique
  pbBGMFade(4.0)
  65.times do |i|
    fade_sprite.opacity = ((i + 1) * 255.0 / 65).round
    pbUpdateSceneForCinematic(1)
  end

  if $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.dispose
  end
  $game_temp.noxus_snowstorm = nil

  if bg_sprite && !bg_sprite.disposed?
    bg_sprite.bitmap.dispose if bg_sprite.bitmap
    bg_sprite.dispose
  end
  egg_actor.dispose
  [valerius, soldat_g, soldat_d].each { |act| act.dispose }
  $game_player.transparent = old_transparent if $game_player

  $game_player.turn_down if $game_player
  pbSEPlay("Battle damage normal", 80, 70) rescue nil
  pbMessage(_INTL("Au même moment, en contrebas de la montagne...\\nLe grondement lointain du tonnerre et de l'explosion résonne jusque dans ta chambre !"))

  65.times do |i|
    fade_sprite.opacity = (255.0 * (1.0 - (i + 1) / 65.0)).round
    pbUpdateSceneForCinematic(1)
  end

  fade_bmp.dispose
  fade_sprite.dispose
  pbDisposeNoxusDirigeableSprite

  if $scene && $scene.respond_to?(:spriteset) && $scene.spriteset && $game_player
    $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 1) rescue nil
  end
  pbSEPlay("Exclamation", 85, 100) rescue nil
  pbUpdateSceneForCinematic(25)
end

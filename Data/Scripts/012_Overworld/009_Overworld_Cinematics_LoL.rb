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
#    neige qui tombe en continu et le GRAND Œuf d'Anivia (144x120) dans son nid.
# 2. Le Commandant Valerius et ses 2 soldats marchent jusqu'à l'Œuf et parlent.
# 3. Le GRAND Dirigeable de Noxus (346x308, ballon 100% visible) arrive en haut,
#    déroule une ÉCHELLE DE CORDE depuis le pont : les 3 Noxiens marchent jusqu'à
#    l'échelle et GRIMPENT les barreaux de dos jusqu'à la cabine du bateau !
# 4. Le GRAND TREUIL descend jusqu'à l'Œuf, le saisit et le soulève :
#    -> DÉCLENCHE IMMÉDIATEMENT LA VRAIE TEMPÊTE (BLIZZARD + TONNERRES/ÉCLAIRS) !
#    -> L'Œuf 100% complet (144x120) est hissé sous la coque sans jamais être caché.
# 5. Un tonnerre géant frappe l'hélice arrière du Dirigeable qui s'enfuit.
# 6. Fondu au noir -> Réveil dans la chambre du joueur pour le début classique !
#===============================================================================

class Game_Temp
  attr_accessor :noxus_dirigeable_sprite
  attr_accessor :noxus_dirigeable_viewport
  attr_accessor :noxus_snowstorm
end

#-------------------------------------------------------------------------------
# Système de Neige, Vraie Tempête Blizzard & Tonnerres/Éclairs (NoxusSnowStorm)
#-------------------------------------------------------------------------------
class NoxusSnowStorm
  def initialize(viewport)
    @viewport = viewport
    @disposed = false
    @mode = :snow
    @frame = 0
    @w = Graphics.width
    @h = Graphics.height

    # Voile atmosphérique de blizzard glacé (actif en mode :blizzard)
    @veil_sprite = Sprite.new(@viewport)
    @veil_bmp = Bitmap.new(@w, @h)
    @veil_bmp.fill_rect(0, 0, @w, @h, Color.new(175, 225, 255, 255))
    @veil_sprite.bitmap = @veil_bmp
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
      # Branche secondaire d'éclair
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

  # Déclenche un coup de tonnerre / éclair à une position X donnée
  def strike_thunder!(bolt_x = nil, play_sound = true)
    return if @disposed
    @bolt_sprite.bitmap = @bolt_bmps[rand(@bolt_bmps.length)]
    @bolt_sprite.x = bolt_x || (24 + rand(@w - 130))
    @bolt_sprite.y = 0
    @bolt_sprite.visible = true
    @bolt_sprite.opacity = 255
    @bolt_timer = 10
    $game_screen.start_flash(Color.new(185, 240, 255, 145), 6) if $game_screen
    if play_sound
      pbSEPlay("Battle thunder", 85, 90 + rand(20)) rescue nil
    end
  end

  # Déclenche immédiatement la VRAIE TEMPÊTE DE NEIGE (Blizzard + Tonnerres) !
  def trigger_blizzard!
    return if @disposed || @mode == :blizzard
    @mode = :blizzard
    @flakes.each_with_index do |f, idx|
      f[:sprite].visible = true if f[:sprite] && !f[:sprite].disposed?
      f[:sprite].bitmap = @flake_bmps[(idx + 1) % @flake_bmps.length]
    end
    @streaks.each do |s|
      s[:sprite].visible = true if s[:sprite] && !s[:sprite].disposed?
    end
    pbSEPlay("PR SFX- Icy Wind", 95, 85) rescue (pbSEPlay("Mining collapse", 80, 130) rescue nil)
    strike_thunder!(48, true)
  end

  def update
    return if @disposed
    @frame += 1

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

      # Coups de tonnerre et rafales de vent réguliers pendant la tempête
      if (@frame % 55) == 0
        strike_thunder!(nil, true)
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

# Hook dans pbUpdateSceneMap pour que la neige, le blizzard et les tonnerres
# continuent en temps réel même pendant que les boîtes de dialogue sont ouvertes !
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
  attr_reader :sprite

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
    refresh_rect
    update_position
  end

  def turn(dir)
    @dir = dir
    @pattern = 0
    refresh_rect
  end

  def step_frame
    @anim_count += 1
    @pattern = (@anim_count / 6) % 4
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

  def jump_in_place(height = 10, frames = 12)
    base_y = @y
    frames.times do |i|
      t = (i + 1).to_f / frames
      arc = Math.sin(t * Math::PI) * height
      @sprite.y = (base_y - arc).round
      pbUpdateSceneForCinematic(1)
    end
    @sprite.y = base_y.round
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
# ÉTAPE 1 : Arrivée nocturne du GRAND Dirigeable de Noxus (346x308, y = 2)
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_Arrivee(target_x = nil, target_y = 2, duration_frames = 65, egg_actor = nil)
  spr = pbGetNoxusDirigeableSprite
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_1_Vol")
  target_x = (Graphics.width - spr.bitmap.width) / 2 if target_x.nil?

  start_x = -spr.bitmap.width - 20
  start_y = -28
  spr.x = start_x
  spr.y = start_y
  spr.opacity = 255

  pbSEPlay("Mining collapse", 75, 70) rescue nil

  duration_frames.times do |i|
    t = (i + 1).to_f / duration_frames
    ease = 1.0 - (1.0 - t) * (1.0 - t)
    spr.x = (start_x + (target_x - start_x) * ease).round
    bobbing = (Math.sin(i * 0.15) * 3.0).round
    spr.y = (start_y + (target_y - start_y) * ease).round + bobbing
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  pbDirigeableNoxus_Flottement(1, egg_actor)
end

def pbDirigeableNoxus_Flottement(cycles = 2, egg_actor = nil)
  spr = $game_temp.noxus_dirigeable_sprite
  return if !spr || spr.disposed?
  base_y = spr.y
  total_frames = cycles * 36
  total_frames.times do |i|
    spr.y = base_y + (Math.sin(i * 0.17) * 3.0).round
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end
  spr.y = base_y
end

#-------------------------------------------------------------------------------
# ÉTAPE 1-BIS : Échelle de corde déroulée depuis le pont du Dirigeable !
#               Valerius et ses 2 soldats marchent jusqu'à l'échelle et
#               GRIMPENT réellement les barreaux jusqu'à la cabine (sans téléportation)
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_EmbarquementEchelle(actors_to_board = [], egg_actor = nil)
  return if actors_to_board.empty?
  vp = pbGetNoxusCinematicViewport
  spr = pbGetNoxusDirigeableSprite

  ladder_x = spr.x + 116 # Sous le bastingage/cabine du pont
  ladder_top_y = spr.y + 92
  ladder_bot_y = 228
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

  # 1) L'échelle de corde se déroule depuis le pont du Dirigeable
  pbSEPlay("Battle Throw", 75, 95) rescue nil
  20.times do |i|
    cur_h = ((i + 1) * max_h / 20.0).round.clamp(8, max_h)
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

  # 2) Les 3 Noxiens rejoignent le pied de l'échelle puis grimpent de dos (dir = 8) !
  #    On place les acteurs devant l'échelle (z = 520) pour qu'on les voie grimper jusqu'en haut
  actors_to_board.each { |a| a.z = 520 if a }

  start_positions = actors_to_board.map { |a| [a.x, a.y] }
  # Points d'attente en colonne au pied de l'échelle
  queue_offsets = [0, 28, 56]

  24.times do |i|
    t = (i + 1).to_f / 24
    actors_to_board.each_with_index do |act, idx|
      next if !act
      sx, sy = start_positions[idx]
      tx = ladder_x.to_f
      ty = (ladder_bot_y + queue_offsets[idx]).to_f
      act.turn(sx < tx ? 6 : 4) if i == 0
      act.x = sx + (tx - sx) * t
      act.y = sy + (ty - sy) * t
      act.step_frame
    end
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  # Ils se tournent tous vers le haut (de dos = dir 8) et grimpent les barreaux !
  actors_to_board.each { |act| act.turn(8) if act }
  climb_frames = 58
  climb_frames.times do |i|
    actors_to_board.each do |act|
      next if !act
      if act.y > ladder_top_y + 14
        act.y -= 3.2
        act.step_frame
        if (i % 10) == 0 && act == actors_to_board[0]
          pbSEPlay("Player bump", 60, 130) rescue nil
        end
      else
        # Arrivé sur le pont devant la porte de la cabine : il entre à l'intérieur !
        act.visible = false
      end
    end
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end
  actors_to_board.each { |act| act.visible = false if act }

  # 3) L'échelle de corde se rétracte sur le pont
  12.times do |i|
    cur_h = (max_h * (1.0 - (i + 1) / 12.0)).round.clamp(0, max_h)
    ladder_bmp.clear
    if cur_h > 4
      ladder_bmp.fill_rect(2,  0, 4, cur_h, c_outline)
      ladder_bmp.fill_rect(22, 0, 4, cur_h, c_outline)
      ladder_bmp.fill_rect(3,  0, 2, cur_h, c_rope)
      ladder_bmp.fill_rect(23, 0, 2, cur_h, c_rope)
    end
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  ladder_bmp.dispose
  ladder_spr.dispose
end

#-------------------------------------------------------------------------------
# ÉTAPE 2 : Le GRAND TREUIL descend jusqu'au Grand Œuf (144x120), le saisit,
#           DÉCLENCHE LA VRAIE TEMPÊTE + TONNERRES, et hisse l'Œuf 100% COMPLET
#           sous la coque du Dirigeable (sans jamais le cacher ni le rétrécir !)
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_CaptureOeuf(egg_event = nil, egg_actor = nil, altar_cx = 256, altar_cy = 284)
  vp = pbGetNoxusCinematicViewport
  spr = pbGetNoxusDirigeableSprite

  ship_belly_y = spr.y + 156 # Bas de la coque du grand Dirigeable (y = 158)

  # 1) Descente du GRAND TREUIL (doubles chaînes épaisses + câble central + large palonnier 116px)
  cable_sprite = Sprite.new(vp)
  cable_sprite.z = 515
  max_cable_len = (altar_cy - ship_belly_y - 18).clamp(40, 200)
  cable_bmp = Bitmap.new(128, max_cable_len)
  cable_sprite.bitmap = cable_bmp
  cable_sprite.ox = 64
  cable_sprite.x = altar_cx
  cable_sprite.y = ship_belly_y

  c_outline = Color.new(22, 18, 26)
  c_gold    = Color.new(235, 190, 80)
  c_red     = Color.new(195, 38, 46)

  pbSEPlay("Battle Throw", 85, 70) rescue nil
  descent_frames = 38
  descent_frames.times do |i|
    t = (i + 1).to_f / descent_frames
    cur_len = (max_cable_len * t).round.clamp(12, max_cable_len)
    cable_bmp.clear
    # Deux grosses chaînes dorées + câble central rouge + large palonnier noxien (116px) en bas
    cable_bmp.fill_rect(28, 0, 8, cur_len - 10, c_outline)
    cable_bmp.fill_rect(30, 0, 4, cur_len - 10, c_gold)
    cable_bmp.fill_rect(92, 0, 8, cur_len - 10, c_outline)
    cable_bmp.fill_rect(94, 0, 4, cur_len - 10, c_gold)
    cable_bmp.fill_rect(60, 0, 8, cur_len - 10, c_outline)
    cable_bmp.fill_rect(62, 0, 4, cur_len - 10, c_red)
    # Large barre de treuil (palonnier)
    cable_bmp.fill_rect(6,  cur_len - 12, 116, 12, c_outline)
    cable_bmp.fill_rect(8,  cur_len - 10, 112, 8,  c_red)
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  # 2) Les grandes pinces du treuil se referment sur le Grand Œuf d'Anivia !
  pbSEPlay("Battle catch click", 95, 80) rescue nil
  $game_screen.start_flash(Color.new(120, 235, 255, 220), 14)
  $game_screen.start_shake(6, 7, 18)

  if egg_event
    $game_self_switches[[$game_map.map_id, egg_event.id, "A"]] = true
    $game_map.need_refresh = true
    $game_map.refresh
  end
  # L'Œuf quitte le nid au sol : le nid enneigé vide en dessous apparaît !
  egg_actor.visible = false if egg_actor

  # -> DÈS QUE L'ŒUF EST ENLEVÉ, LA VRAIE TEMPÊTE (BLIZZARD + TONNERRES) ÉCLATE !
  if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.trigger_blizzard!
  end

  # 3) Le GRAND TREUIL hisse le GRAND ŒUF COMPLET (156x154, z = 525 devant la coque !)
  #    depuis le nid (y = 278) jusqu'à sa position d'attache sous la coque (y = 227) !
  lift_sprite = Sprite.new(vp)
  lift_sprite.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Grappin_Oeuf")
  lift_sprite.ox = lift_sprite.bitmap.width / 2
  lift_sprite.oy = lift_sprite.bitmap.height / 2
  lift_sprite.z = 525 # Devant la coque : l'Œuf est 100% visible en entier !

  start_lift_y = altar_cy - 6
  end_lift_y   = spr.y + 148 + (lift_sprite.bitmap.height / 2) # Aligné au pixel près avec Dirigeable_Noxus_2_Capture !

  lift_frames = 70
  pbSEPlay("Mining reveal", 85, 70) rescue nil
  lift_frames.times do |i|
    t = (i + 1).to_f / lift_frames
    ease = t * t * (3.0 - 2.0 * t)
    cur_y = (start_lift_y + (end_lift_y - start_lift_y) * ease).round
    lift_sprite.x = altar_cx
    lift_sprite.y = cur_y

    # Les chaînes au-dessus du palonnier se rétractent au fur et à mesure
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

  cable_bmp.dispose
  cable_sprite.dispose
  lift_sprite.bitmap.dispose if lift_sprite.bitmap
  lift_sprite.dispose

  # 4) Le Grand Œuf complet reste suspendu au Grand Treuil sous le Dirigeable !
  spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_2_Capture")
  pbSEPlay("Battle catch click", 90, 100) rescue nil

  pbDirigeableNoxus_Flottement(1)
end

#-------------------------------------------------------------------------------
# ÉTAPE 3 : Tonnerre géant sur l'hélice arrière, Explosion & Fuite dans la tempête
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_ExplosionEtFuite(duration_frames = 70, dispose_at_end = true)
  spr = pbGetNoxusDirigeableSprite

  # Double coup de tonnerre direct sur l'arrière du Dirigeable !
  if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.strike_thunder!(spr.x + 10, true)
  end
  pbSEPlay("Battle thunder", 100, 95) rescue nil
  $game_screen.start_flash(Color.new(190, 245, 255, 245), 18)
  $game_screen.start_shake(8, 9, 32)

  spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_3_Explosion")

  base_y = spr.y
  40.times do |i|
    spr.y = base_y + ((i % 4 < 2) ? -3 : 3)
    if i == 18 && $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
      $game_temp.noxus_snowstorm.strike_thunder!(spr.x + 260, true)
    end
    pbUpdateSceneForCinematic(1)
  end

  pbSEPlay("Battle damage super", 85, 75) rescue nil
  start_x = spr.x
  end_x   = Graphics.width + 40
  duration_frames.times do |i|
    t = (i + 1).to_f / duration_frames
    ease = t * t
    spr.x = (start_x + (end_x - start_x) * ease).round
    spr.y = base_y - (t * 14).round + (Math.sin(i * 0.3) * 4.0).round
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

  altar_cx = Graphics.width / 2
  altar_cy = 284

  # 0) Fond plein écran du Toit de la Montagne Enneigée (avec le nid enneigé déjà intégré)
  bg_sprite = nil
  if !utiliser_ma_carte
    bg_sprite = Sprite.new(vp)
    bg_sprite.bitmap = Bitmap.new("Graphics/Pictures/Fond_Sanctuaire_Glace")
    bg_sprite.z = 50
  end

  # -> Lancement de la NEIGE EN CONTINU dès le début de la cinématique !
  if $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.dispose
  end
  $game_temp.noxus_snowstorm = NoxusSnowStorm.new(vp)

  if egg_event
    altar_cx = egg_event.screen_x
    altar_cy = egg_event.screen_y - 16
  end

  # 1) Affichage du GRAND Œuf d'Anivia animé (!Oeuf_Anivia.png : 144x120 par frame) posé dans la neige
  egg_actor = NoxusCutsceneActor.new(vp, "!Oeuf_Anivia", altar_cx, altar_cy + 60, 2, 150)
  egg_event.transparent = true if egg_event

  # 2) Arrivée et marche animée du Commandant Valerius et de ses 2 soldats dans la neige !
  valerius = NoxusCutsceneActor.new(vp, "trainer_ROCKETBOSS", altar_cx, 120, 2, 300)
  soldat_g = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_M", altar_cx - 84, 100, 2, 290)
  soldat_d = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_F", altar_cx + 84, 100, 2, 290)

  45.times do |i|
    t = (i + 1).to_f / 45
    valerius.y = 120 + (altar_cy - 44 - 120) * t
    soldat_g.y = 100 + (altar_cy + 4 - 100) * t
    soldat_d.y = 100 + (altar_cy + 4 - 100) * t
    valerius.step_frame
    soldat_g.step_frame
    soldat_d.step_frame
    egg_actor.step_frame
    pbUpdateSceneForCinematic(1)
  end

  valerius.turn(2)
  soldat_g.turn(6)
  soldat_d.turn(4)
  pbUpdateSceneForCinematic(12)

  # Dialogues des personnages sur le sommet enneigé
  valerius.jump_in_place(10, 12)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Enfin... Nous avons atteint le toit de la montagne sacrée de Freljord. L'Œuf d'Anivia est entre nos mains !"))

  soldat_g.jump_in_place(8, 10)
  pbMessage(_INTL("\\bSoldat de Noxus :\\b Commandant ! L'Œuf du Cryophénix est gigantesque ! Les balises de treuillage sont verrouillées !"))

  valerius.jump_in_place(10, 12)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Parfait ! Faites approcher le Dirigeable ! Remontons à bord par l'échelle et actionnons le grand treuil !"))

  # 3) Le GRAND Dirigeable arrive dans le ciel étoilé au-dessus des montagnes (y = 2)
  target_ship_x = (Graphics.width - 346) / 2
  pbDirigeableNoxus_Arrivee(target_ship_x, 2, 65, egg_actor)

  # 4) L'échelle de corde se déroule et les 3 Noxiens grimpent réellement à bord !
  pbDirigeableNoxus_EmbarquementEchelle([valerius, soldat_g, soldat_d], egg_actor)

  # 5) Le GRAND TREUIL descend jusqu'à l'Œuf, le saisit et déclenche la VRAIE TEMPÊTE + TONNERRES !
  pbDirigeableNoxus_CaptureOeuf(egg_event, egg_actor, altar_cx, altar_cy)

  pbMessage(_INTL("\\bCommandant Valerius :\\b Ahahaha ! L'Œuf d'Anivia est suspendu sous notre coque ! Peu importe ce blizzard et ces tonnerres, en route vers Port-Brumeux !"))
  pbMessage(_INTL("Un cri glacial déchire soudain la tempête de Freljord ! La foudre s'abat violemment sur le dirigeable !"))

  # 6) Tonnerre géant, explosion de l'hélice arrière & fuite du Dirigeable avec le Grand Œuf complet
  pbDirigeableNoxus_ExplosionEtFuite(70, false)

  pbMessage(_INTL("L'Œuf d'Anivia a été emporté par le Dirigeable de Noxus au cœur de l'orage de neige... Mais son hélice arrière a explosé vers la Caverne de l'Épreuve !"))

  # 7) TRANSITION DOUCE VERS LE DÉBUT CLASSIQUE POKÉMON (Réveil dans la chambre)
  fade_sprite = Sprite.new(vp)
  fade_bmp = Bitmap.new(Graphics.width, Graphics.height)
  fade_bmp.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 255))
  fade_sprite.bitmap = fade_bmp
  fade_sprite.z = 900
  fade_sprite.opacity = 0

  25.times do |i|
    fade_sprite.opacity = ((i + 1) * 255.0 / 25).round
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

  25.times do |i|
    fade_sprite.opacity = (255.0 * (1.0 - (i + 1) / 25.0)).round
    pbUpdateSceneForCinematic(1)
  end

  fade_bmp.dispose
  fade_sprite.dispose
  pbDisposeNoxusDirigeableSprite

  if $scene && $scene.respond_to?(:spriteset) && $scene.spriteset && $game_player
    $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 1) rescue nil
  end
  pbSEPlay("Exclamation", 85, 100) rescue nil
  pbUpdateSceneForCinematic(15)
end

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
# 1. Affiche en plein écran le décor du Toit de la Montagne Enneigée d'Anivia
#    (Fond_Sanctuaire_Glace.png) avec neige qui tombe en continu.
# 2. L'Œuf d'Anivia animé (!Oeuf_Anivia.png) repose dans son nid enneigé (y = 232).
# 3. Le Commandant Valerius et ses 2 soldats de Noxus marchent jusqu'à l'Œuf,
#    l'encerclent et parlent sous la neige.
# 4. Le Dirigeable de Noxus arrive dans le ciel étoilé en haut (y = -18),
#    descend son grappin jusqu'à l'Œuf (y = 232), soulève concrètement l'Œuf
#    de son nid (qui devient VIDE au sol) -> DÉCLENCHE IMMÉDIATEMENT UNE VRAIE
#    TEMPÊTE DE NEIGE (BLIZZARD INTENSE) et hisse l'Œuf sous le bateau.
# 5. L'éclair frappe l'hélice arrière du Dirigeable qui s'enfuit dans le blizzard.
# 6. Fondu au noir -> Transition narrative -> Fondu d'ouverture sur la chambre
#    du joueur avec un [!] de réveil pour commencer l'aventure Pokémon classique !
#===============================================================================

class Game_Temp
  attr_accessor :noxus_dirigeable_sprite
  attr_accessor :noxus_dirigeable_viewport
  attr_accessor :noxus_snowstorm
end

#-------------------------------------------------------------------------------
# Système de Neige & Vraie Tempête Blizzard en temps réel (NoxusSnowStorm)
# - Mode :snow     (Avant l'enlèvement de l'Œuf) : neige douce qui tombe
# - Mode :blizzard (Dès que l'Œuf est enlevé)    : tempête violente avec rafales
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

    # Bitmaps partagés pour les flocons (2x2, 3x3, 4x4, 5x5) -> ultra rapide (0 lag)
    @flake_bmps = [2, 3, 4, 5].map do |sz|
      b = Bitmap.new(sz, sz)
      b.fill_rect(0, 0, sz, sz, Color.new(245, 252, 255, 245))
      if sz >= 4
        b.fill_rect(1, 1, sz - 2, sz - 2, Color.new(255, 255, 255, 255))
      end
      b
    end

    # Bitmaps partagés pour les rafales de vent diagonales en mode :blizzard
    @streak_bmp_1 = Bitmap.new(36, 16)
    @streak_bmp_2 = Bitmap.new(24, 12)
    16.times do |i|
      x1 = 34 - (i * 2)
      y1 = i
      @streak_bmp_1.fill_rect(x1, y1, 3, 2, Color.new(220, 245, 255, 190)) if x1 >= 0
    end
    12.times do |i|
      x2 = 22 - (i * 2)
      y2 = i
      @streak_bmp_2.fill_rect(x2, y2, 2, 1, Color.new(200, 235, 255, 160)) if x2 >= 0
    end

    # Création des 160 flocons (65 actifs en neige douce, 160 actifs en tempête !)
    @flakes = []
    160.times do |i|
      spr = Sprite.new(@viewport)
      spr.bitmap = @flake_bmps[i % @flake_bmps.length]
      spr.z = (i % 3 == 0) ? 720 : 690
      px = rand(@w)
      py = rand(@h)
      spr.x = px
      spr.y = py
      spr.opacity = 180 + rand(75)
      spr.visible = (i < 65)
      @flakes << {
        sprite: spr,
        x: px.to_f,
        y: py.to_f,
        vx_snow: -0.6 - rand * 1.1,
        vy_snow: 1.5 + rand * 1.8,
        vx_bliz: -8.0 - rand * 6.5,
        vy_bliz: 4.5 + rand * 4.5,
        phase: rand * 6.28
      }
    end

    # Création des 28 rafales de vent glacé (visibles uniquement pendant la tempête !)
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
        vx: -15.0 - rand * 7.0,
        vy: 6.5 + rand * 3.5
      }
    end
  end

  # Déclenche immédiatement la VRAIE TEMPÊTE DE NEIGE (Blizzard de Freljord) !
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
  end

  def update
    return if @disposed
    @frame += 1

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
      # Mode :blizzard — Vraie tempête de neige intense !
      if @veil_sprite && !@veil_sprite.disposed?
        target_op = 52 + (Math.sin(@frame * 0.14) * 20).round
        @veil_sprite.opacity = target_op.clamp(30, 78)
      end

      # Son de rafale de blizzard périodique
      if (@frame % 95) == 0
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
    @flakes.each do |f|
      f[:sprite].dispose if f[:sprite] && !f[:sprite].disposed?
    end
    @streaks.each do |s|
      s[:sprite].dispose if s[:sprite] && !s[:sprite].disposed?
    end
    @flake_bmps.each { |b| b.dispose if b && !b.disposed? }
    @streak_bmp_1.dispose if @streak_bmp_1 && !@streak_bmp_1.disposed?
    @streak_bmp_2.dispose if @streak_bmp_2 && !@streak_bmp_2.disposed?
    @veil_sprite.dispose if @veil_sprite && !@veil_sprite.disposed?
    @veil_bmp.dispose if @veil_bmp && !@veil_bmp.disposed?
  end
end

# Hook dans pbUpdateSceneMap pour que la neige et la tempête continuent de tomber
# en temps réel même pendant que les boîtes de dialogue (pbMessage) sont affichées !
alias __noxus_cinematic_orig_pbUpdateSceneMap pbUpdateSceneMap unless defined?(__noxus_cinematic_orig_pbUpdateSceneMap)
def pbUpdateSceneMap
  __noxus_cinematic_orig_pbUpdateSceneMap
  if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.update
  end
end

# Met à jour la carte et les événements pendant une animation cinématique
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

# Crée ou récupère le Viewport principal de la cinématique
def pbGetNoxusCinematicViewport
  if !$game_temp.noxus_dirigeable_viewport || $game_temp.noxus_dirigeable_viewport.disposed?
    $game_temp.noxus_dirigeable_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    # Z = 99900 : au-dessus de la carte, mais SOUS les boîtes de dialogue (99999) !
    $game_temp.noxus_dirigeable_viewport.z = 99900
  end
  return $game_temp.noxus_dirigeable_viewport
end

# Crée ou récupère le sprite du Dirigeable de Noxus
def pbGetNoxusDirigeableSprite
  vp = pbGetNoxusCinematicViewport
  if !$game_temp.noxus_dirigeable_sprite || $game_temp.noxus_dirigeable_sprite.disposed?
    $game_temp.noxus_dirigeable_sprite = Sprite.new(vp)
    $game_temp.noxus_dirigeable_sprite.z = 500
  end
  return $game_temp.noxus_dirigeable_sprite
end

# Supprime proprement le sprite du Dirigeable et la tempête à la fin de la cinématique
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

# Cherche automatiquement l'événement de l'Œuf sur la carte si présent
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
# ÉTAPE 1 : Arrivée nocturne du Dirigeable de Noxus en haut de l'écran (y = -18)
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_Arrivee(target_x = nil, target_y = -18, duration_frames = 65, egg_actor = nil)
  spr = pbGetNoxusDirigeableSprite
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_1_Vol")
  target_x = (Graphics.width - spr.bitmap.width) / 2 if target_x.nil?

  start_x = -spr.bitmap.width - 20
  start_y = -48
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

#-------------------------------------------------------------------------------
# Flottement sur place du Dirigeable (oscillation douce haut/bas)
#-------------------------------------------------------------------------------
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
# ÉTAPE 2 : Le grappin descend de la coque du bateau (y = 148) jusqu'au nid
#           de l'Œuf (y = 232), l'Œuf disparaît de sa position initiale (le
#           nid devient VIDE !), LA VRAIE TEMPÊTE DE NEIGE SE DÉCHAÎNE et
#           l'Œuf monte concrètement de y = 232 à y = 152 !
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_CaptureOeuf(egg_event = nil, egg_actor = nil, actors_to_board = [], altar_cx = 256, altar_cy = 232)
  vp = pbGetNoxusCinematicViewport
  spr = pbGetNoxusDirigeableSprite

  ship_belly_x = spr.x + (spr.bitmap.width / 2)
  ship_belly_y = spr.y + 164 # Bas de la coque du bateau volant (~146 px)

  # 1) Descente progressive des câbles et de la pince depuis la coque jusqu'à l'Œuf (y = 232)
  cable_sprite = Sprite.new(vp)
  cable_sprite.z = 350
  max_cable_len = (altar_cy - ship_belly_y + 16).clamp(40, 200)
  cable_bmp = Bitmap.new(64, max_cable_len)
  cable_sprite.bitmap = cable_bmp
  cable_sprite.ox = 32
  cable_sprite.x = altar_cx
  cable_sprite.y = ship_belly_y

  pbSEPlay("Battle Throw", 80, 75) rescue nil
  descent_frames = 40
  descent_frames.times do |i|
    t = (i + 1).to_f / descent_frames
    cur_len = (max_cable_len * t).round.clamp(6, max_cable_len)
    cable_bmp.clear
    # Deux câbles dorés + câble central + barre de treuil rouge noxienne en bas
    cable_bmp.fill_rect(18, 0, 3, cur_len - 4, Color.new(212, 168, 70))
    cable_bmp.fill_rect(43, 0, 3, cur_len - 4, Color.new(212, 168, 70))
    cable_bmp.fill_rect(31, 0, 2, cur_len - 4, Color.new(175, 32, 40))
    cable_bmp.fill_rect(12, cur_len - 5, 40, 5, Color.new(175, 32, 40))
    egg_actor.step_frame if egg_actor
    pbUpdateSceneForCinematic(1)
  end

  # 2) La pince se referme sur l'Œuf d'Anivia !
  pbSEPlay("Battle catch click", 95, 80) rescue nil
  $game_screen.start_flash(Color.new(120, 235, 255, 210), 12)
  $game_screen.start_shake(5, 6, 16)

  # -> L'ŒUF QUITTE CONCRÈTEMENT SA POSITION INITIALE DANS LA NEIGE :
  if egg_event
    $game_self_switches[[$game_map.map_id, egg_event.id, "A"]] = true
    $game_map.need_refresh = true
    $game_map.refresh
  end
  # On cache l'Œuf posé sur le nid : le nid enneigé vide en dessous apparaît immédiatement !
  egg_actor.visible = false if egg_actor

  # -> DÈS QUE L'ŒUF EST ENLEVÉ, LA VRAIE TEMPÊTE DE NEIGE (BLIZZARD) SE DÉCHAÎNE !
  if $game_temp && $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.trigger_blizzard!
  end

  # 3) L'Œuf saisi par le grappin part de sa position initiale (y = 232)
  #    et MONTE progressivement pixel par pixel jusqu'à la coque du Dirigeable (y = 152) !
  lift_sprite = Sprite.new(vp)
  lift_sprite.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Grappin_Oeuf")
  lift_sprite.ox = lift_sprite.bitmap.width / 2
  lift_sprite.oy = lift_sprite.bitmap.height / 2
  lift_sprite.z = 460

  start_lift_y = altar_cy - 8
  end_lift_y   = spr.y + 178

  lift_frames = 75
  pbSEPlay("Mining reveal", 85, 70) rescue nil
  lift_frames.times do |i|
    t = (i + 1).to_f / lift_frames
    ease = t * t * (3.0 - 2.0 * t)
    cur_y = (start_lift_y + (end_lift_y - start_lift_y) * ease).round
    lift_sprite.x = altar_cx
    lift_sprite.y = cur_y

    # Le câble se rétracte au fur et à mesure que l'Œuf monte !
    rem_len = (cur_y - ship_belly_y - 20).round.clamp(0, max_cable_len)
    cable_bmp.clear
    if rem_len > 4
      cable_bmp.fill_rect(18, 0, 3, rem_len, Color.new(212, 168, 70))
      cable_bmp.fill_rect(43, 0, 3, rem_len, Color.new(212, 168, 70))
      cable_bmp.fill_rect(31, 0, 2, rem_len, Color.new(175, 32, 40))
    end

    # Les commandants/soldats noxiens remontent dans le dirigeable en même temps
    actors_to_board.each do |actor|
      next if !actor || !actor.sprite || actor.sprite.disposed?
      if i > 10
        actor.y -= 1.8
        actor.opacity = (255 * (1.0 - ((i - 10).to_f / 45.0))).clamp(0, 255).round
      end
    end

    pbUpdateSceneForCinematic(1)
  end

  cable_bmp.dispose
  cable_sprite.dispose
  lift_sprite.bitmap.dispose if lift_sprite.bitmap
  lift_sprite.dispose

  # 4) L'Œuf est maintenant accroché sous la coque du Dirigeable (Dirigeable_Noxus_2_Capture)
  spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_2_Capture")
  pbSEPlay("Battle catch click", 90, 100) rescue nil

  pbDirigeableNoxus_Flottement(1)
end

#-------------------------------------------------------------------------------
# ÉTAPE 3 : Éclair du Sanctuaire, Explosion de l'hélice arrière & Fuite
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_ExplosionEtFuite(duration_frames = 70, dispose_at_end = true)
  spr = pbGetNoxusDirigeableSprite
  pbSEPlay("Battle thunder", 100, 95) rescue nil
  $game_screen.start_flash(Color.new(180, 245, 255, 240), 16)
  $game_screen.start_shake(8, 9, 30)

  spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_3_Explosion")

  base_y = spr.y
  40.times do |i|
    spr.y = base_y + ((i % 4 < 2) ? -3 : 3)
    pbUpdateSceneForCinematic(1)
  end

  pbSEPlay("Battle damage super", 85, 75) rescue nil
  start_x = spr.x
  end_x   = Graphics.width + 40
  duration_frames.times do |i|
    t = (i + 1).to_f / duration_frames
    ease = t * t
    spr.x = (start_x + (end_x - start_x) * ease).round
    spr.y = base_y - (t * 20).round + (Math.sin(i * 0.3) * 4.0).round
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

  # Si tu n'es PAS dans la maison (Map 003), le script utilise automatiquement
  # TA carte RPG Maker XP comme décor !
  if utiliser_ma_carte.nil?
    utiliser_ma_carte = ($game_map && $game_map.map_id != 3 && $game_map.map_id != 1)
  end

  old_transparent = $game_player ? $game_player.transparent : false
  if utiliser_ma_carte && $game_player
    $game_player.transparent = true
    pbUpdateSceneForCinematic(2)
  end

  altar_cx = Graphics.width / 2
  altar_cy = 232

  # 0) Fond plein écran du Toit de la Montagne Enneigée
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

  # 1) Affichage du Nid Enneigé (sauf si déjà dessiné sur la carte avec un événement Œuf)
  altar_sprite = nil
  if !egg_event
    altar_sprite = Sprite.new(vp)
    altar_sprite.bitmap = Bitmap.new("Graphics/Pictures/Autel_Anivia_Vide")
    altar_sprite.ox = altar_sprite.bitmap.width / 2
    altar_sprite.oy = altar_sprite.bitmap.height / 2
    altar_sprite.x = altar_cx
    altar_sprite.y = altar_cy
    altar_sprite.z = 100
  else
    altar_cx = egg_event.screen_x
    altar_cy = egg_event.screen_y - 16
  end

  # 2) Affichage de l'Œuf d'Anivia animé (!Oeuf_Anivia.png) posé dans la neige
  egg_actor = NoxusCutsceneActor.new(vp, "!Oeuf_Anivia", altar_cx, altar_cy + 34, 2, 150)
  egg_event.transparent = true if egg_event

  # 3) Arrivée et marche animée du Commandant Valerius et de ses 2 soldats dans la neige !
  valerius = NoxusCutsceneActor.new(vp, "trainer_ROCKETBOSS", altar_cx, 90, 2, 300)
  soldat_g = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_M", altar_cx - 68, 70, 2, 290)
  soldat_d = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_F", altar_cx + 68, 70, 2, 290)

  45.times do |i|
    t = (i + 1).to_f / 45
    valerius.y = 90 + (altar_cy - 28 - 90) * t
    soldat_g.y = 70 + (altar_cy + 12 - 70) * t
    soldat_d.y = 70 + (altar_cy + 12 - 70) * t
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

  # Dialogues des personnages sur le sommet enneigé (la neige continue de tomber !)
  valerius.jump_in_place(10, 12)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Enfin... Nous avons atteint le toit de la montagne sacrée de Freljord. L'Œuf d'Anivia est entre nos mains !"))

  soldat_g.jump_in_place(8, 10)
  pbMessage(_INTL("\\bSoldat de Noxus :\\b Commandant ! L'Œuf d'Anivia est juste devant nous au milieu des pics de glace. Les balises sont verrouillées !"))

  valerius.jump_in_place(10, 12)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Parfait ! Faites approcher le Dirigeable et descendez le treuil pour arracher l'Œuf de son nid !"))

  # 4) Le Dirigeable arrive dans le ciel étoilé au-dessus des montagnes (y = -18)
  target_ship_x = altar_cx - 128
  pbDirigeableNoxus_Arrivee(target_ship_x, -18, 65, egg_actor)

  # 5) Le grappin descend jusqu'à l'Œuf (y = 232), l'Œuf quitte son nid enneigé
  #    -> LA VRAIE TEMPÊTE DE NEIGE (BLIZZARD) SE DÉCLENCHE IMMÉDIATEMENT !
  pbDirigeableNoxus_CaptureOeuf(egg_event, egg_actor, [valerius, soldat_g, soldat_d], altar_cx, altar_cy)

  pbMessage(_INTL("\\bCommandant Valerius :\\b Ahahaha ! L'Œuf du Cryophénix est à nous ! Peu importe cette tempête de neige qui se lève, en route vers Port-Brumeux !"))
  pbMessage(_INTL("Un cri glacial déchire soudain le blizzard de Freljord ! Une tempête d'éclairs s'abat sur le dirigeable !"))

  # 6) Éclair, explosion de l'hélice arrière & fuite du Dirigeable dans le blizzard
  pbDirigeableNoxus_ExplosionEtFuite(70, false)

  pbMessage(_INTL("L'Œuf d'Anivia a été emporté par le Dirigeable de Noxus au cœur de la tempête... Mais son hélice arrière a explosé vers la Caverne de l'Épreuve !"))

  # 7) TRANSITION DOUCE VERS LE DÉBUT CLASSIQUE POKÉMON (Réveil dans la chambre)
  fade_sprite = Sprite.new(vp)
  fade_bmp = Bitmap.new(Graphics.width, Graphics.height)
  fade_bmp.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 255))
  fade_sprite.bitmap = fade_bmp
  fade_sprite.z = 900
  fade_sprite.opacity = 0

  # Fondu au noir sur le sommet en pleine tempête
  25.times do |i|
    fade_sprite.opacity = ((i + 1) * 255.0 / 25).round
    pbUpdateSceneForCinematic(1)
  end

  # Pendant que l'écran est noir, on coupe la tempête et on retire le décor de la montagne
  if $game_temp.noxus_snowstorm && !$game_temp.noxus_snowstorm.disposed?
    $game_temp.noxus_snowstorm.dispose
  end
  $game_temp.noxus_snowstorm = nil

  if bg_sprite && !bg_sprite.disposed?
    bg_sprite.bitmap.dispose if bg_sprite.bitmap
    bg_sprite.dispose
  end
  if altar_sprite && !altar_sprite.disposed?
    altar_sprite.bitmap.dispose if altar_sprite.bitmap
    altar_sprite.dispose
  end
  egg_actor.dispose
  [valerius, soldat_g, soldat_d].each { |act| act.dispose }
  $game_player.transparent = old_transparent if $game_player

  $game_player.turn_down if $game_player
  pbSEPlay("Battle damage normal", 80, 70) rescue nil
  pbMessage(_INTL("Au même moment, en contrebas de la montagne...\\nLe grondement lointain de l'explosion et de la tempête résonne jusque dans ta chambre !"))

  # Ouverture du fondu sur la chambre du joueur (003: \PN's house)
  25.times do |i|
    fade_sprite.opacity = (255.0 * (1.0 - (i + 1) / 25.0)).round
    pbUpdateSceneForCinematic(1)
  end

  fade_bmp.dispose
  fade_sprite.dispose
  pbDisposeNoxusDirigeableSprite

  # Petit [!] sur la tête du joueur qui se réveille dans sa chambre, prêt à jouer !
  if $scene && $scene.respond_to?(:spriteset) && $scene.spriteset && $game_player
    $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 1) rescue nil
  end
  pbSEPlay("Exclamation", 85, 100) rescue nil
  pbUpdateSceneForCinematic(15)
end

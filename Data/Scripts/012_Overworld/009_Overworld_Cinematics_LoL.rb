#===============================================================================
# Cinématiques Overworld — Acte 1 (Freljord & Dirigeable de Noxus)
#===============================================================================
# Fichier : Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb
# Ajouté par : Antigravity
#
# UTILISATION (au lancement d'une Nouvelle Partie dans Quick start intro / Intro
# ou dans n'importe quel événement avec "Script...") :
#
#   pbCinematiqueDirigeableNoxus
#
# Tout s'affiche et s'anime automatiquement sans aucune interaction requise :
# 1. Le Sanctuaire d'Anivia, le socle et l'Œuf animé (!Oeuf_Anivia) apparaissent
#    en bas de l'écran (y = 232, juste au-dessus de la boîte de dialogue).
# 2. Le Commandant Valerius et ses 2 soldats de Noxus marchent jusqu'à l'Œuf,
#    l'encerclent et parlent.
# 3. Le Dirigeable de Noxus arrive dans le ciel en haut de l'écran (y = -18),
#    laissant un grand espace visible entre la coque du bateau (y = 148) et
#    l'Œuf sur son socle (y = 232).
# 4. Le grappin descend de y = 148 jusqu'à l'Œuf (y = 232), l'Œuf quitte
#    concrètement son socle (qui devient VIDE à y = 232) et remonte dans les
#    airs de y = 232 jusqu'à y = 154 sous le bateau du Dirigeable !
# 5. L'éclair frappe l'hélice arrière et le Dirigeable s'enfuit vers la droite
#    en emportant l'Œuf, tandis que le socle vide reste au sol.
#===============================================================================

class Game_Temp
  attr_accessor :noxus_dirigeable_sprite
  attr_accessor :noxus_dirigeable_viewport
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

# Supprime proprement le sprite du Dirigeable à la fin de la cinématique
def pbDisposeNoxusDirigeableSprite
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
# ÉTAPE 2 : Le grappin descend de la coque du bateau (y = 148) jusqu'au socle
#           de l'Œuf (y = 242), l'Œuf disparaît de sa position initiale (le
#           socle devient VIDE !) et monte concrètement de y = 242 à y = 152 !
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

  # -> L'ŒUF QUITTE CONCRÈTEMENT SA POSITION INITIALE SUR LE SOCLE :
  if egg_event
    $game_self_switches[[$game_map.map_id, egg_event.id, "A"]] = true
    $game_map.need_refresh = true
    $game_map.refresh
  end
  # On cache l'Œuf posé sur le socle : l'Autel Vide en dessous apparaît immédiatement !
  egg_actor.visible = false if egg_actor

  # 3) L'Œuf saisi par le grappin part de sa position initiale sur le socle (y = 232)
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
def pbDirigeableNoxus_ExplosionEtFuite(duration_frames = 70)
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

  pbDisposeNoxusDirigeableSprite
end

#-------------------------------------------------------------------------------
# CINÉMATIQUE COMPLÈTE AUTOMATIQUE (Fonctionne dès "Nouvelle Partie" sans interaction)
#-------------------------------------------------------------------------------
def pbCinematiqueDirigeableNoxus(explicit_egg_event_id = nil)
  vp = pbGetNoxusCinematicViewport
  egg_event = pbFindAniviaEggEvent(explicit_egg_event_id)

  $game_player.turn_up if $game_player
  pbUpdateSceneForCinematic(4)

  # Position idéale à l'écran (512x384) :
  # - Le Dirigeable est en haut (y = -18 -> bas de la coque à y = 146)
  # - L'Autel et l'Œuf (!Oeuf_Anivia) sont en bas au centre (x = 256, y = 232),
  #   bien EN DESSOUS du Dirigeable et AU-DESSUS de la boîte de dialogue (y = 288) !
  altar_cx = Graphics.width / 2
  altar_cy = 232

  # 1) Affichage du Socle de l'Autel (Autel_Anivia_Vide) à la position initiale (y = 232)
  altar_sprite = Sprite.new(vp)
  altar_sprite.bitmap = Bitmap.new("Graphics/Pictures/Autel_Anivia_Vide")
  altar_sprite.ox = altar_sprite.bitmap.width / 2
  altar_sprite.oy = altar_sprite.bitmap.height / 2
  altar_sprite.x = altar_cx
  altar_sprite.y = altar_cy
  altar_sprite.z = 100

  # 2) Affichage de l'Œuf d'Anivia animé (!Oeuf_Anivia.png) posé SUR le socle (y = 264)
  egg_actor = NoxusCutsceneActor.new(vp, "!Oeuf_Anivia", altar_cx, altar_cy + 34, 2, 150)

  # 3) Arrivée et marche animée du Commandant Valerius et de ses 2 soldats vers l'Œuf !
  valerius = NoxusCutsceneActor.new(vp, "trainer_ROCKETBOSS", altar_cx, 90, 2, 300)
  soldat_g = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_M", altar_cx - 68, 70, 2, 290)
  soldat_d = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_F", altar_cx + 68, 70, 2, 290)

  if $scene && $scene.respond_to?(:spriteset) && $scene.spriteset && $game_player
    $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 1) rescue nil
  end
  pbSEPlay("Exclamation", 85, 100) rescue nil

  # Les 3 personnages marchent pas à pas jusqu'au socle de l'Œuf d'Anivia
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

  # Ils s'arrêtent autour de l'Œuf : les soldats regardent l'Œuf, Valerius regarde en bas
  valerius.turn(2)
  soldat_g.turn(6) # Regarde vers l'Œuf (droite)
  soldat_d.turn(4) # Regarde vers l'Œuf (gauche)
  pbUpdateSceneForCinematic(12)

  # Dialogues des personnages devant l'Œuf
  valerius.jump_in_place(10, 12)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Trop tard, enfant de Freljord ! Les gardiens du Sanctuaire ont baissé leur garde."))

  soldat_g.jump_in_place(8, 10)
  pbMessage(_INTL("\\bSoldat de Noxus :\\b Commandant ! L'Œuf d'Anivia est juste devant nous sur son socle de givre. Les balises sont verrouillées !"))

  valerius.jump_in_place(10, 12)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Parfait ! Faites approcher le Dirigeable et descendez le treuil pour arracher l'Œuf de son autel !"))

  # 4) Le Dirigeable arrive en haut de l'écran (y = -18), laissant l'Autel et l'Œuf
  #    parfaitement visibles en bas (y = 232) !
  target_ship_x = altar_cx - 128
  pbDirigeableNoxus_Arrivee(target_ship_x, -18, 65, egg_actor)

  # 5) Le grappin descend jusqu'à l'Œuf (y = 232), l'Œuf quitte sa position initiale
  #    (le socle à y = 232 devient VIDE !) et l'Œuf monte jusqu'au Dirigeable (y = 152) !
  pbDirigeableNoxus_CaptureOeuf(egg_event, egg_actor, [valerius, soldat_g, soldat_d], altar_cx, altar_cy)

  pbMessage(_INTL("\\bCommandant Valerius :\\b Ahahaha ! L'Œuf du Cryophénix a quitté son socle, il est à nous ! En route vers Port-Brumeux !"))
  pbMessage(_INTL("Un cri glacial déchire soudain les cieux de Freljord ! Une tempête d'éclairs s'abat sur le dirigeable !"))

  # 6) Éclair, explosion de l'hélice arrière & fuite du Dirigeable avec l'Œuf
  #    pendant que le socle VIDE reste bien visible en bas !
  pbDirigeableNoxus_ExplosionEtFuite(70)

  pbMessage(_INTL("L'Œuf d'Anivia a été emporté par le Dirigeable de Noxus, ne laissant derrière lui que l'autel vide... Mais son hélice arrière a explosé vers la Caverne de l'Épreuve !"))

  altar_sprite.bitmap.dispose if altar_sprite.bitmap
  altar_sprite.dispose
  egg_actor.dispose
  [valerius, soldat_g, soldat_d].each { |act| act.dispose }
end

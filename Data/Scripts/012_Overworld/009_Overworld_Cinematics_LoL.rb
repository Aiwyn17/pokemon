#===============================================================================
# Cinématiques Overworld — Acte 1 (Freljord & Dirigeable de Noxus)
#===============================================================================
# Fichier : Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb
# Ajouté par : Antigravity
#
# UTILISATION DANS UN ÉVÉNEMENT RPG MAKER XP (Commande "Script...") :
#
#   pbCinematiqueDirigeableNoxus
#
# Optionnel : Si tu as posé un événement pour l'Œuf sur ta carte (avec l'image
# !Oeuf_Anivia.png), le script le détecte automatiquement (ou tu peux écrire
# pbCinematiqueDirigeableNoxus(ID_DE_TON_EVENEMENT_OEUF)) et active son
# Interrupteur Local A ("A" = ON) au moment précis où le grappin soulève l'Œuf !
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
# Acteur animé (PNJ de cinématique utilisant une planche 4x4 Graphics/Characters)
# Permet de faire marcher/tourner/sauter Valerius et ses soldats sur la carte !
#-------------------------------------------------------------------------------
class NoxusCutsceneActor
  attr_reader :sprite

  # dir : 2 = Bas, 4 = Gauche, 6 = Droite, 8 = Haut
  def initialize(viewport, char_name, x, y, dir = 2, z = 200)
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

  def x; @x; end
  def y; @y; end

  def move_to(target_x, target_y, frames, dir = nil)
    if dir
      @dir = dir
    else
      dx = target_x - @x
      dy = target_y - @y
      if dx.abs > dy.abs
        @dir = (dx > 0) ? 6 : 4
      else
        @dir = (dy > 0) ? 2 : 8
      end
    end
    start_x = @x
    start_y = @y
    frames.times do |i|
      t = (i + 1).to_f / frames
      @x = start_x + (target_x - start_x) * t
      @y = start_y + (target_y - start_y) * t
      @anim_count += 1
      @pattern = (@anim_count / 5) % 4
      refresh_rect
      update_position
      pbUpdateSceneForCinematic(1)
    end
    @pattern = 0
    refresh_rect
    update_position
  end

  def jump_in_place(height = 12, frames = 14)
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

  def opacity=(val)
    @sprite.opacity = val if @sprite && !@sprite.disposed?
  end

  def dispose
    if @sprite && !@sprite.disposed?
      @sprite.dispose
    end
    if @bitmap && !@bitmap.disposed?
      @bitmap.dispose
    end
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

# Cherche automatiquement l'événement de l'Œuf sur la carte si aucun ID n'est fourni
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
# ÉTAPE 1 : Arrivée nocturne du Dirigeable de Noxus au-dessus du Sanctuaire
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_Arrivee(target_x = nil, target_y = 4, duration_frames = 65)
  spr = pbGetNoxusDirigeableSprite
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_1_Vol")
  target_x = (Graphics.width - spr.bitmap.width) / 2 if target_x.nil?

  start_x = -spr.bitmap.width - 20
  start_y = -36
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
    pbUpdateSceneForCinematic(1)
  end

  pbDirigeableNoxus_Flottement(1)
end

#-------------------------------------------------------------------------------
# Flottement sur place du Dirigeable (oscillation douce haut/bas)
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_Flottement(cycles = 2)
  spr = $game_temp.noxus_dirigeable_sprite
  return if !spr || spr.disposed?
  base_y = spr.y
  total_frames = cycles * 36
  total_frames.times do |i|
    spr.y = base_y + (Math.sin(i * 0.17) * 3.0).round
    pbUpdateSceneForCinematic(1)
  end
  spr.y = base_y
end

#-------------------------------------------------------------------------------
# ÉTAPE 2 : Le grappin descend jusqu'à l'Œuf, l'Œuf quitte sa position initiale
#           (le socle devient vide !) et monte concrètement vers le Dirigeable !
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_CaptureOeuf(egg_event = nil, ground_egg_sprite = nil, actors_to_board = [])
  vp = pbGetNoxusCinematicViewport
  spr = pbGetNoxusDirigeableSprite

  # Coordonnées initiales de l'Œuf sur la carte (en pixels à l'écran)
  if egg_event
    egg_screen_x = egg_event.screen_x
    egg_screen_y = egg_event.screen_y - 40
  elsif ground_egg_sprite && !ground_egg_sprite.disposed?
    egg_screen_x = ground_egg_sprite.x + ground_egg_sprite.bitmap.width / 2
    egg_screen_y = ground_egg_sprite.y + ground_egg_sprite.bitmap.height / 2
  else
    egg_screen_x = Graphics.width / 2
    egg_screen_y = Graphics.height / 2 + 24
  end

  # Position de la coque du Dirigeable où l'Œuf va être hissé
  ship_belly_x = spr.x + (spr.bitmap.width / 2)
  ship_belly_y = spr.y + 158

  # 1) Descente du câble/grappin depuis le Dirigeable jusqu'à l'Œuf sur son socle
  cable_sprite = Sprite.new(vp)
  cable_sprite.z = 450
  cable_bmp = Bitmap.new(64, 240)
  cable_bmp.fill_rect(22, 0, 3, 220, Color.new(212, 168, 70))
  cable_bmp.fill_rect(39, 0, 3, 220, Color.new(212, 168, 70))
  cable_bmp.fill_rect(31, 0, 2, 220, Color.new(175, 32, 40))
  cable_bmp.fill_rect(14, 216, 36, 4, Color.new(175, 32, 40))
  cable_sprite.bitmap = cable_bmp
  cable_sprite.ox = 32

  pbSEPlay("Battle Throw", 80, 75) rescue nil
  descent_frames = 35
  start_cable_y = ship_belly_y - 220
  end_cable_y   = egg_screen_y - 210
  descent_frames.times do |i|
    t = (i + 1).to_f / descent_frames
    cable_sprite.x = (ship_belly_x + (egg_screen_x - ship_belly_x) * t).round
    cable_sprite.y = (start_cable_y + (end_cable_y - start_cable_y) * t).round
    # On coupe ce qui dépasse au-dessus de la coque du bateau
    pbUpdateSceneForCinematic(1)
  end

  # 2) Le grappin saisit l'Œuf sur le socle !
  pbSEPlay("Battle catch click", 95, 80) rescue nil
  $game_screen.start_flash(Color.new(120, 235, 255, 210), 12)
  $game_screen.start_shake(5, 6, 16)

  # -> L'ŒUF QUITTE SA POSITION INITIALE SUR LE SOCLE :
  # Si c'est un événement sur la carte, on active son Interrupteur Local A (le socle devient vide !)
  if egg_event
    $game_self_switches[[$game_map.map_id, egg_event.id, "A"]] = true
    $game_map.need_refresh = true
    $game_map.refresh
  end
  # Si c'est le sprite d'Œuf posé au sol par la cinématique, on le cache (le socle en dessous reste vide !)
  if ground_egg_sprite && !ground_egg_sprite.disposed?
    ground_egg_sprite.visible = false
  end
  cable_sprite.dispose
  cable_bmp.dispose

  # 3) On crée le sprite de l'Œuf saisi par le grappin AUX COORDONNÉES EXACTES DU SOCLE
  #    et on le fait MONTER pixel par pixel jusqu'au Dirigeable !
  lift_sprite = Sprite.new(vp)
  lift_sprite.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Grappin_Oeuf")
  lift_sprite.ox = lift_sprite.bitmap.width / 2
  lift_sprite.oy = lift_sprite.bitmap.height / 2
  lift_sprite.z = 480

  start_lift_x = egg_screen_x
  start_lift_y = egg_screen_y - 12
  end_lift_x   = ship_belly_x
  end_lift_y   = spr.y + 182

  lift_frames = 65
  pbSEPlay("Mining reveal", 85, 70) rescue nil
  lift_frames.times do |i|
    t = (i + 1).to_f / lift_frames
    ease = t * t * (3.0 - 2.0 * t) # Smoothstep
    lift_sprite.x = (start_lift_x + (end_lift_x - start_lift_x) * ease).round
    lift_sprite.y = (start_lift_y + (end_lift_y - start_lift_y) * ease).round
    spr.y = 4 + (Math.sin(i * 0.18) * 3.0).round

    # Les commandants/soldats noxiens embarquent dans le dirigeable pendant la montée
    actors_to_board.each do |actor|
      next if !actor || !actor.sprite || actor.sprite.disposed?
      actor.sprite.y -= 2 if i > 15
      actor.opacity = (255 * (1.0 - ((i - 15).to_f / 40.0))).clamp(0, 255).round if i > 15
    end

    pbUpdateSceneForCinematic(1)
  end

  # 4) L'Œuf est maintenant verrouillé sous la coque du Dirigeable (Dirigeable_Noxus_2_Capture)
  lift_sprite.bitmap.dispose if lift_sprite.bitmap
  lift_sprite.dispose

  spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_2_Capture")
  pbSEPlay("Battle catch click", 90, 100) rescue nil

  pbDirigeableNoxus_Flottement(1)
end

#-------------------------------------------------------------------------------
# ÉTAPE 3 : Éclair du Sanctuaire, Explosion de l'hélice arrière & Fuite
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_ExplosionEtFuite(duration_frames = 65)
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
    spr.y = base_y - (t * 24).round + (Math.sin(i * 0.3) * 5.0).round
    pbUpdateSceneForCinematic(1)
  end

  pbDisposeNoxusDirigeableSprite
end

#-------------------------------------------------------------------------------
# CINÉMATIQUE COMPLÈTE AVEC DÉPLACEMENT DES PERSONNAGES & VOL CONCRET DE L'ŒUF
#-------------------------------------------------------------------------------
def pbCinematiqueDirigeableNoxus(explicit_egg_event_id = nil)
  vp = pbGetNoxusCinematicViewport
  egg_event = pbFindAniviaEggEvent(explicit_egg_event_id)

  # Le joueur se tourne vers le haut (vers l'autel / la scène)
  $game_player.turn_up
  pbUpdateSceneForCinematic(5)

  altar_sprite = nil
  ground_egg_sprite = nil

  # Coordonnées du socle de l'Œuf à l'écran
  if egg_event
    altar_cx = egg_event.screen_x
    altar_cy = egg_event.screen_y - 16
  else
    # Si aucun événement Œuf n'est posé sur la carte, on affiche l'Autel et l'Œuf
    # directement devant le joueur pour qu'on voie concrètement l'Œuf partir de son socle !
    altar_cx = $game_player.screen_x
    altar_cy = [$game_player.screen_y - 96, 130].max

    altar_sprite = Sprite.new(vp)
    altar_sprite.bitmap = Bitmap.new("Graphics/Pictures/Autel_Anivia_Vide")
    altar_sprite.ox = altar_sprite.bitmap.width / 2
    altar_sprite.oy = altar_sprite.bitmap.height / 2
    altar_sprite.x = altar_cx
    altar_sprite.y = altar_cy
    altar_sprite.z = 100

    ground_egg_sprite = Sprite.new(vp)
    ground_egg_sprite.bitmap = Bitmap.new("Graphics/Pictures/Oeuf_Anivia_Seul")
    ground_egg_sprite.x = altar_cx - ground_egg_sprite.bitmap.width / 2
    ground_egg_sprite.y = altar_cy - ground_egg_sprite.bitmap.height / 2 - 6
    ground_egg_sprite.z = 120
  end

  # 1) Création et déplacement des personnages de Noxus vers l'Œuf d'Anivia !
  # Commandant Valerius (centre) + 2 Soldats de Noxus (gauche et droite)
  valerius = NoxusCutsceneActor.new(vp, "trainer_ROCKETBOSS", altar_cx, -20, 2, 300)
  soldat_g = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_M", altar_cx - 56, -40, 2, 290)
  soldat_d = NoxusCutsceneActor.new(vp, "trainer_TEAMROCKET_F", altar_cx + 56, -40, 2, 290)

  # Point d'exclamation sur le joueur quand il aperçoit l'escouade de Noxus
  if $scene && $scene.respond_to?(:spriteset) && $scene.spriteset
    $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 1) rescue nil
  end
  pbSEPlay("Exclamation", 85, 100) rescue nil

  # Les 3 personnages de Noxus marchent concrètement jusqu'à l'Œuf d'Anivia !
  40.times do |i|
    t = (i + 1).to_f / 40
    valerius.sprite.x = altar_cx
    valerius.sprite.y = (-20 + (altar_cy + 36 - (-20)) * t).round
    soldat_g.sprite.x = altar_cx - 56
    soldat_g.sprite.y = (-40 + (altar_cy + 14 - (-40)) * t).round
    soldat_d.sprite.x = altar_cx + 56
    soldat_d.sprite.y = (-40 + (altar_cy + 14 - (-40)) * t).round
    frame_col = (i / 5) % 4
    [valerius, soldat_g, soldat_d].each do |act|
      act.sprite.src_rect.x = frame_col * (act.sprite.bitmap.width / 4)
    end
    pbUpdateSceneForCinematic(1)
  end
  [valerius, soldat_g, soldat_d].each { |act| act.turn(2) }

  # Les deux soldats encerclent l'Œuf (se tournent vers l'Œuf au centre)
  soldat_g.turn(6) # Regarde à droite (vers l'Œuf)
  soldat_d.turn(4) # Regarde à gauche (vers l'Œuf)
  valerius.turn(8) # Valerius regarde d'abord l'Œuf d'Anivia
  pbUpdateSceneForCinematic(15)

  # Valerius se retourne vers le joueur et parle !
  valerius.turn(2)
  valerius.jump_in_place(10, 12)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Trop tard, enfant de Freljord ! Les gardiens du Sanctuaire ont baissé leur garde."))

  soldat_g.jump_in_place(8, 10)
  pbMessage(_INTL("\\bSoldat de Noxus :\\b Commandant Valerius ! L'Œuf d'Anivia est juste devant nous sur son socle de givre. Les balises sont verrouillées !"))

  valerius.turn(8) # Se tourne vers l'Œuf
  pbUpdateSceneForCinematic(10)
  pbMessage(_INTL("\\bCommandant Valerius :\\b Parfait ! Faites approcher le Dirigeable et descendez le treuil pour arracher l'Œuf de son autel !"))

  # 2) Arrivée du Dirigeable de Noxus juste au-dessus du socle de l'Œuf
  target_ship_x = altar_cx - 128
  pbDirigeableNoxus_Arrivee(target_ship_x, 4, 65)

  # 3) Le grappin descend jusqu'au socle, l'Œuf disparaît de sa position initiale
  #    (le socle au sol devient vide !) et l'Œuf monte concrètement jusqu'au Dirigeable !
  pbDirigeableNoxus_CaptureOeuf(egg_event, ground_egg_sprite, [valerius, soldat_g, soldat_d])

  pbMessage(_INTL("\\bCommandant Valerius :\\b Ahahaha ! L'Œuf du Cryophénix a quitté son autel, il est à nous ! En route vers Port-Brumeux !"))
  pbMessage(_INTL("Un cri glacial déchire soudain les cieux de Freljord ! Une tempête d'éclairs s'abat sur le dirigeable !"))

  # 4) L'éclair frappe l'hélice arrière et le Dirigeable s'enfuit avec l'Œuf !
  #    Si l'autel temporaire a été affiché sur une carte de test, on le laisse visible pendant l'explosion puis on nettoie
  pbDirigeableNoxus_ExplosionEtFuite(65)

  if altar_sprite && !altar_sprite.disposed?
    altar_sprite.bitmap.dispose if altar_sprite.bitmap
    altar_sprite.dispose
  end
  if ground_egg_sprite && !ground_egg_sprite.disposed?
    ground_egg_sprite.bitmap.dispose if ground_egg_sprite.bitmap
    ground_egg_sprite.dispose
  end
  [valerius, soldat_g, soldat_d].each { |act| act.dispose }

  pbMessage(_INTL("L'Œuf d'Anivia a été emporté, ne laissant derrière lui que le socle brisé... Mais l'hélice arrière du dirigeable a explosé en direction de la Caverne de l'Épreuve !"))
end

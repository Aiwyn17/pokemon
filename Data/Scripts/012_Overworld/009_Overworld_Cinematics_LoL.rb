#===============================================================================
# Cinématiques Overworld — Acte 1 (Freljord & Dirigeable de Noxus)
#===============================================================================
# Fichier : Data/Scripts/012_Overworld/009_Overworld_Cinematics_LoL.rb
# Ajouté par : Antigravity
#
# UTILISATION DANS UN ÉVÉNEMENT RPG MAKER XP (Commande "Script...") :
#
# Option 1 — Jouer toute la cinématique d'un seul coup :
#   pbCinematiqueDirigeableNoxus
#
# Option 2 — Jouer étape par étape (pour intercaler tes propres textes/dialogues) :
#   pbDirigeableNoxus_Arrivee
#   # -> Tes commandes "Afficher du texte" (ex: Valerius parle)
#   pbDirigeableNoxus_CaptureOeuf
#   # -> Active ton Interrupteur Local pour changer l'Autel en Autel Pillé
#   pbDirigeableNoxus_ExplosionEtFuite
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
    $game_system.update if $game_system
    $game_screen.update if $game_screen
    $game_map.update if $game_map
    if $scene && $scene.respond_to?(:spriteset) && $scene.spriteset
      $scene.spriteset.update
    end
  end
end

# Crée ou récupère le sprite du Dirigeable de Noxus
def pbGetNoxusDirigeableSprite
  if !$game_temp.noxus_dirigeable_viewport || $game_temp.noxus_dirigeable_viewport.disposed?
    $game_temp.noxus_dirigeable_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    # Z = 250 : au-dessus de la carte et des personnages, mais SOUS les boîtes de dialogue !
    $game_temp.noxus_dirigeable_viewport.z = 250
  end
  if !$game_temp.noxus_dirigeable_sprite || $game_temp.noxus_dirigeable_sprite.disposed?
    $game_temp.noxus_dirigeable_sprite = Sprite.new($game_temp.noxus_dirigeable_viewport)
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

#-------------------------------------------------------------------------------
# ÉTAPE 1 : Arrivée nocturne du Dirigeable de Noxus au-dessus du Sanctuaire
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_Arrivee(target_x = nil, target_y = 8, duration_frames = 70)
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
    # Décélération douce (ease-out) à l'approche de l'Autel
    ease = 1.0 - (1.0 - t) * (1.0 - t)
    spr.x = (start_x + (target_x - start_x) * ease).round
    # Légère oscillation verticale (effet de flottement du ballon dans le vent)
    bobbing = (Math.sin(i * 0.15) * 4.0).round
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
  total_frames = cycles * 40
  total_frames.times do |i|
    spr.y = base_y + (Math.sin(i * 0.157) * 4.0).round
    pbUpdateSceneForCinematic(1)
  end
  spr.y = base_y
end

#-------------------------------------------------------------------------------
# ÉTAPE 2 : Abordage et Capture de l'Œuf d'Anivia avec le treuil noxien
#-------------------------------------------------------------------------------
def pbDirigeableNoxus_CaptureOeuf
  spr = pbGetNoxusDirigeableSprite
  pbSEPlay("Battle catch click", 90, 80) rescue nil
  $game_screen.start_flash(Color.new(120, 235, 255, 200), 12)
  $game_screen.start_shake(5, 6, 16)

  spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
  spr.bitmap = Bitmap.new("Graphics/Pictures/Dirigeable_Noxus_2_Capture")
  spr.x = (Graphics.width - spr.bitmap.width) / 2 if spr.x == 0

  pbDirigeableNoxus_Flottement(2)
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

  # Le dirigeable tangue sous le choc de l'explosion pendant 40 frames
  base_y = spr.y
  40.times do |i|
    spr.y = base_y + ((i % 4 < 2) ? -3 : 3)
    pbUpdateSceneForCinematic(1)
  end

  # Fuite précipitée vers la droite (en direction de Frimedor / Caverne de l'Épreuve)
  pbSEPlay("Battle damage super", 85, 75) rescue nil
  start_x = spr.x
  end_x   = Graphics.width + 40
  duration_frames.times do |i|
    t = (i + 1).to_f / duration_frames
    ease = t * t # Accélération progressive
    spr.x = (start_x + (end_x - start_x) * ease).round
    spr.y = base_y - (t * 24).round + (Math.sin(i * 0.3) * 5.0).round
    pbUpdateSceneForCinematic(1)
  end

  pbDisposeNoxusDirigeableSprite
end

#-------------------------------------------------------------------------------
# CINÉMATIQUE COMPLÈTE CLÉ EN MAIN (en 1 seule ligne : pbCinematiqueDirigeableNoxus)
#-------------------------------------------------------------------------------
def pbCinematiqueDirigeableNoxus
  pbDirigeableNoxus_Arrivee
  pbMessage(_INTL("\\bCommandant Valerius :\\b Parfait ! Les gardiens du Sanctuaire ont baissé leur garde. Abaissez le treuil et emparez-vous de l'Œuf d'Anivia !"))
  pbDirigeableNoxus_CaptureOeuf
  pbMessage(_INTL("\\bCommandant Valerius :\\b La relique cryophénix est à nous ! Direction Port-Brumeux !"))
  pbMessage(_INTL("Un cri glacial déchire soudain les cieux de Freljord ! Une tempête d'éclairs s'abat sur le dirigeable !"))
  pbDirigeableNoxus_ExplosionEtFuite
  pbMessage(_INTL("L'hélice arrière du dirigeable noxien a explosé ! Un réacteur en flammes vient de s'écraser vers la Caverne de l'Épreuve !"))
end

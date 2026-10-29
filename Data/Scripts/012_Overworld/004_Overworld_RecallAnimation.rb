#===============================================================================
# League of Legends Recall / Teleport Animation
#===============================================================================
def pbLoLRecallAnimation
  pbMessage(_INTL("Commencing Recall..."))
  pbSEPlay("Recall", 100) # Assuming a sound effect named Recall exists or fallback

  # Flash screen cyan/blue for magic TP effect
  $game_screen.start_flash(Color.new(0, 255, 255, 128), 20)
  pbWait(2) # Wait 2 seconds (simulating 8s recall scaled down for RPG maker pacing)

  # Upward beam effect
  $game_screen.start_flash(Color.new(255, 255, 255, 255), 10)
  pbSEPlay("Teleport", 100)
end

def pbInteractWithTurret(map_id, x, y)
  if pbConfirmMessage(_INTL("Do you want to Recall to the base?"))
    pbLoLRecallAnimation

    pbFadeOutIn do
      $game_temp.player_new_map_id    = map_id
      $game_temp.player_new_x         = x
      $game_temp.player_new_y         = y
      $game_temp.player_new_direction = 2
      pbDismountBike
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    end
  end
end

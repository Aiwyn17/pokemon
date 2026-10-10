#===============================================================================
# CREDITS
# Marin (og speed up script), Phantombass (19.1 version), Mashirosakura, Golisopod User,
# D0vid (v21.1 version), Naelle & Skyflyer (Turbo Icon/Animation), DPertierra
#===============================================================================
#===============================================================================#
# Speed configuration
#===============================================================================#
SPEEDUP_STAGES = [1, 1.5, 2]
SPEEDUP_BUTTON = Input::AUX1 # Default to the 'L' button (e.g. Q on QWERTY keyboards)

$turbo_game_speed = 0
$turbo_can_toggle = true
$turbo_fake_uptime_tally = 0.0
$turbo_when_we_got_last_uptime = 0.0

def update_uptime_snapshot
  time_since_we_got_last_uptime = System.unscaled_uptime - $turbo_when_we_got_last_uptime
  $turbo_fake_uptime_tally += SPEEDUP_STAGES[$turbo_game_speed] * time_since_we_got_last_uptime
  $turbo_when_we_got_last_uptime = System.unscaled_uptime
end

def pbDisableturbo_can_toggleTurbo
  $turbo_game_speed = 0
  $turbo_can_toggle = false # This won't be saved when reloading the game from a save
end

def pbEnableturbo_can_toggleTurbo
  $turbo_game_speed = 0
  $turbo_can_toggle = true
end

module Input
  class << self
    alias_method :turbo_original_update, :update unless method_defined?(:turbo_original_update)
  end
  def self.update
    turbo_original_update
    if $turbo_can_toggle && trigger?(SPEEDUP_BUTTON)
      $turbo_game_speed += 1
      if $turbo_game_speed >= SPEEDUP_STAGES.size
        $turbo_game_speed = 0
      end
      update_uptime_snapshot
      $buttonframes = 0
    end
  end
end
#====================================================================================#
# Return System.Uptime with a multiplier to create an alternative timeline
#====================================================================================#
module System
  class << self
    alias_method :unscaled_uptime, :uptime unless method_defined?(:unscaled_uptime)
  end

  def self.real_uptime
    return unscaled_uptime
  end

  def self.uptime
    update_uptime_snapshot
    return $turbo_fake_uptime_tally
  end
end
#===============================================================================#
# Fix for scrolling fog speed
#===============================================================================#
# class Game_Map
#   unless method_defined?(:original_update)
#     alias_method :original_update, :update
#   end

#   def update
#     temp_timer = @fog_scroll_last_update_timer
#     @fog_scroll_last_update_timer = System.uptime # Don't scroll in the original update method
#     original_update
#     @fog_scroll_last_update_timer = temp_timer
#     update_fog
#   end

#   def update_fog
#     uptime_now = System.unscaled_uptime
#     @fog_scroll_last_update_timer =
#       uptime_now unless @fog_scroll_last_update_timer
#     speedup_mult = SPEEDUP_STAGES[$turbo_game_speed]
#     scroll_mult =
#       (uptime_now - @fog_scroll_last_update_timer) * 5 * speedup_mult
#     @fog_ox -= @fog_sx * scroll_mult
#     @fog_oy -= @fog_sy * scroll_mult
#     @fog_scroll_last_update_timer = uptime_now
#   end
# end
#===============================================================================#
# Fix for animation index crash
#===============================================================================#
# class SpriteAnimation
#   def update_animation
#     new_index =
#       (
#         (System.uptime - @_animation_timer_start) / @_animation_time_per_frame
#       ).to_i
#     if new_index >= @_animation_duration
#       dispose_animation
#       return
#     end
#     quick_update = (@_animation_index == new_index)
#     @_animation_index = new_index
#     frame_index = @_animation_index
#     current_frame = @_animation.frames[frame_index]
#     unless current_frame
#       dispose_animation
#       return
#     end
#     cell_data = current_frame.cell_data
#     position = @_animation.position
#     animation_set_sprites(
#       @_animation_sprites,
#       cell_data,
#       position,
#       quick_update
#     )
#     return if quick_update
#     @_animation.timings.each do |timing|
#       next if timing.frame != frame_index
#       animation_process_timing(timing, @_animation_hit)
#     end
#   end
# end

#===============================================================================#
# Show the speedup status icon
#===============================================================================#
module Graphics
  class << self
    alias _old_update_turbo update
    def update
      _old_update_turbo
      $buttonframes = 150 if !$buttonframes
      if $buttonframes < 150 # Frames en pantalla
        if !@turbo_icon || @turbo_icon.disposed?
          @turbo_icon = Sprite.new
          @turbo_icon.z = 999_999
        end
        @turbo_icon.bitmap =
          Bitmap.new("Graphics/UI/Speedup/Turbo#{$turbo_game_speed}")
        $buttonframes += 1
        @turbo_icon.dispose if $buttonframes == 150
      end
    end
  end
end

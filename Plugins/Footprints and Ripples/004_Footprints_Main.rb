#===============================================================================
# Footprints & Ripples - Main Logic & Handlers
# Compatible with Pokémon Essentials v21.1
#===============================================================================
module FootprintsManager
  @idle_ripple_timer = 0

  # Check if a character event is permitted to spawn footprints
  def self.can_leave_footprints?(event)
    return false if !event || event.transparent || event.opacity == 0
    return false if event.jumping?

    if event.is_a?(Game_Event)
      # Check name exclusions
      return false if event.name[/\[NoFoot\]/i] || event.name[/\/nofoot\//i]
      # Distinguish follower from generic NPC
      if event.is_a?(Game_Follower)
        return FootprintsSettings::ENABLE_FOLLOWER_FOOTPRINTS
      else
        return FootprintsSettings::ENABLE_NPC_FOOTPRINTS
      end
    end

    # Player is always enabled
    return true
  end

  # Process step event
  def self.on_step_taken(event)
    return if !$scene.is_a?(Scene_Map)
    return if !can_leave_footprints?(event)

    map = event.map
    return if !map
    tag = event.terrain_tag

    # Determine terrain category
    is_sand = tag.id == :Sand || tag.battle_environment == :Sand || FootprintsSettings::SAND_TERRAINS.include?(tag.id)
    is_snow = tag.id == :Ice || tag.ice || FootprintsSettings::SNOW_TERRAINS.include?(tag.id)
    is_water = tag.id == :Puddle || tag.id == :StillWater || tag.id == :Water || FootprintsSettings::WATER_TERRAINS.include?(tag.id)

    # Footprints (Sand or Snow)
    if is_sand || is_snow
      # Alternating feet: 0 = Left foot, 1 = Right foot
      foot = event.instance_variable_get(:@fp_step_foot) || 0
      event.instance_variable_set(:@fp_step_foot, (foot == 0) ? 1 : 0)

      # Check for bicycle
      is_bike = (event == $game_player && $PokemonGlobal&.bicycle && FootprintsSettings::ENABLE_BIKE_TRACKS)
      type = is_bike ? :bike : (is_snow ? :snow : :sand)

      spriteset = $scene.spriteset(map.map_id)
      if spriteset
        fp = Sprite_Footprint.new(Spriteset_Map.viewport, map, event.x, event.y, event.direction, foot, type)
        spriteset.addUserSprite(fp)
      end
    elsif is_water
      # Water ripples
      return if $PokemonGlobal&.diving
      spriteset = $scene.spriteset(map.map_id)
      if spriteset
        rip = Sprite_WaterRipple.new(Spriteset_Map.viewport, map, event.x, event.y)
        spriteset.addUserSprite(rip)
      end
    end
  end

  # Update idle ripples for player standing still in water
  def self.update_idle_ripples
    return if FootprintsSettings::IDLE_RIPPLE_INTERVAL <= 0
    return if !$scene.is_a?(Scene_Map)
    return if !$game_player || $game_player.moving? || $game_player.jumping?
    return if $PokemonGlobal&.diving

    tag = $game_player.terrain_tag
    is_water = tag.id == :Puddle || tag.id == :StillWater || tag.id == :Water || FootprintsSettings::WATER_TERRAINS.include?(tag.id)
    return if !is_water

    @idle_ripple_timer += 1
    if @idle_ripple_timer >= FootprintsSettings::IDLE_RIPPLE_INTERVAL
      @idle_ripple_timer = 0
      map = $game_player.map
      spriteset = $scene.spriteset(map.map_id)
      if spriteset
        rip = Sprite_WaterRipple.new(Spriteset_Map.viewport, map, $game_player.x, $game_player.y)
        spriteset.addUserSprite(rip)
      end
    end
  end

  def self.reset_idle_timer
    @idle_ripple_timer = 0
  end
end

# Hook step event in Essentials v21.1
EventHandlers.add(:on_step_taken, :footprints_and_ripples,
  proc { |event|
    FootprintsManager.reset_idle_timer if event == $game_player
    FootprintsManager.on_step_taken(event)
  }
)

# Hook Scene_Map update for idle ripples
class Scene_Map
  alias _fp_ripples_update update unless method_defined?(:_fp_ripples_update)
  def update
    _fp_ripples_update
    FootprintsManager.update_idle_ripples
  end
end

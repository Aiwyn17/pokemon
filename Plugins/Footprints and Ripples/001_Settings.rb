#===============================================================================
# Footprints & Ripples - Configuration
# Compatible with Pokémon Essentials v21.1
#===============================================================================
module FootprintsSettings
  # Duration in game frames a footprint remains visible before fading out
  # (40 frames ~= 1 second). Default: 100 frames (~2.5 seconds).
  FOOTPRINT_DURATION = 100

  # Initial opacity of footprints when placed (0 to 255).
  FOOTPRINT_INITIAL_OPACITY = 220

  # Whether bicycle riding on sand/snow leaves tire tracks.
  ENABLE_BIKE_TRACKS = true

  # Whether following Pokémon and partner trainers leave footprints.
  ENABLE_FOLLOWER_FOOTPRINTS = true

  # Whether NPC map events leave footprints.
  # (Any event with "[NoFoot]" or "/nofoot/" in its name is always ignored).
  ENABLE_NPC_FOOTPRINTS = true

  # Number of frames each animation stage of water ripple lasts.
  # (5 stages * 4 frames = 20 frames total animation).
  RIPPLE_FRAME_DELAY = 4

  # Initial opacity of water ripple (0 to 255).
  RIPPLE_INITIAL_OPACITY = 240

  # Interval in frames between idle ripples when standing still in water/puddle.
  # Set to 0 to disable idle ripples. Default: 50 frames (~1.25 seconds).
  IDLE_RIPPLE_INTERVAL = 50

  # Terrain tag symbols considered sand (leave sand footprints).
  SAND_TERRAINS = [:Sand]

  # Terrain tag symbols considered snow/ice (leave snow footprints).
  SNOW_TERRAINS = [:Ice]

  # Terrain tag symbols considered water (leave water ripples).
  WATER_TERRAINS = [:Puddle, :StillWater, :Water, :DeepWater]
end

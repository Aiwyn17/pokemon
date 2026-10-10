#===============================================================================
# Footprints & Ripples - Water Ripple Sprite
# Compatible with Pokémon Essentials v21.1
#===============================================================================
class Sprite_WaterRipple < Sprite
  attr_reader :tile_x, :tile_y, :map_id

  @bitmap_cache = nil

  def self.get_bitmap
    if !@bitmap_cache || @bitmap_cache.disposed?
      @bitmap_cache = AnimatedBitmap.new("Graphics/Characters/water_ripple").bitmap
      RPG::Cache.retain("Graphics/Characters/water_ripple")
    end
    return @bitmap_cache
  end

  def initialize(viewport, map, tile_x, tile_y)
    super(viewport)
    @map = map
    @map_id = map.map_id
    @tile_x = tile_x
    @tile_y = tile_y
    @frame = 0
    @frame_timer = FootprintsSettings::RIPPLE_FRAME_DELAY
    @total_frames = 5

    self.bitmap = Sprite_WaterRipple.get_bitmap
    self.src_rect.set(0, 0, 64, 64)
    self.ox = 32
    self.oy = 32
    self.z = 2
    self.opacity = FootprintsSettings::RIPPLE_INITIAL_OPACITY
    pbDayNightTint(self)
    update_coords
  end

  def update_coords
    return if !@map
    # Center of 32x32 tile is +16 X, and +20 Y (where character feet make contact)
    tile_screen_x = ((@tile_x * Game_Map::REAL_RES_X - @map.display_x).to_f / Game_Map::X_SUBPIXELS).round + (Game_Map::TILE_WIDTH / 2)
    tile_screen_y = ((@tile_y * Game_Map::REAL_RES_Y - @map.display_y).to_f / Game_Map::Y_SUBPIXELS).round + (Game_Map::TILE_HEIGHT * 5 / 8)

    if defined?(TilemapRenderer::ZOOM_X) && TilemapRenderer::ZOOM_X != 1
      tile_screen_x = ((tile_screen_x - (Graphics.width / 2.0)) * TilemapRenderer::ZOOM_X) + (Graphics.width / 2.0)
      self.zoom_x = TilemapRenderer::ZOOM_X
    end
    if defined?(TilemapRenderer::ZOOM_Y) && TilemapRenderer::ZOOM_Y != 1
      tile_screen_y = ((tile_screen_y - (Graphics.height / 2.0)) * TilemapRenderer::ZOOM_Y) + (Graphics.height / 2.0)
      self.zoom_y = TilemapRenderer::ZOOM_Y
    end

    self.x = tile_screen_x
    self.y = tile_screen_y
  end

  def update
    return if disposed?
    update_coords
    @frame_timer -= 1
    if @frame_timer <= 0
      @frame += 1
      if @frame >= @total_frames
        dispose
        return
      end
      @frame_timer = FootprintsSettings::RIPPLE_FRAME_DELAY
      self.src_rect.set(@frame * 64, 0, 64, 64)
      if @frame >= 3
        self.opacity = (FootprintsSettings::RIPPLE_INITIAL_OPACITY * 0.7).round
      end
    end
  end
end

#===============================================================================
# Footprints & Ripples - Footprints Sprite
# Compatible with Pokémon Essentials v21.1
#===============================================================================
class Sprite_Footprint < Sprite
  attr_reader :tile_x, :tile_y, :map_id

  @bitmap_cache = {}

  def self.get_bitmap(filename)
    if !@bitmap_cache[filename] || @bitmap_cache[filename].disposed?
      @bitmap_cache[filename] = AnimatedBitmap.new(filename).bitmap
      RPG::Cache.retain(filename)
    end
    return @bitmap_cache[filename]
  end

  def initialize(viewport, map, tile_x, tile_y, direction, foot_col, type = :sand)
    super(viewport)
    @map = map
    @map_id = map.map_id
    @tile_x = tile_x
    @tile_y = tile_y
    @direction = direction
    @foot_col = foot_col   # 0 = left foot, 1 = right foot
    @type = type           # :sand, :snow, :bike
    @total_duration = FootprintsSettings::FOOTPRINT_DURATION
    @timer = @total_duration

    # Select bitmap file
    case @type
    when :bike
      bitmap_file = "Graphics/Characters/footprint_bike"
    when :snow
      bitmap_file = "Graphics/Characters/footprint_snow"
    else
      bitmap_file = "Graphics/Characters/footprint_sand"
    end

    self.bitmap = Sprite_Footprint.get_bitmap(bitmap_file)

    # Frame rect calculation
    # In 64x128 sheet:
    # 2 columns (32px each): Col 0 = Left foot, Col 1 = Right foot
    # 4 rows (32px each): Row 0 = Down (2), Row 1 = Left (4), Row 2 = Right (6), Row 3 = Up (8)
    if @type == :bike
      # For bicycle:
      # Vertical track: row 0 for Down/Up
      # Horizontal track: row 1 for Left/Right
      row = [2, 8].include?(@direction) ? 0 : 1
      self.src_rect.set(0, row * 32, 32, 32)
    else
      col = @foot_col.clamp(0, 1)
      row = case @direction
            when 2 then 0 # Down
            when 4 then 1 # Left
            when 6 then 2 # Right
            when 8 then 3 # Up
            else 0
            end
      self.src_rect.set(col * 32, row * 32, 32, 32)
    end

    self.ox = 0
    self.oy = 0
    self.z = 1
    self.opacity = FootprintsSettings::FOOTPRINT_INITIAL_OPACITY
    pbDayNightTint(self)
    update_coords
  end

  def update_coords
    return if !@map
    this_x = ((@tile_x * Game_Map::REAL_RES_X - @map.display_x).to_f / Game_Map::X_SUBPIXELS).round
    this_y = ((@tile_y * Game_Map::REAL_RES_Y - @map.display_y).to_f / Game_Map::Y_SUBPIXELS).round

    if defined?(TilemapRenderer::ZOOM_X) && TilemapRenderer::ZOOM_X != 1
      this_x = ((this_x - (Graphics.width / 2.0)) * TilemapRenderer::ZOOM_X) + (Graphics.width / 2.0)
      self.zoom_x = TilemapRenderer::ZOOM_X
    end
    if defined?(TilemapRenderer::ZOOM_Y) && TilemapRenderer::ZOOM_Y != 1
      this_y = ((this_y - (Graphics.height / 2.0)) * TilemapRenderer::ZOOM_Y) + (Graphics.height / 2.0)
      self.zoom_y = TilemapRenderer::ZOOM_Y
    end

    self.x = this_x
    self.y = this_y
  end

  def update
    return if disposed?
    update_coords
    @timer -= 1
    if @timer <= 0
      dispose
      return
    end
    fraction = @timer.to_f / @total_duration
    self.opacity = (FootprintsSettings::FOOTPRINT_INITIAL_OPACITY * fraction).round
  end
end

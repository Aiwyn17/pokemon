class PokemonGlobalMetadata
  def recipes
    @recipes = [] unless @recipes
    return @recipes
  end
end

def pbUnlockRecipe(recipe_id)
  return if !recipe_id
  recipe_id = recipe_id.to_sym if recipe_id.is_a?(String)
  $PokemonGlobal.recipes.push(recipe_id)
  $PokemonGlobal.recipes.uniq!
end

def pbLockRecipe(recipe_id)
  return if !recipe_id
  recipe_id = recipe_id.to_sym if recipe_id.is_a?(String)
  return unless $PokemonGlobal.recipes.include?(recipe_id)
  $PokemonGlobal.recipes.delete(recipe_id)
end

def pbKnowsRecipe?(recipe_id)
  return false if !recipe_id
  recipe_id = recipe_id.to_sym if recipe_id.is_a?(String)
  return $PokemonGlobal.recipes.include?(recipe_id)
end

def pbGetRecipes(flag=nil)
  ret = []
  flag_str = flag ? flag.to_s : nil
  $PokemonGlobal.recipes.each do |recipe|
    next unless GameData::Recipe.exists?(recipe)
    next if flag_str && !GameData::Recipe.get(recipe).has_flag?(flag_str)
    ret.push(recipe)
  end
  return ret
end

# Raccourci pour ouvrir la Forge / Établi d'Artisanat
def pbOpenForge(flag = :Forge)
  stock = pbGetRecipes(flag)
  if stock.empty?
    stock = pbGetRecipes
  end
  pbItemCrafter(stock, _INTL("Bienvenue à la Forge ! Que souhaitez-vous forger ?"), _INTL("Revenez quand vous aurez de nouveaux composants !"))
end

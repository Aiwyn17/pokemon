class SpeciesValidator 
  def level(species, value)
    return 5 if !value
    if value > Settings::MAXIMUM_LEVEL
      Console.echoln_li _INTL("The level for \"#{species}\" is set too high, the max level is \"#{Settings::MAXIMUM_LEVEL}\"!")
      value = Settings::MAXIMUM_LEVEL
    end 
    return value
  end 

  def ability(species, value)
    return if !value 
    if value.is_a?(Integer)
      abils = species.getAbilityList
      if value < 0 
        Console.echoln_li _INTL("Ability: the index cannot be lower than \"0\"")
        return
      end 
      if value >= abils.length 
        Console.echoln_li _INTL("Ability with Index: \"#{value}\" is invalid for \"#{species.speciesName}\"")
        return 
      end
      return value
    elsif value.is_a?(Symbol)
      if !GameData::Ability.try_get(value)
        Console.echoln_li _INTL("Ability: \"#{value}\" does not exist!")
        return 
      end 
      if !species.hasAbility?(value)
        Console.echoln_li _INTL("Ability: \"#{value}\" cannot to be given to \"#{species.speciesName}\"!")
        return value
      end 
      return value 
    else
      Console.echoln_li _INTL("Ability: \"#{value}\" must be either a Integer or Hash.")
      return 
    end 
  end 

  def nickname(value)
    return if !value
    if value.length > Pokemon::MAX_NAME_SIZE
      Console.echoln_li _INTL("Nickname: \"#{value}\" exceeds the max length of \"#{Pokemon::MAX_NAME_SIZE}\" for Species Nicknames.")
      return
    end 
    return value
  end 

  def gender(species, gender, value)
    return if !value 
    if (!canMale(species) && (value == "male" || value == 0)) || (!canFemale(species) && (value == "female" || value == 1 )) || (!canGenderless(species) && (value == "genderless" || value == 2))
      Console.echoln_li _INTL("Gender: \"#{value}\" is not a valid for \"#{species.speciesName}\".")
    end 
    return value 
  end 

  def canMale(species)
    species.gender = 0 
    return species.gender == 0
  end 

  def canFemale(species)
    species.gender = 1 
    return species.gender == 1
  end 

  def canGenderless(species)
    species.gender = 2 
    return species.gender == 2
  end 

  def item(value)
    return if !value
    if GameData::Item.try_get(value)
      return value 
    else 
      Console.echoln_li _INTL("Item: #{value} does not exist!")
    end 
  end 

  def pokeBall(value)
    return if !value 
    itemData = GameData::Item.try_get(value)
    if !itemData
      Console.echoln_li _INTL("Pokeball: #{value} does not exist!")
    elsif !itemData.is_poke_ball?
      Console.echoln_li _INTL("Pokeball: #{value} is not a Poke Ball Item.")
    else 
      return value 
    end 
  end 

  def nature(value)
    return if !value
    if GameData::Nature.try_get(value)
        return value
    else 
      Console.echoln_li _INTL("Nature: #{value} does not exist!")
    end 
  end 

  def form(species, value)
    return if !value
    return value if value == 0
    if !species.isSpecies?(("#{(species.species_data).id}_#{value}").to_sym)
      Console.echoln_li _INTL("Form: \"#{value}\" is not a valid form for \"#{species.speciesName}\".")
      return 
    end 
    return value
  end 

  def obtainLevel(species, value)
    return if !value 
    if value > species.level
      Console.echoln_li _INTL("Obtain Level: \"#{value}\" should not be higher than \"#{species.level}\" for \"#{species.speciesName}\".")
      return 
    end 
    if value < 1
      Console.echoln_li _INTL("Obtain Level: \"#{value}\" should be greater than or equal to 1.")
      return 
    end 
    return value
  end 

  def obtainMap(value)
    return if !value 
    if !GameData::MapMetadata.try_get(value)
      Console.echoln_li _INTL("Obtain Map: Map \"#{value}\" does not exist!")
      return 
    end
    return value 
  end 

  def obtainMethod(value)
    return if !value 
    if value == 3 || value > 4 || value < 0 
      Console.echoln_li _INTL("Obtain Method: \"#{value}\" does not exist!")
      return 
    end 
    return value
  end 

  def obtainText(value)
    return if !value 
    if !value.is_a?(String)
      Console.echoln_li _INTL("Obtain Text: \"#{value}\" is not a string.")
      return 
    end 
    return value
  end 

  def ownerId(value)
    return if !value 
    if value < 1 || value > 99999
      Console.echoln_li _INTL("Owner ID: \"#{value}\" should not be \"#{value < 1 ? "smaller than 1" : "bigger than 99999"}\".")
      return 
    end 
    return value 
  end 

  def ownerName(value)
    return if !value 
    if value.length > Settings::MAX_PLAYER_NAME_SIZE
      Console.echoln_li _INTL("Owner Name: \"#{value}\" exceeds the max length of \"#{Settings::MAX_PLAYER_NAME_SIZE}\" for NPC Names.")
      return 
    end 
    return value 
  end 

  def ownerGender(value)
    return if !value 
    if value < 0 || value > 3
      Console.echoln_li _INTL("Owner Gender: \"#{value}\" does not exist!")
      return
    end 
    return value
  end 

  def ownerLanguage(value)
    return if !value 
    case value
    when "unknown", 0
      return 0
    when "japanese", 1
      return 1
    when "english", "default", 2
      return 2
    when "french", 3
      return 3
    when "italian", 4
      return 4
    when "german", 5
      return 5
    when "spanish", 7
      return 7
    when "korean", 8
      return 8
    else 
      Console.echoln_li _INTL("Owner Language: \"#{value}\" does not exist!")
      return 
    end 
  end 

  def iv(value, type)
    return if !value
    if Settings::DISABLE_IVS_AND_EVS 
      Console.echoln_li _INTL("IV: \"#{value}\" is not valid as IVs are disabled.")
      return 
    end 
    if value > Pokemon::IV_STAT_LIMIT || value < 1
      Console.echoln_li _INTL("IV: \"#{type}\" has a value of \"#{value}\" which cannot be \"#{value < 1 ? "lower than 1" : "higher than #{Pokemon::IV_STAT_LIMIT}"}\".")
      return 
    end 
    return value 
  end 

  def ev(species, value, type)
    return if !value 
    if Settings::DISABLE_IVS_AND_EVS
      Console.echoln_li _INTL("EV: \"#{value}\" is not valid as EVs are disabled.")
      return 0
    end
    if value > Pokemon::EV_STAT_LIMIT || value < 1
      Console.echoln_li _INTL("EV: \"#{type}\" has a value of \"#{value}\" which cannot be \"#{value < 1 ? "lower than 1" : "higher than #{Pokemon::EV_STAT_LIMIT}"}\".")
      return 0
    end 
    sumEV = 0
    species.ev.each do |e, s| s.to_i
      break if e.to_s == type.upcase
      sumEV += s.to_i if sumEV + s.to_i <= Pokemon::EV_LIMIT
    end 
    if sumEV + value > Pokemon::EV_LIMIT
      Console.echoln_li _INTL("EV: \"#{type}\" has a value of \"#{value}\" which will make the current total of \"#{sumEV}\" exceed the max EV limit of \"#{Pokemon::EV_LIMIT}\".")
      return 0 
    end 
    return value 
  end 

  def moves(species, values)
    return if !values || values.length < 1
    if values.length > 4
      Console.echoln_li _INTL("Moves: \"#{species.speciesName}\" can only learn \"#{Pokemon::MAX_MOVES}\" moves at a time. If you give more, the first ones will be replaced each time.")
    end 
    return values 
  end 

  def cannotStore(value)
    return if !value
    if !(value.is_a?(TrueClass) || value.is_a?(FalseClass))
      Console.echoln_li _INTL("Cannot Store: \"#{value}\" is not valid! Set to either \"true\" or \"false\".")
      return 
    end 
    return value 
  end 

  def cannotTrade(value)
    return if !value 
    if !(value.is_a?(TrueClass) || value.is_a?(FalseClass))
      Console.echoln_li _INTL("Cannot Trade: \"#{value}\" is not valid! Set to either \"true\" or \"false\".")
      return 
    end 
    return value 
  end 

  def cannotRelease(value)
    return if !value 
    if !(value.is_a?(TrueClass) || value.is_a?(FalseClass))
      Console.echoln_li _INTL("Cannot Release: \"#{value}\" is not valid! Set to either \"true\" or \"false\".")
      return 
    end 
    return value 
  end 

  def happiness(value)
    return if !value 
    if value.is_a?(Integer) && value > 255
      Console.echoln_li _INTL("Happiness: \"#{value}\" cannot be higher than 255.")
      return 
    end 
    if !["walking", "levelup", "groom", "evberry", "vitamin", "wing", "machine", "battleitem", "faint", "faintbad", "powder", "energyroot", "revivalherb"].include?(value)
      Console.echoln_li _INTL("Happiness: \"#{value}\" does not exist!")
      return 
    end 
    return value 
  end 

  def pokerus(species, value)
    return if !value 
    if !value.is_a?(Integer)
      Console.echoln_li _INTL("Pokerus: \"#{value}\" is not a number!")
      return 
    end 
    if value < 0 || value > 15 
      Console.echoln_li _INTL("Pokerus: \"#{value}\" cannot be #{value < 1 ? "lower than 1" : "higher than 15"}.")
      return 
    end 
    return value 
  end 

  def status(species, value)
    return if !value 
    status = GameData::Status.try_get(value)
    if !status 
      Console.echoln_li _INTL("Status: \"#{value}\" does not exist!")
      return 
    end 
    return value
  end 
end 

class SpeciesMartAdapter < PokemonMartAdapter
  def initialize(stock)
    @stock = stock
    @valid = SpeciesValidator.new
    @shinies = {}
    @superShinies = {}
    @genders = {}
    @forms = {}
  end

  def findSpecies(species)
    return @stock.find { |s| s[:name] == species }
  end

  def getName(species)
    speciesData = GameData::Species.try_get(species)
    return nil if !speciesData
    return speciesData.name
  end 

  def setShiny(species)
    species = findSpecies(species)
    shiny = false
    if species.key?(:shiny)
      shiny = getShinyChance(species[:shiny], "Shiny")
    end 
    if !@shinies.key?(species[:name])
      @shinies[species[:name]] = shiny 
      return shiny
    else 
      return @shinies[species[:name]]
    end 
  end 

  def setSuperShiny(species)
    species = findSpecies(species)
    shiny = false
    if species.key?(:supershiny)
      shiny = getShinyChance(species[:supershiny], "Super Shiny")
    end 
    if !@superShinies.key?(species[:name])
      @shinies[species[:name]] = shiny
      return shiny 
    else 
      return @superShinies[species[:name]]
    end 
  end 

  def getShinyChance(shiny, type)
    if shiny.is_a?(Integer)
      return rand(shiny) == 4
    end 
    return shiny
  end

  def getShiny(species)
    return @shinies[species]
  end 

  def getSuperShiny(species)
    return @superShinies[species]
  end 

  def setGender(species)
    species = findSpecies(species)
    temp = Pokemon.new(species[:name], 1)
    if !@genders.key?(species[:name])
      gender = nil
      if species.key?(:gender)
        gender = 0 if (species[:gender] == 0 || species[:gender] == "male") && temp.male? 
        gender = 1 if (species[:gender] == 1 || species[:gender] == "female") && temp.female? && !gender
      end 
      gender = temp.gender if !gender
      @valid.gender(temp, gender, species[:gender])
      @genders[species[:name]] = gender
      return gender
    else
      return @genders[species[:name]]
    end 
  end 

  def getGender(species)
    return @genders[species]
  end 

  def setForm(species)
    species = findSpecies(species)
    temp = Pokemon.new(species[:name], 1)
    if !@forms.key?(species[:name])
      form = temp.form
      if species.key?(:form)
        form = species[:form] if @valid.form(temp, species[:form])
      end 
      @forms[species[:name]] = form 
      return form 
    else 
      return @forms[species[:name]]
    end 
  end 

  def getForm(species)
    return @forms[species]
  end 

  def getDisplayName(species)
    speciesName = getName(species)
    level = @valid.level(findSpecies(species)[:name], findSpecies(species)[:level])
    if level
      return "#{speciesName} (Lv. #{level})"
    else
      return speciesName
    end
  end

  def getDescription(species)
    speciesData = GameData::Species.try_get(species)
    return nil if !speciesData
    return findSpecies(species)[:description] || speciesData.pokedex_entry
  end

  def addSpecies(species)
    @valid = SpeciesValidator.new
    spData = findSpecies(species)
    level = @valid.level(spData[:name], spData[:level])
    pkmn = Pokemon.new(spData[:name], level)
    pkmn.ability_index = spData[:ability] if @valid.ability(pkmn, spData[:ability]) && spData[:ability].is_a?(Integer)
    pkmn.ability = spData[:ability] if @valid.ability(pkmn, spData[:ability]) && spData[:ability].is_a?(Symbol)
    pkmn.name = spData[:nickname] if @valid.nickname(spData[:nickname])
    pkmn.gender = getGender(species)
    pkmn.item = spData[:item] if @valid.item(spData[:item])
    pkmn.poke_ball = spData[:pokeball] if @valid.pokeBall(spData[:pokeball])
    pkmn.nature = spData[:nature] if @valid.nature(spData[:nature])
    pkmn.form = getForm(species)
    if spData[:obtain]
      pkmn.obtain_level = spData[:obtain][:level] if @valid.obtainLevel(pkmn, spData[:obtain][:level])
      pkmn.obtain_map = spData[:obtain][:map] if @valid.obtainMap(spData[:obtain][:map])
      pkmn.obtain_method = spData[:obtain][:method] if @valid.obtainMethod(spData[:obtain][:method])
      pkmn.obtain_text = spData[:obtain][:text] if @valid.obtainText(spData[:obtain][:text])
    end 
    if spData.key?(:owner)
      if spData[:owner].key?(:id)
        if spData[:owner][:id] == "random"
          pkmn.owner.id = rand(99999)
        else 
          pkmn.owner.id = spData[:owner][:id] if @valid.ownerId(spData[:owner][:id])
        end 
      end 
      pkmn.owner.name = spData[:owner][:name] if @valid.ownerName(spData[:owner][:name])
      pkmn.owner.gender = spData[:owner][:gender] if @valid.ownerGender(spData[:owner][:gender])
      pkmn.owner.language = spData[:owner][:language] if @valid.ownerLanguage(spData[:owner][:language])
    end    
    if spData.key?(:ivs)
      pkmn.iv[:HP] = spData[:ivs][:HP] if @valid.iv(spData[:ivs][:HP], "Hp")
      pkmn.iv[:ATTACK] = spData[:ivs][:ATTACK] if @valid.iv(spData[:ivs][:ATTACK], "Attack")
      pkmn.iv[:DEFENCE] = spData[:ivs][:DEFENCE] if @valid.iv(spData[:ivs][:DEFENCE], "Defence")
      pkmn.iv[:SPECIAL_ATTACK] = spData[:ivs][:SPECIAL_ATTACK] if @valid.iv(spData[:ivs][:SPECIAL_ATTACK], "Special Attack")
      pkmn.iv[:SPECIAL_DEFENCE] = spData[:ivs][:SPECIAL_DEFENCE] if @valid.iv(spData[:ivs][:SPECIAL_DEFENCE], "Special Defence")
      pkmn.iv[:SPEED] = spData[:ivs][:SPEED] if @valid.iv(spData[:ivs][:SPEED], "Speed")
    end 
    if spData.key?(:evs)
      pkmn.ev[:HP] = spData[:evs][:HP] if @valid.ev(pkmn, spData[:evs][:HP], "Hp")
      pkmn.ev[:ATTACK] = spData[:evs][:ATTACK] if @valid.ev(pkmn, spData[:evs][:ATTACK], "Attack")
      pkmn.ev[:DEFENCE] = spData[:evs][:DEFENCE] if @valid.ev(pkmn, spData[:evs][:DEFENCE], "Defence")
      pkmn.ev[:SPECIAL_ATTACK] = spData[:evs][:SPECIAL_ATTACK] if @valid.ev(pkmn, spData[:evs][:SPECIAL_ATTACK], "Special Attack")
      pkmn.ev[:SPECIAL_DEFENCE] = spData[:evs][:SPECIAL_DEFENCE] if @valid.ev(pkmn, spData[:evs][:SPECIAL_DEFENCE], "Special Defence")
      pkmn.ev[:SPEED] = spData[:evs][:SPEED] if @valid.ev(pkmn, spData[:evs][:SPEED], "Speed")
    end 
    pkmn.shiny = getShiny(species) # already checked if the parameter was given or not.
    pkmn.super_shiny = getSuperShiny(species)
    spData[:moves].each { |move| pkmn.learn_move(move) } if @valid.moves(pkmn, spData[:moves])
    pkmn.cannot_store = spData[:cannotstore] if @valid.cannotStore(spData[:cannotstore])
    pkmn.cannot_trade = spData[:cannottrade] if @valid.cannotTrade(spData[:cannottrade])
    pkmn.cannot_release = spData[:cannotrelease] if @valid.cannotRelease(spData[:cannotrelease])
    if @valid.happiness(spData[:happiness])
      pkmn.changeHappiness(spData[:happiness]) if spData[:happiness].is_a?(String)
      pkmn.happiness = spData[:happiness] if spData[:happiness].is_a?(Integer)
    end 
    pkmn.givePokerus(spData[:pokerus]) if spData.key?(:pokerus)
    pkmn.status = spData[:status] if spData.key?(:status)
    pkmn.calc_stats
    pbAddPokemonSilent(pkmn)
  end
end

class SpeciesMart_Scene < PokemonMart_Scene
  def pbStartSpeciesBuyScene(stock, adapter, discount)
    pbScrollMap(6, 5, 5)
    pbSEPlay("GUI menu open")
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @stock = stock
    @adapter = adapter
    @discount = discount
    @buySpecies = true
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/Mart/bg")
    @sprites["icon"] = PokemonSpeciesIconSprite.new(0, @viewport)
    @sprites["icon"].x = 4
    @sprites["icon"].y = Graphics.height - 90
    @sprites["iconReturn"] = ItemIconSprite.new(36, Graphics.height - 50, nil, @viewport)
    @sprites["iconReturn"].visible = false
    @winAdapter = BuyAdapter.new(adapter)
    @sprites["itemwindow"] = Window_PokemonMart.new(
      @stock, @winAdapter, Graphics.width - 316 - 16, 10, 330 + 16, Graphics.height - 128, nil, @discount
    )
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].index = 0
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.newWithSize(
      "", 64, Graphics.height - 96 - 16, Graphics.width - 64, 128, @viewport
    )
    pbPrepareWindow(@sprites["itemtextwindow"])
    @sprites["itemtextwindow"].baseColor = Color.new(248, 248, 248)
    @sprites["itemtextwindow"].shadowColor = Color.black
    @sprites["itemtextwindow"].windowskin = nil
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible = true
    @sprites["moneywindow"].viewport = @viewport
    @sprites["moneywindow"].x = 0
    @sprites["moneywindow"].y = 0
    @sprites["moneywindow"].width = 190
    @sprites["moneywindow"].height = 96
    @sprites["moneywindow"].baseColor = Color.new(88, 88, 88)
    @sprites["moneywindow"].shadowColor = Color.new(168, 184, 184)
    pbDeactivateWindows(@sprites)
    @buying = true
    pbRefresh
    Graphics.frame_reset
  end
end

class SpeciesMartScreen < PokemonMartScreen
  def pbSpeciesScreen
    @scene.pbStartSpeciesBuyScene(@stock, @adapter, @discount)
    species = nil
    loop do
      species = @scene.pbChooseBuyItem
      break if !species
      quantity = 1
      speciesName = @adapter.getName(species)
      speciesPrice = @adapter.getPrice(species, false, @discount)
      entry = $pokeMartTracker[:items].find { |entry| entry[:name] == species } if $pokeMartTracker.key?(:items)
      if !entry.nil? && entry[:limit] == 0
        quantity = 0
        pbDisplayPaused(_INTL(@getSpeech[:SpeciesOutOfStock]&.sample || "We no longer have {1} available to buy.", speciesName))
      end
      next if quantity == 0
      next if !pbConfirm(_INTL(@getSpeech[:BuySpecies]&.sample || "So you want {1}? That'll be {2}.", speciesName, @adapter.getCurrencyPrice(speciesPrice.to_s_formatted)))
      if @adapter.getMoney < speciesPrice
        pbDisplayPaused(_INTL(@getSpeech[:NotEnoughMoney]&.sample ||"You don't have enought {1}", @adapter.getCurrency, speciesName))
        next
      end
      entry[:limit] -= quantity if !entry.nil? && quantity != 0
      unless pbBoxesFull?
        $stats.money_spent_at_marts += speciesPrice
        $amount = @adapter.setChangeMoney(@adapter.getMoney - speciesPrice)
        @adapter.addSpecies(species)
        pbDisplayPaused(_INTL(@getSpeech[:SpeciesThanks]&.sample || "Here you go! Thanks a lot!", speciesName)) { pbSEPlay("Mart buy item") }
      else
        pbDisplayPaused(_INTL(@getSpeech[:NoRoomInStorage]&.sample || "You have no more room in the Storage."))
      end
      break if checkOutOfStock(@stock)
    end
    @scene.pbEndBuyScene
  end
end

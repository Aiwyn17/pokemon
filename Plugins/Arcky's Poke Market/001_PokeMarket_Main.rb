class PokemonMartAdapter
  def getMoney
    if $currency.is_a?(String)
      case $currency.downcase
      when "money", "gold"
        return $player.money
      when "coins"
        return $player.coins
      when "battle points", "bp"
        return $player.battle_points
      end 
    else
      return $bag.quantity($currency)
    end
  end

  def getMoneyString
    if $currency.is_a?(String)
      case $currency.downcase
      when "money", "gold"
        return _INTL("Money:\n<r>{1}", pbGetGoldString)
      when "coins"
        return _INTL("Coins:\n<r>{1}", $player.coins.to_s_formatted)
      when "battle points", "bp"
        return _INTL("Battle Points:\n<r>{1}", $player.battle_points.to_s_formatted)
      end 
    else
      return _INTL("<r>{1}      ", $bag.quantity($currency))
    end
  end

  def setMoney(value)
    if $currency.is_a?(String)
      case $currency.downcase
      when "money", "gold"
        return $player.money = value
      when "coins"
        return $player.coins = value
      when "battle points", "bp"
        return $player.battle_points = value
      end
    else
      if $bag.quantity($currency) > value
        return $bag.remove($currency, $bag.quantity($currency) - value)
      else 
        return $bag.add($currency, ($bag.quantity($currency) - value).abs)
      end 
    end 
  end

  def getPrice(item, selling = false, discount = nil, qty = 1)
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      if selling
        return $game_temp.mart_prices[item][1] if $game_temp.mart_prices[item][1] >= 0
      elsif $game_temp.mart_prices[item][0] > 0
        return $game_temp.mart_prices[item][0]
      end
    else 
      if selling.is_a?(Numeric)
        discount = selling if selling
        selling = false
      end
      gameVar = $game_variables[discount.abs] if discount
      disc = 0
      if discount && !gameVar.nil? && gameVar >= 0
        APMSettings::Discounts.each do |key, value|
          if key.is_a?(Symbol)
            next unless $bag.has?(key)
            next unless value.is_a?(Hash) && value.key?(discount)
            if value[discount].is_a?(Array)
              disc = value[discount][gameVar] || 0
              if value[discount].length - 1 < gameVar
                Console.echoln_li _INTL("Please check the value of game variable #{@discount}, it's too high according to it's Discounts values")
              end
            else
              disc = value[discount]
            end
            break
          elsif key == discount
            if value.is_a?(Array)
              disc = value[gameVar] || 0
              if value.length - 1 < gameVar
                Console.echoln_li _INTL("Please check the value of game variable #{@discount}, it's too high according to it's Discounts values")
              end
            else
              disc = value
            end
          end
        end
      end
      itemData = GameData::Item.try_get(item)
      if itemData
        if $currency.is_a?(String)
          case $currency.downcase
          when "money", "gold"
            price = itemData.price.to_f
          when "coins"
            price = itemData.coin_price.to_f
          when "battle points", "bp"
            price = itemData.bp_price.to_f
          end
          if selling
            case $currency.downcase
            when "money", "gold"
              return itemData.sell_price
            when "coins"
              return itemData.sell_coin_price
            when "battle points", "bp"
              return itemData.sell_bp_price
            end
          end
        else
          itemPrice = $itemCurrencyPrizes.find { |i| i.key?(item) }&.[](item)
          if (itemPrice)
            price = itemPrice[:price] || 1
          else 
            price = 1
          end 
        end 
      else
        speciesData = GameData::Species.try_get(item)
        if speciesData
          price = findSpecies(item)[:price] || 1000
        else
          price = 1
        end
      end
      newPrice = (price * ((100 - disc).to_f / 100)).round(0) * qty
      return newPrice
    end 
  end

  def getDisplayPrice(item, selling = false, discount = nil, qty = 1)
    price = getPrice(item, selling, discount, qty).to_s_formatted
    if $currency.is_a?(String)
      case $currency.downcase
      when "money", "gold"
        return _INTL("$ {1}", price)
      when "coins"
        return _INTL("{1} Coin#{price.to_i > 1 ? 's' : ''}", price)
      when "battle points", "bp"
        return _INTL("{1} BP", price)
      end
    else
      return _INTL("{1}", price)
    end 
  end

  def getCurrencyPrice(price)
    if $currency.is_a?(String)
      case $currency.downcase
      when "money", "gold"
        return "$#{price}"
      when "coins"
        return "#{price} Coins"
      when "battle points", "bp"
        return "#{price} BP"
      end
    else
      return "#{price} #{$currency.name_plural}"
    end 
  end

  def getCurrency
    if $currency.is_a?(String)
      case $currency.downcase
      when "money", "gold"
        return "Money"
      when "coins"
        return "Coins"
      when "battle points", "bp"
        return "Battle Points"
      end
    else 
      return $currency.name_plural
    end 
  end

  def setChangeMoney(value)
    money = getMoney - value
    times =  money.abs > 50 ? 50 : money.abs
    amount = money != 0 ? (money.to_f / times) : 0
    $amount = (1..times).map { |step| getMoney - (amount * step) }
  end
end

class BuyAdapter
  def getDisplayPrice(item, discount)
    @adapter.getDisplayPrice(item, false, discount)
  end

  def getPrice(item, discount)
    @adapter.getPrice(item, false, discount)
  end 
end

class PokemonMart_Scene
  def pbRefresh
    if @subscene
      @subscene.pbRefresh
    else
      itemwindow = @sprites["itemwindow"]
      return if itemwindow.nil?
      if @buySpecies
        if itemwindow.item
          @sprites["icon"].species = itemwindow.item
          @sprites["icon"].shiny = @adapter.setShiny(itemwindow.item)
          @sprites["icon"].gender = @adapter.setGender(itemwindow.item)
          @sprites["icon"].form = @adapter.setForm(itemwindow.item)
          @sprites["iconReturn"].visible = false
          @sprites["icon"].visible = true
        else
          @sprites["iconReturn"].item = itemwindow.item
          @sprites["iconReturn"].visible = true
          @sprites["icon"].visible = false
        end
      else
        @sprites["icon"].item = itemwindow.item
      end
      @sprites["itemtextwindow"].text =
        (itemwindow.item) ? @adapter.getDescription(itemwindow.item) : _INTL("Quit shopping.")
      if @sprites["qtywindow"]
        @sprites["qtywindow"].visible = !itemwindow.item.nil?
        @sprites["qtywindow"].text    = _INTL("In Bag:<r>{1}", @adapter.getQuantity(itemwindow.item))
        @sprites["qtywindow"].y       = Graphics.height - 102 - @sprites["qtywindow"].height
      end
      if $itemCurrencyPrizes
        $currentItem = { item: itemwindow.item, data: $itemCurrencyPrizes.find { |i| i.key?(itemwindow.item) }&.[](itemwindow.item) }
        $currency = !$currentItem[:data].nil? && $currentItem[:data].key?(:currency) ? GameData::Item.try_get($currentItem[:data][:currency]) : $initialCurrency
        @sprites["currencyIcon"].item = $currency
      else 
        if @sprites["currencyIcon"]
          @sprites["currencyIcon"].visible = false
        end
      end 
      itemwindow.refresh
    end
    updateCurrencyWindow(@sprites["moneywindow"], @adapter)
  end

  def pbStartBuyOrSellScene(buying, stock, choiceStock, stockByCat, adapter, discount)
    # Scroll right before showing screen
    $currentItem = nil
    pbScrollMap(6, 5, 5)
    pbSEPlay("GUI menu open")
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    if choiceStock.nil?
      @stock = stock
      @stockIndex = 0
    else
      @stock = stock = choiceStock
      @stockIndex = stockByCat.values.index(choiceStock)
      @stockByCat = stockByCat
      @catName = stockByCat.keys[@stockIndex]
    end
    @discount = discount
    @adapter = adapter
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if Essentials::VERSION.include?("21")
      @sprites["background"].setBitmap("Graphics/UI/Mart/bg")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/martScreen")
    end
    @sprites["icon"] = ItemIconSprite.new(36, Graphics.height - 50, nil, @viewport)
    @sprites["currencyIcon"] = ItemIconSprite.new(156, 30, nil, @viewport)
    @sprites["currencyIcon"].z = 99999
    @winAdapter = buying ? BuyAdapter.new(adapter) : SellAdapter.new(adapter)
    @sprites["category"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["category"].visible = true
    pbSetSystemFont(@sprites["category"].bitmap)
    if !@catName.nil?
      pbDrawTextPositions(@sprites["category"].bitmap, [
        [@catName, Graphics.width - 300, 30, 0, Color.new(88, 88, 80), Color.new(168, 184, 184)],
        ["Page #{@stockIndex + 1}/#{@stockByCat.length}", 490, 30, 1, Color.new(88, 88, 80), Color.new(168, 184, 184)],
        ["-----------------------", Graphics.width - 300, 46, 0, Color.new(88, 88, 80), Color.new(168, 184, 184)]
      ])
      yMin = 42
      yMax = 156
    else
      yMin = 10
      yMax = 128
    end
    if stockByCat && stockByCat.length >= 1
      @sprites["leftArrow"] = AnimatedSprite.new("Graphics/UI/Mart/arrow_left", 8, 40, 28, 2, @viewport)
      @sprites["leftArrow"].y = ((Graphics.height - 96) / 2) - 14
      @sprites["leftArrow"].x = 180
      @sprites["leftArrow"].z = 135
      @sprites["rightArrow"] = AnimatedSprite.new("Graphics/UI/Mart/arrow_right", 8, 40, 28, 2, @viewport)
      @sprites["rightArrow"].y = ((Graphics.height - 96) / 2) - 14
      @sprites["rightArrow"].x = Graphics.width - 34
      @sprites["rightArrow"].z = 135
      if @stockByCat.length > 1
        @sprites["leftArrow"].play
        @sprites["rightArrow"].play 
      else 
        @sprites["leftArrow"].visible = false
        @sprites["rightArrow"].visible = false 
      end 
    end 
    @sprites["itemwindow"] = Window_PokemonMart.new(
      stock, @winAdapter, Graphics.width - 316 - 16, yMin, 330 + 16, Graphics.height - yMax, nil, @discount
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
    @sprites["moneywidth"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["moneywidth"].visible = false
    currencyName = $currency.respond_to?(:name_plural) ? $currency.name_plural : $currency.to_s
    if @sprites["moneywidth"].bitmap.text_size(currencyName).width >= 120
      @sprites["moneywindow"].height = 60
    else 
      @sprites["moneywindow"].height = 96
    end
    @sprites["moneywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["moneywindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["qtywindow"])
    @sprites["qtywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["qtywindow"].viewport = @viewport
    @sprites["qtywindow"].width = 190
    @sprites["qtywindow"].height = 64
    @sprites["qtywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["qtywindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtywindow"].text = _INTL("In Bag:<r>{1}", @adapter.getQuantity(@sprites["itemwindow"].item))
    @sprites["qtywindow"].y    = Graphics.height - 102 - @sprites["qtywindow"].height
    pbDeactivateWindows(@sprites)
    @buying = buying
    pbRefresh
    Graphics.frame_reset
  end

  def pbStartBuyScene(stock, choiceStock, stockByCat, adapter, discount)
    pbStartBuyOrSellScene(true, stock, choiceStock, stockByCat, adapter, discount)
  end

  def pbChooseBuyItem
    itemwindow = @sprites["itemwindow"]
    @sprites["helpwindow"].visible = false
    pbActivateWindow(@sprites, "itemwindow") do
      pbRefresh
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        pbRefresh if itemwindow.item != olditem
        if Input.trigger?(Input::LEFT) && !@stockByCat.nil?
          if @stockByCat.length > 1
            pbSEPlay("GUI naming tab swap start")
            @stockIndex -= 1
            @stockIndex = @stockByCat.length - 1 if @stockIndex < 0
            updateStock
            itemwindow = @sprites["itemwindow"]
            pbRefresh
          end 
          next
        elsif Input.trigger?(Input::RIGHT) && !@stockByCat.nil?
          if @stockByCat.length > 1
            pbSEPlay("GUI naming tab swap start")
            @stockIndex += 1
            @stockIndex = 0 if @stockIndex > @stockByCat.length - 1
            pbPlayCursorSE
            updateStock
            itemwindow = @sprites["itemwindow"]
            pbRefresh
          end 
          next
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          return nil
        elsif Input.trigger?(Input::USE)
          if itemwindow.index < @stock.length
            pbRefresh
            return @stock[itemwindow.index]
          else
            return nil
          end
        end
      end
    end
  end

  def updateStock
    @stock = @stockByCat.values[@stockIndex]
    if @sprites["category"]
      @sprites["category"].bitmap.clear
      @catName = @stockByCat.keys[@stockIndex]
      pbDrawTextPositions(@sprites["category"].bitmap, [
        [@catName, Graphics.width - 300, 30, 0, Color.new(88, 88, 80), Color.new(168, 184, 184)],
        ["Page #{@stockIndex + 1}/#{@stockByCat.length}", 490, 30, 1, Color.new(88, 88, 80), Color.new(168, 184, 184)],
        ["-----------------------", Graphics.width - 300, 46, 0, Color.new(88, 88, 80), Color.new(168, 184, 184)]
      ])
      yMin = 42
      yMax = 156
    else
      yMin = 10
      yMax = 124
    end
    @sprites["itemwindow"].dispose
    @sprites["itemwindow"] = Window_PokemonMart.new(
      @stock, @winAdapter, Graphics.width - 316 - 16, yMin, 330 + 16, Graphics.height - yMax, nil, @discount
    )
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].index = 0
    @sprites["itemwindow"].refresh
  end

  def pbChooseNumber(helptext, item, maximum, minimum = 1, quantity = 1)
    curnumber = quantity || 1
    ret = 0
    helpwindow = @sprites["helpwindow"]
    pbDisplay(helptext, true)
    using(numwindow = Window_AdvancedTextPokemon.new("")) do   # Showing number of items
      pbPrepareWindow(numwindow)
      numwindow.viewport = @viewport
      numwindow.width = 224
      numwindow.height = 64
      numwindow.baseColor = Color.new(88, 88, 80)
      numwindow.shadowColor = Color.new(168, 184, 184)
      numwindow.text = _INTL("x{1}<r>{2}", curnumber, @adapter.getDisplayPrice(item, false, @discount, curnumber))
      pbBottomRight(numwindow)
      numwindow.y -= helpwindow.height
      loop do
        Graphics.update
        Input.update
        numwindow.update
        update
        oldnumber = curnumber
        if Input.repeat?(Input::LEFT)
          curnumber -= 10
          curnumber = minimum if curnumber < minimum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2}", curnumber, @adapter.getDisplayPrice(item, false, @discount, curnumber))
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::RIGHT)
          curnumber += 10
          curnumber = maximum if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2}", curnumber, @adapter.getDisplayPrice(item, false, @discount, curnumber))
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::UP)
          curnumber += 1
          curnumber = minimum if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2}", curnumber, @adapter.getDisplayPrice(item, false, @discount, curnumber))
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::DOWN)
          curnumber -= 1
          curnumber = maximum if curnumber < minimum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2}", curnumber, @adapter.getDisplayPrice(item, false, @discount, curnumber))
            pbPlayCursorSE
          end
        elsif Input.trigger?(Input::USE)
          ret = curnumber
          break
        elsif Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = quantity > 1 ? quantity : 0
          break
        end
      end
    end
    helpwindow.visible = false
    return ret
  end
end

class PokemonMartScreen
  def initialize(scene, stock, speech = nil, choiceStock = nil, stockByCat = nil, discount = nil, species = false, speciesStock = nil)
    @scene = scene
    @stock = stock
    @discount = discount
    @getSpeech = speech
    @choiceStock = choiceStock
    @stockByCat = stockByCat
    @adapter = !species ? PokemonMartAdapter.new : SpeciesMartAdapter.new(speciesStock)
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @choiceStock, @stockByCat, @adapter, @discount)
    item = nil
    loop do
      item = @scene.pbChooseBuyItem
      break if !item
      quantity       = 0
      itemname       = @adapter.getDisplayName(item)
      itemnameplural = @adapter.getDisplayNamePlural(item)
      price = @adapter.getPrice(item, @discount)
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL(@getSpeech[:NotEnoughMoney]&.sample || "You don't have enough {1}.", @adapter.getCurrency))
        next
      end
      if GameData::Item.get(item).is_important?
        next if !pbConfirm(_INTL(@getSpeech[:BuyItemImportant]&.sample || "So you want {1}?\nIt'll be {2}. All right?", itemname, @adapter.getCurrencyPrice(price.to_s_formatted)))
        quantity = 1
      else
        totAddItems = getMaxAddableItems(item)
        maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getMoney / price
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        maxafford = totAddItems if Settings::BAG_MAX_PER_SLOT > totAddItems && totAddItems > 0
        entry = $pokeMartTracker[:items].find { |entry| entry[:name] == item } if $pokeMartTracker.key?(:items)
        maxafford = entry[:limit] if !entry.nil? && entry[:limit] < maxafford && entry[:limit] <= Settings::BAG_MAX_PER_SLOT
        oldPrice = @adapter.getPrice(item, nil)
        if !@discount.nil? && price != 1 && price != oldPrice
          if price < oldPrice
            quantity = @scene.pbChooseNumber(
              _INTL(@getSpeech[:BuyItemAmountDiscount]&.sample || "So how many {1}?", itemnameplural, @adapter.getCurrencyPrice(price), @adapter.getCurrencyPrice(oldPrice)),
              item, maxafford) unless maxafford == 0
          elsif price > oldPrice
            quantity = @scene.pbChooseNumber(
              _INTL(@getSpeech[:BuyItemAmountOvercharge]&.sample || "So how many {1}?", itemnameplural, @adapter.getCurrencyPrice(price), @adapter.getCurrencyPrice(oldPrice)),
              item, maxafford) unless maxafford == 0
          end
        else
          quantity = @scene.pbChooseNumber(
            _INTL(@getSpeech[:BuyItemAmount]&.sample || "So how many {1}?", itemnameplural),
            item, maxafford) unless maxafford == 0
          if price == 1 && !@discount.nil?
            Console.echoln_li _INTL("Be aware that when an item has a price of 1, discounts don't work.")
          end
        end
        if !entry.nil? && entry[:limit] == 0
          quantity = 0
          pbDisplayPaused(_INTL(@getSpeech[:BuyOutOfStock]&.sample || "I'm sorry, we are currently out of {1}. Come back {2}.", itemnameplural, $pokeMartTracker[:refresh]))
        end
        if quantity == 0
          pbDisplayPaused(_INTL(@getSpeech[:NoRoomInBag]&.sample || "You have no room in your Bag.")) if totAddItems == 0
          next
        end
        price *= quantity
        if quantity > 1
          next if !pbConfirm(_INTL(@getSpeech[:BuyItemMult]&.sample || "So you want {1} {2}?\nThey'll be {3}. All right?", quantity, itemnameplural, @adapter.getCurrencyPrice(price.to_s_formatted)))
        elsif quantity > 0
          next if !pbConfirm(_INTL(@getSpeech[:BuyItem]&.sample || "So you want {1} {2}?\nIt'll be {3}. All right?", quantity, itemname, @adapter.getCurrencyPrice(price.to_s_formatted)))
        end
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL(@getSpeech[:NotEnoughMoney]&.sample || "You don't have enough {1}.", @adapter.getCurrency))
        next
      end
      entry[:limit] -= quantity if !entry.nil? && quantity != 0
      added = 0
      quantity.times do
        break if !@adapter.addItem(item)
        added += 1
      end
      if added == quantity
        $stats.money_spent_at_marts += price
        $stats.mart_items_bought += quantity
        $amount = @adapter.setChangeMoney(@adapter.getMoney - price)
        @stock.delete_if { |item| GameData::Item.get(item).is_important? && $bag.has?(item) }
        if !@stockByCat.nil?
          @stockByCat.each do |key, values|
            values.delete_if do |item|
              GameData::Item.get(item).is_important? && $bag.has?(item)
            end
            if values.empty?
              @stockByCat.delete(key)
            end
          end
        end
        pbDisplayPaused(_INTL(@getSpeech[:BuyThanks]&.sample || "Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
        Achievements.setProgress("ITEMS_BOUGHT",$stats.mart_items_bought) if PluginManager.installed?("Mega MewThree's Achievement System")
        getBonusItems(item, @adapter, quantity, @getSpeech)
        countPurchasedItem(item, quantity)
        if quantity > 1
          unless !@getSpeech[:PurchaseCountMult]
            pbDisplayPaused(_INTL(@getSpeech[:PurchaseCountMult]&.sample || "Amazing, you got {1}Points!", quantity))
          end
        else
          unless !(@getSpeech[:PurchaseCount])
            pbDisplayPaused(_INTL(@getSpeech[:PurchaseCount]&.sample || "Congrats, you got 1 point!"))
          end
        end
        break if checkOutOfStock(@stock)
      else
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbDisplayPaused(_INTL(@getSpeech[:NoRoomInBag]&.sample || "You have no room in your Bag."))
      end
    end
    @scene.pbEndBuyScene
  end

  def getMaxAddableItems(item)
    pocket = GameData::Item.get(item).pocket
    list = $bag.pockets[pocket]
    maxPocketSize = Settings::BAG_MAX_POCKET_SIZE[pocket - 1]
    return maxPocketSize if maxPocketSize < 0
    maxPerSlot = Settings::BAG_MAX_PER_SLOT
    currItems = list.select { |slot| slot[0] == item }
    totCurrItems = currItems.sum { |slot| slot[1] }
    avSpaceInSlot = currItems.sum { |slot| maxPerSlot - slot[1] }
    avSlots = maxPocketSize - list.size
    totAddItems = avSpaceInSlot + (avSlots * maxPerSlot)
    return totAddItems
  end

  def pbSellScreen
    item = @scene.pbStartSellScene(@adapter.getInventory, @adapter)
    loop do
      item = @scene.pbChooseSellItem
      break if !item
      itemname       = @adapter.getDisplayName(item)
      itemnameplural = @adapter.getDisplayNamePlural(item)
      if !@adapter.canSell?(item)
        pbDisplayPaused(_INTL(@getSpeech[:CantSellItem]&.sample || "Oh, no. I can't buy {1}.", itemnameplural))
        next
      end
      price = @adapter.getPrice(item, true, @discount)
      qty = @adapter.getQuantity(item)
      next if qty == 0
      @scene.pbShowMoney
      if qty > 1
        qty = @scene.pbChooseNumber(
          _INTL(@getSpeech[:SellItemAmount]&.sample || "How many {1} would you like to sell?", itemnameplural), item, qty
        )
      end
      if qty == 0
        @scene.pbHideMoney
        next
      end
      price *= qty
      if pbConfirm(_INTL(@getSpeech[:SellItem]&.sample || "I can pay {1}.\nWould that be OK?", @adapter.getCurrencyPrice(price.to_s_formatted)))
        old_money = @adapter.getMoney
        $amount = @adapter.setChangeMoney(@adapter.getMoney + price)
        $stats.money_earned_at_marts += @adapter.getMoney - old_money
        qty.times { @adapter.removeItem(item) }
        Achievements.incrementProgress("ITEMS_SOLD",qty) if PluginManager.installed?("Mega MewThree's Achievement System")
        sold_item_name = (qty > 1) ? itemnameplural : itemname
        pbDisplayPaused(_INTL("You turned over the {1} and got {2}.",
                              sold_item_name, @adapter.getCurrencyPrice(price.to_s_formatted))) { pbSEPlay("Mart buy item") }
        @scene.pbRefresh
      end
      @scene.pbHideMoney
    end
    @scene.pbEndSellScene
  end
end

def checkOutOfStock(stock)
  return false if !$pokeMartTracker || $pokeMartTracker.nil? || !$pokeMartTracker[:items]
  filter = stock.select { |item| !$pokeMartTracker[:items].map { |it| it[:name] }.include?(item) }
  return false if filter.length != 0
  if $pokeMartTracker[:randomStock] && $pokeMartTracker[:randomStock]
    stockItems = $pokeMartTracker[:items].select { |item| $pokeMartTracker[:randomStock].include?(item[:name])}
  else
    stockItems = $pokeMartTracker[:items]
  end
  return stockItems.all? { |item| item[:limit] === 0}
end

def forcePokemonMartRefresh
  return if $ArckyGlobal.pokeMartTracker.empty?
  $ArckyGlobal.pokeMartTracker.each do |mapID, events|
    events.each do |eventID, values|
      next if values.nil? || values[:refresh] == "never"
      $ArckyGlobal.pokeMartTracker[mapID][eventID] = nil
    end
  end
  $game_switches[APMSettings::BillSwitch] = false
end

def pbSpeciesMart(stockWithLimit, speech: nil, discount: nil, currency: "money", random: nil, filter: "all")
  if currency.is_a?(String) 
    $currency = setCurrency(currency) 
  else  
    Console.echoln_li _INTL("An Item as currency is not supported for this type of market, it'll not use money as the currency instead.")
    $currency = setCurrency("money")
  end 
  stockWithLimit = getItemStock(stockWithLimit)
  return if stockWithLimit.empty?
  refreshRate, stock = extractStock(stockWithLimit)
  if stock.nil?
    Console.echoln_li _INTL("The given stock does not exist")
    return 
  elsif stock.empty?
    Console.echoln_li _INTL("The stock cannot be empty!")
    return
  end 
  $pokeMartTracker = createPokeMartTracker(stock.map {|i| [i, 1]}.unshift("never"), "never", true)
  $itemCurrencyPrizes = !$currency.is_a?(String) ? getItemStockPrice(stockWithLimit) : nil 
  stock = editSpeciesBadge(stock)
  stock = getRandomStock(stock, random) if random
  stock = filterSpeciesStock(stock, filter)
  getSpeech = getChosenSpeech(speech)
  if getSpeech.nil?
    Console.echoln_li _INTL("The given speech does not exist")
    return 
  end 
  if checkOutOfStock(stock)
    pbMessage(_INTL(getSpeech[:EverythingOutOfStock]&.sample || "Subarashi! You bought my whole stock! Come back again when I have new stock for you!"))
  else 
    pbMessage(_INTL(getSpeech[:IntroSpecies]&.sample || "Hello, I have an exclusive offer for you, interested?"))
    scene = SpeciesMart_Scene.new
    screen = SpeciesMartScreen.new(scene, stock, getSpeech, nil, nil, discount, true, stockWithLimit.drop(0))
    screen.pbSpeciesScreen
    if checkOutOfStock(stock)
      pbMessage(_INTL(getSpeech[:EverythingOutOfStock]&.sample || "Subarashi! You bought my whole stock! Come back again when I have new stockfor you!"))
    else
      pbMessage(_INTL(getSpeech[:OutroSpecies]&.sample || "Do come again, maybe..."))
    end 
    $ArckyGlobal.pokeMartTracker[@map_id][@event_id] = $pokeMartTracker unless $pokeMartTracker&.empty?
    $game_temp.clear_mart_prices
  end 
end

def pbShelfMart(stockWithLimit, speech: nil, useCat: false, discount: nil, currency: "money")
  if currency.is_a?(String) 
    $currency = setCurrency(currency) 
  else  
    Console.echoln_li _INTL("An Item as currency is not supported for this type of market, it'll not use money as the currency instead.")
    $currency = setCurrency("money")
  end 
  refreshRate, stock = extractStock(stockWithLimit)
  $pokeMartTracker = createPokeMartTracker(stockWithLimit, refreshRate)
  $itemCurrencyPrizes = !$currency.is_a?(String) ? getItemStockPrice(stockWithLimit) : nil 
  stock = editStockBadgeOrImportant(stock)
  getSpeech = getChosenSpeech(speech)
  pbMessage(_INTL(getSpeech[:IntroShelf]&.sample || "Is there anything catching your eye?"))
  scene = PokemonMart_Scene.new
  screen = PokemonMartScreen.new(scene, stock, getSpeech, nil, nil, discount)
  screen.pbShelfScreen
  $ArckyGlobal.pokeMartTracker[@map_id][@event_id] = $pokeMartTracker unless $pokeMartTracker&.empty?
  $ArckyGlobal.pokeMartTracker[@map_id][@event_id][:bill] = $bill
  $game_temp.clear_mart_prices
end

def pbPokemonMart(stockWithLimit, speech: nil, useCat: false, discount: nil, currency: "money", cantSell: false, billEnd: false, random: nil)
  $currency = currency.is_a?(String) ? setCurrency(currency) : setItemCurrency(currency)
  $initialCurrency = $currency.dup.freeze
  stockWithLimit = getItemStock(stockWithLimit)
  return if stockWithLimit.empty?
  refreshRate, stock = extractStock(stockWithLimit)
  # no speech given (optional useCat, discount, currency and cantSell):
  $pokeMartTracker = createPokeMartTracker(stockWithLimit, refreshRate, false)
  $itemCurrencyPrizes = !$currency.is_a?(String) ? getItemStockPrice(stockWithLimit) : nil 
  if !$currency.is_a?(String) && cantSell == false 
    Console.echoln_li _INTL("Selling is not allowed when using an Item as the currency for the store, please disable selling for this event.")
    cantSell = true 
  end 
  stock = editStockBadgeOrImportant(stock)
  stock = getRandomStock(stock, random) if random
  getSpeech = getChosenSpeech(speech)
  canCheckOut = checkBillAndStoreCurrency && $game_switches[APMSettings::BillSwitch]
  commands, cmdBuy, cmdSell, cmdBill, cmdQuit = setCommands(cantSell, getSpeech, stock, canCheckOut)
  # commands has only leave option or not cmd bill and no more stock and other items without limit
  if (commands.length === 1 || !cmdBill && checkOutOfStock(stock))
    pbMessage(_INTL(getSpeech[:EverythingOutOfStock]&.sample || "I'm out of stock now, come back {1}", $pokeMartTracker[:refresh]))
    return
  end
  introText = getTimeOfDay(getSpeech, "Intro")
  cmd = pbMessage(_INTL(introText&.sample || "Welcome! How may I help you?"), commands, cmdQuit + 1)
  loop do
    catStock = []
    if cmdBuy >= 0 && cmd == cmdBuy
      if useCat
        stockByCat = convertStockByCategories(stockByCat, stock)
        choice = !speech.nil? && !(getSpeech[:CategoryText]&.empty?) ? pbMessage(_INTL(getSpeech[:CategoryText]&.sample), stockByCat.keys << "Go Back", -1) : 0
        if choice != -1 && choice != stockByCat.length
          choiceStock = stockByCat.values[choice]
          pbPlayDecisionSE
        end
      end
      unless choiceStock.nil? && useCat
        scene = PokemonMart_Scene.new
        screen = PokemonMartScreen.new(scene, stock, getSpeech, choiceStock, stockByCat, discount)
        screen.pbBuyScreen
      end
    elsif cmdSell >= 0 && cmd == cmdSell
      scene = PokemonMart_Scene.new
      screen = PokemonMartScreen.new(scene, stock, getSpeech)
      screen.pbSellScreen
    elsif cmdBill >= 0 && cmd == cmdBill
      payBill(getSpeech)
      $game_switches[APMSettings::BillSwitch] = false
      commands, cmdBuy, cmdSell, cmdBill, cmdQuit = setCommands(cantSell, getSpeech, stock, canCheckOut)
      if commands.length === 1
        pbMessage(_INTL(getSpeech[:EverythingOutOfStock]&.sample || "I'm out of stock now, come back {1}", $pokeMartTracker[:refresh]))
        break
      end
      if billEnd
        outroText = getTimeOfDay(getSpeech, "Outro")
        pbMessage(_INTL(outroText&.sample || "Do come again!"))
        break
      end
    else
      outroText = getTimeOfDay(getSpeech, "Outro")
      pbMessage(_INTL(outroText&.sample || "Do come again!"))
      break
    end
    if checkOutOfStock(stock)
      pbMessage(_INTL(getSpeech[:EverythingOutOfStock]&.sample || "I'm out of stock now, come back {1}", $pokeMartTracker[:refresh]))
      if cantSell
        cmdQuit = 2
        cmd = cmdQuit
      end
    else
      commands, cmdBuy, cmdSell, cmdBill, cmdQuit = setCommands(cantSell, getSpeech, stock, canCheckOut)
      cmd = pbMessage(_INTL(getSpeech[:MenuReturnText]&.sample || "Is there anything else I can do for you?"), commands, cmdQuit + 1)
    end
  end
  $ArckyGlobal.pokeMartTracker[@map_id][@event_id] = $pokeMartTracker unless $pokeMartTracker&.empty?
  $game_temp.clear_mart_prices
end

def setItemCurrency(currency)
  item = GameData::Item.try_get(currency)
  if !item 
    Console.echoln_li _INTL("#{currency} was not found in the Items PBS and cannot be used as the currency.")
    return "money"
  end 
  return item
end 

def setCommands(cantSell, getSpeech, stock, canCheckOut)
  commands = []
  cmdBuy  = -1
  cmdSell = -1
  cmdBill = -1
  cmdQuit = -1
  commands[cmdBuy = commands.length]  = _INTL(getSpeech[:MenuTextBuy]&.sample || "I'm here to buy") if !canCheckOut && !checkOutOfStock(stock)
  commands[cmdSell = commands.length] = _INTL(getSpeech[:MenuTextSell]&.sample || "I'm here to sell") if !cantSell && !canCheckOut
  commands[cmdBill = commands.length] = _INTL(getSpeech[:MenuTextBill]&.sample || "I'm here to checkout") if canCheckOut
  commands[cmdQuit = commands.length] = _INTL(getSpeech[:MenuTextQuit]&.sample || "No, thanks")
  return commands, cmdBuy, cmdSell, cmdBill, cmdQuit
end

def checkBillAndStoreCurrency
  $ArckyGlobal.pokeMartTracker[@map_id].any? do |eventID, keys|
    next if !keys.key?(:bill)
    keys[:bill][:currency] == $currency
  end 
end 

def createPokeMartTracker(stockWithLimit, refreshRate, buySpecies = false)
  date = pbGetTimeNow.strftime("%Y-%m-%d")
  $ArckyGlobal.pokeMartTracker ||= {}
  $ArckyGlobal.pokeMartTracker[@map_id] ||= {}
  $ArckyGlobal.pokeMartTracker[@map_id][@event_id] ||= {}
  pokeMartTracker = $ArckyGlobal.pokeMartTracker[@map_id][@event_id]
  $ArckyGlobal.pokeMartTracker[@map_id][@event_id][:bill] ||= {}
  $bill = $ArckyGlobal.pokeMartTracker[@map_id][@event_id][:bill]
  $bill = { :total => 0, :basket => {}, :currency => $currency, :event => @event_id } if $bill.empty?
  if stockWithLimit.any? {|item| item.is_a?(Array) }
    # get the days between the day that one item was out of stock and the day of checking again
    daysDiff = getPreviousRefreshDate(date)
    timeInDays = convertDays(refreshRate, daysDiff)
    if timeInDays.nil? && refreshRate != "never"
      $ArckyGlobal.pokeMartTracker[@map_id][@event_id] = {}
      timeInDays = convertDays(refreshRate, 0)
    end
    pokeMartTracker = $ArckyGlobal.pokeMartTracker[@map_id][@event_id]
    pokeMartTracker = { :date => date, :refresh => timeInDays, :items => getItemList(stockWithLimit.drop(1), buySpecies) } if pokeMartTracker.empty? || pokeMartTracker.length <= 1
    pokeMartTracker[:refresh] = timeInDays if !pokeMartTracker.empty?
  end
  return pokeMartTracker
end

def editStockBadgeOrImportant(stock)
  APMSettings::BadgesForItems.each do |badgeCount, badgeItems|
    if badgeCount > $player.badge_count
      badgeItems.each do |item|
        stock.delete(item)
      end
    end
  end
  stock.delete_if { |item| GameData::Item.get(item).is_important? && $bag.has?(item) }
  return stock
end

def editSpeciesBadge(stock)
  APMSettings::BadgesForSpecies.each do |badgeCount, badgeSpecies|
    if badgeCount > $player.badge_count
      badgeSpecies.each do |species|
        stock.delete(species)
      end 
    end 
  end 
  return stock
end 

def getRandomStock(stock, random)
  if !random[0]&.is_a?(String)
    Console.echoln_li _INTL("#{random[0]} should be the refresh time and needs to be a string.")
    return stock
  end
  if !random[1]&.is_a?(Integer)
    Console.echoln_li _INTL("#{random[1]} should be the amount of random items to select and needs to be an integer/number")
    return stock
  end
  if random[0].downcase == "random"
    Console.echoln_li _INTL("#{random[0]} is not a supported refresh rate for random items, please use 'daily', '2daily' or 'weekly' instead.")
    return stock
  end
  date = pbGetTimeNow.strftime("%Y-%m-%d")
  daysDiff = getPreviousRandomRefreshDate(date)
  timeInDays = convertDays(random[0], daysDiff)
  if timeInDays.nil? || !$pokeMartTracker[:randomStock]
    $pokeMartTracker[:randomStock] = stock.sample(random[1])
    timeInDays = convertDays(random[0], 0)
  end
  $pokeMartTracker[:randomDate] = date
  stock = $pokeMartTracker[:randomStock]
  return stock
end

def filterSpeciesStock(stock, filter)
  case filter 
  when "caught"
    return stock.select { |sp| $player.owned?(sp) }
  when "seen"
    return stock.select { |sp| $player.seen?(sp) }
  when "all"
    return stock
  else 
    if !filter.nil?
      Console.echoln_li _INTL("Unknown filter given.")
    end 
  end 
  return stock 
end 

def getChosenSpeech(speech)
  unless speech.nil?
    getSpeech = APMSettings.const_get(speech.gsub(" ", "")) if APMSettings.const_defined?(speech.gsub(" ", ""))
  else
    getSpeech = {}
  end
end

def convertStockByCategories(stockByCat, stock)
  stockByCat = Hash.new { |hash, key| hash[key] = [] }
  categoryHash = {}
  APMSettings::CategoryNames.each_with_index do |name, index|
    order = (index + 1) * 10
    categoryHash[name] = { order: order }
  end
  stock.each do |item|
    pocketName = APMSettings::CustomCategoryNames.find { |category, list| list[:items].include?(item) }&.first
    if pocketName.nil?
      pocketID = GameData::Item.get(item).pocket
      pocketName = APMSettings::CategoryNames[pocketID-1]
    end
    stockByCat[pocketName] << item
  end
  stockByCat = stockByCat.sort_by do |key, _|
    order = categoryHash[key]&.dig(:order) || APMSettings::CustomCategoryNames[key]&.dig(:order)
    order || Float::INFINITY
  end.to_h
  return stockByCat
end

def getPreviousRefreshDate(date)
  pokeMartTracker = $ArckyGlobal.pokeMartTracker[@map_id][@event_id]
  return 0 if pokeMartTracker.empty? || pokeMartTracker.length <= 1 || !pokeMartTracker[:date]
  return ((getDateFromString(date) - getDateFromString(pokeMartTracker[:date].to_s)) / (24 * 60 * 60)).round(0)
end

def getPreviousRandomRefreshDate(date)
  pokeMartTracker = $ArckyGlobal.pokeMartTracker[@map_id][@event_id]
  return 0 if pokeMartTracker.empty? || pokeMartTracker.length <= 1 || !pokeMartTracker[:randomDate]
  return ((getDateFromString(date) - getDateFromString(pokeMartTracker[:randomDate].to_s)) / (24 * 60 * 60)).round(0)
end

def convertDays(refreshRate, daysDiff)
  if refreshRate.nil?
    Console.echoln_li _INTL("No refresh rate was set for the items with a limit.")
    return -1
  end
  case refreshRate.downcase
  when "daily"
    days = 1
  when "2daily"
    days = 2
  when "weekly"
    days = 7
  when "random"
    unless $ArckyGlobal.pokeMartTracker[@map_id][@event_id].empty?
      refresh = $ArckyGlobal.pokeMartTracker[@map_id][@event_id][:refresh]
      case refresh
      when "in a week"
        days = 7
      when /in (\d+) days/
        days = refresh[/\d+/].to_i
      when "tomorrow"
        days = 1
      end
    else
      days = rand(1..7)
    end
  else
    days = -1
  end
  time = days - daysDiff
  time = 0 if time < 0
  case time.round(0)
  when 1
    return "tomorrow"
  when 2..6
    return "in #{time.to_i} days"
  when 7
    return "in a week"
  when 0
    return nil
  else
    return "never"
  end
end

def getItemList(stock, buySpecies = false)
  itemList = []
  newStock = stock.select { |item| item.is_a?(Array) && !item[1].nil? }
  newStock.each do |item|
    item = item[0...-1] if !$currency.is_a?(String)
    next if item[1].nil? || item[1].is_a?(Array)
    item[2] = item[1] if item[2].nil?
    if item[1] > item[2] && !buySpecies
      Console.echoln_li _INTL("The min limit can't be bigger than the max limit for :#{item[0]}")
      next
    end
    limit = !buySpecies ? rand(item[1]..item[2]) : 1
    entry = { :name => item[0], :limit => limit }
    itemList << entry
  end
  return itemList
end

def getItemStockPrice(stock)
  prizes = []
  stock.each do |item|
    next if item.is_a?(String) || !item.is_a?(Array)
    if item.last.is_a?(Array)
      price = item.last[0].is_a?(Integer) ? item.last[0] : 1
      currency = item.last[1].is_a?(Symbol) ? item.last[1] : $currency 
      if (item.last[1].is_a?(String))
        Console.echoln_li _INTL("The specific currency for an item can only be another item, #{item.last[1]} is not allowed as the currency for #{item[0]}")
      end 
      prizes.push({ item[0] => { price: price, currency: currency }})
    else 
      prizes.push({ item[0] => { price: item.last } })
    end 
  end 
  return prizes
end

def getItemStock(stock)
  if stock.is_a?(String)
    if APMSettings::StockItems.key?(stock.to_sym)
      stock = APMSettings::StockItems[stock.to_sym]
    else
      Console.echoln_li _INTL("#{stock} does not exist in the StockItems setting.")
      stock = []
    end
  end
  return stock
end

def extractStock(stock)
  if stock[0].is_a?(String)
    refreshRate = stock[0]
    stock = stock.drop(1)
  end
  extractedStock = stock.map do |item|
    if item.is_a?(Array)
      item[0]
    elsif item.is_a?(Hash)
      if (item.key?(:name))
        if GameData::Species.try_get(item[:name])
          item[:name]
        else
          Console.echoln_li _INTL("Species with name: #{item[:name]} does not exist, please check the spelling.")
          next 
        end 
      else 
        Console.echoln_li _INTL("Missing name:")
        next 
      end 
    else
      item
    end
  end
  return refreshRate, extractedStock.compact
end

def getTimeOfDay(getSpeech, text)
  return if getSpeech.empty?
  weekDay = pbGetTimeNow.wday
  day = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday][weekDay]
  part = (weekDay == 0 || weekDay == 6) ? "Weekend" : "Week"
  time = if PBDayNight.isMorning?
            "Morning"
        elsif PBDayNight.isAfternoon?
            "Afternoon"
        elsif PBDayNight.isEvening?
            "Evening"
        elsif PBDayNight.isDay?
            "Day"
        elsif PBDayNight.isNight?
            "Night"
        end
  output = "#{text}#{day}#{time}".to_sym
  fallback = {
    "Morning" => ["#{text}TextMorning#{day}".to_sym, "#{text}TextDay#{day}".to_sym, "#{text}Text#{day}".to_sym, "#{text}TextMorning#{part}".to_sym, "#{text}TextDay#{part}".to_sym, "#{text}Text#{part}".to_sym, "#{text}TextMorning".to_sym, "#{text}TextDay".to_sym, "#{text}Text".to_sym],
    "Day" => ["#{text}TextDay#{day}".to_sym, "#{text}Text#{day}".to_sym, "#{text}TextDay#{part}".to_sym, "#{text}Text#{part}".to_sym, "#{text}TextDay".to_sym, "#{text}Text".to_sym],
    "Afternoon" => ["#{text}TextAfternoon#{day}".to_sym, "#{text}TextDay#{day}".to_sym, "#{text}Text#{day}".to_sym, "#{text}TextAfternoon#{part}".to_sym, "#{text}TextDay#{part}".to_sym, "#{text}Text#{part}".to_sym, "#{text}TextAfternoon".to_sym, "#{text}TextDay".to_sym, "#{text}Text".to_sym],
    "Evening" => ["#{text}TextEvening#{day}".to_sym, "#{text}TextDay#{day}".to_sym, "#{text}Text#{day}".to_sym, "#{text}TextEvening#{part}".to_sym, "#{text}TextDay#{part}".to_sym, "#{text}Text#{part}".to_sym, "#{text}TextEvening".to_sym, "#{text}TextDay".to_sym, "#{text}Text".to_sym],
    "Night" => ["#{text}TextNight#{day}".to_sym, "#{text}Text#{day}".to_sym, "#{text}TextNight#{part}".to_sym, "#{text}Text#{part}".to_sym, "#{text}TextNight".to_sym, "#{text}Text".to_sym]
  }
  fallbackOptions = fallback[time] || []
  fallbackOptions.each do |fallbackOption|
    return getSpeech[fallbackOption] unless getSpeech[fallbackOption]&.empty? || getSpeech[fallbackOption].nil?
  end
  return getSpeech[text.to_sym]
end

def getBonusItems(item, adapter, quantity, speech = nil, retBonus = false)
  bonus = APMSettings::BonusItems[item]
  item = :POKEBALL if !bonus && GameData::Item.get(item).is_poke_ball?
  if bonus
    if quantity && bonus[:amount]
      if quantity >= bonus[:amount]
        bonusItem = []
        bItem = nil
        itemsWithChance = 0
        totalChance = 0
        if bonus[:item].is_a?(Array) || bonus[:item].is_a?(Hash)
          bonus[:item].each do |item, prop|
            next unless prop && (prop.is_a?(Numeric) || (prop.is_a?(Hash) && prop.key?(:chance)))
            if prop.is_a?(Hash)
              totalChance += prop[:chance]
            else
              totalChance += prop
            end
            itemsWithChance += 1
          end
          if itemsWithChance == bonus[:item].length
            if totalChance != 100
              factor = 100.0 / totalChance
              if bonus[:item].is_a?(Array) || bonus[:item].is_a?(Hash)
                array = bonus[:item].map do |key, value|
                  if value.is_a?(Numeric)
                    [key, value * factor]
                  elsif value.is_a?(Hash)
                    [key, value[:chance] * factor, value[:amount] || 1]
                  end
                end
                bonus[:item] = array
              end
            end
          else
            remChance = 100 - totalChance
            itemsWithoutChance = bonus[:item].length - itemsWithChance
            if itemsWithoutChance > 0
              indChance = remChance.to_f / itemsWithoutChance
              array = bonus[:item].map do |key, value|
                if !value
                  [key, indChance]
                elsif value.is_a?(Hash)
                  [key, value[:chance] || indChance, value[:amount] || 1]
                else
                  item
                end
              end
              bonus[:item] = array
            end
          end
          bonusArray = []
          numb = 0
          bonus[:item].each do |item, chance|
            numb += chance
            bonusArray << [item, numb]
          end
        end
        qty = 1
        counter = 0
        (quantity / bonus[:amount]).times do
          if bonus[:item].is_a?(Array) || bonus[:item].is_a?(Hash)
            ranChance = rand(1..1000).to_f / 10
            bItem = bonusArray.find { |item, chance| chance.to_f >= ranChance }[0]
            qty = bonus[:item].find {|itm| itm[0] == bItem }[2] || 1
          else
            bItem = bonus[:item]
          end
          counter += qty
          qty.times do
            break if !adapter.addItem(bItem)
            bonusItem << bItem
          end
        end
        tallyItems = bonusItem.tally.map do |item, amount|
          name = GameData::Item.get(item).name
          name = GameData::Item.get(item).name_plural if amount > 1
          "#{amount} #{name}"
        end
        added = [counter == bonusItem.length, counter > bonusItem.length]
        return tallyItems, added if retBonus
        string = mergeArrayToString(tallyItems)
        outputString = getBonusItemsString(added, string, speech)
        pbDisplayPaused(outputString)
      end
    else
      Console.echoln_li _INTL("There's no :amount defined for :#{item} in BonusItems.")
    end
  else
    Console.echoln_li _INTL(":#{item} has no bonus item(s) defined in BonusItems (ignore if intented).")
  end
end

def getBonusItemsString(added, string, speech)
  if added[0] && !string.nil? # All bonus Items were added.
    return _INTL(speech[:BuyBonusMult]&.sample || "And have {1} on the house!", string)
  elsif added[1] && !string.nil? # not all bonus Items were added.
    return _INTL("And have {1} on the house! (Not all bonus items were added, not enough room in your bag.)", string)
  else
    return _INTL("You have not enough room in your bag for the bonus items.")
  end
end

def countPurchasedItem(item, quantity)
  APMSettings::ItemPurchaseCounter.each { |var, items|
    if items.include?(item)
      if !$game_variables[var].is_a?(Integer)
        Console.echoln_li _INTL("Game variable #{var} is not a number!")
        break
      end
      $game_variables[var] += quantity
    end
  }
end

class Window_PokemonMart < Window_DrawableCommand
  def initialize(stock, adapter, x, y, width, height, viewport = nil, discount = nil)
    @stock       = stock
    @adapter     = adapter
    @discount    = discount
    super(x, y, width, height, viewport)
    if Essentials::VERSION.include?("21")
      @selarrow    = AnimatedBitmap.new("Graphics/UI/Mart/cursor")
    else
      @selarrow    = AnimatedBitmap.new("Graphics/Pictures/martSel")
    end
    @baseColor   = Color.new(88, 88, 80)
    @shadowColor = Color.new(168, 184, 184)
    @baseColor2  = Color.new(160, 160, 168)
    @shadowColor2 = Color.new(208, 208, 216)
    @baseColor3 = Color.new(232, 32, 16)
    @shadowColor3 = Color.new(248, 168, 184)
    self.windowskin = nil
  end

  def itemCount
    return @stock.length + 1
  end

  def item
    return (self.index >= @stock.length) ? nil : @stock[self.index]
  end

  def drawItem(index, count, rect)
    textpos = []
    rect = drawCursor(index, rect)
    ypos = rect.y
    if index == count - 1
      textpos.push([_INTL("CANCEL"), rect.x, ypos + 2, :left, self.baseColor, self.shadowColor])
    else
      item = @stock[index]
      itemname = @adapter.getDisplayName(item)
      qty = @adapter.getDisplayPrice(item, @discount)
      entry = $pokeMartTracker[:items].find { |entry| entry[:name] == item} if $pokeMartTracker.key?(:items)
      if !entry.nil? && entry[:limit] == 0
        itemname = itemname.gsub(/\s*\(Lv\. \d+\)/, "")
        qty = "Out of Stock"
      end
      baseColor = qty == "Out of Stock" ? @baseColor2 : self.baseColor
      shadowColor = qty == "Out of Stock" ? @shadowColor2 : self.shadowColor
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2 - 16
      # Item specific currency
      if $itemCurrencyPrizes
        currentItem = { item: item, data: $itemCurrencyPrizes.find { |i| i.key?(item) }&.[](item) }
        currency = !currentItem[:data].nil? && currentItem[:data].key?(:currency) ? GameData::Item.try_get(currentItem[:data][:currency]) : $initialCurrency
        xQty -= 18
        pbDrawImagePositionsScalable(self.contents, [[GameData::Item.icon_filename(currency), rect.width-18, ypos+8, 0, 0, 128, 128, 64, 64]])
        if $bag.quantity(currency) < @adapter.getPrice(item, @discount)
          baseColor = @baseColor3
          shadowColor = @shadowColor3
        end 
      end
      textpos.push([itemname, rect.x, ypos + 2, :left, baseColor, self.shadowColor])
      textpos.push([qty, xQty, ypos + 2, :left, baseColor, self.shadowColor])
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

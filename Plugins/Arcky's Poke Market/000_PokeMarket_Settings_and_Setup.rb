module APMSettings
  # By default these are set to the Pocket names, you can name them anything you want but you should respect the Pocket Order.
  # Unless you've modified this. Not all Categories are shown each time, for example, "Key Items" would probably never be shown (these are filtered out by the script by default).
  CategoryNames = PokemonBag.pocket_names.map { |pocket| pocket.to_s }

  CustomCategoryNames = {
    "Evolution Stones" => {
      :items => [:FIRESTONE, :THUNDERSTONE, :WATERSTONE, :LEAFSTONE, :MOONSTONE, :SUNSTONE, :DUSKSTONE, :DAWNSTONE, :SHINYSTONE, :ICESTONE],
      :order => 11
    },
    "Type Plates" => {
      :items => [:FLAMEPLATE, :SPLASHPLATE, :ZAPPLATE, :MEADOWPLATE, :ICICLEPLATE, :FISTPLATE, :TOXICPLATE, :EARTHPLATE, :SKYPLATE, :MINDPLATE, :INSECTPLATE, :STONEPLATE, :SPOOKYPLATE, :DRACOPLATE, :DREADPLATE, :IRONPLATE, :PIXIEPLATE],
      :order => 12
    },
    "Type Gems" => {
      :items => [:FIREGEM, :WATERGEM, :ELECTRICGEM, :GRASSGEM, :ICEGEM, :FIGHTINGGEM, :POISONGEM, :GROUNDGEM, :FLYINGGEM, :PSYCHICGEM, :BUGGEM, :ROCKGEM, :GHOSTGEM, :DRAGONGEM, :DARKGEM, :STEELGEM, :FAIRYGEM, :NORMALGEM],
      :order => 13
    }
  }

  BadgesForItems = {
    1 => [:GREATBALL, :SUPERPOTION, :ANTIDOTE, :PARALYZEHEAL, :AWAKENING, :BURNHEAL, :ICEHEAL, :REPEL, :ESCAPEROPE],
    3 => [:HYPERPOTION, :SUPERREPEL, :REVIVE],
    5 => [:ULTRABALL, :FULLHEAL, :MAXREPEL],
    7 => [:MAXPOTION],
    8 => [:FULLRESTORE]
  }

  BadgesForSpecies = {
    1 => [:GROWLITHE],
    2 => [:BULBASAUR, :SQUIRTLE],
    3 => [:CHARMANDER]
  }

  StockItems = {
    :normalStore => [
      :POKEBALL, :GREATBALL, :ULTRABALL,
      :POTION, :SUPERPOTION, :HYPERPOTION, :MAXPOTION,
      :FULLRESTORE, :REVIVE,
      :REPEL, :SUPERREPEL, :MAXREPEL,
      :ANTIDOTE, :BURNHEAL, :ICEHEAL, :AWAKENING, :PARALYZEHEAL, :FULLHEAL
    ],
    :limitStore => ["daily",
      [:POKEBALL, 10, 18], [:GREATBALL, 12, 16], [:ULTRABALL, 8, 15],
      :POTION, :SUPERPOTION, :HYPERPOTION, :MAXPOTION,
      [:FULLRESTORE, 20, 25], :REVIVE,
      :REPEL, [:SUPERREPEL, 20], :MAXREPEL
    ],
    :randomStore => [
      :FLAMEPLATE, :SPLASHPLATE, :ZAPPLATE, :MEADOWPLATE, :ICICLEPLATE,
      :FISTPLATE, :TOXICPLATE, :EARTHPLATE, :SKYPLATE, :MINDPLATE,
      :INSECTPLATE, :STONEPLATE, :SPOOKYPLATE, :DRACOPLATE, :DREADPLATE,
      :IRONPLATE, :PIXIEPLATE
    ],
    :pokemonStore => [
      {
        name: :GROWLITHE, # :GROWLITHE for Kantonian Growlithe, :GROWLITHE_1 for Hisuian Growlithe
        price: 11000, # price of the species
        level: 25, # level of the species 
        description: "A cute Dog that can be dangerous too...", # description to show in the Mart UI.
        ability: 1, # ability of the species 
        nickname: "Doggo", # nickname of the species 
        gender: 0, # male or 0, female or 1, genderless = 2
        item: :MASTERBALL, # held item
        pokeball: :CHERISHBALL, # pokemon species is caught in 
        nature: :RELAXED, # nature of the species 
        form: 0, # form of the species (if you provide this, make sure the name parameter matches)
        obtain: { # obtain details
          level: 15, # level when it was obtained
          map: 24, # map it was obtained on
          method: 2, # 0 = met, 1 = egg received, 2 = traded and 4 = fateful encounter
          text: "Bought from a shady seller in Cedolan City...", # replaces obtain map with text.
        },
        owner: {
          id: 14458, # "random" or specify a number
          name: "Maurice", # owner name
          gender: 0, # 0 (male), 1 (female), 2 (mixed), 3 (unknown)
          language: 2, # 0 (unkown), 1 (japanese), 2 (english, default), 3 (french), 4 (italian), 5 (german), 7 (spanish), 8 (korean)
        },
        ivs: { # modify species ivs
          HP: 15,
          ATTACK: 25,
          DEFENCE: 25,
          SPECIAL_ATTACK: 15,
          SPECIAL_DEFENCE: 25,
          SPEED: 31 
        },
        evs: { # modiy species evs
          HP: 20,
          ATTACK: 110,
          DEFENCE: 30,
          SPECIAL_ATTACK: 110,
          SPECIAL_DEFENCE: 50,
          SPEED: 200
        },
        shiny: 8, # = 1/8, true or false by default 
        supershiny: false, # same as shiny, set a chance, true or false by default
        moves: [ # set the moves for the species, adding more than 4 will make the first one get replaced by the 5th.
          :FIREBLAST,
          :FLAMETHROWER,
          :EXTREMESPEED,
          :OUTRAGE,
          :TACKLE
        ].sample(4), # use .sample(4) to have a random selection of 4 moves if you added more than 4 moves
        cannotstore: false, # species cannot be stored in the pc
        cannottrade: false, # species cannot be traded
        cannotrelease: false,  # species cannot be released
        happiness: "walking", # events are possible too: walking, levelup, groom, evberry, vitamin, wing, machine, battleitem, faint, faintbad, powder, energyroot, revivalherb
        pokerus: 16, # a number between 1 and 15 or 0 for random.
        status: :SLEEP # set the status of the species
      },
      {
        name: :BULBASAUR, 
        price: 9500,
        level: 15
      },
      {
        name: :CHARMANDER,
        price: 9500,
        level: 15
      },
      {
        name: :SQUIRTLE,
        price: 9500,
        level: 15
      },
      {
        name: :PIKACHU,
        price: 8500,
        level: 20
      }
    ]
  }

  # if this is set to true, if a species is shiny (either guaranteed or by chance), the icon will be the shiny one
  ShowShinySpecies = true 
  Discounts = {
    :COUPONA => {
      26 => [0, 3, 6, 8, 10],
      28 => [0, -2, -5]
    },
    27 => [0, 1, 4, 7, 11],
    :COUPONB => {
      29 => [10, 8, 6, 4, 2, 0, -2, -4, -6, -8, -10, -12]
    }
  }

  ItemPurchaseCounter = {
    101 => [:POKEBALL, :GREATBALL, :ULTRABALL],
    102 => [:POTION, :SUPERPOTION, :HYPERPOTION]
  }

  BonusItems = {
    :POKEBALL => {
      :amount => 5,
      :item => :PREMIERBALL
    },
    :GREATBALL => {
      :amount => 10,
      :item => [
        [:GREATBALL, 80],
        [:PREMIERBALL, 20]
      ]
    },
    :ULTRABALL => {
      :amount => 5,
      :item => {
        :PREMIERBALL => {
          :amount => 3
        },
        :MASTERBALL => {
          :chance => 0.1
        },
        :ULTRABALL => {
          :amount => 2,
          :chance => 5
        }
      }
    },
    :POTION => {
      :amount => 5,
      :item => {
        :ANTIDOTE => {
          :amount => 2
        },
        :PARALYZEHEAL => {
          :amount => 2,
          :chance => 20
        },
        :ICEHEAL => {
          :amount => 2,
          :chance => 20
        },
        :BURNHEAL => {
          :amount => 2
        },
        :FULLHEAL => {
          :chance => 5
        }
      }
    },
    :FULLHEAL => {
      :amount => 10,
      :item => {
        :FULLHEAL => {
          :amount => 3
        }
      }
    }
  }

  BillSwitch = 99

  ProSeller = {
    # Text when talking to them. This is the default one.
    IntroText: ["Good Day, welcome how may I serve you?", "Hello, welcome, what can I mean for you?", "Hello, Welcome what can I get for you?"],
    # Text in the choice menu for buying.
    MenuTextBuy: ["I want to buy!"],
    # Text in the choice menu for selling.
    MenuTextSell: ["Give me your money!"],
    # Text in the choice menu for paying the bill.
    MenuTextBill: ["I'm paying my debt"],
    # Text in the choice menu for leaving.
    MenuTextQuit: ["Bye bye!"],
    # Text when choosing to buy item. (optional: If you make this empty( [] ), you'll go to the buy screen directly.)
    CategoryText: [], #["We listed our Items in Categories for you.","Exclusively for you, these are the Categories we have to offer."], # or CategoryText: [],
    # Text when choosing amount of item. {1} = item name.
    BuyItemAmount: ["So how many {1}?", "How many {1} would you like?"],
    # Text when choosing amount of item with discount. {1} = item name {2} = discount price {3} = original price.
    BuyItemAmountDiscount: ["There's a discount on {1}, they're {2} instead of {3}. How many would you like?"],
    # Text when choosing amount of item with overcharge. {1} = item name {2} = overcharge price {3} = original price.
    BuyItemAmountOvercharge: ["There's overcharge on {1}, you must pay {2} instead of {3}. So how many?"],
    # Text when buying 1 of an item. {1} = item vowel {2} = item name {3} = price.
    BuyItem: ["So you want {1} {2}?\nIt'll be {3}. All right?", "So you would like to buy {1} {2}?\nThat's going to cost you {3}!"],
    # Text when buying 2 or more of an item. {1} = amount {2} = item name (plural) {3} = price.
    BuyItemMult: ["So you want {1} {2}?\nThey'll be {3}. All right?"],
    # Text when buying important item (that you can only buy 1 off). {1} = item name {2} = price.
    BuyItemImportant: ["So you want {1}?\nIt'll be {2} . All right?"],
    # Text when wanted item is out of stock. {1} = item name (plural) {2} = time in days (tomorrow, in 2 days, in x days, in a week, next week etc.)
    BuyOutOfStock: ["We're really sorry, this item is currently out of stock. Come back {2}!", "We're sorry but we don't have any {1} left. Come back {2}!", "Come back {2} when we have more {1}."],
    # Text when bought item.
    BuyThanks: ["Here you are! Thank you!"],
    # Text when x or more of a kind of item is bought and is defined in BonusItems Setting. {1} = Bonus Item(s) name(s).
    BuyBonusMult: ["And have {1} on the house!"],
    # Text when you don't have enough money to buy x item(s).
    NotEnoughMoney: ["You don't have enough {1}."],
    # Text when you don't have enough room in your bag. (Only used if you have an item limit).
    NoRoomInBag: ["You have no room in your Bag."],
    # Text when selecting an item to sell. {1} = item name
    SellItemAmount: ["How many {1} would you like to sell?"],
    # Text when confirming amount of selected item to sell. {1} = price
    SellItem: ["I can pay {1}.\nWould that be OK?"],
    # Text when unable to sell selected item. {1} = item name
    CantSellItem: ["Oh, no. I can't buy {1}."],
    # Text when returning to menu to choose either buying, selling or exit.
    MenuReturnText: ["Is there anything else I can do for you?", "What else could I mean for you today?"],
    # Text when the NPC is checking the items in the basket. {1} = list of each amount and item {2} = total price to pay.
    BillCheckOut: ["Your basket contains {1} which comes to a total of {2}, please."],
    # Text when a single item is bought and added to the purchase count game variable.
    PurchaseCount: ["Congratulations, you've earned 1 loyalty point!"],
    # Text when more than 1 item is bought and added to the purchase count game variable. {1} amount of purchased items.
    PurchaseCountMult: ["Wow, amazing! You got {1} loyalty points!"],
    # Text when you bought everything out of stock for this store and nothing is left to buy (you can still allow selling). {1} = time in days (tomorrow, in 2days, in x days, in a week, next week etc.)
    EverythingOutOfStock: ["Well you bought everything I have in my stock. You can buy again {1}."],
    # Text when exiting.
    OutroText: ["Do come again!", "Thank you, I hope to see you again.", "Thank you for your purchase, come again!"],
    OutroTextSaturday: ["Thank you for your purchase. \nEnjoy the rest of your Saturday."]
  }

  ShelfOne = {
    # Text when talking to a shelf in the mart.
    IntroShelf: ["Is there anything catching your eye?", "How nice, you can buy items from the shelf now too! :P"],
    # Text when selecting an item that you haven't added to your basket yet. {1} = item name
    ShelfItemAmount: ["How many {1} would you like to add to your basket?"],
    # Text when selecting an item that you have already x amount of in your basket. {1} = item name {2} = amount of that item.
    ShelfItemAmountChange: ["You currently have {2} {1} in your basket, change it to how many?"],
    # Text when selecting an item that you have the max amount of in your basket (only when using item limits for that item). {1} item name
    ShelfItemAmountLimit: ["Your basket has all {1} in stock, change it to how many?"],
    # Text when selecting an item that is out of stock (after check out). {1} = item name (plural) {2} = time in days (tomorrow, in 2 days, in x days, in a week, next week etc.)
    ShelfOutOfStock: ["{1} are currently out of stock, come back {2}."],
    # Text when selecting an item that has a discount. {1} discount in percentage {2} = item name {3} = discount price {4} original price
    ShelfItemAmountDiscount: ["There's a discount on {2}, how many would you like?"],
    # Text when selecting an item that has an overcharge. {1} overcharge in percentage {2} = item name {3} = overcharge price {4} original price
    ShelfItemAmountOvercharge: ["There's an overcharge on {2}, how many would you like?"],
    # Text when selecting an item that you can't buy because you don't have enough money. {1} = currency {2} item name (plural)
    NotEnoughMoney: ["You don't have enough {1} to add any {2} to your basket."],
    # Text when selecting an item that you can't buy more off because you don't have enough money. {1} = currency {2} = item name (plural).
    NotEnoughMoneyItem: ["You are out of {1}. Change the quantity of {2} you have in your basket?"],
    # Text when changing amount of item that you couldn't buy more off because you don't have enough money. {1} = item name (plural)
    NotEnoughMoneyAmount: ["Change the amount of {1} in your basket to how many?"],
    # Text when increasing the amount of an item {1} = quantity {2} item name {3} bill increased by x amount.
    ShelfItemAmountIncrease: ["You added {1} {2} to your basket. Your bill was increased by {3}.", "{1} {2} have been added to your basket. Your bill was increased by {3}."],
    # Text when decreasing the amount of an item {1} = quantity {2} item name {3} bill decreased by x amount.
    ShelfItemAmountDecrease: ["You took {1} {2} out of your basket. Your bill was decreased by {3}."],
    # Text when removing an item from your basket (changing the amount to 0). {1} = quantity {2} item name {3} bill decreased by x amount.
    ShelfItemAmountRemove: ["You removed {1} {2} from you basket. Your bill was decreased by {3}.", "{1} {2} were removed from your basket. Your bill was decreased by {3}."],
  }

  PokeSeller = {
    # Text when talking to seller.
    IntroSpecies: ["Hey you! Want to see my exclusive offer?", "Hello, are you interested in my exclusive offer perhaps?"],
    # Text when talking to seller and selected species have already been bought. {1} = species name
    SpeciesOutOfStock: ["I don't have {1} anymore, you already bought it...", "You want another {1}? Well aren't you satisfied with 1 already?"],
    # Text when selecting species to buy. {1} = species name, {2} = species price
    BuySpecies: ["So you want {1}? That'll be {2}"],
    # Text when you don't have enough money to buy selected species. {1} = currency, {2} = species name
    NotEnoughMoney: ["You don't have enough {1} to buy {2}", "Please come back when you have enough {1}."],
    # Text when you have no more room in your PC Storage. {1} = species name
    NoRoomInStorage: ["Your PC Storage is full, you can't buy {1}"],
    # Text when buying species. {1} = species name
    SpeciesThanks: ["Thank you for your purchase, we hope you'll take good care for {1}."],
    # Text when you have bought all species in stock.
    EverythingOutOfStock: ["Amazing, you bought all my exclusive offers, I'm really rich now thanks to you!"],
    # Text when exiting.
    OutroSpecies: ["Come again and I might have more exclusive offers for you."]
  }
end

# If it would be easier to setup stores here then you only need to add an event script line saying pbStore1 or whatever you called the method.
# Since you're more limited in space in the event, it could be easier to manage your stores here (or you can make .rb files for each store)
# For the different option Arguments, check the guide as it's explained in detail in there.

def pbSomeMart
  pbPokemonMart(["2daily",
    [:POKEBALL, 10, 15], [:GREATBALL, 5], :ULTRABALL,
    [:POTION, 12, 19], :SUPERPOTION, :HYPERPOTION, :MAXPOTION,
    :FULLRESTORE, :REVIVE,
    :ANTIDOTE, :PARALYZEHEAL, :AWAKENING, :BURNHEAL, :ICEHEAL,
    :FULLHEAL,
    :REPEL, :SUPERREPEL, :MAXREPEL,
    :ESCAPEROPE, :TM11
  ], speech: "ProSeller", discount: 27, useCat: true, billEnd: true, currency: "money")
end

def pbStoreWithRandom
  pbPokemonMart("randomStore", random: ["daily", rand(1..4)], speech: "ProSeller", useCat: true, cantSell: true, currency: "coins")
end

def pbSomeShelf
  pbShelfMart(["daily",:POTION, :SUPERPOTION,
    :POKEBALL, :GREATBALL,
    :REPEL,
    :ANTIDOTE, :BURNHEAL, :ICEHEAL, :AWAKENING, :PARALYZEHEAL
  ], speech: "ShelfOne", discount: 29)
end

def pbSomeShelf2
  pbShelfMart([:POTION,
    :POKEBALL, :REPEL
  ], discount: 26, currency: "Coins")
end

def pbTmShelf
  pbShelfMart(
    ["daily",
      :TM01, :TM02, :TM03, :TM04, :TM05, :TM06, :TM07, :ESCAPEROPE
    ])
end

def pbSomeSpeciesMart
  pbSpeciesMart(
    "pokemonStore", speech: "PokeSeller", discount: 27, currency: "money",
  )
end

def apricornShop
  pbPokemonMart([
    [:HEAVYBALL, [1, :BLACKAPRICORN]], [:LUREBALL, [1, :BLUEAPRICORN]], [:FRIENDBALL, [1, :GREENAPRICORN]], [:LOVEBALL, [1, :PINKAPRICORN]], [:LEVELBALL, [1, :REDAPRICORN]], [:FASTBALL, [1, :WHITEAPRICORN]], [:MOONBALL, [1, :YELLOWAPRICORN]]
  ], speech: "ProSeller", useCat: true, currency: :YELLOWAPRICORN )
end

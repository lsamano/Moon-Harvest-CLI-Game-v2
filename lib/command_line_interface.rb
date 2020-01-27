class CommandLineInterface
  attr_accessor :farmer, :choice, :warning_message, :success_message, :chosen_livestock

  # Reusable TTY Prompts
  def select_prompt(string, array_of_choices)
    prompt = TTY::Prompt.new
    prompt.select(string, array_of_choices, filter: true)
  end

  def naming_prompt(string)
    prompt = TTY::Prompt.new
    name = prompt.ask(string, required: true)
    name.chomp
  end

  # Reusable warning notice
  def notice(string, color = :light_white)
    puts "-----------------------------------------------"
    puts ""
    puts string.colorize(color)
    puts ""
    puts "-----------------------------------------------"
    puts ""
  end

  # Method for farming actions that affect the field
  def farming(action)
    hash = farmer.seed_bag_hash{action[:search]}
    if hash.empty?
      self.warning_message = action[:empty]
      go_to_field
    else
      if action == farmer.planting
        puts "SEED BAGS IN INVENTORY".colorize(:yellow)
        farmer.brief_inventory
      end
      choice = select_prompt(action[:choose], hash)
      if action == farmer.harvesting
        choice.update(planted: 0)
      end
      choice.update(action[:action])
      self.success_message = action[:done]
      go_to_field
    end
  end

  # Method called to start the game
  def game_start
    opening
    first_menu
  end

  def start_audio(string)
    # change to true to turn on BGM, along with line 61
    if false
      pid = fork{ exec 'afplay', string }
    end
  end

  def stop_audio
    # change to true to turn on BGM, along with line 54
    if false
      pid = fork{ exec "killall", 'afplay' }
    end
  end

  # Opening header
  def opening
    system("clear")
    start_audio("./audio/01.mp3")
    puts ""
    puts ""
    puts "==============================================="
    puts ""
    puts "   Welcome to Moon Harvest: A Life in Space!"
    puts ""
    puts "==============================================="
    puts ""
    puts ""
  end

  # Menu options
  def opening_menu_options
    if Farmer.all.empty?
      [ "New Game", "Exit" ]
    else
      [ "Load Game", "New Game", "Delete File", "Exit" ]
    end
  end

  # First/opening menu options
  def first_menu
    choice = select_prompt("", opening_menu_options)
    case choice
    when "New Game"
      character_creation
    when "Load Game"
      character_menu
    when "Delete File"
      character_deletion
    when "Exit"
      exit_message
    end
  end

  # Start a New Game by creating a new Farmer
  def character_creation
    farmer_name = naming_prompt("What's your Farmer's name?")
    if Farmer.find_by(name: farmer_name)
      notice("A Farmer by that name already exists! \nPlease choose a different name.", :red)
      return character_creation
    else
      self.farmer = Farmer.create(name: farmer_name)
      choose_a_difficulty
      notice("You are Farmer #{self.farmer.name}. Welcome!".bold, :magenta)
      sleep(2.seconds)
      opening_sequence
    end
  end

  def choose_a_difficulty
    puts "Choose a difficulty."
    puts "Note:"
    puts "In Easy Mode, you start with a cow and sheep and 2000 G.".colorize(:cyan)
    puts "In Normal Mode, you start with a cow and 1500 G.".colorize(:green)
    puts "In Hard Mode, you start with no livestock and 1000 G.".colorize(:red)
    difficulty_choice = select_prompt("", [ "Easy", "Normal", "Hard" ])
    case difficulty_choice
    when "Easy"
      cow_name = naming_prompt("What's your cow's name?")
      sheep_name = naming_prompt("What's your sheep's name?")
      Livestock.create(animal_id: Animal.find_by(species: "cow").id, farmer_id: farmer.id, name: cow_name)
      Livestock.create(animal_id: Animal.find_by(species: "sheep").id, name: sheep_name)
    when "Normal"
      cow_name = naming_prompt("What's your cow's name?")
      Livestock.create(animal_id: Animal.first.id, farmer_id: farmer.id, name: cow_name)
      self.farmer.update(money: 1500)
    when "Hard"
      notice("The farmer life sure is hard!")
      self.farmer.update(money: 1000)
    end
  end

  # Opening Sequence when you start a new game
  def opening_sequence
    system("clear")
    notice("One day, while at the market...")
    puts "Note: Press enter to advance..."
    gets
    notice("... a small dog was on sale.")
    gets
    system("clear")
    notice("Apparently, the dog had lost their owner recently.".bold)
    gets
    notice("Vendor: SpaceLyft will be here in 20 minutes to \ntake the dog to the kennel. \nI'd take 'em, but the missus is allergic.")
    gets
    system("clear")
    notice("Do you want to take 'em?".bold)
    choice = select_prompt("", ["Yes"])
    dog_name = naming_prompt("Give your new dog a name.")
    Dog.create(name: dog_name, farmer: farmer)
    notice("#{farmer.dog.name} looks at you with curious eyes...")
    gets
    notice("Your space farming life with \nyour new companion starts now!".bold)
    gets
    system("clear")
    notice("... One week later...")
    gets
    notice("#{farmer.dog.name} is adjusting well to your farm life. \n\nHowever...")
    gets
    notice("It would be nice if you could buy #{farmer.dog.name} their own bed.".bold, :light_red)
    gets
    notice("One of the vendors at the marketplace is \nselling a dog bed for 10,000 G. \n\nMaybe you can buy it for #{farmer.dog.name}...?")
    gets
    system("clear")
    notice("You decide to save up 10,000 G to buy a dog bed!".bold)
    gets
    stop_audio
    start_audio("./audio/02.mp3")
    game_menu
  end

  # Load the file of an existing Farmer
  def character_menu
    choice = select_prompt("Choose a File", Farmer.pluck("name"))
    self.farmer = Farmer.find_by(name: choice)
    notice("Welcome back, Farmer #{self.farmer.name}!", :magenta)
    puts ""
    sleep(1.3)

    stop_audio
    # sleep(1.seconds)
    start_audio("./audio/02.mp3")
    game_menu
  end

  # Delete a Farmer file
  def character_deletion
    choice = select_prompt("Choose a File to Delete", Farmer.pluck("name"))
    self.farmer = Farmer.find_by(name: choice)
    confirmation = select_prompt("Are you absolutely sure you want to delete #{farmer.name}'s file? \nWARNING: This CANNOT be undone!", ["Yes, delete #{farmer.name}!", "Nevermind."])
    case confirmation
    when "Yes, delete #{farmer.name}!"
      farmer.destroy
      notice("File destroyed.", :red)
      sleep(2.seconds)
      game_start
    when "Nevermind."
      game_start
    end
  end

  # Header UI
  def print_status
    case farmer.season
    when "spring"
      ui_season_text = "🌸 Spring"
    when "summer"
      ui_season_text = "🏖 Summer"
    when "fall"
      ui_season_text = "🍁 Fall"
    when "winter"
      ui_season_text = "⛄️ Winter"
    end
    puts "Farmer #{farmer.name}".bold.colorize(:color => :black, :background => :light_white)
    puts "#{ui_season_text}, Day #{farmer.date}"
    puts "💰 #{farmer.money} G"
  end

  # Reusable game header, also prints warning/success messages
  def game_header(place)
    system("clear")
    print_status
    puts "==============================================="
    puts "                   #{place}"
    puts "==============================================="
    if self.warning_message
      notice(self.warning_message, :red)
      self.warning_message = nil
    elsif self.success_message
      notice(self.success_message, :light_green)
      self.success_message = nil
    end
  end

  def main_menu_options
    [ "Inventory", "Field", "Barn", "Home", "Town", "Market", "Exit" ]
  end

  # Main menu prompt
  def game_menu
    game_header("YOUR FARM")
    choice = select_prompt("MAIN MENU", main_menu_options)
    case choice
    when "Inventory"
      show_inventory
      game_menu
    when "Field"
      go_to_field
    when "Barn"
      go_to_barn
    when "Market"
      go_to_market
    when "Home"
      go_to_home
    when "Town"
      go_to_town
    when "Exit"
      exit_message
    end
  end

  def show_inventory
    game_header("INVENTORY")
    unplanted_hash = farmer.seed_bag_count_hash(0)
    if unplanted_hash.any?
      rows = []
      unplanted_hash.each do |seed_bag, amount_owned|
        crop = CropType.find_by(crop_name: seed_bag)
        one_row = []
        one_row << "#{seed_bag}".upcase.bold
        one_row << "#{crop.days_to_grow}"
        one_row << "x#{amount_owned}"
        rows << one_row
      end
      table = Terminal::Table.new(
        title: "SEED BAGS".colorize(:yellow),
        headings: ['Name', 'Days to Grow', 'Amount Owned'],
        rows: rows
      )
      table.align_column(1, :center)
      table.align_column(2, :center)
      puts table
    else
      puts "SEED BAGS".colorize(:yellow)
      puts "None."
      puts "-------------------------------------------"
    end
    puts ""
    harvested_hash = farmer.seed_bag_count_hash(1)
    if harvested_hash.any?
      rows = []
      harvested_hash.each do |ripe_seed, amount_owned|
        crop = CropType.find_by(crop_name: ripe_seed)
        one_row = []
        one_row << "#{ripe_seed}".upcase.bold
        one_row << "#{crop.sell_price} G"
        one_row << "x#{amount_owned}"
        rows << one_row
      end
      table = Terminal::Table.new(
        title: "HARVESTED CROPS".colorize(:light_green),
        headings: ['Name', 'Price per Crop','Amount Owned'],
        rows: rows
      )
      table.align_column(1, :center)
      table.align_column(2, :center)
      puts table
    else
      puts "HARVESTED CROPS".colorize(:light_green)
      puts "None."
      puts "-------------------------------------------"
    end
    puts ""
    if farmer.product_inventory_hash.any?
      rows = []
      farmer.product_inventory_hash.each do |product, amount|
        one_row = []
        animal = Animal.find_by(product_name: product)
        one_row << "#{product.upcase.bold}"
        one_row << "#{animal.sell_price} G"
        one_row << "x#{amount}"
        rows << one_row
        # puts "#{product.upcase.bold} x#{amount}"
      end
      animal_table = Terminal::Table.new(
        title: "ANIMAL PRODUCTS".colorize(:magenta),
        headings: ['Name', 'Price per Item', 'Amount Owned'],
        rows: rows
      )
      animal_table.align_column(1, :center)
      animal_table.align_column(2, :center)
      puts animal_table
    else
      puts "ANIMAL PRODUCTS".colorize(:magenta)
      puts "None."
      puts "-------------------------------------------"
    end
    select_prompt("Press Enter to Exit.", [ "Exit" ])
  end

  def field_options
    [ "Water", "Plant", "Harvest", "Destroy", "Inventory", "Exit" ]
  end

  # list of planted crops and their watered status
  def print_planted_seeds
    planted_seed_array = farmer.seed_bags.where("planted = ?", 1)
    if planted_seed_array.empty?
      notice("Your field is empty!\nWhy not try planting some seeds?", :red)
    else
      planted_seed_array.each do |seed_bag|
        puts "#{seed_bag.crop_type.crop_name}".upcase.bold
        puts "Growth: #{(seed_bag.growth/seed_bag.crop_type.days_to_grow.to_f*100).round(1)}%"
        if seed_bag.ripe?
          puts "Soil: This crop is ready to be harvested!".colorize(:light_green)
        elsif seed_bag.watered?
          puts "Soil: The soil is nice and damp.".colorize(:cyan)
        else
          puts "Soil: The soil is dry.".colorize(:yellow)
        end
        puts "-------------------------------------------"
      end
      puts ""
    end
  end

  def go_to_field
    game_header("FIELD")
    print_planted_seeds

    # new prompt for plant, water, harvest, destroy
    choice = select_prompt("What would you like to do?", field_options)
    case choice
    when "Plant"
      farming(farmer.planting)
    when "Water"
      farming(farmer.watering)
    when "Harvest"
      farming(farmer.harvesting)
    when "Destroy"
      planted_array = farmer.seed_bags.where("planted = ?", 1)

      if planted_array.empty?
        self.warning_message = "There's nothing in your field to destroy!"
        go_to_field
      else
        #puts brief numbered list of field crops
        planted_array.each_with_index do |planted_seed_bag, index|
          puts "#{index+1}. #{planted_seed_bag.crop_type.crop_name}     Growth: #{(planted_seed_bag.growth/planted_seed_bag.crop_type.days_to_grow.to_f*100).round(1)}%"
        end

        planted_hash = farmer.seed_bag_hash{planted_array}
        #planted_array.each_with_object({}).with_index{ |(seed_bag, hash), index| hash["#{index+1}. #{seed_bag.crop_type.crop_name}"] = seed_bag}
        choice = select_prompt("What would you like to destroy?", planted_hash)
        puts "-------------------------------------------"
        puts ""
        puts "This crop?"
        puts ""
        puts "#{choice.crop_type.crop_name}".upcase.bold
        puts "Growth: #{(choice.growth/choice.crop_type.days_to_grow.to_f*100).round(1)}%"
        puts ""
        confirmation = select_prompt("Are you absolutely sure you want to destroy your #{choice.crop_type.crop_name}?\nWARNING: This CANNOT be undone!", ["Destroy it!", "Nevermind"])
        case confirmation
        when "Destroy it!"
          choice.destroy
          system("clear")
          notice("The crop was destroyed...")
          sleep(2.seconds)
          go_to_field
        when "Nevermind"
          go_to_field
        end
      end
    when "Exit"
      game_menu
    end
  end

  def crop_options
    array = farmer.crops_in_season.pluck("crop_name")
    array << "Exit"
  end

  def go_to_barn
    game_header("BARN")
    # List of animals and their Status
    # Prompt to choose an animal or exit
    if farmer.livestocks_hash.empty?
      notice("You have no livestock!",:red)
      barn_options = ["Exit"]
    else
      print_livestocks
      barn_options = ["Select Animal", "Exit"]
    end
    choice = select_prompt("What would you like to do?", barn_options)
    case choice
    when "Select Animal"
      self.chosen_livestock = select_prompt("Choose one of your livestock.", farmer.livestocks_hash)
      pick_an_animal
    when "Exit"
      game_menu
    end
  end

  def pick_an_animal
    game_header("BARN")
    print_livestocks
    choice = select_prompt("What would you like to do with #{chosen_livestock.name}?", ["Brush", "Feed", "Milk/Shear", "Go Back"])
    case choice
    when "Brush"
      animal_care("brush")
    when "Feed"
      animal_care("feed")
    when "Milk/Shear"
      animal_care("get product")
    when "Go Back"
      go_to_barn
    end
  end

  def print_livestocks
    my_livestocks = farmer.livestocks
    rows = []
    my_livestocks.each do |livestock|
      one_row = []
      one_row << "#{livestock.name}".upcase.bold
      one_row << "#{livestock.animal.species}".capitalize
      hearts = ""
      number_of_hearts = (livestock.love.to_f/2).ceil
      number_of_hearts.times {|i| hearts << "❤️ "}
      one_row << "#{hearts}"
      one_row << (livestock.brushed? ? "✅" : "🔳")
      one_row << (livestock.fed? ? "✅" : "🔳")
      product_emoji = livestock.day_counter_for_product < livestock.animal.frequency ? "❌" : "⭕️"
      one_row << product_emoji
      rows << one_row
    end
    livestock_table = Terminal::Table.new :title => "LIVESTOCK".colorize(:magenta), :headings => ['Name', 'Type', 'Care Meter', 'Brushed', 'Fed', 'Product Ready?'], :rows => rows
    livestock_table.align_column(3, :center)
    livestock_table.align_column(4, :center)
    livestock_table.align_column(5, :center)
    puts livestock_table
  end

  def animal_care(action)
    if action == "brush"
      chosen_livestock.update(brushed: 1)
      self.success_message = "You brushed #{chosen_livestock.name}! They seem to like it."
      pick_an_animal
    elsif action == "feed"
      chosen_livestock.update(fed: 1)
      self.success_message = "You fed #{chosen_livestock.name}! They seem to like it."
      pick_an_animal
    elsif action == "get product"
      if chosen_livestock.day_counter_for_product < chosen_livestock.animal.frequency
        self.warning_message = "#{chosen_livestock.name} is not ready for you to do that!"
        return pick_an_animal
      else
        Product.create(livestock_id: chosen_livestock.id, farmer_id: farmer.id)
        chosen_livestock.update(day_counter_for_product: 0)
        if chosen_livestock.animal.species == "cow"
          self.success_message = "You milked #{chosen_livestock.name}!"
        elsif chosen_livestock.animal.species == "sheep"
          self.success_message = "You sheared #{chosen_livestock.name}'s wool!"
        end
        return pick_an_animal
      end
    end

  end

  def go_to_market
    game_header("MARKETPLACE")
    choice = select_prompt("Vendor: What would you like to do?", ["Buy Seeds", "Sell Crops", "Sell Animal Products", "About that Dog Bed...", "Go To Farm", "Go To Town"])
    case choice
    when "Buy Seeds"
      # list of seeds and prices
      puts "==========================================="
      puts ""
      rows = []
      farmer.crops_in_season.each do |crop_type|
        one_row = []
        one_row << "#{crop_type.crop_name}".upcase.bold
        one_row << "#{crop_type.days_to_grow}".bold
        one_row << "#{crop_type.buy_price}".bold + " G"
        rows << one_row
      end
      market_table = Terminal::Table.new :title => "#{farmer.season.titleize} Crops on Sale".bold.colorize(:magenta), :headings => ['Name', 'Days to Grow', 'Price'], :rows => rows
      market_table.align_column(1, :center)
      market_table.align_column(2, :center)
      puts market_table
      puts ""

      # new prompt selecting from list of seeds to buy
      choice = select_prompt("Vendor: What would you like to purchase?", crop_options)
      if choice == "Exit"
        go_to_market
      else
        chosen_bag = CropType.find_by(crop_name: choice)
        # Checks if the farmer has enough money to make the purchase
        if chosen_bag.buy_price > farmer.money
          self.warning_message = "Vendor: You don't have enough money to buy that!"
          go_to_market
        else
          confirmation = select_prompt("Buy one bag of #{choice}?", ["Yes", "No"])
          case confirmation
          when "Yes"
            new_crop = farmer.buy_seed_bag(chosen_bag)
            farmer.money -= chosen_bag.buy_price
            farmer.save
            self.success_message = "You bought a bag of #{choice} seeds!"
            go_to_market
          when "No"
            system("clear")
            go_to_market
          end
        end
      end

    when "Sell Crops"
      harvested_hash = farmer.seed_bag_count_hash(1)
      if harvested_hash.none?
        self.warning_message = "Vendor: Doesn't look like you have any crops \nto sell me."
      else
        total = 0
        harvested_hash.each do |crop_name, amount|
          crop = CropType.find_by(crop_name: crop_name)
          subtotal = crop.sell_price * amount
          puts "#{crop_name}".upcase.bold.colorize(:magenta) + " x #{amount} = #{subtotal} G"
          total += subtotal
        end
        puts "TOTAL: #{total} G".bold.colorize(:light_green)
        choice = select_prompt("Would you like to ship all your crops for #{total} G?", ["Yes, sell them all!", "No"])
        case choice
        when "Yes, sell them all!"
          to_sell = farmer.seed_bags.where("planted = ?", 0).where("harvested = ?", 1)
          to_sell.each do |seed_bag|
            seed_bag.destroy
          end
          farmer.money += total
          farmer.save
          self.success_message = "You sold all your crops for a profit! \nYou now have #{farmer.money} G."
        end
      end
      go_to_market

    when "About that Dog Bed..."
      game_header("MARKETPLACE")
      sentence = "Vendor: Oh, that thing? It costs " + "10,000".bold + " G."
      notice(sentence, :magenta)
      choice = select_prompt("Do you want to buy it?", [ "Yes", "No" ])
      case choice
      when "Yes"
        if farmer.money < 10000
          self.warning_message = "Vendor: Sorry, but you don't have enough cash! \nCome back when you have 10,000 G."
          go_to_market
        else
          game_finish
        end
      when "No"
        go_to_market
      end
    when "Sell Animal Products"
      if farmer.product_inventory_hash.empty?
        self.warning_message = "Vendor: Doesn't look like you have anything \nto sell me."
      else
        total = 0
        product_array = farmer.products.where("farmer_id = ?", farmer.id)
        new_product_hash = product_array.each_with_object(Hash.new(0)) do |product_instance, inv_hash|
          inv_hash[product_instance.livestock.animal.product_name] += 1
        end
        # binding.pry
        new_product_hash.each do |product_name, amount|
          animal = Animal.find_by(product_name: product_name)
          subtotal = animal.sell_price * amount
          puts "#{product_name}".upcase.bold.colorize(:magenta) + " x #{amount} = #{subtotal} G"
          total += subtotal
        end
        puts "TOTAL: #{total} G".bold.colorize(:light_green)
        choice = select_prompt("Would you like to sell all of your animal products for #{total} G?", ["Yes, sell them all!", "No"])
        case choice
        when "Yes, sell them all!"
          product_array.each do |product_instance|
            # binding.pry
            product_instance.destroy
          end
          farmer.money += total
          farmer.save
          self.success_message = "You sold all your animal products for a profit! \nYou now have #{farmer.money} G."
        end
      end
      go_to_market
    when "Go To Farm"
      game_menu
    when "Go To Town"
      go_to_town
    end
  end

  def town_choices
    [ "Speak to Clara", "Go To Market", "Back to Farm" ]
  end

  def go_to_town
    game_header("TOWN")
    notice("Welcome to Prospera Town!", :yellow)
    choice = select_prompt("What would you like to do?", town_choices)
    case choice
    when "Speak to Clara"
      game_header("CLARA")
      string = "\nYou say hello to Clara. \nShe glances up and gives you a slight \nnod before returning to her notebook.\n "
      notice(string)
      select_prompt("Press Enter to Exit.", ["Exit"])
      go_to_town
    when "Go To Market"
      go_to_market
    when "Back to Farm"
      game_menu
    end
  end

  def home_options
    [ "Sleep", "Rename...", "Go Outside" ]
  end

  def go_to_home
    game_header("HOME")
    notice(farmer.dog.flavor_text, :magenta)
    choice = select_prompt("What would you like to do?", home_options)
    case choice
    when "Sleep"
      sleep_sequence
      game_menu
    when "Rename..."
      rename_menu
    when "Go Outside"
      game_menu
    end
  end

  def sleep_sequence
    farmer.next_day
    system("clear")
    notice("🌕 You fell asleep...", :light_blue)
    # sleep(1.seconds)
    notice("☀️  Good morning!", :light_yellow)
    # sleep(1.seconds)
  end

  def rename_menu
    choice = select_prompt("Who would you like to rename?", ["#{farmer.name}", "#{farmer.dog.name}", "Nevermind"])
    case choice
    when "#{farmer.name}"
      new_name = naming_prompt("What is your new name?")
      if new_name == farmer.name
        self.warning_message = "That's already your name! \nGuess you changed your mind."
      elsif Farmer.find_by(name: new_name)
        self.warning_message = "A Farmer by that name already exists! \nPlease choose a different name."
      else
        farmer.update(name: new_name)
        self.success_message = "You've been renamed!"
      end
      return go_to_home
    when "#{farmer.dog.name}"
      new_name = naming_prompt("What is your dog's new name?")
      if new_name == farmer.dog.name
        self.warning_message = "That's already their name! \nGuess you changed your mind."
      else
        farmer.dog.update(name: new_name)
        self.success_message = "Your dog has been renamed!"
      end
      return go_to_home
    when "Nevermind"
      return go_to_home
    end
  end

  def exit_message
    puts "==============================================="
    puts ""
    puts "                   Good Bye!"
    puts ""
    puts "==============================================="
    stop_audio
    return puts ""
  end

  def game_finish
    system("clear")
    farmer.money -= 10000
    farmer.save
    notice("Yay! You bought a dog bed for #{farmer.dog.name}!".bold, :light_green)
    notice("                     FIN".bold, :light_magenta)
    puts "Press enter to exit.".colorize(:white)
    gets
  end
end

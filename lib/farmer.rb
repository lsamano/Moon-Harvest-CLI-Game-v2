class Farmer < ActiveRecord::Base
  has_many :seed_bags, :dependent => :destroy
  has_many :crop_types, through: :seed_bags
  has_many :livestocks, :dependent => :destroy
  has_many :products, :dependent => :destroy
  has_many :animals, through: :livestocks
  has_one :dog

  # Hash containing planting actions
  def planting
    {
      search: self.seed_bags.where("planted = ?", 0).where("harvested = ?", 0),
      empty: "You have no seeds you can plant!",
      choose: "Which seed would you like to plant?",
      take_action: lambda { |choice|
        choice.update(planted: 1)
        return "Planted!"
      },
      needs_brief_list: true,
      print_brief_list: -> do
        puts "SEED BAGS IN INVENTORY".colorize(:yellow)
        self.brief_inventory
      end
    }
  end

  # Hash containing harvesting actions
  def harvesting
    {
      search: self.seed_bags.where("planted = ?", 1).where("ripe = ?", 1),
      empty: "You have no crops you can harvest right now!",
      choose: "What would you like to harvest?",
      needs_brief_list: false,
      take_action: lambda { |choice|
        choice.update(harvested: 1, planted: 0)
        return "Harvested!"
      }
    }
  end

  # Hash containing watering actions
  def watering
    {
      search: self.seed_bags.where("planted = ?", 1).where("watered = ?", 0).where("ripe = ?", 0),
      empty: "You have no crops that need to be watered!",
      choose: "Which crop would you like to water?",
      needs_brief_list: false,
      take_action: lambda { |crop|
        crop.update(watered: 1)
        return "Watered!"
      }
    }
  end

  def destroying
    {
      search: self.seed_bags.where("planted = ?", 1),
      empty: "You have no crops to even destroy!",
      choose: "Which crop would you like to destroy?",
      needs_brief_list: true,
      print_brief_list: -> do
        puts "ALL PLANTED CROPS".colorize(:yellow)
        self.brief_planted_crops
      end,
      take_action: lambda { |choice|
        puts "-------------------------------------------"
        puts ""
        puts "This crop?"
        puts ""
        puts "#{choice.crop_type.crop_name}".upcase.bold
        puts "Growth: #{(choice.growth/choice.crop_type.days_to_grow.to_f*100).round(1)}%"
        puts ""
        prompt = TTY::Prompt.new
        confirmation = prompt.select("Are you absolutely sure you want to destroy your #{choice.crop_type.crop_name}?\nWARNING: This CANNOT be undone!", ["Destroy it!", "Nevermind"])
        case confirmation
        when "Destroy it!"
          choice.destroy
          return "The crop was destroyed."
        when "Nevermind"
          return "You chose not to destroy it."
        end
      }
    }
  end

  # Numbered list of seed bags owned. Yields to
  # the search criteria to narrow what is listed
  def seed_bag_hash
    array = yield
    array.each_with_object({}).with_index { |(seed_bag, hash), index|
      hash["#{index+1}. #{seed_bag.crop_type.crop_name}"] = seed_bag
    }
    #=> {"1. Turnip"=> <seed_bag_instance>, "2. Tomato"=> <seed_bag_instance>}
  end

  # Briefly lists seed bags in inventory
  def brief_inventory
    self.seed_bag_count_hash(0).each do |crop_name, amount|
      puts "#{crop_name}".upcase.bold + " x#{amount}"
    end
    #=> TURNIP x4
    #=> TOMATO x1
  end

  # puts brief numbered list of field crops
  def brief_planted_crops
    planted_array = self.seed_bags.where("planted = ?", 1)
    planted_array.each_with_index do |planted_seed_bag, index|
      puts "#{index+1}. #{planted_seed_bag.crop_type.crop_name}     Growth: #{(planted_seed_bag.growth/planted_seed_bag.crop_type.days_to_grow.to_f*100).round(1)}%"
    end
  end

  # returns counting hash for use in inventory and menus (tables)
  def seed_bag_count_hash(boolean)
    # boolean == 0 means unplanted seed bags
    # boolean == 1 means harvested crops
    seed_bag_array = self.crop_types.where("planted = ?", 0).where("harvested = ?", boolean)
    name_array = seed_bag_array.pluck("crop_name")
    name_array.each_with_object(Hash.new(0)) do |crop_name, inv_hash|
      inv_hash[crop_name] += 1
    end
    # => {"turnip"=>2, "radish"=>5} for unplanted seed bags or harvested crops
  end

  def product_inventory_hash
    # The .where below is done to query the database again for the newest data
    name_array = self.products.where("farmer_id = ?", self.id).map(&:product_name)

    name_array.each_with_object(Hash.new(0)) do |product_name, inv_hash|
      inv_hash[product_name] += 1
    end
  end

  def livestocks_hash
    self.livestocks.each_with_object({})
    .with_index{ |(livestock, hash), index|
      hash["#{index+1}. #{livestock.name}"] = livestock
    }
  end

  # returns array of crop_type instances that match the farmer's season
  def crops_in_season
    CropType.where("season = ?", self.season)
  end

  # determines date via total days past
  def date
    calc_date = self.day % 30
    calc_date == 0 ? 30 : calc_date
  end

  # determines season via total days past
  def season
    number = ((self.day - 1) / 30) % 4
    case number
    when 0
      return "spring"
    when 1
      return "summer"
    when 2
      return "fall"
    when 3
      return "winter"
    end
  end

  def next_day
    # increase day
    self.increment!(:day)

    # Dog updated
    if dog.petted == 1 && dog.love < 10
      dog.update(petted: 0, love: dog.love + 1)
    end

    # Crops updated
    planted_seed_array = self.seed_bags.where("planted = ?", 1)
    planted_seed_array.each do |seed_bag|
      if seed_bag.watered == 1
        seed_bag.increment!(:growth)
        seed_bag.update(watered: 0)
      end
      if seed_bag.growth >= seed_bag.crop_type.days_to_grow
        seed_bag.update(ripe: 1)
      end
    end

    # Animals updated
    livestock_array = self.livestocks
    livestock_array.each do |livestock|
      if livestock.day_counter_for_product < livestock.animal.frequency
        livestock.increment!(:day_counter_for_product)
      end
      if livestock.fed? && livestock.brushed? && livestock.love < 10
        livestock.increment!(:love)
      end
      livestock.update(fed: 0, brushed: 0)
    end
  end

  def buy_seed_bag(crop_type)
    SeedBag.create(
      farmer_id: self.id,
      crop_type_id: crop_type.id
    )
    self.update(money: self.money - crop_type.buy_price)
  end

  def buy_livestock(animal, name)
    Livestock.create(
      name: name,
      farmer_id: self.id,
      animal_id: animal.id
    )
    self.update(money: self.money - animal.buy_price)
  end
end

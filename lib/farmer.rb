class Farmer < ActiveRecord::Base
  has_many :seed_bags, :dependent => :destroy
  has_many :crop_types, through: :seed_bags
  has_many :livestocks, :dependent => :destroy
  has_many :products, :dependent => :destroy
  has_many :animals, through: :livestocks

  # Hash containing planting actions
  def planting
    {
      search: self.seed_bags.where("planted = ?", 0).where("harvested = ?", 0),
      empty: "You have no seeds you can plant!",
      choose: "Which seed would you like to plant?",
      done: "Planted!",
      action: {planted: 1}
    }
  end

  # Hash containing harvesting actions
  def harvesting
    {
      search: self.seed_bags.where("planted = ?", 1).where("ripe = ?", 1),
      empty: "You have no crops you can harvest right now!",
      choose: "What would you like to harvest?",
      done: "Harvested!",
      action: {harvested: 1}
    }
  end

  # Hash containing watering actions
  def watering
    {
      search: self.seed_bags.where("planted = ?", 1).where("watered = ?", 0).where("ripe = ?", 0),
      empty: "You have no crops that need to be watered!",
      choose: "Which crop would you like to water?",
      done: "Watered!",
      action: {watered: 1}
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
    # The line below is done to query the database again for the newest data
    product_array = self.products.where("farmer_id = ?", self.id)
    #.map{ |i| i.livestock.animal.product_name}

    product_array.each_with_object(Hash.new(0)) do |product_instance, inv_hash|
      inv_hash[product_instance.livestock.animal.product_name] += 1
    end
  end

  def dog_flavor_text_array
    [
      "#{self.dog} is quietly snoring on your bed...",
      "Oh no! #{self.dog} found their way into the \nfridge and ate all of the string cheese!",
      "#{self.dog} seems to have constructed their \nown fort, made entirely of your boots.",
      "#{self.dog} excitedly jumps at you, barking. \nWelcome home!",
      "#{self.dog} is watching the Galactic News Network \non TV. Space Pirates appear to wreaking \nhavoc again...",
      "Gasp! #{self.dog} is missing! \n... Oh wait, they're right there on the sofa.",
      "#{self.dog} is playing with their favorite toy.\n It squeaks as they gnaw on it.",
      "#{self.dog} is watching TV. There is a \nparakeet on a branch. #{self.dog} really \nwants to touch it!",
      "#{self.dog} is starting to look a bit dirty. \nTime for a bath!"
    ]
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

  def next_day
    # increase day
    self.increment!(:day)

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
      "farmer_id": self.id,
      "crop_type_id": crop_type.id
    )
  end
end

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

  # Numbered list of seed bags owned. Yields to the search criteria to narrow
  # what is listed
  def seed_bag_hash
    array = yield
    array.each_with_object({}).with_index { |(seed_bag, hash), index|
      hash["#{index+1}. #{seed_bag.crop_type.crop_name}"] = seed_bag
    }
    #=> {"1. Turnip"=> <seed_bag_instance>, "2. Tomato"=> <seed_bag_instance>}
  end

  def seed_bag_inventory_hash
    seed_name_array = self.crop_types.where("planted = ?", 0).where("harvested = ?", 0).pluck("crop_name")
    seed_name_array.each_with_object(Hash.new(0)) do |crop_name, inv_hash|
      inv_hash[crop_name] += 1
    end
    #=> {"turnip"=>2, "radish"=>5} For unplanted seed bags
  end

  # Briefly lists seed bags in inventory
  def brief_inventory
    self.seed_bag_inventory_hash.each do |crop_name, amount|
      puts "#{crop_name}".upcase.bold + " x#{amount}"
    end
    #=> TURNIP x4
    #=> TOMATO x1
  end

  def ripe_seed_inventory_hash
    seed_name_array = self.crop_types.where("planted = ?", 0).where("harvested = ?", 1).pluck("crop_name")
    seed_name_array.each_with_object(Hash.new(0)) do |crop_name, inv_hash|
      inv_hash[crop_name] += 1
    end
    #=> {"turnip"=>2, "radish"=>5} For harvested crops
  end

  def product_inventory_hash
    # product_array = self.products.where("farmer_id = ?", self.id) #.map{ |i| i.livestock.animal.product_name}

    self.products.each_with_object(Hash.new(0)) do |product_instance, inv_hash|
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
    self.livestocks.each_with_object({}).with_index{ |(livestock, hash), index| hash["#{index+1}. #{livestock.name}"] = livestock}
  end

  def buy_seed_bag(crop_type)
    SeedBag.create(
      "farmer_id": self.id,
      "crop_type_id": crop_type.id
    )
  end
end

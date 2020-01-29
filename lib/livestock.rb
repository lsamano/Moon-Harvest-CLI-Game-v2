class Livestock < ActiveRecord::Base
  belongs_to :animal
  belongs_to :farmer
  has_many :products

  def produce_product
    self.products.create(farmer_id: farmer.id)
    self.update(day_counter_for_product: 0)
    # Product.create(livestock_id: chosen_livestock.id, farmer_id: farmer.id)
    if self.animal.species == "cow"
      return "You milked #{self.name}!"
    elsif self.animal.species == "sheep"
      return "You sheared #{self.name}'s wool!"
    end
  end

  def get_brushed
    self.update(brushed: 1)
    "You brushed #{self.name}! They seem to like it."
  end

  def get_fed
    self.update(fed: 1)
    "You fed #{self.name}! They seem to like it."
  end
end

class Livestock < ActiveRecord::Base
  belongs_to :animal
  belongs_to :farmer
  has_many :products

  def produce_product
    self.products.create(farmer_id: farmer.id)
    self.update(day_counter_for_product: 0)
    return "You #{animal.action_word}ed #{self.name}!"
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

class Product < ActiveRecord::Base
  belongs_to :livestock
  belongs_to :farmer

  def product_name
    self.livestock.animal.product_name
  end
end

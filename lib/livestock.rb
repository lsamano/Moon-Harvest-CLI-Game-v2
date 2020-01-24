class Livestock < ActiveRecord::Base
  belongs_to :animal
  belongs_to :farmer
  has_many :products
end

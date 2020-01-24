class CropType < ActiveRecord::Base
  has_many :seed_bags
  has_many :farmers, through: :seed_bags
end

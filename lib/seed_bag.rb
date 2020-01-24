class SeedBag < ActiveRecord::Base
  belongs_to :farmer
  belongs_to :crop_type
end

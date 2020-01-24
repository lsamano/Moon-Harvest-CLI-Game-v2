class Product < ActiveRecord::Base
  belongs_to :livestock
  belongs_to :farmer
end

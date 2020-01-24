class Animal < ActiveRecord::Base
  has_many :livestock
  has_many :farmers, through: :livestock
  has_many :products, through: :livestock
  #
end

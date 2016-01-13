class PriceTier < ActiveRecord::Base
  has_many :businesses
end

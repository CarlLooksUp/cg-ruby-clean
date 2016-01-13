class ProductType < ActiveRecord::Base
  has_and_belongs_to_many :products
  has_ancestry

  scope :ic_codes, -> { where('ic_id is not null').order(:label) }
end

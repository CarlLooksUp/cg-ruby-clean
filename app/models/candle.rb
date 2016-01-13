class Candle < ActiveRecord::Base
  
  has_one :name_object, as: :nameable
  has_one :user, through: :name_object
  accepts_nested_attributes_for :name_object
  
  def self.search_by_name(search)
    if search
      Candle.joins(:name_object).where('name_objects.name ILIKE ?', "%#{search}%")
    else
      Candle.joins(:name_object)
    end
  end
end

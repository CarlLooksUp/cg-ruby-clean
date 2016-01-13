class Transaction < ActiveRecord::Base
  belongs_to :price_tier
  belongs_to :coupon
  belongs_to :user
  belongs_to :name_object

  def amount_dollars
    self.amount / 100.0
  end
end

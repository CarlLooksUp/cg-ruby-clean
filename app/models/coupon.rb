class Coupon < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true

  def expired?
    puts (Time.now > self.expiration_date).to_s
    Time.now > self.expiration_date or self.number_of_uses == 0
  end

  def final_price(price)
    if not self.amount_off.nil?
      price - self.amount_off
    elsif not self.percent_off.nil?
      (price - (price * self.percent_off/100.0)).floor
    else
      price
    end
  end
end

module CouponsHelper
  def discount(coupon)
    if not coupon.amount_off.nil?
      "-" + number_to_currency((coupon.amount_off / 100.0)) 
    elsif not coupon.percent_off.nil?
      "-" + coupon.percent_off.to_s + "%"
    else
      "0"
    end
  end
end

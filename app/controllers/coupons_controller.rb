class CouponsController < ApplicationController
  before_action :signed_in_admin, only: [:new, :create]

  def coupon_check
     Coupon.find_by code: params[:coupon_code]
    if 
      render json: { valid_code: true }
    else
      render json: { valid_code: false }
    end
  end

  def new
    @coupon = Coupon.new
    @coupon.number_of_uses = -1
  end

  def create
    code = params[:coupon][:code]
    series = params[:series_number].blank? ? 1 : params[:series_number].to_i 
    @coupons = []
    @errors = []
    (1..series).each do |i|
      p = coupon_params.clone
      unless series == 1
        identifier = SecureRandom.hex(2)
        p[:code] = p[:code] + "_" + identifier
      end
      coupon = Coupon.new(p)
      if coupon.save
        @coupons.push coupon
      else
        @errors.push coupon.errors
      end
    end

    respond_to do |format|
      format.js
      format.html { redirect_to @coupons[0] }
    end
  end

  def destroy
  end

  def email
    coupon = Coupon.find params[:email_coupon_id]
    email = params[:email]
    UserMailer.coupon_offer(coupon, email).deliver
    respond_to do |format|
      format.js
    end
  end

  private
    def coupon_params
      params.required(:coupon).permit(:description, :code, :expiration_date, :number_of_uses, :percent_off, :amount_off)      
    end
end

class StaticContentController < ApplicationController
  def home
    @faq_set = 'home'
    @numbered = false
    @learn_more = true
    render layout: "homepage"
  end

  def about
  end

  def contact
  end

  def terms
  end

  def team
  end

  def faq
    @faq_set = 'faq_page'
    @numbered = true
    @learn_more = false
  end

  def why
  end

  def actual_use
  end

  def construction
  end

  def pricing
    @annual_id = PriceTier.find_by( machine_label: 'annual' ).id
    @renewal_id = PriceTier.find_by( machine_label: 'half_renewal' ).id
    @short_id = PriceTier.find_by( machine_label: 'short' ).id
    @lifetime_id = PriceTier.find_by( machine_label: 'lifetime' ).id
  end
end

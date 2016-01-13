namespace :prices do
  desc "Create price tiers"
  task :init_prices => :environment do |t, args|
    short = PriceTier.where(machine_label: 'short').first_or_create.update( machine_label: 'short', short_label: '4-month', long_label: '4-month - $19.95', price: 1995, months_to_expire: 4, is_renewal: false )

    annual = PriceTier.where(machine_label: 'annual').first_or_create.update( machine_label: 'annual', short_label: '1-year', long_label: '1-year - $29.95', price: 2995, months_to_expire: 12, is_renewal: false )

    lifetime = PriceTier.where(machine_label: 'lifetime').first_or_create.update( machine_label: 'lifetime', short_label: 'Lifetime', long_label: 'Lifetime - $49.95', price: 4995, months_to_expire: 1200, is_renewal: false )

    half_renewal = PriceTier.where(machine_label: 'half_renewal').first_or_create.update( machine_label: 'half_renewal', short_label: 'Extended (6 month)', long_label: 'Renewal (6 months) - $9.95', price: 995, months_to_expire: 6, is_renewal: true )

    year_renewal = PriceTier.where(machine_label: 'year_renewal').first_or_create.update( machine_label: 'year_renewal', short_label: 'Extended (1 year)', long_label: 'Renewal (1 year) - $29.95', price: 2995, months_to_expire: 12, is_renewal: true)

    life_renewal = PriceTier.where(machine_label: 'life_renewal').first_or_create.update( machine_label: 'life_renewal', short_label: 'Lifetime', long_label: 'Lifetime (extension) - $39.95', price: 3995, months_to_expire: 1200, is_renewal: true)
  end

  desc "Create some basic coupons"
  task :coupons => :environment do |t, args|
    puts "Not yet implemented"
  end

  desc "Remove old renewal price tier"
  task :cleanup_renewals => :environment do |t, args|
    renewal = PriceTier.find_by(machine_label: 'renewal')
    half_renewal = PriceTier.find_by(machine_label: 'half_renewal')
    Business.where(price_tier: p) do |biz|
      biz.update(price_tier: half_renewal)
    end
    Transaction.where(price_tier: p) do |t|
      t.update(price_tier: half_renewal)
    end
    renewal.destroy
  end
end

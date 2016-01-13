class AddRenewalToPriceTier < ActiveRecord::Migration
  def change
    add_column :price_tiers, :is_renewal, :boolean
  end
end

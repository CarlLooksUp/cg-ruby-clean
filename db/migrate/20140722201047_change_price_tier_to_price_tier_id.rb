class ChangePriceTierToPriceTierId < ActiveRecord::Migration
  def change
    rename_column :businesses, :price_tier, :price_tier_id
  end
end

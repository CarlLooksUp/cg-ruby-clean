class ChangePaymentLevelToPriceTier < ActiveRecord::Migration
  def change
    remove_column :businesses, :paid_level
    add_column :businesses, :price_tier, :integer
  end
end

class AddIntermediateLabelToPriceTiers < ActiveRecord::Migration
  def change
    rename_column :price_tiers, :short_label, :machine_label
    add_column :price_tiers, :short_label, :string
  end
end

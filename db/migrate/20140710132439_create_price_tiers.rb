class CreatePriceTiers < ActiveRecord::Migration
  def change
    create_table :price_tiers do |t|
      t.string :short_label
      t.string :long_label
      t.integer :price
      t.integer :months_to_expire

      t.timestamps
    end
  end
end

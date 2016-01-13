class AddUnspscIdToProductTypes < ActiveRecord::Migration
  def change
    add_column :product_types, :unspsc_id, :integer
  end
end

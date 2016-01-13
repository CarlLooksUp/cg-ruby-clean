class AddIcIdToProductTypes < ActiveRecord::Migration
  def change
    add_column :product_types, :ic_id, :integer
    add_index :product_types, :ic_id
  end
end

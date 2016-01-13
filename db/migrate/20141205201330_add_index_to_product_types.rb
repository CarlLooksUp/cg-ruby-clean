class AddIndexToProductTypes < ActiveRecord::Migration
  def change
    add_index :product_types, :ancestry
  end
end

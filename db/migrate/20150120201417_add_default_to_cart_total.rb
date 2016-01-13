class AddDefaultToCartTotal < ActiveRecord::Migration
  def change
    change_column :carts, :total, :integer, default: 0
  end

end

class AddDateOfFirstUseMaskToProducts < ActiveRecord::Migration
  def change
    add_column :products, :date_of_first_use_mask, :integer, default: 0
  end
end

class AddBusinessNameToProducts < ActiveRecord::Migration
  def change
    add_column :products, :business_name, :string
  end
end

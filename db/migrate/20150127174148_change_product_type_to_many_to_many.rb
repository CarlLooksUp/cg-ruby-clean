class ChangeProductTypeToManyToMany < ActiveRecord::Migration
  def change
    create_table :products_product_types, id: false do |t|
      t.belongs_to :product, index: true
      t.belongs_to :product_type, index: true  
    end
  end
end

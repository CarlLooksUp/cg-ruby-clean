class RenameProductsProductTypesTable < ActiveRecord::Migration
  def change
    rename_table :products_product_types, :product_types_products
  end
end

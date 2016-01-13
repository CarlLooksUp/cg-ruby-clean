class CreateProductsAndProductTypes < ActiveRecord::Migration
  def change
    create_table :product_types do |t|
      t.string :label
      t.string :ancestry

      t.timestamps
    end

    create_table :products do |t|
      t.references :product_type
      t.references :business
      t.string :logo_image_path
      t.string :product_image_path
      t.string :link
      t.boolean :is_service
      t.text :description
      t.date :date_of_first_use

      t.timestamps
    end
  end
end

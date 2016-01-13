class ChangeProductImageColumnNames < ActiveRecord::Migration
  def change
    rename_column :products, :product_image_path, :product_image_filename
    rename_column :products, :logo_image_path, :logo_image_filename
  end
end

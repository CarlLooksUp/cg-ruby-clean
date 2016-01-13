class AddFullImageFilenameToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :full_image_filename, :string
  end
end

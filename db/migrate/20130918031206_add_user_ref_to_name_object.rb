class AddUserRefToNameObject < ActiveRecord::Migration
  def change
    add_column :name_objects, :user_id, :integer
    add_index :name_objects, :user_id
  end
end

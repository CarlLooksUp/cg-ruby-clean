class AddIndexToNameObjectName < ActiveRecord::Migration
  def change
    add_index :name_objects, :name
  end
end

class AddIndexForNameableId < ActiveRecord::Migration
  def change
    add_index :name_objects, [:nameable_id, :nameable_type]
  end
end

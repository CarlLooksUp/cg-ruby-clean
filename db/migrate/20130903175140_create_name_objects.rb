class CreateNameObjects < ActiveRecord::Migration
  def change
    create_table :name_objects do |t|
      t.string :name
      t.integer :likes
      t.references :nameable, polymorphic: true

      t.timestamps
    end
  end
end

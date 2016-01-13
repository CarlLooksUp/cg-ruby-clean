class CreateSkiAreas < ActiveRecord::Migration
  def change
    create_table :ski_areas do |t|
      t.string :city
      t.string :state
      t.string :country

      t.timestamps
    end
  end
end

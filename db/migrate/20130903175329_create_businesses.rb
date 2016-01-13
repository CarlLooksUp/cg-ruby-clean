class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :location
      t.string :tagline

      t.timestamps
    end
  end
end

class AddTsNametoNameObjects < ActiveRecord::Migration
  def change
  	add_column :name_objects, :name_search, :tsvector
  end
end

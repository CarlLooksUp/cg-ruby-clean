class AddSourceColumnToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :source, :string
  end
end

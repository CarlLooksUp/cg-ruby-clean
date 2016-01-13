class AddStatusColumnToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :status, :string
  end
end

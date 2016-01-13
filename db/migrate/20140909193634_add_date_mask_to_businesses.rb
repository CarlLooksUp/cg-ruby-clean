class AddDateMaskToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :date_of_first_use_mask, :integer, default: 0
    add_column :businesses, :planned_date_mask, :integer, default: 0
  end
end

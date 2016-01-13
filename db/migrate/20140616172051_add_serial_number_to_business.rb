class AddSerialNumberToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :serial_number, :string
    add_index :businesses, :serial_number
  end
end

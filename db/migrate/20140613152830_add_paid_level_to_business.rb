class AddPaidLevelToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :paid_level, :integer
  end
end

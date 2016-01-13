class AddPlannedDateToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :planned_date, :date
  end
end

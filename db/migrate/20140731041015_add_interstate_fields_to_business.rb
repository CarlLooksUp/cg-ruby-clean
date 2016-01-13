class AddInterstateFieldsToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :is_interstate, :boolean
    add_column :businesses, :operating_region, :string
  end
end

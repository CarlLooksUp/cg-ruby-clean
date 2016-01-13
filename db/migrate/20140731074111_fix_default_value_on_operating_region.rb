class FixDefaultValueOnOperatingRegion < ActiveRecord::Migration
  def change
    remove_column :businesses, :operating_region
    add_column :businesses, :operating_region, :string, array: true, default: []
  end
end

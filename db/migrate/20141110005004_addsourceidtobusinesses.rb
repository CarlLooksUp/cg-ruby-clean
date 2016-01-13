class Addsourceidtobusinesses < ActiveRecord::Migration
  def change
  	add_column :businesses, :source_id, :integer
  end
end

class CreateIndexOnBusinessId < ActiveRecord::Migration
  def change
    add_index :businesses, :id, name: 'idx_business_id'
  end
end

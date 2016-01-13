class AddBetaIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :beta_id, :integer
  end
end

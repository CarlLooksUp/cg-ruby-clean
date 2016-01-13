class AddRolesUserJoinTable < ActiveRecord::Migration
  def change
    create_join_table :roles, :users do |t|
      t.index :user_id
    end
  end
end

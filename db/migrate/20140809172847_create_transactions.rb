class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :charge_id
      t.integer :amount
      t.integer :coupon_id
      t.integer :price_tier_id
      t.integer :user_id
      t.integer :name_object_id

      t.timestamps
    end
  end
end

class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :code
      t.index :code
      t.string :description
      t.integer :percent_off
      t.integer :amount_off
      t.date :expiration_date
    end
  end
end

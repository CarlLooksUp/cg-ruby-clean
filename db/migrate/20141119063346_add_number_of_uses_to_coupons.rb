class AddNumberOfUsesToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :number_of_uses, :integer
  end
end

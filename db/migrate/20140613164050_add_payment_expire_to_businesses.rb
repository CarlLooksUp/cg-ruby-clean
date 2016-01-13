class AddPaymentExpireToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :payment_expire, :date
  end
end

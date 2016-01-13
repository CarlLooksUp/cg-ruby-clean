class CreateCandles < ActiveRecord::Migration
  def change
    create_table :candles do |t|
      t.string :description
      t.string :company
      t.string :collection

      t.timestamps
    end
  end
end

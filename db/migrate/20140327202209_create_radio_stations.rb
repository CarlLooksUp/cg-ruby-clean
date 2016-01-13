class CreateRadioStations < ActiveRecord::Migration
  def change
    create_table :radio_stations do |t|
      t.string :call_sign
      t.string :frequency
      t.string :format
      t.string :city
      t.string :state
      t.string :country

      t.timestamps
    end
  end
end

class AddCriteriaToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :sic_code, :string
    add_column :businesses, :website, :string
    add_column :businesses, :phone, :string
    add_column :businesses, :entity_type, :string
    add_column :businesses, :in_use, :boolean
    add_column :businesses, :date_of_first_use, :date
    add_column :businesses, :plans_for_use, :string
  end
end

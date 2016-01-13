class AddProofOfUseFilenameToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :proof_of_use_filename, :string
  end
end

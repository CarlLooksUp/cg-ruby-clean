class Populatenamesrch < ActiveRecord::Migration
  def change
  	execute <<-SQL
  		UPDATE name_objects set name_search = to_tsvector('english',name);
  	SQL
  end
end

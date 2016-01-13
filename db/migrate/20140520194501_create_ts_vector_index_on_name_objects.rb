class CreateTsVectorIndexOnNameObjects < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      execute "create index index_name_objects_on_tsvector_name on name_objects using gin(to_tsvector('english',name));"
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      execute "drop index index_name_objects_on_tsvector_name;"
    end
  end
end

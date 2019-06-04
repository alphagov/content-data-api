class CreateLowerIndexOnBasePath < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    CREATE INDEX index_lower_base_path ON dimensions_editions (lower(base_path));
    SQL
  end

  def down
    execute <<-SQL
    DROP INDEX index_lower_base_path;
    SQL
  end
end

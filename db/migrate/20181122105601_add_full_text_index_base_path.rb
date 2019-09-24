class AddFullTextIndexBasePath < ActiveRecord::Migration[5.2]
  def up
    execute "create index dimensions_editions_base_path on dimensions_editions using gin(to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text)))"
  end

  def down
    execute "drop index dimensions_editions_base_path"
  end
end

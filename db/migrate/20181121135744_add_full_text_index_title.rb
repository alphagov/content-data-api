class AddFullTextIndexTitle < ActiveRecord::Migration[5.2]
  def up
    execute "create index dimensions_editions_title on dimensions_editions using gin(to_tsvector('english', title ))"
  end

  def down
    execute "drop index dimensions_editions_title"
  end
end

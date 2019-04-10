class RenameLatestColumnToLive < ActiveRecord::Migration[5.2]
  def up
    rename_column :dimensions_editions, :latest, :live
  end

  def down
    rename_column :dimensions_editions, :live, :latest
  end
end

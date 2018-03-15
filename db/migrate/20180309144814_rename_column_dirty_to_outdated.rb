class RenameColumnDirtyToOutdated < ActiveRecord::Migration[5.1]
  def change
    rename_column :dimensions_items, :dirty, :outdated
  end
end

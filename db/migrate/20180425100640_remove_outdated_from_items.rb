class RemoveOutdatedFromItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :dimensions_items, :outdated, :boolean
    remove_column :dimensions_items, :outdated_at, :datetime
  end
end

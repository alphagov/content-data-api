class AddOudatedAtToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :outdated_at, :datetime
  end
end

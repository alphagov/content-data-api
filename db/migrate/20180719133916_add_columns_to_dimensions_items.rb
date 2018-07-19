class AddColumnsToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :publishing_app, :string
    add_column :dimensions_items, :rendering_app, :string
    add_column :dimensions_items, :analytics_identifier, :string
    add_column :dimensions_items, :phase, :string
    add_column :dimensions_items, :previous_version, :string
    add_column :dimensions_items, :update_type, :string
    add_column :dimensions_items, :last_edited_at, :datetime
    add_column :dimensions_items, :links, :json
  end
end

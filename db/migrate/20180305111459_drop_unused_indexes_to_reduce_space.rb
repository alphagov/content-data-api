class DropUnusedIndexesToReduceSpace < ActiveRecord::Migration[5.1]
  def change
    # duplicated of [:dimensions_date_id, dimensions_item_id]
    remove_index :facts_metrics, :dimensions_date_id

    # This is no longer in used
    remove_index :content_items, :title

    # This index is no longer in use
    remove_index :dimensions_dates, :date_name_abbreviated

    # We don't need an index on both fields, only on `latest`
    remove_index :dimensions_items, [:latest, :base_path]
    add_index :dimensions_items, :latest
  end
end

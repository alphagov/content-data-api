class DropContentItemsBasePathCreatedWithoutMigration < ActiveRecord::Migration[5.1]
  def up
    if index_exists?(:dimensions_items, [:base_path], name: 'idx_cnt_bp')
      remove_index :dimensions_items, name: 'idx_cnt_bp'
    end
  end
end

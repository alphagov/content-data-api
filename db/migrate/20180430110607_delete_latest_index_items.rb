class DeleteLatestIndexItems < ActiveRecord::Migration[5.1]
  def change
    remove_index :dimensions_items, :latest
  end
end

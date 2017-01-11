class RenameLinkToBasePath < ActiveRecord::Migration[5.0]
  def change
    rename_column :content_items, :link, :base_path
  end
end

class AddWordFilesCountToContentItem < ActiveRecord::Migration[5.1]
  def change
    add_column :content_items, :number_of_word_files, :integer, default: 0
  end
end

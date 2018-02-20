class AddNumberOfWordFilesToDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :number_of_word_files, :integer
  end
end

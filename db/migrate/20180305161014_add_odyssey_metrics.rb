class AddOdysseyMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :string_length, :integer, default: 0
    add_column :dimensions_items, :sentence_count, :integer, default: 0
    add_column :dimensions_items, :word_count, :integer, default: 0
  end
end

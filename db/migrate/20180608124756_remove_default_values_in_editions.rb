class RemoveDefaultValuesInEditions < ActiveRecord::Migration[5.1]
  def change
    change_column_default :facts_editions, :string_length, nil
    change_column_default :facts_editions, :sentence_count, nil
    change_column_default :facts_editions, :word_count, nil
  end
end

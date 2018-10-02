class RenameFactsEditionColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :facts_editions, :number_of_pdfs, :pdf_count
    rename_column :facts_editions, :number_of_word_files, :doc_count
    rename_column :facts_editions, :readability_score, :readability
    rename_column :facts_editions, :string_length, :chars
    rename_column :facts_editions, :sentence_count, :sentences
    rename_column :facts_editions, :word_count, :words
  end
end

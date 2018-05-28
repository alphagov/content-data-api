class RemoveQualityMetricsFromDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :dimensions_items, :number_of_pdfs, :integer
    remove_column :dimensions_items, :number_of_word_files, :integer
    remove_column :dimensions_items, :readability_score, :integer
    remove_column :dimensions_items, :contractions_count, :integer
    remove_column :dimensions_items, :equality_count, :integer
    remove_column :dimensions_items, :indefinite_article_count, :integer
    remove_column :dimensions_items, :passive_count, :integer
    remove_column :dimensions_items, :profanities_count, :integer
    remove_column :dimensions_items, :redundant_acronyms_count, :integer
    remove_column :dimensions_items, :repeated_words_count, :integer
    remove_column :dimensions_items, :simplify_count, :integer
    remove_column :dimensions_items, :spell_count, :integer
    remove_column :dimensions_items, :string_length, :integer
    remove_column :dimensions_items, :sentence_count, :integer
    remove_column :dimensions_items, :word_count, :integer
  end
end

class AddQualityMetricsToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :readability_score, :integer
    add_column :dimensions_items, :contractions_count, :integer
    add_column :dimensions_items, :equality_count, :integer
    add_column :dimensions_items, :indefinite_article_count, :integer
    add_column :dimensions_items, :passive_count, :integer
    add_column :dimensions_items, :profanities_count, :integer
    add_column :dimensions_items, :redundant_acronyms_count, :integer
    add_column :dimensions_items, :repeated_words_count, :integer
    add_column :dimensions_items, :simplify_count, :integer
    add_column :dimensions_items, :spell_count, :integer
  end
end

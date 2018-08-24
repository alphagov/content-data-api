class DeleteOldEditionMetrics < ActiveRecord::Migration[5.2]
  def change
    remove_column :facts_editions, :contractions_count
    remove_column :facts_editions, :equality_count
    remove_column :facts_editions, :indefinite_article_count
    remove_column :facts_editions, :passive_count
    remove_column :facts_editions, :profanities_count
    remove_column :facts_editions, :redundant_acronyms_count
    remove_column :facts_editions, :repeated_words_count
    remove_column :facts_editions, :simplify_count
    remove_column :facts_editions, :spell_count
  end
end

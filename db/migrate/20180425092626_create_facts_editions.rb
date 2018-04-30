class CreateFactsEditions < ActiveRecord::Migration[5.1]
  def change
    create_table :facts_editions do |t|
      t.date :dimensions_date_id, index: true
      t.bigint :dimensions_item_id

      t.integer :number_of_pdfs
      t.integer :number_of_word_files
      t.integer :readability_score
      t.integer :contractions_count
      t.integer :equality_count
      t.integer :indefinite_article_count
      t.integer :passive_count
      t.integer :profanities_count
      t.integer :redundant_acronyms_count
      t.integer :repeated_words_count
      t.integer :simplify_count
      t.integer :spell_count
      t.integer :string_length, default: 0
      t.integer :sentence_count, default: 0
      t.integer :word_count, default: 0
      t.json :raw_json
      t.string :status, default: 'live'
      t.string :description
      t.datetime :first_published_at
      t.datetime :public_updated_at

      t.timestamps
    end

    add_foreign_key :facts_editions, :dimensions_dates, foreign_key: :dimensions_date_id, primary_key: :date
    add_foreign_key :facts_editions, :dimensions_items, foreign_key: :dimensions_item_id, primary_key: :id
    add_index :facts_editions, :dimensions_item_id, unique: true, name: 'index_facts_editions_on_dimension_ids'
  end
end

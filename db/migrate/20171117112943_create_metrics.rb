class CreateMetrics < ActiveRecord::Migration[5.1]
  def change
    create_table :metrics do |t|
      t.date :date, null: false
      t.string :content_id, null: false

      t.integer :title_length
      t.float :reading_grade
      t.integer :word_count
      t.timestamp :last_updated_at
      t.string :phase
      t.string :publication_state
      t.integer :version_number
    end

    add_foreign_key :metrics, :content_items, column: :content_id, primary_key: :content_id
    add_index :metrics, [:content_id, :date], unique: true, name: :metrics_unique_content_id_date
  end
end

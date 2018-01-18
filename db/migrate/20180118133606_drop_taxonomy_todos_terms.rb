class DropTaxonomyTodosTerms < ActiveRecord::Migration[5.1]
  def change
    drop_table :taxonomy_todos_terms do |t|
      t.bigint "term_id", null: false
      t.bigint "taxonomy_todo_id", null: false
    end
  end
end

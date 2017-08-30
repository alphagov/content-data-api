class CreateJoinTableForTodosTerms < ActiveRecord::Migration[5.1]
  def change
    create_join_table :terms, :taxonomy_todos do |t|
      t.index [:taxonomy_todo_id]
      t.index [:term_id]
      t.index %i[term_id taxonomy_todo_id], name: "index_terms_taxonomy_todos", unique: true
    end
  end
end

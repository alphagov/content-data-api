class DropTaxonomyTodos < ActiveRecord::Migration[5.1]
  def change
    drop_table :taxonomy_todos do |t|
      t.bigint "content_item_id"
      t.bigint "taxonomy_project_id"
      t.datetime "completed_at"
      t.string "completed_by"
      t.string "status", default: "todo"
      t.timestamps null: false
    end
  end
end

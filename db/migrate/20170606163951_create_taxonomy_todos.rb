class CreateTaxonomyTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :taxonomy_todos do |t|
      t.belongs_to :content_item, foreign_key: true
      t.belongs_to :taxonomy_project, foreign_key: true
      t.datetime :completed_at
      t.string :completed_by

      t.timestamps
    end
  end
end

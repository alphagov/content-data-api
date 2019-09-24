class AddStatusToTaxonomyTodos < ActiveRecord::Migration[5.1]
  def change
    add_column :taxonomy_todos, :status, :string, default: "todo"
  end
end

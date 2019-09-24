class AddParentIdToDimensionEdition < ActiveRecord::Migration[5.2]
  def change
    add_column :dimensions_editions, :parent_id, :integer, null: true

    add_index :dimensions_editions, :parent_id, name: "index_dim_edition_parent_id"
  end
end

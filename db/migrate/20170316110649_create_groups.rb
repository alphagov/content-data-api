class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :slug
      t.string :name
      t.string :group_type
      t.integer :parent_group_id, foreign_key: true, null: true

      t.timestamps
    end
  end
end

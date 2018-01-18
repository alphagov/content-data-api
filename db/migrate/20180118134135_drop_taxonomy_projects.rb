class DropTaxonomyProjects < ActiveRecord::Migration[5.1]
  def change
    drop_table :taxonomy_projects do |t|
      t.string "name"
      t.timestamps null: false
    end
  end
end

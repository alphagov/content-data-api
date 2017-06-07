class CreateTaxonomyProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :taxonomy_projects do |t|
      t.string :name

      t.timestamps
    end
  end
end

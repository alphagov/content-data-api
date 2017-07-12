class CreateTerms < ActiveRecord::Migration[5.1]
  def change
    create_table :terms do |t|
      t.string :name
      t.belongs_to :taxonomy_project
      t.timestamps
    end
  end
end

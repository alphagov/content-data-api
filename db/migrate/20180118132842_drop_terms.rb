class DropTerms < ActiveRecord::Migration[5.1]
  def change
    drop_table :terms do |t|
      t.string "name"
      t.bigint "taxonomy_project_id"
      t.timestamps null: false
    end
  end
end

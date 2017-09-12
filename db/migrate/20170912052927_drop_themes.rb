class DropThemes < ActiveRecord::Migration[5.1]
  def change
    drop_table :themes do |t|
      t.string "name", null: false
      t.timestamps

      t.index ["name"], name: "index_themes_on_name", unique: true
    end
  end
end

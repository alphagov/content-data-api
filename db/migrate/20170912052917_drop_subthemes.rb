class DropSubthemes < ActiveRecord::Migration[5.1]
  def change
    drop_table :subthemes do |t|
      t.bigint "theme_id"
      t.string "name", null: false
      t.timestamps

      t.index %w[theme_id name], name: "index_subthemes_on_theme_id_and_name", unique: true
      t.index ["theme_id"], name: "index_subthemes_on_theme_id"
    end
  end
end

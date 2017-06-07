class CreateSubthemes < ActiveRecord::Migration[5.1]
  def change
    create_table :subthemes do |t|
      t.belongs_to :theme
      t.string :name, null: false
      t.timestamps
    end

    add_index :subthemes, %i(theme_id name), unique: true
  end
end

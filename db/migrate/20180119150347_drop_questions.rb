class DropQuestions < ActiveRecord::Migration[5.1]
  def change
    drop_table :questions do |t|
      t.string "type", null: false
      t.text "text", null: false
      t.timestamps null: false
    end
  end
end

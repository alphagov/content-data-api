class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.string :type, null: false
      t.text :text, null: false

      t.timestamps
    end

    add_index :questions, :type
  end
end

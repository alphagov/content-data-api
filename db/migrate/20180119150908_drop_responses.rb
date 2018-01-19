class DropResponses < ActiveRecord::Migration[5.1]
  def change
    drop_table :responses do |t|
      t.integer "audit_id"
      t.integer "question_id"
      t.text "value"
      t.timestamps null: false
    end
  end
end

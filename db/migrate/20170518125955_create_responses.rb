class CreateResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :responses do |t|
      t.belongs_to :audit
      t.belongs_to :question
      t.text :value

      t.timestamps
    end
  end
end

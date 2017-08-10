class CreateAllocations < ActiveRecord::Migration[5.1]
  def change
    create_table :allocations do |t|
      t.references :user, foreign_key: true, null: false
      t.references :content_item, foreign_key: true, null: false

      t.timestamps
    end
  end
end

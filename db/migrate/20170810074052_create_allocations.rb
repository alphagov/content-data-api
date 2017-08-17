class CreateAllocations < ActiveRecord::Migration[5.1]
  def change
    create_table :allocations do |t|
      t.string :content_id, null: false
      t.string :uid, null: false

      t.timestamps
    end

    add_index :allocations, :content_id, unique: true
    add_index :allocations, :uid
  end
end

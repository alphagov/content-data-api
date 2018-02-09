class DropAllocations < ActiveRecord::Migration[5.1]
  def change
    drop_table :allocations do |t|
      t.string "content_id", null: false
      t.string "uid", null: false
      t.timestamps null: false
    end
  end
end

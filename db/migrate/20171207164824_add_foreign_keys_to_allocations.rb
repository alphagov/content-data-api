class AddForeignKeysToAllocations < ActiveRecord::Migration[5.1]
  def change
    add_index "users", :uid, unique: true

    add_foreign_key "allocations", "content_items", column: :content_id, primary_key: :content_id
    add_foreign_key "allocations", "users", column: :uid, primary_key: :uid
  end
end

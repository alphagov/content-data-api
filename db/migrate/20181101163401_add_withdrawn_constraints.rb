class AddWithdrawnConstraints < ActiveRecord::Migration[5.2]
  def up
    change_column_null :dimensions_editions, :withdrawn, false
  end

  def down
    change_column_null :dimensions_editions, :withdrawn, true
  end
end

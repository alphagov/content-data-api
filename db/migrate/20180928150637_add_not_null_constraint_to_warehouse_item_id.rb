class AddNotNullConstraintToWarehouseItemId < ActiveRecord::Migration[5.2]
  def change
    say "setting not null constraint on `warehouse_item_id`"
    change_column_null :dimensions_items, :warehouse_item_id, false
  end
end

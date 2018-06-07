class RemoveStatusFromDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    remove_column :dimensions_items, :status, :boolean
  end
end

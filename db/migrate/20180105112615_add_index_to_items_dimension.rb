class AddIndexToItemsDimension < ActiveRecord::Migration[5.1]
  def change
    add_index :dimensions_items, [:content_id, :link, :organisation_id], name: :dimensions_items_natural_key
    add_index :dimensions_items_temps, [:content_id, :link, :organisation_id], name: :dimensions_items_temps_natual_key
  end
end



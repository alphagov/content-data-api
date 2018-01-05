class CreateDimensionsItemsTemps < ActiveRecord::Migration[5.1]
  def change
    create_table :dimensions_items_temps, id: false do |t|
      t.string :content_id
      t.string :title
      t.string :link
      t.string :description
      t.string :organisation_id
    end
  end
end

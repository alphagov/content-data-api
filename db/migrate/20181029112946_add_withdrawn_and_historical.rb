class AddWithdrawnAndHistorical < ActiveRecord::Migration[5.2]
  def change
    add_column :dimensions_editions, :withdrawn, :boolean
    add_column :dimensions_editions, :historical, :boolean
  end
end

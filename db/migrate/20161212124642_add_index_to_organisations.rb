class AddIndexToOrganisations < ActiveRecord::Migration[5.0]
  def change
    add_index :organisations, :slug, unique: true
  end
end

class AddContentIdToOrganisations < ActiveRecord::Migration[5.0]
  def change
    add_column :organisations, :content_id, :string
  end
end

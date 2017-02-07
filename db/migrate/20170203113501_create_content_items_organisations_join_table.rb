class CreateContentItemsOrganisationsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_join_table :content_items, :organisations
  end
end

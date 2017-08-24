class DropOrganisationsItemsJoinTable < ActiveRecord::Migration[5.1]
  def change
    drop_join_table :content_items, :organisations
  end
end

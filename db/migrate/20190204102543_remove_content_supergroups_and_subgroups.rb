class RemoveContentSupergroupsAndSubgroups < ActiveRecord::Migration[5.2]
  def change
    remove_column :dimensions_editions, :content_purpose_supergroup
    remove_column :dimensions_editions, :content_purpose_subgroup
  end
end

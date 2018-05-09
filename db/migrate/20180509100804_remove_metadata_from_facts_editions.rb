class RemoveMetadataFromFactsEditions < ActiveRecord::Migration[5.1]
  def change
    remove_column :facts_editions, :raw_json, :json
    remove_column :facts_editions, :status, :string
    remove_column :facts_editions, :description, :string
    remove_column :facts_editions, :first_published_at, :datetime
    remove_column :facts_editions, :public_updated_at, :datetime
  end
end

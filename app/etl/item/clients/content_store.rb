require 'gds_api/content_store'

class Item::Clients::ContentStore
  def initialize
    @content_store_client = GdsApi::ContentStore.new(Plek.new.find('content-store'))
  end

  def fetch_raw_json(base_path)
    content_store_client.content_item(base_path).to_hash
  end

private

  attr_reader :content_store_client
end

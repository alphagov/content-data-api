require 'gds_api/content_store'
class ItemsService
  def initialize
    @publishing_api_client = Clients::PublishingAPI.new
    @content_store_client = GdsApi::ContentStore.new(Plek.new.find('content-store'))
  end

  def fetch_all
    publishing_api_client
      .fetch_all(%w[content_id base_path locale])
  end

  def fetch_raw_json(base_path)
    content_store_client.content_item(base_path).to_hash
  end

private

  attr_reader :publishing_api_client, :content_store_client
end
